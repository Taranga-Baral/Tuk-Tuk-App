import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/chat/chat_display_page.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestPage extends StatefulWidget {
  final String userId;

  const RequestPage({super.key, required this.userId});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List<DocumentSnapshot> requests = [];
  List<DocumentSnapshot> arrivedDrivers = [];
  bool isDataLoaded = false;
  bool showArrivedDrivers = false;
  bool _isOnline = true; // Track connectivity status
  final Map<String, bool> _buttonStates =
      {}; // Track button states per trip using tripId (String)
  List<bool> _expandedStates = []; // Track expanded state for each card

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadData();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _loadData() async {
    try {
      print('Fetching requests...');
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('requestsofDrivers')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('requestTimestamp', descending: true)
          .limit(20) // Load first 20 documents
          .get();

      print('Fetching arrived drivers...');
      final arrivedDriversSnapshot = await FirebaseFirestore.instance
          .collection('arrivedDrivers')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
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
        print('No requests or arrived drivers found for this user.');
      }

      // Check the state of each request in Firestore to see if it's confirmed
      for (var request in requestsSnapshot.docs) {
        final tripId = request['tripId'];
        final confirmedSnapshot = await FirebaseFirestore.instance
            .collection('confirmedDrivers')
            .where('tripId', isEqualTo: tripId)
            .get();

        setState(() {
          _buttonStates[tripId] = confirmedSnapshot
              .docs.isNotEmpty; // Button is darkened if confirmed
        });
      }

      // Initialize the _expandedStates list with false values for all requests
      _expandedStates = List.filled(requestsSnapshot.docs.length, false);

      setState(() {
        requests = requestsSnapshot.docs;
        arrivedDrivers = arrivedDriversSnapshot.docs;
        isDataLoaded = true;
      });
    } catch (e) {
      print('Error loading data: $e');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection.'),
          duration: Duration(seconds: 3),
        ),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request confirmed and stored in Firebase.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _buttonStates[tripId] = false; // Re-enable button if error occurs
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming request: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Requests Page'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.refresh),
                color: Colors.white,
              ),
              PopupMenuButton<String>(
                color: Color.fromRGBO(255, 255, 255, 1),
                onSelected: (value) {
                  setState(() {
                    if (value == 'requests') {
                      showArrivedDrivers = false;
                    } else if (value == 'arrivedDrivers') {
                      showArrivedDrivers = true;
                    }
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'requests',
                    child: Text('Requests'),
                  ),
                  PopupMenuItem(
                    value: 'arrivedDrivers',
                    child: Text('Arrived Drivers'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      body: isDataLoaded
          ? LayoutBuilder(
              // Use LayoutBuilder to manage screen size
              builder: (context, constraints) {
                return Column(
                  children: [
                    if (showArrivedDrivers) ...[
                      Flexible(
                        child: ListView.builder(
                          itemCount: arrivedDrivers.length,
                          itemBuilder: (context, index) {
                            final driver = arrivedDrivers[index];
                            final driverId = driver['driverId'];
                            final tripId = driver['tripId'];

                            return FutureBuilder<Map<String, dynamic>>(
                              future:
                                  _getDriverAndTripDetails(driverId, tripId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: Center(
                                        child: Image(image: AssetImage("assets/logo.png")),
                                      ));
                                }

                                final driverData =
                                    snapshot.data!['driver'] ?? {};
                                final tripData = snapshot.data!['trip'] ?? {};

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    child: FlipCard(
                                      direction: FlipDirection.HORIZONTAL,
                                      front: Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        shadowColor:
                                            Colors.grey.withOpacity(0.5),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  
                                                  
                                                  CircleAvatar(
                                                    radius: 25,
                                                    backgroundImage: driverData[
                                                                'profilePictureUrl'] !=
                                                            null
                                                        ? NetworkImage(driverData[
                                                            'profilePictureUrl'])
                                                        : AssetImage(
                                                                'assets/tuktuk.jpg')
                                                            as ImageProvider,
                                                  ),
                                                  SizedBox(width: 15),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${driverData['name'] ?? 'Unknown'}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Plate: ${driverData['numberPlate'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
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
                                                  'Pickup:',
                                                  tripData['pickupLocation'] ??
                                                      'N/A'),
                                              _buildInfoRow(
                                                  'Delivery:',
                                                  tripData[
                                                          'deliveryLocation'] ??
                                                      'N/A'),
                                              _buildInfoRow(
                                                  'Vehicle:',
                                                  tripData['vehicle_mode'] ??
                                                      'N/A'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      back: Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        shadowColor:
                                            Colors.grey.withOpacity(0.5),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Driver Contact:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${driverData['phone'] ?? 'N/A'}',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  Spacer(),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.phone,
                                                            color:
                                                                Colors.green),
                                                        onPressed: () {
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
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Phone number is unavailable')),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.chat,
                                                            color: Colors.blue),
                                                        onPressed: () {
                                                          Navigator.of(context)
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
                                                                    userId: widget
                                                                        .userId,
                                                                    driverId:
                                                                        driverId,
                                                                    tripId:
                                                                        tripId,
                                                                    driverName:
                                                                        driverData[
                                                                            'name'],
                                                                    pickupLocation:
                                                                        tripData[
                                                                            'pickupLocation'],
                                                                    deliveryLocation:
                                                                        tripData[
                                                                            'deliveryLocation'],
                                                                    distance:
                                                                        tripData[
                                                                            'distance'],
                                                                    no_of_person:
                                                                        tripData[
                                                                            'no_of_person'],
                                                                    vehicle_mode:
                                                                        tripData[
                                                                            'vehicle_mode'],
                                                                    fare: tripData[
                                                                        'fare'],
                                                                  ),
                                                                );
                                                              },
                                                              transitionsBuilder:
                                                                  (context,
                                                                      animation,
                                                                      secondaryAnimation,
                                                                      child) {
                                                                const begin =
                                                                    Offset(1.0,
                                                                        0.0);
                                                                const end =
                                                                    Offset.zero;
                                                                const curve =
                                                                    Curves
                                                                        .easeInOut;

                                                                var tween = Tween(
                                                                    begin:
                                                                        begin,
                                                                    end: end);
                                                                var offsetAnimation =
                                                                    animation.drive(tween.chain(
                                                                        CurveTween(
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
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              _buildInfoRow('Brand:',
                                                  driverData['brand'] ?? 'N/A'),
                                              _buildInfoRow('Color:',
                                                  driverData['color'] ?? 'N/A'),
                                              Divider(),
                                              _buildInfoRow('Distance:',
                                                  '${tripData['distance'] ?? 'N/A'} km'),
                                              _buildInfoRow('Fare:',
                                                  '${tripData['fare'] ?? 'N/A'}'),
                                              _buildInfoRow(
                                                'Timestamp:',
                                                tripData['timestamp'] != null &&
                                                        tripData['timestamp']
                                                            is Timestamp
                                                    ? _formatTimestamp(
                                                        tripData['timestamp'])
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
                              ]),
                              builder: (context,
                                  AsyncSnapshot<List<DocumentSnapshot>>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: Image(
                                    image: AssetImage('assets/logo.png'),
                                  ));
                                }

                                if (snapshot.hasError || !snapshot.hasData) {
                                  return Text('Error loading data');
                                }

                                if (snapshot.data == null) {
                                  return Text('No any user data');
                                }

                                final vehicleData = snapshot.data![0].data()
                                    as Map<String, dynamic>;
                                final tripData = snapshot.data![1].data()
                                    as Map<String, dynamic>;

                                final phone = vehicleData['phone'] ?? 'N/A';
                                final address = vehicleData['address'] ?? 'N/A';
                                final brand = vehicleData['brand'] ?? 'N/A';
                                final profilePicture =
                                    vehicleData['profilePictureUrl'] ?? 'N/A';
                                final color = vehicleData['color'] ?? 'N/A';
                                final name = vehicleData['name'] ?? 'N/A';
                                final numberPlate =
                                    vehicleData['numberPlate'] ?? 'N/A';
                                final vehicleType =
                                    vehicleData['vehicleType'] ?? 'N/A';

                                final pickupLocation =
                                    tripData['pickupLocation'] ?? 'N/A';
                                final deliveryLocation =
                                    tripData['deliveryLocation'] ?? 'N/A';

                                final noOfPerson =
                                    tripData['no_of_person'] ?? 'N/A';

                                final vehicleMode =
                                    tripData['vehicle_mode'] ?? 'N/A';

                                final fare = tripData['fare'] ?? 'N/A';
                                final distance = tripData['distance'] ?? 'N/A';
                                final timestamp =
                                    tripData['requestTimestamp'] ?? 'NA';
                                final distance_between_driver_and_passenger =
                                    tripData[
                                            'distance_between_driver_and_passenger'] ??
                                        'N/A';

                                return FlipCard(
                                  flipOnTouch:
                                      true, // Flip animation on card tap
                                  direction: FlipDirection
                                      .HORIZONTAL, // Horizontal flip
                                  back: Card(
                                    elevation: 5,
                                    margin: EdgeInsets.all(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Pickup Location: $pickupLocation',
                                              style: TextStyle(fontSize: 14)),
                                          Divider(),
                                          Text(
                                              'Delivery Location: $deliveryLocation',
                                              style: TextStyle(fontSize: 14)),
                                          Divider(),
                                          Text('Fare: $fare',
                                              style: TextStyle(fontSize: 14)),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              SizedBox(width: 20),
                                              GestureDetector(
                                                child: Icon(Icons.phone,
                                                    color: Colors.green),
                                                onTap: () {
                                                  final phoneNumber =
                                                      vehicleData['phone'];
                                                  if (phoneNumber != null &&
                                                      phoneNumber.isNotEmpty) {
                                                    _launchPhoneNumber(
                                                        phoneNumber);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Phone number is unavailable')),
                                                    );
                                                  }
                                                },
                                              ),
                                              SizedBox(width: 20),
                                              ElevatedButton(
                                                onPressed:
                                                    _buttonStates[tripId] ==
                                                            true
                                                        ? null
                                                        : () {
                                                            confirmRequest(
                                                                userId,
                                                                driverId,
                                                                tripId);
                                                          },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      _buttonStates[tripId] ==
                                                              true
                                                          ? Colors.grey
                                                          : Colors.blue,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical:
                                                          12), // Padding for button
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8), // Rounded corners
                                                  ),
                                                ),
                                                // child: Text(
                                                //   'Confirm',
                                                // style: TextStyle(
                                                //   fontSize:
                                                //       16, // Font size for the text
                                                //   fontWeight: FontWeight
                                                //       .bold, // Bold text
                                                // ),
                                                // ),

                                                child: Text(
                                                  _buttonStates[tripId] == true
                                                      ? 'Confirmed'
                                                      : 'Confirm',
                                                  style: TextStyle(
                                                    fontSize:
                                                        16, // Font size for the text
                                                    fontWeight: FontWeight
                                                        .bold, // Bold text
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  front: Card(
                                    
                                    elevation: 5,
                                    margin: EdgeInsets.all(10),
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                radius: 25,
                                                backgroundImage: profilePicture !=
                                                        null
                                                    ? NetworkImage(
                                                        profilePicture)
                                                    : AssetImage(
                                                            'assets/tuktuk.jpg')
                                                        as ImageProvider,
                                              ),
                                              
                                                  
                                              title: Text(
                                                '$name - $numberPlate',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Passenger: $noOfPerson | Mode: $vehicleMode',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  Text(
                                                      '$vehicleType $brand ($color)',
                                                      maxLines: 1),
                                                ],
                                              ),
                                            ),
                                            Divider(),
                                            Text(
                                              'Contact: $phone',
                                              style: TextStyle(fontSize: 14),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                              maxLines: null,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Trip Distance: ${distance} km',
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                              maxLines: null,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Driver is ${distance_between_driver_and_passenger} km far from your Pickup Place',
                                              style: TextStyle(fontSize: 14),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                              maxLines: null,
                                            ),
                                            SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(Icons.arrow_forward_ios_rounded,
                                                  color: Colors
                                                      .blue), // Flip prompt
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
                    ],
                  ],
                );
              },
            )
          : Center(child: Image(image: AssetImage("assets/logo.png"))),
    );
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
            '$label',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
}
