#include <jni.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include <android/log.h>

#define LOG_TAG "NativeSecurity"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Obfuscated key parts
static const uint8_t keyParts[4][8] = {
    {0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0},
    {0xF0, 0xDE, 0xBC, 0x9A, 0x78, 0x56, 0x34, 0x12},
    {0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA},
    {0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55}
};

// Obfuscated IV parts
static const uint8_t ivParts[2][8] = {
    {0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88},
    {0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11}
};

// Runtime key construction
JNIEXPORT jbyteArray JNICALL
Java_com_example_app_SecurityProvider_getAesKey(JNIEnv *env, jobject thiz) {
    uint8_t fullKey[32];
    
    // Combine parts with transformations
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 8; j++) {
            fullKey[i*8 + j] = keyParts[i][j] ^ (0xAA + i + j);
            fullKey[i*8 + j] = (fullKey[i*8 + j] << 4) | (fullKey[i*8 + j] >> 4);
        }
    }
    
    // Additional scrambling
    for (int i = 0; i < 16; i++) {
        uint8_t temp = fullKey[i];
        fullKey[i] = fullKey[31 - i];
        fullKey[31 - i] = temp;
    }
    
    jbyteArray result = (*env)->NewByteArray(env, 32);
    (*env)->SetByteArrayRegion(env, result, 0, 32, (jbyte*)fullKey);
    
    // Securely clear
    memset(fullKey, 0, 32);
    return result;
}

JNIEXPORT jbyteArray JNICALL
Java_com_example_app_SecurityProvider_getAesIv(JNIEnv *env, jobject thiz) {
    uint8_t fullIv[16];
    
    // Combine IV parts
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 8; j++) {
            fullIv[i*8 + j] = ivParts[i][j] ^ (0x55 + i - j);
            fullIv[i*8 + j] = ~fullIv[i*8 + j];
        }
    }
    
    jbyteArray result = (*env)->NewByteArray(env, 16);
    (*env)->SetByteArrayRegion(env, result, 0, 16, (jbyte*)fullIv);
    
    memset(fullIv, 0, 16);
    return result;
}

JNIEXPORT jstring JNICALL
Java_com_example_app_SecurityProvider_getDeviceId(JNIEnv *env, jobject thiz) {
    // Get ANDROID_ID securely
    jclass settingsClass = (*env)->FindClass(env, "android/provider/Settings$Secure");
    jmethodID getString = (*env)->GetStaticMethodID(
        env, settingsClass, "getString",
        "(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;");
    
    jclass contextClass = (*env)->FindClass(env, "android/content/Context");
    jmethodID getContentResolver = (*env)->GetMethodID(
        env, contextClass, "getContentResolver", "()Landroid/content/ContentResolver;");
    
    jobject context = (*env)->CallStaticObjectMethod(
        env, contextClass, (*env)->GetStaticMethodID(
            env, contextClass, "getApplicationContext", "()Landroid/content/Context;"));
    
    jobject resolver = (*env)->CallObjectMethod(env, context, getContentResolver);
    jstring param = (*env)->NewStringUTF(env, "android_id");
    
    jstring androidId = (*env)->CallStaticObjectMethod(
        env, settingsClass, getString, resolver, param);
    
    // Clean up
    (*env)->DeleteLocalRef(env, param);
    (*env)->DeleteLocalRef(env, resolver);
    (*env)->DeleteLocalRef(env, context);
    (*env)->DeleteLocalRef(env, contextClass);
    (*env)->DeleteLocalRef(env, settingsClass);
    
    return androidId;
}

JNIEXPORT jboolean JNICALL
Java_com_example_app_SecurityProvider_verifyTamper(JNIEnv *env, jobject thiz) {
    // Check app signature
    jclass contextClass = (*env)->FindClass(env, "android/content/Context");
    jmethodID getPackageManager = (*env)->GetMethodID(
        env, contextClass, "getPackageManager", "()Landroid/content/pm/PackageManager;");
    
    jmethodID getPackageName = (*env)->GetMethodID(
        env, contextClass, "getPackageName", "()Ljava/lang/String;");
    
    jobject context = (*env)->CallStaticObjectMethod(
        env, contextClass, (*env)->GetStaticMethodID(
            env, contextClass, "getApplicationContext", "()Landroid/content/Context;"));
    
    jobject packageManager = (*env)->CallObjectMethod(env, context, getPackageManager);
    jstring packageName = (*env)->CallObjectMethod(env, context, getPackageName);
    
    jclass packageManagerClass = (*env)->FindClass(env, "android/content/pm/PackageManager");
    jmethodID getPackageInfo = (*env)->GetMethodID(
        env, packageManagerClass, "getPackageInfo",
        "(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;");
    
    jobject packageInfo = (*env)->CallObjectMethod(
        env, packageManager, getPackageInfo, packageName, 0x40); // GET_SIGNATURES
    
    jclass packageInfoClass = (*env)->FindClass(env, "android/content/pm/PackageInfo");
    jfieldID signaturesField = (*env)->GetFieldID(
        env, packageInfoClass, "signatures", "[Landroid/content/pm/Signature;");
    
    jobjectArray signatures = (*env)->GetObjectField(env, packageInfo, signaturesField);
    jobject signature = (*env)->GetObjectArrayElement(env, signatures, 0);
    
    jclass signatureClass = (*env)->FindClass(env, "android/content/pm/Signature");
    jmethodID toCharsString = (*env)->GetMethodID(
        env, signatureClass, "toCharsString", "()Ljava/lang/String;");
    
    jstring currentSignature = (*env)->CallObjectMethod(env, signature, toCharsString);
    const char* expectedSignature = "YOUR_APP_SIGNATURE"; // Replace with your signature
    
    jboolean isTampered = JNI_FALSE;
    const char* signatureStr = (*env)->GetStringUTFChars(env, currentSignature, NULL);
    
    if (strcmp(signatureStr, expectedSignature)) {
        isTampered = JNI_TRUE;
    }
    
    // Clean up
    (*env)->ReleaseStringUTFChars(env, currentSignature, signatureStr);
    (*env)->DeleteLocalRef(env, currentSignature);
    (*env)->DeleteLocalRef(env, signature);
    (*env)->DeleteLocalRef(env, signatures);
    (*env)->DeleteLocalRef(env, packageInfo);
    (*env)->DeleteLocalRef(env, packageName);
    (*env)->DeleteLocalRef(env, packageManager);
    (*env)->DeleteLocalRef(env, context);
    (*env)->DeleteLocalRef(env, contextClass);
    (*env)->DeleteLocalRef(env, packageManagerClass);
    (*env)->DeleteLocalRef(env, packageInfoClass);
    (*env)->DeleteLocalRef(env, signatureClass);
    
    return isTampered;
}

JNIEXPORT void JNICALL
Java_com_example_app_SecurityProvider_freeMemory(JNIEnv *env, jobject thiz, jlong ptr) {
    free((void*)ptr);
}