// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/chat/chat_display_page.dart';
// import 'package:flutter/material.dart';
// import 'package:animations/animations.dart'; // Import the animations package

// class ChatPage extends StatefulWidget {
//   final String userId;

//   const ChatPage({super.key, required this.userId});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   List<Map<String, dynamic>> confirmedDriversData = [];
//   DocumentSnapshot? lastDocument; // For pagination
//   bool isLoadingMore = false; // To track loading state

//   @override
//   void initState() {
//     super.initState();
//     fetchConfirmedDriversData();
//   }

//   Future<void> fetchConfirmedDriversData({bool isLoadMore = false}) async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;

//     Query query = firestore
//         .collection('confirmedDrivers')
//         .where('userId', isEqualTo: widget.userId)
//         .orderBy('confirmedAt', descending: true)
//         .limit(isLoadMore ? 10 : 10); // Load 10 cards at a time

//     if (isLoadMore && lastDocument != null) {
//       query = query.startAfterDocument(lastDocument!);
//     }

//     QuerySnapshot confirmedDriversSnapshot = await query.get();

//     if (confirmedDriversSnapshot.docs.isNotEmpty) {
//       List<Map<String, dynamic>> fetchedData = [];

//       for (var doc in confirmedDriversSnapshot.docs) {
//         var confirmedDriverData = doc.data() as Map<String, dynamic>;

//         // Fetch details from trips using tripId
//         DocumentSnapshot tripSnapshot = await firestore
//             .collection('trips')
//             .doc(confirmedDriverData['tripId'])
//             .get();
//         var tripData = tripSnapshot.data() as Map<String, dynamic>;

//         // Fetch details from vehicleData using driverId
//         DocumentSnapshot driverSnapshot = await firestore
//             .collection('vehicleData')
//             .doc(confirmedDriverData['driverId'])
//             .get();
//         var driverData = driverSnapshot.data() as Map<String, dynamic>;

//         // Combine the data from both collections and include profile picture
//         fetchedData.add({
//           'id': doc.id,
//           'pickupLocation': tripData['pickupLocation'],
//           'deliveryLocation': tripData['deliveryLocation'],
//           'distance': tripData['distance'],
//           'fare': tripData['fare'],
//           'driverName': driverData['name'],
//           'driverPhone': driverData['phone'],
//           'profilePictureUrl': driverData['profilePictureUrl'] ?? '',
//           'driverId': confirmedDriverData['driverId'],
//           'tripId': confirmedDriverData['tripId'],
//           'no_of_person': tripData['no_of_person'],
//           'vehicle_mode': tripData['vehicle_mode'],
//           'timestamp': confirmedDriverData['timestamp'], // Ensure this field exists
//         });
//       }

//       setState(() {
//         if (isLoadMore) {
//           confirmedDriversData.addAll(fetchedData);
//         } else {
//           confirmedDriversData = fetchedData;
//         }
//         lastDocument = confirmedDriversSnapshot.docs.last; // Update the last document
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with Drivers'),
//         backgroundColor: Colors.greenAccent.shade200.withOpacity(0.9),
//       ),
//       body: confirmedDriversData.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: confirmedDriversData.length,
//                       itemBuilder: (context, index) {
//                         var data = confirmedDriversData[index];
//                         String driverId = data['driverId'];
//                         String tripId = data['tripId'];
//                         String profilePictureUrl = data['profilePictureUrl'];

// return Column(
//   children: [
//     Card(
//       elevation: 1,

//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Container(
//         // decoration: BoxDecoration(
//         //   gradient: LinearGradient(
//         //     colors: [Colors.white, Colors.grey[200]!],
//         //     begin: Alignment.topLeft,
//         //     end: Alignment.bottomRight,
//         //   ),
//         //   borderRadius: BorderRadius.circular(15),
//         // ),
//         child: ListTile(
//           contentPadding: EdgeInsets.all(16),
//           leading: CircleAvatar(
//             radius: 20,
//             backgroundImage: profilePictureUrl.isNotEmpty
//                 ? NetworkImage(profilePictureUrl)
//                 : AssetImage('assets/loading_screen.gif') as ImageProvider,
//           ),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('${data['driverName']}', style: TextStyle(fontWeight: FontWeight.bold)),

//                    Text('... ${index+1}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
//                 ],
//               ),
//               SizedBox(height: 8),
//             ],
//           ),
//           subtitle: Column(
//             children: [
//               Text(
//                 'उठाउने स्थान : ${data['pickupLocation']}\n\n'
//                 'डेलिभरी स्थान : ${data['deliveryLocation']}\n\n'
//                 'सम्पर्क : ${data['driverPhone']}',
//                 textAlign: TextAlign.left,
//                 style: TextStyle(color: Colors.grey[600],),
//               ),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   IconButton(
//             icon: Icon(Icons.chat, color: Colors.green),
//             onPressed: () {
//               // Navigate to ChatDetailPage with animation
//               Navigator.of(context).push(
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) {
//                     return FadeScaleTransition(
//                       animation: animation,
//                       child: ChatDetailPage(
//                         userId: widget.userId,
//                         driverId: driverId,
//                         tripId: tripId,
//                         driverName: data['driverName'],
//                         pickupLocation: data['pickupLocation'],
//                         deliveryLocation: data['deliveryLocation'],
//                         distance: data['distance'],
//                         no_of_person: data['no_of_person'],
//                         vehicle_mode: data['vehicle_mode'],
//                         fare: data['fare'],
//                       ),
//                     );
//                   },
//                   transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                     const begin = Offset(1.0, 0.0);
//                     const end = Offset.zero;
//                     const curve = Curves.easeInOut;

//                     var tween = Tween(begin: begin, end: end);
//                     var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));

//                     return SlideTransition(position: offsetAnimation, child: child);
//                   },
//                 ),
//               );
//             },
//           ),

//                 ],
//               ),
//                                     ],
//                                   ),

//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                   if (isLoadingMore) CircularProgressIndicator(), // Show loading indicator
//                   ElevatedButton(
//                     onPressed: () {
//                       if (!isLoadingMore) {
//                         setState(() {
//                           isLoadingMore = true;
//                         });
//                         fetchConfirmedDriversData(isLoadMore: true).then((_) {
//                           setState(() {
//                             isLoadingMore = false; // Reset loading state
//                           });
//                         });
//                       }
//                     },
//                     child: Text('Load More'),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/chat/chat_display_page.dart';
// import 'package:flutter/material.dart';
// import 'package:animations/animations.dart';
// import 'package:google_fonts/google_fonts.dart'; // Import the animations package

// class ChatPage extends StatefulWidget {
//   final String userId;

//   const ChatPage({super.key, required this.userId});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   List<Map<String, dynamic>> confirmedDriversData = [];
//   DocumentSnapshot? lastDocument; // For pagination
//   bool isLoadingMore = false; // To track loading state

//   @override
//   void initState() {
//     super.initState();
//     fetchConfirmedDriversData();
//   }

//   Future<void> fetchConfirmedDriversData({bool isLoadMore = false}) async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;

//     // Calculate time 1 hour ago
//     DateTime oneHourAgo = DateTime.now().subtract(Duration(hours: 1));

//     Query query = firestore
//         .collection('confirmedDrivers')
//         .where('userId', isEqualTo: widget.userId)
//         .orderBy('confirmedAt', descending: true)
//         .limit(isLoadMore ? 10 : 10); // Load 10 cards at a time

//     if (isLoadMore && lastDocument != null) {
//       query = query.startAfterDocument(lastDocument!);
//     }

//     QuerySnapshot confirmedDriversSnapshot = await query.get();

//     if (confirmedDriversSnapshot.docs.isNotEmpty) {
//       List<Map<String, dynamic>> fetchedData = [];

//       for (var doc in confirmedDriversSnapshot.docs) {
//         var confirmedDriverData = doc.data() as Map<String, dynamic>;

//         // Check if this trip is in successfulTrips collection
//         bool isTripSuccessful = await _checkIfTripIsSuccessful(
//           confirmedDriverData['tripId'],
//           confirmedDriverData['userId'],
//         );

//         if (!isTripSuccessful) {
//           // Fetch details from trips using tripId
//           DocumentSnapshot tripSnapshot = await firestore
//               .collection('trips')
//               .doc(confirmedDriverData['tripId'])
//               .get();

//           // Check if the trip exists and is within the last hour
//           if (tripSnapshot.exists) {
//             var tripData = tripSnapshot.data() as Map<String, dynamic>;
//             var tripTimestamp = (tripData['timestamp'] as Timestamp).toDate();

//             // Compare tripTimestamp with oneHourAgo
//             if (tripTimestamp.isAfter(oneHourAgo)) {
//               // Trip is within the last hour, include it in fetchedData
//               // Fetch details from vehicleData using driverId
//               DocumentSnapshot driverSnapshot = await firestore
//                   .collection('vehicleData')
//                   .doc(confirmedDriverData['driverId'])
//                   .get();
//               var driverData = driverSnapshot.data() as Map<String, dynamic>;

//               // Combine the data from both collections and include profile picture
//               fetchedData.add({
//                 'id': doc.id,
//                 'pickupLocation': tripData['pickupLocation'],
//                 'deliveryLocation': tripData['deliveryLocation'],
//                 'distance': tripData['distance'],
//                 'fare': tripData['fare'],
//                 'driverName': driverData['name'],
//                 'driverPhone': driverData['phone'],
//                 'profilePictureUrl': driverData['profilePictureUrl'] ?? '',
//                 'driverId': confirmedDriverData['driverId'],
//                 'tripId': confirmedDriverData['tripId'],
//                 'no_of_person': tripData['no_of_person'],
//                 'vehicle_mode': tripData['vehicle_mode'],
//                 'timestamp': confirmedDriverData[
//                     'timestamp'], // Ensure this field exists
//               });
//             } else {
//               // Trip is older than 1 hour, skip processing
//               print(
//                   'Skipping trip ${confirmedDriverData['tripId']} as it is older than 1 hour.');
//             }
//           } else {
//             print(
//                 'Trip ${confirmedDriverData['tripId']} does not exist or has no data.');
//           }
//         } else {
//           print(
//               'Trip ${confirmedDriverData['tripId']} is marked as successful in the database. Skipping.');
//         }
//       }

//       setState(() {
//         if (isLoadMore) {
//           confirmedDriversData.addAll(fetchedData);
//         } else {
//           confirmedDriversData = fetchedData;
//         }
//         lastDocument =
//             confirmedDriversSnapshot.docs.last; // Update the last document
//       });
//     }
//   }

// // Function to check if a trip is marked as successful in successfulTrips collection
//   Future<bool> _checkIfTripIsSuccessful(String tripId, String userId) async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;

//     try {
//       QuerySnapshot querySnapshot = await firestore
//           .collection('successfulTrips')
//           .where('tripId', isEqualTo: tripId)
//           .where('userId', isEqualTo: userId)
//           .limit(1)
//           .get();

//       return querySnapshot
//           .docs.isNotEmpty; // Return true if trip is marked as successful
//     } catch (e) {
//       print('Error checking successful trip: $e');
//       return false; // Assume trip is not marked as successful on error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Chat with Drivers',
//           style: GoogleFonts.outfit(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         // backgroundColor: Colors.greenAccent.shade200.withOpacity(0.9),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: confirmedDriversData.isEmpty
//           ? Center(
//               child: Image(
//               image: AssetImage('assets/no_data_found.gif'),
//               height: MediaQuery.of(context).size.height * 0.5,
//               width: MediaQuery.of(context).size.width * 0.5,
//             ))
//           : Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: confirmedDriversData.length,
//                       itemBuilder: (context, index) {
//                         var data = confirmedDriversData[index];
//                         String driverId = data['driverId'];
//                         String tripId = data['tripId'];
//                         String profilePictureUrl = data['profilePictureUrl'];

//                         // Case: Data available
//                         return Column(
//                           children: [
//                             Card(
//                               elevation: 1,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Container(
//                                 child: ListTile(
//                                   contentPadding: EdgeInsets.all(16),
//                                   leading: CircleAvatar(
//                                     radius: 20,
//                                     backgroundImage:
//                                         profilePictureUrl.isNotEmpty
//                                             ? NetworkImage(profilePictureUrl)
//                                             : AssetImage('assets/logo.png')
//                                                 as ImageProvider,
//                                   ),
//                                   title: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               '${data['driverName']}',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                           Text(
//                                             '... ${index + 1}',
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: 8),
//                                     ],
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Pickup Location: ${data['pickupLocation']}\n\n'
//                                         'Delivery Location: ${data['deliveryLocation']}\n\n'
//                                         'Contact: ${data['driverPhone']}',
//                                         style:
//                                             TextStyle(color: Colors.grey[600]),
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           IconButton(
//                                             icon: Icon(Icons.chat,
//                                                 color: Colors.green),
//                                             onPressed: () {
//                                               // Navigate to ChatDetailPage with animation
//                                               Navigator.of(context).push(
//                                                 PageRouteBuilder(
//                                                   pageBuilder: (context,
//                                                       animation,
//                                                       secondaryAnimation) {
//                                                     return FadeScaleTransition(
//                                                       animation: animation,
//                                                       child: ChatDetailPage(
//                                                         userId: widget.userId,
//                                                         driverId: driverId,
//                                                         tripId: tripId,
//                                                         driverName:
//                                                             data['driverName'],
//                                                         pickupLocation: data[
//                                                             'pickupLocation'],
//                                                         deliveryLocation: data[
//                                                             'deliveryLocation'],
//                                                         distance:
//                                                             data['distance'],
//                                                         no_of_person: data[
//                                                             'no_of_person'],
//                                                         vehicle_mode: data[
//                                                             'vehicle_mode'],
//                                                         fare: data['fare'],
//                                                       ),
//                                                     );
//                                                   },
//                                                   transitionsBuilder: (context,
//                                                       animation,
//                                                       secondaryAnimation,
//                                                       child) {
//                                                     const begin =
//                                                         Offset(1.0, 0.0);
//                                                     const end = Offset.zero;
//                                                     const curve =
//                                                         Curves.easeInOut;

//                                                     var tween = Tween(
//                                                         begin: begin, end: end);
//                                                     var offsetAnimation =
//                                                         animation.drive(tween
//                                                             .chain(CurveTween(
//                                                                 curve: curve)));

//                                                     return SlideTransition(
//                                                       position: offsetAnimation,
//                                                       child: child,
//                                                     );
//                                                   },
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                   if (isLoadingMore)
//                     CircularProgressIndicator(), // Show loading indicator
//                   ElevatedButton(
//                     onPressed: () {
//                       if (!isLoadingMore) {
//                         setState(() {
//                           isLoadingMore = true;
//                         });
//                         fetchConfirmedDriversData(isLoadMore: true).then((_) {
//                           setState(() {
//                             isLoadingMore = false; // Reset loading state
//                           });
//                         });
//                       }
//                     },
//                     child: Text('Load More'),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/chat/chat_display_page.dart';
// import 'package:flutter/material.dart';
// import 'package:animations/animations.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ChatPage extends StatefulWidget {
//   final String userId;

//   const ChatPage({super.key, required this.userId});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   List<Map<String, dynamic>> confirmedDriversData = [];
//   DocumentSnapshot? lastDocument;
//   bool isLoadingMore = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchConfirmedDriversData();
//   }

//   Future<void> fetchConfirmedDriversData({bool isLoadMore = false}) async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     DateTime oneHourAgo = DateTime.now().subtract(Duration(hours: 1));

//     Query query = firestore
//         .collection('confirmedDrivers')
//         .where('userId', isEqualTo: widget.userId)
//         .orderBy('confirmedAt', descending: true)
//         .limit(isLoadMore ? 10 : 10);

//     if (isLoadMore && lastDocument != null) {
//       query = query.startAfterDocument(lastDocument!);
//     }

//     QuerySnapshot confirmedDriversSnapshot = await query.get();

//     if (confirmedDriversSnapshot.docs.isNotEmpty) {
//       List<Map<String, dynamic>> fetchedData = [];

//       for (var doc in confirmedDriversSnapshot.docs) {
//         var confirmedDriverData = doc.data() as Map<String, dynamic>;

//         bool isTripSuccessful = await _checkIfTripIsSuccessful(
//           confirmedDriverData['tripId'],
//           confirmedDriverData['userId'],
//         );

//         if (!isTripSuccessful) {
//           DocumentSnapshot tripSnapshot = await firestore
//               .collection('trips')
//               .doc(confirmedDriverData['tripId'])
//               .get();

//           if (tripSnapshot.exists) {
//             var tripData = tripSnapshot.data() as Map<String, dynamic>;
//             var tripTimestamp = (tripData['timestamp'] as Timestamp).toDate();

//             if (tripTimestamp.isAfter(oneHourAgo)) {
//               DocumentSnapshot driverSnapshot = await firestore
//                   .collection('vehicleData')
//                   .doc(confirmedDriverData['driverId'])
//                   .get();
//               var driverData = driverSnapshot.data() as Map<String, dynamic>;

//               fetchedData.add({
//                 'id': doc.id,
//                 'pickupLocation': tripData['pickupLocation'],
//                 'deliveryLocation': tripData['deliveryLocation'],
//                 'distance': tripData['distance'],
//                 'fare': tripData['fare'],
//                 'driverName': driverData['name'],
//                 'driverPhone': driverData['phone'],
//                 'profilePictureUrl': driverData['profilePictureUrl'] ?? '',
//                 'driverId': confirmedDriverData['driverId'],
//                 'tripId': confirmedDriverData['tripId'],
//                 'no_of_person': tripData['no_of_person'],
//                 'vehicle_mode': tripData['vehicle_mode'],
//                 'timestamp': confirmedDriverData['timestamp'],
//               });
//             }
//           }
//         }
//       }

//       setState(() {
//         if (isLoadMore) {
//           confirmedDriversData.addAll(fetchedData);
//         } else {
//           confirmedDriversData = fetchedData;
//         }
//         lastDocument = confirmedDriversSnapshot.docs.last;
//       });
//     }
//   }

//   Future<bool> _checkIfTripIsSuccessful(String tripId, String userId) async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;

//     try {
//       QuerySnapshot querySnapshot = await firestore
//           .collection('successfulTrips')
//           .where('tripId', isEqualTo: tripId)
//           .where('userId', isEqualTo: userId)
//           .limit(1)
//           .get();

//       return querySnapshot.docs.isNotEmpty;
//     } catch (e) {
//       print('Error checking successful trip: $e');
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Chat with Drivers',
//           style: GoogleFonts.outfit(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: confirmedDriversData.isEmpty
//           ? Center(
//               child: Image(
//                 image: AssetImage('assets/no_data_found.gif'),
//                 height: MediaQuery.of(context).size.height * 0.5,
//                 width: MediaQuery.of(context).size.width * 0.5,
//               ),
//             )
//           : Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: confirmedDriversData.length,
//                       itemBuilder: (context, index) {
//                         var data = confirmedDriversData[index];
//                         String driverId = data['driverId'];
//                         String tripId = data['tripId'];
//                         String profilePictureUrl = data['profilePictureUrl'];

//                         return Card(
//                           elevation: 4,
//                           margin: EdgeInsets.symmetric(vertical: 6),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Serial Number
//                                 Container(
//                                   width: 30,
//                                   alignment: Alignment.center,
//                                   child: Text(
//                                     '${index + 1}',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.blueAccent,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 // Profile Picture
//                                 CircleAvatar(
//                                   radius: 20,
//                                   backgroundImage: profilePictureUrl.isNotEmpty
//                                       ? NetworkImage(profilePictureUrl)
//                                       : AssetImage('assets/logo.png')
//                                           as ImageProvider,
//                                 ),
//                                 SizedBox(width: 12),
//                                 // Driver Details
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       // Driver Name
//                                       Text(
//                                         data['driverName'],
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       SizedBox(height: 8),
//                                       // Pickup Location
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.location_on,
//                                             color: Colors.red,
//                                             size: 16,
//                                           ),
//                                           SizedBox(width: 4),
//                                           Expanded(
//                                             child: Text(
//                                               'Pickup: ${data['pickupLocation']}',
//                                               style: TextStyle(fontSize: 14),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: 4),
//                                       // Delivery Location
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.location_on,
//                                             color: Colors.green,
//                                             size: 16,
//                                           ),
//                                           SizedBox(width: 4),
//                                           Expanded(
//                                             child: Text(
//                                               'Delivery: ${data['deliveryLocation']}',
//                                               style: TextStyle(fontSize: 14),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: 4),
//                                       // Contact Number
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.phone,
//                                             color: Colors.blue,
//                                             size: 16,
//                                           ),
//                                           SizedBox(width: 4),
//                                           Text(
//                                             'Contact: ${data['driverPhone']}',
//                                             style: TextStyle(fontSize: 14),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // Chat Icon
//                                 IconButton(
//                                   icon: Icon(Icons.chat, color: Colors.green),
//                                   onPressed: () {
//                                     Navigator.of(context).push(
//                                       PageRouteBuilder(
//                                         pageBuilder: (context, animation,
//                                             secondaryAnimation) {
//                                           return FadeScaleTransition(
//                                             animation: animation,
//                                             child: ChatDetailPage(
//                                               userId: widget.userId,
//                                               driverId: driverId,
//                                               tripId: tripId,
//                                               driverName: data['driverName'],
//                                               pickupLocation:
//                                                   data['pickupLocation'],
//                                               deliveryLocation:
//                                                   data['deliveryLocation'],
//                                               distance: data['distance'],
//                                               no_of_person:
//                                                   data['no_of_person'],
//                                               vehicle_mode:
//                                                   data['vehicle_mode'],
//                                               fare: data['fare'],
//                                             ),
//                                           );
//                                         },
//                                         transitionsBuilder: (context, animation,
//                                             secondaryAnimation, child) {
//                                           const begin = Offset(1.0, 0.0);
//                                           const end = Offset.zero;
//                                           const curve = Curves.easeInOut;

//                                           var tween =
//                                               Tween(begin: begin, end: end);
//                                           var offsetAnimation = animation.drive(
//                                               tween.chain(
//                                                   CurveTween(curve: curve)));

//                                           return SlideTransition(
//                                             position: offsetAnimation,
//                                             child: child,
//                                           );
//                                         },
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   if (isLoadingMore)
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: CircularProgressIndicator(),
//                     ),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (!isLoadingMore) {
//                         setState(() {
//                           isLoadingMore = true;
//                         });
//                         fetchConfirmedDriversData(isLoadMore: true).then((_) {
//                           setState(() {
//                             isLoadingMore = false;
//                           });
//                         });
//                       }
//                     },
//                     child: Text('Load More'),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/chat/chat_display_page.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  final String userId;

  const ChatPage({super.key, required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> confirmedDriversData = [];
  DocumentSnapshot? lastDocument;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    fetchConfirmedDriversData();
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  Future<void> fetchConfirmedDriversData({bool isLoadMore = false}) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime oneHourAgo = DateTime.now().subtract(Duration(hours: 1));

    Query query = firestore
        .collection('confirmedDrivers')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('confirmedAt', descending: true)
        .limit(isLoadMore ? 10 : 10);

    if (isLoadMore && lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot confirmedDriversSnapshot = await query.get();

    if (confirmedDriversSnapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in confirmedDriversSnapshot.docs) {
        var confirmedDriverData = doc.data() as Map<String, dynamic>;

        bool isTripSuccessful = await _checkIfTripIsSuccessful(
          confirmedDriverData['tripId'],
          confirmedDriverData['userId'],
        );

        if (!isTripSuccessful) {
          DocumentSnapshot tripSnapshot = await firestore
              .collection('trips')
              .doc(confirmedDriverData['tripId'])
              .get();

          if (tripSnapshot.exists) {
            var tripData = tripSnapshot.data() as Map<String, dynamic>;
            var tripTimestamp = (tripData['timestamp'] as Timestamp).toDate();

            if (tripTimestamp.isAfter(oneHourAgo)) {
              DocumentSnapshot driverSnapshot = await firestore
                  .collection('vehicleData')
                  .doc(confirmedDriverData['driverId'])
                  .get();
              var driverData = driverSnapshot.data() as Map<String, dynamic>;

              fetchedData.add({
                'id': doc.id,
                'pickupLocation': tripData['pickupLocation'],
                'deliveryLocation': tripData['deliveryLocation'],
                'distance': tripData['distance'],
                'fare': tripData['fare'],
                'driverName': driverData['name'],
                'driverPhone': driverData['phone'],
                'profilePictureUrl': driverData['profilePictureUrl'] ?? '',
                'driverId': confirmedDriverData['driverId'],
                'tripId': confirmedDriverData['tripId'],
                'no_of_person': tripData['no_of_person'],
                'vehicle_mode': tripData['vehicle_mode'],
                'timestamp': confirmedDriverData['timestamp'],
              });
            }
          }
        }
      }

      setState(() {
        if (isLoadMore) {
          confirmedDriversData.addAll(fetchedData);
        } else {
          confirmedDriversData = fetchedData;
        }
        lastDocument = confirmedDriversSnapshot.docs.last;
      });
    }
  }

  Future<bool> _checkIfTripIsSuccessful(String tripId, String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('successfulTrips')
          .where('tripId', isEqualTo: tripId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking successful trip: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chat with Drivers',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: confirmedDriversData.isEmpty
          ? Center(
              child: Image(
                image: AssetImage('assets/no_data_found.gif'),
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: confirmedDriversData.length,
                        itemBuilder: (context, index) {
                          var data = confirmedDriversData[index];
                          return DriverCard(
                            data: data,
                            index: index,
                            onChatPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return FadeScaleTransition(
                                      animation: animation,
                                      child: ChatDetailPage(
                                        userId: widget.userId,
                                        driverId: data['driverId'],
                                        tripId: data['tripId'],
                                        driverName: data['driverName'],
                                        pickupLocation: data['pickupLocation'],
                                        deliveryLocation:
                                            data['deliveryLocation'],
                                        distance: data['distance'],
                                        no_of_person: data['no_of_person'],
                                        vehicle_mode: data['vehicle_mode'],
                                        fare: data['fare'],
                                      ),
                                    );
                                  },
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end);
                                    var offsetAnimation = animation.drive(
                                        tween.chain(CurveTween(curve: curve)));

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (isLoadingMore)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        if (!isLoadingMore) {
                          setState(() {
                            isLoadingMore = true;
                          });
                          fetchConfirmedDriversData(isLoadMore: true).then((_) {
                            setState(() {
                              isLoadingMore = false;
                            });
                          });
                        }
                      },
                      child: Text('Load More'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final VoidCallback onChatPressed;

  const DriverCard({
    required this.data,
    required this.index,
    required this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    // return Stack(
    //   clipBehavior: Clip.none,
    //   children: [
    //     Card(
    //       elevation: 4,
    //       margin: EdgeInsets.symmetric(vertical: 6),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(12),
    //       ),
    //       child: Padding(
    //         padding: const EdgeInsets.all(12.0),
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             SizedBox(width: 1),
    //             // Profile Picture
    //             CircleAvatar(
    //               radius: 20,
    //               backgroundImage: data['profilePictureUrl'].isNotEmpty
    //                   ? NetworkImage(data['profilePictureUrl'])
    //                   : AssetImage('assets/logo.png') as ImageProvider,
    //             ),
    //             SizedBox(width: 12),
    //             // Driver Details
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   // Driver Name
    //                   Text(
    //                     data['driverName'],
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                     ),
    //                   ),
    //                   SizedBox(height: 8),
    //                   // Pickup Location
    //                   Row(
    //                     children: [
    //                       Icon(
    //                         Icons.location_on,
    //                         color: Colors.red,
    //                         size: 16,
    //                       ),
    //                       SizedBox(width: 4),
    //                       Expanded(
    //                         child: Text(
    //                           'Pickup: ${data['pickupLocation']}',
    //                           style: TextStyle(fontSize: 14),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   SizedBox(height: 4),
    //                   // Delivery Location
    //                   Row(
    //                     children: [
    //                       Icon(
    //                         Icons.location_on,
    //                         color: Colors.green,
    //                         size: 16,
    //                       ),
    //                       SizedBox(width: 4),
    //                       Expanded(
    //                         child: Text(
    //                           'Delivery: ${data['deliveryLocation']}',
    //                           style: TextStyle(fontSize: 14),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   SizedBox(height: 4),
    //                   // Contact Number
    //                   Row(
    //                     children: [
    //                       Icon(
    //                         Icons.phone,
    //                         color: Colors.blue,
    //                         size: 16,
    //                       ),
    //                       SizedBox(width: 4),
    //                       Text(
    //                         'Contact: ${data['driverPhone']}',
    //                         style: TextStyle(fontSize: 14),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             // Chat Icon
    //             IconButton(
    //               icon: Icon(Icons.chat, color: Colors.green),
    //               onPressed: onChatPressed,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     Positioned(
    //       top: -1,
    //       right: -1,
    //       child: // Serial Number
    //           ClipRRect(
    //         borderRadius: BorderRadius.circular(20),
    //         child: Container(
    //           color: Colors.blueAccent,
    //           width: 20,
    //           height: 20,
    //           alignment: Alignment.center,
    //           child: Text(
    //             '${index + 1}',
    //             style: TextStyle(
    //               fontSize: 16,
    //               fontWeight: FontWeight.bold,
    //               color: Colors.white,
    //             ),
    //           ),
    //         ),
    //       ),
    //     )
    //   ],
    // );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture with Custom Border
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            data['profilePictureUrl'].isNotEmpty
                                ? data['profilePictureUrl']
                                : 'assets/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      IconButton(
                        icon: Icon(Icons.chat,
                            color: Colors.green.shade600, size: 24),
                        onPressed: onChatPressed,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Driver Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Driver Name
                        Text(
                          data['driverName'],
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Pickup Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red.shade400,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pickup: ${data['pickupLocation']}',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Delivery Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.green.shade400,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Delivery: ${data['deliveryLocation']}',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Contact Number
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.blue.shade400,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Contact: ${data['driverPhone']}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chat Icon
                ],
              ),
            ),
          ),
        ),
        // Serial Number Badge
        Positioned(
          top: 8,
          right: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
