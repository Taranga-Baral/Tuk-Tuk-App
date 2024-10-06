// import 'package:final_menu/homepage1.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:final_menu/login_screen/sign_up_page.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: 'AIzaSyCrHL5E_oHQjng6ApZza8TGqx1CxxKH7vM',
//         authDomain: 'menu-app-8cced.firebaseapp.com',
//         projectId: 'menu-app-8cced',
//         storageBucket: 'menu-app-8cced.appspot.com',
//         messagingSenderId: '387296614571',
//         appId: '1:387296614571:web:f19599ed85e2d017b73fee',
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const AuthWrapper(),
//     );
//   }
// }

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   _AuthWrapperState createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkUser();
//   }

//   Future<void> _checkUser() async {
//     // Display splash screen for 3 seconds
//     await Future.delayed(const Duration(seconds: 20));

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Always display the splash screen until loading is complete
//     if (_isLoading) {
//       return const SplashScreen();
//     }

//     // After loading is complete, check the user status
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       return const HomePage1();
//     } else {
//       return const RegistrationPage();
//     }
//   }
// }

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize AnimationController
//     _controller = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     );

//     // Define Animation
//     _animation = Tween<double>(begin: 0.0, end: 10.0).animate(_controller);

//     // Start the animation
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: FadeTransition(
//           opacity: _animation,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/logo.png', // Your logo path
//                 width: 150, // Adjust as needed
//                 height: 150, // Adjust as needed
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Book your Rides for Fair Fare',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Made by Taranga Baral',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/splash_screen/splash_screen.dart';
import 'package:final_menu/tutorial_screen_user/tutorial_screen_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_menu/login_screen/sign_up_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      _isFirstLaunch = !hasSeenTutorial; // If tutorial is seen, not first launch
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
        return HomePage1(); // Navigate to HomePage1 if logged in
      } else {
        return const RegistrationPage(); // Navigate to Registration if not logged in
      }
    }
  }
}

