// import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
// import 'package:bcrypt/bcrypt.dart'; // Import the bcrypt package

// class DriverRegistrationPage extends StatefulWidget {
//   const DriverRegistrationPage({super.key});

//   @override
//   _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
// }

// class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   Color _color = const Color.fromARGB(255, 189, 62, 228);

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedEmail = prefs.getString('driverEmail');

//     if (savedEmail != null && savedEmail.isNotEmpty) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) => DriverHomePage(driverEmail: savedEmail)),
//       );
//     }
//   }

//   Future<void> _validateDriver() async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       _showErrorMessage('Please enter both email and Password.');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('vehicleData')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         String hashedPassword = querySnapshot.docs.first['password'];

//         if (BCrypt.checkpw(password, hashedPassword)) {
//           setState(() {
//             _color = const Color.fromARGB(255, 14, 199, 54);
//           });

//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString('driverEmail', email);

//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => DriverHomePage(driverEmail: email)),
//           );
//         } else {
//           _showErrorMessage(
//               'No matching driver found. Please check your email and Password.');
//           setState(() {
//             _color = const Color.fromARGB(255, 189, 62, 228);
//           });
//         }
//       } else {
//         _showErrorMessage('No matching driver found. Please check your email.');
//         setState(() {
//           _color = const Color.fromARGB(255, 189, 62, 228);
//         });
//       }
//     } catch (e) {
//       _showErrorMessage('Error validating driver: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showErrorMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Registration'),
//         backgroundColor: const Color.fromARGB(255, 101, 12, 185),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => DriverAuthPage()));
//                 },
//                 child: const Text(
//                   'New Driver? Register Here (Driver Mode)',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.w600,
//                       decoration: TextDecoration.underline,
//                       decorationColor: Color.fromARGB(255, 101, 12, 185)),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Enter your registered email:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 decoration: const InputDecoration(
//                   prefixIconColor: Color.fromARGB(255, 187, 109, 201),
//                   labelText: 'Enter your E-mail',
//                   prefixIcon: Icon(Icons.email),
//                   hintText: 'johndoe@gmail.com',
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Color.fromARGB(255, 182, 116, 194)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Color.fromARGB(255, 200, 54, 244)),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(18)),
//                   ),
//                 ),
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Enter your Password:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 decoration: const InputDecoration(
//                   prefixIconColor: Color.fromARGB(255, 187, 109, 201),
//                   labelText: 'Enter your Password',
//                   prefixIcon: Icon(Icons.lock), // Changed icon to lock
//                   hintText: '********',
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Color.fromARGB(255, 182, 116, 194)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide:
//                         BorderSide(color: Color.fromARGB(255, 200, 54, 244)),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(18)),
//                   ),
//                 ),
//                 controller: _passwordController,
//                 obscureText: true, // Make password field obscure
//               ),
//               const SizedBox(height: 38),
//               _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : ClipRRect(
//                       borderRadius: const BorderRadius.all(Radius.circular(12)),
//                       child: GestureDetector(
//                         onTap: _validateDriver,
//                         child: Container(
//                           height: MediaQuery.of(context).size.height * 0.07,
//                           width: MediaQuery.of(context).size.width,
//                           color: _color,
//                           child: const Center(
//                             child: Text(
//                               'Submit',
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
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }
// import 'package:final_menu/Driver_HomePages/bottom_nav_bar.dart';
// import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
// import 'package:bcrypt/bcrypt.dart'; // Import the bcrypt package

// class DriverRegistrationPage extends StatefulWidget {
//   const DriverRegistrationPage({super.key});

//   @override
//   _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
// }

// class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
// final TextEditingController _emailController = TextEditingController();
// final TextEditingController _passwordController = TextEditingController();
// bool _isLoading = false;
// Color _color = Colors.teal;

//   @override
//   void initState() {
//     super.initState();
// _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedEmail = prefs.getString('driverEmail');

//     if (savedEmail != null && savedEmail.isNotEmpty) {
//       _showLoginOptions(savedEmail);
//     }
//   }

//   void _showLoginOptions(String savedEmail) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Account Found'),
//           content: Text(
//               'You already have an account: $savedEmail. Would you like to log in with this account or switch to another one?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 // Clear the saved email to log in with a different account
//                 _clearSavedEmail();
//                 Navigator.pop(context);
//               },
//               child: const Text('Switch Account'),
//             ),
//             TextButton(
//               onPressed: () {
//   // Log in with the saved account
//   Navigator.pushAndRemoveUntil(
//     context,
//     PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) =>
//           BottomNavBarPage(driverEmail: savedEmail),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0); // Slide in from the right
//         const end = Offset.zero;
//         const curve = Curves.decelerate;

//         var tween = Tween(begin: begin, end: end)
//             .chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);

//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     ),
//     (route) => false, // This ensures all previous routes are removed
//   );
// },

//               child: const Text('Log In'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _clearSavedEmail() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('driverEmail'); // Clear the saved email
//     // Optionally, you can clear the controllers as well
//     _emailController.clear();
//     _passwordController.clear();
//   }

//   Future<void> _validateDriver() async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       _showErrorMessage('Please enter both email and Password.');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('vehicleData')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         String hashedPassword = querySnapshot.docs.first['password'];

//         if (BCrypt.checkpw(password, hashedPassword)) {
//           setState(() {
//             _color = const Color.fromARGB(255, 14, 199, 54);
//           });

//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString('driverEmail', email);

//   // Log in with the saved account
//   Navigator.pushAndRemoveUntil(
//     context,
//     PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) =>
//           BottomNavBarPage(driverEmail: email),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0); // Slide in from the right
//         const end = Offset.zero;
//         const curve = Curves.decelerate;

//         var tween = Tween(begin: begin, end: end)
//             .chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);

//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     ),
//     (route) => false, // This ensures all previous routes are removed
//   );
//         } else {
//           _showErrorMessage(
//               'No matching driver found. Please check your email and Password.');
//           setState(() {
//             _color = Colors.teal;
//           });
//         }
//       } else {
//         _showErrorMessage('No matching driver found. Please check your email.');
//         setState(() {
//           _color = Colors.teal;
//         });
//       }
//     } catch (e) {
//       _showErrorMessage('Error validating driver: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showErrorMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Registration'),
//         backgroundColor: Colors.teal,
//       ),

//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => DriverAuthPage()));
//                 },
//                 child: const Text(
//                   'New Driver? Register Here (Driver Mode)',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.w600,
//                       decoration: TextDecoration.underline,
//                       decorationColor: Colors.teal),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Enter your registered email:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 decoration: const InputDecoration(
//                   prefixIconColor: Colors.teal,
//                   labelText: 'Enter your E-mail',
//                   prefixIcon: Icon(Icons.email),
//                   hintText: 'johndoe@gmail.com',
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.teal),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.teal),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(18)),
//                   ),
//                 ),
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Enter your Password:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 decoration: const InputDecoration(
//                   prefixIconColor: Colors.teal,
//                   labelText: 'Enter your Password',
//                   prefixIcon: Icon(Icons.lock), // Changed icon to lock
//                   hintText: '********',
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.teal),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.teal),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(18)),
//                   ),
//                 ),
//                 controller: _passwordController,
//                 obscureText: true, // Make password field obscure
//               ),
//               const SizedBox(height: 38),
//               _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : ClipRRect(
//                       borderRadius: const BorderRadius.all(Radius.circular(12)),
//                       child: GestureDetector(
//                         onTap: _validateDriver,
//                         child: Container(
//                           height: MediaQuery.of(context).size.height * 0.07,
//                           width: MediaQuery.of(context).size.width,
//                           color: _color,
//                           child: const Center(
//                             child: Text(
//                               'Submit',
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
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
// void dispose() {
//   _emailController.dispose();
//   _passwordController.dispose();
//   super.dispose();
// }
// }

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/Driver_HomePages/bottom_nav_bar.dart';
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/galli_maps/map_page.dart';
import 'package:final_menu/login_screen/profile_setup.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  Color _color = const Color.fromARGB(255, 255, 82, 82);

  @override
  void initState() {
    super.initState();

    // Check if the user is already logged in
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('driverEmail');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      _showLoginOptions(savedEmail);
    }
  }

  void _showLoginOptions(String savedEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          elevation: 10, // Shadow
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Fit content height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Account Found',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                // Content
                Text(
                  'You already have an account: $savedEmail. Would you like to log in with this account or switch to another one?',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 25),
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Logout Button
                    TextButton(
                      onPressed: () {
                        // Clear the saved email to log in with a different account
                        _clearSavedEmail();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        backgroundColor:
                            redColor.withAlpha(230), // Light red background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Log In Button
                    TextButton(
                      onPressed: () {
                        // Log in with the saved account
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    BottomNavBarPage(driverEmail: savedEmail),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin =
                                  Offset(1.0, 0.0); // Slide in from the right
                              const end = Offset.zero;
                              const curve = Curves.decelerate;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                          (route) => false, // Remove all previous routes
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.green
                            .withAlpha(220), // Light green background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _clearSavedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('driverEmail'); // Clear the saved email
    // Optionally, you can clear the controllers as well
    _emailController.clear();
    _passwordController.clear();
  }

  Future<void> _validateDriver() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorMessage('Please enter both email and Password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vehicleData')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String hashedPassword = querySnapshot.docs.first['password'];

        if (BCrypt.checkpw(password, hashedPassword)) {
          setState(() {
            _color = const Color.fromARGB(255, 14, 199, 54);
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('driverEmail', email);

          // Log in with the saved account
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  BottomNavBarPage(driverEmail: email),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Slide in from the right
                const end = Offset.zero;
                const curve = Curves.decelerate;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
            (route) => false, // This ensures all previous routes are removed
          );
        } else {
          _showErrorMessage(
              'No matching driver found. Please check your email and Password.');
          setState(() {
            _color = Colors.redAccent;
          });
        }
      } else {
        _showErrorMessage('No matching driver found. Please check your email.');
        setState(() {
          _color = Colors.redAccent;
        });
      }
    } catch (e) {
      _showErrorMessage('Error validating driver: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _showErrorMessage(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message)),
  //   );
  // }

  void _showErrorMessage(String message) {
    String dialogTitle = 'Error';
    String dialogMessage = message;

    if (message == 'Please enter both email and Password.') {
      dialogTitle = 'Error';
    } else if (message ==
        'No matching driver found. Please check your email and Password.') {
      dialogTitle = 'Driver Not Found';
    } else if (message ==
        'No matching driver found. Please check your email.') {
      dialogTitle = 'Driver Not Found';
    } else {
      dialogTitle = 'Error Validating Driver';
    }

    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: dialogTitle,
      desc: '\t $dialogMessage \t',
      btnOkOnPress: () {},
    ).show();
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
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/driver_register_image.png',
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.9)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.height * 0.05,
                  backgroundImage: AssetImage(
                    'assets/signin_signup_logo.jpg',
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DriverAuthPage()),
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
              Text(
                'Verify Driver',
                style: GoogleFonts.poppins(
                  color: Color.fromARGB(255, 255, 89, 117),
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
                      controller: _emailController,
                      decoration: const InputDecoration(
                        prefixIconColor: Color.fromARGB(174, 255, 89, 117),
                        labelText: 'Enter your E-mail',
                        prefixIcon: Icon(Icons.email),
                        hintText: 'johndoe@gmail.com',
                        filled: true,
                        fillColor: Colors.white12,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 190, 170, 173)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 89, 117)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        suffixIconColor:
                            const Color.fromARGB(211, 158, 158, 158),
                        prefixIconColor:
                            const Color.fromARGB(174, 255, 89, 117),
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
                              color: Color.fromARGB(255, 190, 170, 173)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 89, 117)),
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
                        onTap: _validateDriver,
                        child: Container(
                          height: 56,
                          width: screenWidth,
                          color: _color,
                          child: Center(
                            child: Text(
                              'Driver Sign In',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: () async {
                        // Check current auth state
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          // User is logged in - check if profile is complete
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();

                          if (userDoc.exists &&
                              userDoc['phone_number'] != null &&
                              userDoc['username'] != null) {
                            // Profile complete - go to MapPage
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapPage(userId: user.uid),
                              ),
                            );
                          } else {
                            // Profile incomplete - go to ProfileSetup
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileSetupPage(user: user),
                              ),
                            );
                          }
                        } else {
                          // No user logged in - go to SignInPage
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => SignInPage()),
                          );
                        }
                      },
                      child: Text(
                        'Login as Passenger',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
