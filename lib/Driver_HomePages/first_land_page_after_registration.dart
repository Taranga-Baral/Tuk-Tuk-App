// import 'dart:async';
// import 'dart:convert';
// import 'package:final_menu/Driver_HomePages/sorting_pages.dart';
// import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
// import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
// import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
// import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
// import 'package:final_menu/login_screen/sign_in_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'trip_model.dart';
// import 'trip_card_widget.dart';

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
//   final List<bool> _isButtonDisabledList =
//       []; // List to hold button states for each trip

//   final List<TripModel> _tripDataList = [];
//   bool _isLoading = false;
//   final ScrollController _scrollController = ScrollController();

//   Future<void> _launchPhoneNumber(String phoneNumber) async {
//     final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(launchUri)) {
//       await launchUrl(launchUri);
//     } else {
//       SnackBar(content: Text('Could not launch Location'));
//     }
//   }

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

//   String _getSortField() => _selectedSortOption == 'Timestamp Newest First'
//       ? 'timestamp'
//       : 'timestamp';

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
//       MaterialPageRoute(
//           builder: (context) =>
//               SortingPage(selectedSortOption: _selectedSortOption)),
//     );

//     if (selectedOption != null) {
//       setState(() {
//         _selectedSortOption = selectedOption;
//         _tripDataList.sort((a, b) => _sortTrips(a, b));
//       });
//     }
//   }

//   // Other existing methods...
//   Future<void> _fetchTrips() async {
//     if (_isLoading || !_hasMore)
//       return; // Check if already loading or no more trips
//     setState(() => _isLoading = true); // Set loading state to true

//     Query query = FirebaseFirestore.instance
//         .collection('trips')
//         .orderBy(_getSortField(), descending: _getSortDescending())
//         .limit(_itemsPerPage); // Limit results to items per page

//     if (_lastDocument != null) {
//       query = query.startAfterDocument(
//           _lastDocument!); // Start after last fetched document
//     }

//     try {
//       final querySnapshot = await query.get();
//       if (querySnapshot.docs.isEmpty) {
//         setState(() => _hasMore = false); // No more trips to load
//         await _loadButtonStates();
//       } else {
//         _lastDocument = querySnapshot.docs.last; // Update last document
//         var newTrips = querySnapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           data['distance'] =
//               double.tryParse(data['distance'] as String ?? '') ?? 0.0;
//           data['fare'] = double.tryParse(data['fare'] as String ?? '') ?? 0.0;
//           data['tripId'] = doc.id; // Get trip ID
//           return TripModel.fromJson(data);
//         }).toList();

//         _tripDataList.addAll(newTrips); // Add new trips to the list

//         // Initialize button states for newly added trips
//         for (var trip in newTrips) {
//           _isButtonDisabledList.add(false); // Set initial state as enabled
//         }

//         // Load button states after new trips are fetched
//         await _loadButtonStates();

//         // Sort the complete trip list
//         _tripDataList.sort((a, b) => _sortTrips(a, b));

//         if (mounted) setState(() {}); // Update UI
//       }
//     } catch (e) {
//       print('Error fetching trips: $e'); // Handle any errors
//     } finally {
//       if (mounted)
//         setState(() => _isLoading = false); // Set loading state to false
//     }
//   }

//   Future<void> _loadButtonStates() async {
//     final driverId = widget.driverEmail;

//     for (int i = 0; i < _tripDataList.length; i++) {
//       final tripId = _tripDataList[i].tripId!;

//       final docSnapshot = await FirebaseFirestore.instance
//           .collection('driverButtonStates')
//           .doc(driverId)
//           .collection('trips')
//           .doc(tripId)
//           .get();

//       bool isDisabled = false;
//       if (docSnapshot.exists) {
//         isDisabled = docSnapshot.data()?['isButtonDisabled'] ?? false;
//       }

//       // Ensure the list is long enough
//       if (i < _isButtonDisabledList.length) {
//         _isButtonDisabledList[i] = isDisabled;
//       } else {
//         _isButtonDisabledList.add(isDisabled);
//       }
//     }

//     setState(() {}); // Update the UI after loading the states
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadButtonStates(); // Load button states
//     _fetchTrips();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         _fetchTrips();
//       }
//     });
//   }

//   void _setButtonState(int index) async {
//     final tripId = _tripDataList[index].tripId!;
//     final driverId = widget.driverEmail;

//     // Save the button state to Firestore
//     await FirebaseFirestore.instance
//         .collection('driverButtonStates')
//         .doc(driverId)
//         .collection('trips')
//         .doc(tripId)
//         .set({'isButtonDisabled': true});

//     setState(() {
//       _isButtonDisabledList[index] =
//           true; // Update the local state for immediate UI feedback
//     });
//   }

//   void _onMenuItemSelected(String value) {
//     switch (value) {
//       case 'accepted_trips':
//         Navigator.push(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) =>
//                 DriverAcceptedPage(driverId: widget.driverEmail),
//             transitionsBuilder:
//                 (context, animation, secondaryAnimation, child) {
//               const begin = Offset(1.0, 0.0); // Slide in from the right
//               const end = Offset.zero;
//               const curve = Curves.decelerate;

//               var tween =
//                   Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//               var offsetAnimation = animation.drive(tween);

//               return SlideTransition(
//                 position: offsetAnimation,
//                 child: child,
//               );
//             },
//           ),
//         );

//         break;
//       case 'driver_filter':
//         Navigator.push(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) =>
//                 DriverFilterPage(driverId: widget.driverEmail),
//             transitionsBuilder:
//                 (context, animation, secondaryAnimation, child) {
//               const begin = Offset(1.0, 0.0); // Slide in from the right
//               const end = Offset.zero;
//               const curve = Curves.decelerate;

//               var tween =
//                   Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//               var offsetAnimation = animation.drive(tween);

//               return SlideTransition(
//                 position: offsetAnimation,
//                 child: child,
//               );
//             },
//           ),
//         );

//         break;
//       case 'successful_trips':
//         Navigator.push(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) =>
//                 DriverSuccessfulTrips(driverId: widget.driverEmail),
//             transitionsBuilder:
//                 (context, animation, secondaryAnimation, child) {
//               const begin = Offset(1.0, 0.0); // Slide in from the right
//               const end = Offset.zero;
//               const curve = Curves.decelerate;

//               var tween =
//                   Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//               var offsetAnimation = animation.drive(tween);

//               return SlideTransition(
//                 position: offsetAnimation,
//                 child: child,
//               );
//             },
//           ),
//         );
//         break;
//       case 'view_messages':
//         Navigator.push(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) =>
//                 DriverChatPage(driverId: widget.driverEmail),
//             transitionsBuilder:
//                 (context, animation, secondaryAnimation, child) {
//               const begin = Offset(1.0, 0.0); // Slide in from the right
//               const end = Offset.zero;
//               const curve = Curves.decelerate;

//               var tween =
//                   Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//               var offsetAnimation = animation.drive(tween);

//               return SlideTransition(
//                 position: offsetAnimation,
//                 child: child,
//               );
//             },
//           ),
//         );
//         break;
//       case 'passenger_mode':
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SignInPage(), // Replace with your SignInPage
//           ),
//         );
//         break;
//       default:
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Home'),
//         actions: [
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.refresh),
//                 onPressed: () {
//                   setState(() {
//                     // Add any necessary state changes here before navigation
//                   });

//                   // Navigate with pushReplacement to DriverHomePage
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => DriverHomePage(
//                               driverEmail: widget.driverEmail,
//                             )),
//                   );
//                 },
//               ),
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.sort_rounded),
//                 onSelected: _onMenuItemSelected,
//                 itemBuilder: (BuildContext context) {
//                   return [
//                     const PopupMenuItem(
//                         value: 'accepted_trips',
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Text('Accepted Trips'),
//                             Icon(
//                               Icons.done,
//                               size: 16,
//                             ),
//                           ],
//                         )),
//                     const PopupMenuItem(
//                         value: 'driver_filter',
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Text('Filter Trips'),
//                             Icon(
//                               Icons.filter_alt_outlined,
//                               size: 16,
//                             ),
//                           ],
//                         )),
//                     const PopupMenuItem(
//                         value: 'successful_trips',
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Text('Successful Trips'),
//                             Icon(
//                               Icons.check_circle_outline,
//                               size: 16,
//                             )
//                           ],
//                         )),
//                     const PopupMenuItem(
//                         value: 'view_messages',
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Text('View Messages'),
//                             Icon(
//                               Icons.chat_bubble_outline_outlined,
//                               size: 16,
//                             ),
//                           ],
//                         )),
//                     const PopupMenuItem(
//                         value: 'passenger_mode', child: Row(
//                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,

//                           children: [
//                             Text('Passenger Mode'),
//                             Icon(Icons.person_outline_sharp)
//                           ],
//                         )),
//                   ];
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: _isLoading && _tripDataList.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               controller: _scrollController,
//               itemCount: _tripDataList.length +
//                   (_hasMore
//                       ? 1
//                       : 0), // Loading indicator if more trips are available
//               itemBuilder: (context, index) {
//                 if (index == _tripDataList.length) {
//                   return Center(
//                       child:
//                           CircularProgressIndicator()); // Loading indicator at the end
//                 }
//                 final tripData = _tripDataList[index];
//                 // Check the index against the length of _isButtonDisabledList
//                 final isButtonDisabled = index < _isButtonDisabledList.length
//                     ? _isButtonDisabledList[index]
//                     : false; // Default to false if index is out of bounds

//                 return TripCardWidget(
//                   tripData: _tripDataList[index],
//                   onPhoneTap: () {
//                     if (tripData.phoneNumber != null &&
//                         tripData.phoneNumber!.isNotEmpty) {
//                       _launchPhoneNumber(tripData.phoneNumber!);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Phone number not available')),
//                       );
//                     }
//                   },
//                   onMapTap: () =>
//                       _launchOpenStreetMapWithDirections(tripData.tripId!),
//                   onRequestTap: () {
//                     _setButtonState(index); // Call to disable the button
//                     showTripAndUserIdInSnackBar(
//                         _tripDataList[index], context, index);
//                   },
//                   index: index,
//                   isButtonDisabled:
//                       isButtonDisabled, // Use the checked value here
//                 );
//               },
//             ),
//     );
//   }

//   Future<void> showTripAndUserIdInSnackBar(
//       TripModel tripData, BuildContext context, int index) async {
//     final tripId = tripData.tripId ?? 'No Trip ID';
//     final userId = tripData.userId ?? 'No User ID';
//     final driverId = widget.driverEmail;

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

//     try {
//       // Step 1: Add the userId, driverId, and tripId to the new "requestsofDrivers" collection
//       await FirebaseFirestore.instance.collection('requestsofDrivers').add({
//         'tripId': tripId,
//         'userId': userId,
//         'driverId': driverId,
//         'requestTimestamp':
//             FieldValue.serverTimestamp(), // Optional: Add a timestamp
//       });

//       // Step 2: Darken the button and show a SnackBar
//       _setButtonState(index); // Call to disable the button after confirmation

//       // Show a SnackBar with tripId, userId, and driverId
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Request sent successfully!',
//           ),
//           duration: const Duration(seconds: 10), // Show for 10 seconds
//         ),
//       );
//     } catch (e) {
//       // Handle error (e.g., if something goes wrong during the Firebase write)
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error sending request: $e'),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:final_menu/Driver_HomePages/sorting_pages.dart';
import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
import 'package:final_menu/galli_maps/driver_view_passenger_location/driver_view_passenger_location.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trip_model.dart';
import 'trip_card_widget.dart';
import 'package:shimmer/shimmer.dart';

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
  List<bool> _isButtonDisabledList =
      []; // List to hold button states for each trip

  List<TripModel> _tripDataList = [];

  StreamSubscription<List<TripModel>>? _tripsSubscription;

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

  Future<void> _refreshData() async {
    setState(() {});
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

  Future<String?> PassengerSelectedVehicleMode(
      String tripId, String userId, String driverId) async {
    try {
      // Query the "trips" collection for the document with matching tripId
      final snapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();

      // Check if the document exists
      if (snapshot.exists) {
        // Access the document data
        final tripData = snapshot.data();

        // Check if userId matches to ensure correct document
        if (tripData?['userId'] == userId) {
          // Return the 'vehicle_mode' field from the document
          return tripData?['vehicle_mode'] as String?;
        } else {
          // Handle case where userId does not match (optional)
          print('User ID does not match the expected user for this trip.');
          return null;
        }
      } else {
        // Handle case where no document exists for the given tripId
        print('No trip document found with tripId: $tripId');
        return null;
      }
    } catch (e) {
      // Handle any errors (e.g., Firestore query failure)
      print('Error fetching vehicle mode: $e');
      return null;
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

  String _getSortField() => _selectedSortOption == 'Timestamp Newest First'
      ? 'timestamp'
      : 'timestamp';

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
      MaterialPageRoute(
          builder: (context) =>
              SortingPage(selectedSortOption: _selectedSortOption)),
    );

    if (selectedOption != null) {
      setState(() {
        _selectedSortOption = selectedOption;
        _tripDataList.sort((a, b) => _sortTrips(a, b));
      });
    }
  }

  // Other existing methods...
  // Future<void> _fetchTrips() async {
  //   if (_isLoading || !_hasMore) {
  //     return; // Check if already loading or no more trips
  //   }
  //   setState(() => _isLoading = true); // Set loading state to true
  //
  //   // Get the current time and the cutoff time (1 hour ago)
  //   DateTime now = DateTime.now();
  //   DateTime cutoffTime = now.subtract(Duration(hours: 1));
  //
  //   Query query = FirebaseFirestore.instance
  //       .collection('trips')
  //       .where('timestamp',
  //           isGreaterThan: Timestamp.fromDate(
  //               cutoffTime)) // Filter for trips within the last hour
  //       .orderBy(_getSortField(), descending: _getSortDescending())
  //       .limit(_itemsPerPage); // Limit results to items per page
  //
  //   if (_lastDocument != null) {
  //     query = query.startAfterDocument(
  //         _lastDocument!); // Start after last fetched document
  //   }
  //
  //   try {
  //     print('Fetching trips...'); // Debugging print
  //     final querySnapshot = await query.get();
  //     if (querySnapshot.docs.isEmpty) {
  //       setState(() => _hasMore = false); // No more trips to load
  //       await _loadButtonStates();
  //     } else {
  //       _lastDocument = querySnapshot.docs.last; // Update last document
  //
  //       // Step 1: Get driverEmail from widget
  //       String driverEmail = widget
  //           .driverEmail; // Assuming driverEmail is available in the widget
  //
  //       // Step 2: Fetch vehicleData for the specific driverEmail
  //       var vehicleQuerySnapshot = await FirebaseFirestore.instance
  //           .collection('vehicleData')
  //           .where('email',
  //               isEqualTo: driverEmail) // Match the driver email in vehicleData
  //           .get();
  //
  //       // Step 3: Create a map of vehicleData for the specific driverEmail
  //       Map<String, dynamic>? vehicleData;
  //       if (vehicleQuerySnapshot.docs.isNotEmpty) {
  //         vehicleData = vehicleQuerySnapshot.docs.first
  //             .data(); // Get vehicle data for this driver
  //         print(
  //             'Fetched vehicleData for driver: $vehicleData'); // Debugging print
  //       } else {
  //         print(
  //             'No vehicleData found for driverEmail: $driverEmail'); // Debugging print
  //       }
  //
  //       // Step 4: Filter trips based on vehicleType match
  //       var newTrips = querySnapshot.docs
  //           .map((doc) {
  //             var tripData = doc.data() as Map<String, dynamic>;
  //             String? vehicleTypeFromVehicleData =
  //                 vehicleData?['vehicleType'] as String?;
  //             String? vehicleTypeFromTrips = tripData['vehicleType'] as String?;
  //
  //             if (vehicleTypeFromVehicleData != null &&
  //                 vehicleTypeFromTrips != null) {
  //               // Only add the trip if the vehicle types match
  //               if (vehicleTypeFromVehicleData == vehicleTypeFromTrips) {
  //                 tripData['distance'] =
  //                     double.tryParse(tripData['distance'] as String? ?? '') ??
  //                         0.0;
  //                 tripData['fare'] =
  //                     double.tryParse(tripData['fare'] as String? ?? '') ?? 0.0;
  //                 tripData['tripId'] = doc.id; // Add trip ID
  //                 return TripModel.fromJson(tripData);
  //               }
  //             }
  //             return null; // Return null if the types don't match
  //           })
  //           .where((trip) => trip != null)
  //           .toList()
  //           .cast<TripModel>();
  //
  //       print('Fetched and filtered trips: $newTrips'); // Debugging print
  //
  //       // Add new trips to the list
  //       _tripDataList.addAll(newTrips);
  //
  //       // Initialize button states for newly added trips
  //       for (var trip in newTrips) {
  //         _isButtonDisabledList.add(false); // Set initial state as enabled
  //       }
  //
  //       // Load button states after new trips are fetched
  //       await _loadButtonStates();
  //
  //       // Sort the complete trip list
  //       _tripDataList.sort((a, b) => _sortTrips(a, b));
  //
  //       if (mounted) setState(() {}); // Update UI
  //     }
  //   } catch (e) {
  //     print('Error fetching trips: $e'); // Handle any errors
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false); // Set loading state to false
  //     }
  //   }
  // }

  Stream<List<TripModel>> _getTripsStream() {
    DateTime cutoffTime = DateTime.now().subtract(Duration(hours: 1));

    return FirebaseFirestore.instance
        .collection('trips')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .orderBy(_getSortField(), descending: _getSortDescending())
        .snapshots()
        .asyncMap((querySnapshot) async {
      // Get driver's vehicle data
      final vehicleQuerySnapshot = await FirebaseFirestore.instance
          .collection('vehicleData')
          .where('email', isEqualTo: widget.driverEmail)
          .get();

      final vehicleData = vehicleQuerySnapshot.docs.isNotEmpty
          ? vehicleQuerySnapshot.docs.first.data()
          : null;

      return querySnapshot.docs
          .map((doc) {
            final tripData = doc.data();

            if (vehicleData?['vehicleType'] == tripData['vehicleType']) {
              tripData['distance'] =
                  double.tryParse(tripData['distance'] as String? ?? '') ?? 0.0;
              tripData['fare'] =
                  double.tryParse(tripData['fare'] as String? ?? '') ?? 0.0;
              tripData['tripId'] = doc.id; // Add trip ID
              return TripModel.fromJson(tripData);
            }

            return null;
          })
          .where((trip) => trip != null)
          .toList()
          .cast<TripModel>();
    });
  }

  Future<void> _loadButtonStates() async {
    final driverId = widget.driverEmail;

    for (int i = 0; i < _tripDataList.length; i++) {
      final tripId = _tripDataList[i].tripId!;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('driverButtonStates')
          .doc(driverId)
          .collection('trips')
          .doc(tripId)
          .get();

      bool isDisabled = false;
      if (docSnapshot.exists) {
        isDisabled = docSnapshot.data()?['isButtonDisabled'] ?? false;
      }

      // Ensure the list is long enough
      if (i < _isButtonDisabledList.length) {
        _isButtonDisabledList[i] = isDisabled;
      } else {
        _isButtonDisabledList.add(isDisabled);
      }
    }

    if (mounted) {
      setState(() {}); // Update the UI after loading the states
    }
  }

  Future<double> fetchTotalFare(String driverId) async {
    double driverTotalBalance = 0.00;
    double driverTotalMoneyToPay = 0.00;
    double totalFare = 0.0;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Step 1: Query confirmedDrivers collection for matching driverId
    QuerySnapshot confirmedDriversSnapshot = await firestore
        .collection('confirmedDrivers')
        .where('driverId', isEqualTo: driverId)
        .get();

    // Step 2: Iterate through matched documents and get tripId
    for (var doc in confirmedDriversSnapshot.docs) {
      String tripId = doc['tripId'];

      // Step 3: Query trips collection using tripId and fetch fare
      DocumentSnapshot tripSnapshot =
          await firestore.collection('trips').doc(tripId).get();

      if (tripSnapshot.exists) {
        double fare = double.parse(tripSnapshot['fare']);
        totalFare += fare; // Step 4: Add fare to totalFare
      }
    }

    // Step 5: Calculate the total money to pay (3% of total fare)
    double totalMoneyToPay = 0.03 * totalFare;

    // Step 6: Update or create a document in the 'balance' collection
    await firestore.collection('balance').doc(driverId).set(
        {
          'driverTotalBalance': totalFare * 0.97, // 97% of total fare
          'driverTotalMoneyToPay': totalMoneyToPay,
        },
        SetOptions(
            merge: true)); // Merge to update existing fields or create new ones

    // Step 7: Update the state (if this is part of a Flutter widget)
    if (mounted) {
      setState(() {
        driverTotalBalance = totalFare;
        driverTotalMoneyToPay = totalMoneyToPay;
      });
    }

    // Step 8: Print the results (optional)
    print('Total Fare: $totalFare');
    print('Total Money to Pay: $totalMoneyToPay');

    return totalFare;
  }

  @override
  void initState() {
    super.initState();
    _loadButtonStates();
    fetchTotalFare(widget.driverEmail);

    // Initialize stream subscription
    _tripsSubscription = _getTripsStream().listen((trips) {
      if (mounted) {
        setState(() {
          _tripDataList = trips;
          _tripDataList.sort(_sortTrips);
          // Initialize button states
          _isButtonDisabledList = List.filled(trips.length, false);
        });
        _loadButtonStates(); // Load button states after new trips arrive
      }
    });
  }

  void _setButtonState(int index) async {
    final tripId = _tripDataList[index].tripId!;
    final driverId = widget.driverEmail;

    // Save the button state to Firestore
    await FirebaseFirestore.instance
        .collection('driverButtonStates')
        .doc(driverId)
        .collection('trips')
        .doc(tripId)
        .set({'isButtonDisabled': true});

    setState(() {
      _isButtonDisabledList[index] =
          true; // Update the local state for immediate UI feedback
    });
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'accepted_trips':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DriverAcceptedPage(driverId: widget.driverEmail),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Slide in from the right
              const end = Offset.zero;
              const curve = Curves.decelerate;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );

        break;
      case 'driver_filter':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DriverFilterPage(driverId: widget.driverEmail),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Slide in from the right
              const end = Offset.zero;
              const curve = Curves.decelerate;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );

        break;
      case 'successful_trips':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DriverSuccessfulTrips(driverId: widget.driverEmail),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Slide in from the right
              const end = Offset.zero;
              const curve = Curves.decelerate;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
        break;
      case 'view_messages':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DriverChatPage(driverId: widget.driverEmail),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Slide in from the right
              const end = Offset.zero;
              const curve = Curves.decelerate;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
        break;
      case 'passenger_mode':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignInPage(),
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  @override
  void dispose() {
    _tripsSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100.withOpacity(0.18),
      appBar: CustomAppBar(
        appBarColor: Colors.teal,
        appBarIcons: const [
          Icons.person_2,
          Icons.info_outline,
        ],
        title: 'Passenger Requests',
        driverId: widget.driverEmail,
      ),
      body: StreamBuilder<List<TripModel>>(
        stream: _getTripsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final trips = snapshot.data!;

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              if (index == _tripDataList.length) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 10,
                                width: 60,
                                color: Colors.grey,
                              ),
                              Container(
                                height: 10,
                                width: 40,
                                color: Colors.grey,
                              ),
                              Container(
                                height: 10,
                                width: 60,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Icon(Icons.electric_rickshaw),
                              Icon(Icons.numbers),
                              Icon(Icons.drive_eta_rounded),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.8,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.75,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.8,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Icon(Icons.send),
                              Icon(
                                Icons.phone,
                              ),
                              Icon(Icons.location_on),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final tripData = trips[index];
              final isButtonDisabled = index < _isButtonDisabledList.length
                  ? _isButtonDisabledList[index]
                  : false;

              // Use FutureBuilder to fetch passengerVehicleMode asynchronously
              return FutureBuilder<String?>(
                future: PassengerSelectedVehicleMode(
                  tripData.tripId.toString(), // Pass tripId
                  tripData.userId.toString(), // Pass userId
                  widget.driverEmail, // Pass driverId
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while waiting for the result
                    return Center(
                      child: SizedBox(), //CircularProgressIndicator
                    );
                  } else if (snapshot.hasError) {
                    // Handle errors
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    // Handle case where no data is returned
                    return SizedBox
                        .shrink(); // Hide the card if no vehicle mode is found
                  } else {
                    // Fetch the vehicle mode for the driver (since _vehicleModeMap is not available)
                    String? passengerVehicleMode = snapshot.data;

                    // Here you would ideally fetch vehicleMode directly from Firestore
                    // For illustration, let's assume vehicleMode fetching similar to passengerVehicleMode
                    Future<String?> fetchVehicleMode() async {
                      final vehicleDataSnapshot = await FirebaseFirestore
                          .instance
                          .collection('vehicleData')
                          .doc(widget.driverEmail)
                          .get();
                      print("$vehicleDataSnapshot.data()?['vehicleMode']");
                      return vehicleDataSnapshot.data()?['vehicleMode']
                          as String?;
                    }

                    // Use FutureBuilder to fetch vehicleMode asynchronously
                    return FutureBuilder<String?>(
                      future: fetchVehicleMode(),
                      builder: (context, vehicleModeSnapshot) {
                        if (vehicleModeSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Show a loading indicator while waiting for the result
                          return Center(
                            child: SizedBox(), //circularProgress Indicator
                          );
                        } else if (vehicleModeSnapshot.hasError) {
                          // Handle errors
                          return Center(
                            child: Text('Error: ${vehicleModeSnapshot.error}'),
                          );
                        } else if (!vehicleModeSnapshot.hasData ||
                            vehicleModeSnapshot.data == null) {
                          // Handle case where no vehicle mode data is returned
                          return SizedBox
                              .shrink(); // Hide the card if no vehicle mode is found
                        } else {
                          String? vehicleMode = vehicleModeSnapshot.data;

                          // Display the card only if the vehicle modes match
                          if (passengerVehicleMode == vehicleMode) {
                            return TripCardWidget(
                              driverId: widget.driverEmail, // Pass driverId
                              userId: tripData.userId.toString(), // Pass userId
                              tripId: tripData.tripId.toString(), // Pass tripId
                              tripData: tripData,
                              onPhoneTap: () {
                                if (tripData.phoneNumber != null &&
                                    tripData.phoneNumber!.isNotEmpty) {
                                  _launchPhoneNumber(tripData.phoneNumber!);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Phone number not available')),
                                  );
                                }
                              },
                              onMapTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DriverViewPassengerLocation(
                                    tripId: tripData.tripId!, // Pass tripId
                                  ),
                                ),
                              ),
                              onRequestTap: () {
                                _setButtonState(
                                    index); // Call to disable the button
                                showTripAndUserIdInSnackBar(
                                    tripData, context, index);
                              },
                              index: index,
                              isButtonDisabled: isButtonDisabled,
                            );
                          } else {
                            // Return an empty container if the vehicle modes don't match
                            return SizedBox.shrink();
                          }
                        }
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> showTripAndUserIdInSnackBar(
      TripModel tripData, BuildContext context, int index) async {
    final tripId = tripData.tripId ?? 'No Trip ID';
    final userId = tripData.userId ?? 'No User ID';
    final driverId = widget.driverEmail;

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

    try {
      // Step 1: Add the userId, driverId, and tripId to the new "requestsofDrivers" collection
      bool requestExists =
          await _checkRequestExists(tripId, userId, widget.driverEmail);

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
          'driverId': driverId,
          'requestTimestamp':
              FieldValue.serverTimestamp(), // Optional: Add a timestamp
        });

        // Step 2: Darken the button and show a SnackBar
        _setButtonState(index); // Call to disable the button after confirmation

        // Show a SnackBar with tripId, userId, and driverId
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
                  'Request Sent Successfully',
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
    } catch (e) {
      // Handle error (e.g., if something goes wrong during the Firebase write)
    }
  }
}
