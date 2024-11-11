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

// return Card(
//   elevation: 5,
//   margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//   child: Padding(
//     padding: const EdgeInsets.all(12.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (tripDetails != null) ...[
//           Text('Pickup Location: ${tripDetails['pickupLocation']}'),
//           Text('Delivery Location: ${tripDetails['deliveryLocation']}'),
//           Text('Distance: ${tripDetails['distance']} km'),
//           Text('Fare: \$${tripDetails['fare']}'),
//         ] else
//           Text('Trip details not available'),
//         SizedBox(height: 8),
//         if (userDetails != null) ...[
//           Text('User: ${userDetails['username']}'),
//           Text('Phone: ${userDetails['phone_number']}'),
//         ] else
//           Text('User details not available'),
//         SizedBox(height: 8),
//         Text('Latest Message: ${chatData['message']}'),
//         SizedBox(height: 8),
//         Text(
//           'Timestamp: ${chatData['timestamp'] != null ? chatData['timestamp'].toDate().toString() : 'Unknown'}',
//         ),
//       ],
//     ),
//   ),
// );
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
import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
import 'package:final_menu/driver_chat_page/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverChatPage extends StatefulWidget {
  final String driverId;

  const DriverChatPage({super.key, required this.driverId});

  @override
  _DriverChatPageState createState() => _DriverChatPageState();
}

class _DriverChatPageState extends State<DriverChatPage> {
  final int pageSize = 10;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  DocumentSnapshot? lastDocument;
  List<QueryDocumentSnapshot> allDocuments = [];

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userChats')
          .where('driverId', isEqualTo: widget.driverId)
          .orderBy('timestamp', descending: true)
          .limit(pageSize)
          .get();

      setState(() {
        allDocuments = querySnapshot.docs;
        if (querySnapshot.docs.length < pageSize) {
          hasMoreData = false; // No more data to load
        }
        if (querySnapshot.docs.isNotEmpty) {
          lastDocument = querySnapshot.docs.last;
        }
      });
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  Future<void> fetchMoreData() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userChats')
          .where('driverId', isEqualTo: widget.driverId)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(pageSize)
          .get();

      setState(() {
        allDocuments.addAll(querySnapshot.docs);
        if (querySnapshot.docs.length < pageSize) {
          hasMoreData = false; // No more data to load
        }
        if (querySnapshot.docs.isNotEmpty) {
          lastDocument = querySnapshot.docs.last;
        }
      });
    } catch (e) {
      print('Error fetching more data: $e');
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarColor: Colors.teal,
        appBarIcons: const [
          Icons.arrow_back,
          Icons.info_outline,
        ],
        title: 'View Messages',
        driverId: widget.driverId,
      ),
      body: allDocuments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !isLoadingMore) {
                  fetchMoreData(); // Load more data when scrolled to bottom
                }
                return false;
              },
              child: ListView.builder(
                itemCount: allDocuments.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == allDocuments.length) {
                    return Center(
                        child:
                            CircularProgressIndicator()); // Loading indicator
                  }

                  var chatData =
                      allDocuments[index].data() as Map<String, dynamic>;
                  String tripId = chatData['tripId'];
                  String userId = chatData['userId'];

                  return FutureBuilder(
                    future: Future.wait([
                      fetchTripDetails(tripId),
                      fetchUserDetails(userId),
                    ]),
                    builder: (context,
                        AsyncSnapshot<List<dynamic>> detailsSnapshot) {
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

                      final tripDetails =
                          detailsSnapshot.data![0] as Map<String, dynamic>?;
                      final userDetails =
                          detailsSnapshot.data![1] as Map<String, dynamic>?;

                      return Card(
                        
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0), // Rounded corners
  ),
  elevation: 0,
  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  if (userDetails != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${userDetails['username']}',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                        Text('... ${index+1}',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500),),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${userDetails['phone_number']}',
                      style: GoogleFonts.comicNeue(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ] else
                    Text(
                      'User details not available',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  SizedBox(height: 12),
                  if (tripDetails != null) ...[
                    Row(
                      children: [
                        Icon(Icons.location_on,color: Colors.red,),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            '${tripDetails['pickupLocation']}',
                            style: GoogleFonts.comicNeue(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,color: Colors.green,),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            '${tripDetails['deliveryLocation']}',
                            style: GoogleFonts.comicNeue(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.linear_scale_rounded,color: Colors.teal,),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            '${double.tryParse(tripDetails['distance'])?.toStringAsFixed(2)} km',
                            style: GoogleFonts.comicNeue(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.money,color: Colors.blueAccent,),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'NPR ${tripDetails['fare']}',
                            style: GoogleFonts.comicNeue(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),


                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.call_end,color: Colors.amber,),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            '${tripDetails['phone']}',
                            style: GoogleFonts.comicNeue(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),



                  ] else
                    Text(
                      'Trip details not available',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Latest Message: ${chatData['message']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Timestamp: ${chatData['timestamp'] != null ? chatData['timestamp'].toDate().toString() : 'Unknown'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        DriverChatDisplayPage(
                      driverId: widget.driverId,
                      tripId: tripId,
                      userId: userId,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // Slide in from the right
                      const end = Offset.zero;
                      const curve = Curves.decelerate;

                      var tween =
                          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              icon: Icon(Icons.chat, color: Colors.redAccent.shade100),
              tooltip: 'Chat with driver',
            ),
          ],
        ),
      ],
    ),
  ),
);

                    },
                  );
                },
              ),
            ),
    );
  }

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
}
