// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';

// class DriverChatDisplayPage extends StatefulWidget {
//   final String driverId;
//   final String tripId;
//   final String userId;

//   const DriverChatDisplayPage({
//     super.key,
//     required this.driverId,
//     required this.tripId,
//     required this.userId,
//   });

//   @override
//   _DriverChatDisplayPageState createState() => _DriverChatDisplayPageState();
// }

// class _DriverChatDisplayPageState extends State<DriverChatDisplayPage> {
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   Future<void> _sendMessage() async {
//     if (messageController.text.isNotEmpty) {
//       final message = messageController.text;
//       final timestamp = FieldValue.serverTimestamp();

//       try {
//         await FirebaseFirestore.instance.collection('driverChats').add({
//           'driverId': widget.driverId,
//           'tripId': widget.tripId,
//           'userId': widget.userId,
//           'message': message,
//           'timestamp': timestamp,
//         });

//         messageController.clear();
//       } catch (e) {
//         print('Error sending message: $e');
//       }
//     }
//   }

//   Stream<List<Map<String, dynamic>>> _getMessages() {
//     final userChatsStream = FirebaseFirestore.instance
//         .collection('userChats')
//         .where('tripId', isEqualTo: widget.tripId)
//         .where('userId', isEqualTo: widget.userId)
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
//         .where('tripId', isEqualTo: widget.tripId)
//         .where('userId', isEqualTo: widget.userId)
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

//   Future<String?> _fetchUsername() async {
//     try {
//       final DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.userId)
//           .get();

//       final data = userDoc.data() as Map<String, dynamic>?;
//       return data?['username'] as String?;
//     } catch (e) {
//       print('Error fetching username: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       resizeToAvoidBottomInset: true,
//       body: Column(
//         children: [
//           Expanded(
//             child: CustomScrollView(
//               controller: _scrollController,
//               slivers: [
//                 SliverAppBar(
//                   foregroundColor: Colors.white,
//                   expandedHeight: 100.0,
//                   floating: false,
//                   pinned: true,
//                   flexibleSpace: FlexibleSpaceBar(
//                     title: FutureBuilder<String?>(
//                       future: _fetchUsername(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Text('Chat');
//                         }
//                         if (snapshot.hasError || !snapshot.hasData) {
//                           return Text('Chat');
//                         }
//                         return Text(
//                           'Passenger : ${snapshot.data}',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w500),
//                         );
//                       },
//                     ),
//                     background: ClipPath(
//                       clipper: _CurvedAppBarClipper(),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Colors.blueAccent, Colors.lightBlueAccent],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   backgroundColor: Colors.blueAccent,
//                 ),
//                 SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       return StreamBuilder<List<Map<String, dynamic>>>(
//                         stream: _getMessages(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return Center(child: CircularProgressIndicator());
//                           }

//                           if (snapshot.hasError) {
//                             return Center(
//                                 child: Text('Error: ${snapshot.error}'));
//                           }

//                           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                             return Center(child: Text('No messages.'));
//                           }

//                           List<Map<String, dynamic>> messages = snapshot.data!;

//                           return ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: messages.length,
//                             itemBuilder: (context, index) {
//                               final chatData = messages[index];
//                               final isDriverMessage =
//                                   chatData['collection'] == 'driverChats';

//                               return Align(
//                                 alignment: isDriverMessage
//                                     ? Alignment.centerRight
//                                     : Alignment.centerLeft,
//                                 child: Container(
//                                   margin: EdgeInsets.symmetric(
//                                       vertical: 6.0, horizontal: 10.0),
//                                   padding: EdgeInsets.all(12.0),
//                                   decoration: BoxDecoration(
//                                     color: isDriverMessage
//                                         ? Colors.blue[50]
//                                         : Colors.white,
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(20),
//                                       topRight: Radius.circular(20),
//                                       bottomLeft: isDriverMessage
//                                           ? Radius.circular(20)
//                                           : Radius.circular(0),
//                                       bottomRight: isDriverMessage
//                                           ? Radius.circular(0)
//                                           : Radius.circular(20),
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 5,
//                                         offset: Offset(0, 3),
//                                       ),
//                                     ],
//                                   ),
//                                   constraints: BoxConstraints(
//                                       maxWidth:
//                                           MediaQuery.of(context).size.width *
//                                               0.7),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         chatData['message'],
//                                         style: TextStyle(
//                                             color: isDriverMessage
//                                                 ? Colors.black87
//                                                 : Colors.black,
//                                             fontSize: 16.0,
//                                             fontWeight: isDriverMessage
//                                                 ? FontWeight.w400
//                                                 : FontWeight.w500),
//                                       ),
//                                       SizedBox(height: 5.0),
//                                       Text(
//                                         chatData['timestamp'] != null
//                                             ? chatData['timestamp']
//                                                 .toDate()
//                                                 .toString()
//                                             : 'Sending...',
//                                         style: TextStyle(
//                                           color: isDriverMessage
//                                               ? Colors.grey[700]
//                                               : Colors.grey[700],
//                                           fontSize: 12.0,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       );
//                     },
//                     childCount: 1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(25.0),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.2),
//                           spreadRadius: 1,
//                           blurRadius: 5,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: TextField(
//                       controller: messageController,
//                       minLines: 1,
//                       maxLines: null,
//                       decoration: InputDecoration(
//                         hintText: 'Type your message...',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.0),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.blueAccent,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: Icon(Icons.send, color: Colors.white),
//                     onPressed: _sendMessage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CurvedAppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(0, size.height - 50);
//     path.quadraticBezierTo(
//         size.width / 2, size.height, size.width, size.height - 50);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';

// class DriverChatDisplayPage extends StatefulWidget {
//   final String driverId;
//   final String tripId;
//   final String userId;

//   const DriverChatDisplayPage({
//     super.key,
//     required this.driverId,
//     required this.tripId,
//     required this.userId,
//   });

//   @override
//   _DriverChatDisplayPageState createState() => _DriverChatDisplayPageState();
// }

// class _DriverChatDisplayPageState extends State<DriverChatDisplayPage> {
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     // Auto-scroll to the bottom when new messages are added
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToBottom();
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _sendMessage() async {
//     if (messageController.text.trim().isNotEmpty) {
//       final message = messageController.text.trim();
//       final timestamp = FieldValue.serverTimestamp();

//       try {
//         await FirebaseFirestore.instance.collection('driverChats').add({
//           'driverId': widget.driverId,
//           'tripId': widget.tripId,
//           'userId': widget.userId,
//           'message': message,
//           'timestamp': timestamp,
//         });

//         messageController.clear();
//         _scrollToBottom();
//         _focusNode.requestFocus();
//       } catch (e) {
//         print('Error sending message: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to send message: $e')),
//         );
//       }
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Stream<List<Map<String, dynamic>>> _getMessages() {
//     final userChatsStream = FirebaseFirestore.instance
//         .collection('userChats')
//         .where('tripId', isEqualTo: widget.tripId)
//         .where('userId', isEqualTo: widget.userId)
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => {...doc.data(), 'collection': 'userChats'})
//             .toList());

//     final driverChatsStream = FirebaseFirestore.instance
//         .collection('driverChats')
//         .where('tripId', isEqualTo: widget.tripId)
//         .where('userId', isEqualTo: widget.userId)
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => {...doc.data(), 'collection': 'driverChats'})
//             .toList());

//     return Rx.combineLatest2(userChatsStream, driverChatsStream,
//         (List<Map<String, dynamic>> userChats,
//             List<Map<String, dynamic>> driverChats) {
//       final allChats = [...userChats, ...driverChats];
//       allChats.sort((a, b) {
//         final timestampA = a['timestamp'] as Timestamp?;
//         final timestampB = b['timestamp'] as Timestamp?;
//         return timestampA?.compareTo(timestampB ?? Timestamp.now()) ?? 0;
//       });
//       return allChats;
//     });
//   }

//   Future<String?> _fetchUsername() async {
//     try {
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.userId)
//           .get();
//       return userDoc.data()?['username'] as String?;
//     } catch (e) {
//       print('Error fetching username: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F7FA),
//       body: Column(
//         children: [
//           _buildAppBar(),
//           Expanded(child: _buildChatList()),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           SizedBox(width: 8),
//           FutureBuilder<String?>(
//             future: _fetchUsername(),
//             builder: (context, snapshot) {
//               return Text(
//                 snapshot.data ?? 'Chat',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatList() {
//     return StreamBuilder<List<Map<String, dynamic>>>(
//       stream: _getMessages(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//               child: CircularProgressIndicator(color: Color(0xFF2196F3)));
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//             child: Text(
//               'No messages yet.',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//           );
//         }

//         final messages = snapshot.data!;
//         return ListView.builder(
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(vertical: 8),
//           itemCount: (messages.length),
//           itemBuilder: (itemBuilder, index) {
//             final message = messages[index];
//             final isDriverMessage = message['collection'] == 'driverChats';
//             final timestamp = (message['timestamp'] as Timestamp?)?.toDate();

//             return Padding(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               child: Align(
//                 alignment: isDriverMessage
//                     ? Alignment.centerRight
//                     : Alignment.centerLeft,
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.75,
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   decoration: BoxDecoration(
//                     color:
//                         isDriverMessage ? Color(0xFF2196F3) : Color(0xFFFFFFFF),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20),
//                       bottomLeft: isDriverMessage
//                           ? Radius.circular(20)
//                           : Radius.circular(0),
//                       bottomRight: isDriverMessage
//                           ? Radius.circular(0)
//                           : Radius.circular(20),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 6,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         message['message'],
//                         style: TextStyle(
//                           color:
//                               isDriverMessage ? Colors.white : Colors.black87,
//                           fontSize: 16,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         timestamp != null
//                             ? _formatTimestamp(timestamp)
//                             : 'Sending...',
//                         style: TextStyle(
//                           color: isDriverMessage
//                               ? Colors.white70
//                               : Colors.grey[600],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildMessageInput() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 4,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Color(0xFFF1F3F5),
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               child: TextField(
//                 controller: messageController,
//                 focusNode: _focusNode,
//                 minLines: 1,
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   hintText: 'Type a message...',
//                   hintStyle: TextStyle(color: Colors.grey[600]),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 onSubmitted: (_) => _sendMessage(),
//               ),
//             ),
//           ),
//           SizedBox(width: 8),
//           Material(
//             color: Color(0xFF2196F3),
//             borderRadius: BorderRadius.circular(20),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(20),
//               onTap: _sendMessage,
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 child: Icon(Icons.send, color: Colors.white, size: 24),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);
//     if (difference.inDays == 0) {
//       return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
//     } else {
//       return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
//     }
//   }

//   TextStyle textStyle({
//     Color? color,
//     double? size,
//     FontWeight? weight,
//   }) {
//     return TextStyle(
//       color: color ?? Colors.black,
//       fontSize: size ?? 16,
//       fontWeight: weight ?? FontWeight.normal,
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DriverChatDisplayPage extends StatefulWidget {
  final String driverId;
  final String tripId;
  final String userId;

  const DriverChatDisplayPage({
    super.key,
    required this.driverId,
    required this.tripId,
    required this.userId,
  });

  @override
  _DriverChatDisplayPageState createState() => _DriverChatDisplayPageState();
}

class _DriverChatDisplayPageState extends State<DriverChatDisplayPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      final message = messageController.text.trim();
      final timestamp = FieldValue.serverTimestamp();

      try {
        await FirebaseFirestore.instance.collection('driverChats').add({
          'driverId': widget.driverId,
          'tripId': widget.tripId,
          'userId': widget.userId,
          'message': message,
          'timestamp': timestamp,
        });

        messageController.clear();
        _scrollToBottom();
        _focusNode.requestFocus();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Stream<List<Map<String, dynamic>>> _getMessages() {
    final userChatsStream = FirebaseFirestore.instance
        .collection('userChats')
        .where('tripId', isEqualTo: widget.tripId)
        .where('userId', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'collection': 'userChats'})
            .toList());

    final driverChatsStream = FirebaseFirestore.instance
        .collection('driverChats')
        .where('tripId', isEqualTo: widget.tripId)
        .where('userId', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'collection': 'driverChats'})
            .toList());

    return Rx.combineLatest2(userChatsStream, driverChatsStream,
        (List<Map<String, dynamic>> userChats,
            List<Map<String, dynamic>> driverChats) {
      final allChats = [...userChats, ...driverChats];
      allChats.sort((a, b) {
        final timestampA = a['timestamp'] as Timestamp?;
        final timestampB = b['timestamp'] as Timestamp?;
        return timestampA?.compareTo(timestampB ?? Timestamp.now()) ?? 0;
      });
      return allChats;
    });
  }

  Future<String?> _fetchUsername() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      return userDoc.data()?['username'] as String?;
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // colors: [Color(0xFFE6F0FA), Color(0xFFB3E5FC)],
            colors: [Color(0xFFE6F0FA), Color(0xffD5E0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildChatList()),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8),
          FutureBuilder<String?>(
            future: _fetchUsername(),
            builder: (context, snapshot) {
              return Row(
                children: [
                  // CircleAvatar(
                  //   backgroundImage: AssetImage(
                  //       'assets/logo.jpg'), // Replace with actual image URL
                  //   radius: 20,
                  // ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF42A5F5), // Blue background
                    child: FutureBuilder<String?>(
                      future: _fetchUsername(),
                      builder: (context, snapshot) {
                        final username = snapshot.data ?? 'Driver';
                        final firstLetter = username.isNotEmpty
                            ? username[0].toUpperCase()
                            : 'D';
                        return Text(
                          firstLetter,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data ?? 'Driver',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Passenger',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Color(0xFF42A5F5)));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('No messages yet.',
                  style: TextStyle(color: Colors.black54)));
        }

        final messages = snapshot.data!;
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isDriverMessage = message['collection'] == 'driverChats';
            final timestamp = (message['timestamp'] as Timestamp?)?.toDate();

            return Align(
              alignment: isDriverMessage
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDriverMessage ? Color(0xFF42A5F5) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message['message'],
                  style: TextStyle(
                    color: isDriverMessage ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Write a message',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Color(0xFF42A5F5),
            radius: 20,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
