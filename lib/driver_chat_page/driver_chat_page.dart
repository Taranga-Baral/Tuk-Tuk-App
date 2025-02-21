import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
import 'package:final_menu/driver_chat_page/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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
          .limit(pageSize * 2) // Fetch more to account for duplicates
          .get();

      // Filter to keep only the latest message for each tripId
      Map<String, QueryDocumentSnapshot> uniqueTrips = {};
      for (var doc in querySnapshot.docs) {
        var chatData = doc.data() as Map<String, dynamic>;
        String tripId = chatData['tripId'];
        DateTime timestamp = chatData['timestamp'].toDate();

        if (!uniqueTrips.containsKey(tripId)) {
          uniqueTrips[tripId] = doc;
        }

        // Stop once we have 10 unique trips
        if (uniqueTrips.length >= pageSize) {
          break;
        }
      }

      setState(() {
        allDocuments = uniqueTrips.values.toList();
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
          .limit(pageSize * 2) // Fetch more to account for duplicates
          .get();

      // Filter to keep only the latest message for each tripId
      Map<String, QueryDocumentSnapshot> uniqueTrips = {};
      for (var doc in querySnapshot.docs) {
        var chatData = doc.data() as Map<String, dynamic>;
        String tripId = chatData['tripId'];
        DateTime timestamp = chatData['timestamp'].toDate();

        if (!uniqueTrips.containsKey(tripId)) {
          uniqueTrips[tripId] = doc;
        }

        // Stop once we have 10 unique trips
        if (uniqueTrips.length >= pageSize) {
          break;
        }
      }

      setState(() {
        allDocuments.addAll(uniqueTrips.values.toList());
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

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100.withOpacity(0.16),
      appBar: CustomAppBar(
        appBarColor: Colors.teal,
        appBarIcons: const [
          Icons.chat,
          Icons.info_outline,
        ],
        title: 'Passenger Chat',
        driverId: widget.driverId,
      ),
      body: allDocuments.isEmpty
          ? Center(
              child: Image(
              image: AssetImage('assets/no_data_found.gif'),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
            ))
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: AnimationLimiter(
                child: NotificationListener<ScrollNotification>(
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
                          child: Image(
                            image: AssetImage('assets/loading_screen.gif'),
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.3,
                          ),
                        );
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
                              margin: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    color: Colors.grey,
                                                    width: 120,
                                                  ),
                                                  SizedBox(
                                                    width: 50,
                                                  ),
                                                  Container(
                                                    height: 10,
                                                    color: Colors.grey,
                                                    width: 50,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                height: 10,
                                                width: 80,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),

                                              Container(
                                                height: 10,
                                                color: Colors.grey,
                                                width: 50,
                                              ),

                                              //end
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          if (detailsSnapshot.hasError) {
                            return Card(
                              elevation: 1,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
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

                          return ChatCard(
                            userId: userId,
                            tripId: tripId,
                            driverId: widget.driverId,
                            message: 'Passenger : ${chatData['message']}',
                            username: userDetails!['username'],
                            timestamp:
                                chatData['timestamp'].toDate().toString(),
                            pickupLocation: tripDetails!['pickupLocation'],
                            deliveryLocation: tripDetails['pickupLocation'],
                            distance: tripDetails['distance'],
                            fare: tripDetails['fare'],
                            phone: tripDetails['phone'],
                          );
                          // return Card(
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(
                          //         12.0), // Rounded corners
                          //   ),
                          //   elevation: 0,
                          //   margin: EdgeInsets.symmetric(
                          //       vertical: 8, horizontal: 16),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(16.0),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceBetween,
                          //           children: [
                          //             Flexible(
                          //               child: Column(
                          //                 crossAxisAlignment:
                          //                     CrossAxisAlignment.start,
                          //                 children: [
                          //                   SizedBox(height: 8),
                          //                   if (userDetails != null) ...[
                          //                     Row(
                          //                       mainAxisAlignment:
                          //                           MainAxisAlignment
                          //                               .spaceBetween,
                          //                       children: [
                          //                         Text(
                          //                           '${userDetails['username']}',
                          //                           style: GoogleFonts.outfit(
                          //                             fontSize: 16,
                          //                             fontWeight:
                          //                                 FontWeight.bold,
                          //                             color: Colors.teal[800],
                          //                           ),
                          //                         ),
                          //                         Text(
                          //                           '... ${index + 1}',
                          //                           style: TextStyle(
                          //                               color: Colors.black87,
                          //                               fontWeight:
                          //                                   FontWeight.w500),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     SizedBox(height: 4),
                          //                     Text(
                          //                       '${userDetails['phone_number']}',
                          //                       style: GoogleFonts.comicNeue(
                          //                         fontSize: 14,
                          //                         color: Colors.grey[700],
                          //                       ),
                          //                     ),
                          //                   ] else
                          //                     Text(
                          //                       'User details not available',
                          //                       style: TextStyle(
                          //                         color: Colors.redAccent,
                          //                         fontStyle: FontStyle.italic,
                          //                       ),
                          //                     ),
                          //                   SizedBox(height: 12),
                          //                   if (tripDetails != null) ...[
                          //                     Row(
                          //                       children: [
                          //                         Icon(
                          //                           Icons.location_on,
                          //                           color: Colors.green,
                          //                         ),
                          //                         SizedBox(
                          //                           width: 10,
                          //                         ),
                          //                         Expanded(
                          //                           child: Text(
                          //                             '${tripDetails['pickupLocation']}',
                          //                             style:
                          //                                 GoogleFonts.comicNeue(
                          //                               fontSize: 14,
                          //                               color: Colors.black87,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     SizedBox(height: 4),
                          //                     Row(
                          //                       children: [
                          //                         Icon(
                          //                           Icons.location_on,
                          //                           color: Colors.red,
                          //                         ),
                          //                         SizedBox(
                          //                           width: 10,
                          //                         ),
                          //                         Expanded(
                          //                           child: Text(
                          //                             '${tripDetails['deliveryLocation']}',
                          //                             style:
                          //                                 GoogleFonts.comicNeue(
                          //                               fontSize: 14,
                          //                               color: Colors.black87,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     SizedBox(height: 4),
                          //                     Row(
                          //                       children: [
                          //                         Icon(
                          //                           Icons.linear_scale_rounded,
                          //                           color: Colors.teal,
                          //                         ),
                          //                         SizedBox(
                          //                           width: 10,
                          //                         ),
                          //                         Expanded(
                          //                           child: Text(
                          //                             '${double.tryParse(tripDetails['distance'])?.toStringAsFixed(2)} km',
                          //                             style:
                          //                                 GoogleFonts.comicNeue(
                          //                               fontSize: 14,
                          //                               color: Colors.black87,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     SizedBox(height: 4),
                          //                     Row(
                          //                       children: [
                          //                         Icon(
                          //                           Icons.money,
                          //                           color: Colors.blueAccent,
                          //                         ),
                          //                         SizedBox(
                          //                           width: 10,
                          //                         ),
                          //                         Expanded(
                          //                           child: Text(
                          //                             'NPR ${tripDetails['fare']}',
                          //                             style:
                          //                                 GoogleFonts.comicNeue(
                          //                               fontSize: 14,
                          //                               color: Colors.black87,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     SizedBox(height: 4),
                          //                     Row(
                          //                       children: [
                          //                         Icon(
                          //                           Icons.call_end,
                          //                           color: Colors.amber,
                          //                         ),
                          //                         SizedBox(
                          //                           width: 10,
                          //                         ),
                          //                         Expanded(
                          //                           child: Text(
                          //                             '${tripDetails['phone']}',
                          //                             style:
                          //                                 GoogleFonts.comicNeue(
                          //                               fontSize: 14,
                          //                               color: Colors.black87,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   ] else
                          //                     Text(
                          //                       'Trip details not available',
                          //                       style: TextStyle(
                          //                         color: Colors.redAccent,
                          //                         fontStyle: FontStyle.italic,
                          //                       ),
                          //                     ),
                          //                   SizedBox(height: 16),
                          //                   Text(
                          //                     chatData['message']
                          //                                 .toString()
                          //                                 .length <
                          //                             16
                          //                         ? 'Latest Message: ${chatData['message']}'
                          //                         : 'Latest Message: ${chatData['message'].toString().substring(0, 15)}...',
                          //                     style: TextStyle(
                          //                       fontSize: 14,
                          //                       color: Colors.red,
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: 8),
                          //                   Text(
                          //                     'Timestamp: ${chatData['timestamp'] != null ? chatData['timestamp'].toDate().toString() : 'Unknown'}',
                          //                     style: TextStyle(
                          //                       fontSize: 12,
                          //                       color: Colors.grey,
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //                           Column(
                          //                             children: [
                          //                               IconButton(
                          //               onPressed: () {
                          //                 Navigator.push(
                          //                   context,
                          //                   PageRouteBuilder(
                          //                     pageBuilder: (context,
                          //                             animation,
                          //                             secondaryAnimation) =>
                          //                         DriverChatDisplayPage(
                          //                       driverId: widget.driverId,
                          //                       tripId: tripId,
                          //                       userId: userId,
                          //                     ),
                          //                     transitionsBuilder: (context,
                          //                         animation,
                          //                         secondaryAnimation,
                          //                         child) {
                          //                       const begin = Offset(1.0,
                          //                           0.0); // Slide in from the right
                          //                       const end = Offset.zero;
                          //                       const curve =
                          //                           Curves.decelerate;

                          //                       var tween = Tween(
                          //                               begin: begin,
                          //                               end: end)
                          //                           .chain(CurveTween(
                          //                               curve: curve));
                          //                       var offsetAnimation =
                          //                           animation.drive(tween);

                          //                       return SlideTransition(
                          //                         position: offsetAnimation,
                          //                         child: child,
                          //                       );
                          //                     },
                          //                   ),
                          //                 );
                          //                                 },
                          //                                 icon: Icon(Icons.chat,
                          //                                     color:
                          //                                         Colors.redAccent.shade100),
                          //                                 tooltip: 'Chat with Passenger',
                          //                               ),
                          // IconButton(
                          //   onPressed: () {
                          //     launchPhoneCall() async {
                          //       final url =
                          //           'tel:${tripDetails?['phone']}';
                          //       // ignore: deprecated_member_use
                          //       if (await canLaunch(url)) {
                          //         // ignore: deprecated_member_use
                          //         await launch(url);
                          //       } else {
                          //         throw 'Could not launch $url';
                          //       }
                          //     }

                          //     launchPhoneCall();
                          //   },
                          //   icon: Icon(Icons.phone,
                          //       color: Colors.green.shade400),
                          //   tooltip: 'Call Passenger',
                          // ),
                          //                             ],
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               );
                        },
                      );
                    },
                  ),
                ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//chat widget

class ChatCard extends StatefulWidget {
  final String username;
  final String message;
  final String timestamp;
  final String pickupLocation;
  final String deliveryLocation;
  final String phone;
  final String distance;
  final String fare;
  final String driverId;
  final String tripId;
  final String userId;

  const ChatCard({
    super.key,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.phone,
    required this.distance,
    required this.fare,
    required this.driverId,
    required this.tripId,
    required this.userId,
  });

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  double _dragOffset = 0.0;
  bool _showPopup = false;
  bool _isExpanded = false; // Track if the card is expanded

  void _onTap() {
    setState(() {
      if (_dragOffset == -160) {
        // If the card is already swiped, reset it
        _dragOffset = 0.0;
        _showPopup = false;
      } else {
        _isExpanded = !_isExpanded; // Toggle expansion state
      }
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      if (_dragOffset < -160) {
        // Set the scroll distance to 160 pixels
        _dragOffset = -160; // Limit swipe distance to 160 pixels
        _showPopup = true; // Show popup when swiped beyond the threshold
      } else if (_dragOffset > 0) {
        _dragOffset = 0; // Prevent swiping to the right
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset > -160) {
      // Check if the swipe distance is less than 160 pixels
      setState(() {
        _dragOffset =
            0.0; // Return to the original position if not swiped enough
        _showPopup = false;
      });
    }
  }

  void _resetCard() {
    setState(() {
      _dragOffset = 0.0;
      _showPopup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DriverChatDisplayPage(
                    driverId: widget.driverId,
                    tripId: widget.tripId,
                    userId: widget.userId)));
      },
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // Card Content
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: Column(
              children: [
                Card(
                  elevation: 0,
                  color: Colors.transparent,
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Avatar with first letter
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade500,
                          radius: 24,
                          child: Text(
                            widget.username.isNotEmpty
                                ? widget.username[0].toUpperCase()
                                : '?', // Fallback for empty username
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Message and timestamp
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.username,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.blueGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    widget.timestamp,
                                    style: GoogleFonts.comicNeue(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.message,
                                style: GoogleFonts.comicNeue(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    // color: Colors.grey.shade700,
                                    color: Colors.black54),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Divider(),
                ),
              ],
            ),
          ),

          if (_showPopup)
            Positioned(
              right: 14,
              top: 0,
              bottom: 0,
              child: Container(
                width:
                    MediaQuery.of(context).size.width * 0.4, // Responsive width
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Make the row scrollable
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Prevent overflow
                    children: [
                      IconButton(
                        icon: Icon(Icons.info,
                            color: Colors.blueGrey,
                            size: 24), // Smaller icon size
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  'Order Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow(Icons.location_on,
                                        'Pickup: ${widget.pickupLocation}'),
                                    SizedBox(height: 12),
                                    _buildDetailRow(Icons.location_on,
                                        'Delivery: ${widget.deliveryLocation}'),
                                    SizedBox(height: 12),
                                    _buildDetailRow(Icons.directions_car,
                                        'Distance: ${double.parse(widget.distance).toStringAsFixed(2)}'),
                                    SizedBox(height: 12),
                                    _buildDetailRow(
                                        Icons.money, 'Fare: ${widget.fare}'),
                                    SizedBox(height: 12),
                                    _buildDetailRow(
                                        Icons.phone, 'Phone: ${widget.phone}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _resetCard();
                                    },
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      DriverChatDisplayPage(
                                driverId: widget.driverId,
                                tripId: widget.tripId,
                                userId: widget.userId,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin =
                                    Offset(1.0, 0.0); // Slide in from the right
                                const end = Offset.zero;
                                const curve = Curves.decelerate;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.chat,
                          color: Colors.blueGrey,
                          size: 24, // Smaller icon size
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          launchPhoneCall() async {
                            final url = 'tel:${widget.phone}';
                            // ignore: deprecated_member_use
                            if (await canLaunch(url)) {
                              // ignore: deprecated_member_use
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          }

                          launchPhoneCall();
                        },
                        icon: Icon(
                          Icons.phone, // Corrected icon
                          color: Colors.blueGrey,
                          size: 24, // Smaller icon size
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // if (_showPopup)
          //   Expanded(
          //     child: Positioned(
          //       right: 14,
          //       top: 0,
          //       bottom: 0,
          //       child: Container(
          //         width: 100,
          //         decoration: BoxDecoration(
          //           color: Colors.transparent,
          //           borderRadius: BorderRadius.circular(16),
          //         ),
          //         alignment: Alignment.center,
          //         child: Row(
          //           children: [
          //             IconButton(
          //               icon:
          //                   Icon(Icons.info, color: Colors.redAccent, size: 30),
          //               onPressed: () {
          //                 showDialog(
          //                   context: context,
          //                   builder: (context) {
          //                     return AlertDialog(
          //                       title: Text(
          //                         "Order Details",
          //                         style: TextStyle(
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 20,
          //                           color: Colors.blueAccent,
          //                         ),
          //                       ),
          //                       content: Column(
          //                         mainAxisSize: MainAxisSize.min,
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           _buildDetailRow(Icons.location_on,
          //                               "Pickup: ${widget.pickupLocation}"),
          //                           SizedBox(height: 12),
          //                           _buildDetailRow(Icons.location_on,
          //                               "Delivery: ${widget.deliveryLocation}"),
          //                           SizedBox(height: 12),
          //                           _buildDetailRow(Icons.directions_car,
          //                               "Distance: ${double.parse(widget.distance).toStringAsFixed(2)}"),
          //                           SizedBox(height: 12),
          //                           _buildDetailRow(
          //                               Icons.money, "Fare: ${widget.fare}"),
          //                           SizedBox(height: 12),
          //                           _buildDetailRow(
          //                               Icons.phone, "Phone: ${widget.phone}"),
          //                         ],
          //                       ),
          //                       actions: [
          //                         TextButton(
          //                           onPressed: () {
          //                             Navigator.pop(context);
          //                             _resetCard();
          //                           },
          //                           child: Text(
          //                             "Close",
          //                             style: TextStyle(
          //                               color: Colors.redAccent,
          //                               fontWeight: FontWeight.bold,
          //                               fontSize: 16,
          //                             ),
          //                           ),
          //                         ),
          //                       ],
          //                     );
          //                   },
          //                 );
          //               },
          //             ),
          //             IconButton(
          //               onPressed: () {
          //                 Navigator.push(
          //                   context,
          //                   PageRouteBuilder(
          //                     pageBuilder:
          //                         (context, animation, secondaryAnimation) =>
          //                             DriverChatDisplayPage(
          //                       driverId: widget.driverId,
          //                       tripId: widget.tripId,
          //                       userId: widget.userId,
          //                     ),
          //                     transitionsBuilder: (context, animation,
          //                         secondaryAnimation, child) {
          //                       const begin =
          //                           Offset(1.0, 0.0); // Slide in from the right
          //                       const end = Offset.zero;
          //                       const curve = Curves.decelerate;

          //                       var tween = Tween(begin: begin, end: end)
          //                           .chain(CurveTween(curve: curve));
          //                       var offsetAnimation = animation.drive(tween);

          //                       return SlideTransition(
          //                         position: offsetAnimation,
          //                         child: child,
          //                       );
          //                     },
          //                   ),
          //                 );
          //               },
          //               icon: Icon(
          //                 Icons.chat,
          //                 color: Colors.blueAccent,
          //               ),
          //             ),
          //             IconButton(
          //               onPressed: () {
          //                 launchPhoneCall() async {
          //                   final url = 'tel:${widget.phone}';
          //                   // ignore: deprecated_member_use
          //                   if (await canLaunch(url)) {
          //                     // ignore: deprecated_member_use
          //                     await launch(url);
          //                   } else {
          //                     throw 'Could not launch $url';
          //                   }
          //                 }

          //                 launchPhoneCall();
          //               },
          //               icon: Icon(
          //                 Icons.chat,
          //                 color: Colors.amber,
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

Widget _buildDetailRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.blueGrey[600]),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey[800],
          ),
        ),
      ),
    ],
  );
}
