// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
// import 'package:final_menu/driver_chat_page/chat_detail_page.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class DriverAcceptedPage extends StatefulWidget {
//   final String driverId;

//   const DriverAcceptedPage({
//     super.key,
//     required this.driverId,
//   });

//   @override
//   _DriverAcceptedPageState createState() => _DriverAcceptedPageState();
// }

// class _DriverAcceptedPageState extends State<DriverAcceptedPage> {
//   bool isExpanded = false; // State variable to track expansion
//   List<QueryDocumentSnapshot> requests = [];
//   bool isLoadingMore = false;
//   bool hasMoreData = true;
//   DocumentSnapshot? lastDocument; // Track last loaded document

//   Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
//     final userDoc =
//         await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     if (userDoc.exists) {
//       return userDoc.data()!;
//     } else {
//       return {'username': 'Unknown', 'phone': 'Unknown'};
//     }
//   }

//   Future<Map<String, dynamic>> _fetchTripDetails(String tripId) async {
//     final tripDoc =
//         await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
//     if (tripDoc.exists) {
//       return tripDoc.data()!;
//     } else {
//       return {
//         'pickupLocation': 'Unknown',
//         'deliveryLocation': 'Unknown',
//         'fare': '0',
//         'distance': '0',
//       };
//     }
//   }

//   Future<bool> _checkNetworkStatus() async {
//     try {
//       final result = await http.get(Uri.parse('https://www.google.com'));
//       return result.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<Map<String, double>> _geocodeAddress(String address) async {
//     final response = await http.get(Uri.parse(
//         'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data.isNotEmpty) {
//         return {
//           'latitude': double.parse(data[0]['lat']),
//           'longitude': double.parse(data[0]['lon']),
//         };
//       }
//     }
//     throw Exception('Failed to geocode address');
//   }

//   Future<void> _launchOpenStreetMapWithDirections(
//       String pickupLocation, String deliveryLocation) async {
//     try {
//       final pickupCoords = _parseCoordinates(pickupLocation) ??
//           await _geocodeAddress(pickupLocation);
//       final deliveryCoords = _parseCoordinates(deliveryLocation) ??
//           await _geocodeAddress(deliveryLocation);

//       final pickupLatitude = pickupCoords['latitude']!;
//       final pickupLongitude = pickupCoords['longitude']!;
//       final deliveryLatitude = deliveryCoords['latitude']!;
//       final deliveryLongitude = deliveryCoords['longitude']!;

//       final String openStreetMapUrl =
//           'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

//       final Uri launchUri = Uri.parse(openStreetMapUrl);

//       if (await canLaunchUrl(launchUri)) {
//         await launchUrl(launchUri);
//       } else {
//         print('Could not launch $launchUri');
//       }
//     } catch (e) {
//       print('Error fetching trip details: $e');
//     }
//   }

//   Map<String, double>? _parseCoordinates(String location) {
//     final parts = location.split(',');
//     if (parts.length == 2) {
//       final latitude = double.tryParse(parts[0]);
//       final longitude = double.tryParse(parts[1]);
//       if (latitude != null && longitude != null) {
//         return {'latitude': latitude, 'longitude': longitude};
//       }
//     }
//     return null;
//   }

//   // Fetch the button states from Firebase for each trip
//   Future<Map<String, bool>> _fetchButtonStates(String tripId) async {
//     final buttonStateDoc = await FirebaseFirestore.instance
//         .collection('tripButtonStates')
//         .doc(tripId)
//         .get();

//     if (buttonStateDoc.exists) {
//       final data = buttonStateDoc.data()!;
//       return {
//         'isSendButtonPressed': data['isSendButtonPressed'] ?? false,
//         'isDoneButtonPressed': data['isDoneButtonPressed'] ?? false,
//       };
//     } else {
//       return {
//         'isSendButtonPressed': false, // Default to not pressed
//         'isDoneButtonPressed': false, // Default to not pressed
//       };
//     }
//   }

//   // Update button states in Firebase for each trip
//   Future<void> _updateButtonStates(
//       String tripId, bool isSendPressed, bool isDonePressed) async {
//     await FirebaseFirestore.instance
//         .collection('tripButtonStates')
//         .doc(tripId)
//         .set({
//       'isSendButtonPressed': isSendPressed,
//       'isDoneButtonPressed': isDonePressed,
//     }, SetOptions(merge: true));
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() {
//       isLoadingMore = true;
//     });

//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('confirmedDrivers')
//         .where('driverId', isEqualTo: widget.driverId)
//         .orderBy('confirmedAt', descending: true)
//         .limit(10) // Load first 20 documents
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       requests = snapshot.docs;
//       lastDocument = snapshot.docs.last; // Track the last document
//     } else {
//       hasMoreData = false; // No more data available
//     }

//     setState(() {
//       isLoadingMore = false;
//     });
//   }

//   Future<void> _loadMoreData() async {
//     if (!isLoadingMore && hasMoreData) {
//       setState(() {
//         isLoadingMore = true;
//       });

//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('confirmedDrivers')
//           .where('driverId', isEqualTo: widget.driverId)
//           .orderBy('confirmedAt', descending: true)
//           .startAfterDocument(lastDocument!) // Start after the last document
//           .limit(10)
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         requests.addAll(snapshot.docs);
//         lastDocument = snapshot.docs.last; // Update last document
//       } else {
//         hasMoreData = false; // No more data available
//       }

//       setState(() {
//         isLoadingMore = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         appBarColor: Colors.teal,
//         appBarIcons: const [
//           Icons.arrow_back,
//           Icons.info_outline,
//         ],
//         title: 'Accepted Requests',
//         driverId: widget.driverId, // Pass the driverId
//       ),
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (ScrollNotification scrollInfo) {
//           if (!isLoadingMore &&
//               scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
//             _loadMoreData();
//           }
//           return true;
//         },
//     child: ListView.builder(
//         itemCount: requests.length,
//         itemBuilder: (context, index) {
//           final request = requests[index];
//           final userId = request['userId'];
//           final tripId = request['tripId'];

//           return FutureBuilder<List<Map<String, dynamic>>>(
//             future: Future.wait([
//               _fetchUserDetails(userId),
//               _fetchTripDetails(tripId),
//               _fetchButtonStates(tripId),
//             ]),
//             builder: (context,
//                 AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               if (!snapshot.hasData) {
//                 return Center(child: Text('Error loading details'));
//               }

//               final userDetails = snapshot.data![0];
//               final tripDetails = snapshot.data![1];
//               final buttonStates = snapshot.data![2];
//               final isSendButtonPressed =
//                   buttonStates['isSendButtonPressed'] ?? false;
//               final isDoneButtonPressed =
//                   buttonStates['isDoneButtonPressed'] ?? false;

//               return Card(
//                 color: Colors.teal.shade50,
//                 elevation: 5,
//                 margin: EdgeInsets.all(10),
//                 child: ListTile(
//                   title: Text('Username: ${userDetails['username']}'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Phone: ${userDetails['phone_number']}'),
//                       Text(
//                           'Pickup Location: ${tripDetails['pickupLocation']}'),
//                       Text(
//                           'Delivery Location: ${tripDetails['deliveryLocation']}'),
//                       Text('Fare: ${tripDetails['fare']}'),
//                       Text('Distance: ${tripDetails['distance']}'),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.chat),
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (BuildContext context) =>
//                                       DriverChatDisplayPage(
//                                           driverId: widget.driverId,
//                                           tripId: tripId,
//                                           userId: userId),
//                                 ),
//                               );
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.phone),
//                             onPressed: () {
//                               final phoneNumber =
//                                   userDetails['phone_number'];
//                               if (phoneNumber != null &&
//                                   phoneNumber.isNotEmpty) {
//                                 _launchPhoneNumber(phoneNumber);
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content:
//                                         Text('Phone number unavailable'),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.map),
//                             onPressed: () {
//                               final pickupLocation =
//                                   tripDetails['pickupLocation'] ?? '';
//                               final deliveryLocation =
//                                   tripDetails['deliveryLocation'] ?? '';
//                               if (pickupLocation.isNotEmpty &&
//                                   deliveryLocation.isNotEmpty) {
//                                 _launchOpenStreetMapWithDirections(
//                                     pickupLocation, deliveryLocation);
//                               }
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.send),
//                             color: isSendButtonPressed
//                                 ? Colors.grey
//                                 : Colors.teal,
//                             onPressed: isSendButtonPressed
//                                 ? null
//                                 : () async {
//                                     final isNetworkAvailable =
//                                         await _checkNetworkStatus();
//                                     if (isNetworkAvailable) {
//                                       try {
//                                         await FirebaseFirestore.instance
//                                             .collection('arrivedDrivers')
//                                             .add({
//                                           'tripId': tripId,
//                                           'driverId': widget.driverId,
//                                           'userId': userId,
//                                           'timestamp':
//                                               FieldValue.serverTimestamp(),
//                                         });

//                                         // Update button states when send is pressed
//                                         await _updateButtonStates(
//                                             tripId, true, false);
//                                         setState(() {});

//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                               content: Text(
//                                                   'Driver request sent successfully')),
//                                         );
//                                       } catch (e) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                               content: Text(
//                                                   'Failed to send driver. Try again.')),
//                                         );
//                                       }
//                                     } else {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         SnackBar(
//                                             content: Text(
//                                                 'No network connection available')),
//                                       );
//                                     }
//                                   },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.done_all),
//                             color:
//                                 isSendButtonPressed && !isDoneButtonPressed
//                                     ? Colors.teal
//                                     : Colors.grey,
//                             onPressed:
//                                 isSendButtonPressed && !isDoneButtonPressed
//                                     ? () async {
//                                         // When done_all button is pressed, mark both buttons as unpressable
//                                         await _updateButtonStates(
//                                             tripId, true, true);

//                                         await FirebaseFirestore.instance
//                                             .collection('successfulTrips')
//                                             .add({
//                                           'tripId': tripId,
//                                           'driverId': widget.driverId,
//                                           'userId': userId,
//                                           'timestamp':
//                                               FieldValue.serverTimestamp(),
//                                         });

//                                         setState(() {});

//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                               content: Text(
//                                                   'Request completed and deleted.')),
//                                         );
//                                       }
//                                     : null,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//   ),
// );
//   }

//  Future<void> _launchPhoneNumber(String phoneNumber) async {
//   final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//   if (await canLaunchUrl(launchUri)) {
//     await launchUrl(launchUri);
//   } else {
//     print('Could not launch $launchUri');
//   }
// }

// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
import 'package:final_menu/driver_chat_page/chat_detail_page.dart';
import 'package:final_menu/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class DriverAcceptedPage extends StatefulWidget {
  final String driverId;

  const DriverAcceptedPage({
    super.key,
    required this.driverId,
  });

  @override
  _DriverAcceptedPageState createState() => _DriverAcceptedPageState();
}

class _DriverAcceptedPageState extends State<DriverAcceptedPage> {
  bool isExpanded = false; // State variable to track expansion
  List<QueryDocumentSnapshot> requests = [];
  bool isLoadingMore = false;
  bool hasMoreData = true;
  DocumentSnapshot? lastDocument; // Track last loaded document



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
        .limit(10) // Load first 10 documents
        .get();

    if (snapshot.docs.isNotEmpty) {
      requests = snapshot.docs;
      lastDocument = snapshot.docs.last; // Track the last document
    } else {
      hasMoreData = false; // No more data available
    }

    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> _loadMoreData() async {
    if (!isLoadingMore && hasMoreData) {
      setState(() {
        isLoadingMore = true;
      });

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('confirmedDrivers')
          .where('driverId', isEqualTo: widget.driverId)
          .orderBy('confirmedAt', descending: true)
          .startAfterDocument(lastDocument!) // Start after the last document
          .limit(10)
          .get();

      if (snapshot.docs.isNotEmpty) {
        requests.addAll(snapshot.docs);
        lastDocument = snapshot.docs.last; // Update last document
      } else {
        hasMoreData = false; // No more data available
      }

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
        title: 'Accepted Requests',
        driverId: widget.driverId, // Pass the driverId
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoadingMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreData();
          }
          return true;
        },
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
                  return (Center(
                    child: Image(image: AssetImage("assets/logo.png")),
                  ));
                }

                if (!snapshot.hasData) {
                  return Center(child: Text('Error loading details'));
                }

                final userDetails = snapshot.data![0];
                final tripDetails = snapshot.data![1];
                final buttonStates = snapshot.data![2];
                final isSendButtonPressed =
                    buttonStates['isSendButtonPressed'] ?? false;
                final isDoneButtonPressed =
                    buttonStates['isDoneButtonPressed'] ?? false;

                return Card(
                  color: Colors.teal.shade50,
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('Username: ${userDetails['username']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone: ${userDetails['phone_number']}'),
                        Text(
                            'Pickup Location: ${tripDetails['pickupLocation']}'),
                        Text(
                            'Delivery Location: ${tripDetails['deliveryLocation']}'),
                        Text('Fare: ${tripDetails['fare']}'),
                        Text('Distance: ${tripDetails['distance']}'),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chat),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          DriverChatDisplayPage(
                                              driverId: widget.driverId,
                                              tripId: tripId,
                                              userId: userId),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.phone),
                                onPressed: () {
                                  final phoneNumber =
                                      userDetails['phone_number'];
                                  if (phoneNumber != null &&
                                      phoneNumber.isNotEmpty) {
                                    _launchPhoneNumber(phoneNumber);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Phone number unavailable'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.map),
                                onPressed: () {
                                  final pickupLocation =
                                      tripDetails['pickupLocation'] ?? '';
                                  final deliveryLocation =
                                      tripDetails['deliveryLocation'] ?? '';
                                  if (pickupLocation.isNotEmpty &&
                                      deliveryLocation.isNotEmpty) {
                                    _launchOpenStreetMapWithDirections(
                                        pickupLocation, deliveryLocation);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.send),
                                color: isSendButtonPressed
                                    ? Colors.grey
                                    : Colors.teal,
                                onPressed: isSendButtonPressed
                                    ? null
                                    : () async {
                                        final isNetworkAvailable =
                                            await _checkNetworkStatus();
                                        if (isNetworkAvailable) {
                                          try {
                                          

                                            await FirebaseFirestore.instance
                                                .collection('arrivedDrivers')
                                                .add({
                                              'tripId': tripId,
                                              'driverId': widget.driverId,
                                              'userId': userId,
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                            });

                                            // Update button states when send is pressed
                                            await _updateButtonStates(
                                                tripId, true, false);
                                            setState(() {});

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Driver request sent successfully')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to send driver. Try again.')),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'No network connection available')),
                                          );
                                        }
                                      },
                              ),
                              IconButton(
                                icon: Icon(Icons.done_all),
                                color:
                                    isSendButtonPressed && !isDoneButtonPressed
                                        ? Colors.teal
                                        : Colors.grey,
                                onPressed:
                                    isSendButtonPressed && !isDoneButtonPressed
                                        ? () async {
                                            // When done_all button is pressed, mark both buttons as unpressable
                                            await _updateButtonStates(
                                                tripId, true, true);

                                            await FirebaseFirestore.instance
                                                .collection('successfulTrips')
                                                .add({
                                              'tripId': tripId,
                                              'driverId': widget.driverId,
                                              'userId': userId,
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                            });

                                            setState(() {});

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Request completed and deleted.')),
                                            );
                                          }
                                        : null,
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
}
