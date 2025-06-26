// import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
// import 'package:final_menu/galli_maps/map_page.dart';
// import 'package:final_menu/homepage1.dart';
// import 'package:final_menu/login_screen/sign_up_page.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SignInPage extends StatefulWidget {
//   const SignInPage({super.key});

//   @override
//   _SignInPageState createState() => _SignInPageState();
// }

// class _SignInPageState extends State<SignInPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _controllerEmail = TextEditingController();
//   final TextEditingController _controllerPassword = TextEditingController();
//   bool _obscureText = true;
//   Color _color = const Color.fromARGB(255, 189, 62, 228);

//   @override
//   void initState() {
//     super.initState();

//     // Check if the user is already logged in
//     _checkIfLoggedIn();
//   }

//   void _checkIfLoggedIn() async {
//     User? user = _auth.currentUser;

//     // If the user is already logged in, navigate to the homepage and clear the navigation stack
//     if (user != null) {
//       Future.delayed(Duration.zero, () {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//               builder: (context) => MapPage(
//                     userId: user.uid,
//                   )),
//           (Route<dynamic> route) =>
//               false, // This clears the entire navigation stack
//         );
//       });
//     }
//   }

//   void _signIn() async {
//     try {
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: _controllerEmail.text.trim(),
//         password: _controllerPassword.text.trim(),
//       );

//       setState(() {
//         _color = _color == const Color.fromARGB(255, 189, 62, 228)
//             ? const Color.fromARGB(255, 14, 199, 54)
//             : const Color.fromARGB(255, 189, 62, 228);
//       });

//       if (userCredential.user != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Sign In Successful'),
//               duration: Duration(seconds: 1)),
//         );

//         Future.delayed(Duration(seconds: 1), () {
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//                 builder: (context) => MapPage(
//                       userId: userCredential.user!.uid,
//                     )),
//             (Route<dynamic> route) => false,
//           );
//         });
//       }
//     } catch (e) {
//       print('Error signing in: $e');
//       // showDialog(
//       //   context: context,
//       //   builder: (context) => AlertDialog(
//       //     title: Text('Sign In Failed'),
//       //     content: Text('Try again with valid credentials.'),
//       //     actions: <Widget>[
//       //       TextButton(
//       //           child: Text('OK'),
//       //           onPressed: () => Navigator.of(context).pop()),
//       //     ],
//       //   ),
//       // );

//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           title: Column(
//             children: const [
//               Icon(Icons.error,
//                   color: Color.fromARGB(220, 244, 67, 54),
//                   size: 40), // Error icon
//               SizedBox(height: 8),

//               Text(
//                 'Sign In Failed',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//           content: const Text(
//             'Try again with valid credentials.',
//             style: TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: <Widget>[
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.5,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor:
//                       Color.fromARGB(214, 163, 66, 192), //purplish bg
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//                 child: const Text(
//                   'OK',
//                   style: TextStyle(
//                     color: Colors.white, // White text
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var screenHeight = MediaQuery.of(context).size.height;
//     var screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(screenHeight * 0.25),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(0),
//             bottomRight: Radius.circular(0),
//           ),
//           child: Container(
//             height: screenHeight * 0.39,
//             width: screenWidth,

//             // color: const Color.fromARGB(255, 200, 54, 244),
//             decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: AssetImage(
//                       'assets/signin_container_image.png',
//                     ),
//                     fit: BoxFit.cover,
//                     opacity: 1)),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: MediaQuery.of(context).size.height * 0.05,
//                   backgroundImage: AssetImage('assets/signin_signup_logo.jpg'),
//                 ),
//                 const SizedBox(height: 12),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => RegistrationPage()),
//                     );
//                   },
//                   child: const Text(
//                     'Not Yet IN? Sign Up Here.',
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w600,
//                       decorationColor: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 14),
//               const Text(
//                 'Sign In',
//                 style: TextStyle(
//                   color: Color.fromARGB(255, 163, 66, 192),
//                   fontSize: 38,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               Padding(
//                 padding: EdgeInsets.all(12),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 30),
//                     // TextFormField(
//                     //   controller: _controllerEmail,
//                     //   decoration: const InputDecoration(
//                     //     prefixIconColor: Color.fromARGB(255, 187, 109, 201),
//                     //     labelText: 'Enter your E-mail',
//                     //     prefixIcon: Icon(Icons.email),
//                     //     hintText: 'johndoe@gmail.com',
//                     //     filled: true,
//                     //     fillColor: Colors.white12,
//                     //     enabledBorder: OutlineInputBorder(
//                     //       borderSide: BorderSide(
//                     //           color: Color.fromARGB(255, 182, 116, 194)),
//                     //     ),
//                     //     focusedBorder: OutlineInputBorder(
//                     //       borderSide: BorderSide(
//                     //           color: Color.fromARGB(255, 200, 54, 244)),
//                     //     ),
//                     //     border: OutlineInputBorder(
//                     //       borderRadius: BorderRadius.all(Radius.circular(18)),
//                     //     ),
//                     //   ),
//                     // ),

//                     TextFormField(
//                       controller: _controllerEmail,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.email,
//                             color: Color.fromARGB(
//                                 255, 187, 109, 201)), // Always purplish
//                         labelText: 'Enter your E-mail',
//                         hintText: 'johndoe@gmail.com',
//                         hintStyle: TextStyle(color: Colors.grey[500]),
//                         labelStyle: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey[600], // Grey label when inactive
//                           fontWeight: FontWeight.w500,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                           borderSide: BorderSide(
//                             color: const Color.fromARGB(
//                                 69, 189, 189, 189)!, // Silverish-grey
//                             width: 1.0, // Thin border when untouched
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                           borderSide: BorderSide(
//                             color: Color.fromARGB(
//                                 255, 187, 109, 201), // Purplish color
//                             width: 1.5, // Slightly broader when focused
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                         contentPadding:
//                             EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//                       ),
//                       style: TextStyle(color: Colors.black87),
//                     ),

//                     const SizedBox(height: 30),
//                     // TextFormField(
//                     //   controller: _controllerPassword,
//                     //   obscureText: _obscureText,
//                     //   decoration: InputDecoration(
//                     //     suffixIconColor:
//                     //         const Color.fromARGB(255, 180, 113, 192),
//                     //     prefixIconColor:
//                     //         const Color.fromARGB(255, 187, 109, 201),
//                     //     labelText: 'Enter your Password',
//                     //     prefixIcon: const Icon(Icons.password),
//                     //     filled: true,
//                     //     fillColor: Colors.white12,
//                     //     suffixIcon: IconButton(
//                     //       icon: Icon(_obscureText
//                     //           ? Icons.visibility_off
//                     //           : Icons.visibility),
//                     //       onPressed: () {
//                     //         setState(() {
//                     //           _obscureText = !_obscureText;
//                     //         });
//                     //       },
//                     //     ),
//                     //     enabledBorder: const OutlineInputBorder(
//                     //       borderSide: BorderSide(
//                     //           color: Color.fromARGB(255, 182, 116, 194)),
//                     //     ),
//                     //     focusedBorder: const OutlineInputBorder(
//                     //       borderSide: BorderSide(
//                     //           color: Color.fromARGB(255, 200, 54, 244)),
//                     //     ),
//                     //     border: const OutlineInputBorder(
//                     //       borderRadius: BorderRadius.all(Radius.circular(18)),
//                     //     ),
//                     //   ),
//                     // ),

//                     TextFormField(
//                       controller: _controllerPassword,
//                       obscureText: _obscureText,
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(Icons.lock,
//                             color: Color.fromARGB(
//                                 255, 187, 109, 201)), // Always purplish
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureText
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color: const Color.fromARGB(123, 158, 158, 158),
//                             size: 20,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscureText = !_obscureText;
//                             });
//                           },
//                         ),
//                         labelText: 'Enter your Password',
//                         hintText: '••••••••',
//                         hintStyle: TextStyle(color: Colors.grey[500]),
//                         labelStyle: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey[600], // Grey label when inactive
//                           fontWeight: FontWeight.w500, // Slightly bolder label
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                           borderSide: BorderSide(
//                             color: const Color.fromARGB(
//                                 69, 189, 189, 189)!, // Silverish-grey,
//                             width: 1.0, // Thin border when untouched
//                           ),
//                         ),
//                         focusedBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                           borderSide: BorderSide(
//                             color: Color.fromARGB(
//                                 255, 187, 109, 201), // Purplish color
//                             width: 1.5, // Slightly broader when focused
//                           ),
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 15, horizontal: 15),
//                       ),
//                       style: TextStyle(color: Colors.black87),
//                     ),

//                     const SizedBox(height: 38),
//                     ClipRRect(
//                       borderRadius: const BorderRadius.all(Radius.circular(12)),
//                       child: GestureDetector(
//                         onTap: _signIn,
//                         child: Container(
//                           // height: screenHeight * 0.08,
//                           height: 55,
//                           width: screenWidth,
//                           color: _color,
//                           child: const Center(
//                             child: Text(
//                               'Sign In',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => DriverAuthPage()),
//                         );
//                       },
//                       child: Container(
//                         width: screenWidth * 0.9,
//                         padding: EdgeInsets.all(screenHeight * 0.02),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(
//                               color: const Color.fromARGB(160, 200, 54, 244),
//                               width: 2),
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: const Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Driver Mode',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color.fromARGB(190, 200, 54, 244),
//                               ),
//                             ),
//                             // const SizedBox(height: 8),
//                             // Text(
//                             //   'Sign in or register as a driver to access driver-specific features.',
//                             //   style: GoogleFonts.amaticSc(
//                             //     fontSize: screenHeight * 0.025,
//                             //     color: const Color.fromARGB(255, 182, 116, 194),
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/galli_maps/map_page.dart';
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/login_screen/profile_setup.dart';
import 'package:final_menu/login_screen/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  bool _obscureText = true;
  Color _color = const Color.fromARGB(255, 189, 62, 228);
  bool _isGoogleSigningIn = false;

  // Add this at class level
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Verify profile is complete
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists ||
        userDoc['phone_number'] == null ||
        userDoc['username'] == null) {
      // Force sign out if profile incomplete
      await _auth.signOut();
      await _googleSignIn.signOut();
      return;
    }

    // Only allow access if profile is complete
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MapPage(userId: user.uid)),
      (route) => false,
    );
  }

  void _signIn() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );

      setState(() {
        _color = _color == const Color.fromARGB(255, 189, 62, 228)
            ? const Color.fromARGB(255, 14, 199, 54)
            : const Color.fromARGB(255, 189, 62, 228);
      });

      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Sign In Successful'),
              duration: Duration(seconds: 1)),
        );

        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => MapPage(
                      userId: userCredential.user!.uid,
                    )),
            (Route<dynamic> route) => false,
          );
        });
      }
    } catch (e) {
      print('Error signing in: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sign In Failed'),
          content: Text('Invalid email or password. Please try again.'),
          actions: <Widget>[
            TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isGoogleSigningIn = true);

      // Clear existing sessions
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isGoogleSigningIn = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      setState(() => _isGoogleSigningIn = false);

      if (!userDoc.exists ||
          userDoc['phone_number'] == null ||
          userDoc['username'] == null) {
        // New user or incomplete profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupPage(
              user: userCredential.user!,
              googleAccessToken: googleAuth.accessToken,
              googleIdToken: googleAuth.idToken,
            ),
          ),
        );
      } else {
        // Existing user with complete profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MapPage(userId: userCredential.user!.uid),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGoogleSigningIn = false);
      _showErrorDialog('Sign In Failed', _getErrorMessage(e));
      debugPrint('Google Sign-In Error: $e');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          return 'This email is already linked with another sign-in method';
        case 'invalid-credential':
          return 'Invalid authentication credentials';
        default:
          return 'Authentication failed. Please try again.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'This email is already linked with another sign-in method.';
      case 'invalid-credential':
        return 'Invalid authentication credentials.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled for this app.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      default:
        return 'Sign-In failed. Please try again.';
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Column(
          children: [
            Icon(Icons.error,
                color: Color.fromARGB(220, 244, 67, 54), size: 40),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(214, 163, 66, 192),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.25),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          child: Container(
            height: screenHeight * 0.39,
            width: screenWidth,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/signin_container_image.png',
                    ),
                    fit: BoxFit.cover,
                    opacity: 1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.height * 0.05,
                  backgroundImage: AssetImage('assets/signin_signup_logo.jpg'),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverAuthPage()),
                        );
                      },
                      child: Text(
                        ' Login as Driver?',
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(178, 14, 13, 13),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  const SizedBox(height: 14),
                  Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      color: Color.fromARGB(255, 163, 66, 192),
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _controllerEmail,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email,
                                color: Color.fromARGB(255, 187, 109, 201)),
                            labelText: 'E-mail',
                            hintText: 'johndoe@gmail.com',
                            hintStyle:
                                GoogleFonts.poppins(color: Colors.grey[500]),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(69, 189, 189, 189)!,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 187, 109, 201),
                                width: 1.5,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                          style: TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _controllerPassword,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock,
                                color: Color.fromARGB(255, 187, 109, 201)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color.fromARGB(123, 158, 158, 158),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            labelText: 'Password',
                            hintText: '••••••••',
                            hintStyle:
                                GoogleFonts.poppins(color: Colors.grey[500]),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(69, 189, 189, 189)!,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 187, 109, 201),
                                width: 1.5,
                              ),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                          style: TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 38),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: _signIn,
                            child: Container(
                              height: 55,
                              width: screenWidth,
                              color: _color,
                              child: Center(
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegistrationPage()),
                              );
                            },
                            child: Text(
                              'Create new account',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromARGB(178, 14, 13, 13),
                                  fontSize: 16),
                            )),
                        SizedBox(
                          height: 75,
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: _signInWithGoogle,
                              child: Text(
                                'Or continue with',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    // color: Color.fromRGBO(243, 83, 33, 1),
                                    color: Color.fromARGB(255, 163, 66, 192),
                                    fontSize: 16),
                              ),
                            ),
                            SizedBox(height: 14),
                            InkWell(
                              onTap:
                                  _isGoogleSigningIn ? null : _signInWithGoogle,
                              child: _isGoogleSigningIn
                                  ? CircularProgressIndicator(
                                      color: Color.fromARGB(255, 163, 66, 192),
                                    )
                                  : Image.asset(
                                      'assets/google.png',
                                      height: 22,
                                    ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
