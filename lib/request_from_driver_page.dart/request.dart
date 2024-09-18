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
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('requestsofDrivers')
          .where('userId', isEqualTo: widget.userId)
          .get();
      final arrivedDriversSnapshot = await FirebaseFirestore.instance
          .collection('arrivedDrivers')
          .where('userId', isEqualTo: widget.userId)
          .get();

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

                                return Card(
                                  margin: EdgeInsets.all(10),
                                  child: Stack(
                                    children: [
                                      ListTile(
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
                                        title: Text(
                                            '${driverData['name']} - ${driverData['numberPlate']}'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '𝗣𝗵𝗼𝗻𝗲: ${driverData['phone']}'),
                                            Text(
                                                '𝗕𝗿𝗮𝗻𝗱: ${driverData['brand']}'),
                                            Text(
                                                '𝗖𝗼𝗹𝗼𝗿: ${driverData['color']}'),
                                            Text(
                                                '𝗔𝗱𝗱𝗿𝗲𝘀𝘀: ${driverData['address']}'),
                                            SizedBox(height: 10),
                                            Text(
                                                '𝗣𝗶𝗰𝗸𝘂𝗽: ${tripData['pickupLocation'] ?? 'N/A'}'),
                                            Text(
                                                '𝗗𝗲𝗹𝗶𝘃𝗲𝗿𝘆: ${tripData['deliveryLocation'] ?? 'N/A'}'),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 1,
                                        right: 10,
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          padding: EdgeInsets.all(8),
                                          child: Opacity(
                                            opacity: 0.8,
                                              child: Image.asset(
                                                  "images/arrived_auto.png")),
                                        ),
                                      ),
                                    ],
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
                                  return Text("Loading ...");
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
                                final fare = tripData['fare'] ?? 'N/A';
                                final distance = tripData['distance'] ?? 'N/A';

                                return Card(
                                  margin: EdgeInsets.all(10),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text('$name - $numberPlate'),
                                          subtitle: Text(
                                              '𝗩𝗲𝗵𝗶𝗰𝗹𝗲: $brand $vehicleType ($color)'),
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
                                                Text('𝗣𝗵𝗼𝗻𝗲: $phone'),
                                                Text(
                                                    '𝗔𝗱𝗱𝗿𝗲𝘀𝘀: $address'),
                                                Text(
                                                    '𝗣𝗶𝗰𝗸𝘂𝗽: $pickupLocation'),
                                                Text(
                                                    '𝗗𝗲𝗹𝗶𝘃𝗲𝗿𝘆: $deliveryLocation'),
                                                Text('𝗙𝗮𝗿𝗲: $fare'),
                                                Text(
                                                    '𝗗𝗶𝘀𝘁𝗮𝗻𝗰𝗲: $distance km'),
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
                                                    SizedBox(
                                                      width: 20,
                                                    ),
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
                                                    )
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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// class RequestPage extends StatefulWidget {
//   final String userId;

//   const RequestPage({super.key, required this.userId});

//   @override
//   _RequestPageState createState() => _RequestPageState();
// }

// class _RequestPageState extends State<RequestPage> {
//   List<DocumentSnapshot> requests = [];
//   List<DocumentSnapshot> arrivedDrivers = [];
//   bool isDataLoaded = false;
//   bool showArrivedDrivers = false;
//   bool _isOnline = true;
//   final Map<String, bool> _buttonStates = {};
  
//   @override
//   void initState() {
//     super.initState();
//     _checkConnectivity();
//     _loadData();
//   }

//   Future<void> _checkConnectivity() async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     setState(() {
//       _isOnline = connectivityResult != ConnectivityResult.none;
//     });
//   }

//   Future<void> _loadData() async {
//     try {
//       final requestsSnapshot = await FirebaseFirestore.instance
//           .collection('requestsofDrivers')
//           .where('userId', isEqualTo: widget.userId)
//           .get();

//       final arrivedDriversSnapshot = await FirebaseFirestore.instance
//           .collection('arrivedDrivers')
//           .where('userId', isEqualTo: widget.userId)
//           .get();

//       for (var request in requestsSnapshot.docs) {
//         final tripId = request['tripId'];
//         final confirmedSnapshot = await FirebaseFirestore.instance
//             .collection('confirmedDrivers')
//             .where('tripId', isEqualTo: tripId)
//             .get();

//         setState(() {
//           _buttonStates[tripId] = confirmedSnapshot.docs.isNotEmpty;
//         });
//       }

//       setState(() {
//         requests = requestsSnapshot.docs;
//         arrivedDrivers = arrivedDriversSnapshot.docs;
//         isDataLoaded = true;
//       });
//     } catch (e) {
//       print('Error loading data: $e');
//     }
//   }

//   Future<void> _launchPhoneNumber(String phoneNumber) async {
//     final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(launchUri)) {
//       await launchUrl(launchUri);
//     } else {
//       print('Could not launch $launchUri');
//     }
//   }

//   Future<void> confirmRequest(
//       String userId, String driverId, String tripId) async {
//     if (!_isOnline) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('No internet connection.'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance.collection('confirmedDrivers').add({
//         'userId': userId,
//         'driverId': driverId,
//         'tripId': tripId,
//         'confirmedAt': FieldValue.serverTimestamp(),
//       });

//       setState(() {
//         _buttonStates[tripId] = true;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Request confirmed and stored in Firebase.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _buttonStates[tripId] = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error confirming request: $e'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Requests Page'),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               setState(() {
//                 showArrivedDrivers = (value == 'arrivedDrivers');
//               });
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(value: 'requests', child: Text('Requests')),
//               PopupMenuItem(value: 'arrivedDrivers', child: Text('Arrived Drivers')),
//             ],
//           ),
//         ],
//       ),
//       body: isDataLoaded
//           ? LayoutBuilder(
//               builder: (context, constraints) {
//                 return Column(
//                   children: [
//                     if (showArrivedDrivers)
//                       _buildArrivedDriversList()
//                     else
//                       _buildRequestsList(),
//                   ],
//                 );
//               },
//             )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }

//   Widget _buildArrivedDriversList() {
//     return Flexible(
//       child: ListView.builder(
//         itemCount: arrivedDrivers.length,
//         itemBuilder: (context, index) {
//           final driver = arrivedDrivers[index];
//           final driverId = driver['driverId'];
//           final tripId = driver['tripId'];

//           return FutureBuilder<Map<String, dynamic>>(
//             future: _getDriverAndTripDetails(driverId, tripId),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               final driverData = snapshot.data!['driver'] ?? {};
//               final tripData = snapshot.data!['trip'] ?? {};

//               return Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Card(
//                   elevation: 5,
//                   margin: EdgeInsets.all(10),
//                   child: ListTile(
//                     title: Text('${driverData['name']} - ${driverData['numberPlate']}'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('𝗣𝗵𝗼𝗻𝗲: ${driverData['phone']}'),
//                         Text('𝗣𝗶𝗰𝗸𝘂𝗽: ${tripData['pickupLocation'] ?? 'N/A'}'),
//                         Text('𝗗𝗲𝗹𝗶𝘃𝗲𝗿𝘆: ${tripData['deliveryLocation'] ?? 'N/A'}'),
//                       ],
//                     ),
//                     trailing: GestureDetector(
//                       child: Icon(Icons.phone),
//                       onTap: () {
//                         final phoneNumber = driverData['phone'];
//                         if (phoneNumber != null && phoneNumber.isNotEmpty) {
//                           _launchPhoneNumber(phoneNumber);
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Phone number is unavailable')),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRequestsList() {
//     return Flexible(
//       child: ListView.builder(
//         itemCount: requests.length,
//         itemBuilder: (context, index) {
//           final request = requests[index];
//           final tripId = request['tripId'];
//           final driverId = request['driverId'];

//           return FutureBuilder(
//             future: Future.wait([
//               FirebaseFirestore.instance.collection('vehicleData').doc(driverId).get(),
//               FirebaseFirestore.instance.collection('trips').doc(tripId).get(),
//             ]),
//             builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
//               if (!snapshot.hasData) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               final vehicleData = snapshot.data![0].data() as Map<String, dynamic>;
//               final tripData = snapshot.data![1].data() as Map<String, dynamic>;

//               return Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(right: 8,left: 8,top: 8),
//                     child: Card(
                      
//                       elevation: 5,
//                       child: ExpansionTile(
//                         title: Text('${vehicleData['name']} - ${vehicleData['numberPlate']}'),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('𝗣𝗶𝗰𝗸𝘂𝗽: ${tripData['pickupLocation']}'),
//                             Text('𝗗𝗲𝗹𝗶𝘃𝗲𝗿𝘆: ${tripData['deliveryLocation']}'),
//                           ],
//                         ),
//                         trailing: ElevatedButton(
                          
//                           onPressed: _buttonStates[tripId] == true
//                               ? null
//                               : () => confirmRequest(request['userId'], driverId, tripId),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _buttonStates[tripId] == true ? Colors.grey : null,
//                           ),
//                           child: Text(_buttonStates[tripId] == true ? 'Confirmed' : 'Confirm'),
//                         ),
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.only(left: 17,bottom: 10),
//                             child: SizedBox(
//                               width: double.infinity ,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('𝗩𝗲𝗵𝗶𝗰𝗹𝗲: ${vehicleData['brand']} ${vehicleData['vehicleType']} (${vehicleData['color']})'),
                                  
//                                   Text('𝗙𝗮𝗿𝗲: ${tripData['fare']}'),
//                                   Text('𝗗𝗶𝘀𝘁𝗮𝗻𝗰𝗲: ${tripData['distance']} km'),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10,),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Future<Map<String, dynamic>> _getDriverAndTripDetails(String driverId, String tripId) async {
//     final driverSnapshot = await FirebaseFirestore.instance.collection('vehicleData').doc(driverId).get();
//     final tripSnapshot = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();

//     return {
//       'driver': driverSnapshot.data(),
//       'trip': tripSnapshot.data(),
//     };
//   }
// }
