import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
import 'package:final_menu/driver_chat_page/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          ? Center(
              child: Image(
              image: AssetImage('assets/no_data_found.gif'),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
            ))
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
                          elevation: 5,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Center(
                                  child: Image(
                                image: AssetImage('assets/loading_screen.gif'),
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                width: MediaQuery.of(context).size.width * 0.3,
                              ))),
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
                          borderRadius:
                              BorderRadius.circular(12.0), // Rounded corners
                        ),
                        elevation: 0,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        if (userDetails != null) ...[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${userDetails['username']}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal[800],
                                                ),
                                              ),
                                              Text(
                                                '... ${index + 1}',
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
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
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.green,
                                              ),
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
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                              ),
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
                                              Icon(
                                                Icons.linear_scale_rounded,
                                                color: Colors.teal,
                                              ),
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
                                              Icon(
                                                Icons.money,
                                                color: Colors.blueAccent,
                                              ),
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
                                              Icon(
                                                Icons.call_end,
                                                color: Colors.amber,
                                              ),
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
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  DriverChatDisplayPage(
                                                driverId: widget.driverId,
                                                tripId: tripId,
                                                userId: userId,
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0,
                                                    0.0); // Slide in from the right
                                                const end = Offset.zero;
                                                const curve = Curves.decelerate;

                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
                                                var offsetAnimation =
                                                    animation.drive(tween);

                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.chat,
                                            color: Colors.redAccent.shade100),
                                        tooltip: 'Chat with Passenger',
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          launchPhoneCall() async {
                                            final url =
                                                'tel:${tripDetails?['phone']}';
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
                                        icon: Icon(Icons.phone,
                                            color: Colors.green.shade400),
                                        tooltip: 'Call Passenger',
                                      ),
                                    ],
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
