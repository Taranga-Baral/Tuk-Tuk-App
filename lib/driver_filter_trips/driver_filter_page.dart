
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class DriverFilterPage extends StatefulWidget {
//   final String driverId;

//   DriverFilterPage({required this.driverId});

//   @override
//   _DriverFilterPageState createState() => _DriverFilterPageState();
// }

// class _DriverFilterPageState extends State<DriverFilterPage> {
//   String? _selectedPlace;
//   String? _selectedSort;
//   final List<String> _places = [
//     'Bharatpur Metropolitan City',
//     'Kalika Municipality',
//     'Khairahani Municipality',
//     'Madi Municipality',
//     'Ratnanagar Municipality',
//     'Rapti Municipality',
//     'Ichchhakamana Rural Municipality'
//   ];

//   final List<String> _sortOptions = [
//     'Timestamp Newest First',
//     'Price Expensive First',
//     'Price Cheap First',
//     'Distance Largest First',
//     'Distance Smallest First'
//   ];

//   // Helper function to convert string to numeric value
//   int _parseStringToInt(String? value) {
//     return int.tryParse(value ?? '') ?? 0;
//   }

//   // Stream to fetch trips based on the selected place and sort them
//   Stream<List<Map<String, dynamic>>> _getTripsStream() {
//     if (_selectedPlace == null) {
//       return Stream.value([]);
//     }

//     // Fetch trips from Firestore
//     return FirebaseFirestore.instance
//         .collection('trips')
//         .where('municipalityDropdown', isEqualTo: _selectedPlace)
//         .snapshots()
//         .map((snapshot) {
//           final trips = snapshot.docs.map((doc) => {
//             'tripId': doc.id, // Document ID as tripId
//             ...doc.data(),    // Other document fields
//           }).toList();

//           // Sort trips based on the selected sort option
//           if (_selectedSort == 'Timestamp Newest First') {
//             trips.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
//           } else if (_selectedSort == 'Price Expensive First') {
//             trips.sort((a, b) => _parseStringToInt(b['fare']) - _parseStringToInt(a['fare']));
//           } else if (_selectedSort == 'Price Cheap First') {
//             trips.sort((a, b) => _parseStringToInt(a['fare']) - _parseStringToInt(b['fare']));
//           } else if (_selectedSort == 'Distance Largest First') {
//             trips.sort((a, b) => _parseStringToInt(b['distance']) - _parseStringToInt(a['distance']));
//           } else if (_selectedSort == 'Distance Smallest First') {
//             trips.sort((a, b) => _parseStringToInt(a['distance']) - _parseStringToInt(b['distance']));
//           }

//           return trips;
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Filter Page'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Display the passed driverId
//             Text(
//               'Driver ID: ${widget.driverId}',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             // Dropdown to select municipality
//             DropdownButton<String>(
//               value: _selectedPlace,
//               hint: Text('Select a place'),
//               items: _places.map((String place) {
//                 return DropdownMenuItem<String>(
//                   value: place,
//                   child: Text(place),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedPlace = newValue;
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             // Dropdown to select sorting option
//             DropdownButton<String>(
//               value: _selectedSort,
//               hint: Text('Select sorting option'),
//               items: _sortOptions.map((String sortOption) {
//                 return DropdownMenuItem<String>(
//                   value: sortOption,
//                   child: Text(sortOption),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedSort = newValue;
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             // Display selected place
//             Text(
//               'Selected Place: ${_selectedPlace ?? 'None selected'}',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             // StreamBuilder to display trips
//             Expanded(
//               child: StreamBuilder<List<Map<String, dynamic>>>(
//                 stream: _getTripsStream(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//                   final trips = snapshot.data ?? [];
//                   if (trips.isEmpty) {
//                     return Center(child: Text('No trips available for selected place.'));
//                   }
//                   return ListView.builder(
//                     itemCount: trips.length,
//                     itemBuilder: (context, index) {
//                       final trip = trips[index];
//                       return Card(
//                         elevation: 4.0,
//                         margin: EdgeInsets.symmetric(vertical: 8.0),
//                         child: ListTile(
//                           contentPadding: EdgeInsets.all(16.0),
//                           title: Text('Pickup Location: ${trip['pickupLocation'] ?? 'N/A'}'),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Delivery Location: ${trip['deliveryLocation'] ?? 'N/A'}'),
//                               Text('Trip ID: ${trip['tripId'] ?? 'N/A'}'), // Document ID as tripId
//                               Text('Driver ID: ${widget.driverId}'), // Display passed driverId
//                               Text('Fare: ${trip['fare'] ?? 'N/A'}'),
//                               Text('Distance: ${trip['distance'] ?? 'N/A'}'),
//                               // Add more fields as needed
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverFilterPage extends StatefulWidget {
  final String driverId;

  DriverFilterPage({required this.driverId});

  @override
  _DriverFilterPageState createState() => _DriverFilterPageState();
}

class _DriverFilterPageState extends State<DriverFilterPage> {
  String? _selectedPlace;
  String? _selectedSort;
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

  // Helper function to convert string before '.' to integer
  int _parseStringToInt(String? value) {
    if (value == null || value.isEmpty) return 0;
    final parts = value.split('.');
    return int.tryParse(parts[0]) ?? 0;
  }

  // Stream to fetch trips based on the selected place and sort them
  Stream<List<Map<String, dynamic>>> _getTripsStream() {
    if (_selectedPlace == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('trips')
        .where('municipalityDropdown', isEqualTo: _selectedPlace)
        .snapshots()
        .map((snapshot) {
          final trips = snapshot.docs.map((doc) => {
            'tripId': doc.id, // Document ID as tripId
            ...doc.data(),    // Other document fields
          }).toList();

          // Sort trips based on the selected sort option
          if (_selectedSort == 'Timestamp Newest First') {
            trips.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
          } else if (_selectedSort == 'Price Expensive First') {
            trips.sort((a, b) => _parseStringToInt(b['fare']) - _parseStringToInt(a['fare']));
          } else if (_selectedSort == 'Price Cheap First') {
            trips.sort((a, b) => _parseStringToInt(a['fare']) - _parseStringToInt(b['fare']));
          } else if (_selectedSort == 'Distance Largest First') {
            trips.sort((a, b) => _parseStringToInt(b['distance']) - _parseStringToInt(a['distance']));
          } else if (_selectedSort == 'Distance Smallest First') {
            trips.sort((a, b) => _parseStringToInt(a['distance']) - _parseStringToInt(b['distance']));
          }

          return trips;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Filter Page'),
        backgroundColor: Colors.teal, // Customize app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select municipality
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedPlace,
                  hint: Text('Select a place'),
                  underline: SizedBox(), // Remove the underline
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedSort,
                  hint: Text('Select sorting option'),
                  underline: SizedBox(), // Remove the underline
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
            SizedBox(height: 20),

            // Display selected place
            Text(
              'Selected Place: ${_selectedPlace ?? 'None selected'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 20),

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
                    return Center(child: Text('No trips available for selected place.'));
                  }
                  return ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${trip['municipalityDropdown'] ?? 'No Record of Municipality'}',
                                      style: TextStyle(fontSize: 14, color: Colors.black54),
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
                                    icon: Icon(Icons.location_history, color: Colors.teal),
                                    onPressed: () {
                                      final tripId = trip['tripId'] ?? '';
                                      _launchOpenStreetMapWithDirections(tripId);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.send, color: Colors.teal),
                                    onPressed: () {
                                      showTripAndUserIdInSnackBar(trip, context);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Pickup: ${trip['pickupLocation'] ?? 'No pickup location'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Delivery: ${trip['deliveryLocation'] ?? 'No delivery location'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Distance: ${double.parse(trip['distance']).toStringAsFixed(1)} km',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Fare: NPR ${double.parse(trip['fare']).toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Phone: ${trip['phone'] ?? 'No phone'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Timestamp: ${trip['timestamp']?.toDate() ?? 'No timestamp'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
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

  // Other helper functions (launch URL, phone call, snack bar, etc.)
  // ...


  
   void showTripAndUserIdInSnackBar(
      Map<String, dynamic> tripData, BuildContext context) async {
    // Extract tripId, userId, and driverId (driver's email)
    final tripId = tripData['tripId'] ?? 'No Trip ID';
    final userId = tripData['userId'] ?? 'No User ID';
    final driverId = widget.driverId; 
    if (tripId == 'No Trip ID' || userId == 'No User ID') {
      // Show error if tripId or userId is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Trip or User ID.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show confirmation dialog before adding the request to Firebase
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Request ?'),
          content: Text(
            'Are you sure to send request to this user?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel confirmation
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm action
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Step 1: Add the userId, driverId, and tripId to the new "requestsofDrivers" collection
        await FirebaseFirestore.instance.collection('requestsofDrivers').add({
          'tripId': tripId,
          'userId': userId,
          'driverId': driverId,
          'requestTimestamp':
              FieldValue.serverTimestamp(), // Optional: Add a timestamp
        });

        // Step 2: Show a SnackBar with tripId, userId, and driverId
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Request sent successfully!',
            ),
            duration: const Duration(seconds: 10), // Show for 10 seconds
          ),
        );
      } catch (e) {
        // Handle error (e.g., if something goes wrong during the Firebase write)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending request: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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

}