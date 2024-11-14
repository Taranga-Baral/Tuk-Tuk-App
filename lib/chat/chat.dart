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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/chat/chat_display_page.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart'; // Import the animations package

class ChatPage extends StatefulWidget {
  final String userId;

  const ChatPage({super.key, required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> confirmedDriversData = [];
  DocumentSnapshot? lastDocument; // For pagination
  bool isLoadingMore = false; // To track loading state

  @override
  void initState() {
    super.initState();
    fetchConfirmedDriversData();
  }

  Future<void> fetchConfirmedDriversData({bool isLoadMore = false}) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Calculate time 1 hour ago
    DateTime oneHourAgo = DateTime.now().subtract(Duration(hours: 1));

    Query query = firestore
        .collection('confirmedDrivers')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('confirmedAt', descending: true)
        .limit(isLoadMore ? 10 : 10); // Load 10 cards at a time

    if (isLoadMore && lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot confirmedDriversSnapshot = await query.get();

    if (confirmedDriversSnapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in confirmedDriversSnapshot.docs) {
        var confirmedDriverData = doc.data() as Map<String, dynamic>;

        // Fetch details from trips using tripId
        DocumentSnapshot tripSnapshot = await firestore
            .collection('trips')
            .doc(confirmedDriverData['tripId'])
            .get();

        // Check if the trip exists and is within the last hour
        if (tripSnapshot.exists) {
          var tripData = tripSnapshot.data() as Map<String, dynamic>;
          var tripTimestamp = (tripData['timestamp'] as Timestamp).toDate();

          // Compare tripTimestamp with oneHourAgo
          if (tripTimestamp.isAfter(oneHourAgo)) {
            // Trip is within the last hour, include it in fetchedData
            // Fetch details from vehicleData using driverId
            DocumentSnapshot driverSnapshot = await firestore
                .collection('vehicleData')
                .doc(confirmedDriverData['driverId'])
                .get();
            var driverData = driverSnapshot.data() as Map<String, dynamic>;

            // Combine the data from both collections and include profile picture
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
              'timestamp':
                  confirmedDriverData['timestamp'], // Ensure this field exists
            });
          } else {
            // Trip is older than 1 hour, skip processing
            print(
                'Skipping trip ${confirmedDriverData['tripId']} as it is older than 1 hour.');
          }
        } else {
          print(
              'Trip ${confirmedDriverData['tripId']} does not exist or has no data.');
        }
      }

      setState(() {
        if (isLoadMore) {
          confirmedDriversData.addAll(fetchedData);
        } else {
          confirmedDriversData = fetchedData;
        }
        lastDocument =
            confirmedDriversSnapshot.docs.last; // Update the last document
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with Drivers',
          style: GoogleFonts.outfit(),
        ),
        backgroundColor: Colors.greenAccent.shade200.withOpacity(0.9),
      ),
      body: confirmedDriversData.isEmpty
          ? Center(
              child: Image(
              image: AssetImage('assets/no_data_found.gif'),
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.7,
            ))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: confirmedDriversData.length,
                      itemBuilder: (context, index) {
                        var data = confirmedDriversData[index];
                        String driverId = data['driverId'];
                        String tripId = data['tripId'];
                        String profilePictureUrl = data['profilePictureUrl'];

                        // Case: Data available
                        return Column(
                          children: [
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        profilePictureUrl.isNotEmpty
                                            ? NetworkImage(profilePictureUrl)
                                            : AssetImage('assets/logo.png')
                                                as ImageProvider,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${data['driverName']}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '... ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pickup Location: ${data['pickupLocation']}\n\n'
                                        'Delivery Location: ${data['deliveryLocation']}\n\n'
                                        'Contact: ${data['driverPhone']}',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.chat,
                                                color: Colors.green),
                                            onPressed: () {
                                              // Navigate to ChatDetailPage with animation
                                              Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                      animation,
                                                      secondaryAnimation) {
                                                    return FadeScaleTransition(
                                                      animation: animation,
                                                      child: ChatDetailPage(
                                                        userId: widget.userId,
                                                        driverId: driverId,
                                                        tripId: tripId,
                                                        driverName:
                                                            data['driverName'],
                                                        pickupLocation: data[
                                                            'pickupLocation'],
                                                        deliveryLocation: data[
                                                            'deliveryLocation'],
                                                        distance:
                                                            data['distance'],
                                                        no_of_person: data[
                                                            'no_of_person'],
                                                        vehicle_mode: data[
                                                            'vehicle_mode'],
                                                        fare: data['fare'],
                                                      ),
                                                    );
                                                  },
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    const begin =
                                                        Offset(1.0, 0.0);
                                                    const end = Offset.zero;
                                                    const curve =
                                                        Curves.easeInOut;

                                                    var tween = Tween(
                                                        begin: begin, end: end);
                                                    var offsetAnimation =
                                                        animation.drive(tween
                                                            .chain(CurveTween(
                                                                curve: curve)));

                                                    return SlideTransition(
                                                      position: offsetAnimation,
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  ),
                  if (isLoadingMore)
                    CircularProgressIndicator(), // Show loading indicator
                  ElevatedButton(
                    onPressed: () {
                      if (!isLoadingMore) {
                        setState(() {
                          isLoadingMore = true;
                        });
                        fetchConfirmedDriversData(isLoadMore: true).then((_) {
                          setState(() {
                            isLoadingMore = false; // Reset loading state
                          });
                        });
                      }
                    },
                    child: Text('Load More'),
                  ),
                ],
              ),
            ),
    );
  }
}
