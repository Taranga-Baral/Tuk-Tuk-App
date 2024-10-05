// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class HomePage extends StatefulWidget {
//   final String url;
//   const HomePage({super.key, required this.url});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   InAppWebViewController? webView;
//   bool _isLoading = true;
//   String? selectedMunicipality;
//   String? selectedMode;
//   int selectedPassengers = 1; // Default to 1 passenger
//   double fare = 0.0;

//   final List<Map<String, dynamic>> municipalitySections = [
//     {'title': 'Chitwan', 'municipalities': [
//       'Bharatpur Metropolitan City', 'Kalika Municipality', 'Khairahani Municipality',
//       'Madi Municipality', 'Ratnanagar Municipality', 'Rapti Municipality', 'Ichchhakamana Rural Municipality',
//     ]},
//   ];

//   final List<String> modes = ['Petrol', 'Electric'];

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () => setState(() => _isLoading = false));
//   }

//   Future<String> _getDistanceFromAPI(String loc1, String loc2) async {
//     final apiUrl = 'https://distance-api3.p.rapidapi.com/distance?location1=$loc1&location2=$loc2&unit=kilometers';
//     const apiKey = 'cd3125ef15msh2caab8018e8198ap187972jsnb9ff3f522f8e';
//     try {
//       final response = await http.get(Uri.parse(apiUrl), headers: {
//         'X-Rapidapi-Key': apiKey,
//         'X-Rapidapi-Host': 'distance-api3.p.rapidapi.com',
//       });
//       return response.statusCode == 200 ? jsonDecode(response.body)['distance'].toString() : 'N/A';
//     } catch (e) {
//       print('Error fetching distance: $e');
//       return 'N/A';
//     }
//   }

//   Future<Map<String, dynamic>> _getUserDetails() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//         return userDoc.data() ?? {};
//       } catch (e) {
//         print('Error fetching user details: $e');
//       }
//     }
//     return {};
//   }

//   void _calculateFare(String distance) {
//     double rate;
//     if (selectedMode == 'Petrol') {
//       if (selectedPassengers == 1) rate = 2.0;
//       else if (selectedPassengers == 2) rate = 1.6;
//       else if (selectedPassengers == 3) rate = 1.5;
//       else rate = 1.4; // 4, 5, 6 people
//     } else {
//       if (selectedPassengers == 1) rate = 0.7;
//       else if (selectedPassengers == 2) rate = 0.6;
//       else if (selectedPassengers == 3) rate = 0.55;
//       else rate = 0.5; // 4, 5, 6 people
//     }
//     fare = (double.parse(distance) * 10) * rate;
//   }

//   Future<void> _storeDataInFirestore(Map<String, dynamic> data) async {
//     try {
//       await FirebaseFirestore.instance.collection('trips').doc().set(data);
//     } catch (e) {
//       print('Error storing data: $e');
//     }
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: Duration(seconds: 5)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepOrange.shade500.withOpacity(0.8),
//         title: Text('Home Page'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             if (!_isLoading)
//               InAppWebView(
//                 initialUrlRequest: URLRequest(url: WebUri(widget.url)),
//                 initialOptions: InAppWebViewGroupOptions(
//                   crossPlatform: InAppWebViewOptions(
//                     javaScriptEnabled: true,
//                     cacheEnabled: true,
//                     mediaPlaybackRequiresUserGesture: false,
//                   ),
//                 ),
//                 onWebViewCreated: (controller) => webView = controller,
//                 onLoadStop: (controller, url) async {
//                   await controller.evaluateJavascript(source: """
//                     document.querySelector('h1.d-flex.m-0.fw-semibold')?.style.display='none';
//                     document.querySelector('a.btn.btn-outline-primary.geolink.flex-grow-1#history_tab')?.remove();
//                     document.querySelector('.secondary.d-flex.gap-2.align-items-center')?.remove();
//                     document.querySelector('a.btn.btn-outline-primary.geolink.editlink#editanchor')?.remove();
//                   """);
//                 },
//               ),
//             if (_isLoading) Center(child: CircularProgressIndicator()),
//             Positioned(
//               bottom: 100,
//               right: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade300.withOpacity(0.6)),
//                 onPressed: () async {
//                   final pickupLocation = await webView?.evaluateJavascript(source: "document.getElementById('route_from').value") ?? 'N/A';
//                   final deliveryLocation = await webView?.evaluateJavascript(source: "document.getElementById('route_to').value") ?? 'N/A';

//                   if (pickupLocation.isEmpty || deliveryLocation.isEmpty) {
//                     _showSnackbar('Enter Proper Address');
//                     return;
//                   }

//                   final distance = await _getDistanceFromAPI(pickupLocation, deliveryLocation);
//                   _calculateFare(distance);
//                   final confirmed = await showDialog<bool>(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (context) => StatefulBuilder(
//                       builder: (context, setState) {
//                         return AlertDialog(
//                           title: Text('Confirm Booking'),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Pickup: $pickupLocation\nDelivery: $deliveryLocation\nDistance Trail: $distance\n\nYour Municipality'),
//                               SizedBox(height: 10),
//                               DropdownButton<String>(
//                                 value: selectedMunicipality,
//                                 hint: Text('Select Municipality'),
//                                 isExpanded: true,
//                                 items: municipalitySections.expand((section) {
//                                   return [DropdownMenuItem<String>(enabled: false, child: Text(section['title'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))].followedBy(
//                                     section['municipalities'].map<DropdownMenuItem<String>>((String municipality) {
//                                       return DropdownMenuItem<String>(
//                                         value: municipality,
//                                         child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(municipality)),
//                                       );
//                                     }),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) => setState(() => selectedMunicipality = newValue),
//                               ),
//                               SizedBox(height: 10),
//                               DropdownButton<String>(
//                                 value: selectedMode,
//                                 hint: Text('Select Mode'),
//                                 isExpanded: true,
//                                 items: modes.map<DropdownMenuItem<String>>((String mode) {
//                                   return DropdownMenuItem<String>(
//                                     value: mode,
//                                     child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(mode)),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     selectedMode = newValue;
//                                     // Recalculate fare based on new mode
//                                     _calculateFare(distance);
//                                   });
//                                 },
//                               ),
//                               SizedBox(height: 10),
//                               Text('Select Number of Passengers:'),
//                               SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                   children: List.generate(6, (index) {
//                                     int passengerCount = index + 1;
//                                     return ChoiceChip(
//                                       label: Text('$passengerCount'),
//                                       selected: selectedPassengers == passengerCount,
//                                       onSelected: (selected) {
//                                         setState(() {
//                                           selectedPassengers = passengerCount;
//                                           // Recalculate fare based on number of passengers
//                                           _calculateFare(distance);
//                                         });
//                                       },
//                                     );
//                                   }),
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//                               Text('Estimated Fare: NPR${fare.toStringAsFixed(2)}'),
//                             ],
//                           ),
//                           actions: <Widget>[
//                             TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
//                             TextButton(
//                               style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.deepOrange.shade600.withOpacity(0.7)),
//                               onPressed: () {
//                                 if (selectedMunicipality != null && selectedMode != null) {
//                                   final bookingData = {
//                                     'pickup_location': pickupLocation,
//                                     'delivery_location': deliveryLocation,
//                                     'distance': distance,
//                                     'fare': fare.toString(),
//                                     'vehicle_mode': selectedMode,
//                                     'no_of_person': selectedPassengers,
//                                     'municipality': selectedMunicipality,
//                                   };
//                                   _storeDataInFirestore(bookingData);
//                                   Navigator.of(context).pop(true);
//                                 } else {
//                                   _showSnackbar('Please select all options');
//                                 }
//                               },
//                               child: Text('Confirm'),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   );

//                   if (confirmed == true) {
//                     _showSnackbar('Booking confirmed!');
//                   }
//                 },
//                 child: Text('Book Ride'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String url;
  const HomePage({super.key, required this.url});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? webView;
  bool _isLoading = true;
  String? selectedMunicipality;
  String? selectedMode;
  int selectedPassengers = 1; // Default to 1 passenger
  double fare = 0.0;

  final List<Map<String, dynamic>> municipalitySections = [
    {
      'title': 'Chitwan',
      'municipalities': [
        'Bharatpur Metropolitan City',
        'Kalika Municipality',
        'Khairahani Municipality',
        'Madi Municipality',
        'Ratnanagar Municipality',
        'Rapti Municipality',
        'Ichchhakamana Rural Municipality',
      ]
    },
  ];

  final List<String> modes = ['Petrol', 'Electric'];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => setState(() => _isLoading = false));
  }

  Future<String> _getDistanceFromAPI(String loc1, String loc2) async {
    final apiUrl =
        'https://distance-api3.p.rapidapi.com/distance?location1=$loc1&location2=$loc2&unit=kilometers';
    const apiKey = 'cd3125ef15msh2caab8018e8198ap187972jsnb9ff3f522f8e';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'X-Rapidapi-Key': apiKey,
        'X-Rapidapi-Host': 'distance-api3.p.rapidapi.com',
      });
      return response.statusCode == 200
          ? jsonDecode(response.body)['distance'].toString()
          : 'N/A';
    } catch (e) {
      print('Error fetching distance: $e');
      return 'N/A';
    }
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userDoc.data() ?? {};
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }
    return {};
  }

  // void _calculateFare(String distance) {
  //   double rate;
  //   double distancedoublevar = double.parse(distance);
  //   int distanceintvarwithoutroundoff = distancedoublevar.toInt();
  //   int distanceintvar = distanceintvarwithoutroundoff.round();
  //   if (distanceintvar <= 7) {
  //     if (selectedMode == 'Petrol') {
  //       if (selectedPassengers == 1) {
  //         rate = 2.0;
  //       } else if (selectedPassengers == 2) {
  //         rate = (1.6) * 2;
  //       } else if (selectedPassengers == 3) {
  //         rate = (1.5) * 3;
  //       } else if (selectedPassengers == 4) {
  //         rate = (1.4) * 4;
  //       } else if (selectedPassengers == 5) {
  //         rate = (1.4) * 5;
  //       } else {
  //         rate = (1.4) * 6;
  //       }
  //     } else {
  //       if (selectedPassengers == 1) {
  //         rate = 0.75;
  //       } else if (selectedPassengers == 2) {
  //         rate = 0.42 * 2;
  //       } else if (selectedPassengers == 3) {
  //         rate = 0.35 * 3;
  //       } else if (selectedPassengers == 4) {
  //         rate = 0.23 * 4;
  //       } else if (selectedPassengers == 5) {
  //         rate = 0.36 * 5;
  //       } else {
  //         rate = 0.31 * 6;
  //       }
  //     }
  //   }else {



  //     if (selectedMode == 'Petrol') {
  //       if (selectedPassengers == 1) {
  //         rate = 1.5;
  //       } else if (selectedPassengers == 2) {
  //         rate = (1.4) * 2;
  //       } else if (selectedPassengers == 3) {
  //         rate = (1.35) * 3;
  //       } else if (selectedPassengers == 4) {
  //         rate = (1.3) * 4;
  //       } else if (selectedPassengers == 5) {
  //         rate = (1.2) * 5;
  //       } else {
  //         rate = (1.1) * 6;
  //       }
  //     } else {
  //       if (selectedPassengers == 1) {
  //         rate = 0.65;
  //       } else if (selectedPassengers == 2) {
  //         rate = 1.2;
  //       } else if (selectedPassengers == 3) {
  //         rate = 1.65;
  //       } else if (selectedPassengers == 4) {
  //         rate = 2;
  //       } else if (selectedPassengers == 5) {
  //         rate = 2.3;
  //       } else {
  //         rate = 2.5;
  //       }
  //     }


  //   }

  //   fare = (double.parse(distance) * 10) * rate;
  // }





  void _calculateFare(String distance) {
  double rate;
  double distancedoublevar = double.parse(distance);
  int distanceintvarwithoutroundoff = distancedoublevar.toInt();
  int distanceintvar = distanceintvarwithoutroundoff.round();

  DateTime now = DateTime.now();
  int currentHour = now.hour;
  //daytime is equal to 6 to 6
  bool isDaytime = currentHour >= 6 && currentHour < 18;

  // Default rate modifier for daytime is 1, and for nighttime it's 1.05
  double timeMultiplier = isDaytime ? 1 : 1.1;

  // Calculate base rate based on distance and mode
  if (distanceintvar <= 7) {
    if (selectedMode == 'Petrol') {
      if (selectedPassengers == 1) {
        rate = 2.0;
      } else if (selectedPassengers == 2) {
        rate = 3.2;
      } else if (selectedPassengers == 3) {
        rate = 4.5;
      } else if (selectedPassengers == 4) {
        rate = 5.6;
      } else if (selectedPassengers == 5) {
        rate = 7;
      } else {
        rate = 8.4;
      }
    } else { // Non-petrol mode
      if (selectedPassengers == 1) {
        rate = 0.75;
      } else if (selectedPassengers == 2) {
        rate = 0.84;
      } else if (selectedPassengers == 3) {
        rate = 1.05;
      } else if (selectedPassengers == 4) {
        rate = 1.3;
      } else if (selectedPassengers == 5) {
        rate = 1.7;
      } else {
        rate = 1.86;
      }
    }
  } else { // Distance greater than 7 km
    if (selectedMode == 'Petrol') {
      if (selectedPassengers == 1) {
        rate = 1.5;
      } else if (selectedPassengers == 2) {
        rate = 2.8;
      } else if (selectedPassengers == 3) {
        rate = 4.05;
      } else if (selectedPassengers == 4) {
        rate = 5.2;
      } else if (selectedPassengers == 5) {
        rate = 6;
      } else {
        rate = 6.8;
      }
    } else { // Non-petrol mode
      if (selectedPassengers == 1) {
        rate = 0.65;
      } else if (selectedPassengers == 2) {
        rate = 0.77;
      } else if (selectedPassengers == 3) {
        rate = 0.9;
      } else if (selectedPassengers == 4) {
        rate = 1.1;
      } else if (selectedPassengers == 5) {
        rate = 1.4;
      } else {
        rate = 1.6;
      }
    }
  }

  // Apply distance and the time-based multiplier to the fare calculation
  fare = (double.parse(distance) * 10) * rate * timeMultiplier;

  // Print to check if it's daytime or nighttime and the calculated fare
  print("Booking time: ${isDaytime ? 'Daytime' : 'Nighttime'}");
  print("Calculated fare: $fare");
}








  Future<void> _storeDataInFirestore(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('trips').doc().set(data);
    } catch (e) {
      print('Error storing data: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 5)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade500.withOpacity(0.8),
        title: Text('Home Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (!_isLoading)
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    cacheEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                ),
                onWebViewCreated: (controller) => webView = controller,
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(source: """
                   var mapViewerElement = document.querySelector('h1.d-flex.m-0.fw-semibold');
                    if (mapViewerElement) mapViewerElement.style.display = 'none';

                    var historyLinkElement = document.querySelector('a.btn.btn-outline-primary.geolink.flex-grow-1#history_tab');
                    if (historyLinkElement) historyLinkElement.remove();
                    
                    var secondaryElement = document.querySelector('.secondary.d-flex.gap-2.align-items-center');
                    if (secondaryElement) secondaryElement.remove();
                    
                    var editLinkElement = document.querySelector('a.btn.btn-outline-primary.geolink.editlink#editanchor');
                    if (editLinkElement) editLinkElement.remove();

                     result;
                  """);
                },
              ),
            if (_isLoading) Center(child: CircularProgressIndicator()),
            Positioned(
              bottom: 50,
              right: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepOrange.shade300.withOpacity(0.6)),
                onPressed: () async {
                  final pickupLocation = await webView?.evaluateJavascript(
                          source:
                              "document.getElementById('route_from').value") ??
                      'N/A';
                  final deliveryLocation = await webView?.evaluateJavascript(
                          source:
                              "document.getElementById('route_to').value") ??
                      'N/A';

                  if (pickupLocation.isEmpty || deliveryLocation.isEmpty) {
                    _showSnackbar('Enter Proper Address');
                    return;
                  }

                  final distance = await _getDistanceFromAPI(
                      pickupLocation, deliveryLocation);
                  _calculateFare(distance);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AlertDialog(
                                title: Text('Confirm Booking'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pickup: $pickupLocation'),
                                    Divider(),
                                    Text('Delivery: $deliveryLocation'),
                                    Divider(),
                                    DropdownButton<String>(
                                      value: selectedMunicipality,
                                      hint: Text('Select Municipality'),
                                      isExpanded: true,
                                      items: municipalitySections.expand((section) {
                                        return [
                                          DropdownMenuItem<String>(
                                              enabled: false,
                                              child: Text(section['title'],
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey)))
                                        ].followedBy(
                                          section['municipalities']
                                              .map<DropdownMenuItem<String>>(
                                                  (String municipality) {
                                            return DropdownMenuItem<String>(
                                              value: municipality,
                                              child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8.0),
                                                  child: Text(municipality)),
                                            );
                                          }),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) => setState(
                                          () => selectedMunicipality = newValue),
                                    ),
                                    SizedBox(height: 10),
                                    DropdownButton<String>(
                                      value: selectedMode,
                                      hint: Text('Select Mode'),
                                      isExpanded: true,
                                      items: modes.map<DropdownMenuItem<String>>(
                                          (String mode) {
                                        return DropdownMenuItem<String>(
                                          value: mode,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.only(left: 8.0),
                                              child: Text(mode)),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedMode = newValue;
                                          // Recalculate fare based on new mode
                                          _calculateFare(distance);
                                        });
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    Text('Select Number of Passengers:'),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(6, (index) {
                                          int passengerCount = index + 1;
                                          return ChoiceChip(
                                            label: Text('$passengerCount'),
                                            selected:
                                                selectedPassengers == passengerCount,
                                            onSelected: (selected) {
                                              setState(() {
                                                selectedPassengers = passengerCount;
                                                // Recalculate fare based on number of passengers
                                                _calculateFare(distance);
                                              });
                                            },
                                          );
                                        }),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                        'Estimated Fare: NPR${fare.toStringAsFixed(2)}'),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false)),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.deepOrange.shade600
                                            .withOpacity(0.7)),
                                    onPressed: () async {
                                      if (selectedMunicipality != null &&
                                          selectedMode != null) {
                                        final userDetails = await _getUserDetails();
                                        final timestamp =
                                            DateTime.now(); // Set timestamp here
                                        final user =
                                            FirebaseAuth.instance.currentUser;
                                        final bookingData = {
                                          'vehicle_mode': selectedMode,
                                          'no_of_person': selectedPassengers,
                                          'userId': user?.uid ?? 'N/A',
                                          'municipalityDropdown':
                                              selectedMunicipality,
                                          'timestamp': FieldValue.serverTimestamp(),
                                          'fare': fare.toStringAsFixed(2),
                                          'distance': distance,
                                          'username':
                                              userDetails['username'] ?? 'N/A',
                                          'email': userDetails['email'] ?? 'N/A',
                                          'phone':
                                              userDetails['phone_number'] ?? 'N/A',
                                          'pickupLocation': pickupLocation,
                                          'deliveryLocation': deliveryLocation,
                                        };
                                        await _storeDataInFirestore(bookingData);
                                        Navigator.of(context).pop(true);
                                      } else {
                                        _showSnackbar('Please select all options');
                                      }
                                    },
                                    child: Text('Confirm'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );

                  if (confirmed == true) {
                    _showSnackbar('Booking confirmed!');
                  }
                },
                child: Text('Book a Ride',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
