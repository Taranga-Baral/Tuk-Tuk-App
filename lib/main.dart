import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/galli_maps/map_page.dart';
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:final_menu/splash_screen/splash_screen.dart';
import 'package:final_menu/tutorial_screen_user/tutorial_screen_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_menu/login_screen/sign_up_page.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    // systemNavigationBarColor: const Color.fromARGB(255, 95, 144, 228),
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeLocationServices();

  await _preloadGoogleFonts();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCrHL5E_oHQjng6ApZza8TGqx1CxxKH7vM',
        authDomain: 'menu-app-8cced.firebaseapp.com',
        projectId: 'menu-app-8cced',
        storageBucket: 'menu-app-8cced.appspot.com',
        messagingSenderId: '387296614571',
        appId: '1:387296614571:web:f19599ed85e2d017b73fee',
      ),
    );
    await checkUpdateAvailability(BuildContext);
    await checkUpdateVersion();
  } else {
    await Firebase.initializeApp();

    await checkUpdateAvailability(BuildContext);
    await checkUpdateVersion();
  }

  // runApp(const MyApp());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp()); // Replace MyApp with your root widget
  });
}

Future<void> _initializeLocationServices() async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled, show a dialog to enable them
    await _showLocationServiceDisabledAlert();
  }

  // Check location permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, show a dialog
      await _showLocationPermissionDeniedAlert();
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, show a dialog to open app settings
    await _showLocationPermissionPermanentlyDeniedAlert();
  }
}

Future<void> _showLocationServiceDisabledAlert() async {
  // This would typically be shown in the context of a widget
  // For main.dart, we'll just print a message
  print(
      'Location services are disabled. Please enable them in device settings.');
}

Future<void> _showLocationPermissionDeniedAlert() async {
  print(
      'Location permissions are denied. Please grant permissions to use location features.');
}

Future<void> _showLocationPermissionPermanentlyDeniedAlert() async {
  print(
      'Location permissions are permanently denied. Please enable them in app settings.');
}

Future<void> _preloadGoogleFonts() async {
  // Initialize Google Fonts (required for preloading)
  await GoogleFonts.pendingFonts([
    // List all font families used in your app
    GoogleFonts.getFont('Outfit'),
    GoogleFonts.getFont('Hind'),
    GoogleFonts.getFont('Montserrat'),
    GoogleFonts.getFont('Comic Neue'),
    GoogleFonts.getFont('Lexend'),
    GoogleFonts.getFont('Ubuntu'),
    GoogleFonts.getFont('Poppins'),
  ]);
}

//update or not
Future<bool> checkUpdateAvailability(context) async {
  try {
    // Access Firestore collection and document
    DocumentSnapshot updateSnapshot = await FirebaseFirestore.instance
        .collection('update') // Replace with your collection name
        .doc('rkgn9bRgnWLSdVSJxj1H') // Replace with your document ID
        .get();

    // Check if document exists and retrieve value of is_update_available
    if (updateSnapshot.exists) {
      bool isUpdateAvailable = updateSnapshot['is_update_available'];
      print(isUpdateAvailable);

      if (isUpdateAvailable) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('New Update Available!'),
              content:
                  Text('A new update is available. Do you want to update now?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Later'),
                ),
                TextButton(
                  onPressed: () {
                    // Implement update logic here
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Update Now'),
                ),
              ],
            );
          },
        );
      }

      return isUpdateAvailable;
    } else {
      // Handle case where document does not exist
      return false;
    }
  } catch (e) {
    // Handle error
    print('Error checking update availability: $e');
    return false;
  }
}

Future<String> checkUpdateVersion() async {
  try {
    // Access Firestore collection and document
    DocumentSnapshot updateSnapshot = await FirebaseFirestore.instance
        .collection('update') // Replace with your collection name
        .doc('rkgn9bRgnWLSdVSJxj1H') // Replace with your document ID
        .get();

    // Check if document exists and retrieve value of is_update_available
    if (updateSnapshot.exists) {
      String version = updateSnapshot['version'];
      print(version);

      return version;
    } else {
      // Handle case where document does not exist
      return '';
    }
  } catch (e) {
    // Handle error
    print('Error checking update availability: $e');
    return '';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuk Tuk',
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isFirstLaunch = true; // Default to true
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for minimum 3 seconds
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _checkTutorialStatus(),
      _verifyUserProfile(),
    ]);

    setState(() => _isLoading = false);
  }

  Future<void> _checkTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('hasSeenTutorial') ?? false;
  }

  Future<void> _verifyUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists ||
          userDoc['phone_number'] == null ||
          userDoc['username'] == null) {
        // Force logout if profile is incomplete
        await _auth.signOut();
        if (await GoogleSignIn().isSignedIn()) {
          await GoogleSignIn().signOut();
        }
      }
    } catch (e) {
      print('Profile verification error: $e');
      await _auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    if (_isFirstLaunch) {
      return TutorialPageUser();
    }

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          if (user == null) {
            return const SignInPage();
          }

          // Verify profile completion before allowing access
          return FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.done) {
                final userDoc = userSnapshot.data;

                if (userDoc != null &&
                    userDoc.exists &&
                    userDoc['phone_number'] != null &&
                    userDoc['username'] != null) {
                  return HomePage1();
                } else {
                  // Force logout if profile is incomplete
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _auth.signOut();
                    GoogleSignIn().signOut();
                  });
                  return const SignInPage();
                }
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
