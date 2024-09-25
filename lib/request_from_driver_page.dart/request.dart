import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
          .limit(30) // Load first 20 documents
          .get();

      print('Requests loaded: ${requestsSnapshot.docs.length}');

      print('Fetching arrived drivers...');
      final arrivedDriversSnapshot = await FirebaseFirestore.instance
          .collection('arrivedDrivers')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('timestamp', descending: true) // Sort by timestamp
          .get();

      print('Arrived drivers loaded: ${arrivedDriversSnapshot.docs.length}');

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
          PopupMenuButton<String>(
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
                                      child: CircularProgressIndicator());
                                }

                                final driverData =
                                    snapshot.data!['driver'] ?? {};
                                final tripData = snapshot.data!['trip'] ?? {};

                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, right: 5, left: 5),
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ListTile(
                                          // leading: CircleAvatar(
                                          //     radius: 20,
                                          //     backgroundImage: driverData['profilePictureUrl'] !=
                                          //             null
                                          //         ? NetworkImage(driverData['profilePictureUrl'])
                                          //         : AssetImage(
                                          //                 'assets/tuktuk.jpg')
                                          //             as ImageProvider, // Fallback image if no URL
                                          //   ),
                                          trailing: GestureDetector(
                                            child: Icon(Icons.phone),
                                            onTap: () {
                                              final phoneNumber =
                                                  driverData['phone'];
                                              if (phoneNumber != null &&
                                                  phoneNumber.isNotEmpty) {
                                                _launchPhoneNumber(phoneNumber);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Phone number is unavailable')),
                                                );
                                              }
                                            },
                                          ),
                                          title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${index + 1}. ${driverData['name']} - ${driverData['numberPlate']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),

                                              SizedBox(
                                                height: 4,
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Passenger ${tripData['no_of_person']}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400),  maxLines:
                                                          null, // Allow multiple lines
                                                      softWrap:
                                                          true, // Enable text wrapping
                                                      overflow: TextOverflow
                                                          .visible, 
                                                    // Ensure text overflows correctly
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Icon(Icons.info_outline,size: 14,),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      '${tripData['vehicle_mode']}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      maxLines:
                                                          null, // Allow multiple lines
                                                      softWrap:
                                                          true, // Enable text wrapping
                                                      overflow: TextOverflow
                                                          .visible, // Ensure text overflows correctly
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  'सम्पर्क: ${driverData['phone']}'),
                                                  Divider(),
                                              Text(
                                                  'ब्राण्ड: ${driverData['brand']}'),
                                                  Divider(),
                                              Text(
                                                  'रङ: ${driverData['color']}'),
                                                  Divider(),
                                              Text(
                                                  'चालकको ठेगाना: ${driverData['address']}'),
                                              
                                                  Divider(),
                                              Text(
                                                  'उठाउने स्थान: ${tripData['pickupLocation'] ?? 'N/A'}'),
                                                  Divider(),
                                              Text(
                                                  'डेलिभरी स्थान: ${tripData['deliveryLocation'] ?? 'N/A'}'),
Divider(),
                                                  Text(
                                                  'दूरी: ${tripData['distance'] ?? 'N/A'}'),

Divider(),
                                                  Text(
                                                  'भाडा: ${tripData['fare'] ?? 'N/A'}'),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: -20,
                                          right: -10,
                                          child: CircleAvatar(
                                            radius: 21,
                                            backgroundImage: driverData[
                                                        'profilePictureUrl'] !=
                                                    null
                                                ? NetworkImage(driverData[
                                                    'profilePictureUrl'])
                                                : AssetImage(
                                                        'assets/tuktuk.jpg')
                                                    as ImageProvider,
                                          ),
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
                                  return Text('Loading ...');
                                }

                                if (snapshot.hasError || !snapshot.hasData) {
                                  return Text('Error loading data');
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

                                final no_of_person =
                                    tripData['no_of_person'] ?? 'N/A';

                                final vehicle_mode =
                                    tripData['vehicle_mode'] ?? 'N/A';

                                final fare = tripData['fare'] ?? 'N/A';
                                final distance = tripData['distance'] ?? 'N/A';

                                return Card(
                                  elevation: 5,
                                  margin: EdgeInsets.all(10),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            radius: 20,
                                            backgroundImage: profilePicture !=
                                                    null
                                                ? NetworkImage(profilePicture)
                                                : AssetImage(
                                                        'assets/tuktuk.jpg')
                                                    as ImageProvider, // Fallback image if no URL
                                          ),
                                          title: Column(
                                            children: [
                                              Text(
                                                '${index+1} . $name - $numberPlate',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines:
                                                    null, // Allow multiple lines
                                                softWrap:
                                                    true, // Enable text wrapping
                                                overflow: TextOverflow
                                                    .visible, // Ensure text overflows correctly
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Passenger $no_of_person',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      maxLines:
                                                          null, // Allow multiple lines
                                                      softWrap:
                                                          true, // Enable text wrapping
                                                      overflow: TextOverflow
                                                          .visible, // Ensure text overflows correctly
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Icon(Icons.info_outline,size: 13,),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      '$vehicle_mode',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      maxLines:
                                                          null, // Allow multiple lines
                                                      softWrap:
                                                          true, // Enable text wrapping
                                                      overflow: TextOverflow
                                                          .visible, // Ensure text overflows correctly
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            'सवारी साधन : $brand $vehicleType ($color)',
                                            maxLines:
                                                null, // Allow multiple lines
                                            softWrap:
                                                true, // Enable text wrapping
                                            overflow: TextOverflow
                                                .visible, // Ensure text overflows correctly
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(_expandedStates[index]
                                                ? Icons.expand_less
                                                : Icons.expand_more),
                                            onPressed: () {
                                              setState(() {
                                                _expandedStates[index] =
                                                    !_expandedStates[
                                                        index]; // Toggle expansion
                                              });
                                            },
                                          ),
                                        ),
                                        if (_expandedStates[index])
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20, left: 18),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'सम्पर्क : ',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Expanded(
                                                      // Wrap the phone text to ensure it fits
                                                      child: Text(
                                                        '$phone',
                                                        maxLines:
                                                            null, // Allow multiple lines
                                                        softWrap:
                                                            true, // Enable text wrapping
                                                        overflow: TextOverflow
                                                            .visible, // Ensure text overflows correctly
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 2),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'चालकको ठेगाना : ',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Expanded(
                                                      // Wrap the address text to ensure it fits
                                                      child: Text(
                                                        '$address',
                                                        maxLines:
                                                            null, // Allow multiple lines
                                                        softWrap:
                                                            true, // Enable text wrapping
                                                        overflow: TextOverflow
                                                            .visible, // Ensure text overflows correctly
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 2),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'उठाउने स्थान : ',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Expanded(
                                                      // Wrap the pickup location text to ensure it fits
                                                      child: Text(
                                                        '$pickupLocation',
                                                        maxLines:
                                                            null, // Allow multiple lines
                                                        softWrap:
                                                            true, // Enable text wrapping
                                                        overflow: TextOverflow
                                                            .visible, // Ensure text overflows correctly
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 2),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'डेलिभरी स्थान : ',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Expanded(
                                                      // Wrap the delivery location text to ensure it fits
                                                      child: Text(
                                                        '$deliveryLocation',
                                                        maxLines:
                                                            null, // Allow multiple lines
                                                        softWrap:
                                                            true, // Enable text wrapping
                                                        overflow: TextOverflow
                                                            .visible, // Ensure text overflows correctly
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 2),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'भाडा : ',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Expanded(
                                                      // Wrap the fare text to ensure it fits
                                                      child: Text(
                                                        '$fare',
                                                        maxLines:
                                                            null, // Allow multiple lines
                                                        softWrap:
                                                            true, // Enable text wrapping
                                                        overflow: TextOverflow
                                                            .visible, // Ensure text overflows correctly
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 2),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'दूरी : ',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Expanded(
                                                      // Wrap the distance text to ensure it fits
                                                      child: Text(
                                                        '$distance km',
                                                        maxLines:
                                                            null, // Allow multiple lines
                                                        softWrap:
                                                            true, // Enable text wrapping
                                                        overflow: TextOverflow
                                                            .visible, // Ensure text overflows correctly
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Divider(),
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: _buttonStates[
                                                                  tripId] ==
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
                                                        backgroundColor:
                                                            _buttonStates[
                                                                        tripId] ==
                                                                    true
                                                                ? Colors.grey
                                                                : null,
                                                      ),
                                                      child: Text(
                                                        _buttonStates[tripId] ==
                                                                true
                                                            ? 'Confirmed'
                                                            : 'Confirm',
                                                      ),
                                                    ),
                                                    SizedBox(width: 20),
                                                    GestureDetector(
                                                      child: Icon(Icons.phone),
                                                      onTap: () {
                                                        final phoneNumber =
                                                            phone;
                                                        if (phoneNumber !=
                                                                null &&
                                                            phoneNumber
                                                                .isNotEmpty) {
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
                                                  ],
                                                ),
                                              ],
                                            ),
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
                    ],
                  ],
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
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
}
