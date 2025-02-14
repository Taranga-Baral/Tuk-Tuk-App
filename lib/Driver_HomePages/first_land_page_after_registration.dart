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
import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
import 'package:final_menu/galli_maps/driver_view_passenger_location/driver_view_passenger_location.dart';
import 'package:final_menu/homepage.dart';
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final List<bool> _isButtonDisabledList =
      []; // List to hold button states for each trip

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
  Future<void> _fetchTrips() async {
    if (_isLoading || !_hasMore) {
      return; // Check if already loading or no more trips
    }
    setState(() => _isLoading = true); // Set loading state to true

    // Get the current time and the cutoff time (1 hour ago)
    DateTime now = DateTime.now();
    DateTime cutoffTime = now.subtract(Duration(hours: 1));

    Query query = FirebaseFirestore.instance
        .collection('trips')
        .where('timestamp',
            isGreaterThan: Timestamp.fromDate(
                cutoffTime)) // Filter for trips within the last hour
        .orderBy(_getSortField(), descending: _getSortDescending())
        .limit(_itemsPerPage); // Limit results to items per page

    if (_lastDocument != null) {
      query = query.startAfterDocument(
          _lastDocument!); // Start after last fetched document
    }

    try {
      print('Fetching trips...'); // Debugging print
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        setState(() => _hasMore = false); // No more trips to load
        await _loadButtonStates();
      } else {
        _lastDocument = querySnapshot.docs.last; // Update last document

        // Step 1: Get driverEmail from widget
        String driverEmail = widget
            .driverEmail; // Assuming driverEmail is available in the widget

        // Step 2: Fetch vehicleData for the specific driverEmail
        var vehicleQuerySnapshot = await FirebaseFirestore.instance
            .collection('vehicleData')
            .where('email',
                isEqualTo: driverEmail) // Match the driver email in vehicleData
            .get();

        // Step 3: Create a map of vehicleData for the specific driverEmail
        Map<String, dynamic>? vehicleData;
        if (vehicleQuerySnapshot.docs.isNotEmpty) {
          vehicleData = vehicleQuerySnapshot.docs.first
              .data(); // Get vehicle data for this driver
          print(
              'Fetched vehicleData for driver: $vehicleData'); // Debugging print
        } else {
          print(
              'No vehicleData found for driverEmail: $driverEmail'); // Debugging print
        }

        // Step 4: Filter trips based on vehicleType match
        var newTrips = querySnapshot.docs
            .map((doc) {
              var tripData = doc.data() as Map<String, dynamic>;
              String? vehicleTypeFromVehicleData =
                  vehicleData?['vehicleType'] as String?;
              String? vehicleTypeFromTrips = tripData['vehicleType'] as String?;

              if (vehicleTypeFromVehicleData != null &&
                  vehicleTypeFromTrips != null) {
                // Only add the trip if the vehicle types match
                if (vehicleTypeFromVehicleData == vehicleTypeFromTrips) {
                  tripData['distance'] =
                      double.tryParse(tripData['distance'] as String? ?? '') ??
                          0.0;
                  tripData['fare'] =
                      double.tryParse(tripData['fare'] as String? ?? '') ?? 0.0;
                  tripData['tripId'] = doc.id; // Add trip ID
                  return TripModel.fromJson(tripData);
                }
              }
              return null; // Return null if the types don't match
            })
            .where((trip) => trip != null)
            .toList()
            .cast<TripModel>();

        print('Fetched and filtered trips: $newTrips'); // Debugging print

        // Add new trips to the list
        _tripDataList.addAll(newTrips);

        // Initialize button states for newly added trips
        for (var trip in newTrips) {
          _isButtonDisabledList.add(false); // Set initial state as enabled
        }

        // Load button states after new trips are fetched
        await _loadButtonStates();

        // Sort the complete trip list
        _tripDataList.sort((a, b) => _sortTrips(a, b));

        if (mounted) setState(() {}); // Update UI
      }
    } catch (e) {
      print('Error fetching trips: $e'); // Handle any errors
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Set loading state to false
      }
    }
  }

//   Future<void> _fetchTrips() async {
//   if (_isLoading || !_hasMore) return; // Check if already loading or no more trips
//   setState(() => _isLoading = true); // Set loading state to true

//   Query query = FirebaseFirestore.instance
//       .collection('trips')
//       .orderBy(_getSortField(), descending: _getSortDescending())
//       .limit(_itemsPerPage); // Limit results to items per page

//   if (_lastDocument != null) {
//     query = query.startAfterDocument(_lastDocument!); // Start after last fetched document
//   }

//   try {
//     final querySnapshot = await query.get();
//     if (querySnapshot.docs.isEmpty) {
//       setState(() => _hasMore = false); // No more trips to load
//       await _loadButtonStates();
//     } else {
//       _lastDocument = querySnapshot.docs.last; // Update last document
//       var newTrips = <TripModel>[];

//       for (var doc in querySnapshot.docs) {
//         var tripData = doc.data() as Map<String, dynamic>;

//         // Ensure driverId exists and is not null
//         String? driverId = tripData['driverId'] as String?;
//         if (driverId == null || driverId.isEmpty) {
//           print('Skipping trip: driverId is null or empty');
//           continue; // Skip this trip if driverId is missing
//         }

//         // Fetch the vehicleData based on the driverId
//         var vehicleSnapshot = await FirebaseFirestore.instance
//             .collection('vehicleData')
//             .doc(driverId)
//             .get();

//         if (vehicleSnapshot.exists) {
//           var vehicleData = vehicleSnapshot.data() as Map<String, dynamic>;

//           // Ensure vehicleType exists in both collections
//           String? vehicleTypeFromVehicleData = vehicleData['vehicleType'] as String?;
//           String? vehicleTypeFromTrips = tripData['vehicleType'] as String?;

//           if (vehicleTypeFromVehicleData == null || vehicleTypeFromTrips == null) {
//             print('Skipping trip: vehicleType is missing in either collection');
//             continue; // Skip this trip if vehicleType is missing
//           }

//           // Only add the trip if the vehicle types match
//           if (vehicleTypeFromVehicleData == vehicleTypeFromTrips) {
//             tripData['distance'] =
//                 double.tryParse(tripData['distance'] as String? ?? '') ?? 0.0;
//             tripData['fare'] =
//                 double.tryParse(tripData['fare'] as String? ?? '') ?? 0.0;
//             tripData['tripId'] = doc.id; // Add trip ID

//             newTrips.add(TripModel.fromJson(tripData));
//           }
//         }
//       }

//       // Add new trips to the list
//       _tripDataList.addAll(newTrips);

//       // Initialize button states for newly added trips
//       for (var trip in newTrips) {
//         _isButtonDisabledList.add(false); // Set initial state as enabled
//       }

//       // Load button states after new trips are fetched
//       await _loadButtonStates();

//       // Sort the complete trip list
//       _tripDataList.sort((a, b) => _sortTrips(a, b));

//       if (mounted) setState(() {}); // Update UI
//     }
//   } catch (e) {
//     print('Error fetching trips: $e'); // Handle any errors
//   } finally {
//     if (mounted) setState(() => _isLoading = false); // Set loading state to false
//   }
// }

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

    setState(() {}); // Update the UI after loading the states
  }

  @override
  void initState() {
    super.initState();
    _loadButtonStates(); // Load button states
    _fetchTrips();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchTrips();
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
            builder: (context) => HomePage1(), // Replace with your SignInPage
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
        centerTitle: true,
        title: Center(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vehicleData')
                .doc(widget.driverEmail)
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 2),
          child: Image(image: AssetImage('assets/fordriverlogo.png')),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.login_outlined),
                onSelected: _onMenuItemSelected,
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                        value: 'passenger_mode',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Passenger Mode'),
                            Icon(Icons.person_outline_sharp)
                          ],
                        )),
                  ];
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading && _tripDataList.isEmpty
          ? Center(
              child: Image(
                image: AssetImage('assets/no_data_found.gif'),
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _tripDataList.length +
                  (_hasMore
                      ? 1
                      : 0), // Loading indicator if more trips are available
              itemBuilder: (context, index) {
                if (index == _tripDataList.length) {
                  return Center(
                      child: SizedBox()); // Loading indicator at the end
                }
                final tripData = _tripDataList[index];
                // Check the index against the length of _isButtonDisabledList
                final isButtonDisabled = index < _isButtonDisabledList.length
                    ? _isButtonDisabledList[index]
                    : false; // Default to false if index is out of bounds

                return TripCardWidget(
                  driverId: widget.driverEmail,
                  userId: tripData.userId.toString(),
                  tripId: tripData.tripId.toString(),
                  tripData: _tripDataList[index],
                  onPhoneTap: () {
                    if (tripData.phoneNumber != null &&
                        tripData.phoneNumber!.isNotEmpty) {
                      _launchPhoneNumber(tripData.phoneNumber!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Phone number not available')),
                      );
                    }
                  },
                  onMapTap: () =>
                      // _launchOpenStreetMapWithDirections(tripData.tripId!),
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverViewPassengerLocation(
                                    tripId: tripData.tripId!,
                                  ))),
                  onRequestTap: () {
                    _setButtonState(index); // Call to disable the button
                    showTripAndUserIdInSnackBar(
                        _tripDataList[index], context, index);
                  },
                  index: index,
                  isButtonDisabled:
                      isButtonDisabled, // Use the checked value here
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
