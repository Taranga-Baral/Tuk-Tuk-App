
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// class RequestPage extends StatefulWidget {
//   final String userId;

//   RequestPage({required this.userId});

//   @override
//   _RequestPageState createState() => _RequestPageState();
// }

// class _RequestPageState extends State<RequestPage> {
//   List<DocumentSnapshot> requests = [];
//   List<DocumentSnapshot> arrivedDrivers = [];
//   bool isDataLoaded = false;
//   bool showArrivedDrivers = false;
//   final Map<int, bool> _buttonStates = {}; // Track button states
//   bool _isOnline = true; // Track connectivity status

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

//       setState(() {
//         requests = requestsSnapshot.docs;
//         arrivedDrivers = arrivedDriversSnapshot.docs;
//         isDataLoaded = true;
//       });
//     } catch (e) {
//       print('Error loading data: $e');
//       // Handle errors as needed
//     }
//   }

//   Future<void> confirmRequest(String userId, String driverId, String tripId, int index) async {
//     if (!_isOnline) {
//       // If offline, display message without changing button state
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('No internet connection.'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _buttonStates[index] = true; // Darken and disable button
//     });

//     try {
//       await FirebaseFirestore.instance.collection('confirmedDrivers').add({
//         'userId': userId,
//         'driverId': driverId,
//         'tripId': tripId,
//         'confirmedAt': FieldValue.serverTimestamp(),
//       });

//       setState(() {
//         requests.removeAt(index);
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Request confirmed and stored in Firebase.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _buttonStates[index] = false; // Re-enable button if error occurs
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
//                 if (value == 'requests') {
//                   showArrivedDrivers = false;
//                 } else if (value == 'arrivedDrivers') {
//                   showArrivedDrivers = true;
//                 }
//               });
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 'requests',
//                 child: Text('Requests'),
//               ),
//               PopupMenuItem(
//                 value: 'arrivedDrivers',
//                 child: Text('Arrived Drivers'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: isDataLoaded
//           ? showArrivedDrivers
//               ? ListView.builder(
//                   itemCount: arrivedDrivers.length,
//                   itemBuilder: (context, index) {
//                     final driver = arrivedDrivers[index];
//                     final driverId = driver['driverId'];
//                     final tripId = driver['tripId'];

//                     return FutureBuilder<Map<String, dynamic>>(
//                       future: _getDriverAndTripDetails(driverId, tripId),
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData) {
//                           return Center(child: CircularProgressIndicator());
//                         }

//                         final driverData = snapshot.data!['driver'];
//                         final tripData = snapshot.data!['trip'];

//                         return Card(
//                           margin: EdgeInsets.all(10),
//                           child: ListTile(
//                             title: Text('${driverData['name']} - ${driverData['numberPlate']}'),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Phone: ${driverData['phone']}'),
//                                 Text('Brand: ${driverData['brand']}'),
//                                 Text('Color: ${driverData['color']}'),
//                                 Text('Address: ${driverData['address']}'),
//                                 SizedBox(height: 10),
//                                 Text('Pickup Location: ${tripData['pickupLocation']}'),
//                                 Text('Delivery Location: ${tripData['deliveryLocation']}'),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 )
//               : ListView.builder(
//                   itemCount: requests.length,
//                   itemBuilder: (context, index) {
//                     final request = requests[index];
//                     final tripId = request['tripId'];
//                     final driverId = request['driverId'];
//                     final userId = request['userId'];

//                     return Card(
//                       margin: EdgeInsets.all(10),
//                       child: ListTile(
//                         title: Text('Trip ID: $tripId'),
//                         subtitle: Text('Driver ID: $driverId'),
//                         trailing: ElevatedButton(
//                           onPressed: _buttonStates[index] == true
//                               ? null
//                               : () {
//                                   confirmRequest(userId, driverId, tripId, index);
//                                 },
//                           child: Text('Confirm'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _buttonStates[index] == true
//                                 ? Colors.grey
//                                 : null,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 )
//           : Center(child: CircularProgressIndicator()),
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestPage extends StatefulWidget {
  final String userId;

  RequestPage({required this.userId});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List<DocumentSnapshot> requests = [];
  List<DocumentSnapshot> arrivedDrivers = [];
  bool isDataLoaded = false;
  bool showArrivedDrivers = false;
  bool _isOnline = true; // Track connectivity status
  final Map<String, bool> _buttonStates = {}; // Track button states per trip using tripId (String)

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
          _buttonStates[tripId] = confirmedSnapshot.docs.isNotEmpty; // Button is darkened if confirmed
        });
      }

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

  

  Future<void> confirmRequest(String userId, String driverId, String tripId) async {
    if (!_isOnline) {
      // If offline, display message without changing button state
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
          ? showArrivedDrivers
              ? ListView.builder(
                  itemCount: arrivedDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = arrivedDrivers[index];
                    final driverId = driver['driverId'];
                    final tripId = driver['tripId'];

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getDriverAndTripDetails(driverId, tripId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final driverData = snapshot.data!['driver'];
                        final tripData = snapshot.data!['trip'];

                        return Card(
  margin: EdgeInsets.all(10),
  child: ListTile(
    trailing: GestureDetector(
      child: Icon(Icons.phone),
      onTap: () {
        final phoneNumber = driverData['phone']; // Get the phone number from the driverData
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          _launchPhoneNumber(phoneNumber); // Launch the phone dialer
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone number is unavailable')),
          );
        }
      },
    ),
    title: Text('${driverData['name']} - ${driverData['numberPlate']}'),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone: ${driverData['phone']}'),
        Text('Brand: ${driverData['brand']}'),
        Text('Color: ${driverData['color']}'),
        Text('Address: ${driverData['address']}'),
        SizedBox(height: 10),
        Text('Pickup Location: ${tripData['pickupLocation']}'),
        Text('Delivery Location: ${tripData['deliveryLocation']}'),
      ],
    ),
  ),
);

                      },
                    );
                  },
                )
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final tripId = request['tripId'];
                    final driverId = request['driverId'];
                    final userId = request['userId'];

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('Trip ID: $tripId'),
                        subtitle: Text('Driver ID: $driverId'),
                        trailing: ElevatedButton(
                          onPressed: _buttonStates[tripId] == true
                              ? null
                              : () {
                                  confirmRequest(userId, driverId, tripId);
                                },
                          child: Text(
                              _buttonStates[tripId] == true ? 'Confirmed' : 'Confirm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonStates[tripId] == true
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Future<Map<String, dynamic>> _getDriverAndTripDetails(String driverId, String tripId) async {
    final driverSnapshot = await FirebaseFirestore.instance.collection('vehicleData').doc(driverId).get();
    final tripSnapshot = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();

    return {
      'driver': driverSnapshot.data(),
      'trip': tripSnapshot.data(),
    };
  }
}
