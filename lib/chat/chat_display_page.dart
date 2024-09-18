
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ChatDetailPage extends StatelessWidget {
//   final String userId;
//   final String driverId;
//   final String tripId;
//   final String driverName; 
//   final String pickupLocation;
//   final String deliveryLocation;
//   final String distance;
//   final String fare;

//   ChatDetailPage({
//     required this.userId,
//     required this.driverId,
//     required this.tripId,
//     required this.driverName,
//     required this.pickupLocation,
//     required this.deliveryLocation,
//     required this.distance,
//     required this.fare,
//   });

//   Future<String?> fetchDriverProfilePicture() async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     final driverSnapshot = await firestore.collection('vehicleData').doc(driverId).get();
//     return driverSnapshot.data()?['profilePicture']; // Fetch the profile picture URL
//   }

//   @override
//   Widget build(BuildContext context) {
//     TextEditingController messageController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with $driverName'),
//       ),
//       body: Column(
//         children: [
//           // Center Avatar and Information Icon
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 20.0),
//             child: Column(
//               children: [
//                 FutureBuilder<String?>(
//                   future: fetchDriverProfilePicture(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return CircleAvatar(
//                         radius: 60,
//                         child: CircularProgressIndicator(),
//                       );
//                     }
//                     if (snapshot.hasError || !snapshot.hasData) {
//                       return CircleAvatar(
//                         radius: 60,
//                         child: Icon(Icons.error),
//                       );
//                     }
//                     String? profilePictureUrl = snapshot.data;
//                     return CircleAvatar(
//                       radius: 60,
//                       backgroundImage: profilePictureUrl != null
//                           ? NetworkImage(profilePictureUrl)
//                           : AssetImage('assets/tuktuk1.png') as ImageProvider,
//                     );
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 IconButton(
//                   icon: Icon(Icons.info_outline, size: 30),
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text('Trip Details'),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text('Driver Name: $driverName'),
//                             Text('Pickup Location: $pickupLocation'),
//                             Text('Delivery Location: $deliveryLocation'),
//                             Text('Distance: ${distance} km'),
//                             Text('Fare: \$${fare}'),
//                           ],
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.of(context).pop(),
//                             child: Text('Close'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Chat messages
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('userChats')
//                   .where('tripId', isEqualTo: tripId)
//                   .orderBy('timestamp', descending: false)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No messages.'));
//                 }

//                 return ListView.builder(
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final chatData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
//                     final isUserMessage = chatData['userId'] == userId;

//                     return Align(
//                       alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
//                         child: Card(
//                           color: isUserMessage ? Colors.blue[100] : Colors.green[100],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Container(
//                             padding: EdgeInsets.all(12.0),
//                             constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   chatData['message'],
//                                   style: TextStyle(
//                                     color: isUserMessage ? Colors.black : Colors.black87,
//                                     fontSize: 16.0,
//                                   ),
//                                 ),
//                                 SizedBox(height: 5.0),
//                                 Text(
//                                   chatData['timestamp'] != null
//                                       ? chatData['timestamp'].toDate().toString()
//                                       : 'Sending...',
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                     fontSize: 12.0,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // Message input
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     minLines: 1,
//                     maxLines: null, // Allow text to wrap into multiple lines
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () async {
//                     if (messageController.text.isNotEmpty) {
//                       await FirebaseFirestore.instance.collection('userChats').add({
//                         'userId': userId,
//                         'driverId': driverId,
//                         'tripId': tripId,
//                         'message': messageController.text,
//                         'timestamp': FieldValue.serverTimestamp(),
//                       });
//                       messageController.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatDetailPage extends StatelessWidget {
  final String userId;
  final String driverId;
  final String tripId;
  final String driverName;
  final String pickupLocation;
  final String deliveryLocation;
  final String distance;
  final String fare;

  ChatDetailPage({
    required this.userId,
    required this.driverId,
    required this.tripId,
    required this.driverName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.distance,
    required this.fare,
  });

  Future<String?> fetchDriverProfilePicture() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final driverSnapshot = await firestore.collection('vehicleData').doc(driverId).get();
    return driverSnapshot.data()?['profilePictureUrl']; // Fetch the profile picture URL
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $driverName'),
      ),
      body: Column(
        children: [
          // Center Avatar and Information Icon
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                FutureBuilder<String?>(
                  future: fetchDriverProfilePicture(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 60,
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return CircleAvatar(
                        radius: 60,
                        child: Icon(Icons.error),
                      );
                    }
                    String? profilePictureUrl = snapshot.data;
                    return CircleAvatar(
                      radius: 60,
                      backgroundImage: profilePictureUrl != null
                          ? NetworkImage(profilePictureUrl)
                          : AssetImage('assets/tuktuk1.png') as ImageProvider, // Fallback image if no URL
                    );
                  },
                ),
                SizedBox(height: 10),
                IconButton(
                  icon: Icon(Icons.info_outline, size: 30),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Trip Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Driver Name: $driverName'),
                            Text('Pickup Location: $pickupLocation'),
                            Text('Delivery Location: $deliveryLocation'),
                            Text('Distance: ${distance} km'),
                            Text('Fare: NPR ${fare}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('userChats')
                  .where('tripId', isEqualTo: tripId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final chatData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final isUserMessage = chatData['userId'] == userId;

                    return Align(
                      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                        child: Card(
                          color: isUserMessage ? Colors.blue[100] : Colors.green[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chatData['message'],
                                  style: TextStyle(
                                    color: isUserMessage ? Colors.black : Colors.black87,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  chatData['timestamp'] != null
                                      ? chatData['timestamp'].toDate().toString()
                                      : 'Sending...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: null, // Allow text to wrap into multiple lines
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (messageController.text.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('userChats').add({
                        'userId': userId,
                        'driverId': driverId,
                        'tripId': tripId,
                        'message': messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

