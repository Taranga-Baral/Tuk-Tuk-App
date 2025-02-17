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
        final data = doc.data();
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
      resizeToAvoidBottomInset:
          true, // Ensure the layout adjusts for the keyboard
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: FutureBuilder<String?>(
                      future: _fetchUsername(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Chat'); // Fallback text while loading
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text(
                              'Chat'); // Fallback text if there's an error
                        }
                        return Text(
                          'Passenger : ${snapshot.data}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                    background: ClipPath(
                      clipper: _CurvedAppBarClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(226, 255, 199, 199)!,
                              Colors.red[400]!
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: Colors.red[400],
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _getMessages(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No messages.'));
                          }

                          List<Map<String, dynamic>> messages = snapshot.data!;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final chatData = messages[index];
                              final isDriverMessage =
                                  chatData['collection'] == 'driverChats';

                              return Align(
                                alignment: isDriverMessage
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 6.0, horizontal: 10.0),
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isDriverMessage
                                        ? Colors.red[100]
                                        : Colors.blue[100],
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
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chatData['message'],
                                        style: TextStyle(
                                            color: isDriverMessage
                                                ? Colors.black87
                                                : Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: isDriverMessage
                                                ? FontWeight.w400
                                                : FontWeight.w500),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        chatData['timestamp'] != null
                                            ? chatData['timestamp']
                                                .toDate()
                                                .toString()
                                            : 'Sending...',
                                        style: TextStyle(
                                          color: isDriverMessage
                                              ? Colors.grey[700]
                                              : Colors.grey[700],
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
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ],
            ),
          ),
          // Bottom input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                        ),
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
                    color: Colors.red[400],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
