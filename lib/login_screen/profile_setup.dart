// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/galli_maps/map_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ProfileSetupPage extends StatefulWidget {
//   final User user;
//   final String? googleAccessToken;
//   final String? googleIdToken;

//   const ProfileSetupPage({
//     super.key,
//     required this.user,
//     this.googleAccessToken,
//     this.googleIdToken,
//   });

//   @override
//   _ProfileSetupPageState createState() => _ProfileSetupPageState();
// }

// class _ProfileSetupPageState extends State<ProfileSetupPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _usernameController = TextEditingController();
//   bool _isSubmitting = false;
//   bool _usernameAvailable = true;

//   Future<void> _submitProfile() async {
//     if (!_formKey.currentState!.validate() || !_usernameAvailable) return;

//     setState(() => _isSubmitting = true);

//     try {
//       // 1. Verify username uniqueness
//       final usernameSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('username', isEqualTo: _usernameController.text.trim())
//           .limit(1)
//           .get();

//       if (usernameSnapshot.docs.isNotEmpty) {
//         setState(() => _usernameAvailable = false);
//         throw Exception('Username already taken');
//       }

//       // 2. Save profile data (atomic operation)
//       final batch = FirebaseFirestore.instance.batch();
//       final userRef =
//           FirebaseFirestore.instance.collection('users').doc(widget.user.uid);

//       batch.set(userRef, {
//         'userId': widget.user.uid,
//         'email': widget.user.email,
//         'phone_number': _phoneController.text.trim(),
//         'username': _usernameController.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       await batch.commit();

//       // 3. Only after successful save, persist auth
//       if (widget.googleAccessToken != null && widget.googleIdToken != null) {
//         await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
//         await FirebaseAuth.instance.signInWithCredential(
//           GoogleAuthProvider.credential(
//             accessToken: widget.googleAccessToken,
//             idToken: widget.googleIdToken,
//           ),
//         );
//       }

//       // 4. Navigate with clean stack
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => MapPage(userId: widget.user.uid)),
//         (route) => false,
//       );
//     } catch (e) {
//       setState(() => _isSubmitting = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> _checkUsernameAvailability(String value) async {
//     if (value.length < 4) return;
//     final exists = await FirebaseFirestore.instance
//         .collection('users')
//         .where('username', isEqualTo: value.trim())
//         .limit(1)
//         .get()
//         .then((snap) => snap.docs.isNotEmpty);

//     setState(() => _usernameAvailable = !exists);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Complete Your Profile'),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Email (read-only from Google)
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 initialValue: widget.user.email,
//                 readOnly: true,
//               ),
//               const SizedBox(height: 20),

//               // Phone Number
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number',
//                   hintText: '+1 234 567 8901',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Required';
//                   if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
//                     return 'Enter valid phone number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Username with live validation
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                   hintText: 'cool_user123',
//                   border: const OutlineInputBorder(),
//                   suffixIcon: _usernameController.text.isEmpty
//                       ? null
//                       : Icon(
//                           _usernameAvailable ? Icons.check : Icons.close,
//                           color: _usernameAvailable ? Colors.green : Colors.red,
//                         ),
//                 ),
//                 onChanged: _checkUsernameAvailability,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Required';
//                   if (value.length < 4) return 'Minimum 4 characters';
//                   if (!_usernameAvailable) return 'Username taken';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 30),

//               // Submit Button
//               ElevatedButton(
//                 onPressed: _isSubmitting ? null : _submitProfile,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: _isSubmitting
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text('COMPLETE PROFILE',
//                         style: TextStyle(fontSize: 18)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _usernameController.dispose();
//     super.dispose();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/galli_maps/map_page.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart'; // Added for Poppins font

class ProfileSetupPage extends StatefulWidget {
  final User user;
  final String? googleAccessToken;
  final String? googleIdToken;

  const ProfileSetupPage({
    super.key,
    required this.user,
    this.googleAccessToken,
    this.googleIdToken,
  });

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isSubmitting = false;
  bool _usernameAvailable = true;

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate() || !_usernameAvailable) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Verify username uniqueness
      final usernameSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: _usernameController.text.trim())
          .limit(1)
          .get();

      if (usernameSnapshot.docs.isNotEmpty) {
        setState(() => _usernameAvailable = false);
        throw Exception('Username already taken');
      }

      // 2. Save profile data (atomic operation)
      final batch = FirebaseFirestore.instance.batch();
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.user.uid);

      batch.set(userRef, {
        'userId': widget.user.uid,
        'email': widget.user.email,
        'phone_number': _phoneController.text.trim(),
        'username': _usernameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // 3. Only after successful save, persist auth
      // 3. Handle Google auth persistence properly
      if (widget.googleAccessToken != null && widget.googleIdToken != null) {
        try {
          await FirebaseAuth.instance.signInWithCredential(
            GoogleAuthProvider.credential(
              accessToken: widget.googleAccessToken,
              idToken: widget.googleIdToken,
            ),
          );
        } catch (e) {
          debugPrint('Google re-authentication error: $e');
          // Proceed anyway since we already have the user
        }
      }

      // 4. Navigate with clean stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MapPage(userId: widget.user.uid)),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      String errorMessage = 'Profile setup failed';

      if (e is FirebaseException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _checkUsernameAvailability(String value) async {
    if (value.length < 4) return;
    final exists = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: value.trim())
        .limit(1)
        .get()
        .then((snap) => snap.docs.isNotEmpty);

    setState(() => _usernameAvailable = !exists);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(26),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SignInPage()),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 18, right: 18, top: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Your Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Form Container
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email (read-only from Google)
                          TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.mail,
                                  color: Color.fromARGB(
                                      255, 187, 109, 201)), // Always purplish
                              labelText: 'Your Registered Email',
                              hintStyle:
                                  GoogleFonts.poppins(color: Colors.grey[500]),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors
                                    .grey[600], // Grey label when inactive
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
                            initialValue: widget.user.email,
                            readOnly: true,
                          ),
                          const SizedBox(height: 24),

                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.phone,
                                  color: Color.fromARGB(
                                      255, 187, 109, 201)), // Always purplish
                              labelText: 'Your Phone Number',
                              hintText: '+977 **********',
                              hintStyle:
                                  GoogleFonts.poppins(color: Colors.grey[500]),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors
                                    .grey[600], // Grey label when inactive
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
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (!RegExp(r'^\+?[0-9]{10,15}$')
                                  .hasMatch(value)) {
                                return 'Enter valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Username with live validation
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_3,
                                  color: Color.fromARGB(
                                      255, 187, 109, 201)), // Always purplish
                              labelText: 'Your Username',
                              hintText: 'Taranga Baral',
                              hintStyle:
                                  GoogleFonts.poppins(color: Colors.grey[500]),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors
                                    .grey[600], // Grey label when inactive
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
                            onChanged: _checkUsernameAvailability,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length < 4) {
                                return 'Minimum 4 characters';
                              }
                              if (!_usernameAvailable) return 'Username taken';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            )),

            // Submit Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 189, 62, 228),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Complete Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
