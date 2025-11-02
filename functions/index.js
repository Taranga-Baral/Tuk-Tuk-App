const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const GALLI_MAPS_TOKEN = "1b040d87-2d67-47d5-aa97-f8b47d301fec";

exports.generateTempToken = functions.https.onCall(async (data, context) => {
  // 🔐 1. Require user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError( "unauthenticated", "Login required" );
  }

  // ⏳ 2. Create a short-lived token (e.g., 5 minutes)
  const tempToken = await admin.firestore().collection("tokens").add({
    token: GALLI_MAPS_TOKEN,
    userId: context.auth.uid,
    expiresAt: new Date(Date.now() + 5 * 60 * 1000), // 5 mins expiry
  });

  // 3. Return a **reference ID** (not the actual token)
  return {tokenId: tempToken.id};
});

