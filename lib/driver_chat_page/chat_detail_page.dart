import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('userChats')
                  .where('tripId', isEqualTo: widget.tripId)
                  .where('userId', isEqualTo: widget.userId)
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
                    final isUserMessage = chatData['userId'] == widget.userId;

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
                  onPressed: () async {
                    if (messageController.text.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('userChats').add({
                        'driverId': widget.driverId,
                        'tripId': widget.tripId,
                        'userId': widget.userId,
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
