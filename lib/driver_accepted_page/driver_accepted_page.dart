import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
import 'package:final_menu/driver_chat_page/chat_detail_page.dart';
import 'package:final_menu/galli_maps/driver_view_passenger_location/driver_view_passenger_location.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverAcceptedPage extends StatefulWidget {
  final String driverId;
  const DriverAcceptedPage({
    super.key,
    required this.driverId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DriverAcceptedPageState createState() => _DriverAcceptedPageState();
}

class _DriverAcceptedPageState extends State<DriverAcceptedPage> {
  bool isExpanded = false; // State variable to track expansion
  List<QueryDocumentSnapshot> requests = [];
  bool isLoadingMore = false;
  bool hasMoreData = true;
  // bool isPerformingLoadMore = false; // Add this flag
  // DocumentSnapshot? lastDocument; // Track last loaded document
  Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()!;
    } else {
      return {'username': 'Unknown', 'phone': 'Unknown'};
    }
  }

  Future<Map<String, dynamic>> _fetchTripDetails(String tripId) async {
    final tripDoc =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    if (tripDoc.exists) {
      return tripDoc.data()!;
    } else {
      return {
        'pickupLocation': 'Unknown',
        'deliveryLocation': 'Unknown',
        'fare': '0',
        'distance': '0',
      };
    }
  }

  Future<bool> _checkNetworkStatus() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com'));
      return result.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, double>> _geocodeAddress(String address) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'latitude': double.parse(data[0]['lat']),
          'longitude': double.parse(data[0]['lon']),
        };
      }
    }
    throw Exception('Failed to geocode address');
  }

  Future<void> _launchOpenStreetMapWithDirections(
      String pickupLocation, String deliveryLocation) async {
    try {
      final pickupCoords = _parseCoordinates(pickupLocation) ??
          await _geocodeAddress(pickupLocation);
      final deliveryCoords = _parseCoordinates(deliveryLocation) ??
          await _geocodeAddress(deliveryLocation);

      final pickupLatitude = pickupCoords['latitude']!;
      final pickupLongitude = pickupCoords['longitude']!;
      final deliveryLatitude = deliveryCoords['latitude']!;
      final deliveryLongitude = deliveryCoords['longitude']!;

      final String openStreetMapUrl =
          'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

      final Uri launchUri = Uri.parse(openStreetMapUrl);

      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Could not launch $launchUri');
      }
    } catch (e) {
      print('Error fetching trip details: $e');
    }
  }

  Map<String, double>? _parseCoordinates(String location) {
    final parts = location.split(',');
    if (parts.length == 2) {
      final latitude = double.tryParse(parts[0]);
      final longitude = double.tryParse(parts[1]);
      if (latitude != null && longitude != null) {
        return {'latitude': latitude, 'longitude': longitude};
      }
    }
    return null;
  }

  Future<Map<String, bool>> _fetchButtonStates(String tripId) async {
    final buttonStateDoc = await FirebaseFirestore.instance
        .collection('tripButtonStates')
        .doc(tripId)
        .get();

    if (buttonStateDoc.exists) {
      final data = buttonStateDoc.data()!;
      return {
        'isSendButtonPressed': data['isSendButtonPressed'] ?? false,
        'isDoneButtonPressed': data['isDoneButtonPressed'] ?? false,
      };
    } else {
      return {
        'isSendButtonPressed': false, // Default to not pressed
        'isDoneButtonPressed': false, // Default to not pressed
      };
    }
  }

  Future<void> _updateButtonStates(
      String tripId, bool isSendPressed, bool isDonePressed) async {
    await FirebaseFirestore.instance
        .collection('tripButtonStates')
        .doc(tripId)
        .set({
      'isSendButtonPressed': isSendPressed,
      'isDoneButtonPressed': isDonePressed,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoadingMore = true;
    });

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('confirmedDrivers')
        .where('driverId', isEqualTo: widget.driverId)
        .orderBy('confirmedAt', descending: true)
        .get(); // Removed the .limit(30)

    setState(() {
      requests = snapshot.docs;
      isLoadingMore = false;
    });
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5, // Number of shimmer placeholders
      itemBuilder: (context, index) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Future<void> _loadMoreData() async {
  //   if (!isLoadingMore && hasMoreData) {
  //     setState(() {
  //       isLoadingMore = true;
  //     });

  //     _buildShimmerLoading();

  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('confirmedDrivers')
  //         .where('driverId', isEqualTo: widget.driverId)
  //         .orderBy('confirmedAt', descending: true)
  //         .startAfterDocument(lastDocument!) // Start after the last document
  //         .limit(30)
  //         .get();

  //     if (snapshot.docs.isNotEmpty) {
  //       requests.addAll(snapshot.docs);
  //       lastDocument = snapshot.docs.last; // Update last document
  //     } else {
  //       hasMoreData = false; // No more data available
  //     }

  //     setState(() {
  //       isLoadingMore = false;
  //     });
  //   }
  // }

  final double _maxScrollSpeed = 1.0; // Adjust as needed
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100.withOpacity(0.18),
      appBar: CustomAppBar(
        appBarColor: Colors.redAccent,
        appBarIcons: const [
          Icons.check_circle,
          Icons.info_outline,
        ],
        title: 'Accepted Requests',
        driverId: widget.driverId, // Pass the driverId
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final userId = request['userId'];
                final tripId = request['tripId'];

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait([
                    _fetchUserDetails(userId),
                    _fetchTripDetails(tripId),
                    _fetchButtonStates(tripId),
                  ]),
                  builder: (context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Image(
                          image: AssetImage('assets/loading_screen.gif'),
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                      );
                    }

                    // Error states
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red, size: 50),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load data',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            ),
                            SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Retry logic if needed
                                setState(() {});
                              },
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // No data state
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.hourglass_empty,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No trip data available',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    final userDetails = snapshot.data![0];
                    final tripDetails = snapshot.data![1];
                    final buttonStates = snapshot.data![2];
                    final isSendButtonPressed =
                        buttonStates['isSendButtonPressed'] ?? false;
                    final isDoneButtonPressed =
                        buttonStates['isDoneButtonPressed'] ?? false;

                    return isDoneButtonPressed
                        ? Container()
                        : Card(
                            color: Colors.transparent,
                            elevation: 0,
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              color: Colors.transparent,
                              elevation: 0,
                              // front: Card(
                              //   elevation: 0,
                              //   color: Colors.transparent,
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(10.0),
                              //   ),
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(16.0),
                              //     child: Column(
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: [
                              //         Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceBetween,
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Expanded(
                              //               child: Text(
                              //                 '${userDetails['username']}',
                              //                 softWrap: true,
                              //                 style: TextStyle(
                              //                   color: Colors.blueGrey,
                              //                   fontSize: 20,
                              //                   fontWeight: FontWeight.w800,
                              //                 ),
                              //               ),
                              //             ),
                              //             SizedBox(
                              //                 width:
                              //                     10), // Add spacing between texts
                              //             Expanded(
                              //               flex:
                              //                   2, // Adjust flex value to control relative width of this column
                              //               child: Column(
                              //                 crossAxisAlignment:
                              //                     CrossAxisAlignment.end,
                              //                 children: [
                              //                   Row(
                              //                     mainAxisAlignment:
                              //                         MainAxisAlignment.end,
                              //                     children: [
                              //                       Text(
                              //                         'NPR ${double.parse(tripDetails['fare']).toStringAsFixed(1)}',
                              //                         softWrap: true,
                              //                         style: TextStyle(
                              //                           color: const Color
                              //                               .fromARGB(
                              //                               155, 0, 0, 0),
                              //                           fontSize: 14,
                              //                           fontWeight:
                              //                               FontWeight.bold,
                              //                         ),
                              //                       ),
                              //                     ],
                              //                   ),
                              //                   SizedBox(height: 6),
                              //                   Text(
                              //                     '${double.parse(tripDetails['distance']).toStringAsFixed(1)} Km',
                              //                     softWrap: true,
                              //                     style: TextStyle(
                              //                       color:
                              //                           const Color.fromARGB(
                              //                               155, 0, 0, 0),
                              //                       fontSize: 14,
                              //                       fontWeight:
                              //                           FontWeight.bold,
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ],
                              //         ),

                              //         // const SizedBox(height: 2),
                              //         Text(
                              //           '${tripDetails['municipalityDropdown']}',
                              //           style: GoogleFonts.comicNeue(),
                              //         ),
                              //         const SizedBox(height: 4),
                              //         Text(
                              //           "${userDetails['phone_number']}",
                              //           style: GoogleFonts.comicNeue(),
                              //         ),

                              //         const SizedBox(height: 12),

                              //         // const SizedBox(height: 12),

                              //         Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceBetween,
                              //           children: [
                              //             InkWell(
                              //               onTap: () {
                              //                 Navigator.push(
                              //                   context,
                              //                   MaterialPageRoute(
                              //                     builder: (BuildContext
                              //                             context) =>
                              //                         DriverChatDisplayPage(
                              //                       driverId: widget.driverId,
                              //                       tripId: tripId,
                              //                       userId: userId,
                              //                     ),
                              //                   ),
                              //                 );
                              //               },
                              //               child: Icon(
                              //                 Icons.chat,
                              //                 size: 20,
                              //                 color: Colors.blueGrey,
                              //               ),
                              //             ),
                              //             InkWell(
                              //               onTap: () {
                              // final phoneNumber =
                              //     userDetails['phone_number'];
                              // if (phoneNumber != null &&
                              //     phoneNumber.isNotEmpty) {
                              //   _launchPhoneNumber(
                              //       phoneNumber);
                              // } else {
                              //   // ScaffoldMessenger.of(context)
                              //   //     .showSnackBar(
                              //   //   const SnackBar(
                              //   //     content: Text(
                              //   //         'Phone number unavailable'),
                              //   //   ),
                              //   // );

                              //   AwesomeDialog(
                              //     context: context,
                              //     dialogType:
                              //         DialogType.error,
                              //     animType: AnimType.topSlide,
                              //     body: Center(
                              //       child: Column(
                              //         children: const [
                              //           Text(
                              //             'Phone Number Invalid',
                              //             style: TextStyle(
                              //                 fontWeight:
                              //                     FontWeight
                              //                         .w500,
                              //                 fontSize: 22,
                              //                 color:
                              //                     Colors.red),
                              //           ),
                              //           SizedBox(
                              //             height: 10,
                              //           ),
                              //           Text(
                              //             'Looks like Phone Number is not Provided by the User',
                              //             style: TextStyle(
                              //                 fontWeight:
                              //                     FontWeight
                              //                         .w300,
                              //                 fontSize: 14,
                              //                 color: Colors
                              //                     .grey),
                              //           ),
                              //           SizedBox(
                              //             height: 10,
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //     btnOkColor: Colors
                              //         .deepOrange.shade500
                              //         .withOpacity(0.8),
                              //     alignment: Alignment.center,
                              //     btnOkOnPress: () {},
                              //   ).show();
                              // }
                              //               },
                              //               child: Icon(
                              //                 Icons.phone,
                              //                 size: 20,
                              //                 color: Colors.blueGrey,
                              //               ),
                              //             ),
                              //             InkWell(
                              //               onTap: () {
                              //                 // final pickupLocation =
                              //                 //     tripDetails['pickupLocation'] ??
                              //                 //         '';
                              //                 // final deliveryLocation =
                              //                 //     tripDetails['deliveryLocation'] ??
                              //                 //         '';
                              //                 // if (pickupLocation.isNotEmpty &&
                              //                 //     deliveryLocation.isNotEmpty) {
                              //                 //   _launchOpenStreetMapWithDirections(
                              //                 //       pickupLocation,
                              //                 //       deliveryLocation);
                              //                 // }
                              //                 Navigator.push(
                              //                     context,
                              //                     MaterialPageRoute(
                              //                         builder: (context) =>
                              //                             DriverViewPassengerLocation(
                              //                                 tripId:
                              //                                     tripId)));
                              //               },
                              //               child: Icon(
                              //                 Icons.location_on_rounded,
                              //                 size: 20,
                              //                 color: Colors.blueGrey
                              //                     .withOpacity(0.8),
                              //               ),
                              //             ),
                              //             isSendButtonPressed
                              //                 ? Container()
                              //                 : InkWell(
                              //                     onTap: isSendButtonPressed
                              //                         ? null
                              //                         : () async {
                              //                             final isNetworkAvailable =
                              //                                 await _checkNetworkStatus();
                              //                             if (isNetworkAvailable) {
                              //                               try {
                              //                                 await FirebaseFirestore
                              //                                     .instance
                              //                                     .collection(
                              //                                         'arrivedDrivers')
                              //                                     .add({
                              //                                   'tripId':
                              //                                       tripId,
                              //                                   'driverId': widget
                              //                                       .driverId,
                              //                                   'userId':
                              //                                       userId,
                              //                                   'timestamp':
                              //                                       FieldValue
                              //                                           .serverTimestamp(),
                              //                                 });

                              //                                 await _updateButtonStates(
                              //                                     tripId,
                              //                                     true,
                              //                                     false);

                              //                                 AwesomeDialog(
                              //                                   context:
                              //                                       context,
                              //                                   dialogType:
                              //                                       DialogType
                              //                                           .success,
                              //                                   animType: AnimType
                              //                                       .topSlide,
                              //                                   body: Center(
                              //                                     child:
                              //                                         Column(
                              //                                       children: const [
                              //                                         Text(
                              //                                           'Arrived',
                              //                                           style: TextStyle(
                              //                                               fontWeight: FontWeight.w500,
                              //                                               fontSize: 22,
                              //                                               color: Colors.green),
                              //                                         ),
                              //                                         SizedBox(
                              //                                           height:
                              //                                               10,
                              //                                         ),
                              //                                         Text(
                              //                                           'Driver Arrival Recorded. Pickup your Passenger. ',
                              //                                           style: TextStyle(
                              //                                               fontWeight: FontWeight.w300,
                              //                                               fontSize: 14,
                              //                                               color: Colors.grey),
                              //                                         ),
                              //                                         SizedBox(
                              //                                           height:
                              //                                               10,
                              //                                         ),
                              //                                       ],
                              //                                     ),
                              //                                   ),
                              //                                   btnOkColor: Colors
                              //                                       .deepOrange
                              //                                       .shade500
                              //                                       .withOpacity(
                              //                                           0.8),
                              //                                   alignment:
                              //                                       Alignment
                              //                                           .center,
                              //                                   btnOkOnPress:
                              //                                       () {},
                              //                                 ).show();

                              //                                 setState(() {});
                              //                               } catch (e) {
                              //                                 ScaffoldMessenger.of(
                              //                                         // ignore: use_build_context_synchronously
                              //                                         context)
                              //                                     .showSnackBar(
                              //                                   const SnackBar(
                              //                                       content: Text(
                              //                                           'Failed to send driver. Try again.')),
                              //                                 );
                              //                               }
                              //                             } else {
                              //                               // ignore: use_build_context_synchronously
                              //                               ScaffoldMessenger
                              //                                       .of(context)
                              //                                   .showSnackBar(
                              //                                 const SnackBar(
                              //                                     content: Text(
                              //                                         'No network connection available')),
                              //                               );
                              //                             }
                              //                           },
                              //                     // child: Icon(
                              //                     //   Icons.send,
                              //                     //   color: isSendButtonPressed
                              //                     //       ? Colors.grey
                              //                     //       : Colors.blue,
                              //                     // ),
                              //                     child: Text('आइपुगे',
                              //                         style: TextStyle(
                              //                           color:
                              //                               isSendButtonPressed
                              //                                   ? Colors.grey
                              //                                   : Colors.blue,
                              //                           fontSize: 17,
                              //                           fontWeight:
                              //                               FontWeight.bold,
                              //                         )),
                              //                   ),
                              //             InkWell(
                              //               onTap: isSendButtonPressed &&
                              //                       !isDoneButtonPressed
                              //                   ? () async {
                              //                       await _updateButtonStates(
                              //                           tripId, true, true);

                              //                       await FirebaseFirestore
                              //                           .instance
                              //                           .collection(
                              //                               'successfulTrips')
                              //                           .add({
                              //                         'tripId': tripId,
                              //                         'driverId':
                              //                             widget.driverId,
                              //                         'userId': userId,
                              //                         'timestamp': FieldValue
                              //                             .serverTimestamp(),
                              //                       });

                              //                       AwesomeDialog(
                              //                         context: context,
                              //                         dialogType:
                              //                             DialogType.success,
                              //                         animType:
                              //                             AnimType.topSlide,
                              //                         body: Center(
                              //                           child: Column(
                              //                             children: const [
                              //                               Text(
                              //                                 'Ride Master',
                              //                                 style: TextStyle(
                              //                                     fontWeight:
                              //                                         FontWeight
                              //                                             .w500,
                              //                                     fontSize:
                              //                                         22,
                              //                                     color: Colors
                              //                                         .green),
                              //                               ),
                              //                               SizedBox(
                              //                                 height: 10,
                              //                               ),
                              //                               Text(
                              //                                 'Trips Added to your Collection.',
                              //                                 style: TextStyle(
                              //                                     fontWeight:
                              //                                         FontWeight
                              //                                             .w300,
                              //                                     fontSize:
                              //                                         14,
                              //                                     color: Colors
                              //                                         .grey),
                              //                               ),
                              //                               SizedBox(
                              //                                 height: 10,
                              //                               ),
                              //                             ],
                              //                           ),
                              //                         ),
                              //                         btnOkColor: Colors
                              //                             .deepOrange.shade500
                              //                             .withOpacity(0.8),
                              //                         alignment:
                              //                             Alignment.center,
                              //                         btnOkOnPress: () {},
                              //                       ).show();
                              //                       setState(() {});
                              //                     }
                              //                   : null,
                              //               child: Text('पुराए',
                              //                   style: TextStyle(
                              //                     color: isSendButtonPressed &&
                              //                             !isDoneButtonPressed
                              //                         ? Color.fromRGBO(
                              //                             1, 181, 116, 1)
                              //                         : Colors.grey,
                              //                     fontSize: 17,
                              //                     fontWeight: FontWeight.bold,
                              //                   )),
                              //             ),
                              //           ],
                              //         ),
                              //         // Row(
                              //         //   mainAxisAlignment:
                              //         //       MainAxisAlignment.end,
                              //         //   children: [
                              //         //     Text(
                              //         //       '... ${index + 1}',
                              //         //       style: TextStyle(
                              //         //           fontWeight: FontWeight.bold,
                              //         //           fontSize: 17,
                              //         //           color: Colors.grey),
                              //         //     ),
                              //         //   ],
                              //         // ),
                              //         SizedBox(
                              //           height: 10,
                              //         ),
                              //         Divider(
                              //           height: 1,
                              //           color: Colors.grey[300],
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),

                              child: Column(
                                children: [
                                  SizedBox(
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    //   borderRadius: BorderRadius.circular(16),
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.black.withOpacity(0.1),
                                    //       blurRadius: 10,
                                    //       spreadRadius: 2,
                                    //       offset: Offset(0, 4),
                                    //     ),
                                    //   ],
                                    // ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 16,
                                          bottom: 16,
                                          right: 12,
                                          left: 12),
                                      child: Column(
                                        children: [
                                          // Passenger Header
                                          Row(
                                            children: [
                                              // Avatar with fallback
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      Colors.blueGrey.shade100,
                                                  image: userDetails[
                                                              'photoUrl'] !=
                                                          null
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                              userDetails[
                                                                  'photoUrl']),
                                                          fit: BoxFit.cover)
                                                      : null,
                                                ),
                                                child:
                                                    userDetails['photoUrl'] ==
                                                            null
                                                        ? Container(
                                                            width: 48,
                                                            height: 48,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .blueGrey
                                                                  .shade100,
                                                              image: userDetails[
                                                                          'photoUrl'] !=
                                                                      null
                                                                  ? DecorationImage(
                                                                      image: NetworkImage(
                                                                          userDetails[
                                                                              'photoUrl']),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : null,
                                                            ),
                                                            child: userDetails[
                                                                        'photoUrl'] ==
                                                                    null
                                                                ? Center(
                                                                    child: Text(
                                                                      userDetails['username']?.isNotEmpty ==
                                                                              true
                                                                          ? userDetails['username'][0]
                                                                              .toUpperCase()
                                                                          : '?',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            26,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black54,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : null,
                                                          )
                                                        : null,
                                              ),
                                              SizedBox(width: 12),

                                              // Passenger Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userDetails['username'] ??
                                                          'Passenger',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blueGrey,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${userDetails['phone_number'] ?? 'N/A'}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Fare Info
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'NPR ${double.parse(tripDetails['fare']).toStringAsFixed(1)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '${double.parse(tripDetails['distance']).toStringAsFixed(1)} km, ${tripDetails['no_of_person']} P.',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 16),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildIconButton(
                                                icon: Icons.chat_bubble_outline,
                                                label: 'Chat',
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DriverChatDisplayPage(
                                                      driverId: widget.driverId,
                                                      tripId: tripId,
                                                      userId: userId,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              _buildIconButton(
                                                icon: Icons.phone_outlined,
                                                label: 'Call',
                                                onTap: () {
                                                  final phoneNumber =
                                                      userDetails[
                                                          'phone_number'];
                                                  if (phoneNumber != null &&
                                                      phoneNumber.isNotEmpty) {
                                                    _launchPhoneNumber(
                                                        phoneNumber);
                                                  } else {
                                                    // ScaffoldMessenger.of(context)
                                                    //     .showSnackBar(
                                                    //   const SnackBar(
                                                    //     content: Text(
                                                    //         'Phone number unavailable'),
                                                    //   ),
                                                    // );

                                                    AwesomeDialog(
                                                      context: context,
                                                      dialogType:
                                                          DialogType.error,
                                                      animType:
                                                          AnimType.topSlide,
                                                      body: Center(
                                                        child: Column(
                                                          children: const [
                                                            Text(
                                                              'Phone Number Invalid',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 22,
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              'Looks like Phone Number is not Provided by the User',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      btnOkColor: Colors
                                                          .deepOrange.shade500
                                                          .withOpacity(0.8),
                                                      alignment:
                                                          Alignment.center,
                                                      btnOkOnPress: () {},
                                                    ).show();
                                                  }
                                                },
                                              ),
                                              _buildIconButton(
                                                icon: Icons.location_searching,
                                                label: 'Map',
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DriverViewPassengerLocation(
                                                            tripId: tripId),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Trip Info Card
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  139, 250, 250, 250),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                            ),
                                            child: Column(
                                              children: [
                                                _buildInfoRow(
                                                  icon: Icons.location_on,
                                                  iconColor: Colors.green,
                                                  text: tripDetails[
                                                      'pickupLocation'],
                                                ),
                                                SizedBox(height: 8),
                                                _buildInfoRow(
                                                  icon: Icons.location_on,
                                                  iconColor: Colors.redAccent,
                                                  text: tripDetails[
                                                      'deliveryLocation'],
                                                ),
                                                SizedBox(height: 8),
                                                _buildInfoRow(
                                                  icon: Icons.location_city,
                                                  iconColor: Colors.blue,
                                                  text: tripDetails[
                                                          'municipalityDropdown'] ??
                                                      'Pickup location',
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(height: 10),

                                          // Action Buttons

                                          SizedBox(height: 12),

                                          // Primary Action Button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: isSendButtonPressed
                                                  ? (!isDoneButtonPressed
                                                      ? () async {
                                                          // Your existing complete ride logic
                                                          await _updateButtonStates(
                                                              tripId,
                                                              true,
                                                              true);
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'successfulTrips')
                                                              .add({
                                                            'tripId': tripId,
                                                            'driverId':
                                                                widget.driverId,
                                                            'userId': userId,
                                                            'timestamp': FieldValue
                                                                .serverTimestamp(),
                                                          });
                                                          setState(() {});
                                                        }
                                                      : null)
                                                  : () async {
                                                      // Your existing mark as arrived logic
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'arrivedDrivers')
                                                          .add({
                                                        'tripId': tripId,
                                                        'driverId':
                                                            widget.driverId,
                                                        'userId': userId,
                                                        'timestamp': FieldValue
                                                            .serverTimestamp(),
                                                      });
                                                      await _updateButtonStates(
                                                          tripId, true, false);
                                                      setState(() {});
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    isSendButtonPressed
                                                        ? (!isDoneButtonPressed
                                                            ? Colors
                                                                .blueAccent
                                                                .withAlpha(240)
                                                            : Colors.green)
                                                        : Colors.redAccent
                                                            .withAlpha(240),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                isSendButtonPressed
                                                    ? (!isDoneButtonPressed
                                                        ? 'Complete Ride - पुराए'
                                                        : 'RIDE COMPLETED - सक्कियो')
                                                    : 'Arrived - आइपुगे',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                  // Divider(),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                ],
                              ),
                            ),
                          );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Helper Widgets
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        SizedBox(width: 8),
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
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(139, 250, 250, 250),
            ),
            child: Icon(icon, size: 22, color: Colors.blueGrey.shade700),
          ),
        ),
        // SizedBox(height: 4),
        // Text(
        //   label,
        //   style: TextStyle(
        //     fontSize: 12,
        //     color: Colors.grey.shade700,
        //   ),
        // ),
      ],
    );
  }

  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

//   ScrollPhysics _buildCustomScrollPhysics() {
//     return AlwaysScrollableScrollPhysics().applyTo(
//       ClampingScrollPhysics(
//         parent: _LimitedScrollPhysics(maxScrollSpeed: _maxScrollSpeed),
//       ),
//     );
//   }
// }
}
