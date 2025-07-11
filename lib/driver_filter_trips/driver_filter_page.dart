import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:final_menu/galli_maps/driver_view_passenger_location/driver_view_passenger_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DriverFilterPage extends StatefulWidget {
  final String driverId;

  const DriverFilterPage({super.key, required this.driverId});

  @override
  _DriverFilterPageState createState() => _DriverFilterPageState();
}

class _DriverFilterPageState extends State<DriverFilterPage> {
  String? _selectedPlace;
  String? _selectedSort;
  String? _selectedVehicleMode;
  String? _selectedVehicleType;
  bool _showDropdowns = false; // Track dropdown visibility
  bool _isSendButtonDarkened = false; // Track send button state

  final List<String> _places = [
    'Bharatpur Metropolitan City',
    'Kalika Municipality',
    'Khairahani Municipality',
    'Madi Municipality',
    'Ratnanagar Municipality',
    'Rapti Municipality',
    'Ichchhakamana Rural Municipality'
  ];

  final List<String> _sortOptions = [
    'Timestamp Newest First',
    'Price Expensive First',
    'Price Cheap First',
    'Distance Largest First',
    'Distance Smallest First'
  ];

  final List<String> _vehicleModes = [
    'Petrol',
    'Electric',
    'All',
  ];

  final List<String> _vehicleTypes = [
    'Tuk Tuk',
    'Motor Bike',
    'Taxi',
  ];
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  // Helper function to convert string before '.' to integer
  int _parseStringToInt(String? value) {
    if (value == null || value.isEmpty) return 0;
    final parts = value.split('.');
    return int.tryParse(parts[0]) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadSendButtonState();
    _fetchVehicleType(); // Fetch the vehicleType when the widget is initialized
  }

  Future<void> _fetchVehicleType() async {
    // method that only fetches vehicleData field's value (if tuk tuk then only tuk tuk and also go on)
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('vehicleData')
        .doc(widget.driverId) // Fetch based on driverId
        .get();

    if (document.exists) {
      setState(() {
        _selectedVehicleType = document['vehicleType']; // Set the vehicleType
        _selectedVehicleMode = document['vehicleMode']; //Set the vehicleMode
      });
    }
  }

  // Load send button state from shared preferences
  Future<void> _loadSendButtonState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSendButtonDarkened = prefs.getBool('sendButtonState') ?? false;
    });
  }

//get current location of driver
  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Save send button state to shared preferences
  Future<void> _saveSendButtonState(bool isDarkened) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sendButtonState', isDarkened);
  }

  Stream<List<Map<String, dynamic>>> _getTripsStream() {
    if (_selectedPlace == null) {
      return Stream.value([]);
    }

    // Start the query by filtering trips based on the selected place
    var query = FirebaseFirestore.instance
            .collection('trips')
            .where('municipalityDropdown', isEqualTo: _selectedPlace)
            .where('vehicle_mode', isEqualTo: _selectedVehicleMode)
            .where('vehicleType',
                isEqualTo: _selectedVehicleType) // Filter by vehicle type
        ;

    // Add vehicle type filter if a specific vehicle type is selected
    // if (_selectedVehicleType != null && _selectedVehicleType != 'All') {
    //   query = query.where('vehicleType', isEqualTo: _selectedVehicleType);
    // }

    // // Add vehicle mode filter if a specific vehicle mode is selected
    // if (_selectedVehicleMode != null && _selectedVehicleMode != 'All') {
    //   query = query.where('vehicleMode', isEqualTo: _selectedVehicleMode);
    // }

    return query.snapshots().map((snapshot) {
      final trips = snapshot.docs
          .map((doc) => {
                'tripId': doc.id,
                ...doc.data(),
              })
          .toList();

      // Filter out trips older than 1 hour
      final now = DateTime.now();
      final oneHourAgo = now.subtract(Duration(hours: 1));
      trips.removeWhere((trip) {
        final tripTimestamp = (trip['timestamp'] as Timestamp).toDate();
        return tripTimestamp.isBefore(oneHourAgo);
      });

      // Sort trips based on the selected sort option
      if (_selectedSort == 'Timestamp Newest First') {
        trips.sort((a, b) => (b['timestamp'] as Timestamp)
            .compareTo(a['timestamp'] as Timestamp));
      } else if (_selectedSort == 'Price Expensive First') {
        trips.sort((a, b) =>
            _parseStringToInt(b['fare']) - _parseStringToInt(a['fare']));
      } else if (_selectedSort == 'Price Cheap First') {
        trips.sort((a, b) =>
            _parseStringToInt(a['fare']) - _parseStringToInt(b['fare']));
      } else if (_selectedSort == 'Distance Largest First') {
        trips.sort((a, b) =>
            _parseStringToInt(b['distance']) -
            _parseStringToInt(a['distance']));
      } else if (_selectedSort == 'Distance Smallest First') {
        trips.sort((a, b) =>
            _parseStringToInt(a['distance']) -
            _parseStringToInt(b['distance']));
      }

      return trips;
    });
  }

  void showTripAndUserIdInSnackBar(Map<String, dynamic> tripData,
      BuildContext context, double distance) async {
    // Extract tripId, userId, and driverId (driver's email)
    final tripId = tripData['tripId'] ?? 'No Trip ID';
    final userId = tripData['userId'] ?? 'No User ID';
    if (tripId == 'No Trip ID' || userId == 'No User ID') {
      // Show error if tripId or userId is missing
      SnackBar(
        content: Text('Invalid Trip or User ID.'),
        duration: Duration(seconds: 3),
      );
      return;
    }

    try {
      // Check if the request already exists
      bool requestExists =
          await _checkRequestExists(tripId, userId, widget.driverId);
      if (requestExists) {
        // Show a SnackBar indicating request already sent
        SnackBar(
          content: Text('Request already sent.'),
          duration: Duration(seconds: 3),
        );
        return;
      } else {
        await FirebaseFirestore.instance.collection('requestsofDrivers').add({
          'tripId': tripId,
          'userId': userId,
          'driverId': widget.driverId,
          'distance_between_driver_and_passenger': distance,
          'requestTimestamp':
              FieldValue.serverTimestamp(), // Optional: Add a timestamp
        });

        Map<String, dynamic> distanceData = {
          'tripId': tripId,
          'userId': userId,
          'driverId': widget.driverId,
          'distance_between_driver_and_passenger': distance,
        };

        // Reference to the new collection
        CollectionReference distanceCollection = FirebaseFirestore.instance
            .collection('distance_between_driver_and_passenger');

        // Add or update the document in the new collection
        await distanceCollection.add(distanceData);
        setState(() {});

        // Step 2: Show a SnackBar with tripId, userId, and driverId

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          body: Center(
            child: Column(
              children: const [
                Text(
                  'Done',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                      color: Colors.green),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Request Sent Successfully. Wait for their Response.',
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

      // Step 1: Add the userId, driverId, and tripId to the "requestsofDrivers" collection
    } catch (e) {
      // Handle error sending request

      SnackBar(
        content: Text('Error sending request: $e'),
        duration: const Duration(seconds: 3),
      );

      print('Error sending Request: $e');
    }
  }

  Future<bool> _checkRequestExists(
      String tripId, String userId, String driverId) async {
    // Query the "requestsofDrivers" collection to check if the request already exists
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('requestsofDrivers')
        .where('tripId', isEqualTo: tripId)
        .where('userId', isEqualTo: userId)
        .where('driverId', isEqualTo: driverId)
        .get();

    return snapshot
        .docs.isNotEmpty; // Return true if any matching document is found
  }

  bool isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.filter_alt,
          color: Colors.white,
        ),
        title: Text(
          'Driver Filter Page',
          style: GoogleFonts.outfit(
            color: Colors.white, // White text for contrast
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showDropdowns ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showDropdowns = !_showDropdowns; // Toggle dropdowns visibility
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showDropdowns) ...[
              OutlinedButton(
                onPressed: () {
                  showFilterPopup(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent, // Text and icon color
                  side: BorderSide(
                    color: Colors.redAccent.shade400, // Border color
                    width: 1.5, // Slightly thicker border
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0, // Compact padding
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(24.0), // Gentle rounding
                  ),
                  backgroundColor: Colors.transparent, // No fill color
                  elevation: 0, // No shadow
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // Minimal touch target
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.grey,
                      size: 18.0, // Compact icon
                    ),
                    SizedBox(width: 8.0), // Tight spacing
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 14.0, // Compact text
                        fontWeight: FontWeight.w500, // Medium weight
                      ),
                    ),
                  ],
                ),
              )
            ],

            // StreamBuilder to display trips
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getTripsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: Image(
                      image: AssetImage('assets/loading_screen.gif'),
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.3,
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final trips = snapshot.data ?? [];
                  if (trips.isEmpty) {
                    return Center(
                        child: Text(
                      'Click Dropdown to start Filtering and Note the Trips which is Older than 1 hour is Dismissed from Our Server',
                      textAlign: TextAlign.center,
                    ));
                  }
                  return ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      //return card

                      return Card(
                        elevation: 1,
                        // color: Colors.white70,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip['username'] ?? 'No Username',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blueGrey),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${trip['municipalityDropdown'] ?? 'No Record of Municipality'} - ${trip['vehicle_mode']}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.phone,
                                        color: Colors.blueGrey),
                                    onPressed: () {
                                      final phoneNumber = trip['phone'] ?? '';
                                      _launchPhoneNumber(phoneNumber);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.location_searching_rounded,
                                        color: Colors.blueGrey),
                                    onPressed: () {
                                      final tripId = trip['tripId'] ?? '';
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DriverViewPassengerLocation(
                                                      tripId: tripId)));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: isButtonDisabled
                                          ? Colors.grey
                                          : Colors.blueAccent,
                                    ),
                                    onPressed: () async {
                                      // Show the initial loading dialog
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image(
                                                    image: AssetImage(
                                                        'assets/loading_screen.gif'),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );

                                      try {
                                        // Check location permission
                                        LocationPermission permission =
                                            await Geolocator.checkPermission();
                                        if (permission ==
                                            LocationPermission.denied) {
                                          // Request permission
                                          permission = await Geolocator
                                              .requestPermission();
                                          if (permission !=
                                                  LocationPermission
                                                      .whileInUse &&
                                              permission !=
                                                  LocationPermission.always) {
                                            // Permission denied
                                            Navigator.pop(
                                                context); // Close the dialog
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Location permission is required to proceed.'),
                                              ),
                                            );
                                            return;
                                          }
                                        }

                                        // Check if location services are enabled
                                        if (!await Geolocator
                                            .isLocationServiceEnabled()) {
                                          // Location services are not enabled
                                          Navigator.pop(
                                              context); // Close the dialog
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Please enable location services.'),
                                            ),
                                          );
                                          return;
                                        }

                                        // Get current location
                                        Position userPosition =
                                            await _getCurrentLocation();

                                        // Fetch pickup location from Firestore
                                        // Map<String, dynamic> tripData =
                                        //     await _getPickupLocation(
                                        //         trip['tripId']);
                                        // var pickupLocation =
                                        //     tripData['pickupLocation'];

                                        Map<String, dynamic> tripData =
                                            await _getPickupLocation(
                                                trip['tripId']);
                                        var pickupLocation =
                                            tripData['pickupLocation'];

                                        Map<String, dynamic> tripData1 = {
                                          'tripId': trip['tripId'],
                                          'userId': trip['userId'],
                                        };

                                        double pickupLatitude;
                                        double pickupLongitude;

                                        // Check if pickupLocation is a GeoPoint (lat, long) or a place name

                                        pickupLatitude =
                                            tripData['pickupLatitude'];
                                        pickupLongitude =
                                            tripData['pickupLongitude'];

                                        // Calculate the distance between user's location and pickup location
                                        double distance = _calculateDistance(
                                          userPosition.latitude,
                                          userPosition.longitude,
                                          pickupLatitude,
                                          pickupLongitude,
                                        );

                                        // Show distance and other information in SnackBar
                                        showTripAndUserIdInSnackBar(
                                            tripData1, context, distance);

                                        // Upload the distance and other information to Firestore

                                        // Success message (optional)
                                        print('Distance successfully uploaded');
                                      } catch (e) {
                                        // Handle errors
                                        print('Error: $e');
                                        // Show error message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'An error occurred. Please try again later.'),
                                          ),
                                        );
                                      } finally {
                                        // Close the loading dialog if still open
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
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
                                      '${trip['pickupLocation'] ?? 'No pickup location'}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
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
                                      '${trip['deliveryLocation'] ?? 'No delivery location'}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.linear_scale_rounded,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${double.parse(trip['distance']).toStringAsFixed(0)} km',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.money,
                                    color: Colors.blueAccent.shade200,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'NPR ${double.parse(trip['fare']).toStringAsFixed(1)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                formatTimestamp(trip['timestamp']),
                                style: GoogleFonts.outfit(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchOpenStreetMapWithDirections(String tripId) async {
    try {
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();

      if (tripSnapshot.exists) {
        final data = tripSnapshot.data() as Map<String, dynamic>;
        final pickupLocation = data['pickupLocation'] as String;
        final deliveryLocation = data['deliveryLocation'] as String;

        // Try to parse as coordinates
        final pickupCoords = _parseCoordinates(pickupLocation);
        final deliveryCoords = _parseCoordinates(deliveryLocation);

        double pickupLatitude;
        double pickupLongitude;
        double deliveryLatitude;
        double deliveryLongitude;

        if (pickupCoords != null) {
          pickupLatitude = pickupCoords['latitude']!;
          pickupLongitude = pickupCoords['longitude']!;
        } else {
          final pickupData = await _geocodeAddress(pickupLocation);
          pickupLatitude = pickupData['latitude']!;
          pickupLongitude = pickupData['longitude']!;
        }

        if (deliveryCoords != null) {
          deliveryLatitude = deliveryCoords['latitude']!;
          deliveryLongitude = deliveryCoords['longitude']!;
        } else {
          final deliveryData = await _geocodeAddress(deliveryLocation);
          deliveryLatitude = deliveryData['latitude']!;
          deliveryLongitude = deliveryData['longitude']!;
        }

        final String openStreetMapUrl =
            'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

        final Uri launchUri = Uri.parse(openStreetMapUrl);

        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        } else {
          print('Could not launch $launchUri');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip details not found')),
          );
        }
      }
    } catch (e) {
      print('Error fetching trip details: $e');
    }
  }

  Map<String, double>? _parseCoordinates(String location) {
    final parts = location.split(',');
    if (parts.length == 2) {
      final latitude = double.tryParse(parts[0]);
      final longitude = double.tryParse(parts[1]);
      if (latitude != null && longitude != null) {
        return {'latitude': latitude, 'longitude': longitude};
      }
    }
    return null;
  }

  Future<Map<String, double>> _geocodeAddress(String address) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'latitude': double.parse(data[0]['lat']),
          'longitude': double.parse(data[0]['lon']),
        };
      }
    }
    throw Exception('Failed to geocode address');
  }

  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  // showPopup(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Driver Filter'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               SingleChildScrollView(
  //                 child: Column(
  //                   children: [
  //                     DecoratedBox(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(8),
  //                         border: Border.all(color: Colors.red, width: 2),
  //                       ),
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 12, vertical: 4),
  //                         child: DropdownButton<String>(
  //                           isExpanded: true,
  //                           value: _selectedPlace,
  //                           hint: Text('Select a place'),
  //                           underline: SizedBox(),
  //                           items: _places.map((String place) {
  //                             return DropdownMenuItem<String>(
  //                               value: place,
  //                               child: Text(place),
  //                             );
  //                           }).toList(),
  //                           onChanged: (String? newValue) {
  //                             setState(() {
  //                               _selectedPlace = newValue;
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: 16),
  //
  //                     // Dropdown to select sorting option
  //                     DecoratedBox(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(8),
  //                         border: Border.all(color: Colors.red, width: 2),
  //                       ),
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 12, vertical: 4),
  //                         child: DropdownButton<String>(
  //                           isExpanded: true,
  //                           value: _selectedSort,
  //                           hint: Text('Select sorting option'),
  //                           underline: SizedBox(),
  //                           items: _sortOptions.map((String sortOption) {
  //                             return DropdownMenuItem<String>(
  //                               value: sortOption,
  //                               child: Text(sortOption),
  //                             );
  //                           }).toList(),
  //                           onChanged: (String? newValue) {
  //                             setState(() {
  //                               _selectedSort = newValue;
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: 16),
  //
  //                     // Dropdown to select vehicle mode
  //                     DecoratedBox(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(8),
  //                         border: Border.all(color: Colors.red, width: 2),
  //                       ),
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 12, vertical: 4),
  //                         child: DropdownButton<String>(
  //                           isExpanded: true,
  //                           value: _selectedVehicleMode,
  //                           hint: Text('Select vehicle mode'),
  //                           underline: SizedBox(),
  //
  //                           items: _selectedVehicleMode != null
  //                               ? [
  //                                   DropdownMenuItem<String>(
  //                                     value: _selectedVehicleMode,
  //                                     child: Text(_selectedVehicleMode!),
  //                                   )
  //                                 ]
  //                               : [],
  //
  //                           // items: _vehicleModes.map((String mode) {
  //                           //   return DropdownMenuItem<String>(
  //                           //     value: mode,
  //                           //     child: Text(mode),
  //                           //   );
  //                           // }).toList(),
  //                           onChanged: (String? newValue) {
  //                             // setState(() {
  //                             //   _selectedVehicleMode = newValue;
  //                             // });
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: 20),
  //
  //                     DecoratedBox(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(8),
  //                         border: Border.all(color: Colors.red, width: 2),
  //                       ),
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 12, vertical: 4),
  //                         child: DropdownButton<String>(
  //                           isExpanded: true,
  //                           value: _selectedVehicleType,
  //                           hint: Text('Vehicle Type'),
  //                           underline: SizedBox(),
  //                           items: _selectedVehicleType != null
  //                               ? [
  //                                   DropdownMenuItem<String>(
  //                                     value: _selectedVehicleType,
  //                                     child: Text(_selectedVehicleType!),
  //                                   )
  //                                 ]
  //                               : [],
  //                           onChanged: (String? newValue) {
  //                             // setState(() {
  //                             //   _selectedVehicleType = newValue!;
  //                             //   // Trigger stream filtering by updating _selectedVehicleType
  //                             // });
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //
  //                     SizedBox(
  //                       height: 20,
  //                     ),
  //
  //                     // Display selected place
  //
  //                     SizedBox(height: 20),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Closes the popup
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void showFilterPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Text(
                    'Filter Drivers',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Content with constrained height
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Location Filter
                          _buildFilterSection(
                            title: 'Location',
                            child: DropdownButtonFormField<String>(
                              value: _selectedPlace,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: _places.map((String place) {
                                return DropdownMenuItem<String>(
                                  value: place,
                                  child: Text(
                                    place,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPlace = newValue;
                                });
                              },
                              hint: Text(
                                'Select location',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sorting Options
                          _buildFilterSection(
                            title: 'Sort By',
                            child: DropdownButtonFormField<String>(
                              value: _selectedSort,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: _sortOptions.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(
                                    option,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSort = newValue;
                                });
                              },
                              hint: Text(
                                'Select sorting',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Vehicle Mode (Read-only)
                          _buildFilterSection(
                            title: 'Vehicle Mode',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedVehicleMode ?? 'Not specified',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.lock_outline,
                                      size: 18, color: Colors.grey[500]),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Vehicle Type (Read-only)
                          _buildFilterSection(
                            title: 'Vehicle Type',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedVehicleType ?? 'Not specified',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.lock_outline,
                                      size: 18, color: Colors.grey[500]),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.grey[100],
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () {
                            // Apply filters
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Apply',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<Map<String, dynamic>> _getPickupLocation(String tripId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    return snapshot.data()!;
  }

  // Function to calculate the distance between two points
  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
            startLatitude, startLongitude, endLatitude, endLongitude) /
        1000; // Convert to kilometers
  }
}
