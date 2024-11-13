import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
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
        .where('municipalityDropdown', isEqualTo: _selectedPlace);

    // Add vehicle type filter if a specific vehicle type is selected
    if (_selectedVehicleType != null && _selectedVehicleType != 'All') {
      query = query.where('vehicleType', isEqualTo: _selectedVehicleType);
    }

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

        // Step 2: Show a SnackBar with tripId, userId, and driverId

        SnackBar(
          content: Text(
            'Request sent successfully!',
          ),
          duration: const Duration(seconds: 3),
        );
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 2),
          child: Image(
            image: AssetImage('assets/fordriverlogo.png'),
            opacity: AlwaysStoppedAnimation(0.97),
          ),
        ),
        title: Center(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vehicleData')
                .doc(widget.driverId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text('');
              }

              var displayName = snapshot.data!['name'];

              return Text(
                displayName ?? 'No Name',
                style: GoogleFonts.josefinSans(
                    color: Colors.black87, fontSize: 18),
              );
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showDropdowns ? Icons.expand_less : Icons.expand_more,
              color: Colors.black87,
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
              ElevatedButton(
                onPressed: () {
                  showPopup(context); // Show popup only when a condition is met
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Colors.teal.shade200.withOpacity(0.9), // Text color
                  padding: EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded edges
                  ),
                  elevation: 2, // Add elevation for shadow effect
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.filter_alt,
                        color: Colors.white), // Add a filter icon
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      'Filter Trips',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],

            // StreamBuilder to display trips
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getTripsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
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
                        elevation: 4.0,
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
                                    color: Colors.teal),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${trip['municipalityDropdown'] ?? 'No Record of Municipality'}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.phone, color: Colors.teal),
                                    onPressed: () {
                                      final phoneNumber = trip['phone'] ?? '';
                                      _launchPhoneNumber(phoneNumber);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.location_history,
                                        color: Colors.teal),
                                    onPressed: () {
                                      final tripId = trip['tripId'] ?? '';
                                      _launchOpenStreetMapWithDirections(
                                          tripId);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: isButtonDisabled
                                          ? Colors.grey
                                          : Colors.teal,
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
                                                children: const [
                                                  CircularProgressIndicator(),
                                                  SizedBox(height: 20),
                                                  Text('Processing...'),
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
                                        if (pickupLocation is GeoPoint) {
                                          // If it's a GeoPoint, extract lat and long
                                          pickupLatitude =
                                              pickupLocation.latitude;
                                          pickupLongitude =
                                              pickupLocation.longitude;
                                        } else {
                                          // If it's a place name, convert to lat-long using Nominatim
                                          Map<String, double> latLong =
                                              await _convertPlaceNameToLatLong(
                                                  pickupLocation);
                                          pickupLatitude = latLong['latitude']!;
                                          pickupLongitude =
                                              latLong['longitude']!;
                                        }

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
                                        await _uploadDistanceData(
                                          tripId: trip['tripId'],
                                          driverId: widget.driverId,
                                          userId: trip['userId'],
                                          distance: distance,
                                        );

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
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${trip['pickupLocation'] ?? 'No pickup location'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
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
                                      '${trip['deliveryLocation'] ?? 'No delivery location'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.linear_scale_rounded,
                                    color: Colors.teal,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${double.parse(trip['distance']).toStringAsFixed(0)} km',
                                      style: TextStyle(fontSize: 14),
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
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                formatTimestamp(trip['timestamp']),
                                style:
                                    TextStyle(fontSize: 11, color: Colors.grey),
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

  showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Driver Filter'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedPlace,
                            hint: Text('Select a place'),
                            underline: SizedBox(),
                            items: _places.map((String place) {
                              return DropdownMenuItem<String>(
                                value: place,
                                child: Text(place),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPlace = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Dropdown to select sorting option
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedSort,
                            hint: Text('Select sorting option'),
                            underline: SizedBox(),
                            items: _sortOptions.map((String sortOption) {
                              return DropdownMenuItem<String>(
                                value: sortOption,
                                child: Text(sortOption),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSort = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Dropdown to select vehicle mode
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedVehicleMode,
                            hint: Text('Select vehicle mode'),
                            underline: SizedBox(),
                            items: _vehicleModes.map((String mode) {
                              return DropdownMenuItem<String>(
                                value: mode,
                                child: Text(mode),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedVehicleMode = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedVehicleType,
                            hint: Text('Vehicle Type'),
                            underline: SizedBox(),
                            items: _selectedVehicleType != null
                                ? [
                                    DropdownMenuItem<String>(
                                      value: _selectedVehicleType,
                                      child: Text(_selectedVehicleType!),
                                    )
                                  ]
                                : [],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedVehicleType = newValue!;
                                // Trigger stream filtering by updating _selectedVehicleType
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      // Display selected place

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Closes the popup
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getPickupLocation(String tripId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    return snapshot.data()!;
  }

  // Function to convert place name to lat-long using OSM Nominatim API
  Future<Map<String, double>> _convertPlaceNameToLatLong(
      String placeName) async {
    final String url =
        'https://nominatim.openstreetmap.org/search?q=$placeName&format=json&limit=1';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final latitude = double.parse(data[0]['lat']);
        final longitude = double.parse(data[0]['lon']);
        return {'latitude': latitude, 'longitude': longitude};
      } else {
        throw Exception('Place not found');
      }
    } else {
      throw Exception('Failed to fetch location data');
    }
  }

  // Function to calculate the distance between two points
  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
            startLatitude, startLongitude, endLatitude, endLongitude) /
        1000; // Convert to kilometers
  }

  // Function to upload data to Firestore
  //unused method that updates data to trips
  Future<void> _uploadDistanceData({
    required String tripId,
    required String driverId,
    required String userId,
    required double distance,
  }) async {
    Map<String, dynamic> distanceData = {
      'tripId': tripId,
      'userId': userId,
      'driverId': driverId,
      'distance_between_driver_and_passenger': distance,
    };

    // Reference to the new collection
    CollectionReference distanceCollection = FirebaseFirestore.instance
        .collection('distance_between_driver_and_passenger');

    // Add or update the document in the new collection
    await distanceCollection.add(distanceData);
    setState(() {});
  }
}
