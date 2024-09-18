
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class DriverChatPage extends StatelessWidget {
//   final String driverId;

//   DriverChatPage({required this.driverId});

//   Future<Map<String, dynamic>?> fetchTripDetails(String tripId) async {
//     final tripSnapshot =
//         await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
//     return tripSnapshot.data();
//   }

//   Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
//     final userSnapshot =
//         await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     return userSnapshot.data();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Chat for $driverId'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('userChats')
//             .where('driverId', isEqualTo: driverId)
//             .orderBy('timestamp', descending: true) // Sort by latest message
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No chats available.'));
//           }

//           // Grouping messages by tripId and userId
//           Map<String, Map<String, QueryDocumentSnapshot>> groupedMessages = {};

//           for (var doc in snapshot.data!.docs) {
//             var chatData = doc.data() as Map<String, dynamic>;
//             String tripId = chatData['tripId'];
//             String userId = chatData['userId'];

//             // Create a unique key for each tripId + userId combination
//             String key = '${tripId}_$userId';

//             // Keep only the latest message for each group (since we ordered by timestamp)
//             if (!groupedMessages.containsKey(tripId)) {
//               groupedMessages[tripId] = {};
//             }

//             if (!groupedMessages[tripId]!.containsKey(userId)) {
//               groupedMessages[tripId]![userId] = doc;
//             }
//           }

//           return ListView.builder(
//             itemCount: groupedMessages.length,
//             itemBuilder: (context, index) {
//               var tripId = groupedMessages.keys.elementAt(index);
//               var userChats = groupedMessages[tripId]!;

//               var latestChatDoc = userChats.values.first; // Latest chat message
//               var chatData = latestChatDoc.data() as Map<String, dynamic>;
//               String userId = chatData['userId'];

//               return FutureBuilder(
//                 future: Future.wait([
//                   fetchTripDetails(tripId),
//                   fetchUserDetails(userId),
//                 ]),
//                 builder: (context, AsyncSnapshot<List<dynamic>> detailsSnapshot) {
//                   if (detailsSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return Card(
//                       elevation: 5,
//                       margin:
//                           EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       ),
//                     );
//                   }

//                   if (detailsSnapshot.hasError) {
//                     return Card(
//                       elevation: 5,
//                       margin:
//                           EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Text('Error loading details'),
//                       ),
//                     );
//                   }

//                   final tripDetails = detailsSnapshot.data![0] as Map<String, dynamic>?;
//                   final userDetails = detailsSnapshot.data![1] as Map<String, dynamic>?;

//                   return Card(
//                     elevation: 5,
//                     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (tripDetails != null) ...[
//                             Text('Pickup Location: ${tripDetails['pickupLocation']}'),
//                             Text('Delivery Location: ${tripDetails['deliveryLocation']}'),
//                             Text('Distance: ${tripDetails['distance']} km'),
//                             Text('Fare: \$${tripDetails['fare']}'),
//                           ] else
//                             Text('Trip details not available'),
//                           SizedBox(height: 8),
//                           if (userDetails != null) ...[
//                             Text('User: ${userDetails['username']}'),
//                             Text('Phone: ${userDetails['phone_number']}'),
//                           ] else
//                             Text('User details not available'),
//                           SizedBox(height: 8),
//                           Text('Latest Message: ${chatData['message']}'),
//                           SizedBox(height: 8),
//                           Text(
//                             'Timestamp: ${chatData['timestamp'] != null ? chatData['timestamp'].toDate().toString() : 'Unknown'}',
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/chat/chat_display_page.dart';
import 'package:final_menu/driver_chat_page/chat_detail_page.dart';
import 'package:flutter/material.dart';

class DriverChatPage extends StatelessWidget {
  final String driverId;

  DriverChatPage({required this.driverId});

  Future<Map<String, dynamic>?> fetchTripDetails(String tripId) async {
    final tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    return tripSnapshot.data();
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userSnapshot.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Chat for $driverId'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userChats')
            .where('driverId', isEqualTo: driverId)
            .orderBy('timestamp', descending: true) // Sort by latest message
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chats available.'));
          }

          // Grouping messages by tripId and userId
          Map<String, Map<String, QueryDocumentSnapshot>> groupedMessages = {};

          for (var doc in snapshot.data!.docs) {
            var chatData = doc.data() as Map<String, dynamic>;
            String tripId = chatData['tripId'];
            String userId = chatData['userId'];

            // Create a unique key for each tripId + userId combination
            String key = '${tripId}_$userId';

            // Keep only the latest message for each group (since we ordered by timestamp)
            if (!groupedMessages.containsKey(tripId)) {
              groupedMessages[tripId] = {};
            }

            if (!groupedMessages[tripId]!.containsKey(userId)) {
              groupedMessages[tripId]![userId] = doc;
            }
          }

          return ListView.builder(
            itemCount: groupedMessages.length,
            itemBuilder: (context, index) {
              var tripId = groupedMessages.keys.elementAt(index);
              var userChats = groupedMessages[tripId]!;

              var latestChatDoc = userChats.values.first; // Latest chat message
              var chatData = latestChatDoc.data() as Map<String, dynamic>;
              String userId = chatData['userId'];

              return FutureBuilder(
                future: Future.wait([
                  fetchTripDetails(tripId),
                  fetchUserDetails(userId),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> detailsSnapshot) {
                  if (detailsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Card(
                      elevation: 5,
                      margin:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  if (detailsSnapshot.hasError) {
                    return Card(
                      elevation: 5,
                      margin:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('Error loading details'),
                      ),
                    );
                  }

                  final tripDetails = detailsSnapshot.data![0] as Map<String, dynamic>?;
                  final userDetails = detailsSnapshot.data![1] as Map<String, dynamic>?;

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (userDetails != null) ...[
                            Text('User: ${userDetails['username']}'),
                            Text('Phone: ${userDetails['phone_number']}'),
                          ] else
                            Text('User details not available'),
                          if (tripDetails != null) ...[
                            Text('Pickup Location: ${tripDetails['pickupLocation']}'),
                            Text('Delivery Location: ${tripDetails['deliveryLocation']}'),
                            Text('Distance: ${tripDetails['distance']} km'),
                            Text('Fare:NPR ${tripDetails['fare']}'),
                          ] else
                            Text('Trip details not available'),
                          SizedBox(height: 8),
                          
                        ],
                      ),
                      subtitle: Text('Latest Message: ${chatData['message']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.chat),
                        onPressed: () {
                          // Navigate to ChatDetailPage with driverId, tripId, and userId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverChatDisplayPage(
                                driverId: driverId,
                                tripId: tripId,
                                userId: userId, 
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
