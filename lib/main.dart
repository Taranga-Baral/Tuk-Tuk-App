import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/galli_maps/map_page.dart';
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/splash_screen/splash_screen.dart';
import 'package:final_menu/tutorial_screen_user/tutorial_screen_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_menu/login_screen/sign_up_page.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    // Display splash screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Check if the tutorial has been completed
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;

    setState(() {
      _isLoading = false;
      _isFirstLaunch =
          !hasSeenTutorial; // If tutorial is seen, not first launch
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always display the splash screen until loading is complete
    if (_isLoading) {
      return const SplashScreen();
    }

    // After loading is complete, check if the tutorial needs to be shown
    if (_isFirstLaunch) {
      return TutorialPageUser(); // Show tutorial
    } else {
      // After tutorial or for registered users, check if user is logged in
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return MapPage(
          userId: user.uid,
        ); // Navigate to HomePage1 if logged in
      } else {
        return const RegistrationPage(); // Navigate to Registration if not logged in
      }
    }
  }
}
