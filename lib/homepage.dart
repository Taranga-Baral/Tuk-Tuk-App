import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:final_menu/request_from_driver_page.dart/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  final String url;
  final String userId;
  const HomePage({super.key, required this.url, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? webView;
  List<String> searchResults = [];
  List<String> searchResultsDelivery = [];
  TextEditingController pickupTextController = TextEditingController();
  TextEditingController deliveryTextController = TextEditingController();
  bool _isLoading = true;
  String? selectedMunicipality;
  int? previousPassengers;
  String? selectedMode;
  String? selectedVehicleType = 'Tuk Tuk';
  int selectedPassengers = 1;
  int previousPassengersForTukTuk =
      1; // To store previous selection for Tuk Tuk
  int previousPassengersForTaxi = 1; // To store previous selection for Taxi
  double fare = 0.0;
  bool isBookingInProgress = false; // Add this variable
  bool isPickupTextFieldEnabled = true;
  bool isDeliveryTextFieldEnabled = true;

// Function to fetch location suggestions for Pickup
  void fetchLocationSuggestionsPickup(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=30');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        List<String> searchResults =
            data.map((place) => place['display_name'].toString()).toList();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Search Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: searchResults.map((result) {
                return SingleChildScrollView(
                  child: ListTile(
                    title: Text(result),
                    onTap: () async {
                      // Set selected result in the Flutter TextField (for Pickup)
                      pickupTextController.text = result;

                      // Disable Pickup TextField
                      setState(() {
                        isPickupTextFieldEnabled = false;
                      });

                      // Inject the selected result into the OSM input field for route_from (Pickup)
                      await webView!.evaluateJavascript(source: '''
                      var osmInput = document.getElementById("route_from");
                      if (osmInput) {
                        osmInput.value = "$result";
                        osmInput.dispatchEvent(new Event('input', { bubbles: true }));
                      }
                    ''');

                      // Reload the whole WebView content
                      await webView!.reload();

                      // Close the dialog
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      });
    } else {
      print('Failed to load suggestions');
    }
  }

// Function to fetch location suggestions for Delivery
  void fetchLocationSuggestionsDelivery(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=30');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        List<String> searchResults =
            data.map((place) => place['display_name'].toString()).toList();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Search Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: searchResults.map((result) {
                return SingleChildScrollView(
                  child: ListTile(
                    title: Text(result),
                    onTap: () async {
                      // Set selected result in the Flutter TextField (for Delivery)
                      deliveryTextController.text = result;

                      // Disable Delivery TextField
                      setState(() {
                        isDeliveryTextFieldEnabled = false;
                      });

                      // Inject the selected result into the OSM input field for route_to (Delivery)
                      await webView!.evaluateJavascript(source: '''
                      var osmInputDelivery = document.getElementById("route_to");
                      if (osmInputDelivery) {
                        osmInputDelivery.value = "$result";
                        osmInputDelivery.dispatchEvent(new Event('input', { bubbles: true }));
                      }
                    ''');

                      // Reload the whole WebView content
                      await webView!.reload();

                      // Close the dialog
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      });
    } else {
      print('Failed to load suggestions');
    }
  }

  void executeJavaScriptOnOSM() async {
    if (webView != null) {
      // Execute JavaScript to trigger the reverse directions button first
      await webView!.evaluateJavascript(source: '''
        var reverseButton = document.querySelector('button.reverse_directions');
        if (reverseButton) {
          reverseButton.click();
        }
      ''');

      await webView!.evaluateJavascript(source: '''
        var reverseButton = document.querySelector('button.reverse_directions');
        if (reverseButton) {
          reverseButton.click();
        }
      ''');

      // Then trigger the submit button
      await webView!.evaluateJavascript(source: '''
        var submitButton = document.querySelector('input[name="commit"]');
        if (submitButton) {
          submitButton.click();
        }
      ''');
    }
  }

  final List<Map<String, dynamic>> municipalitySections = [
    {
      'title': 'Chitwan',
      'municipalities': [
        'Bharatpur Metropolitan City',
        'Kalika Municipality',
        'Khairahani Municipality',
        'Madi Municipality',
        'Ratnanagar Municipality',
        'Rapti Municipality',
        'Ichchhakamana Rural Municipality',
      ]
    },
  ];

  final List<String> modes = ['Petrol', 'Electric'];
  final List<String> types = ['Tuk Tuk', 'Motor Bike', 'Taxi'];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => setState(() => _isLoading = false));
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _requestLocationPermission();
    // Simulate clicking the location button in the web view
    if (webView != null) {
      await webView!.evaluateJavascript(source: """
          document.querySelector('.control-button.control-button-last').click();
        """);
    }
  }

  Future<String> _getDistanceFromAPI(String loc1, String loc2) async {
    print('Location 1 is : $loc1');
    print('Location 2 is : $loc2');
    final apiUrl =
        'https://distance-api3.p.rapidapi.com/distance?location1=$loc1&location2=$loc2&unit=kilometers';
    const apiKey = 'cd3125ef15msh2caab8018e8198ap187972jsnb9ff3f522f8e';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'X-Rapidapi-Key': apiKey,
        'X-Rapidapi-Host': 'distance-api3.p.rapidapi.com',
      });
      return response.statusCode == 200
          ? jsonDecode(response.body)['distance'].toString()
          : 'N/A';
    } catch (e) {
      print('Error fetching distance: $e');
      return 'N/A';
    }
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userDoc.data() ?? {};
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }
    return {};
  }

  void _calculateFare(String distance) {
    double rate = 0;
    print(distance);
    double distancedoublevar = double.parse(distance);
    int distanceintvarwithoutroundoff = distancedoublevar.toInt();
    int distanceintvar = distanceintvarwithoutroundoff.round();

    DateTime now = DateTime.now();
    int currentHour = now.hour;
    //daytime is equal to 6 to 6
    bool isDaytime = currentHour >= 6 && currentHour < 18;

    // Default rate modifier for daytime is 1, and for nighttime it's 1.05
    double timeMultiplier = isDaytime ? 1 : 1.1;

    if (selectedVehicleType == 'Tuk Tuk') {
      // Calculate base rate based on distance and mode
      if (distanceintvar <= 7) {
        if (selectedMode == 'Petrol') {
          if (selectedPassengers == 1) {
            rate = 2.4;
          } else if (selectedPassengers == 2) {
            rate = 4.5;
          } else if (selectedPassengers == 3) {
            rate = 7;
          } else if (selectedPassengers == 4) {
            rate = 9;
          } else if (selectedPassengers == 5) {
            rate = 11.5;
          } else {
            rate = 14;
          }
        } else {
          // Non-petrol mode
          if (selectedPassengers == 1) {
            rate = 1;
          } else if (selectedPassengers == 2) {
            rate = 1.6;
          } else if (selectedPassengers == 3) {
            rate = 2.4;
          } else if (selectedPassengers == 4) {
            rate = 3.4;
          } else if (selectedPassengers == 5) {
            rate = 4.2;
          } else {
            rate = 5;
          }
        }
      } else {
        // Distance greater than 7 km
        if (selectedMode == 'Petrol') {
          if (selectedPassengers == 1) {
            rate = 1.9;
          } else if (selectedPassengers == 2) {
            rate = 3.6;
          } else if (selectedPassengers == 3) {
            rate = 5.5;
          } else if (selectedPassengers == 4) {
            rate = 7.4;
          } else if (selectedPassengers == 5) {
            rate = 9.7;
          } else {
            rate = 12;
          }
        } else {
          // Non-petrol mode
          if (selectedPassengers == 1) {
            rate = 0.75;
          } else if (selectedPassengers == 2) {
            rate = 1.4;
          } else if (selectedPassengers == 3) {
            rate = 4.3;
          } else if (selectedPassengers == 4) {
            rate = 5.7;
          } else if (selectedPassengers == 5) {
            rate = 7;
          } else {
            rate = 8.5;
          }
        }
      }
    } else if (selectedVehicleType == 'Motor Bike') {
      // Calculate base rate based on distance and mode
      if (distanceintvar <= 10) {
        if (selectedMode == 'Petrol') {
          if (selectedPassengers == 1) {
            rate = 1.6;
          }
        } else {
          // Non-petrol mode
          if (selectedPassengers == 1) {
            rate = 1;
          }
        }
      } else {
        // Distance greater than 7 km
        if (selectedMode == 'Petrol') {
          if (selectedPassengers == 1) {
            rate = 1.2;
          }
        } else {
          // Non-petrol mode
          if (selectedPassengers == 1) {
            rate = 0.75;
          }
        }
      }
    } else if (selectedVehicleType == 'Taxi') {
      // Calculate base rate based on distance and mode
      if (distanceintvar <= 7) {
        if (selectedMode == 'Petrol') {
          if (selectedPassengers == 1) {
            rate = 10;
          } else if (selectedPassengers == 2) {
            rate = 10;
          } else if (selectedPassengers == 3) {
            rate = 10;
          } else if (selectedPassengers == 4) {
            rate = 10;
          } else if (selectedPassengers == 5) {
            rate = 10;
          } else {
            rate = 10;
          }
        } else {
          // Non-petrol mode
          if (selectedPassengers == 1) {
            rate = 4;
          } else if (selectedPassengers == 2) {
            rate = 4;
          } else if (selectedPassengers == 3) {
            rate = 4;
          } else if (selectedPassengers == 4) {
            rate = 4;
          } else if (selectedPassengers == 5) {
            rate = 4;
          } else {
            rate = 4;
          }
        }
      } else {
        // Distance greater than 7 km
        if (selectedMode == 'Petrol') {
          if (selectedPassengers == 1) {
            rate = 7.5;
          } else if (selectedPassengers == 2) {
            rate = 7.5;
          } else if (selectedPassengers == 3) {
            rate = 7.5;
          } else if (selectedPassengers == 4) {
            rate = 7.5;
          } else if (selectedPassengers == 5) {
            rate = 7.5;
          } else {
            rate = 7.5;
          }
        } else {
          // Non-petrol mode
          if (selectedPassengers == 1) {
            rate = 3;
          } else if (selectedPassengers == 2) {
            rate = 3;
          } else if (selectedPassengers == 3) {
            rate = 3;
          } else if (selectedPassengers == 4) {
            rate = 3;
          } else if (selectedPassengers == 5) {
            rate = 3;
          } else {
            rate = 3;
          }
        }
      }
    }

    // Apply distance and the time-based multiplier to the fare calculation
    fare = (double.parse(distance) * 10) * rate * timeMultiplier;

    // Print to check if it's daytime or nighttime and the calculated fare
    print("Booking time: ${isDaytime ? 'Daytime' : 'Nighttime'}");
    print('Calculated fare: $fare');
    print('Selected Vehicle Type: $selectedVehicleType');
  }

  Future<void> _storeDataInFirestore(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('trips').doc().set(data);
    } catch (e) {
      print('Error storing data: $e');
    }
  }

  // void _showSnackbar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(message), duration: Duration(seconds: 5)));
  // }

  void _showSnackbar(String message, BuildContext context) {
    if (message == 'Enter Proper Address') {
      // Display alert with error sign
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        body: Center(
          child: Column(
            children: [
              Text(
                'Error',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.red),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Enter Proper Pickup & Delivery Address',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 12,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Image(
                  image: AssetImage('assets/homepage_address_alert.gif'),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        btnOkColor: Colors.deepOrange.shade500.withOpacity(0.8),
        descTextStyle: TextStyle(color: Colors.red),
        alignment: Alignment.center,
        btnOkOnPress: () {},
      ).show();
    } else if (message == 'Select all of the Valid Option') {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        body: Center(
          child: Column(
            children: [
              Text(
                'Error',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.red),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Select all of the Booking options',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 12,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Image(
                  image: AssetImage('assets/homepage_booking_confirmed.gif'),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        btnOkColor: Colors.deepOrange.shade500.withOpacity(0.8),
        descTextStyle: TextStyle(color: Colors.red),
        alignment: Alignment.center,
        btnOkOnPress: () {},
      ).show();
    } else if (message == 'Booking confirmed!') {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        body: Center(
          child: Column(
            children: const [
              Text(
                'Success',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.green),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Booking Confirmed',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        btnOkColor: Colors.deepOrange.shade500.withOpacity(0.8),
        alignment: Alignment.center,
        btnOkOnPress: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => RequestPage(userId: widget.userId)));
        },
      ).show();

      // Show full-screen animated flowers overlay
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          return Stack(
            children: [
              // Background with transparency
              Container(
                color: Colors.black.withOpacity(0.2),
              ),
              // Centered animated image
              Center(
                child: Image.asset(
                  'assets/bloom_booking.png',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
        },
      );

      // Close the overlay after 5 seconds (adjust as needed)
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop(); // Close the overlay
      });
    } else if (message == 'Location permission granted') {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        body: Center(
          child: Column(
            children: const [
              Text(
                'Location Permission Granted',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.green),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Note: To View your Current Location you need to enable GPS from Notification if it is not Turned on',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        btnOkColor: Colors.deepOrange.shade500.withOpacity(0.8),
        alignment: Alignment.center,
        btnOkOnPress: () {},
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        body: Center(
          child: Column(
            children: const [
              Text(
                'Location permission Denied',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.red),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Go to Settings and Enable Location Permission.',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        btnOkColor: Colors.deepOrange.shade500.withOpacity(0.8),
        alignment: Alignment.center,
        btnOkOnPress: () {},
      ).show();
    }
  }

  double containerHeight = 50.0;
  bool locationOn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pickupLocation = await webView?.evaluateJavascript(
                  source: "document.getElementById('route_from').value") ??
              'N/A';
          final deliveryLocation = await webView?.evaluateJavascript(
                  source: "document.getElementById('route_to').value") ??
              'N/A';

          if (pickupLocation.isEmpty || deliveryLocation.isEmpty) {
            // ignore: use_build_context_synchronously
            _showSnackbar('Enter Proper Address', context);
            return;
          }

          final distance =
              await _getDistanceFromAPI(pickupLocation, deliveryLocation);
          _calculateFare(distance);
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Confirm Booking',
                                style: GoogleFonts.outfit(fontSize: 20)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                _buildVehicleTypeSelector(distance, setState),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Text(
                                  '$pickupLocation',
                                  textAlign: TextAlign.start,
                                )),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Text(
                                  '$deliveryLocation',
                                  textAlign: TextAlign.start,
                                )),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: selectedMunicipality,
                              hint: Text('Select Municipality'),
                              isExpanded: true,
                              items: municipalitySections.expand((section) {
                                List<DropdownMenuItem<String>> items = [
                                  DropdownMenuItem<String>(
                                    enabled: false,
                                    child: Text(
                                      section['title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                  ),
                                  ...section['municipalities']
                                      .map<DropdownMenuItem<String>>(
                                    (String municipality) {
                                      return DropdownMenuItem<String>(
                                        value: municipality,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(municipality),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ];
                                return items;
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedMunicipality = newValue ?? '';
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: selectedMode,
                              hint: Text('Select Mode'),
                              isExpanded: true,
                              items: modes.map<DropdownMenuItem<String>>(
                                (String mode) {
                                  return DropdownMenuItem<String>(
                                    value: mode,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(mode),
                                    ),
                                  );
                                },
                              ).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedMode = newValue ?? '';
                                  _calculateFare(
                                      distance); // Recalculate fare based on new mode
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Select Number of Passengers:'),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  selectedVehicleType == 'Motor Bike' ? 1 : 5,
                                  (index) {
                                    int passengerCount = index + 1;
                                    bool isSelectable =
                                        selectedVehicleType != 'Motor Bike' ||
                                            passengerCount == 1;

                                    return ChoiceChip(
                                      label: Text('$passengerCount'),
                                      selected:
                                          selectedPassengers == passengerCount,
                                      onSelected: isSelectable
                                          ? (selected) {
                                              setState(() {
                                                if (selectedVehicleType ==
                                                    'Motor Bike') {
                                                  selectedPassengers =
                                                      1; // Set to 1 for Motor Bike
                                                  _triggerPassengerSelection(
                                                      1,
                                                      double.tryParse(
                                                              distance) ??
                                                          0.0);
                                                } else {
                                                  selectedPassengers =
                                                      passengerCount; // Set to selected passenger
                                                }
                                                _calculateFare(
                                                    distance); // Recalculate fare based on the number of passengers
                                              });
                                            }
                                          : null,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'Estimated Fare: NPR${fare.toStringAsFixed(2)}'),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.deepOrange.shade600
                                      .withOpacity(0.7),
                                ),
                                onPressed: isBookingInProgress
                                    ? null
                                    : () async {
                                        if (selectedMunicipality != null &&
                                            selectedVehicleType != null &&
                                            selectedMode != null &&
                                            ((selectedVehicleType ==
                                                        'Motor Bike' &&
                                                    selectedPassengers == 1) ||
                                                (selectedVehicleType ==
                                                        'Tuk Tuk' &&
                                                    (selectedPassengers >= 1 &&
                                                        selectedPassengers <=
                                                            5)) ||
                                                (selectedVehicleType ==
                                                        'Taxi' &&
                                                    (selectedPassengers >= 1 &&
                                                        selectedPassengers <=
                                                            5)))) {
                                          setState(() {
                                            isBookingInProgress =
                                                true; // Disable the button
                                          });
                                          final userDetails =
                                              await _getUserDetails();
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          final bookingData = {
                                            'vehicle_mode': selectedMode,
                                            'vehicleType': selectedVehicleType,
                                            'no_of_person': selectedPassengers,
                                            'userId': user?.uid ?? 'N/A',
                                            'municipalityDropdown':
                                                selectedMunicipality,
                                            'timestamp':
                                                FieldValue.serverTimestamp(),
                                            'fare': fare.toStringAsFixed(2),
                                            'distance': distance,
                                            'username':
                                                userDetails['username'] ??
                                                    'N/A',
                                            'email':
                                                userDetails['email'] ?? 'N/A',
                                            'phone':
                                                userDetails['phone_number'] ??
                                                    'N/A',
                                            'pickupLocation': pickupLocation,
                                            'deliveryLocation':
                                                deliveryLocation,
                                          };

                                          await _storeDataInFirestore(
                                              bookingData);
                                          Navigator.of(context).pop(true);
                                          setState(() {
                                            isBookingInProgress =
                                                false; // Enable the button after completion
                                          });
                                        } else {
                                          _showSnackbar(
                                              'Select all of the Valid Option',
                                              context);
                                        }
                                      },
                                child: Text('Confirm'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );

          if (confirmed == true) {
            // ignore: use_build_context_synchronously
            _showSnackbar('Booking confirmed!', context);
          }
        },
        focusColor: Colors.deepOrange.shade400,
        hoverColor: Colors.deepOrange,
        backgroundColor: Colors.deepOrange.shade300,
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.car,
            color: Colors.white,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade500.withOpacity(0.8),
        title: Text(
          'Home Page',
          style: GoogleFonts.outfit(),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.location_history,
              color: Colors.white,
            ),
            onPressed: () async {
              await _requestLocationPermission();
              // Simulate clicking the location button in the web view
              if (webView != null) {
                await webView!.evaluateJavascript(source: """
          document.querySelector('.control-button.control-button-last').click();
        """);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!_isLoading)
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    cacheEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                ),
                onWebViewCreated: (controller) => webView = controller,
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(source: """
      var mapViewerElement = document.querySelector('h1.d-flex.m-0.fw-semibold');
      if (mapViewerElement) mapViewerElement.style.display = 'none';

      var historyLinkElement = document.querySelector('a.btn.btn-outline-primary.geolink.flex-grow-1#history_tab');
      if (historyLinkElement) historyLinkElement.remove();

      var secondaryElement = document.querySelector('.secondary.d-flex.gap-2.align-items-center');
      if (secondaryElement) secondaryElement.remove();

      var editLinkElement = document.querySelector('a.btn.btn-outline-primary.geolink.editlink#editanchor');
      if (editLinkElement) editLinkElement.remove();

      result;
    """);
                },
                onGeolocationPermissionsShowPrompt: (controller, origin) async {
                  return GeolocationPermissionShowPromptResponse(
                    origin: origin,
                    allow: true, // Set to true to grant permission
                    retain:
                        true, // Set to true if you want to retain the permissions
                  );
                },
              ),
            if (_isLoading) Center(child: CircularProgressIndicator()),
            // Positioned(
            //     bottom: 0,
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.only(
            //           topLeft: Radius.circular(40),
            //           topRight: Radius.circular(40)),
            //       child: Container(
            //         color: Colors.white,
            //         height: 70,
            //         width: MediaQuery.of(context).size.width,
            //       ),
            //     )),

            Positioned(
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  color: Colors.transparent,
                  height: containerHeight * 0.8,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _updateWebViewWithLocation(double latitude, double longitude) async {
  if (webView != null) {
    await webView!.evaluateJavascript(source: """
      var inputField = document.getElementById('route_from');
      if (inputField) {
        inputField.value = '$latitude,$longitude';
      }
      // Simulate clicking the reverse directions button twice
      var reverseButton = document.querySelector('.reverse_directions');
      if (reverseButton) {
        reverseButton.click();
        reverseButton.click();
      }
    """);
  }
}


  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      // Request location permission if denied
      if (await Permission.location.request().isGranted) {
        // ignore: use_build_context_synchronously
        _showSnackbar('Location permission granted', context);
      } else {
        // ignore: use_build_context_synchronously
        _showSnackbar('Location permission denied', context);
      }
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Permission granted, get current location
      Position position = await Geolocator.getCurrentPosition();
      // Pass latitude and longitude to WebView or use it directly
      _updateWebViewWithLocation(position.latitude, position.longitude);
    } else {
      // Handle permission denied
      print('Location permission denied.');
    }
  }

  Widget _buildVehicleTypeSelector(String distance, StateSetter setState) {
    final List<String> vehicleTypes = ['Tuk Tuk', 'Motor Bike', 'Taxi'];
    final List<String> vehicleImages = [
      'assets/homepage_tuktuk.png',
      'assets/homepage_motorbike.png',
      'assets/homepage_taxi.png'
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vehicleTypes.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedVehicleType == vehicleTypes[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedVehicleType = vehicleTypes[index];
                print('Selected Vehicle Type: $selectedVehicleType');
                _calculateFare(distance); // Recalculate fare after selection
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? Colors.deepOrange : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      vehicleImages[index],
                      height: 60,
                      width: 60,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    vehicleTypes[index],
                    style: GoogleFonts.comicNeue(
                      color: isSelected ? Colors.teal : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _triggerPassengerSelection(int passengerCount, double distance) {
    setState(() {
      // Manually trigger the button's touch event for passenger selection
      selectedPassengers = passengerCount;

      // Call the fare calculation logic
      _calculateFare(distance
          .toString()); // Recalculate fare when the number of passengers changes
    });
  }
}
