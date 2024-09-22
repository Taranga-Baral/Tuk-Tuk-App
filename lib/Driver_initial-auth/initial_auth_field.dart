// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
// import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
// import 'package:final_menu/homepage.dart';
// import 'package:final_menu/login_screen/sign_in_page.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:easy_stepper/easy_stepper.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';

// class DriverAuthPage extends StatefulWidget {
//   const DriverAuthPage({super.key});

//   @override
//   _DriverAuthPageState createState() => _DriverAuthPageState();
// }

// Color _color = const Color.fromARGB(255, 189, 62, 228);

// class _DriverAuthPageState extends State<DriverAuthPage> {
//   void showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   DateTime? _selectedDateOfBirth;
//   final _picker = ImagePicker();
//   String _selectedVehicleType = 'Tuk Tuk'; // Default value for dropdown

//   final _numberPlateController = TextEditingController();
//   final _brandController = TextEditingController();
//   final _colorController = TextEditingController();
//   final _licenseNumberController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();

//   File? _bluebookPhoto;
//   File? _citizenshipFrontPhoto;
//   File? _licenseFrontPhoto;
//   File? _selfieWithCitizenshipPhoto;
//   File? _selfieWithLicensePhoto;
//   File? _profilePicturePhoto;

//   String? _bluebookPhotoUrl;
//   String? _citizenshipFrontUrl;
//   String? _licenseFrontUrl;
//   String? _selfieWithCitizenshipUrl;
//   String? _selfieWithLicenseUrl;
//   String? _profilePictureUrl;

//   int _activeStep = 0; // Manage active step
//   bool _termsAccepted = false; // Track terms acceptance

//   bool _validateFields() {
//     final email = _emailController.text;
//     final phoneNumber = _phoneController.text.replaceAll('+977 ', '');

//     final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
//     final phoneNumberRegex = RegExp(r'^\d{10}$'); // 10 digits

//     if (_nameController.text.isEmpty ||
//         _addressController.text.isEmpty ||
//         _dobController.text.isEmpty ||
//         email.isEmpty ||
//         phoneNumber.isEmpty ||
//         !emailRegex.hasMatch(email) ||
//         !phoneNumberRegex.hasMatch(phoneNumber)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Either you left some field or some entered format is incorrect',
//           ),
//         ),
//       );
//       return false;
//     }

//     return true;
//   }

//   Future<void> _pickImage(String imageType) async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         switch (imageType) {
//           case 'bluebook':
//             _bluebookPhoto = File(pickedFile.path);
//             break;
//           case 'citizenshipFront':
//             _citizenshipFrontPhoto = File(pickedFile.path);
//             break;
//           case 'licenseFront':
//             _licenseFrontPhoto = File(pickedFile.path);
//             break;
//           case 'selfieWithCitizenship':
//             _selfieWithCitizenshipPhoto = File(pickedFile.path);
//             break;
//           case 'selfieWithLicense':
//             _selfieWithLicensePhoto = File(pickedFile.path);
//             break;
//           case 'profilePicture':
//             _profilePicturePhoto = File(pickedFile.path);
//             break;
//         }
//       });
//     }
//   }

//   Future<File?> _compressImage(File imageFile) async {
//     final img.Image? image = img.decodeImage(await imageFile.readAsBytes());
//     if (image == null) return null;

//     final img.Image resized =
//         img.copyResize(image, width: 800); // Adjust size as needed
//     final compressedFile = File(imageFile.path)
//       ..writeAsBytesSync(
//           img.encodeJpg(resized, quality: 85)); // Adjust quality as needed

//     return compressedFile;
//   }

//   Future<String?> _uploadImage(
//     File imageFile, String imageType, String driverId) async {
//   try {
//     final compressedImageFile = await _compressImage(imageFile);
//     if (compressedImageFile == null) {
//       print('Compressed image is null for $imageType');
//       return null;
//     }

//     final storageRef = FirebaseStorage.instance.ref().child(
//         'images/$driverId/$imageType/${DateTime.now().millisecondsSinceEpoch}.jpg');
//     final uploadTask = storageRef.putFile(compressedImageFile);

//     final snapshot = await uploadTask.whenComplete(() {});
//     final downloadUrl = await snapshot.ref.getDownloadURL();

//     return downloadUrl;
//   } catch (e) {
//     print('Error uploading image for $imageType: $e');
//     return null;
//   }
// }

//   Future<void> _submitForm() async {
//   try {
//     String driverId = _emailController.text; // Unique identifier (email)
//     bool allUploadsSuccessful = true;

//     // Upload images and get URLs if the respective photo exists
//     if (_bluebookPhoto != null) {
//       _bluebookPhotoUrl = await _uploadImage(_bluebookPhoto!, 'bluebook', driverId);
//       if (_bluebookPhotoUrl == null) allUploadsSuccessful = false;
//     }
//     if (_citizenshipFrontPhoto != null) {
//       _citizenshipFrontUrl = await _uploadImage(_citizenshipFrontPhoto!, 'citizenshipFront', driverId);
//       if (_citizenshipFrontUrl == null) allUploadsSuccessful = false;
//     }
//     if (_licenseFrontPhoto != null) {
//       _licenseFrontUrl = await _uploadImage(_licenseFrontPhoto!, 'licenseFront', driverId);
//       if (_licenseFrontUrl == null) allUploadsSuccessful = false;
//     }
//     if (_selfieWithCitizenshipPhoto != null) {
//       _selfieWithCitizenshipUrl = await _uploadImage(_selfieWithCitizenshipPhoto!, 'selfieWithCitizenship', driverId);
//       if (_selfieWithCitizenshipUrl == null) allUploadsSuccessful = false;
//     }
//     if (_selfieWithLicensePhoto != null) {
//       _selfieWithLicenseUrl = await _uploadImage(_selfieWithLicensePhoto!, 'selfieWithLicense', driverId);
//       if (_selfieWithLicenseUrl == null) allUploadsSuccessful = false;
//     }
//     if (_profilePicturePhoto != null) {
//       _profilePictureUrl = await _uploadImage(_profilePicturePhoto!, 'profilePicture', driverId);
//       if (_profilePictureUrl == null) allUploadsSuccessful = false;
//     }

//     if (!allUploadsSuccessful) {
//       // Show error message if any upload failed
//       showSnackBar(context, 'Some images failed to upload. Please try again.');
//       return;
//     }

//     // Check if the document already exists in Firestore
//     final vehicleDataRef = FirebaseFirestore.instance.collection('vehicleData').doc(driverId);
//     final docSnapshot = await vehicleDataRef.get();

//     if (docSnapshot.exists) {
//       // Update existing fields
//       await vehicleDataRef.update({
//         'vehicleType': _selectedVehicleType,
//         'numberPlate': _numberPlateController.text,
//         'brand': _brandController.text,
//         'color': _colorController.text,
//         if (_bluebookPhotoUrl != null) 'bluebookPhotoUrl': _bluebookPhotoUrl,
//         'licenseNumber': _licenseNumberController.text,
//         if (_citizenshipFrontUrl != null) 'citizenshipFrontUrl': _citizenshipFrontUrl,
//         if (_licenseFrontUrl != null) 'licenseFrontUrl': _licenseFrontUrl,
//         if (_selfieWithCitizenshipUrl != null) 'selfieWithCitizenshipUrl': _selfieWithCitizenshipUrl,
//         if (_selfieWithLicenseUrl != null) 'selfieWithLicenseUrl': _selfieWithLicenseUrl,
//         if (_profilePictureUrl != null) 'profilePictureUrl': _profilePictureUrl,
//         'name': _nameController.text,
//         'address': _addressController.text,
//         'dob': _dobController.text,
//         'email': _emailController.text,
//         'phone': _phoneController.text,
//       });
//     } else {
//       // Create new document
//       await vehicleDataRef.set({
//         'vehicleType': _selectedVehicleType,
//         'numberPlate': _numberPlateController.text,
//         'brand': _brandController.text,
//         'color': _colorController.text,
//         'bluebookPhotoUrl': _bluebookPhotoUrl ?? '',
//         'licenseNumber': _licenseNumberController.text,
//         'citizenshipFrontUrl': _citizenshipFrontUrl ?? '',
//         'licenseFrontUrl': _licenseFrontUrl ?? '',
//         'selfieWithCitizenshipUrl': _selfieWithCitizenshipUrl ?? '',
//         'selfieWithLicenseUrl': _selfieWithLicenseUrl ?? '',
//         'profilePictureUrl': _profilePictureUrl ?? '',
//         'name': _nameController.text,
//         'address': _addressController.text,
//         'dob': _dobController.text,
//         'email': _emailController.text,
//         'phone': _phoneController.text,
//       });
//     }
import 'dart:io';
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

Color _color = const Color.fromARGB(255, 189, 62, 228);

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
  bool _termsAccepted = false; // Track terms acceptance
  final _formKey = GlobalKey<FormState>();
  bool _validateFields() {
    final email = _emailController.text;
    final phoneNumber = _phoneController.text.replaceAll('+977 ', '');

    // Regex for email and phone number validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final phoneNumberRegex = RegExp(r'^\d{10}$'); // 10 digits

    // Validate text fields
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
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
      appBar: AppBar(
        title: const Text('Vehicle Information Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverRegistrationPage()));
              },
              child: const Text(
                ' Already? Sign In Here (Driver Mode)',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromARGB(255, 101, 12, 185)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignInPage()));
              },
              child: const Text(
                'Passenger Mode',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromARGB(255, 101, 12, 185)),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.17,
              width: MediaQuery.of(context).size.width,
              child: EasyStepper(
                activeStep: _activeStep,
                onStepReached: (index) {},
                steps: const [
                  EasyStep(
                    title: 'Terms & Conditions',
                    icon: Icon(Icons.assignment),
                  ),
                  EasyStep(
                    title: 'Vehicle Info',
                    icon: Icon(Icons.car_rental_rounded),
                  ),
                  EasyStep(
                    title: 'Documents',
                    icon: Icon(Icons.attach_file_outlined),
                  ),
                  EasyStep(
                    title: 'Personal Info',
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
                            Text(
                              'Terms and Conditions',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
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
                                const Text('I accept the terms and conditions'),
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
                        children:  [
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
                                'Tuk Tuk'
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
                                    color: Color.fromARGB(255, 182, 116, 194),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 200, 54, 244),
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
                                    color: Color.fromARGB(255, 182, 116, 194),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 200, 54, 244),
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
                                    color: Color.fromARGB(255, 182, 116, 194),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 200, 54, 244),
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
                        children:  [
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
                        children:  [
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
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null; // Return null if the input is valid
                        },
                        controller: _nameController,
                        decoration: const InputDecoration(
                          prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
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
                          prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.place_outlined),
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
                          prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                          labelText: 'Date of Birth',
                          prefixIcon: Icon(Icons.date_range),
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
                        readOnly: true,
                        onTap: _selectDateOfBirth,
                      ),

                      SizedBox(
                        height: 25,
                      ),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
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
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
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
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        child: GestureDetector(
                          onTap: () {
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
    );
  }

  String get _termsAndConditionsText {
    return '''
    Terms and Conditions...

    1. Introduction
     Welcome to our service. By accessing or using our service, you agree to be bound by these terms and conditions. Please read them carefully.

     2. Changes to Terms
     We may update these terms from time to time. The updated version will be effective when we post it.

     3. User Responsibilities
     You agree to provide accurate information and to keep your account secure. You are responsible for all activities that occur under your account.

     4. Use of Service
     You agree to use our service only for lawful purposes and in accordance with our guidelines. You are prohibited from engaging in any activity that disrupts or interferes with our service.

     5. Privacy
     We are committed to protecting your privacy. Our privacy policy outlines how we collect, use, and share your information.

     6. Intellectual Property
     All content and materials on our service are owned by us or our licensors. You may not use or reproduce any content without our permission.

     7. Limitation of Liability
     We are not liable for any indirect, incidental, or consequential damages arising from your use of our service.

     8. Governing Law
     These terms are governed by the laws of the jurisdiction in which we operate. Any disputes will be resolved in the courts of that jurisdiction.

     9. Contact Us
     If you have any questions about these terms, please contact us at support@example.com.

      10. Governing Law & Jurisdiction
    These Terms will be governed by and interpreted in accordance with the laws of the State of [Your State], and you submit to the non-exclusive jurisdiction of the state and federal courts located in [Your State] for the resolution of any disputes.
    ''';
  }
}
