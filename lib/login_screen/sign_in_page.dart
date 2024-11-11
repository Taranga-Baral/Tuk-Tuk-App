// import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
// import 'package:final_menu/homepage1.dart';
// import 'package:final_menu/login_screen/sign_up_page.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';

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

//   void _signIn() async {
//     try {
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: _controllerEmail.text,
//         password: _controllerPassword.text,
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
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => HomePage1()),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error signing in: $e');
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Sign In Failed'),
//           content: Text('Invalid email or password. Please try again.'),
//           actions: <Widget>[
//             TextButton(
//                 child: Text('OK'),
//                 onPressed: () => Navigator.of(context).pop()),
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
//         preferredSize: Size.fromHeight(screenHeight * 0.2),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(28),
//             bottomRight: Radius.circular(24),
//           ),
//           child: Container(
//             height: screenHeight * 0.39,
//             width: screenWidth,
//             color: const Color.fromARGB(255, 200, 54, 244),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundImage: AssetImage('assets/signin_signup_logo.jpg'),
//                 ),
//                 const SizedBox(height: 12),
//                 InkWell(
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
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       decoration: TextDecoration.underline,
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
//                     TextFormField(
//                       controller: _controllerEmail,
//                       decoration: const InputDecoration(
//                         prefixIconColor:
//                             Color.fromARGB(255, 187, 109, 201),
//                         labelText: 'Enter your E-mail',
//                         prefixIcon: Icon(Icons.email),
//                         hintText: 'johndoe@gmail.com',
//                         filled: true,
//                         fillColor: Colors.white12,
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color.fromARGB(255, 182, 116, 194)),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color.fromARGB(255, 200, 54, 244)),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(18)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     TextFormField(
//                       controller: _controllerPassword,
//                       obscureText: _obscureText,
//                       decoration: InputDecoration(
//                         suffixIconColor:
//                             const Color.fromARGB(255, 180, 113, 192),
//                         prefixIconColor:
//                             const Color.fromARGB(255, 187, 109, 201),
//                         labelText: 'Enter your Password',
//                         prefixIcon: const Icon(Icons.password),
//                         filled: true,
//                         fillColor: Colors.white12,
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscureText
//                               ? Icons.visibility_off
//                               : Icons.visibility),
//                           onPressed: () {
//                             setState(() {
//                               _obscureText = !_obscureText;
//                             });
//                           },
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color.fromARGB(255, 182, 116, 194)),
//                         ),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color.fromARGB(255, 200, 54, 244)),
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(18)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 38),
//                     ClipRRect(
//                       borderRadius: const BorderRadius.all(Radius.circular(12)),
//                       child: GestureDetector(
//                         onTap: _signIn,
//                         child: Container(
//                           height: screenHeight * 0.07,
//                           width: screenWidth,
//                           color: _color,
//                           child: const Center(
//                             child: Text(
//                               'Sign In',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 26,
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
//                               color: const Color.fromARGB(255, 200, 54, 244),
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
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Driver Mode',
//                               style: GoogleFonts.amaticSc(
//                                 fontSize: screenHeight * 0.04,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color.fromARGB(255, 200, 54, 244),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
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
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/login_screen/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  bool _obscureText = true;
  Color _color = const Color.fromARGB(255, 189, 62, 228);

  @override
  void initState() {
    super.initState();

    // Check if the user is already logged in
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() async {
  User? user = _auth.currentUser;

  // If the user is already logged in, navigate to the homepage and clear the navigation stack
  if (user != null) {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage1()),
        (Route<dynamic> route) => false,  // This clears the entire navigation stack
      );
    });
  }
}


  void _signIn() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
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
  MaterialPageRoute(builder: (context) => HomePage1()),
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
            
            // color: const Color.fromARGB(255, 200, 54, 244),
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/signin_container_image.png',),fit: BoxFit.cover,opacity: 1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.height *0.05,
                  backgroundImage: AssetImage('assets/signin_signup_logo.jpg'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage()),
                    );
                  },
                  child: const Text(
                    'Not Yet IN? Sign Up Here.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 14),
              const Text(
                'Sign In',
                style: TextStyle(
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
                      decoration: const InputDecoration(
                        prefixIconColor:
                            Color.fromARGB(255, 187, 109, 201),
                        labelText: 'Enter your E-mail',
                        prefixIcon: Icon(Icons.email),
                        hintText: 'johndoe@gmail.com',
                        filled: true,
                        fillColor: Colors.white12,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 182, 116, 194)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 200, 54, 244)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _controllerPassword,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        suffixIconColor:
                            const Color.fromARGB(255, 180, 113, 192),
                        prefixIconColor:
                            const Color.fromARGB(255, 187, 109, 201),
                        labelText: 'Enter your Password',
                        prefixIcon: const Icon(Icons.password),
                        filled: true,
                        fillColor: Colors.white12,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 182, 116, 194)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 200, 54, 244)),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: GestureDetector(
                        onTap: _signIn,
                        child: Container(
                          height: screenHeight * 0.08,
                          width: screenWidth,
                          color: _color,
                          child: const Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverAuthPage()),
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.9,
                        padding: EdgeInsets.all(screenHeight * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color.fromARGB(255, 200, 54, 244),
                              width: 2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Driver Mode',
                              style: GoogleFonts.amaticSc(
                                fontSize: screenHeight * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 200, 54, 244),
                              ),
                            ),
                            // const SizedBox(height: 8),
                            // Text(
                            //   'Sign in or register as a driver to access driver-specific features.',
                            //   style: GoogleFonts.amaticSc(
                            //     fontSize: screenHeight * 0.025,
                            //     color: const Color.fromARGB(255, 182, 116, 194),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
