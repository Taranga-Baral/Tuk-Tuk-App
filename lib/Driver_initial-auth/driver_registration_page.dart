import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // New phone controller
  bool _isLoading = false;
  Color _color = const Color.fromARGB(255, 189, 62, 228);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if the user is already logged in
  }

  // Check if user is already registered and logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('driverEmail');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      // If email is already saved, navigate to DriverHomePage with the email
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverHomePage(driverEmail: savedEmail)),
      );
    }
  }

Future<void> _validateDriver() async {
  final String email = _emailController.text.trim();
  final String phone = _phoneController.text.trim(); // Get phone number

  if (email.isEmpty || phone.isEmpty) {
    _showErrorMessage('Please enter both email and phone number.');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Query to match both email and phone number
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('vehicleData')
        .where('email', isEqualTo: email)  
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _color = const Color.fromARGB(255, 14, 199, 54); // Green color
      });

      // Save the email locally and navigate to DriverHomePage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('driverEmail', email);

      // Navigate to DriverHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverHomePage(driverEmail: email)),
      );
    } else {
      _showErrorMessage('No matching driver found. Please check your email and phone number.');
      // Don't change the button color if details are incorrect
      setState(() {
        _color = const Color.fromARGB(255, 189, 62, 228); // Keep original color
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
                      context, MaterialPageRoute(builder: (context) => DriverAuthPage()));
                },
                child: const Text(
                  'New Driver? Register Here (Driver Mode)',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Color.fromARGB(255, 101, 12, 185)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your registered email:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                  labelText: 'Enter your E-mail',
                  prefixIcon: Icon(Icons.email),
                  hintText: 'johndoe@gmail.com',
                  filled: true,
                  fillColor: Colors.white12,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 182, 116, 194)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 200, 54, 244)),
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
                'Enter your phone number:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                  labelText: 'Enter your Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '123-456-7890',
                  filled: true,
                  fillColor: Colors.white12,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 182, 116, 194)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 200, 54, 244)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
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
    super.dispose();
  }
}
