// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:rxdart/rxdart.dart';

// class ChatDetailPage extends StatelessWidget {
//   final String userId;
//   final String driverId;
//   final String tripId;
//   final String driverName;
//   final String pickupLocation;
//   final String deliveryLocation;
//   final String distance;
//   final String fare;
//   final int no_of_person;
//   final String vehicle_mode;

//   const ChatDetailPage({
//     super.key,
//     required this.userId,
//     required this.driverId,
//     required this.tripId,
//     required this.driverName,
//     required this.pickupLocation,
//     required this.deliveryLocation,
//     required this.distance,
//     required this.fare,
//     required this.no_of_person,
//     required this.vehicle_mode,
//   });

//   Future<String?> fetchDriverProfilePicture() async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     final driverSnapshot =
//         await firestore.collection('vehicleData').doc(driverId).get();
//     return driverSnapshot.data()?['profilePictureUrl'];
//   }

//   Stream<List<Map<String, dynamic>>> _getMessages() {
//     final userChatsStream = FirebaseFirestore.instance
//         .collection('userChats')
//         .where('tripId', isEqualTo: tripId)
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         data['collection'] = 'userChats';
//         return data;
//       }).toList();
//     });

//     final driverChatsStream = FirebaseFirestore.instance
//         .collection('driverChats')
//         .where('tripId', isEqualTo: tripId)
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         data['collection'] = 'driverChats';
//         return data;
//       }).toList();
//     });

//     return Rx.combineLatest2(userChatsStream, driverChatsStream,
//         (userChats, driverChats) {
//       List<Map<String, dynamic>> allChats = [];
//       allChats.addAll(userChats);
//       allChats.addAll(driverChats);
//       allChats.sort((a, b) {
//         final timestampA = a['timestamp'] as Timestamp?;
//         final timestampB = b['timestamp'] as Timestamp?;
//         if (timestampA == null || timestampB == null) {
//           return 0;
//         }
//         return timestampA.compareTo(timestampB);
//       });
//       return allChats;
//     });
//   }

//   void _showTripDetails(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Trip Details'),
//         content: SingleChildScrollView(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'चालकको नाम : $driverName',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'उठाउने स्थान : $pickupLocation',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'डेलिभरी स्थान : $deliveryLocation',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'दूरी : $distance km',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'भाडा : NPR $fare',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'यात्री (हरू) : $no_of_person',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'सवारी साधनको प्रकार : $vehicle_mode',
//                   textAlign: TextAlign.left,
//                 ),
//               ],
//             ),
//           ]),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.blueAccent,
//             ),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     TextEditingController messageController = TextEditingController();

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200.0,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               centerTitle: true,
//               title: FutureBuilder<String?>(
//                 future: fetchDriverProfilePicture(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Text('Loading...');
//                   }
//                   if (snapshot.hasError || !snapshot.hasData) {
//                     return Text('Driver: $driverName');
//                   }
//                   String? profilePictureUrl = snapshot.data;
//                   return GestureDetector(
//                     onTap: () => _showTripDetails(context),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         AvatarGlow(
//                           glowColor: Colors.blueAccent,
//                           duration: Duration(milliseconds: 2000),
//                           repeat: true,
//                           child: CircleAvatar(
//                             radius: 20,
//                             backgroundImage: profilePictureUrl != null
//                                 ? NetworkImage(profilePictureUrl)
//                                 : AssetImage('assets/tuktuk1.png')
//                                     as ImageProvider,
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Text(
//                           driverName,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               background: FutureBuilder<String?>(
//                 future: fetchDriverProfilePicture(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError || !snapshot.hasData) {
//                     return Center(child: Icon(Icons.error));
//                   }
//                   String? profilePictureUrl = snapshot.data;
//                   return Image.network(
//                     profilePictureUrl!,
//                     fit: BoxFit.cover,
//                   );
//                 },
//               ),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildListDelegate([
//               // Chat messages
//               StreamBuilder<List<Map<String, dynamic>>>(
//                 stream: _getMessages(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }

//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return Center(child: Text('No messages.'));
//                   }

//                   final messages = snapshot.data!;

//                   return ListView.builder(
//                     padding: EdgeInsets.all(10.0),
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final chatData = messages[index];
//                       final isDriverMessage =
//                           chatData['collection'] == 'driverChats';

//                       return Align(
//                         alignment: isDriverMessage
//                             ? Alignment.centerLeft
//                             : Alignment.centerRight,
//                         child: Container(
//                           margin: EdgeInsets.symmetric(
//                               vertical: 6.0, horizontal: 10.0),
//                           padding: EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             color: isDriverMessage
//                                 ? Colors.green.withOpacity(0.3)
//                                 : Colors.blueAccent.withOpacity(0.8),
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(20),
//                               topRight: Radius.circular(20),
//                               bottomLeft: isDriverMessage
//                                   ? Radius.circular(20)
//                                   : Radius.circular(0),
//                               bottomRight: isDriverMessage
//                                   ? Radius.circular(0)
//                                   : Radius.circular(20),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 5,
//                                 offset: Offset(0, 3),
//                               )
//                             ],
//                           ),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.7),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 chatData['message'],
//                                 style: TextStyle(
//                                   color: isDriverMessage
//                                       ? Colors.black87
//                                       : Colors.white,
//                                   fontSize: 16.0,
//                                 ),
//                               ),
//                               SizedBox(height: 5.0),
//                               Text(
//                                 chatData['timestamp'] != null
//                                     ? chatData['timestamp'].toDate().toString()
//                                     : 'Sending...',
//                                 style: TextStyle(
//                                   color: isDriverMessage
//                                       ? Colors.grey[700]
//                                       : Colors.white70,
//                                   fontSize: 12.0,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ]),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(25.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                       offset: Offset(0, 3),
//                     )
//                   ],
//                 ),
//                 child: TextField(
//                   controller: messageController,
//                   minLines: 1,
//                   maxLines: null,
//                   decoration: InputDecoration(
//                     hintText: 'Type your message...',
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 8.0),
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.blueAccent,
//                 shape: BoxShape.circle,
//               ),
//               child: IconButton(
//                 icon: Icon(Icons.send, color: Colors.white),
//                 onPressed: () async {
//                   if (messageController.text.isNotEmpty) {
//                     await FirebaseFirestore.instance
//                         .collection('userChats')
//                         .add({
//                       'userId': userId,
//                       'driverId': driverId,
//                       'tripId': tripId,
//                       'message': messageController.text,
//                       'timestamp': FieldValue.serverTimestamp(),
//                     });

//                     messageController.clear();
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:rxdart/rxdart.dart';

class ChatDetailPage extends StatefulWidget {
  final String userId;
  final String driverId;
  final String tripId;
  final String driverName;
  final String pickupLocation;
  final String deliveryLocation;
  final String distance;
  final String fare;
  final int no_of_person;
  final String vehicle_mode;

  const ChatDetailPage({
    super.key,
    required this.userId,
    required this.driverId,
    required this.tripId,
    required this.driverName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.distance,
    required this.fare,
    required this.no_of_person,
    required this.vehicle_mode,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  Future<String?> fetchDriverProfilePicture() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final driverSnapshot =
        await firestore.collection('vehicleData').doc(widget.driverId).get();
    return driverSnapshot.data()?['profilePictureUrl'];
  }

  Stream<List<Map<String, dynamic>>> _getMessages() {
    final userChatsStream = FirebaseFirestore.instance
        .collection('userChats')
        .where('tripId', isEqualTo: widget.tripId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['collection'] = 'userChats';
        return data;
      }).toList();
    });

    final driverChatsStream = FirebaseFirestore.instance
        .collection('driverChats')
        .where('tripId', isEqualTo: widget.tripId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['collection'] = 'driverChats';
        return data;
      }).toList();
    });

    return Rx.combineLatest2(userChatsStream, driverChatsStream,
        (userChats, driverChats) {
      List<Map<String, dynamic>> allChats = [];
      allChats.addAll(userChats);
      allChats.addAll(driverChats);
      allChats.sort((a, b) {
        final timestampA = a['timestamp'] as Timestamp?;
        final timestampB = b['timestamp'] as Timestamp?;
        if (timestampA == null || timestampB == null) {
          return 0;
        }
        return timestampA.compareTo(timestampB);
      });
      return allChats;
    });
  }

  void _showTripDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trip Details'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'चालकको नाम : ${widget.driverName}',
                  textAlign: TextAlign.left,
                ),
                Divider(),
                Text(
                  'उठाउने स्थान : ${widget.pickupLocation}',
                  textAlign: TextAlign.left,
                ),
                Divider(),
                Text(
                  'डेलिभरी स्थान : ${widget.deliveryLocation}',
                  textAlign: TextAlign.left,
                ),
                Divider(),
                Text(
                  'दूरी : ${widget.distance} km',
                  textAlign: TextAlign.left,
                ),
                Divider(),
                Text(
                  'भाडा : NPR ${widget.fare}',
                  textAlign: TextAlign.left,
                ),
                Divider(),
                Text(
                  'यात्री (हरू) : ${widget.no_of_person}',
                  textAlign: TextAlign.left,
                ),
                Divider(),
                Text(
                  'सवारी साधनको प्रकार : ${widget.vehicle_mode}',
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();

    // return Scaffold(
    //   resizeToAvoidBottomInset: false,

    //   body: CustomScrollView(
    //     slivers: [
    //       SliverAppBar(
    //         expandedHeight: 200.0,
    //         floating: false,
    //         stretch: true,
    //         pinned: true,
    //         flexibleSpace: FlexibleSpaceBar(
    //           centerTitle: true,
    //           title: FutureBuilder<String?>(
    //             future: fetchDriverProfilePicture(),
    //             builder: (context, snapshot) {
    //               if (snapshot.connectionState == ConnectionState.waiting) {
    //                 return Text('Loading...');
    //               }
    //               if (snapshot.hasError || !snapshot.hasData) {
    //                 return Text('Driver: ${widget.driverName}');
    //               }
    //               String? profilePictureUrl = snapshot.data;
    //               return GestureDetector(
    //                 onTap: () => _showTripDetails(context),
    //                 child: Row(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     AvatarGlow(
    //                       glowColor: Colors.blueAccent,
    //                       duration: Duration(milliseconds: 2000),
    //                       repeat: true,
    //                       child: CircleAvatar(
    //                         radius: 20,
    //                         backgroundImage: profilePictureUrl != null
    //                             ? NetworkImage(profilePictureUrl)
    //                             : AssetImage('assets/tuktuk1.png')
    //                                 as ImageProvider,
    //                       ),
    //                     ),
    //                     SizedBox(width: 12),
    //                     Text(
    //                       '${widget.driverName}',
    //                       style: TextStyle(
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.bold,
    //                         color: Colors.white,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               );
    //             },
    //           ),
    //           background: LayoutBuilder(
    //             builder: (context, constraints) {
    //               final double maxHeight = constraints.maxHeight;
    //               final double minHeight = kToolbarHeight;
    //               final double currentHeight = constraints.biggest.height;
    //               final double opacity =
    //                   (currentHeight - minHeight) / (maxHeight - minHeight);

    //               return FutureBuilder<String?>(
    //                 future: fetchDriverProfilePicture(),
    //                 builder: (context, snapshot) {
    //                   if (snapshot.connectionState == ConnectionState.waiting) {
    //                     return Center(child: CircularProgressIndicator());
    //                   }
    //                   if (snapshot.hasError || !snapshot.hasData) {
    //                     return Center(child: Icon(Icons.error));
    //                   }
    //                   String? profilePictureUrl = snapshot.data;
    //                   return Opacity(
    //                     opacity: opacity.clamp(
    //                         1, 1.0), // 60% transparency at minimum height
    //                     child: Image.network(
    //                       profilePictureUrl!,
    //                       fit: BoxFit.cover,
    //                     ),
    //                   );
    //                 },
    //               );
    //             },
    //           ),
    //         ),
    //       ),
    //       SliverList(
    //         delegate: SliverChildListDelegate([
    //           // Chat messages
    //           StreamBuilder<List<Map<String, dynamic>>>(
    //             stream: _getMessages(),
    //             builder: (context, snapshot) {
    //               if (snapshot.connectionState == ConnectionState.waiting) {
    //                 return Center(child: CircularProgressIndicator());
    //               }

    //               if (snapshot.hasError) {
    //                 return Center(child: Text('Error: ${snapshot.error}'));
    //               }

    //               if (!snapshot.hasData || snapshot.data!.isEmpty) {
    //                 return Center(child: Text('No messages.'));
    //               }

    //               final messages = snapshot.data!;

    //               return ListView.builder(
    //                 padding: EdgeInsets.all(10.0),
    //                 shrinkWrap: true,
    //                 physics: NeverScrollableScrollPhysics(),
    //                 itemCount: messages.length,
    //                 itemBuilder: (context, index) {
    //                   final chatData = messages[index];
    //                   final isDriverMessage =
    //                       chatData['collection'] == 'driverChats';

    //                   return Align(
    //                     alignment: isDriverMessage
    //                         ? Alignment.centerLeft
    //                         : Alignment.centerRight,
    //                     child: Container(
    //                       margin: EdgeInsets.symmetric(
    //                           vertical: 6.0, horizontal: 10.0),
    //                       padding: EdgeInsets.all(12.0),
    //                       decoration: BoxDecoration(
    //                         color: isDriverMessage
    //                             ? Colors.green.withOpacity(0.3)
    //                             : Colors.blueAccent.withOpacity(0.8),
    //                         borderRadius: BorderRadius.only(
    //                           topLeft: Radius.circular(20),
    //                           topRight: Radius.circular(20),
    //                           bottomLeft: isDriverMessage
    //                               ? Radius.circular(20)
    //                               : Radius.circular(0),
    //                           bottomRight: isDriverMessage
    //                               ? Radius.circular(0)
    //                               : Radius.circular(20),
    //                         ),
    //                         boxShadow: [
    //                           BoxShadow(
    //                             color: Colors.black.withOpacity(0.1),
    //                             blurRadius: 5,
    //                             offset: Offset(0, 3),
    //                           )
    //                         ],
    //                       ),
    //                       constraints: BoxConstraints(
    //                           maxWidth:
    //                               MediaQuery.of(context).size.width * 0.7),
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Text(
    //                             chatData['message'],
    //                             style: TextStyle(
    //                               color: isDriverMessage
    //                                   ? Colors.black87
    //                                   : Colors.white,
    //                               fontSize: 16.0,
    //                             ),
    //                           ),
    //                           SizedBox(height: 5.0),
    //                           Text(
    //                             chatData['timestamp'] != null
    //                                 ? chatData['timestamp'].toDate().toString()
    //                                 : 'Sending...',
    //                             style: TextStyle(
    //                               color: isDriverMessage
    //                                   ? Colors.grey[700]
    //                                   : Colors.white70,
    //                               fontSize: 12.0,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   );
    //                 },
    //               );
    //             },
    //           ),
    //         ]),
    //       ),
    //     ],
    //   ),
    //   bottomNavigationBar: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Row(
    //       children: [
    //         Expanded(
    //           child: Container(
    //             padding: EdgeInsets.symmetric(horizontal: 10.0),
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(25.0),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: Colors.grey.withOpacity(0.2),
    //                   spreadRadius: 1,
    //                   blurRadius: 5,
    //                   offset: Offset(0, 3),
    //                 )
    //               ],
    //             ),
    //             child: TextField(
    //               controller: messageController,
    //               minLines: 1,
    //               maxLines: null,
    //               decoration: InputDecoration(
    //                 hintText: 'Type your message...',
    //                 border: InputBorder.none,
    //               ),
    //             ),
    //           ),
    //         ),
    //         SizedBox(width: 8.0),
    //         Container(
    //           decoration: BoxDecoration(
    //             color: Colors.blueAccent,
    //             shape: BoxShape.circle,
    //           ),
    //           child: IconButton(
    //             icon: Icon(Icons.send, color: Colors.white),
    //             onPressed: () async {
    //               if (messageController.text.isNotEmpty) {
    //                 await FirebaseFirestore.instance
    //                     .collection('userChats')
    //                     .add({
    //                   'userId': widget.userId,
    //                   'driverId': widget.driverId,
    //                   'tripId': widget.tripId,
    //                   'message': messageController.text,
    //                   'timestamp': FieldValue.serverTimestamp(),
    //                 });

    //                 messageController.clear();
    //               }
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensure the body resizes to avoid the keyboard
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.blueAccent,
            expandedHeight: 200.0,
            floating: false,
            stretch: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: FutureBuilder<String?>(
                future: fetchDriverProfilePicture(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // return Text('Loading...');
                    return Center(
                      child: Image(image: AssetImage('assets/logo.png')),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    // return Text('Driver: $driverName');
                    return Center(
                      child: Image(image: AssetImage('assets/logo.png')),
                    );
                  }
                  String? profilePictureUrl = snapshot.data;
                  return GestureDetector(
                    onTap: () => _showTripDetails(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AvatarGlow(
                          glowColor: Colors.blueAccent,
                          duration: Duration(milliseconds: 2000),
                          repeat: true,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: profilePictureUrl != null
                                ? NetworkImage(profilePictureUrl)
                                : AssetImage('assets/tuktuk1.png')
                                    as ImageProvider,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          widget.driverName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              background: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxHeight = constraints.maxHeight;
                  final double minHeight = kToolbarHeight;
                  final double currentHeight = constraints.biggest.height;
                  final double opacity =
                      (currentHeight - minHeight) / (maxHeight - minHeight);

                  return FutureBuilder<String?>(
                    future: fetchDriverProfilePicture(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(child: Icon(Icons.error));
                      }
                      String? profilePictureUrl = snapshot.data;
                      return Opacity(
                        opacity: opacity.clamp(1, 1.0),
                        child: Image.network(
                          profilePictureUrl!,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // Chat messages
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No messages.'));
                  }

                  final messages = snapshot.data!;

                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final chatData = messages[index];
                      final isDriverMessage =
                          chatData['collection'] == 'driverChats';

                      return Align(
                        alignment: isDriverMessage
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 10.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isDriverMessage
                                ? Colors.green.withOpacity(0.3)
                                : Colors.blueAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: isDriverMessage
                                  ? Radius.circular(20)
                                  : Radius.circular(0),
                              bottomRight: isDriverMessage
                                  ? Radius.circular(0)
                                  : Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatData['message'],
                                style: TextStyle(
                                  color: isDriverMessage
                                      ? Colors.black87
                                      : Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                chatData['timestamp'] != null
                                    ? chatData['timestamp'].toDate().toString()
                                    : 'Sending...',
                                style: TextStyle(
                                  color: isDriverMessage
                                      ? Colors.grey[700]
                                      : Colors.white70,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Adjust padding for keyboard
        ),
        child: Container(
          padding: EdgeInsets.all(8.0),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () async {
                    if (messageController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('userChats')
                          .add({
                        'userId': widget.userId,
                        'driverId': widget.driverId,
                        'tripId': widget.tripId,
                        'message': messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      messageController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
