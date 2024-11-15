import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DriverAuthPage extends StatefulWidget {
  const DriverAuthPage({super.key});

  @override
  _DriverAuthPageState createState() => _DriverAuthPageState();
}

Color _color = const Color.fromARGB(255, 255, 89, 117);

class _DriverAuthPageState extends State<DriverAuthPage> {
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  DateTime? _selectedDateOfBirth;
  final _picker = ImagePicker();
  String _selectedVehicleType = 'Tuk Tuk'; // Default value for dropdown

  final _numberPlateController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _bluebookPhoto;
  File? _citizenshipFrontPhoto;
  File? _licenseFrontPhoto;
  File? _selfieWithCitizenshipPhoto;
  File? _selfieWithLicensePhoto;
  File? _profilePicturePhoto;

  String? _bluebookPhotoUrl;
  String? _citizenshipFrontUrl;
  String? _licenseFrontUrl;
  String? _selfieWithCitizenshipUrl;
  String? _selfieWithLicenseUrl;
  String? _profilePictureUrl;

  int _activeStep = 0; // Manage active step
  bool _obscurePassword = true; // To toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  bool _termsAccepted = false; // Track terms acceptance
  final _formKey = GlobalKey<FormState>();
  final _formKeylast = GlobalKey<FormState>();
  bool _validateFields() {
    final email = _emailController.text;
    final phoneNumber = _phoneController.text.replaceAll('+977 ', '');

    // Regex for email and phone number validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final phoneNumberRegex = RegExp(r'^\d{10}$'); // 10 digits

    // Validate text fields
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _dobController.text.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        !emailRegex.hasMatch(email) ||
        !phoneNumberRegex.hasMatch(phoneNumber)) {
      showSnackBar(context, 'Please fill all required fields correctly.');
      return false;
    }

    // Validate if all images are selected
    if (_bluebookPhoto == null ||
        _citizenshipFrontPhoto == null ||
        _licenseFrontPhoto == null ||
        _selfieWithCitizenshipPhoto == null ||
        _selfieWithLicensePhoto == null ||
        _profilePicturePhoto == null) {
      showSnackBar(context, 'Please select all required images.');
      return false;
    }

    return true;
  }

  Future<void> _pickImage(String imageType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (imageType) {
          case 'bluebook':
            _bluebookPhoto = File(pickedFile.path);
            break;
          case 'citizenshipFront':
            _citizenshipFrontPhoto = File(pickedFile.path);
            break;
          case 'licenseFront':
            _licenseFrontPhoto = File(pickedFile.path);
            break;
          case 'selfieWithCitizenship':
            _selfieWithCitizenshipPhoto = File(pickedFile.path);
            break;
          case 'selfieWithLicense':
            _selfieWithLicensePhoto = File(pickedFile.path);
            break;
          case 'profilePicture':
            _profilePicturePhoto = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<String?> _uploadImage(
      File imageFile, String imageType, String driverId) async {
    if (!imageFile.existsSync()) {
      print('File does not exist for $imageType');
      return null;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'images/$driverId/$imageType/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image for $imageType: $e');
      return null;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_validateFields()) {
      return; // If validation fails, do not proceed
    }

    try {
      String hashedPassword =
          BCrypt.hashpw(_passwordController.text, BCrypt.gensalt());
      String driverId = _emailController.text; // Unique identifier (email)
      bool allUploadsSuccessful = true;

      // Show the loading popup with an image
      showDialog(
        context: context,
        barrierDismissible: false, // Disable back button and outside touch
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Please wait while we process your request.')),
              );
              return false; // Prevent back button
            },
            child: Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/loading_screen.gif', height: 100),
                    const SizedBox(height: 10),
                    const Text('Uploading and processing data...'),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Upload images and get URLs
      if (_bluebookPhoto != null) {
        _bluebookPhotoUrl =
            await _uploadImage(_bluebookPhoto!, 'bluebook', driverId);
        if (_bluebookPhotoUrl == null) allUploadsSuccessful = false;
      }
      if (_citizenshipFrontPhoto != null) {
        _citizenshipFrontUrl = await _uploadImage(
            _citizenshipFrontPhoto!, 'citizenshipFront', driverId);
        if (_citizenshipFrontUrl == null) allUploadsSuccessful = false;
      }
      if (_licenseFrontPhoto != null) {
        _licenseFrontUrl =
            await _uploadImage(_licenseFrontPhoto!, 'licenseFront', driverId);
        if (_licenseFrontUrl == null) allUploadsSuccessful = false;
      }
      if (_selfieWithCitizenshipPhoto != null) {
        _selfieWithCitizenshipUrl = await _uploadImage(
            _selfieWithCitizenshipPhoto!, 'selfieWithCitizenship', driverId);
        if (_selfieWithCitizenshipUrl == null) allUploadsSuccessful = false;
      }
      if (_selfieWithLicensePhoto != null) {
        _selfieWithLicenseUrl = await _uploadImage(
            _selfieWithLicensePhoto!, 'selfieWithLicense', driverId);
        if (_selfieWithLicenseUrl == null) allUploadsSuccessful = false;
      }
      if (_profilePicturePhoto != null) {
        _profilePictureUrl = await _uploadImage(
            _profilePicturePhoto!, 'profilePicture', driverId);
        if (_profilePictureUrl == null) allUploadsSuccessful = false;
      }

      // Check if all uploads were successful
      if (!allUploadsSuccessful) {
        showSnackBar(
            context, 'Some images failed to upload. Please try again.');
        Navigator.pop(context); // Close the popup
        return;
      }

      // Proceed with saving the form data in Firestore
      final vehicleDataRef =
          FirebaseFirestore.instance.collection('vehicleData').doc(driverId);
      final docSnapshot = await vehicleDataRef.get();

      if (docSnapshot.exists) {
        // Update existing fields
        await vehicleDataRef.update({
          'vehicleType': _selectedVehicleType,
          'numberPlate': _numberPlateController.text,
          'brand': _brandController.text,
          'color': _colorController.text,
          if (_bluebookPhotoUrl != null) 'bluebookPhotoUrl': _bluebookPhotoUrl,
          'licenseNumber': _licenseNumberController.text,
          if (_citizenshipFrontUrl != null)
            'citizenshipFrontUrl': _citizenshipFrontUrl,
          if (_licenseFrontUrl != null) 'licenseFrontUrl': _licenseFrontUrl,
          if (_selfieWithCitizenshipUrl != null)
            'selfieWithCitizenshipUrl': _selfieWithCitizenshipUrl,
          if (_selfieWithLicenseUrl != null)
            'selfieWithLicenseUrl': _selfieWithLicenseUrl,
          if (_profilePictureUrl != null)
            'profilePictureUrl': _profilePictureUrl,
          'name': _nameController.text,
          'address': _addressController.text,
          'dob': _dobController.text,
          'email': _emailController.text,
          'password': hashedPassword,
          'phone': _phoneController.text,
        });
      } else {
        // Create new document
        await vehicleDataRef.set({
          'vehicleType': _selectedVehicleType,
          'numberPlate': _numberPlateController.text,
          'brand': _brandController.text,
          'color': _colorController.text,
          'bluebookPhotoUrl': _bluebookPhotoUrl ?? '',
          'licenseNumber': _licenseNumberController.text,
          'citizenshipFrontUrl': _citizenshipFrontUrl ?? '',
          'licenseFrontUrl': _licenseFrontUrl ?? '',
          'selfieWithCitizenshipUrl': _selfieWithCitizenshipUrl ?? '',
          'selfieWithLicenseUrl': _selfieWithLicenseUrl ?? '',
          'profilePictureUrl': _profilePictureUrl ?? '',
          'name': _nameController.text,
          'address': _addressController.text,
          'dob': _dobController.text,
          'email': _emailController.text,
          'password': hashedPassword,
          'phone': _phoneController.text,
        });
      }

      // Success
      showSnackBar(context, 'Registration successful.');
      await Future.delayed(const Duration(seconds: 3));

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverRegistrationPage()),
      );
    } catch (e) {
      print('Error submitting form: $e');
      showSnackBar(context, 'An error occurred. Please try again.');
      Navigator.pop(context); // Close the popup in case of error
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
        // Format the date and update the controller
        _dobController.text =
            '${_selectedDateOfBirth!.toLocal()}'.split(' ')[0];
        _color = _color == const Color.fromARGB(255, 189, 62, 228)
            ? const Color.fromARGB(255, 14, 199, 54)
            : const Color.fromARGB(255, 189, 62, 228);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushReplacement(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => DriverRegistrationPage()));
              //   },
              //   child: const Text(
              //     ' Already? Sign In Here (Driver Mode)',
              //     style: TextStyle(
              //         color: Colors.black,
              //         fontWeight: FontWeight.w600,
              //         decoration: TextDecoration.underline,
              //         decorationColor: Color.fromARGB(255, 101, 12, 185)),
              //   ),
              // ),
              // SizedBox(
              //   height: 5,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushReplacement(context,
              //         MaterialPageRoute(builder: (context) => SignInPage()));
              //   },
              //   child: const Text(
              //     'Passenger Mode',
              //     style: TextStyle(
              //         color: Colors.black,
              //         fontWeight: FontWeight.w600,
              //         decoration: TextDecoration.underline,
              //         decorationColor: Color.fromARGB(255, 101, 12, 185)),
              //   ),
              // ),

              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DriverRegistrationPage()),
        );
      },
      icon: Icon(Icons.local_taxi, color: Colors.pink),
      tooltip: 'Already? Sign In Here (Driver Mode)',
    ),
    SizedBox(width: 20),
    IconButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      },
      icon: Icon(Icons.person, color: Colors.red),
      
      tooltip: 'Passenger Mode',
    ),
  ],
),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width,
                child: EasyStepper(
                  
                  activeStep: _activeStep,
                  onStepReached: (index) {},
                  steps: const [
                    EasyStep(
                      // title: 'Terms & Conditions',
                      icon: Icon(Icons.assignment),
                    ),
                    EasyStep(
                      // title: 'Vehicle Info',
                      icon: Icon(Icons.car_rental_rounded),
                    ),
                    EasyStep(
                      // title: 'Documents',
                      icon: Icon(Icons.attach_file_outlined),
                    ),
                    EasyStep(
                      // title: 'Personal Info',
                      icon: Icon(Icons.person),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_activeStep == 0) ...[
                        // Terms haru
                        Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height < 400 ? MediaQuery.of(context).size.height *0.15 : MediaQuery.of(context).size.height *0.5,
                                
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SizedBox(
                                    height: 400,
                                    child: ListView(
                                      children: [
                                        Text(
                                          _termsAndConditionsText,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _termsAccepted,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _termsAccepted = newValue ?? false;
                                      });
                                    },
                                  ),
                                  const Text('Agree'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                child: GestureDetector(
                                  onTap: () {
                                    if (_termsAccepted) {
                                      setState(() {
                                        _activeStep =
                                            1; // Move to Vehicle Info step
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please accept the terms and conditions.')),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height * 0.07,
                                    width: MediaQuery.of(context).size.width,
                                    color: _color,
                                    child: const Center(
                                      child: Text(
                                        'Agree and Continue',
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
                      ],
                      if (_activeStep == 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: Icon(Icons.arrow_back),
                              onTap: () {
                                setState(() {
                                  _activeStep = 0;
                                });
                              },
                            ),
                          ],
                        ),
                        Form(
                          key: _formKey, // Form key for validation
                          child: Column(
                            children: [
                              // Vehicle Info Step
                              DropdownButton<String>(
                                value: _selectedVehicleType,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedVehicleType = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Tuk Tuk',
                                  'Motor Bike',
                                  'Taxi'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              SizedBox(
                                height: 5,
                              ),
        
                              // Number Plate TextFormField
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null; // Valid input
                                },
                                controller: _numberPlateController,
                                decoration: const InputDecoration(
                                  labelText: 'Number Plate',
                                  prefixIcon: Icon(
                                      Icons.format_list_numbered_rtl_outlined),
                                  filled: true,
                                  fillColor: Colors.white12,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 255, 89, 117),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
        
                              // Brand TextFormField
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null; // Valid input
                                },
                                controller: _brandController,
                                decoration: const InputDecoration(
                                  labelText: 'Brand',
                                  prefixIcon:
                                      Icon(Icons.electric_rickshaw_outlined),
                                  filled: true,
                                  fillColor: Colors.white12,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 255, 89, 117),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
        
                              // Color TextFormField
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null; // Valid input
                                },
                                controller: _colorController,
                                decoration: const InputDecoration(
                                  labelText: 'Color',
                                  prefixIcon: Icon(Icons.color_lens_outlined),
                                  filled: true,
                                  fillColor: Colors.white12,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 255, 89, 117),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
        
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null; // Valid input
                                },
                                controller: _licenseNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'License Number',
                                  prefixIcon: Icon(Icons.numbers),
                                  filled: true,
                                  fillColor: Colors.white12,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 255, 89, 117),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18)),
                                  ),
                                ),
                              ),
        
                              const SizedBox(height: 20),
        
                              // Next Button
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                child: GestureDetector(
                                  onTap: () {
                                    if (_formKey.currentState == null ||
                                        !_formKey.currentState!.validate()) {
                                      // If form is invalid, show a SnackBar and prevent navigation
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please fill out all fields before proceeding.')),
                                      );
                                      return; // Prevent further execution
                                    }
        
                                    // Validate the form
                                    if (_formKey.currentState!.validate()) {
                                      // If the form is valid, proceed to the next step
                                      setState(() {
                                        _activeStep = 2;
                                      });
                                    } else {
                                      // If validation fails, show the errors in the form
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please fill out all fields')),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height * 0.07,
                                    width: MediaQuery.of(context).size.width,
                                    color: _color,
                                    child: const Center(
                                      child: Text(
                                        'Next',
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
                        )
                      ],
                      if (_activeStep == 2) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: Icon(Icons.arrow_back),
                              onTap: () {
                                setState(() {
                                  _activeStep = 0;
                                });
                              },
                            ),
                          ],
                        ),
        
                        SizedBox(
                          height: 20,
                        ),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: () => _pickImage('bluebook'),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.055,
                              width: MediaQuery.of(context).size.width * 0.9,
                              color: _color,
                              child: const Center(
                                child: Text(
                                  'Upload BlueBook Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
        
                        SizedBox(
                          height: 25,
                        ),
                        if (_bluebookPhoto != null) ...[
                          Image.file(_bluebookPhoto!),
                        ],
        
                        SizedBox(
                          height: 25,
                        ),
        
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: () => _pickImage('citizenshipFront'),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.055,
                              width: MediaQuery.of(context).size.width * 0.9,
                              color: _color,
                              child: const Center(
                                child: Text(
                                  'Upload Citizenship Front Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        if (_citizenshipFrontPhoto != null) ...[
                          Image.file(_citizenshipFrontPhoto!),
                        ],
        
                        SizedBox(
                          height: 25,
                        ),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: () => _pickImage('licenseFront'),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.055,
                              width: MediaQuery.of(context).size.width * 0.9,
                              color: _color,
                              child: const Center(
                                child: Text(
                                  'Upload License Front Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
        
                        SizedBox(
                          height: 25,
                        ),
        
                        if (_licenseFrontPhoto != null) ...[
                          Image.file(_licenseFrontPhoto!),
                        ],
        
                        SizedBox(
                          height: 25,
                        ),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: () => _pickImage('selfieWithCitizenship'),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.055,
                              width: MediaQuery.of(context).size.width * 0.9,
                              color: _color,
                              child: const Center(
                                child: Text(
                                  'Upload Selfie with Citizenship Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
        
                        SizedBox(
                          height: 25,
                        ),
        
                        if (_selfieWithCitizenshipPhoto != null) ...[
                          Image.file(_selfieWithCitizenshipPhoto!),
                        ],
                        // ElevatedButton(
                        //   onPressed: () => _pickImage(''),
                        //   child: const Text(''),
                        // ),
                        SizedBox(
                          height: 25,
                        ),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: () => _pickImage('selfieWithLicense'),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.055,
                              width: MediaQuery.of(context).size.width * 0.9,
                              color: _color,
                              child: const Center(
                                child: Text(
                                  'Upload Selfie with License Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
        
                        SizedBox(
                          height: 25,
                        ),
        
                        if (_selfieWithLicensePhoto != null) ...[
                          Image.file(_selfieWithLicensePhoto!),
                        ],
        
                        SizedBox(
                          height: 25,
                        ),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: () => _pickImage('profilePicture'),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.055,
                              width: MediaQuery.of(context).size.width * 0.9,
                              color: _color,
                              child: const Center(
                                child: Text(
                                  'Upload your Profile Picture',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
        
                        SizedBox(
                          height: 25,
                        ),
        
                        if (_profilePicturePhoto != null) ...[
                          Image.file(_profilePicturePhoto!),
                        ],
        
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _activeStep =
                                  3; // Move to Personal Information step
                            });
                          },
                          child: const Text('Next'),
                        ),
                      ],
                      if (_activeStep == 3) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: Icon(Icons.arrow_back),
                              onTap: () {
                                setState(() {
                                  _activeStep = 0;
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                return null; // Return null if the input is valid
                              },
                              controller: _nameController,
                              decoration: const InputDecoration(
                                prefixIconColor:
                                    Color.fromARGB(240, 255, 89, 117),
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.person),
                                filled: true,
                                fillColor: Colors.white12,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 255, 89, 117)),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                ),
                              ),
                            ),
        
                            SizedBox(
                              height: 25,
                            ),
        
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                return null; // Return null if the input is valid
                              },
                              controller: _addressController,
                              decoration: const InputDecoration(
                                prefixIconColor:
                                    Color.fromARGB(240, 255, 89, 117),
                                labelText: 'Address',
                                prefixIcon: Icon(Icons.place_outlined),
                                filled: true,
                                fillColor: Colors.white12,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 255, 89, 117)),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
        
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                return null; // Return null if the input is valid
                              },
                              controller: _dobController,
                              decoration: const InputDecoration(
                                prefixIconColor:
                                    Color.fromARGB(240, 255, 89, 117),
                                labelText: 'Date of Birth',
                                prefixIcon: Icon(Icons.date_range),
                                filled: true,
                                fillColor: Colors.white12,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 255, 89, 117)),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                ),
                              ),
                              readOnly: true,
                              onTap: _selectDateOfBirth,
                            ),
        
                            SizedBox(
                              height: 25,
                            ),
        
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                prefixIconColor:
                                    Color.fromARGB(240, 255, 89, 117),
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                filled: true,
                                fillColor: Colors.white12,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 200, 54, 244)),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final emailRegex =
                                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email address.';
                                } else if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address.';
                                }
                                return null; // Return null if validation is successful
                              },
                            ),
        
                            SizedBox(
                              height: 25,
                            ),
                            Form(
                              key: _formKeylast,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText:
                                    _obscurePassword, // Obscure text if true
                                decoration: InputDecoration(
                                  prefixIconColor:
                                      const Color.fromARGB(240, 255, 89, 117),
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.password),
                                  filled: true,
                                  fillColor: Colors.white12,
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(110, 255, 89, 117)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 255, 89, 117)),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18)),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons
                                              .visibility, // Show the correct icon
                                      color: Color.fromARGB(240, 255, 89, 117)
                                    ),
                                    onPressed:
                                        _togglePasswordVisibility, // Toggle password visibility
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required';
                                  } else if (value.length < 6) {
                                    // Check for minimum length
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null; // Return null if validation is successful
                                },
                              ),
                            ),
        
                            SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                prefixIconColor:
                                    Color.fromARGB(240, 255, 89, 117),
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone),
                                filled: true,
                                fillColor: Colors.white12,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(110, 255, 89, 117)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 255, 89, 117)),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                final phoneNumber =
                                    value?.replaceAll('+977 ', '') ?? '';
                                final phoneNumberRegex = RegExp(r'^\d{10}$');
                                if (!phoneNumberRegex.hasMatch(phoneNumber)) {
                                  return 'Phone number must be 10 digits excluding +977.';
                                }
                                return null; // Return null if validation is successful
                              },
                            ),
        
                            const SizedBox(height: 30),
                            // ElevatedButton(
                            //   onPressed: () {
                            // if (_validateFields()) {
                            //   _submitForm();
                            // }
                            //   },
                            //   child: const Text('Submit'),
                            // )
                          ],
                        ),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: GestureDetector(
                            onTap: () {
                              if (_formKeylast.currentState == null ||
                                  !_formKeylast.currentState!.validate()) {
                                // If form is invalid, show a SnackBar and prevent navigation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please fill out all fields before proceeding.')),
                                );
                                return; // Prevent further execution
                              }
        
                              if (_validateFields()) {
                                _submitForm(context);
                              }
                            },
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _termsAndConditionsText {
    return '''
Terms And Condition : 

These Terms and Conditions ("Terms") govern your use of the Tuk Tuk Sawari Mobile application ("App"), operated by Tuk Tuk Sawari. By accessing or using our App, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use the App.
1. Scope of Service

1.1 Service Description: Tuk Tuk Ride facilitates transportation services within Chitwan district, aiming to provide reliable and fair rides.

1.2 Expansion: The service may expand to additional areas beyond Chitwan in the future.
2. User Responsibilities

2.1 Passenger Responsibilities: Passengers agree to use the App responsibly, provide accurate information, not to steal or hack any data by any means, and to treat drivers with respect.

2.2 Driver Responsibilities: Drivers agree to provide safe transportation, to pay 6% of each Ride, maintain their vehicles, and comply with local regulations.
3. Fees and Payments

3.1 Passenger Side: The passenger side of the App is currently free to use for a limited time. Some features may become paid in the future, which will be communicated in advance.

3.2 Driver Commission: Drivers agree to pay a commission of 6% per ride to Tuk Tuk Sawari for each Ride fare generated through the App.
4. User Conduct

4.1 Prohibited Conduct: Users agree not to engage in fraudulent, illegal, or other harmful activities while using the App. This includes but is not limited to harassment, misrepresentation, or misuse of the service. Company shall not take any Responsibility for any Misconduct Performed by Drivers.

5. Privacy Policy

5.1 Data Collection: We collect and use personal data as outlined in our Privacy Policy, which governs how we handle user information. By using the App, you consent to our Privacy Policy.
6. Modifications to Terms

6.1 Updates: Tuk Tuk reserves the right to update these Terms at any time. Changes will be effective upon posting to the App. Continued use of the App after changes constitutes acceptance of the updated Terms.
7. Limitation of Liability

7.1 Disclaimer: Tuk Tuk Sawari is not liable for any damages or losses incurred from the use of the App, including but not limited to vehicle accidents, disputes between users, or service interruptions.
8. Governing Law

8.1 Jurisdiction: These Terms are governed by the laws of Nepal. Any disputes arising from these Terms shall be resolved in the court.
9. Contact Us

9.1 Support: For questions or concerns about these Terms or the App, please contact us at +977 9767218258

By using the Tuk Tuk Ride App, you agree to abide by these Terms and Conditions. Thank you for choosing Tuk Tuk Sawari for your Transportation needs.

Last Updated : 10/28/2024


    ''';
  }
}
