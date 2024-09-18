
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';

// class DriverChatDisplayPage extends StatefulWidget {
//   final String driverId;
//   final String tripId;
//   final String userId;

//   DriverChatDisplayPage({
//     required this.driverId,
//     required this.tripId,
//     required this.userId,
//   });

//   @override
//   _DriverChatDisplayPageState createState() => _DriverChatDisplayPageState();
// }

// class _DriverChatDisplayPageState extends State<DriverChatDisplayPage> {
//   final TextEditingController messageController = TextEditingController();

//   Future<void> _sendMessage() async {
//     if (messageController.text.isNotEmpty) {
//       final message = messageController.text;
//       final timestamp = FieldValue.serverTimestamp();

//       try {
//         // Send message to driverChats collection
//         await FirebaseFirestore.instance.collection('driverChats').add({
//           'driverId': widget.driverId,
//           'tripId': widget.tripId,
//           'userId': widget.userId,
//           'message': message,
//           'timestamp': timestamp,
//         });

//         // Clear the text field
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
//           return snapshot.docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             data['collection'] = 'userChats';
//             return data;
//           }).toList();
//         });

//     final driverChatsStream = FirebaseFirestore.instance
//         .collection('driverChats')
//         .where('tripId', isEqualTo: widget.tripId)
//         .where('userId', isEqualTo: widget.userId)
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             data['collection'] = 'driverChats';
//             return data;
//           }).toList();
//         });

//     return Rx.combineLatest2(userChatsStream, driverChatsStream, (userChats, driverChats) {
//       List<Map<String, dynamic>> allChats = [];
//       allChats.addAll(userChats);
//       allChats.addAll(driverChats);
//       allChats.sort((a, b) {
//         final timestampA = a['timestamp'] as Timestamp?;
//         final timestampB = b['timestamp'] as Timestamp?;
//         if (timestampA == null || timestampB == null) {
//           return 0; // Handle cases where timestamp might be null
//         }
//         return timestampA.compareTo(timestampB);
//       });
//       return allChats;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: _getMessages(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('No messages.'));
//                 }

//                 List<Map<String, dynamic>> messages = snapshot.data!;

//                 return ListView.builder(
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final chatData = messages[index];
//                     final isDriverMessage = chatData['collection'] == 'driverChats';

//                     return Align(
//                       alignment: isDriverMessage ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
//                         child: Card(
//                           color: isDriverMessage ? Colors.green[100] : Colors.blue[100],
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
//                                     color: isDriverMessage ? Colors.black87 : Colors.black,
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
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     minLines: 1,
//                     maxLines: null,
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
//                   onPressed: _sendMessage,
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
import 'package:rxdart/rxdart.dart';

class DriverChatDisplayPage extends StatefulWidget {
  final String driverId;
  final String tripId;
  final String userId;

  DriverChatDisplayPage({
    required this.driverId,
    required this.tripId,
    required this.userId,
  });

  @override
  _DriverChatDisplayPageState createState() => _DriverChatDisplayPageState();
}

class _DriverChatDisplayPageState extends State<DriverChatDisplayPage> {
  final TextEditingController messageController = TextEditingController();

  Future<void> _sendMessage() async {
    if (messageController.text.isNotEmpty) {
      final message = messageController.text;
      final timestamp = FieldValue.serverTimestamp();

      try {
        // Send message to driverChats collection
        await FirebaseFirestore.instance.collection('driverChats').add({
          'driverId': widget.driverId,
          'tripId': widget.tripId,
          'userId': widget.userId,
          'message': message,
          'timestamp': timestamp,
        });

        // Clear the text field
        messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Stream<List<Map<String, dynamic>>> _getMessages() {
    final userChatsStream = FirebaseFirestore.instance
        .collection('userChats')
        .where('tripId', isEqualTo: widget.tripId)
        .where('userId', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['collection'] = 'userChats';
            return data;
          }).toList();
        });

    final driverChatsStream = FirebaseFirestore.instance
        .collection('driverChats')
        .where('tripId', isEqualTo: widget.tripId)
        .where('userId', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['collection'] = 'driverChats';
            return data;
          }).toList();
        });

    return Rx.combineLatest2(userChatsStream, driverChatsStream, (userChats, driverChats) {
      List<Map<String, dynamic>> allChats = [];
      allChats.addAll(userChats);
      allChats.addAll(driverChats);
      allChats.sort((a, b) {
        final timestampA = a['timestamp'] as Timestamp?;
        final timestampB = b['timestamp'] as Timestamp?;
        if (timestampA == null || timestampB == null) {
          return 0; // Handle cases where timestamp might be null
        }
        return timestampA.compareTo(timestampB);
      });
      return allChats;
    });
  }

 Future<String?> _fetchUsername() async {
  try {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    
    // Safely cast the data to a Map<String, dynamic>
    final data = userDoc.data() as Map<String, dynamic>?;
    
    // Check if data is not null and retrieve the username
    return data?['username'] as String?;
  } catch (e) {
    print('Error fetching username: $e');
    return null;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: _fetchUsername(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Chat'); // Fallback text while loading
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Text('Chat'); // Fallback text if there's an error
            }
            return Text('Chat with ${snapshot.data}');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
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

                List<Map<String, dynamic>> messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final chatData = messages[index];
                    final isDriverMessage = chatData['collection'] == 'driverChats';

                    return Align(
                      alignment: isDriverMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                        child: Card(
                          color: isDriverMessage ? Colors.green[100] : Colors.blue[100],
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
                                    color: isDriverMessage ? Colors.black87 : Colors.black,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: null,
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
                  color: Colors.greenAccent,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
