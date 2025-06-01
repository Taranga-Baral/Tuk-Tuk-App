import 'package:animations/animations.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/chat/chat_display_page.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestPage extends StatefulWidget {
  final String userId;
  final bool? arrivedDriveronInit;

  const RequestPage(
      {super.key, required this.userId, this.arrivedDriveronInit});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List<DocumentSnapshot> requests = [];
  List<DocumentSnapshot> arrivedDrivers = [];
  bool isDataLoaded = false;

  bool _isOnline = true; // Track connectivity status
  final Map<String, bool> _buttonStates =
      {}; // Track button states per trip using tripId (String)
  List<bool> _expandedStates = [];
  bool showArrivedDrivers = false;
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadData();
  }

  Future<void> _refreshData() async {
    if (showArrivedDrivers == false) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RequestPage(
                    userId: widget.userId,
                    arrivedDriveronInit: false,
                  )));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RequestPage(
                    userId: widget.userId,
                    arrivedDriveronInit: true,
                  )));
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _loadData() async {
    showArrivedDrivers = widget.arrivedDriveronInit ?? showArrivedDrivers;

    try {
      print('Fetching requests...');
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('requestsofDrivers')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('requestTimestamp', descending: true)
          .limit(50) // Limit the number of documents to load
          .get();

      print('Fetching arrived drivers...');
      final arrivedDriversSnapshot = await FirebaseFirestore.instance
          .collection('arrivedDrivers')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      // Debugging: Print retrieved documents
      for (var doc in requestsSnapshot.docs) {
        print('Request: ${doc.data()}');
      }

      for (var doc in arrivedDriversSnapshot.docs) {
        print('Arrived driver: ${doc.data()}');
      }

      // Check if requests exist before continuing
      if (requestsSnapshot.docs.isEmpty &&
          arrivedDriversSnapshot.docs.isEmpty) {
        print('No requests or Arrived Drivers Found for this User.');
        return; // Exit if no requests found
      }

      // Initialize variables to hold the documents with distance information
      List<DocumentSnapshot> filteredRequests = [];

      // Filter requests with 'distance_between_driver_and_passenger' field
      for (var requestDoc in requestsSnapshot.docs) {
        final request = requestDoc.data();
        final tripId = request['tripId'];
        final driverId = request['driverId'];
        final userId = request['userId'];

        // Fetch distance data from 'distance_between_driver_and_passenger' collection
        final distanceSnapshot = await FirebaseFirestore.instance
            .collection('distance_between_driver_and_passenger')
            .where('tripId', isEqualTo: tripId)
            .where('driverId', isEqualTo: driverId)
            .where('userId', isEqualTo: userId)
            .get();

        // Merge data from 'requestsofDrivers' and 'distance_between_driver_and_passenger'
        if (distanceSnapshot.docs.isNotEmpty) {
          final distanceData = distanceSnapshot.docs.first.data();
          request['distance_between_driver_and_passenger'] =
              distanceData['distance'] ?? 'N/A';
        } else {
          request['distance_between_driver_and_passenger'] = 'N/A';
        }

        filteredRequests.add(requestDoc);
      }

      // Process the filtered requests to check if confirmed in another collection
      for (var request in filteredRequests) {
        final tripId = request['tripId'];
        final confirmedSnapshot = await FirebaseFirestore.instance
            .collection('confirmedDrivers')
            .where('tripId', isEqualTo: tripId)
            .get();

        setState(() {
          _buttonStates[tripId] =
              confirmedSnapshot.docs.isNotEmpty; // Update button states
        });
      }

      // Initialize the _expandedStates list with false values for all requests
      _expandedStates = List.filled(filteredRequests.length, false);

      setState(() {
        requests = filteredRequests;
        arrivedDrivers = arrivedDriversSnapshot.docs;
        isDataLoaded = true;
      });
    } catch (e) {
      print('Error loading data: $e');
      // Handle errors gracefully, e.g., show a snackbar or alert dialog
    }
  }

  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  Future<void> confirmRequest(
      String userId, String driverId, String tripId) async {
    if (!_isOnline) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'Error',
        desc: 'No internet connection.',
        btnOkOnPress: () {},
      ).show();

      return;
    }

    try {
      await FirebaseFirestore.instance.collection('confirmedDrivers').add({
        'userId': userId,
        'driverId': driverId,
        'tripId': tripId,
        'arrived': false,
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _buttonStates[tripId] = true; // Darken and disable the button
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Request confirmed and stored in Firebase.'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: 'Success',
        desc: 'Request confirmed and stored in Firebase.',
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      setState(() {
        _buttonStates[tripId] = false; // Re-enable button if error occurs
      });

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'Error',
        desc: 'Error confirming request: $e',
        btnOkText: 'OK',
        btnOkOnPress: () {},
      ).show();
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 8, // Number of shimmer placeholders
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
                  // Container(
                  //   width: 150,
                  //   height: 40,
                  //   color: Colors.white,
                  // ),
                  // const SizedBox(height: 8),
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: 24,
                  //       height: 40,
                  //       color: Colors.white,
                  //     ),
                  //     const SizedBox(width: 10),
                  //     Expanded(
                  //       child: Container(
                  //         height: 40,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 5),
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: 24,
                  //       height: 40,
                  //       color: Colors.white,
                  //     ),
                  //     const SizedBox(width: 10),
                  //     Expanded(
                  //       child: Container(
                  //         height: 40,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            color: Colors.grey,
                            width: 120,
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

                          //start
                          SizedBox(
                            height: 4,
                          ),
                          Container(
                            height: 10,
                            color: Colors.grey,
                            width: 50,
                          ),

                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 10,
                            color: Colors.grey,
                            width: 50,
                          ),

                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 10,
                            color: Colors.grey,
                            width: 50,
                          ),

                          //end
                        ],
                      ),
                      CircleAvatar(
                        radius: 30,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        // backgroundColor: Colors.blueAccent,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // backgroundColor: Color.fromRGBO(65, 95, 207, 1),
          backgroundColor: Colors.blueAccent,
          // title: Text(
          //   'Driver Requests',
          // softWrap: true,
          // maxLines: 1,
          // style: GoogleFonts.outfit(
          //   color: Colors.white,
          //   fontWeight: FontWeight.bold,
          // ),
          // ),
          title: showArrivedDrivers == true
              ? Text(
                  'Arrived Driver',
                  softWrap: true,
                  maxLines: 1,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  'Approve Request of Drivers',
                  softWrap: true,
                  maxLines: 1,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

          // actions: [
          //   Row(
          //     children: [
          //       PopupMenuButton<String>(
          //         iconColor: Colors.white,
          //         color: Color.fromRGBO(255, 255, 255, 1),
          //         onSelected: (value) {
          //           setState(() {
          //             if (value == 'requests') {
          //               showArrivedDrivers = false;
          //             } else if (value == 'arrivedDrivers') {
          //               showArrivedDrivers = true;
          //             }
          //           });
          //         },
          //         itemBuilder: (context) => [
          //           PopupMenuItem(
          //             value: 'requests',
          //             child: Text('Requests'),
          //           ),
          //           PopupMenuItem(
          //             value: 'arrivedDrivers',
          //             child: Text('Arrived Drivers'),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ],
        ),
        floatingActionButton: showArrivedDrivers
            ? SizedBox(
                width: 120,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    print('Value of showArrivedDrivers 1: $showArrivedDrivers');
                    setState(() {
                      showArrivedDrivers = !showArrivedDrivers;
                    });
                    print(
                        'Value of showArrivedDrivers after 1: $showArrivedDrivers');
                  },
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.92),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Requests',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                width: 155,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    print('Value of showArrivedDrivers 2: $showArrivedDrivers');

                    setState(() {
                      showArrivedDrivers = !showArrivedDrivers;
                    });
                    print(
                        'Value of showArrivedDrivers after 2: $showArrivedDrivers');
                  },
                  backgroundColor: Color.fromRGBO(1, 181, 116, 0.93),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.drive_eta_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Waiting for You',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
        body: isDataLoaded
            ? RefreshIndicator(
                onRefresh: _refreshData,
                child: LayoutBuilder(
                  // Use LayoutBuilder to manage screen size
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        if (showArrivedDrivers) ...[
                          Flexible(
                            child: ListView.builder(
                              physics: _buildCustomScrollPhysics(),
                              itemCount: arrivedDrivers.length,
                              itemBuilder: (context, index) {
                                final driver = arrivedDrivers[index];
                                final driverId = driver['driverId'];
                                final tripId = driver['tripId'];

                                return FutureBuilder<Map<String, dynamic>>(
                                  future: _getDriverAndTripDetails(
                                      driverId, tripId),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                          child: Center(
                                        child: Image(
                                            image: AssetImage(
                                                'assets/no_data_found.gif')),
                                      ));
                                      // return _buildShimmerLoading();
                                    }

                                    final driverData =
                                        snapshot.data!['driver'] ?? {};
                                    final tripData =
                                        snapshot.data!['trip'] ?? {};

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                        child: FlipCard(
                                          direction: FlipDirection.HORIZONTAL,
                                          front: Card(
                                            elevation: 1,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            shadowColor:
                                                Colors.grey.withOpacity(0.5),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      // CircleAvatar(
                                                      //   radius: 25,
                                                      //   backgroundImage: driverData[
                                                      //               'profilePictureUrl'] !=
                                                      //           null
                                                      //       ? NetworkImage(
                                                      //           driverData[
                                                      //               'profilePictureUrl'])
                                                      //       : AssetImage(
                                                      //               'assets/tuktuk.jpg')
                                                      //           as ImageProvider,
                                                      // ),

                                                      Container(
                                                        width: 55,
                                                        height: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.green,
                                                            width: 2,
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1),
                                                              blurRadius: 6,
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        child: ClipOval(
                                                          child: Image.network(
                                                            driverData['profilePictureUrl']
                                                                    .isNotEmpty
                                                                ? driverData[
                                                                    'profilePictureUrl']
                                                                : 'assets/logo.png',
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                // Image is fully loaded, return the image
                                                                return child;
                                                              } else {
                                                                // Image is still loading, return a CircularProgressIndicator
                                                                return Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    value: loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Icon(
                                                              Icons.person,
                                                              size: 40,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      SizedBox(width: 15),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${driverData['name'] ?? 'Unknown'}',
                                                              style: GoogleFonts
                                                                  .outfit(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              'Plate: ${driverData['numberPlate'] ?? 'N/A'}',
                                                              style: GoogleFonts
                                                                  .comicNeue(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .grey[700],
                                                              ),
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(
                                                      height: 20,
                                                      color: Colors.grey[300]),
                                                  SizedBox(height: 10),
                                                  _buildInfoRow(
                                                      'Passenger:',
                                                      tripData['no_of_person']
                                                              .toString() ??
                                                          'N/A'),
                                                  _buildInfoRow(
                                                      'Pickup  :',
                                                      tripData[
                                                              'pickupLocation'] ??
                                                          'N/A'),
                                                  _buildInfoRow(
                                                      'Delivery:',
                                                      tripData[
                                                              'deliveryLocation'] ??
                                                          'N/A'),
                                                  _buildInfoRow(
                                                      'Vehicle :',
                                                      tripData[
                                                              'vehicle_mode'] ??
                                                          'N/A'),
                                                  //this
                                                  // Row(
                                                  //   mainAxisAlignment:
                                                  //       MainAxisAlignment.end,
                                                  //   children: [
                                                  //     Text('... ${index + 1}',
                                                  //         style: TextStyle(
                                                  //             fontWeight:
                                                  //                 FontWeight
                                                  //                     .w500,
                                                  //             fontSize: 20,
                                                  //             color: Colors
                                                  //                 .black54))
                                                  //   ],
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          back: Card(
                                            elevation: 1,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            shadowColor:
                                                Colors.grey.withOpacity(0.5),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Driver Contact:',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${driverData['phone'] ?? 'N/A'}',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 16),
                                                      ),
                                                      Spacer(),
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            radius: 20,
                                                            backgroundImage:
                                                                AssetImage(
                                                              driverData['vehicleType'] ==
                                                                      'Taxi'
                                                                  ? 'assets/homepage_taxi.png'
                                                                  : driverData[
                                                                              'vehicleType'] ==
                                                                          'Tuk Tuk'
                                                                      ? 'assets/homepage_tuktuk.png'
                                                                      : 'assets/homepage_motorbike.png',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              final phoneNumber =
                                                                  driverData[
                                                                      'phone'];
                                                              if (phoneNumber !=
                                                                      null &&
                                                                  phoneNumber
                                                                      .isNotEmpty) {
                                                                _launchPhoneNumber(
                                                                    phoneNumber);
                                                              } else {
                                                                // ScaffoldMessenger
                                                                //         .of(context)
                                                                //     .showSnackBar(
                                                                //   SnackBar(
                                                                //       content: Text(
                                                                //           'Phone number is unavailable')),
                                                                // );
                                                                AwesomeDialog(
                                                                  context:
                                                                      context,
                                                                  dialogType:
                                                                      DialogType
                                                                          .error,
                                                                  animType: AnimType
                                                                      .topSlide,
                                                                  title:
                                                                      'Phone Number Unavailable',
                                                                  desc:
                                                                      'The phone number is currently unavailable.',
                                                                  btnOkOnPress:
                                                                      () {},
                                                                ).show();
                                                              }
                                                            },
                                                            child: Icon(
                                                                Icons.phone,
                                                                color: Colors
                                                                    .blueGrey),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                PageRouteBuilder(
                                                                  pageBuilder: (context,
                                                                      animation,
                                                                      secondaryAnimation) {
                                                                    return FadeScaleTransition(
                                                                      animation:
                                                                          animation,
                                                                      child:
                                                                          ChatDetailPage(
                                                                        userId:
                                                                            widget.userId,
                                                                        driverId:
                                                                            driverId,
                                                                        tripId:
                                                                            tripId,
                                                                        driverName:
                                                                            driverData['name'],
                                                                        pickupLocation:
                                                                            tripData['pickupLocation'],
                                                                        deliveryLocation:
                                                                            tripData['deliveryLocation'],
                                                                        distance:
                                                                            tripData['distance'],
                                                                        no_of_person:
                                                                            tripData['no_of_person'],
                                                                        vehicle_mode:
                                                                            tripData['vehicle_mode'],
                                                                        fare: tripData[
                                                                            'fare'],
                                                                      ),
                                                                    );
                                                                  },
                                                                  transitionsBuilder: (context,
                                                                      animation,
                                                                      secondaryAnimation,
                                                                      child) {
                                                                    const begin =
                                                                        Offset(
                                                                            1.0,
                                                                            0.0);
                                                                    const end =
                                                                        Offset
                                                                            .zero;
                                                                    const curve =
                                                                        Curves
                                                                            .easeInOut;

                                                                    var tween = Tween(
                                                                        begin:
                                                                            begin,
                                                                        end:
                                                                            end);
                                                                    var offsetAnimation =
                                                                        animation.drive(tween.chain(CurveTween(
                                                                            curve:
                                                                                curve)));

                                                                    return SlideTransition(
                                                                        position:
                                                                            offsetAnimation,
                                                                        child:
                                                                            child);
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            child: Icon(
                                                                Icons.chat,
                                                                color: Colors
                                                                    .blueGrey),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  _buildInfoRow(
                                                      'Brand:',
                                                      driverData['brand'] ??
                                                          'N/A'),
                                                  _buildInfoRow(
                                                      'Color:',
                                                      driverData['color'] ??
                                                          'N/A'),
                                                  Divider(),
                                                  _buildInfoRow('Distance:',
                                                      '${double.parse(tripData['distance']).toStringAsFixed(2) ?? 'N/A'} km'),
                                                  _buildInfoRow('Fare:',
                                                      '${tripData['fare'] ?? 'N/A'}'),
                                                  _buildInfoRow(
                                                    'Timestamp:',
                                                    tripData['timestamp'] !=
                                                                null &&
                                                            tripData[
                                                                    'timestamp']
                                                                is Timestamp
                                                        ? _formatTimestamp(
                                                            tripData[
                                                                'timestamp'])
                                                        : 'N/A',
                                                  ),
                                                ],
                                              ),
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
                        ] else ...[
                          Flexible(
                            //                         child: ListView.builder(
                            //                           itemCount: requests.length,
                            //                           physics: _buildCustomScrollPhysics(),
                            //                           itemBuilder: (context, index) {
                            //                             final request = requests[index];
                            //                             final tripId = request['tripId'];
                            //                             final driverId = request['driverId'];
                            //                             final userId = request['userId'];

                            //                             return FutureBuilder(
                            //                               future: Future.wait([
                            //                                 FirebaseFirestore.instance
                            //                                     .collection('vehicleData')
                            //                                     .doc(driverId)
                            //                                     .get(),
                            //                                 FirebaseFirestore.instance
                            //                                     .collection('trips')
                            //                                     .doc(tripId)
                            //                                     .get(),
                            //                                 FirebaseFirestore.instance
                            //                                     .collection(
                            //                                         'distance_between_driver_and_passenger')
                            //                                     .where('tripId', isEqualTo: tripId)
                            //                                     .where('userId', isEqualTo: userId)
                            //                                     .get(),
                            //                               ]),
                            //                               builder: (context,
                            //                                   AsyncSnapshot<List<Object>> snapshot) {
                            //                                 if (snapshot.connectionState ==
                            //                                     ConnectionState.waiting) {
                            //                                   return Center(
                            //                                       child: Image(
                            //                                     image: AssetImage('assets/logo.png'),
                            //                                   ));
                            //                                 }

                            //                                 if (snapshot.hasError || !snapshot.hasData) {
                            //                                   return Text('Error loading data');
                            //                                 }

                            //                                 if (snapshot.data == null) {
                            //                                   return Text('No any user data');
                            //                                 }

                            //                                // Accessing documents from the snapshot
                            //     final vehicleDataSnapshot = snapshot.data![0];
                            //     final tripDataSnapshot = snapshot.data![1];
                            //     final distanceSnapshot = snapshot.data![2];

                            // // Checking if distanceSnapshot contains any documents
                            //     if (distanceSnapshot.docs.isEmpty) {
                            //       return Text('No distance data found');
                            //     }

                            //     // Accessing the first document from distanceSnapshot
                            //     final distanceDoc = distanceSnapshot.docs.first;
                            //     final distanceData = distanceDoc.data() as Map<String, dynamic>;

                            //                                 // Access data from DocumentSnapshot using data() method
                            //                                 Map<String, dynamic> vehicleData =
                            //                                     vehicleDataSnapshot.data()
                            //                                         as Map<String, dynamic>;
                            //                                 Map<String, dynamic> tripData = tripDataSnapshot
                            //                                     .data() as Map<String, dynamic>;

                            //                                     Map<String, dynamic> distanceData = tripDataSnapshot
                            //                                     .data() as Map<String, dynamic>;

                            //                                 final phone = vehicleData['phone'] ?? 'N/A';
                            //                                 final address = vehicleData['address'] ?? 'N/A';
                            //                                 final brand = vehicleData['brand'] ?? 'N/A';
                            //                                 final profilePicture =
                            //                                     vehicleData['profilePictureUrl'] ?? 'N/A';
                            //                                 final color = vehicleData['color'] ?? 'N/A';
                            //                                 final name = vehicleData['name'] ?? 'N/A';
                            //                                 final numberPlate =
                            //                                     vehicleData['numberPlate'] ?? 'N/A';
                            //                                 final vehicleType =
                            //                                     vehicleData['vehicleType'] ?? 'N/A';

                            //                                 final pickupLocation =
                            //                                     tripData['pickupLocation'] ?? 'N/A';
                            //                                 final deliveryLocation =
                            //                                     tripData['deliveryLocation'] ?? 'N/A';

                            //                                 final noOfPerson =
                            //                                     tripData['no_of_person'] ?? 'N/A';

                            //                                 final vehicleMode =
                            //                                     tripData['vehicle_mode'] ?? 'N/A';

                            //                                 final fare = tripData['fare'] ?? 'N/A';
                            //                                 final distance = tripData['distance'] ?? 'N/A';
                            //                                 final timestamp =
                            //                                     tripData['requestTimestamp'] ?? 'NA';
                            //                                 final distanceBetweenDriverAndPassenger = distanceData[
                            //                                         'distance_between_driver_and_passenger'] ??
                            //                                     'N/A';

                            //                                 return FlipCard(
                            //                                   flipOnTouch:
                            //                                       true, // Flip animation on card tap
                            //                                   direction: FlipDirection
                            //                                       .HORIZONTAL, // Horizontal flip
                            //                                   back: Card(
                            //                                     elevation: 1,
                            //                                     margin: EdgeInsets.all(10),
                            //                                     child: Padding(
                            //                                       padding: const EdgeInsets.all(15.0),
                            //                                       child: Column(
                            //                                         crossAxisAlignment:
                            //                                             CrossAxisAlignment.start,
                            //                                         children: [
                            //                                           Row(
                            //                                             children: [
                            //                                               Icon(
                            //                                                 Icons.location_on,
                            //                                                 color: Colors.green,
                            //                                               ),
                            //                                               SizedBox(
                            //                                                 width: 10,
                            //                                               ),
                            //                                               Expanded(
                            //                                                 child: Text('$pickupLocation',
                            //                                                     style: TextStyle(
                            //                                                         fontWeight:
                            //                                                             FontWeight.bold)),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                           Divider(),
                            //                                           Row(
                            //                                             children: [
                            //                                               Icon(
                            //                                                 Icons.location_on,
                            //                                                 color: Colors.red,
                            //                                               ),
                            //                                               SizedBox(
                            //                                                 width: 10,
                            //                                               ),
                            //                                               Expanded(
                            //                                                 child: Text('$deliveryLocation',
                            //                                                     style: TextStyle(
                            //                                                         fontWeight:
                            //                                                             FontWeight.bold)),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                           Divider(),
                            //                                           Row(
                            //                                             children: [
                            //                                               Icon(
                            //                                                 Icons.money,
                            //                                                 color:
                            //                                                     Colors.blueAccent.shade200,
                            //                                               ),
                            //                                               SizedBox(
                            //                                                 width: 10,
                            //                                               ),
                            //                                               Expanded(
                            //                                                 child: Text('NPR $fare',
                            //                                                     style: TextStyle(
                            //                                                         fontWeight:
                            //                                                             FontWeight.w500)),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            // Row(
                            //   mainAxisAlignment:
                            //       MainAxisAlignment.end,
                            //   children: [
                            //     SizedBox(width: 20),
                            //     GestureDetector(
                            //       child: Icon(Icons.phone,
                            //           color: Colors.green),
                            //       onTap: () {
                            //         final phoneNumber =
                            //             vehicleData['phone'];
                            //         if (phoneNumber != null &&
                            //             phoneNumber.isNotEmpty) {
                            //           _launchPhoneNumber(
                            //               phoneNumber);
                            //         } else {
                            //           AwesomeDialog(
                            //             context: context,
                            //             dialogType:
                            //                 DialogType.error,
                            //             animType:
                            //                 AnimType.topSlide,
                            //             title:
                            //                 'Phone Number Unavailable',
                            //             desc:
                            //                 'The phone number is currently unavailable.',
                            //             btnOkOnPress: () {},
                            //           ).show();
                            //         }
                            //       },
                            //     ),
                            //     SizedBox(width: 20),
                            //     ElevatedButton(
                            //       onPressed:
                            //           _buttonStates[tripId] ==
                            //                   true
                            //               ? null
                            //               : () {
                            //                   confirmRequest(
                            //                       userId,
                            //                       driverId,
                            //                       tripId);
                            //                 },
                            //       style: ElevatedButton.styleFrom(
                            //         foregroundColor: Colors.white,
                            //         backgroundColor:
                            //             _buttonStates[tripId] ==
                            //                     true
                            //                 ? Colors.grey
                            //                 : Colors.blue,
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 24,
                            //             vertical:
                            //                 12), // Padding for button
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius:
                            //               BorderRadius.circular(
                            //                   8), // Rounded corners
                            //         ),
                            //       ),
                            //       child: Text(
                            //         'Confirm',
                            //       style: TextStyle(
                            //         fontSize:
                            //             16, // Font size for the text
                            //         fontWeight: FontWeight
                            //             .bold, // Bold text
                            //       ),
                            //       ),

                            //       child: Text(
                            //         _buttonStates[tripId] == true
                            //             ? 'Confirmed'
                            //             : 'Confirm',
                            //         style: TextStyle(
                            //           fontSize:
                            //               16, // Font size for the text
                            //           fontWeight: FontWeight
                            //               .bold, // Bold text
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            //                                   front: Card(
                            //                                     elevation: 1,
                            //                                     margin: EdgeInsets.all(10),
                            //                                     child: SizedBox(
                            //                                       child: Padding(
                            //                                         padding: const EdgeInsets.all(15.0),
                            //                                         child: Column(
                            //                                           crossAxisAlignment:
                            //                                               CrossAxisAlignment.start,
                            //                                           children: [
                            //                                             ListTile(
                            //                                               leading: CircleAvatar(
                            //                                                 radius: 25,
                            //                                                 backgroundImage: profilePicture !=
                            //                                                         null
                            //                                                     ? NetworkImage(
                            //                                                         profilePicture)
                            //                                                     : AssetImage(
                            //                                                             'assets/tuktuk.jpg')
                            //                                                         as ImageProvider,
                            //                                               ),
                            //                                               title: Text(
                            //                                                 '$name - $numberPlate',
                            //                                                 style: GoogleFonts.outfit(
                            //                                                     fontWeight: FontWeight.bold,
                            //                                                     fontSize: 16),
                            //                                               ),
                            //                                               subtitle: Column(
                            //                                                 crossAxisAlignment:
                            //                                                     CrossAxisAlignment.start,
                            //                                                 children: [
                            //                                                   Text(
                            //                                                     'Passenger: $noOfPerson | Mode: $vehicleMode',
                            //                                                     style:
                            //                                                         GoogleFonts.comicNeue(
                            //                                                             fontSize: 14),
                            //                                                   ),
                            //                                                   Text(
                            //                                                     '$vehicleType $brand ($color)',
                            //                                                     style:
                            //                                                         GoogleFonts.comicNeue(),
                            //                                                     maxLines: null,
                            //                                                     softWrap: true,
                            //                                                   ),
                            //                                                 ],
                            //                                               ),
                            //                                             ),
                            //                                             Divider(),
                            //                                             Row(
                            //                                               children: [
                            //                                                 Icon(
                            //                                                   Icons.call_end_sharp,
                            //                                                   color: Colors.green,
                            //                                                 ),
                            //                                                 SizedBox(
                            //                                                   width: 10,
                            //                                                 ),
                            //                                                 Expanded(
                            //                                                   child: Text(
                            //                                                     '$phone',
                            //                                                     style:
                            //                                                         GoogleFonts.comicNeue(
                            //                                                             fontSize: 14),
                            //                                                     softWrap: true,
                            //                                                     overflow:
                            //                                                         TextOverflow.visible,
                            //                                                     maxLines: null,
                            //                                                   ),
                            //                                                 ),
                            //                                               ],
                            //                                             ),
                            //                                             SizedBox(height: 5),
                            //                                             Row(
                            //                                               children: [
                            //                                                 Icon(
                            //                                                   Icons.linear_scale_rounded,
                            //                                                   color: Colors.orange,
                            //                                                 ),
                            //                                                 SizedBox(
                            //                                                   width: 10,
                            //                                                 ),
                            //                                                 Text(
                            //                                                   '${double.tryParse(distance)?.toStringAsFixed(1)} km',
                            //                                                   softWrap: true,
                            //                                                   overflow:
                            //                                                       TextOverflow.visible,
                            //                                                   maxLines: null,
                            //                                                   style: GoogleFonts.comicNeue(
                            //                                                       fontSize: 14),
                            //                                                 ),
                            //                                               ],
                            //                                             ),
                            //                                             SizedBox(height: 5),
                            //                                             Row(
                            //                                               children: [
                            //                                                 Icon(
                            //                                                   Icons.people_sharp,
                            //                                                   color: Colors
                            //                                                       .pinkAccent.shade200,
                            //                                                 ),
                            //                                                 SizedBox(
                            //                                                   width: 10,
                            //                                                 ),
                            //                                                 Text(
                            //                                                   'Driver is ${(distanceBetweenDriverAndPassenger).toStringAsFixed(1)} km away',
                            //                                                   style: GoogleFonts.comicNeue(
                            //                                                       fontSize: 14),
                            //                                                   softWrap: true,
                            //                                                   overflow:
                            //                                                       TextOverflow.visible,
                            //                                                   maxLines: null,
                            //                                                 ),
                            //                                               ],
                            //                                             ),
                            //                                             Align(
                            //                                               alignment: Alignment.bottomRight,
                            //                                               child: Text(
                            //                                                 '... ${index + 1}',
                            //                                                 style: TextStyle(
                            //                                                     fontWeight: FontWeight.w500,
                            //                                                     fontSize: 20,
                            //                                                     color: Colors.black54),
                            //                                               ),
                            //                                             ),
                            //                                           ],
                            //                                         ),
                            //                                       ),
                            //                                     ),
                            //                                   ),
                            //                                 );
                            //                               },
                            //                             );
                            //                           },
                            //                         ),
                            child: ListView.builder(
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                final request = requests[index];
                                final tripId = request['tripId'];
                                final driverId = request['driverId'];
                                final userId = request['userId'];

                                return FutureBuilder(
                                  future: Future.wait([
                                    FirebaseFirestore.instance
                                        .collection('vehicleData')
                                        .doc(driverId)
                                        .get(),
                                    FirebaseFirestore.instance
                                        .collection('trips')
                                        .doc(tripId)
                                        .get(),
                                    FirebaseFirestore.instance
                                        .collection(
                                            'distance_between_driver_and_passenger')
                                        .where('tripId', isEqualTo: tripId)
                                        .where('driverId', isEqualTo: driverId)
                                        .where('userId', isEqualTo: userId)
                                        .get(),
                                  ]),
                                  builder: (context,
                                      AsyncSnapshot<List<dynamic>> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ListView.builder(
                                        itemCount:
                                            8, // Number of shimmer placeholders
                                        itemBuilder: (context, index) {
                                          return Card(
                                            margin: const EdgeInsets.all(8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Container(
                                                    //   width: 150,
                                                    //   height: 40,
                                                    //   color: Colors.white,
                                                    // ),
                                                    // const SizedBox(height: 8),
                                                    // Row(
                                                    //   children: [
                                                    //     Container(
                                                    //       width: 24,
                                                    //       height: 40,
                                                    //       color: Colors.white,
                                                    //     ),
                                                    //     const SizedBox(width: 10),
                                                    //     Expanded(
                                                    //       child: Container(
                                                    //         height: 40,
                                                    //         color: Colors.white,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    // const SizedBox(height: 5),
                                                    // Row(
                                                    //   children: [
                                                    //     Container(
                                                    //       width: 24,
                                                    //       height: 40,
                                                    //       color: Colors.white,
                                                    //     ),
                                                    //     const SizedBox(width: 10),
                                                    //     Expanded(
                                                    //       child: Container(
                                                    //         height: 40,
                                                    //         color: Colors.white,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),

                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: 20,
                                                              color:
                                                                  Colors.grey,
                                                              width: 120,
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Container(
                                                              height: 10,
                                                              width: 80,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Container(
                                                              height: 10,
                                                              color:
                                                                  Colors.grey,
                                                              width: 50,
                                                            ),

                                                            //start
                                                            SizedBox(
                                                              height: 4,
                                                            ),
                                                            Container(
                                                              height: 10,
                                                              color:
                                                                  Colors.grey,
                                                              width: 50,
                                                            ),

                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Container(
                                                              height: 10,
                                                              color:
                                                                  Colors.grey,
                                                              width: 50,
                                                            ),

                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Container(
                                                              height: 10,
                                                              color:
                                                                  Colors.grey,
                                                              width: 50,
                                                            ),

                                                            //end
                                                          ],
                                                        ),
                                                        CircleAvatar(
                                                          radius: 30,
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
                                      // return _buildShimmerLoading();
                                    }

                                    if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data == null) {
                                      return Text('Error loading data');
                                      // return _buildShimmerLoading();
                                    }

                                    final vehicleData = snapshot.data![0].data()
                                        as Map<String, dynamic>;
                                    final tripData = snapshot.data![1].data()
                                        as Map<String, dynamic>;

                                    // Check for distance data from distance_between_driver_and_passenger collection
                                    String distanceBetweenDriverAndPassenger =
                                        'N/A';
                                    if (snapshot.data![2].docs.isNotEmpty) {
                                      final distanceDoc =
                                          snapshot.data![2].docs.first;
                                      final distanceData = distanceDoc.data()
                                          as Map<String, dynamic>;
                                      distanceBetweenDriverAndPassenger =
                                          distanceData[
                                                      'distance_between_driver_and_passenger']
                                                  .toString() ??
                                              'N/A';
                                    }

                                    // Extracting necessary data from vehicleData and tripData
                                    final phone = vehicleData['phone'] ?? 'N/A';
                                    final name = vehicleData['name'] ?? 'N/A';
                                    final numberPlate =
                                        vehicleData['numberPlate'] ?? 'N/A';
                                    final profilePicture =
                                        vehicleData['profilePictureUrl'] ??
                                            'N/A';
                                    final vehicleType =
                                        vehicleData['vehicleType'] ?? 'N/A';
                                    final vehicleModeD =
                                        vehicleData['vehicleMode'] ?? 'N/A';
                                    final vehicleModeT =
                                        tripData['vehicle_mode'] ?? 'N/A';

                                    final pickupLocation =
                                        tripData['pickupLocation'] ?? 'N/A';
                                    final deliveryLocation =
                                        tripData['deliveryLocation'] ?? 'N/A';
                                    final fare = tripData['fare'] ?? 'N/A';
                                    final distance =
                                        tripData['distance'] ?? 'N/A';

                                    return vehicleModeT == vehicleModeD
                                        ? FlipCard(
                                            flipOnTouch: true,
                                            direction: FlipDirection.HORIZONTAL,
                                            back: Card(
                                              elevation: 1,
                                              margin: EdgeInsets.all(10),
                                              child:
                                                  vehicleModeT == vehicleModeD
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '$pickupLocation',
                                                                      style: GoogleFonts.montserrat(
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Divider(),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '$deliveryLocation',
                                                                      style: GoogleFonts.montserrat(
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Divider(),
                                                              Row(
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      // Copy the full tripId to the clipboard
                                                                      Clipboard.setData(
                                                                          ClipboardData(
                                                                              text: tripId));
                                                                      // Show a toast message to indicate the text has been copied
                                                                      Fluttertoast
                                                                          .showToast(
                                                                        msg:
                                                                            tripId,
                                                                        toastLength:
                                                                            Toast.LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity.TOP,
                                                                        backgroundColor:
                                                                            Colors.blue,
                                                                        textColor:
                                                                            Colors.white,
                                                                      );
                                                                    },
                                                                    child:
                                                                        Expanded(
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.copy,
                                                                            color:
                                                                                Colors.blueAccent,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                            'TripID: ${tripId.substring(0, 18)}****',
                                                                            style:
                                                                                GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Divider(),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    radius: 20,
                                                                    backgroundImage:
                                                                        AssetImage(
                                                                      vehicleType ==
                                                                              'Taxi'
                                                                          ? 'assets/homepage_taxi.png'
                                                                          : vehicleType == 'Tuk Tuk'
                                                                              ? 'assets/homepage_tuktuk.png'
                                                                              : 'assets/homepage_motorbike.png',
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    child: Icon(
                                                                        Icons
                                                                            .phone,
                                                                        color: Colors
                                                                            .blueGrey),
                                                                    onTap: () {
                                                                      final phoneNumber =
                                                                          vehicleData[
                                                                              'phone'];
                                                                      if (phoneNumber !=
                                                                              null &&
                                                                          phoneNumber
                                                                              .isNotEmpty) {
                                                                        _launchPhoneNumber(
                                                                            phoneNumber);
                                                                      } else {
                                                                        AwesomeDialog(
                                                                          context:
                                                                              context,
                                                                          dialogType:
                                                                              DialogType.error,
                                                                          animType:
                                                                              AnimType.topSlide,
                                                                          title:
                                                                              'Phone Number Unavailable',
                                                                          desc:
                                                                              'The phone number is currently unavailable.',
                                                                          btnOkOnPress:
                                                                              () {},
                                                                        ).show();
                                                                      }
                                                                    },
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: _buttonStates[tripId] ==
                                                                            true
                                                                        ? null
                                                                        : () {
                                                                            confirmRequest(
                                                                                userId,
                                                                                driverId,
                                                                                tripId);
                                                                          },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      foregroundColor:
                                                                          Colors
                                                                              .white,
                                                                      backgroundColor: _buttonStates[tripId] ==
                                                                              true
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .blue,
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              24,
                                                                          vertical:
                                                                              12), // Padding for button
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8), // Rounded corners
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      _buttonStates[tripId] ==
                                                                              true
                                                                          ? 'Trip Booked'
                                                                          : 'Confirm',
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontSize:
                                                                            14, // Font size for the text
                                                                        fontWeight:
                                                                            FontWeight.w600, // Bold text
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 50,
                                                            ),
                                                            Center(
                                                              child: Text(
                                                                'You Selected $vehicleModeT Vehicle but this is $vehicleModeD',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: GoogleFonts.montserrat(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 50,
                                                            ),
                                                          ],
                                                        ),
                                            ),
                                            front: Card(
                                              elevation: 0.9,
                                              margin: EdgeInsets.all(10),
                                              child: SizedBox(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ListTile(
                                                        trailing: Container(
                                                          width: 55,
                                                          height: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: Colors
                                                                  .redAccent,
                                                              width: 2,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius: 6,
                                                                offset:
                                                                    const Offset(
                                                                        0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipOval(
                                                            child:
                                                                Image.network(
                                                              profilePicture
                                                                      .isNotEmpty
                                                                  ? profilePicture
                                                                  : 'assets/logo.png',
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      Widget
                                                                          child,
                                                                      ImageChunkEvent?
                                                                          loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null) {
                                                                  // Image is fully loaded, return the image
                                                                  return child;
                                                                } else {
                                                                  // Image is still loading, return a CircularProgressIndicator
                                                                  return Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      value: loadingProgress.expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              loadingProgress.expectedTotalBytes!
                                                                          : null,
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              errorBuilder:
                                                                  (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Icon(
                                                                Icons.person,
                                                                size: 40,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // trailing: CircleAvatar(
                                                        //   radius: 20,
                                                        //   backgroundImage: profilePicture !=
                                                        //           null
                                                        //       ? NetworkImage(
                                                        //           profilePicture)
                                                        //       : AssetImage(
                                                        //               'assets/tuktuk.jpg')
                                                        //           as ImageProvider,
                                                        // ),
                                                        title: Text(
                                                          '$name',
                                                          style: GoogleFonts
                                                              .outfit(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                        ),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '$vehicleModeD V | $numberPlate | $vehicleType',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        thickness: 0.1,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .call_end_sharp,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              '$phone',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                      fontSize:
                                                                          14),
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                        height: 5,
                                                      ),

                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.money,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              'NPR $fare',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .linear_scale_rounded,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            'Total: ${double.tryParse(distance)?.toStringAsFixed(1)} km,\nDriver is ${double.parse(distanceBetweenDriverAndPassenger).toStringAsFixed(2)} km away',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),

                                                      //this
                                                      // Row(
                                                      //   mainAxisAlignment:
                                                      //       MainAxisAlignment
                                                      //           .end,
                                                      //   children: [
                                                      //     Text(
                                                      //       '... ${index + 1}',
                                                      //       style: GoogleFonts
                                                      //           .comicNeue(
                                                      //               fontSize:
                                                      //                   20,
                                                      //               color: Colors
                                                      //                   .grey),
                                                      //     ),
                                                      //   ],
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              )
            : _buildShimmerLoading());
  }

  Future<Map<String, dynamic>> _getDriverAndTripDetails(
      String driverId, String tripId) async {
    final driverSnapshot = await FirebaseFirestore.instance
        .collection('vehicleData')
        .doc(driverId)
        .get();
    final tripSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();

    return {
      'driver': driverSnapshot.data(),
      'trip': tripSnapshot.data(),
    };
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style:
                  GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[700]),
              overflow: TextOverflow.visible,
              textAlign: TextAlign.start,
              softWrap: true,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime =
        timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    return DateFormat('yyyy-MM-dd HH:mm')
        .format(dateTime); // Customize the format as needed
  }

  ScrollPhysics _buildCustomScrollPhysics() {
    final ScrollController scrollController = ScrollController();
    const double maxScrollSpeed = 1.0; // Adjust as needed
    return AlwaysScrollableScrollPhysics().applyTo(
      ClampingScrollPhysics(
        parent: _LimitedScrollPhysics(maxScrollSpeed: maxScrollSpeed),
      ),
    );
  }
}

class _LimitedScrollPhysics extends ScrollPhysics {
  final double maxScrollSpeed;

  const _LimitedScrollPhysics({
    required this.maxScrollSpeed,
    super.parent,
  });

  @override
  _LimitedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _LimitedScrollPhysics(
      maxScrollSpeed: maxScrollSpeed,
      parent: buildParent(ancestor),
    );
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (velocity.abs() > maxScrollSpeed) {
      velocity = velocity.sign * maxScrollSpeed;
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
