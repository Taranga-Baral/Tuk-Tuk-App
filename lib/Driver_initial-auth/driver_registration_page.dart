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
import 'package:final_menu/Driver_HomePages/bottom_nav_bar.dart';
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
import 'package:bcrypt/bcrypt.dart'; // Import the bcrypt package

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  Color _color = Colors.teal;

  @override
  void initState() {
    super.initState();
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
        return AlertDialog(
          title: const Text('Account Found'),
          content: Text(
              'You already have an account: $savedEmail. Would you like to log in with this account or switch to another one?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Clear the saved email to log in with a different account
                _clearSavedEmail();
                Navigator.pop(context);
              },
              child: const Text('Switch Account'),
            ),
            TextButton(
              onPressed: () {
  // Log in with the saved account
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          BottomNavBarPage(driverEmail: savedEmail),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
},

              child: const Text('Log In'),
            ),
          ],
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
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
            _color = Colors.teal;
          });
        }
      } else {
        _showErrorMessage('No matching driver found. Please check your email.');
        setState(() {
          _color = Colors.teal;
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DriverAuthPage()));
                },
                child: const Text(
                  'New Driver? Register Here (Driver Mode)',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.teal),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your registered email:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  prefixIconColor: Colors.teal,
                  labelText: 'Enter your E-mail',
                  prefixIcon: Icon(Icons.email),
                  hintText: 'johndoe@gmail.com',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your Password:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  prefixIconColor: Colors.teal,
                  labelText: 'Enter your Password',
                  prefixIcon: Icon(Icons.lock), // Changed icon to lock
                  hintText: '********',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                controller: _passwordController,
                obscureText: true, // Make password field obscure
              ),
              const SizedBox(height: 38),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: GestureDetector(
                        onTap: _validateDriver,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width,
                          color: _color,
                          child: const Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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
