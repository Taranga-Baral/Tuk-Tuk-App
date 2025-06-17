import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/galli_maps/booking_option_with_firebase.dart';
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/request_from_driver_page.dart/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:galli_vector_package/galli_vector_package.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:final_menu/models/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// class FareCalculator {
//   static double calculateFare({
//     required String distance,
//     required String vehicleType,
//     required String mode,
//     required int passengers,
//   }) {
//     double rate = 0;
//     double distanceKm = double.parse(distance) / 1000;
//     DateTime now = DateTime.now();
//     int currentHour = now.hour;
//     bool isDaytime = currentHour >= 6 && currentHour < 18;
//     double timeMultiplier = isDaytime ? 1 : 1.1;

//     // Define fare rates for each vehicle type and mode
//     final Map<String, Map<String, List<double>>> fareRates = {
//       'Tuk Tuk': {
//         'Petrol': [2.4, 4.5, 7, 9, 11.5, 14],
//         'Electric': [1, 1.6, 2.4, 3.4, 4.2, 5],
//       },
//       'Motor Bike': {
//         'Petrol': [1.6, 1.2],
//         'Electric': [1, 0.75],
//       },
//       'Taxi': {
//         'Petrol': [10, 7.5],
//         'Electric': [4, 3],
//       },
//     };

//     // Get the rate based on vehicle type, mode, and passengers
//     if (fareRates.containsKey(vehicleType) &&
//         fareRates[vehicleType]!.containsKey(mode)) {
//       List<double> rates = fareRates[vehicleType]![mode]!;
//       rate = rates[passengers - 1]; // Adjust for 0-based index
//     }

//     // Apply distance and time-based multiplier
//     return (distanceKm * 10) *
//         rate *
//         timeMultiplier *
//         (isDaytime ? 1.01 : 0.99);
//   }
// }

class FareCalculator {
  static double calculateFare({
    required String distance,
    required String vehicleType,
    required String mode,
    required int passengers,
  }) {
    double rate = 0;
    double distanceKm =
        double.parse(distance) / 1000; // Convert meters to kilometers
    DateTime now = DateTime.now();
    int currentHour = now.hour;
    bool isDaytime = currentHour >= 6 && currentHour < 18;
    double timeMultiplier = isDaytime ? 1 : 1.05; // Nighttime surcharge

    // Define fare rates for each vehicle type and mode
    final Map<String, Map<String, List<double>>> fareRates = {
      'Tuk Tuk': {
        'Petrol': [2.4, 4.5, 7, 9, 11.5, 14], // Rates for 1 to 5 passengers
        'Electric': [1, 1.6, 2.4, 3.4, 4.2, 5], // Rates for 1 to 5 passengers
      },
      'Motor Bike': {
        'Petrol': [1.6], // Only 1 passenger allowed
        'Electric': [1], // Only 1 passenger allowed
      },
      'Taxi': {
        'Petrol': [10], // Fixed rate for up to 5 passengers
        'Electric': [4], // Fixed rate for up to 5 passengers
      },
    };

    // Validate passengers based on vehicle type
    if (vehicleType == 'Motor Bike' && passengers > 1) {
      throw Exception('Motor Bike can only carry 1 passenger.');
    }
    if (vehicleType == 'Tuk Tuk' && passengers > 5) {
      throw Exception('Tuk Tuk can only carry up to 5 passengers.');
    }
    if (vehicleType == 'Taxi' && passengers > 5) {
      throw Exception('Taxi can only carry up to 5 passengers.');
    }

    // Get the rate based on vehicle type, mode, and passengers
    if (fareRates.containsKey(vehicleType) &&
        fareRates[vehicleType]!.containsKey(mode)) {
      List<double> rates = fareRates[vehicleType]![mode]!;

      // For Taxi, use the fixed rate regardless of passengers
      if (vehicleType == 'Taxi') {
        rate = rates[0]; // Fixed rate for Taxi
      }
      // For Tuk Tuk, use the rate based on passengers
      else if (vehicleType == 'Tuk Tuk') {
        rate = rates[passengers - 1]; // Adjust for 0-based index
      }
      // For Motor Bike, use the fixed rate
      else if (vehicleType == 'Motor Bike') {
        rate = rates[0]; // Fixed rate for Motor Bike
      }
    }

    // Apply distance and time-based multiplier
    return (distanceKm * 10) * rate * timeMultiplier;
  }
}

class MapPage extends StatefulWidget {
  final String userId;
  const MapPage({super.key, required this.userId});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? controller;
  Line? _selectedLine;
  String _distance = '';
  final bool _distanceResetViewBookingOption = true;
  String _duration = '';
  String _deliveryLocation = '';
  Symbol? _selectedSymbol;
  Symbol? _selectedSymbol1;
  String _searchQuery = '';
  String _pickupLocation = '';
  double _heightOfMap = 1;
  String _destinationLatitude = '';
  String _destinationLongitude = '';

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  GalliMethods methods = GalliMethods('1b040d87-2d67-47d5-aa97-f8b47d301fec');
  List<Symbol> markers = [];
  late void Function() clearMarkers;
  LocationData? _currentLocation;
  ApiModels apimodels = ApiModels();
  final List<Line> _routeLines = [];
  List<String> searchResults = [];
  List<String> searchResultsDelivery = [];
  TextEditingController pickupTextController = TextEditingController();
  TextEditingController deliveryTextController = TextEditingController();
  final bool _isLoading = true;
  String? selectedMunicipality;
  int? previousPassengers;
  String? selectedMode = 'Petrol';
  String? selectedVehicleType = 'Tuk Tuk';
  int selectedPassengers = 1;
  int previousPassengersForTukTuk =
      1; // To store previous selection for Tuk Tuk
  int previousPassengersForTaxi = 1; // To store previous selection for Taxi
  double fare = 0.0;
  bool isBookingInProgress = false; // Add this variable
  bool isPickupTextFieldEnabled = true;
  bool isDeliveryTextFieldEnabled = true;

  Future<void> _storeDataInFirestore(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('trips').doc().set(data);
    } catch (e) {
      print('Error storing data: $e');
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

  // void _calculateFare(String distance) {
  //   double rate = 0;
  //   print(distance);
  //   double distancedoublevar = double.parse(distance);
  //   int distanceintvarwithoutroundoff = distancedoublevar.toInt();
  //   int distanceintvar = distanceintvarwithoutroundoff.round();

  //   DateTime now = DateTime.now();
  //   int currentHour = now.hour;
  //   //daytime is equal to 6 to 6
  //   bool isDaytime = currentHour >= 6 && currentHour < 18;

  //   // Default rate modifier for daytime is 1, and for nighttime it's 1.05
  //   double timeMultiplier = isDaytime ? 1 : 1.1;

  //   if (selectedVehicleType == 'Tuk Tuk') {
  //     // Calculate base rate based on distance and mode
  //     if (distanceintvar <= 7) {
  //       if (selectedMode == 'Petrol') {
  //         if (selectedPassengers == 1) {
  //           rate = 2.4;
  //         } else if (selectedPassengers == 2) {
  //           rate = 4.5;
  //         } else if (selectedPassengers == 3) {
  //           rate = 7;
  //         } else if (selectedPassengers == 4) {
  //           rate = 9;
  //         } else if (selectedPassengers == 5) {
  //           rate = 11.5;
  //         } else {
  //           rate = 14;
  //         }
  //       } else {
  //         // Non-petrol mode
  //         if (selectedPassengers == 1) {
  //           rate = 1;
  //         } else if (selectedPassengers == 2) {
  //           rate = 1.6;
  //         } else if (selectedPassengers == 3) {
  //           rate = 2.4;
  //         } else if (selectedPassengers == 4) {
  //           rate = 3.4;
  //         } else if (selectedPassengers == 5) {
  //           rate = 4.2;
  //         } else {
  //           rate = 5;
  //         }
  //       }
  //     } else {
  //       // Distance greater than 7 km
  //       if (selectedMode == 'Petrol') {
  //         if (selectedPassengers == 1) {
  //           rate = 1.9;
  //         } else if (selectedPassengers == 2) {
  //           rate = 3.6;
  //         } else if (selectedPassengers == 3) {
  //           rate = 5.5;
  //         } else if (selectedPassengers == 4) {
  //           rate = 7.4;
  //         } else if (selectedPassengers == 5) {
  //           rate = 9.7;
  //         } else {
  //           rate = 12;
  //         }
  //       } else {
  //         // Non-petrol mode
  //         if (selectedPassengers == 1) {
  //           rate = 0.75;
  //         } else if (selectedPassengers == 2) {
  //           rate = 1.4;
  //         } else if (selectedPassengers == 3) {
  //           rate = 4.3;
  //         } else if (selectedPassengers == 4) {
  //           rate = 5.7;
  //         } else if (selectedPassengers == 5) {
  //           rate = 7;
  //         } else {
  //           rate = 8.5;
  //         }
  //       }
  //     }
  //   } else if (selectedVehicleType == 'Motor Bike') {
  //     // Calculate base rate based on distance and mode
  //     if (distanceintvar <= 10) {
  //       if (selectedMode == 'Petrol') {
  //         if (selectedPassengers == 1) {
  //           rate = 1.6;
  //         }
  //       } else {
  //         // Non-petrol mode
  //         if (selectedPassengers == 1) {
  //           rate = 1;
  //         }
  //       }
  //     } else {
  //       // Distance greater than 7 km
  //       if (selectedMode == 'Petrol') {
  //         if (selectedPassengers == 1) {
  //           rate = 1.2;
  //         }
  //       } else {
  //         // Non-petrol mode
  //         if (selectedPassengers == 1) {
  //           rate = 0.75;
  //         }
  //       }
  //     }
  //   } else if (selectedVehicleType == 'Taxi') {
  //     // Calculate base rate based on distance and mode
  //     if (distanceintvar <= 7) {
  //       if (selectedMode == 'Petrol') {
  //         if (selectedPassengers == 1) {
  //           rate = 10;
  //         } else if (selectedPassengers == 2) {
  //           rate = 10;
  //         } else if (selectedPassengers == 3) {
  //           rate = 10;
  //         } else if (selectedPassengers == 4) {
  //           rate = 10;
  //         } else if (selectedPassengers == 5) {
  //           rate = 10;
  //         } else {
  //           rate = 10;
  //         }
  //       } else {
  //         // Non-petrol mode
  //         if (selectedPassengers == 1) {
  //           rate = 4;
  //         } else if (selectedPassengers == 2) {
  //           rate = 4;
  //         } else if (selectedPassengers == 3) {
  //           rate = 4;
  //         } else if (selectedPassengers == 4) {
  //           rate = 4;
  //         } else if (selectedPassengers == 5) {
  //           rate = 4;
  //         } else {
  //           rate = 4;
  //         }
  //       }
  //     } else {
  //       // Distance greater than 7 km
  //       if (selectedMode == 'Petrol') {
  //         if (selectedPassengers == 1) {
  //           rate = 7.5;
  //         } else if (selectedPassengers == 2) {
  //           rate = 7.5;
  //         } else if (selectedPassengers == 3) {
  //           rate = 7.5;
  //         } else if (selectedPassengers == 4) {
  //           rate = 7.5;
  //         } else if (selectedPassengers == 5) {
  //           rate = 7.5;
  //         } else {
  //           rate = 7.5;
  //         }
  //       } else {
  //         // Non-petrol mode
  //         if (selectedPassengers == 1) {
  //           rate = 3;
  //         } else if (selectedPassengers == 2) {
  //           rate = 3;
  //         } else if (selectedPassengers == 3) {
  //           rate = 3;
  //         } else if (selectedPassengers == 4) {
  //           rate = 3;
  //         } else if (selectedPassengers == 5) {
  //           rate = 3;
  //         } else {
  //           rate = 3;
  //         }
  //       }
  //     }
  //   }

  //   // Apply distance and the time-based multiplier to the fare calculation
  //   fare = (double.parse(distance) * 10) *
  //       rate *
  //       timeMultiplier *
  //       (isDaytime ? 1.01 : 0.99);

  //   // Print to check if it's daytime or nighttime and the calculated fare
  //   print("Booking time: ${isDaytime ? 'Daytime' : 'Nighttime'}");
  //   print('Calculated fare: $fare');
  //   print('Selected Vehicle Type: $selectedVehicleType');
  // }

  Widget _buildVehicleTypeSelector(
      String distance, String duration, StateSetter setState) {
    final List<String> vehicleTypes = ['Tuk Tuk', 'Motor Bike', 'Taxi'];
    final List<String> vehicleModes = ['Petrol', 'Electric'];
    final List<String> vehicleImages = [
      'assets/homepage_tuktuk.png',
      'assets/homepage_motorbike.png',
      'assets/homepage_taxi.png'
    ];

    final List<String> chitwanMunicipalities = [
      'Bharatpur Metropolitan City',
      'Kalika Municipality',
      'Khairahani Municipality',
      'Madi Municipality',
      'Ratnanagar Municipality',
      'Rapti Municipality',
      'Ichchhakamana Rural Municipality',
    ];

    void mapHeightWhenFirstBooked() {
      setState(
        () {
          _heightOfMap = 0;
        },
      );
    }

    void mapHeightWhenMapButtonClicked() {
      setState(
        () {
          _heightOfMap = 0.4;
        },
      );
    }

    mapHeightWhenFirstBooked();
    double screenTextScaleFactor = MediaQuery.of(context).textScaleFactor;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          right: 12,
          left: 12,
        ),
        child: Column(
          children: [
            //home buttons
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_searchQuery.isNotEmpty &&
                        _distance != '' &&
                        _duration != '' &&
                        _deliveryLocation != '')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: const Color.fromARGB(255, 80, 91, 247),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                _searchQuery.length > 20
                                    ? '${_searchQuery.substring(0, 20)}...'
                                    : _searchQuery,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.outfit(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(
                      width: 10,
                    ),
                    // Cancel Icon (Red)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MapPage(userId: widget.userId)));
                      },
                      child: Icon(
                        Icons.close,
                        color: const Color.fromARGB(237, 244, 67, 54),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 5,
            ),

            // Pickup and Delivery Locations
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Locations (from, to)',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.orange[800],
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _pickupLocation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _deliveryLocation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Vehicle Type Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Vehicle Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 100, // Reduced height for a compact UI
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vehicleTypes.length,
                      itemBuilder: (context, index) {
                        bool isSelected =
                            selectedVehicleType == vehicleTypes[index];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedVehicleType = vehicleTypes[index];
                              selectedPassengers =
                                  1; // Reset passengers when vehicle changes
                              fare = FareCalculator.calculateFare(
                                distance: distance,
                                vehicleType: selectedVehicleType!,
                                mode: selectedMode!,
                                passengers: selectedPassengers,
                              );
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      0.25, // Reduced width for a compact UI
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color.fromARGB(
                                              235, 80, 91, 247)
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    vehicleImages[index],
                                    height:
                                        50, // Reduced height for a compact UI
                                    width: 50, // Reduced width for a compact UI
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  vehicleTypes[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? const Color.fromARGB(235, 80, 91, 247)
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Municipality Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Your Municipality',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chitwanMunicipalities.map((municipality) {
                      bool isSelected = selectedMunicipality == municipality;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMunicipality = municipality;
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromARGB(235, 80, 91, 247)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            municipality,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isSelected ? Colors.white : Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 10,
            ),

            // Vehicle Mode Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Vehicle Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: vehicleModes.map((mode) {
                      bool isSelected = selectedMode == mode;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMode = mode;
                              fare = FareCalculator.calculateFare(
                                distance: distance,
                                vehicleType: selectedVehicleType!,
                                mode: selectedMode!,
                                passengers: selectedPassengers,
                              );
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromARGB(235, 80, 91, 247)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                mode,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Number of Passengers Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Number of Passengers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        selectedVehicleType == 'Motor Bike' ? 1 : 5,
                        (index) {
                          int passengerCount = index + 1;
                          bool isSelected =
                              selectedPassengers == passengerCount;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(
                                '$passengerCount',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color.fromARGB(235, 80, 91, 247),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedPassengers = passengerCount;
                                  fare = FareCalculator.calculateFare(
                                    distance: distance,
                                    vehicleType: selectedVehicleType!,
                                    // mode: 'Petrol',
                                    mode: selectedMode!,
                                    passengers: selectedPassengers,
                                  );
                                });
                              },
                              selectedColor:
                                  const Color.fromARGB(235, 80, 91, 247),
                              backgroundColor: Colors.grey[200],
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Total Fare, Distance, and Duration Display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(26, 68, 137, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Distance:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${(double.parse(_distance) / 1000).toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Duration:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '~ ${(double.parse(_duration) / 60).toStringAsFixed(0)} Min, Driving',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Total Fare:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            'NPR ${fare.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: isBookingInProgress
                  ? null
                  : () async {
                      if (selectedMunicipality != null &&
                          selectedVehicleType != null &&
                          selectedMode != null &&
                          ((selectedVehicleType == 'Motor Bike' &&
                                  selectedPassengers == 1) ||
                              (selectedVehicleType == 'Tuk Tuk' &&
                                  (selectedPassengers >= 1 &&
                                      selectedPassengers <= 5)) ||
                              (selectedVehicleType == 'Taxi' &&
                                  (selectedPassengers >= 1 &&
                                      selectedPassengers <= 5)))) {
                        setState(() {
                          isBookingInProgress = true; // Disable the button
                        });
                        final userDetails = await _getUserDetails();
                        final user = FirebaseAuth.instance.currentUser;
                        final bookingData = {
                          'vehicle_mode': selectedMode,
                          'vehicleType': selectedVehicleType,
                          'no_of_person': selectedPassengers,
                          'userId': user?.uid ?? 'N/A',
                          'municipalityDropdown': selectedMunicipality,
                          'timestamp': FieldValue.serverTimestamp(),
                          'fare': fare.toStringAsFixed(2),
                          'distance':
                              (double.parse(distance) / 1000).toString(),
                          'username': userDetails['username'] ?? 'N/A',
                          'email': userDetails['email'] ?? 'N/A',
                          'phone': userDetails['phone_number'] ?? 'N/A',
                          'pickupLocation': _pickupLocation,
                          'deliveryLocation': _deliveryLocation,
                          'pickupLatitude': _currentLocation!.latitude,
                          'pickupLongitude': _currentLocation!.longitude,
                          'deliveryLatitude': _destinationLatitude,
                          'deliveryLongitude': _destinationLongitude,
                        };

                        await _storeDataInFirestore(bookingData);
                        // Navigator.of(context).pop(true);
                        setState(() {
                          isBookingInProgress =
                              false; // Enable the button after completion
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RequestPage(userId: widget.userId)));
                        });
                      } else {
                        _showSnackbar(
                            'Select all of the Valid Option', context);
                      }
                    },
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Container(
                    width: double.infinity, // Full width
                    height: 50, // Fixed height
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 73, 85, 252),
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Subtle shadow
                          blurRadius: 6,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Hail a Ride',
                        style: TextStyle(
                          color: Colors.white, // White text for contrast
                          fontSize: 18, // Slightly larger font size
                          fontWeight: FontWeight.bold, // Bold text
                          letterSpacing:
                              1.0, // Slightly spaced letters for a professional look
                        ),
                      ),
                    ),
                  )),
            ),

            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
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
    _getUserLocation();
    _fetchLocation();
    _searchController.addListener(updateLiveText);
    void showLocationInfoPopup(BuildContext context) async {
      // Check if the popup has already been shown
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasPopupBeenShown = prefs.getBool('hasPopupBeenShown') ?? false;

      if (!hasPopupBeenShown && _currentLocation != null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.bottomSlide,
          title: 'Location Information',
          desc:
              '', // Leave desc empty since we'll use the body for custom content
          body: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Green Sign Indicates your Pickup Point',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Red Sign Indicates your Delivery Point',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.my_location, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Your Device: (${_currentLocation!.latitude}, ${_currentLocation!.longitude})',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          btnOkOnPress: () {
            // Set the flag to true after the popup is shown
            prefs.setBool('hasPopupBeenShown', true);
          },
        ).show();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLocationInfoPopup(context);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(updateLiveText);
    _searchController.dispose();
    super.dispose();
  }

  void updateLiveText() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  Future<void> _fetchLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });

    // showLocationInfoPopup(context);
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SizedBox(
              height: _distance != ''
                  ? MediaQuery.of(context).size.height * 0.4
                  : MediaQuery.of(context).size.height * 1,
              width: double.infinity,
              child: Listener(
                onPointerMove: (_) {},
                child: Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20)),
                      child: SizedBox(
                        height: _distance != ''
                            ? MediaQuery.of(context).size.height * 0.4
                            : MediaQuery.of(context).size.height * 1,
                        child: GalliMap(
                          scrollGestureEnabled: true,
                          showThree60Widget: false,
                          showSearchWidget: false,
                          doubleClickZoomEnabled: true,
                          dragEnabled: true,
                          showCurrentLocation: true,
                          showCurrentLocationButton: true,
                          authToken: '1b040d87-2d67-47d5-aa97-f8b47d301fec',
                          size: (
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          ),
                          compassPosition: (
                            position: CompassViewPosition.bottomRight,
                            offset: const Point(14, 75)
                          ),
                          showCompass: true,
                          onMapCreated: (newC) {
                            controller = newC;
                            setState(() {});
                          },
                          onMapClick: (LatLng latLng) {},
                          onMapLongPress: (LatLng latlng) {},
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 42,
                                    left: 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage1()));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        color: Color.fromARGB(255, 80, 91, 240),
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.14,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.14,
                                        child: Icon(
                                          Icons.menu_rounded,
                                          size: 22,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, top: 42),
                                  child: Material(
                                    elevation: 4.5,
                                    borderRadius: BorderRadius.circular(10),
                                    shadowColor: Colors.grey
                                        .withAlpha(50), // Silverish shadow
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Form(
                                        key: _formKey,
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter Location';
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: _handleSearch,
                                          controller: _searchController,
                                          decoration: InputDecoration(
                                            hintText: 'म यहाँ जान्छु',
                                            hintStyle: GoogleFonts.hind(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              // fontStyle: FontStyle.italic,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 24,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            suffixIcon: _searchController.text
                                                    .trim()
                                                    .isNotEmpty
                                                ? IconButton(
                                                    icon: Icon(
                                                      Icons.clear,
                                                      color: Colors.grey[600],
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      _searchController.clear();
                                                      setState(() {});
                                                    },
                                                  )
                                                : null,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 15.0,
                                              horizontal: 20.0,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide
                                                  .none, // No visible border
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          cursorColor: Colors.blue[700],
                                          cursorWidth: 2.0,
                                          cursorRadius: Radius.circular(2.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding:
                                //       const EdgeInsets.only(left: 10, top: 35),
                                //   child: SizedBox(
                                //     width: MediaQuery.of(context).size.width *
                                //         0.78,
                                //     child: Form(
                                //       key: _formKey,
                                //       child: TextFormField(
                                //         validator: (value) {
                                //           if (value!.isEmpty) {
                                //             return "Please enter Location";
                                //           }
                                //           return null; // Return null if validation passes
                                //         },
                                //         onFieldSubmitted: _handleSearch,

                                //         controller: _searchController,
                                //         decoration: InputDecoration(
                                //           // Add a hint text
                                //           hintText: 'Full Location',
                                //           hintStyle: TextStyle(
                                //             color: Colors.grey[800],
                                //             fontSize: 16,
                                //             fontStyle: FontStyle.italic,
                                //           ),
                                //           // Add a prefix icon (e.g., a search icon)
                                //           prefixIcon: Icon(
                                //             Icons.search,
                                //             color: Colors.blue[700],
                                //             size: 24,
                                //           ),
                                //           // Add a border with rounded corners
                                //           border: OutlineInputBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(12.0),
                                //             borderSide: BorderSide(
                                //               color: Colors.blue[700]!,
                                //               width: 2.0,
                                //             ),
                                //           ),
                                //           // Customize the focused border
                                //           focusedBorder: OutlineInputBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(12.0),
                                //             borderSide: BorderSide(
                                //               color: Colors.blue[700]!,
                                //               width: 2.0,
                                //             ),
                                //           ),
                                //           // Customize the enabled border
                                //           enabledBorder: OutlineInputBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(12.0),
                                //             borderSide: BorderSide(
                                //               color: Colors.grey[400]!,
                                //               width: 1.5,
                                //             ),
                                //           ),
                                //           // Add a filled background color
                                //           filled: true,
                                //           fillColor: const Color.fromARGB(
                                //               200, 255, 255, 255),
                                //           // Add a suffix icon (e.g., a clear button)
                                //           suffixIcon: _searchController.text
                                //                   .trim()
                                //                   .isNotEmpty
                                //               ? IconButton(
                                //                   icon: Icon(
                                //                     Icons.clear,
                                //                     color: Colors.grey[600],
                                //                     size: 20,
                                //                   ),
                                //                   onPressed: () {
                                //                     _searchController.clear();
                                //                     setState(() {});
                                //                   },
                                //                 )
                                //               : null,
                                //           // Add padding inside the TextField
                                //           contentPadding: EdgeInsets.symmetric(
                                //             vertical: 5.0,
                                //             horizontal: 20.0,
                                //           ),
                                //         ),
                                //         // Customize the text style
                                //         style: TextStyle(
                                //           color: Colors.black87,
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.w500,
                                //         ),
                                //         // Add cursor customization
                                //         cursorColor: Colors.blue[700],
                                //         cursorWidth: 2.0,
                                //         cursorRadius: Radius.circular(2.0),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: _distance != ''
                      ? _buildVehicleTypeSelector(
                          _distance, _duration, setState)
                      : null),
            ),
          ),
        ],
      ),
    );
  }

  void showPopup() {
    if (_searchController.text.isEmpty) {
      Dialog(
        backgroundColor: Colors.white,
        elevation: 1,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Please Enter Proper Location',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              Center(
                child: Text(
                  'No Proper Location is Found',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }
    print('Search Data is :${_searchController.text}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 1,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Results',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                        fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: apimodels.getLocation(
                        double.parse(
                            _currentLocation!.latitude!.toStringAsFixed(6)),
                        double.parse(
                            _currentLocation!.longitude!.toStringAsFixed(6)),
                        _searchController.text.trim(),
                        '1b040d87-2d67-47d5-aa97-f8b47d301fec'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error fetching data.'));
                      } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                        return Center(child: Text('Enter Proper Location.'));
                      } else {
                        List<dynamic> searchData = snapshot.data;
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: searchData.length,
                          itemBuilder: (context, index) {
                            var myData = snapshot.data[index];
                            return GestureDetector(
                              onTap: () async {
                                var coordinates = await getLocationCoordinates(
                                    double.parse(_currentLocation!.latitude!
                                        .toStringAsFixed(6)),
                                    double.parse(_currentLocation!.longitude!
                                        .toStringAsFixed(6)),
                                    // _searchController.text.trim(),
                                    myData['name'],
                                    myData['province'],
                                    myData['district'],
                                    myData['municipality'],
                                    myData['ward'],
                                    '1b040d87-2d67-47d5-aa97-f8b47d301fec');
                                if (coordinates != null) {
                                  await clearRoutes(); // Clear existing routes
                                  await drawRoute(
                                      coordinates); // Draw new route

                                  // Fetch and print pickup and delivery location names
                                  await fetchPickupLocationName();
                                  await fetchLocationName(coordinates);
                                  await fetchDistanceDuration(coordinates);
                                  setState(() {
                                    _destinationLatitude =
                                        coordinates.latitude.toString();
                                    _destinationLongitude =
                                        coordinates.longitude.toString();
                                  });

                                  Navigator.of(context).pop(); // Close dialog

//start
                                  if (_searchQuery.isNotEmpty &&
                                      _distance != '' &&
                                      _duration != '') {
                                    fare = FareCalculator.calculateFare(
                                      distance: _distance,
                                      vehicleType: selectedVehicleType!,
                                      mode: 'Petrol',
                                      passengers: selectedPassengers,
                                    );
                                    print('Printed Fare : $fare');
                                  }
//end
                                }
                              },
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 3.0, horizontal: 0),
                                    child: ListTile(
                                      hoverColor: Colors.grey[200],
                                      selectedTileColor: Colors.green[100],
                                      title: Text(
                                        myData['name'],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.outfit(
                                            fontSize: 15, letterSpacing: 0.1),
                                      ),
                                      subtitle: Text(
                                        '${myData['district']}, ${myData['province']}',
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.lexend(
                                          letterSpacing: 0.1,
                                          fontSize: 10,
                                        ),
                                      ),
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.location_on_rounded,
                                            color: Colors.black54,
                                            size: 14,
                                          ),
                                          Text(
                                            '${double.parse(myData['distance']).toStringAsFixed(2)} km',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: (double.parse(myData[
                                                            'distance'])) <=
                                                        20
                                                    ? Colors.green[600]
                                                    : double.parse(myData[
                                                                'distance']) >
                                                            50
                                                        ? Colors.red[300]
                                                        : Colors.orangeAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<LatLng?> getLocationCoordinates(
      double currentLat,
      double currentLng,
      String locationName,
      String province,
      String district,
      String municipality,
      String ward,
      String authToken) async {
    String url = 'https://route-init.gallimap.com/api/v1/search/currentLocation'
        '?accessToken=$authToken'
        '&name=$locationName'
        '&currentLat=$currentLat'
        '&currentLng=$currentLng';

    try {
      var response = await http
          .get(Uri.parse(url), headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var features = jsonData['data']['features'];
        if (features != null && features.isNotEmpty) {
          var coordinates = features[0]['geometry']['coordinates'];
          return LatLng(coordinates[1], coordinates[0]);
        }
      }
    } catch (e) {
      print('Error fetching location coordinates: $e');

      var response = await http
          .get(Uri.parse(url), headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var features = jsonData['data']['features'];
        if (features != null && features.isNotEmpty) {
          // var coordinates = features[0]['geometry']['coordinates'];
          // return LatLng(coordinates[1], coordinates[0]);

          for (var feature in features) {
            var properties = feature['properties'];

            // Check if all criteria match
            if (properties['province'] == province &&
                properties['district'] == district &&
                properties['municipality'] == municipality &&
                properties['ward'] == ward) {
              // Return coordinates of the matched location
              // var coordinates = feature['geometry']['coordinates'];
              // return LatLng(coordinates[1], coordinates[0]);

              var geometry = feature['geometry'];
              if (geometry != null && geometry['coordinates'] != null) {
                var coordinates = geometry['coordinates'];
                if (coordinates.length >= 2) {
                  // Ensure there are at least two elements
                  return LatLng(coordinates[1], coordinates[0]);
                }
              }
            }

            if (feature['geometry']['type'] == 'Polygon') {
              var polygonCoordinates = feature['geometry']['coordinates'];
              if (polygonCoordinates.isNotEmpty) {
                var firstCoordinates = polygonCoordinates[0]
                    [0]; // Assuming the first set of coordinates
                return LatLng(firstCoordinates[1], firstCoordinates[0]);
              }
            }
          }
        }
      }
    }
    return null;
  }

  Future<void> drawRoute(LatLng destination) async {
    if (controller == null || _currentLocation == null) return;

    String url =
        'https://route-init.gallimap.com/api/v1/routing?mode=driving&srcLat=${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}&srcLng=${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}&dstLat=${destination.latitude}&dstLng=${destination.longitude}&accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
      });

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['success']) {
          var routeData = jsonData['data']['data'];
          List<LineOptions> lineOptionsList = [];

          for (var route in routeData) {
            var latlngs = route['latlngs'];
            List<LatLng> geometry = [];

            for (var latlng in latlngs) {
              geometry.add(LatLng(latlng[1], latlng[0]));
            }

            lineOptionsList.add(LineOptions(
              geometry: geometry,
              lineColor: '#0000FF',
              lineWidth: 4.0,
              lineOpacity: 0.98,
              draggable: false,
              lineJoin: 'round',
              lineGapWidth: 2,
              lineBlur: 3,
              lineOffset: 2,
            ));
          }

          // Clear existing routes before drawing new ones
          await clearRoutes();

          // Add new routes and store them in _routeLines
          for (var options in lineOptionsList) {
            var line = await controller!.addLine(options);
            _routeLines.add(line);
          }

          // Add markers for pickup and delivery locations
          List<LatLng> markerCoordinates = [
            LatLng(
              double.parse(_currentLocation!.latitude!.toStringAsFixed(6)),
              double.parse(_currentLocation!.longitude!.toStringAsFixed(6)),
            ),
            LatLng(destination.latitude ?? 0.00, destination.longitude ?? 0.00),
          ];

          Future<void> addGalliMarker(LatLng point) async {
            if (_selectedSymbol == null && controller != null) {
              _selectedSymbol = await controller!.addSymbol(SymbolOptions(
                geometry: point,
                iconAnchor: 'center ',
                iconSize: 0.3,
                iconHaloBlur: 10,
                iconHaloWidth: 2,
                iconOpacity: 1,
                iconOffset: Offset(0, 0.8),
                iconColor: '#0077FF',
                iconHaloColor: '#FFFFFF',
                iconImage: 'images/pickup.png',
                draggable: false,
              ));
            }
          }

          addGalliMarker(LatLng(_currentLocation!.latitude ?? 27.24444,
              _currentLocation!.longitude ?? 84.332));
          Future<void> addGalliMarker1(LatLng point) async {
            if (_selectedSymbol1 == null && controller != null) {
              _selectedSymbol1 = await controller!.addSymbol(SymbolOptions(
                geometry: point,
                iconAnchor: 'center ',
                iconSize: 0.2,
                iconHaloBlur: 10,
                iconHaloWidth: 2,
                iconOpacity: 0.96,
                iconOffset: Offset(0, 0.8),
                iconColor: '#0077FF',
                iconHaloColor: '#FFFFFF',
                iconImage: 'images/destination.png',
                draggable: false,
              ));
            }
          }

          addGalliMarker1(LatLng(destination.latitude, destination.longitude));

          //end

          // await controller!.addSymbol(markerOptionsList as SymbolOptions);
        }
      }
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  Future<bool> fetchLocationName(LatLng destination) async {
    final String destinationnameURL =
        'https://route-init.gallimap.com/api/v1/reverse/generalReverse?accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec&lat=${destination.latitude}&lng=${destination.longitude}';

    try {
      final response = await http.get(Uri.parse(destinationnameURL));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final String locationName = jsonResponse['data']['generalName'];
          print('Hi there Delivery locname is : $locationName');
          print(
              'Hi there Destination Latitude is : ${destination.latitude}, Destination Longitude is : ${destination.longitude}');
          setState(() {
            _deliveryLocation = locationName;
          });
          return true;
        } else {
          print('Error: ${jsonResponse['message']}');
          return false;
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception caught: $e');
      return false;
    }
  }

  // Future<void> fetchDistanceDuration(LatLng destination) async {
  //   final String distanceAndDuration =
  //       "https://route-init.gallimap.com/api/v1/routing/distance?mode=driving&srcLat=${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}&srcLng=${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}&dstLat=${destination.latitude}&dstLng=${destination.longitude}&accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec";

  //   try {
  //     final response = await http.get(Uri.parse(distanceAndDuration));
  //     final Map<String, dynamic> jsonResponse = json.decode(response.body);

  //     if (jsonResponse['success'] == true) {
  //       final double distance = jsonResponse['data'][0]['distance'];
  //       final double duration = jsonResponse['data'][0]['duration'];

  //       print('Hi there Distance is : $distance');
  //       print('Hi there Duration is : $duration');
  //       print('hi there hi there');
  //     } else {
  //       print('Error: ${jsonResponse['message']}');
  //     }
  //   } catch (e) {
  //     print('Exception caught: $e');
  //   }
  // }

  Future<bool> fetchDistanceDuration(LatLng destination) async {
    try {
      const String accessToken = '1b040d87-2d67-47d5-aa97-f8b47d301fec';
      const String baseUrl =
          'https://route-init.gallimap.com/api/v1/routing/distance';
      const String mode = 'driving';
      final String srcLat = _currentLocation!.latitude!.toStringAsFixed(10);
      final String srcLng = _currentLocation!.longitude!.toStringAsFixed(10);
      final String dstLat = destination.latitude.toStringAsFixed(10);
      final String dstLng = destination.longitude.toStringAsFixed(10);

      final String distanceAndDurationUrl =
          '$baseUrl?mode=$mode&srcLat=$srcLat&srcLng=$srcLng&dstLat=$dstLat&dstLng=$dstLng&accessToken=$accessToken';

      final response = await http.get(Uri.parse(distanceAndDurationUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final double distance = jsonResponse['data']['data'][0]['distance'];
          final double duration = jsonResponse['data']['data'][0]['duration'];

          print('Hi There Distance: $distance meters');
          print('Hi There Duration: $duration seconds');
          setState(() {
            _distance = distance.toString();
            _duration = duration.toString();
          });
          //start
          return true;
          //end
        } else {
          print('Error: ${jsonResponse['message']}');
          return false;
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception caught: $e');
      // Handle exceptions here, such as network errors or JSON decoding errors
      return false;
    }
  }

  Future<void> fetchPickupLocationName() async {
    final String pickupnameURL =
        'https://route-init.gallimap.com/api/v1/reverse/generalReverse?accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec&lat=${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}&lng=${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}';

    try {
      final response = await http.get(Uri.parse(pickupnameURL));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final String locationName = jsonResponse['data']['generalName'];
          print('Hi there Pickup locname is : $locationName');
          print(
              'Hi there Pickup Latitude is : ${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}, Pickup Longitude is : ${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}');
          setState(() {
            _pickupLocation = locationName;
          });
        } else {
          print('Error: ${jsonResponse['message']}');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  void _handleSearch(String query) {
    setState(() {
      if (_formKey.currentState!.validate()) {
        _searchQuery = query;
      } else {
        // Validation failed, do not submit
        print('Validation failed');
        // Optionally show an error message or take other actions
      }
    });
    showPopup();
  }

  Future<void> clearRoutes() async {
    if (controller != null && _routeLines.isNotEmpty) {
      for (var line in _routeLines) {
        await controller!.removeLine(line);
      }
      _routeLines.clear(); // Clear the list of route lines

      Future<void> removeGalliMarker() async {
        if (_selectedSymbol != null && controller != null) {
          await controller!.removeSymbol(_selectedSymbol!);
          _selectedSymbol = null; // Reset selected marker after removal
        }
      }

      Future<void> removeGalliMarker1() async {
        if (_selectedSymbol1 != null && controller != null) {
          await controller!.removeSymbol(_selectedSymbol1!);
          _selectedSymbol1 = null; // Reset selected marker after removal
        }
      }

      removeGalliMarker();
      removeGalliMarker1();
    }
  }

  void _triggerPassengerSelection(int passengerCount, double distance) {
    setState(() {
      // Manually trigger the button's touch event for passenger selection
      selectedPassengers = passengerCount;

      // Call the fare calculation logic
      fare = FareCalculator.calculateFare(
        distance: _distance,
        vehicleType: selectedVehicleType!,
        mode: selectedMode!,
        passengers: selectedPassengers,
      );

      print('Calced Fare: $fare');
    });
  }

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
          Navigator.push(
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
}
