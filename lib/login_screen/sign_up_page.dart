import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/galli_maps/map_page.dart';
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  bool _obscureText = true;
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Color _color = const Color.fromARGB(255, 189, 62, 228);

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // If sign in is successful
        if (userCredential.user != null) {
          final uid = userCredential.user!.uid;
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'username': _usernameController.text.trim(),
            'phone_number': _mobileController.text.trim(),
            'email': _emailController.text.trim(),
          });

          // Show Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign Up Successful'),
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to HomePage after 1 second
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage1()),
            );
          });

          setState(() {
            _color = _color == const Color.fromARGB(255, 189, 62, 228)
                ? const Color.fromARGB(255, 14, 199, 54)
                : const Color.fromARGB(255, 189, 62, 228);
          });
        }
      } catch (e) {
        print('Error Signing Up: $e');
        // Handle sign in errors here

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sign Up Failed'),
            content: Text(
                'Either email is already taken or the format is incorrect'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenWidth, screenHeight * 0.2),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
          child: Container(
            height: screenHeight * 0.39,
            width: screenWidth,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/signup_container_image.png'),
                    fit: BoxFit.cover,
                    opacity: 1)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.height * 0.05,
                    backgroundImage:
                        AssetImage('assets/signin_signup_logo.jpg'),
                  ),
                  SizedBox(
                    height: 12,
                  ),
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
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 14,
                ),
                Text(
                  'Sign up',
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 163, 66, 192),
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                //               RichText(
                //   text: TextSpan(
                //     children: const [
                //       TextSpan(
                //         text: 'Sign ',
                //         style: TextStyle(
                //           color: Color.fromARGB(255, 163, 66, 192), // Purple color
                //           fontSize: 30,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //       TextSpan(
                //         text: 'Up',
                //         style: TextStyle(
                //           color: Colors.redAccent, // Adjust color as needed
                //           fontSize: 30,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //       TextSpan(
                //         text: '.',
                //         style: TextStyle(
                //           color: Colors.redAccent, // Adjust color as needed
                //           fontSize: 30,
                //           fontWeight: FontWeight.w900,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 18,
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // TextFormField(
                        //   controller: _usernameController,
                        //   decoration: const InputDecoration(
                        //     labelText: 'Enter your Username',
                        //     prefixIcon: Icon(Icons.person_2),
                        //     hintText: 'Taranga Baral',
                        //     filled: true,
                        //     fillColor: Colors.white12,
                        //     prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //         color: Color.fromARGB(255, 182, 116, 194),
                        //       ),
                        //     ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //           color: Color.fromARGB(255, 200, 54, 244)),
                        //     ),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.all(Radius.circular(18)),
                        //     ),
                        //   ),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter a username';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_2,
                                color: Color.fromARGB(
                                    255, 187, 109, 201)), // Always purplish
                            labelText: 'Enter your Username',
                            hintText: 'Taranga Baral',
                            hintStyle:
                                GoogleFonts.poppins(color: Colors.grey[500]),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              color:
                                  Colors.grey[600], // Grey label when inactive
                              fontWeight:
                                  FontWeight.w500, // Slightly bolder label
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(
                                    69, 189, 189, 189), // Silverish-grey,
                                width: 1.0, // Thin border when untouched
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 187, 109, 201), // Purplish color
                                width: 1.5, // Slightly broader when focused
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        // TextFormField(
                        //   keyboardType: TextInputType.number,
                        //   controller: _mobileController,
                        //   decoration: const InputDecoration(
                        //     labelText: 'Enter your Mobile Number',
                        //     prefixIcon: Icon(Icons.phone),
                        //     hintText: '98********',
                        //     filled: true,
                        //     fillColor: Colors.white12,
                        //     prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //         color: Color.fromARGB(255, 182, 116, 194),
                        //       ),
                        //     ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //           color: Color.fromARGB(255, 200, 54, 244)),
                        //     ),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.all(Radius.circular(18)),
                        //     ),
                        //   ),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter a mobile phone number';
                        //     } else if (value.length < 10 || value.length > 10) {
                        //       return 'Please Enter Valid Mobile Number';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _mobileController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone,
                                color: Color.fromARGB(
                                    255, 187, 109, 201)), // Always purplish
                            labelText: 'Enter your Mobile Number',
                            hintText: '98********',
                            hintStyle:
                                GoogleFonts.poppins(color: Colors.grey[500]),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              color:
                                  Colors.grey[600], // Grey label when inactive
                              fontWeight:
                                  FontWeight.w500, // Slightly bolder label
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(
                                    69, 189, 189, 189), // Silverish-grey,
                                width: 1.0, // Thin border when untouched
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 187, 109, 201), // Purplish color
                                width: 1.5, // Slightly broader when focused
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a mobile phone number';
                            } else if (value.length != 10) {
                              return 'Please enter a valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        // TextFormField(
                        //   controller: _emailController,
                        //   decoration: const InputDecoration(
                        //     labelText: 'Enter your E-mail',
                        //     prefixIcon: Icon(Icons.email),
                        //     hintText: 'johndoe@gmail.com',
                        //     filled: true,
                        //     fillColor: Colors.white12,
                        //     prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //         color: Color.fromARGB(255, 182, 116, 194),
                        //       ),
                        //     ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //           color: Color.fromARGB(255, 200, 54, 244)),
                        //     ),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.all(Radius.circular(18)),
                        //     ),
                        //   ),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter an email';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email,
                                color: Color.fromARGB(
                                    255, 187, 109, 201)), // Always purplish
                            labelText: 'Enter your E-mail',
                            hintText: 'example@gmail.com',
                            hintStyle:
                                GoogleFonts.poppins(color: Colors.grey[500]),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              color:
                                  Colors.grey[600], // Grey label when inactive
                              fontWeight:
                                  FontWeight.w500, // Slightly bolder label
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(
                                    69, 189, 189, 189), // Silverish-grey,
                                width: 1.0, // Thin border when untouched
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 187, 109, 201), // Purplish color
                                width: 1.5, // Slightly broader when focused
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email address';
                            } else if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
                        // TextFormField(
                        //   controller: _passwordController,
                        //   obscureText: _obscureText,
                        //   decoration: InputDecoration(
                        //     labelText: 'Enter your Password',
                        //     prefixIcon: const Icon(Icons.password),
                        //     filled: true,
                        //     fillColor: Colors.white12,
                        //     prefixIconColor:
                        //         const Color.fromARGB(255, 187, 109, 201),
                        //     suffixIconColor:
                        //         const Color.fromARGB(255, 180, 113, 192),
                        //     suffixIcon: IconButton(
                        //       icon: Icon(_obscureText
                        //           ? Icons.visibility_off
                        //           : Icons.visibility),
                        //       onPressed: () {
                        //         setState(() {
                        //           _obscureText = !_obscureText;
                        //         });
                        //       },
                        //     ),
                        //     enabledBorder: const OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //         color: Color.fromARGB(255, 182, 116, 194),
                        //       ),
                        //     ),
                        //     focusedBorder: const OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //           color: Color.fromARGB(255, 200, 54, 244)),
                        //     ),
                        //     border: const OutlineInputBorder(
                        //       borderRadius: BorderRadius.all(Radius.circular(18)),
                        //     ),
                        //   ),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter a password';
                        //     } else if (value.length < 6) {
                        //       return 'Password must be at least 6 characters long';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock,
                                color: Color.fromARGB(
                                    255, 187, 109, 201)), // Always purplish
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
                            labelText: 'Enter your Password',
                            hintText: '••••••••',
                            hintStyle:
                                GoogleFonts.poppins(color: Colors.grey[500]),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              color:
                                  Colors.grey[600], // Grey label when inactive
                              fontWeight:
                                  FontWeight.w500, // Slightly bolder label
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(
                                    69, 189, 189, 189), // Silverish-grey,
                                width: 1.0, // Thin border when untouched
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 187, 109, 201), // Purplish color
                                width: 1.5, // Slightly broader when focused
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 38),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: _register,
                            child: Container(
                              // height: screenHeight * 0.08,
                              height: 55,
                              width: screenWidth,
                              color: _color,
                              child: const Center(
                                child: Text(
                                  'Register',
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

                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInPage()),
                              );
                            },
                            child: RichText(
                                text: TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Already? ',
                                    style: GoogleFonts.poppins(
                                        color: const Color.fromARGB(
                                            178, 14, 13, 13),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(
                                    text: 'Sign In',
                                    style: GoogleFonts.poppins(
                                        color:
                                            Color.fromARGB(255, 163, 66, 192),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
