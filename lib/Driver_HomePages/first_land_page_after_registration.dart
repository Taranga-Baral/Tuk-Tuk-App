// import 'dart:async';
// import 'dart:convert';
// import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
// import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
// import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
// import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
// import 'package:final_menu/login_screen/sign_in_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:card_loading/card_loading.dart';
// import 'package:url_launcher/url_launcher.dart';

// class DriverHomePage extends StatefulWidget {
//   final String driverEmail; // Take driverEmail as input

//   const DriverHomePage({super.key, required this.driverEmail});

//   @override
//   State<DriverHomePage> createState() => _DriverHomePageState();
// }

// class _DriverHomePageState extends State<DriverHomePage> {
//   String _selectedSortOption = 'Timestamp Newest First';
//   final int _itemsPerPage = 10;
//   DocumentSnapshot? _lastDocument;
//   bool _hasMore = true;
//   final List<Map<String, dynamic>> _tripDataList = [];
  
//   bool _isLoading = false;
//   final ScrollController _scrollController = ScrollController();
//   Timer? _removeOldTripsTimer;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTrips();

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         _fetchTrips();
//       }
//     });
//   }

//   //send button method

//   void showTripAndUserIdInSnackBar(
//       Map<String, dynamic> tripData, BuildContext context) async {
//     // Extract tripId, userId, and driverId (driver's email)
//     final tripId = tripData['tripId'] ?? 'No Trip ID';
//     final userId = tripData['userId'] ?? 'No User ID';
//     final driverId = widget.driverEmail; // Email from the driver

//     if (tripId == 'No Trip ID' || userId == 'No User ID') {
//       // Show error if tripId or userId is missing
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Invalid Trip or User ID.'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }

//     // Show confirmation dialog before adding the request to Firebase
//     bool confirm = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Request ?'),
//           content: Text(
//             'Are you sure to send request to this user?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false); // Cancel confirmation
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // Confirm action
//               },
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm == true) {
//       try {
//         // Step 1: Add the userId, driverId, and tripId to the new "requestsofDrivers" collection
//         await FirebaseFirestore.instance.collection('requestsofDrivers').add({
//           'tripId': tripId,
//           'userId': userId,
//           'driverId': driverId,
//           'requestTimestamp':
//               FieldValue.serverTimestamp(), // Optional: Add a timestamp
//         });

//         // Step 2: Show a SnackBar with tripId, userId, and driverId
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Request sent successfully!',
//             ),
//             duration: const Duration(seconds: 10), // Show for 10 seconds
//           ),
//         );
//       } catch (e) {
//         // Handle error (e.g., if something goes wrong during the Firebase write)
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error sending request: $e'),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

  // // Fetch trips from Firestore
  // Future<void> _fetchTrips() async {
  //   if (_isLoading || !_hasMore) return;
  //   setState(() => _isLoading = true);

  //   Query query = FirebaseFirestore.instance
  //       .collection('trips')
  //       .orderBy(_getSortField(), descending: _getSortDescending())
  //       .limit(_itemsPerPage);

  //   if (_lastDocument != null) query = query.startAfterDocument(_lastDocument!);

  //   try {
  //     final querySnapshot = await query.get();
  //     if (querySnapshot.docs.isEmpty) {
  //       setState(() => _hasMore = false);
  //     } else {
  //       _lastDocument = querySnapshot.docs.last;
  //       var newTrips = querySnapshot.docs.map((doc) {
  //         var data = doc.data() as Map<String, dynamic>;
  //         data['distance'] =
  //             double.tryParse(data['distance'] as String ?? '') ?? 0.0;
  //         data['fare'] = double.tryParse(data['fare'] as String ?? '') ?? 0.0;
  //         data['tripId'] = doc.id;
  //         return data;
  //       }).toList();

  //       newTrips.sort((a, b) => _sortTrips(a, b));

  //       if (mounted) setState(() => _tripDataList.addAll(newTrips));
  //     }
  //   } catch (e) {
  //     print('Error fetching trips: $e');
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  // // Launch phone number
  // Future<void> _launchPhoneNumber(String phoneNumber) async {
  //   final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  //   if (await canLaunchUrl(launchUri)) {
  //     await launchUrl(launchUri);
  //   } else {
  //     print('Could not launch $launchUri');
  //   }
  // }

  // // Geocode address to latitude and longitude
  // Future<Map<String, double>> _geocodeAddress(String address) async {
  //   final response = await http.get(Uri.parse(
  //       'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}'));

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     if (data.isNotEmpty) {
  //       return {
  //         'latitude': double.parse(data[0]['lat']),
  //         'longitude': double.parse(data[0]['lon']),
  //       };
  //     }
  //   }
  //   throw Exception('Failed to geocode address');
  // }

  // // Launch OpenStreetMap with directions
  // Future<void> _launchOpenStreetMapWithDirections(String tripId) async {
  //   try {
  //     DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
  //         .collection('trips')
  //         .doc(tripId)
  //         .get();

  //     if (tripSnapshot.exists) {
  //       final data = tripSnapshot.data() as Map<String, dynamic>;
  //       final pickupLocation = data['pickupLocation'] as String;
  //       final deliveryLocation = data['deliveryLocation'] as String;

  //       // Try to parse as coordinates
  //       final pickupCoords = _parseCoordinates(pickupLocation);
  //       final deliveryCoords = _parseCoordinates(deliveryLocation);

  //       double pickupLatitude;
  //       double pickupLongitude;
  //       double deliveryLatitude;
  //       double deliveryLongitude;

  //       if (pickupCoords != null) {
  //         pickupLatitude = pickupCoords['latitude']!;
  //         pickupLongitude = pickupCoords['longitude']!;
  //       } else {
  //         final pickupData = await _geocodeAddress(pickupLocation);
  //         pickupLatitude = pickupData['latitude']!;
  //         pickupLongitude = pickupData['longitude']!;
  //       }

  //       if (deliveryCoords != null) {
  //         deliveryLatitude = deliveryCoords['latitude']!;
  //         deliveryLongitude = deliveryCoords['longitude']!;
  //       } else {
  //         final deliveryData = await _geocodeAddress(deliveryLocation);
  //         deliveryLatitude = deliveryData['latitude']!;
  //         deliveryLongitude = deliveryData['longitude']!;
  //       }

  //       final String openStreetMapUrl =
  //           'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

  //       final Uri launchUri = Uri.parse(openStreetMapUrl);

  //       if (await canLaunchUrl(launchUri)) {
  //         await launchUrl(launchUri);
  //       } else {
  //         print('Could not launch $launchUri');
  //       }
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Trip details not found')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching trip details: $e');
  //   }
  // }

  // // Helper function to parse coordinates from string
  // Map<String, double>? _parseCoordinates(String location) {
  //   final parts = location.split(',');
  //   if (parts.length == 2) {
  //     final latitude = double.tryParse(parts[0]);
  //     final longitude = double.tryParse(parts[1]);
  //     if (latitude != null && longitude != null) {
  //       return {'latitude': latitude, 'longitude': longitude};
  //     }
  //   }
  //   return null;
  // }

  // String _getSortField() => _selectedSortOption == 'Timestamp Newest First'
  //     ? 'timestamp'
  //     : 'timestamp';

  // bool _getSortDescending() => _selectedSortOption == 'Timestamp Newest First';

  // int _sortTrips(Map<String, dynamic> a, Map<String, dynamic> b) {
  //   switch (_selectedSortOption) {
  //     case 'Price Expensive First':
  //       return _compareByIntegerPart(b['fare'], a['fare']);
  //     case 'Price Cheap First':
  //       return _compareByIntegerPart(a['fare'], b['fare']);
  //     case 'Distance Largest First':
  //       return _compareByIntegerPart(b['distance'], a['distance']);
  //     case 'Distance Smallest First':
  //       return _compareByIntegerPart(a['distance'], b['distance']);

  //     default:
  //       return 0;
  //   }
  // }

  // int _compareByIntegerPart(double? num1, double? num2) {
  //   return (num1?.truncate() ?? 0).compareTo(num2?.truncate() ?? 0);
  // }

  // // Delete trip with confirmation
  // Future<void> _deleteTripWithConfirmation(String tripId) async {
  //   try {
  //     DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
  //         .collection('trips')
  //         .doc(tripId)
  //         .get();

  //     if (tripSnapshot.exists) {
  //       // Show a confirmation dialog before deleting the trip
  //       bool? confirmed = await showDialog<bool>(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('Confirm Trip?'),
  //             content: Text('Are you sure you want to select this trip'),
  //             actions: <Widget>[
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop(false);
  //                 },
  //                 child: Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop(true);
  //                 },
  //                 child: Text('Confirm'),
  //               ),
  //             ],
  //           );
  //         },
  //       );

  //       if (confirmed == true) {
  //         await _deleteTrip(tripId);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Trip deleted successfully')),
  //         );
  //       }
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Trip not found')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     print('Error checking trip existence: $e');
  //   }
  // }

  // // Delete trip from Firestore
  // Future<void> _deleteTrip(String tripId) async {
  //   try {
  //     await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();
  //   } catch (e) {
  //     print('Error deleting trip: $e');
  //   }
  // }

//   @override
  
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.driverEmail),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               setState(() {
//                 _selectedSortOption = value;
//                 _tripDataList.clear();
//                 _lastDocument = null;
//                 _hasMore = true;
//                 _fetchTrips();
//               });
//             },
//             itemBuilder: (context) => [
//               'Timestamp Newest First',
//               'Price Expensive First',
//               'Price Cheap First',
//               'Distance Largest First',
//               'Distance Smallest First',
//             ]
//                 .map((choice) =>
//                     PopupMenuItem(value: choice, child: Text(choice)))
//                 .toList(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(
//     children: [
//       SizedBox(width: 5),
//       // Button 1
//       _customElevatedButton(
//         context: context,
//         label: 'View Accepted Requests',
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   DriverAcceptedPage(driverId: widget.driverEmail),
//             ),
//           );
//         },
//       ),
//       SizedBox(width: 20),
//       // Button 2
//       _customElevatedButton(
//         context: context,
//         label: 'Filter Trips',
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DriverFilterPage(
//                 driverId: widget.driverEmail,
//               ),
//             ),
//           );
//         },
//       ),
//       SizedBox(width: 20),
//       // Button 3
//       _customElevatedButton(
//         context: context,
//         label: 'Successful Trips',
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DriverSuccessfulTrips(
//                 driverId: widget.driverEmail,
//               ),
//             ),
//           );
//         },
//       ),
//       SizedBox(width: 20),
//       // Button 4
//       _customElevatedButton(
//         context: context,
//         label: 'Chat',
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DriverChatPage(
//                 driverId: widget.driverEmail,
//               ),
//             ),
//           );
//         },
//       ),
//       SizedBox(width: 20),
//       // Button 5
//       _customElevatedButton(
//         context: context,
//         label: 'Passenger Mode',
//         onPressed: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SignInPage(),
//             ),
//           );
//         },
//       ),
//     ],
//   ),
// ),

//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: _tripDataList.length + (_hasMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index >= _tripDataList.length) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     child: CardLoading(
//                         height: 150, borderRadius: BorderRadius.circular(15)),
//                   );
//                 }
//                 var tripData = _tripDataList[index];
//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   child: Column(
//                     children: [
//                       Card(
                        
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15)),
//                         elevation: 0,
//                         color: Colors.transparent,
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.all(16),
//                           title: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       tripData['username'] ?? 'No Username',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold, fontSize: 18),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   IconButton(
                              
//                                     icon: const Icon(Icons.phone),
//                                     onPressed: () {
//                                       final phoneNumber = tripData['phone'] ?? '';
//                                       _launchPhoneNumber(phoneNumber);
//                                     },
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.location_history),
//                                     onPressed: () {
//                                       final tripId = tripData['tripId'] ?? '';
//                                       _launchOpenStreetMapWithDirections(tripId);
//                                     },
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   IconButton(
//                                       icon: const Icon(Icons.send),
//                                       onPressed: () {
//                                         showTripAndUserIdInSnackBar(tripData, context);
//                                       }),
//                                 ],
//                               ),
                      
//                               Row(
//                                 children: [
//                                   Text(tripData['no_of_person'].toString(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   Icon(Icons.info_outline),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
                      
                      
//                                   Text(tripData['vehicle_mode'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),),
                                  
                      
                      
//                                 ],
//                               ),


                              
//                               SizedBox(
//                                 height: 10,
//                               ),
//                             ],
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                   '${tripData['municipalityDropdown'] ?? 'No Record of Municipality'}',
//                                   style: const TextStyle(
//                                       fontSize: 14, fontWeight: FontWeight.w400)),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                   'Pickup: ${tripData['pickupLocation'] ?? 'No pickup location'}',
//                                   style: const TextStyle(
//                                       fontSize: 14, fontWeight: FontWeight.w300)),
//                               Text(
//                                   'Delivery: ${tripData['deliveryLocation'] ?? 'No delivery location'}',
//                                   style: const TextStyle(
//                                       fontSize: 14, fontWeight: FontWeight.w300)),
//                               Text(
//                                   'Distance: ${tripData['distance']?.toStringAsFixed(1) ?? 'No distance'} km',
//                                   style: const TextStyle(
//                                       fontSize: 14, fontWeight: FontWeight.w300)),
//                               Text(
//                                   'Fare: NPR ${tripData['fare']?.toStringAsFixed(0) ?? 'No fare'}',
//                                   style: const TextStyle(
//                                       fontSize: 14, fontWeight: FontWeight.w300)),
//                               Text('Phone: ${tripData['phone'] ?? 'No phone'}',
//                                   style: const TextStyle(
//                                       fontSize: 14, fontWeight: FontWeight.w300)),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                   'Timestamp: ${tripData['timestamp']?.toDate() ?? 'No timestamp'}',
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Colors.grey)),
//                             ],
//                           ),
//                           isThreeLine: true,
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 15,right: 15),
//                         child: Divider(),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _removeOldTripsTimer?.cancel();
//     super.dispose();
//   }
// }
// Widget _customElevatedButton({
//   required BuildContext context,
//   required String label,
//   required VoidCallback onPressed,
// }) {
//   return ElevatedButton(
//     onPressed: onPressed,
//     style: ElevatedButton.styleFrom(
//       foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 83, 182, 136), // Text color
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(30), // Rounded corners
//       ),
//       elevation: 2, // Shadow effect
//     ),
//     child: Text(
//       label,
//       style: const TextStyle(
//         fontSize: 16, // Text size
//         fontWeight: FontWeight.bold, // Text weight
//       ),
//     ),
//   );
// }




























































// lib/driver_home_page/driver_home_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:final_menu/Driver_HomePages/sorting_pages.dart';
import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trip_model.dart';
import 'trip_card_widget.dart';
// class DriverHomePage extends StatefulWidget {
//   final String driverEmail;

//   const DriverHomePage({super.key, required this.driverEmail});

//   @override
//   State<DriverHomePage> createState() => _DriverHomePageState();
// }

// class _DriverHomePageState extends State<DriverHomePage> {
//   String _selectedSortOption = 'Timestamp Newest First';
//   final int _itemsPerPage = 10;
//   DocumentSnapshot? _lastDocument;
//   bool _hasMore = true;
//   final List<TripModel> _tripDataList = [];
  
//   bool _isLoading = false;
//   final ScrollController _scrollController = ScrollController();
//   Timer? _removeOldTripsTimer;
// Future<void> _launchPhoneNumber(String phoneNumber) async {
//   final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//   if (await canLaunchUrl(launchUri)) {
//     await launchUrl(launchUri);

//   } else {
  
//     SnackBar(content: Text('Couldnot launch Location'));
//   }
// }


//   Future<Map<String, double>> _geocodeAddress(String address) async {
//     final response = await http.get(Uri.parse(
//         'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data.isNotEmpty) {
//         return {
//           'latitude': double.parse(data[0]['lat']),
//           'longitude': double.parse(data[0]['lon']),
//         };
//       }
//     }
//     throw Exception('Failed to geocode address');
//   }

//   Future<void> _launchOpenStreetMapWithDirections(String tripId) async {
//     try {
//       DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
//           .collection('trips')
//           .doc(tripId)
//           .get();

//       if (tripSnapshot.exists) {
//         final data = tripSnapshot.data() as Map<String, dynamic>;
//         final pickupLocation = data['pickupLocation'] as String;
//         final deliveryLocation = data['deliveryLocation'] as String;

//         // Try to parse as coordinates
//         final pickupCoords = _parseCoordinates(pickupLocation);
//         final deliveryCoords = _parseCoordinates(deliveryLocation);

//         double pickupLatitude;
//         double pickupLongitude;
//         double deliveryLatitude;
//         double deliveryLongitude;

//         if (pickupCoords != null) {
//           pickupLatitude = pickupCoords['latitude']!;
//           pickupLongitude = pickupCoords['longitude']!;
//         } else {
//           final pickupData = await _geocodeAddress(pickupLocation);
//           pickupLatitude = pickupData['latitude']!;
//           pickupLongitude = pickupData['longitude']!;
//         }

//         if (deliveryCoords != null) {
//           deliveryLatitude = deliveryCoords['latitude']!;
//           deliveryLongitude = deliveryCoords['longitude']!;
//         } else {
//           final deliveryData = await _geocodeAddress(deliveryLocation);
//           deliveryLatitude = deliveryData['latitude']!;
//           deliveryLongitude = deliveryData['longitude']!;
//         }

//         final String openStreetMapUrl =
//             'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

//         final Uri launchUri = Uri.parse(openStreetMapUrl);

//         if (await canLaunchUrl(launchUri)) {
//           await launchUrl(launchUri);
//         } else {
//           print('Could not launch $launchUri');
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Trip details not found')),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error fetching trip details: $e');
//     }
//   }

//   Map<String, double>? _parseCoordinates(String location) {
//     final parts = location.split(',');
//     if (parts.length == 2) {
//       final latitude = double.tryParse(parts[0]);
//       final longitude = double.tryParse(parts[1]);
//       if (latitude != null && longitude != null) {
//         return {'latitude': latitude, 'longitude': longitude};
//       }
//     }
//     return null;
//   }

//   String _getSortField() => _selectedSortOption == 'Timestamp Newest First' ? 'timestamp' : 'timestamp';

//   bool _getSortDescending() => _selectedSortOption == 'Timestamp Newest First';

//   int _sortTrips(TripModel a, TripModel b) {
//     switch (_selectedSortOption) {
//       case 'Price Expensive First':
//         return _compareByIntegerPart(b.fare, a.fare);
//       case 'Price Cheap First':
//         return _compareByIntegerPart(a.fare, b.fare);
//       case 'Distance Largest First':
//         return _compareByIntegerPart(b.distance, a.distance);
//       case 'Distance Smallest First':
//         return _compareByIntegerPart(a.distance, b.distance);
//       default: // Timestamp Newest First
//         return b.timestamp.compareTo(a.timestamp);
//     }
//   }

//   int _compareByIntegerPart(double a, double b) {
//     return a.compareTo(b);
//   }

//   Future<void> _navigateToSortingPage() async {
//     final selectedOption = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => SortingPage(selectedSortOption: _selectedSortOption)),
//     );

//     if (selectedOption != null) {
//       setState(() {
//         _selectedSortOption = selectedOption;
//         _tripDataList.sort((a, b) => _sortTrips(a, b));
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchTrips();

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//         _fetchTrips();
//       }
//     });
//   }

  // void showTripAndUserIdInSnackBar(TripModel tripData, BuildContext context) async {
  //   final tripId = tripData.tripId ?? 'No Trip ID';
  //   final userId = tripData.username ?? 'No User ID';
  //   final driverId = widget.driverEmail;

  //   if (tripId == 'No Trip ID' || userId == 'No User ID') {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Invalid Trip or User ID.'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //     return;
  //   }

//     bool confirm = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Request?'),
//           content: Text('Are you sure to send request to this user?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//               },
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm == true) {
//       try {
//         await FirebaseFirestore.instance.collection('requestsofDrivers').add({
//           'tripId': tripId,
//           'userId': userId,
//           'driverId': driverId,
//           'requestTimestamp': FieldValue.serverTimestamp(),
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Request sent successfully!'),
//             duration: const Duration(seconds: 10),
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error sending request: $e'),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

  // Future<void> _fetchTrips() async {
  //   if (_isLoading || !_hasMore) return;
  //   setState(() => _isLoading = true);

  //   Query query = FirebaseFirestore.instance
  //       .collection('trips')
  //       .orderBy(_getSortField(), descending: _getSortDescending())
  //       .limit(_itemsPerPage);

  //   if (_lastDocument != null) query = query.startAfterDocument(_lastDocument!);

  //   try {
  //     final querySnapshot = await query.get();
  //     if (querySnapshot.docs.isEmpty) {
  //       setState(() => _hasMore = false);
  //     } else {
  //       _lastDocument = querySnapshot.docs.last;
  //       var newTrips = querySnapshot.docs.map((doc) {
  //         var data = doc.data() as Map<String, dynamic>;
  //         data['distance'] = double.tryParse(data['distance'] as String ?? '') ?? 0.0;
  //         data['fare'] = double.tryParse(data['fare'] as String ?? '') ?? 0.0;
  //         data['tripId'] = doc.id;
  //         return TripModel.fromJson(data);
  //       }).toList();

  //       // Combine new trips with the existing list
  //       _tripDataList.addAll(newTrips);

  //       // Sort the complete trip list
  //       _tripDataList.sort((a, b) => _sortTrips(a, b));

  //       if (mounted) setState(() {});
  //     }
  //   } catch (e) {
  //     print('Error fetching trips: $e');
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

//   // Other methods remain unchanged...

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Home'),
//         actions: [
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.ads_click),
//                 onPressed: (){},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.sort),
//                 onPressed: _navigateToSortingPage,
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: _isLoading && _tripDataList.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               controller: _scrollController,
//               itemCount: _tripDataList.length,
//            itemBuilder: (context, index) {
//   final tripData = _tripDataList[index];
//   return TripCardWidget(
//     tripData: tripData,
//     index: index, // Pass the current index
//     onPhoneTap: () {
//       if (tripData.phoneNumber != null && tripData.phoneNumber!.isNotEmpty) {
//         _launchPhoneNumber(tripData.phoneNumber!);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Phone number not available')),
//         );
//       }
//     },
//     onMapTap: () => _launchOpenStreetMapWithDirections(tripData.tripId!),
//     onRequestTap: () => showTripAndUserIdInSnackBar(tripData, context),
//   );
// },
//             ),
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }import 'package:flutter/material.dart';
// Import your other necessary files here...

class DriverHomePage extends StatefulWidget {
  final String driverEmail;

  const DriverHomePage({super.key, required this.driverEmail});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String _selectedSortOption = 'Timestamp Newest First';
  final int _itemsPerPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  final List<TripModel> _tripDataList = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      SnackBar(content: Text('Could not launch Location'));
    }
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

  String _getSortField() => _selectedSortOption == 'Timestamp Newest First' ? 'timestamp' : 'timestamp';

  bool _getSortDescending() => _selectedSortOption == 'Timestamp Newest First';

  int _sortTrips(TripModel a, TripModel b) {
    switch (_selectedSortOption) {
      case 'Price Expensive First':
        return _compareByIntegerPart(b.fare, a.fare);
      case 'Price Cheap First':
        return _compareByIntegerPart(a.fare, b.fare);
      case 'Distance Largest First':
        return _compareByIntegerPart(b.distance, a.distance);
      case 'Distance Smallest First':
        return _compareByIntegerPart(a.distance, b.distance);
      default: // Timestamp Newest First
        return b.timestamp.compareTo(a.timestamp);
    }
  }

  int _compareByIntegerPart(double a, double b) {
    return a.compareTo(b);
  }

  Future<void> _navigateToSortingPage() async {
    final selectedOption = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SortingPage(selectedSortOption: _selectedSortOption)),
    );

    if (selectedOption != null) {
      setState(() {
        _selectedSortOption = selectedOption;
        _tripDataList.sort((a, b) => _sortTrips(a, b));
      });
    }
  }
  // Other existing methods...
  Future<void> _fetchTrips() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('trips')
        .orderBy(_getSortField(), descending: _getSortDescending())
        .limit(_itemsPerPage);

    if (_lastDocument != null) query = query.startAfterDocument(_lastDocument!);

    try {
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        _lastDocument = querySnapshot.docs.last;
        var newTrips = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['distance'] = double.tryParse(data['distance'] as String ?? '') ?? 0.0;
          data['fare'] = double.tryParse(data['fare'] as String ?? '') ?? 0.0;
          data['tripId'] = doc.id;
          return TripModel.fromJson(data);
        }).toList();

        // Combine new trips with the existing list
        _tripDataList.addAll(newTrips);

        // Sort the complete trip list
        _tripDataList.sort((a, b) => _sortTrips(a, b));

        if (mounted) setState(() {});
      }
    } catch (e) {
      print('Error fetching trips: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchTrips();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchTrips();
      }
    });
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'accepted_trips':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverAcceptedPage(driverEmail: widget.driverEmail, driverId: widget.driverEmail,),
          ),
        );
        break;
      case 'driver_filter':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverFilterPage(driverId: widget.driverEmail,),
          ),
        );
        break;
      case 'successful_trips':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverSuccessfulTrips(driverId: widget.driverEmail,),
          ),
        );
        break;
      case 'view_messages':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverChatPage(driverId: widget.driverEmail,),
          ),
        );
        break;
      case 'passenger_mode':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignInPage(), // Replace with your SignInPage
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _navigateToSortingPage,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.ads_click),
            onSelected: _onMenuItemSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 'accepted_trips', child: Text('Accepted Trips')),
                const PopupMenuItem(value: 'driver_filter', child: Text('Driver Filter Page')),
                const PopupMenuItem(value: 'successful_trips', child: Text('Successful Trips')),
                const PopupMenuItem(value: 'view_messages', child: Text('View Messages')),
                const PopupMenuItem(value: 'passenger_mode', child: Text('Passenger Mode')),
              ];
            },
          ),
        ],
      ),
      body: _isLoading && _tripDataList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _tripDataList.length,
              itemBuilder: (context, index) {
                final tripData = _tripDataList[index];
                return TripCardWidget(
                  tripData: tripData,
                  onPhoneTap: () {
                    if (tripData.phoneNumber != null && tripData.phoneNumber!.isNotEmpty) {
                      _launchPhoneNumber(tripData.phoneNumber!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Phone number not available')),
                      );
                    }
                  },
                  onMapTap: () => _launchOpenStreetMapWithDirections(tripData.tripId!),
                  onRequestTap: () => showTripAndUserIdInSnackBar(tripData, context), index: index,
                );
              },
            ),
    );
  }
  void showTripAndUserIdInSnackBar(TripModel tripData, BuildContext context) async {
    final tripId = tripData.tripId ?? 'No Trip ID';
    final userId = tripData.username ?? 'No User ID';
    final driverId = widget.driverEmail;

    if (tripId == 'No Trip ID' || userId == 'No User ID') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Trip or User ID.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
}