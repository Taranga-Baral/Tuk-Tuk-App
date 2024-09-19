
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/chat/chat_display_page.dart';
// import 'package:flutter/material.dart';

// class ChatPage extends StatefulWidget {
//   final String userId;

//   const ChatPage({super.key, required this.userId});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   List<Map<String, dynamic>> confirmedDriversData = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchConfirmedDriversData();
//   }

// Future<void> fetchConfirmedDriversData() async {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // Query confirmedDrivers where userId matches
//   QuerySnapshot confirmedDriversSnapshot = await firestore
//       .collection('confirmedDrivers')
//       .where('userId', isEqualTo: widget.userId)
//       .get();

//   List<Map<String, dynamic>> fetchedData = [];

//   for (var doc in confirmedDriversSnapshot.docs) {
//     var confirmedDriverData = doc.data() as Map<String, dynamic>;

//     // Fetch details from trips using tripId
//     DocumentSnapshot tripSnapshot = await firestore
//         .collection('trips')
//         .doc(confirmedDriverData['tripId'])
//         .get();
//     var tripData = tripSnapshot.data() as Map<String, dynamic>;

//     // Fetch details from vehicleData using driverId
//     DocumentSnapshot driverSnapshot = await firestore
//         .collection('vehicleData')
//         .doc(confirmedDriverData['driverId'])
//         .get();
//     var driverData = driverSnapshot.data() as Map<String, dynamic>;

//     // Combine the data from both collections and include profile picture
//     fetchedData.add({
//       'id': doc.id,
//       'pickupLocation': tripData['pickupLocation'],
//       'deliveryLocation': tripData['deliveryLocation'],
//       'distance': tripData['distance'],
//       'fare': tripData['fare'],
//       'driverName': driverData['name'],
//       'driverPhone': driverData['phone'],
//       'profilePictureUrl': driverData['profilePictureUrl'] ?? '', // Fetch profile picture
//       'driverId': confirmedDriverData['driverId'],
//       'tripId': confirmedDriverData['tripId'],
//     });
//   }

//   setState(() {
//     confirmedDriversData = fetchedData;
//   });
// }


// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text('Chat with Drivers'),
//     ),
//     body: confirmedDriversData.isEmpty
//         ? Center(child: CircularProgressIndicator())
//         : Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: ListView.builder(
//               itemCount: confirmedDriversData.length,
//               itemBuilder: (context, index) {
//                 var data = confirmedDriversData[index];
//                 String driverId = data['driverId'];
//                 String tripId = data['tripId'];
//                 String profilePictureUrl = data['profilePictureUrl'];

//                 return Column(
//                   children: [
//                     Card(
//                       elevation: 5,
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: profilePictureUrl.isNotEmpty
//                               ? NetworkImage(profilePictureUrl)
//                               : AssetImage('assets/loading_screen.gif')
//                                   as ImageProvider, // Fallback image if no URL
//                         ),
//                         title: Text('Driver: ${data['driverName']}'),
//                         subtitle: Text(
//                           'Pickup: ${data['pickupLocation']}\n'
//                           'Delivery: ${data['deliveryLocation']}\n'
//                           'Phone: ${data['driverPhone']}',
//                         ),
//                         trailing: IconButton(
//                           icon: Icon(Icons.chat),
//                           onPressed: () {
//                             // Navigate to ChatDetailPage
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ChatDetailPage(
//                                   userId: widget.userId,
//                                   driverId: driverId,
//                                   tripId: tripId,
//                                   driverName: data['driverName'],
//                                   pickupLocation: data['pickupLocation'],
//                                   deliveryLocation: data['deliveryLocation'],
//                                   distance: data['distance'],
//                                   fare: data['fare'],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//   );
// }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/chat/chat_display_page.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // Import the animations package

class ChatPage extends StatefulWidget {
  final String userId;

  const ChatPage({super.key, required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> confirmedDriversData = [];

  @override
  void initState() {
    super.initState();
    fetchConfirmedDriversData();
  }

  Future<void> fetchConfirmedDriversData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query confirmedDrivers where userId matches
    QuerySnapshot confirmedDriversSnapshot = await firestore
        .collection('confirmedDrivers')
        .where('userId', isEqualTo: widget.userId)
        .get();

    List<Map<String, dynamic>> fetchedData = [];

    for (var doc in confirmedDriversSnapshot.docs) {
      var confirmedDriverData = doc.data() as Map<String, dynamic>;

      // Fetch details from trips using tripId
      DocumentSnapshot tripSnapshot = await firestore
          .collection('trips')
          .doc(confirmedDriverData['tripId'])
          .get();
      var tripData = tripSnapshot.data() as Map<String, dynamic>;

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
        'profilePictureUrl': driverData['profilePictureUrl'] ?? '', // Fetch profile picture
        'driverId': confirmedDriverData['driverId'],
        'tripId': confirmedDriverData['tripId'],
      });
    }

    setState(() {
      confirmedDriversData = fetchedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Drivers'),
        backgroundColor: Colors.greenAccent.shade200.withOpacity(0.9),
      ),
      body: confirmedDriversData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: confirmedDriversData.length,
                itemBuilder: (context, index) {
                  var data = confirmedDriversData[index];
                  String driverId = data['driverId'];
                  String tripId = data['tripId'];
                  String profilePictureUrl = data['profilePictureUrl'];

                  return Column(
                    children: [
                      // Card(
                      //   elevation: 5,
                      //   child: ListTile(
                      //     leading: CircleAvatar(
                      //       backgroundImage: profilePictureUrl.isNotEmpty
                      //           ? NetworkImage(profilePictureUrl)
                      //           : AssetImage('assets/tuktuk.jpg')
                      //               as ImageProvider, // Fallback image if no URL
                      //     ),
                      //     title: Text('Driver: ${data['driverName']}'),
                      //     subtitle: Text(
                      //       'Pickup: ${data['pickupLocation']}\n'
                      //       'Delivery: ${data['deliveryLocation']}\n'
                      //       'Phone: ${data['driverPhone']}',
                      //     ),
                      //     trailing: IconButton(
                      //       icon: Icon(Icons.chat),
                      //       onPressed: () {
                      //         // Navigate to ChatDetailPage with animation
                      //         Navigator.of(context).push(
                      //           PageRouteBuilder(
                      //             pageBuilder: (context, animation, secondaryAnimation) {
                      //               return FadeScaleTransition(
                      //                 animation: animation,
                      //                 child: ChatDetailPage(
                      //                   userId: widget.userId,
                      //                   driverId: driverId,
                      //                   tripId: tripId,
                      //                   driverName: data['driverName'],
                      //                   pickupLocation: data['pickupLocation'],
                      //                   deliveryLocation: data['deliveryLocation'],
                      //                   distance: data['distance'],
                      //                   fare: data['fare'],
                      //                 ),
                      //               );
                      //             },
                      //             transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      //               const begin = Offset(1.0, 0.0);
                      //               const end = Offset.zero;
                      //               const curve = Curves.fastEaseInToSlowEaseOut;

                      //               var tween = Tween(begin: begin, end: end);
                      //               var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));

                      //               return SlideTransition(position: offsetAnimation, child: child);
                      //             },
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ),

                      Card(
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[200]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundImage: profilePictureUrl.isNotEmpty
            ? NetworkImage(profilePictureUrl)
            : AssetImage('assets/loading_screen.gif') as ImageProvider,
      ),
      title: Text('Driver: ${data['driverName']}', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        'Pickup: ${data['pickupLocation']}\n'
        'Delivery: ${data['deliveryLocation']}\n'
        'Phone: ${data['driverPhone']}',
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: IconButton(
        icon: Icon(Icons.chat, color: Colors.green),
        onPressed: () {
          // Navigate to ChatDetailPage with animation
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeScaleTransition(
                  animation: animation,
                  child: ChatDetailPage(
                    userId: widget.userId,
                    driverId: driverId,
                    tripId: tripId,
                    driverName: data['driverName'],
                    pickupLocation: data['pickupLocation'],
                    deliveryLocation: data['deliveryLocation'],
                    distance: data['distance'],
                    fare: data['fare'],
                  ),
                );
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end);
                var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
      ),
    ),
  ),
),

                      SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
