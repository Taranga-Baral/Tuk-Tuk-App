// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class DriverAcceptedPage extends StatefulWidget {
//   final String driverId;

//   const DriverAcceptedPage({super.key, required this.driverId});

//   @override
//   _DriverAcceptedPageState createState() => _DriverAcceptedPageState();
// }

// Map<String, bool> _isButtonPressed = {};
// Map<String, bool> _isEndButtonEnabled = {};

// class _DriverAcceptedPageState extends State<DriverAcceptedPage> {
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

//   Future<void> _launchPhoneNumber(String phoneNumber) async {
//     final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(launchUri)) {
//       await launchUrl(launchUri);
//     } else {
//       print('Could not launch $launchUri');
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Accepted Requests'),
//         // Removed the sorting options from the app bar
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('confirmedDrivers')
//             .where('driverId', isEqualTo: widget.driverId)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No accepted requests for this driver.'));
//           }

//           // Removed sorting call
//           List<QueryDocumentSnapshot> requests = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               final request = requests[index];
//               final userId = request['userId'];
//               final tripId = request['tripId'];

//               return FutureBuilder<List<Map<String, dynamic>>>(
//                 future: Future.wait([
//                   _fetchUserDetails(userId),
//                   _fetchTripDetails(tripId),
//                 ]),
//                 builder: (context,
//                     AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   if (!snapshot.hasData) {
//                     return Center(child: Text('Error loading details'));
//                   }

//                   final userDetails = snapshot.data![0];
//                   final tripDetails = snapshot.data![1];
//                   final isButtonDisabled = _isButtonPressed[tripId] ?? false;
//                   final isSendButtonDisabled =
//                       _isButtonPressed[tripId] ?? false;
//                   final isEndButtonEnabled =
//                       _isEndButtonEnabled[tripId] ?? false;
//                   return Card(
//                     margin: EdgeInsets.all(10),
//                     child: ListTile(
//                       title: Text('Trip ID: $tripId'),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('User ID: $userId'),
//                           Text('Username: ${userDetails['username']}'),
//                           Text('Phone: ${userDetails['phone_number']}'),
//                           Text(
//                               'Pickup Location: ${tripDetails['pickupLocation']}'),
//                           Text(
//                               'Delivery Location: ${tripDetails['deliveryLocation']}'),
//                           Text('Fare: ${tripDetails['fare']}'),
//                           Text('Distance: ${tripDetails['distance']}'),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.phone),
//                                 onPressed: () {
//                                   final phoneNumber =
//                                       userDetails['phone'] ?? '';
//                                   if (phoneNumber.isNotEmpty) {
//                                     _launchPhoneNumber(phoneNumber);
//                                   }
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.map),
//                                 onPressed: () {
//                                   final pickupLocation =
//                                       tripDetails['pickupLocation'] ?? '';
//                                   final deliveryLocation =
//                                       tripDetails['deliveryLocation'] ?? '';
//                                   if (pickupLocation.isNotEmpty &&
//                                       deliveryLocation.isNotEmpty) {
//                                     _launchOpenStreetMapWithDirections(
//                                         pickupLocation, deliveryLocation);
//                                   }
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.send),
//                                 color: isSendButtonDisabled
//                                     ? Colors.grey
//                                     : Colors.blue,
//                                 onPressed: isSendButtonDisabled
//                                     ? null
//                                     : () async {
//                                         final isNetworkAvailable =
//                                             await _checkNetworkStatus();
//                                         if (isNetworkAvailable) {
//                                           try {
//                                             await FirebaseFirestore.instance
//                                                 .collection('arrivedDrivers')
//                                                 .add({
//                                               'tripId': tripId,
//                                               'driverId': widget.driverId,
//                                               'userId': userId,
//                                               'timestamp':
//                                                   FieldValue.serverTimestamp(),
//                                             });

//                                             setState(() {
//                                               _isButtonPressed[tripId] =
//                                                   true; // Disable the send button
//                                               _isEndButtonEnabled[tripId] =
//                                                   true; // Enable the end button
//                                             });

//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(
//                                               SnackBar(
//                                                   content: Text(
//                                                       'Driver arrival recorded')),
//                                             );
//                                           } catch (e) {
//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(
//                                               SnackBar(
//                                                   content: Text(
//                                                       'Failed to record arrival')),
//                                             );
//                                           }
//                                         } else {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                                 content: Text(
//                                                     'No network connection')),
//                                           );
//                                         }
//                                       },
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.done_all),
//                                 color: isEndButtonEnabled
//                                     ? Colors.green
//                                     : Colors.grey,
//                                 onPressed: isEndButtonEnabled
//                                     ? () async {
//                                         try {
//                                           await FirebaseFirestore.instance
//                                               .collection('successfulTrips')
//                                               .add({
//                                             'tripId': tripId,
//                                             'driverId': widget.driverId,
//                                             'userId': userId,
//                                             'timestamp':
//                                                 FieldValue.serverTimestamp(),
//                                           });

//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                                 content: Text(
//                                                     'Trip marked as successful')),
//                                           );
//                                         } catch (e) {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                                 content: Text(
//                                                     'Failed to mark trip as successful')),
//                                           );
//                                         }
//                                       }
//                                     : null, // Disable the end button if send button wasn't pressed
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
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
import 'package:final_menu/driver_chat_page/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverAcceptedPage extends StatefulWidget {
  final String driverId;

  const DriverAcceptedPage({super.key, required this.driverId});

  @override
  _DriverAcceptedPageState createState() => _DriverAcceptedPageState();
}

Map<String, bool> _isSendButtonPressed = {};
Map<String, bool> _isDoneButtonPressed = {};

class _DriverAcceptedPageState extends State<DriverAcceptedPage> {
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

  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accepted Requests'),
        // Removed the sorting options from the app bar
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('confirmedDrivers')
            .where('driverId', isEqualTo: widget.driverId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No accepted requests for this driver.'));
          }

          List<QueryDocumentSnapshot> requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final userId = request['userId'];
              final tripId = request['tripId'];

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: Future.wait([
                  _fetchUserDetails(userId),
                  _fetchTripDetails(tripId),
                ]),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return Center(child: Text('Error loading details'));
                  }

                  final userDetails = snapshot.data![0];
                  final tripDetails = snapshot.data![1];
                  final isSendButtonPressed =
                      _isSendButtonPressed[tripId] ?? false;
                  final isDoneButtonEnabled =
                      _isDoneButtonPressed[tripId] ?? false;
                  return Card(
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
                          Row(
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
                                          userId: userId)));
                        },
                      ),
                              IconButton(
                                icon: Icon(Icons.phone),
                                onPressed: () {
                                  final phoneNumber =
                                      userDetails['phone'] ?? '';
                                  if (phoneNumber.isNotEmpty) {
                                    _launchPhoneNumber(phoneNumber);
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
                                    ? Colors.green
                                    : Colors.greenAccent,
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

                                            setState(() {
                                              _isSendButtonPressed[tripId] =
                                                  true; // Disable the send button and turn it green
                                              // Enable the done button only after send button is pressed
                                              _isDoneButtonPressed[tripId] =
                                                  false; // Initially set to false
                                            });

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Driver arrival recorded')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to record arrival')),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'No network connection')),
                                          );
                                        }
                                      },
                              ),
                              IconButton(
                                icon: Icon(Icons.done_all),
                                color: isDoneButtonEnabled
                                    ? Colors.green
                                    : Colors.greenAccent,
                                onPressed: isSendButtonPressed
                                    ? (isDoneButtonEnabled
                                        ? null
                                        : () async {
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('successfulTrips')
                                                  .add({
                                                'tripId': tripId,
                                                'driverId': widget.driverId,
                                                'userId': userId,
                                                'timestamp': FieldValue
                                                    .serverTimestamp(),
                                              });

                                              setState(() {
                                                _isDoneButtonPressed[tripId] =
                                                    true; // Turn the done button green and make it unpressable
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Trip marked as successful')),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to mark trip as successful')),
                                              );
                                            }
                                          })
                                    : null,
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
          );
        },
      ),
    );
  }
}
