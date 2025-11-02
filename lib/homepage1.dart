import 'dart:async';
import 'dart:convert';
import 'package:final_menu/galli_maps/map_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
import 'package:final_menu/Statistics_page/Statistics-Page.dart';
import 'package:final_menu/chat/chat.dart';
import 'package:final_menu/history_page/history_page.dart';
import 'package:final_menu/homepage.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:final_menu/request_from_driver_page.dart/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  _HomePage1State createState() => _HomePage1State();
}

late String userId;

class _HomePage1State extends State<HomePage1> {
  String mapsearchedplace = '';

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  late LocationData
      _currentLocation; // Location variable to hold user's current location
  final Location _location = Location();
  late String _initialUrl;
  double totalFare = 0.0;
  double totalDistance = 0.0;
  int totalDeliveryLocations = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid;
    } else {
      // Handle case where currentUser is null or userId initialization fails
    }
    _initialUrl =
        'https://www.openstreetmap.org/#map=13/51.5/-0.09'; // Default location (London) for initialization
    _getLocation();
    _calculateStatistics();
  }

  final _advancedDrawerController = AdvancedDrawerController();

  //start

  Future<void> _calculateStatistics() async {
    try {
      final successfulTripsSnapshot = await FirebaseFirestore.instance
          .collection('successfulTrips')
          .where('userId', isEqualTo: userId)
          .get();

      List<String> tripIds = [];
      for (var doc in successfulTripsSnapshot.docs) {
        final data = doc.data();
        final tripId = data['tripId'] as String?;
        if (tripId != null && tripId.isNotEmpty) {
          tripIds.add(tripId);
        }
      }

      double fareSum = 0.0;
      double distanceSum = 0.0;

      if (tripIds.isNotEmpty) {
        final tripsSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .where(FieldPath.documentId, whereIn: tripIds)
            .get();

        for (var doc in tripsSnapshot.docs) {
          final data = doc.data();
          final fare = data['fare'] as String?;
          final distance = data['distance'] as String?;

          if (fare != null && fare.isNotEmpty) {
            fareSum += double.tryParse(fare) ?? 0.0;
          }

          if (distance != null && distance.isNotEmpty) {
            distanceSum += double.tryParse(distance) ?? 0.0;
          }
        }
      }

      totalDeliveryLocations = successfulTripsSnapshot.docs.length;

      setState(() {
        totalFare = fareSum;
        totalDistance = distanceSum;
        isLoading = false;
      });
    } catch (e) {
      print('Error calculating statistics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getLocation() async {
    try {
      var locationData = await _location.getLocation();
      setState(() {
        _currentLocation = locationData;
        _initialUrl =
            'https://www.openstreetmap.org/#map=13/${_currentLocation.latitude}/${_currentLocation.longitude}';
      });
    } catch (e) {
      print('Error getting location: $e');
      // Handle location fetch error
    }
  }

  // Future<bool> checkUpdateAvailability(BuildContext context) async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();

  //     // Get the last execution time from SharedPreferences
  //     int lastExecution = prefs.getInt('lastExecution') ?? 0;
  //     int currentTime = DateTime.now().millisecondsSinceEpoch;
  //     int oneDayInMillis = 1 * 24 * 60 * 60 * 1000; // 1 day in milliseconds

  //     // Check if a day has passed since the last execution
  //     if (currentTime - lastExecution >= oneDayInMillis) {
  //       // Update the last execution time in SharedPreferences
  //       await prefs.setInt('lastExecution', currentTime);

  //       // Access Firestore collection and document
  //       DocumentSnapshot updateSnapshot = await FirebaseFirestore.instance
  //           .collection('update') // Replace with your collection name
  //           .doc('rkgn9bRgnWLSdVSJxj1H') // Replace with your document ID
  //           .get();

  //       // Check if document exists and retrieve value of is_update_available
  //       if (updateSnapshot.exists) {
  //         bool isUpdateAvailable = updateSnapshot['is_update_available'];
  //         String version = updateSnapshot['version'];
  //         String thisVersion =
  //             '1.0.2'; //yo chai maile jailei rakhna parxa taki user ko device ko aaile ko version sanga compare garna milos so user lai update aako xa vanera notify garna sakiyos

  //         if (isUpdateAvailable && thisVersion != version) {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: Text('New Update Available!'),
  //                 content: Text(
  //                     'A new update $version is available. We Highly Recommend you to Update Tuk Tuk Sawari from www.tuktuk.tarangabaral.com.np Website for Better Performance and Experience. \n \nDeveloper : Taranga Baral'),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       'Later',
  //                       style: TextStyle(color: Colors.red, fontSize: 14),
  //                     ),
  //                   ),
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         Timer.periodic(Duration(seconds: 1 * 24 * 60 * 60),
  //                             (timer) {
  //                           checkUpdateAvailability(context);
  //                         });
  //                         _launchURL('https://www.tuktuk.tarangabaral.com.np');
  //                       },
  //                       child: Text(
  //                         'Update',
  //                         style: TextStyle(
  //                             color: Colors.green,
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.w600),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         }

  //         return isUpdateAvailable;
  //       } else {
  //         // Handle case where document does not exist
  //         return false;
  //       }
  //     } else {
  //       print('Daily check skipped: Not enough time has passed.');
  //       return false;
  //     }
  //   } catch (e) {
  //     // Handle error
  //     print('Error checking update availability: $e');
  //     return false;
  //   }
  // }

  Future<bool> checkUpdateAvailability(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get the last execution time from SharedPreferences
      int lastExecution = prefs.getInt('lastExecution') ?? 0;
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      // int oneDayInMillis = 1 * 24 * 60 * 60 * 1000; // 1 day in milliseconds
      int oneDayInMillis = 2 * 1000;

      // Check if a day has passed since the last execution
      if (currentTime - lastExecution >= oneDayInMillis) {
        // Update the last execution time in SharedPreferences
        await prefs.setInt('lastExecution', currentTime);

        // Access Firestore collection and document
        DocumentSnapshot updateSnapshot = await FirebaseFirestore.instance
            .collection('update') // Replace with your collection name
            .doc('rkgn9bRgnWLSdVSJxj1H') // Replace with your document ID
            .get();

        // Check if document exists and retrieve value of is_update_available
        if (updateSnapshot.exists) {
          bool isUpdateAvailable = updateSnapshot['is_update_available'];
          String version = updateSnapshot['version'];
          String thisVersion = '1.0.2'; // Replace with the current app version

          if (isUpdateAvailable && thisVersion != version) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('New Update Available!'),
                  content: Text(
                      'A new update $version is available. We highly recommend you to update Tuk Tuk Sawari from www.tuktuk.tarangabaral.com.np for better performance and experience. \n \nDeveloper: Taranga Baral'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Later',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _launchURL('https://www.tuktuk.tarangabaral.com.np');
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return isUpdateAvailable;
        } else {
          // Handle case where document does not exist
          return false;
        }
      } else {
        print('Daily check skipped: Not enough time has passed.');
        return false;
      }
    } catch (e) {
      // Handle error
      print('Error checking update availability: $e');
      return false;
    }
  }

  //end

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String? message =
        ModalRoute.of(context)?.settings.arguments as String?;
    final User? currentUser = FirebaseAuth.instance.currentUser;
    checkUpdateAvailability(context);
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('No user is logged in, Login Again'),
              GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                  child: Icon(
                    Icons.home,
                    color: Colors.green,
                  ))
            ],
          ),
        ),
      );
    }
    IconData iconData;
    Color iconColor;
    late String userId = currentUser.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(userId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
                child: Text('Error loading user data: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: null,
          );
        }

        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        String username = data['username'] ?? 'Unknown User';
        String phoneNumber = data['phone_number'] ?? 'No Phone Number';
        String email = currentUser.email ?? 'No Email';

        String avatarLetter =
            username.isNotEmpty ? username[0].toUpperCase() : 'U';

        return AdvancedDrawer(
            controller: _advancedDrawerController,
            backdropColor: const Color.fromARGB(255, 68, 138, 255),
            drawer: buildDrawer(
                context, avatarLetter, username, phoneNumber, email),
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    leading: InkWell(
                      onTap: () {
                        _advancedDrawerController.showDrawer();
                      },
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                    foregroundColor: Colors.red,
                    expandedHeight: 150.0, // Height when fully expanded
                    floating: false,
                    pinned: true,
                    centerTitle: false, elevation: 2,
                    snap: false, backgroundColor: Colors.blueAccent,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Tuk Tuk',
                        style: GoogleFonts.outfit(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      background: Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'images/homepage_card_bg.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 0, right: 0),
                            child: _buildUserDetailsCard(
                              context: context,
                              username: username,
                              avatarLetter: username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : 'U',
                            ),
                          ),
                          Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    child: Container(
                                      height: 180,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      color: Color.fromRGBO(255, 188, 71, 1),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -20,
                                    right: 50,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[50],
                                      radius: 30,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Color.fromRGBO(255, 188, 71, 1),
                                        child: Icon(
                                          Icons.currency_rupee_outlined,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 18,
                                    child: Image(
                                      image: AssetImage(
                                        'assets/money.gif',
                                      ),
                                      height: 80,
                                      width: 80,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 30,
                                    child: Image(
                                      image: AssetImage(
                                        'assets/total fare container.png',
                                      ),
                                      height: 180,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Positioned(
                                    top: 14,
                                    left: 28,
                                    child: Column(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 30,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    'कुल भुक्तानि गरिएको भाडा\n',
                                                style: GoogleFonts.hind(
                                                  fontSize: 24,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    'NPR ${totalFare.toStringAsFixed(2)}',
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16,
                                                    color: const Color.fromARGB(
                                                        239, 255, 255, 255)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    child: Container(
                                      height: 180,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      color: Color.fromRGBO(255, 154, 170, 1.0),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -20,
                                    right: 50,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[50],
                                      radius: 30,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Color.fromRGBO(255, 154, 170, 1.0),
                                        child: Icon(
                                          Icons.history,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 28,
                                    child: Image(
                                      image: AssetImage(
                                        'assets/kilometer.gif',
                                      ),
                                      height: 80,
                                      width: 80,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 30,
                                    child: Image(
                                      image: AssetImage(
                                        'assets/total distance container.png',
                                      ),
                                      height: 180,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Positioned(
                                    top: 14,
                                    left: 28,
                                    child: Column(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 30,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'जम्मा हिडिएको कि.मि \n',
                                                style: GoogleFonts.hind(
                                                  fontSize: 22,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '${totalDistance.toStringAsFixed(2)} Kilometer',
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16,
                                                    color: const Color.fromARGB(
                                                        239, 255, 255, 255)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    child: Container(
                                      height: 180,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      color: Color.fromRGBO(113, 120, 211, 1.0),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -20,
                                    right: 50,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[50],
                                      radius: 30,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Color.fromRGBO(113, 120, 211, 1.0),
                                        child: Icon(
                                          Icons.drive_eta,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 28,
                                    child: Image(
                                      image: AssetImage(
                                        'assets/total_trips.gif',
                                      ),
                                      height: 100,
                                      width: 100,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 30,
                                    child: Image(
                                      image: AssetImage(
                                        'assets/total trips container.png',
                                      ),
                                      height: 180,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Positioned(
                                    top: 14,
                                    left: 28,
                                    child: Column(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 30,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    'कुल यात्रा गरिएको संख्या\n',
                                                style: GoogleFonts.hind(
                                                  fontSize: 24,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    'Trips: $totalDeliveryLocations',
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16,
                                                    color: const Color.fromARGB(
                                                        239, 255, 255, 255)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //   body: SafeArea(
              //     child: Stack(
              //       clipBehavior: Clip.none,
              //       children: [
              //         SingleChildScrollView(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             children: [
              //               Padding(
              //                 padding: EdgeInsets.only(left: 0, right: 0),
              //                 child: _buildUserDetailsCard(
              //                   context: context,
              //                   username: username,
              //                   avatarLetter: username.isNotEmpty
              //                       ? username[0].toUpperCase()
              //                       : 'U',
              //                 ),
              //               ),

              //               // Row(
              //               //   children: [
              //               //     _buildStatCard(
              //               //       title: 'भुक्तानी गरिएको कुल भाडा',
              //               //       value: 'NPR ${totalFare.toStringAsFixed(2)}',
              //               //       cardColor: Colors.lime,
              //               //       iconColor: Colors.red,
              //               //       iconData: Icons.money,
              //               //       screenWidth: screenWidth,
              //               //     ),
              //               //     Column(
              //               //       children: [
              //               //         _buildStatCard(
              //               //           title: 'अनुमानित यात्रा',
              //               //           value: '${totalDistance.toStringAsFixed(2)} km',
              //               //           cardColor: Colors.green,
              //               //           iconColor: Colors.blue,
              //               //           iconData: Icons.travel_explore,
              //               //           screenWidth: screenWidth,
              //               //         ),
              //               //         _buildStatCard(
              //               //           title: 'यात्रा संख्या',
              //               //           value: '$totalDeliveryLocations',
              //               //           cardColor: Colors.orange,
              //               //           iconColor: Colors.yellow,
              //               //           iconData: Icons.tire_repair_rounded,
              //               //           screenWidth: screenWidth,
              //               //         ),
              //               //       ],
              //               //     ),
              //               //   ],
              //               // ),

              //               Column(
              //                 children: [
              //                   Stack(
              //                     clipBehavior: Clip.none,
              //                     children: [
              //                       ClipRRect(
              //                         borderRadius:
              //                             BorderRadius.all(Radius.circular(30)),
              //                         child: Container(
              //                           height: 180,
              //                           width:
              //                               MediaQuery.of(context).size.width * 0.9,
              //                           color: Color.fromRGBO(255, 188, 71, 1),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: -20,
              //                         right: 50,
              //                         child: CircleAvatar(
              //                           backgroundColor: Colors.grey[50],
              //                           radius: 30,
              //                           child: CircleAvatar(
              //                             radius: 20,
              //                             backgroundColor:
              //                                 Color.fromRGBO(255, 188, 71, 1),
              //                             child: Icon(
              //                               Icons.currency_rupee_outlined,
              //                               size: 20,
              //                               color: Colors.white,
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: 0,
              //                         left: 18,
              //                         child: Image(
              //                           image: AssetImage(
              //                             'assets/money.gif',
              //                           ),
              //                           height: 80,
              //                           width: 80,
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: 0,
              //                         left: 30,
              //                         child: Image(
              //                           image: AssetImage(
              //                             'assets/total fare container.png',
              //                           ),
              //                           height: 180,
              //                           width: MediaQuery.of(context).size.width,
              //                         ),
              //                       ),
              //                       Positioned(
              //                         top: 14,
              //                         left: 28,
              //                         child: Column(
              //                           children: [
              //                             // Text(
              //                             //   'Total Fare',
              //                             //   style: GoogleFonts.lato(
              //                             //     fontWeight: FontWeight.bold,
              //                             //     color: Colors.white,
              //                             //     fontSize: 30,
              //                             //   ),
              //                             // ),
              //                             // SizedBox(
              //                             //   height: 10,
              //                             // ),
              //                             // Text(
              //                             // 'NPR ${totalFare.toStringAsFixed(2)}',
              //                             //   style: TextStyle(
              //                             //     color: Colors.white,
              //                             //     fontSize: 20,
              //                             //   ),
              //                             // ),

              //                             RichText(
              //                               text: TextSpan(
              //                                 style: TextStyle(
              //                                   fontWeight: FontWeight.bold,
              //                                   color: Colors.white,
              //                                   fontSize: 30,
              //                                 ),
              //                                 children: [
              //                                   TextSpan(
              //                                     text:
              //                                         'कुल भुक्तानि गरिएको भाडा\n',
              //                                     style: GoogleFonts
              //                                         .tiroDevanagariHindi(
              //                                       // overflow: TextOverflow.ellipsis,
              //                                       fontSize: 24,
              //                                     ),
              //                                   ),
              //                                   TextSpan(
              //                                     text:
              //                                         'NPR ${totalFare.toStringAsFixed(2)}',
              //                                     style: TextStyle(
              //                                       fontSize: 18,
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   SizedBox(
              //                     height: 20,
              //                   ),
              //                   Stack(
              //                     clipBehavior: Clip.none,
              //                     children: [
              //                       ClipRRect(
              //                         borderRadius:
              //                             BorderRadius.all(Radius.circular(30)),
              //                         child: Container(
              //                           height: 180,
              //                           width:
              //                               MediaQuery.of(context).size.width * 0.9,
              //                           color: Color.fromRGBO(255, 154, 170, 1.0),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: -20,
              //                         right: 50,
              //                         child: CircleAvatar(
              //                           backgroundColor: Colors.grey[50],
              //                           radius: 30,
              //                           child: CircleAvatar(
              //                             radius: 20,
              //                             backgroundColor:
              //                                 Color.fromRGBO(255, 154, 170, 1.0),
              //                             child: Icon(
              //                               Icons.history,
              //                               size: 20,
              //                               color: Colors.white,
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: 10,
              //                         left: 28,
              //                         child: Image(
              //                           image: AssetImage(
              //                             'assets/kilometer.gif',
              //                           ),
              //                           height: 80,
              //                           width: 80,
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: 0,
              //                         left: 30,
              //                         child: Image(
              //                           image: AssetImage(
              //                             'assets/total distance container.png',
              //                           ),
              //                           height: 180,
              //                           width: MediaQuery.of(context).size.width,
              //                         ),
              //                       ),
              //                       Positioned(
              //                         top: 14,
              //                         left: 28,
              //                         child: Column(
              //                           children: [
              //                             // Text(
              //                             //   'Total Distance \n ${totalDistance.toStringAsFixed(2)} km',
              //                             //   style: GoogleFonts.lato(
              //                             //     fontWeight: FontWeight.bold,
              //                             //     color: Colors.white,
              //                             //     fontSize: 30,
              //                             //   ),
              //                             // ),

              //                             RichText(
              //                               text: TextSpan(
              //                                 style: GoogleFonts.lato(
              //                                   fontWeight: FontWeight.bold,
              //                                   color: Colors.white,
              //                                   fontSize: 30,
              //                                 ),
              //                                 children: [
              //                                   TextSpan(
              //                                     text: 'जम्मा हिडिएको कि.मि \n',
              //                                     style: GoogleFonts
              //                                         .tiroDevanagariHindi(
              //                                       fontSize: 22,
              //                                     ),
              //                                   ),
              //                                   TextSpan(
              //                                     text:
              //                                         '${totalDistance.toStringAsFixed(2)} Kilometer',
              //                                     style: TextStyle(
              //                                       fontSize: 18,
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                             ),

              //                             SizedBox(
              //                               height: 10,
              //                             ),
              //                             // Text(
              //                             //   '${totalDistance.toStringAsFixed(2)} km',
              //                             //   style: TextStyle(
              //                             //     color: Colors.white,
              //                             //     fontSize: 20,
              //                             //   ),
              //                             // ),
              //                           ],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   SizedBox(
              //                     height: 20,
              //                   ),
              //                   Stack(
              //                     clipBehavior: Clip.none,
              //                     children: [
              //                       ClipRRect(
              //                         borderRadius:
              //                             BorderRadius.all(Radius.circular(30)),
              //                         child: Container(
              //                           height: 180,
              //                           width:
              //                               MediaQuery.of(context).size.width * 0.9,
              //                           color: Color.fromRGBO(113, 120, 211, 1.0),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: -20,
              //                         right: 50,
              //                         child: CircleAvatar(
              //                           backgroundColor: Colors.grey[50],
              //                           radius: 30,
              //                           child: CircleAvatar(
              //                             radius: 20,
              //                             backgroundColor:
              //                                 Color.fromRGBO(113, 120, 211, 1.0),
              //                             child: Icon(
              //                               Icons.drive_eta,
              //                               size: 20,
              //                               color: Colors.white,
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: 0,
              //                         left: 28,
              //                         child: Image(
              //                           image: AssetImage(
              //                             'assets/total_trips.gif',
              //                           ),
              //                           height: 100,
              //                           width: 100,
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: 0,
              //                         left: 30,
              //                         child: Image(
              //                           image: AssetImage(
              //                             'assets/total trips container.png',
              //                           ),
              //                           height: 180,
              //                           width: MediaQuery.of(context).size.width,
              //                         ),
              //                       ),
              //                       Positioned(
              //                         top: 14,
              //                         left: 28,
              //                         child: Column(
              //                           children: [
              //                             // Row(
              //                             //   children: [
              //                             //     Text(
              //                             //       'Total Trips : $totalDeliveryLocations',
              //                             //       style: GoogleFonts.lato(
              //                             //         fontWeight: FontWeight.bold,
              //                             //         color: Colors.white,
              //                             //         fontSize: 30,
              //                             //       ),
              //                             //     ),
              //                             //   ],
              //                             // ),

              //                             RichText(
              //                               text: TextSpan(
              //                                 style: GoogleFonts.lato(
              //                                   fontWeight: FontWeight.bold,
              //                                   color: Colors.white,
              //                                   fontSize: 30,
              //                                 ),
              //                                 children: [
              //                                   TextSpan(
              //                                     text:
              //                                         'कुल यात्रा गरिएको संख्या\n',
              //                                     style: GoogleFonts
              //                                         .tiroDevanagariHindi(
              //                                       fontSize: 24,
              //                                     ),
              //                                   ),
              //                                   TextSpan(
              //                                     text: '$totalDeliveryLocations',
              //                                     style: TextStyle(
              //                                       fontSize: 26,
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                             ),

              //                             SizedBox(
              //                               height: 10,
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   SizedBox(
              //                     height: 20,
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),

              //         // Positioned(
              //         //     top: -90,
              //         //     right: 0,
              //         //     child: ClipRRect(
              //         //       borderRadius:
              //         //           BorderRadius.only(bottomLeft: Radius.circular(50)),
              //         //       child: Container(
              //         //         color: Colors.blueAccent,
              //         //         height: 100,
              //         //         width: 80,
              //         //       ),
              //         //     )),

              //         Positioned(
              //             top: 0,
              //             right: 0,
              //             child: ClipRRect(
              //               borderRadius: BorderRadius.only(
              //                 bottomLeft: Radius.circular(30),
              //                 // topLeft: Radius.circular(30),
              //               ),
              //               child: Container(
              //                 color: Colors.blueAccent,
              //                 height: 70,
              //                 width: 70,
              //                 child: Center(
              //                   child: GestureDetector(
              //                     onTap: () {
              //                       _advancedDrawerController.showDrawer();
              //                     },
              //                     child: Icon(
              //                       Icons.menu,
              //                       color: Colors.white,
              //                       size: 26,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             )),
              //       ],
              //     ),
              //   ),
              // ),
            ));
      },
    );
  }

  Widget _buildUserDetailsCard({
    required BuildContext context,
    required String username,
    required String avatarLetter,
  }) {
    // Controller for the search field
    TextEditingController searchController = TextEditingController();

    Future<List<Map<String, dynamic>>> searchLocations(String query) async {
      // Trim and convert the query to lowercase for better matching
      String trimmedQuery = query.trim().toLowerCase();

      // Variables to hold the queries for 'chowk' and 'chok'
      String chowkQuery = trimmedQuery;
      String chokQuery = trimmedQuery;

      // Check if the query contains either 'chowk' or 'chok'
      bool containsChowk = trimmedQuery.contains('chowk');
      bool containsChok = trimmedQuery.contains('chok');

      // Modify the query if "chowk" or "chok" is found
      if (containsChowk) {
        chokQuery = trimmedQuery.replaceAll('chowk', 'chok');
      } else if (containsChok) {
        chowkQuery = trimmedQuery.replaceAll('chok', 'chowk');
      }

      // Call API for both variations
      final String urlChowk =
          'https://nominatim.openstreetmap.org/search?q=$chowkQuery,nepal&format=json&limit=50';
      final String urlChok =
          'https://nominatim.openstreetmap.org/search?q=$chokQuery,nepal&format=json&limit=50';

      final responseChowk = await http.get(Uri.parse(urlChowk));
      final responseChok = await http.get(Uri.parse(urlChok));

      // Ensure both requests were successful
      if (responseChowk.statusCode == 200 && responseChok.statusCode == 200) {
        final List<dynamic> dataChowk = jsonDecode(responseChowk.body);
        final List<dynamic> dataChok = jsonDecode(responseChok.body);

        List<Map<String, dynamic>> combinedResults = [];

        if (containsChowk || containsChok) {
          // If query contains 'chowk' or 'chok', combine both results
          combinedResults.addAll(dataChowk
              .map((item) => {
                    'display_name': item['display_name'],
                    'lat': item['lat'],
                    'lon': item['lon'],
                  })
              .toList());

          combinedResults.addAll(dataChok
              .map((item) => {
                    'display_name': item['display_name'],
                    'lat': item['lat'],
                    'lon': item['lon'],
                  })
              .toList());
        } else {
          // Otherwise, only return results from the first query
          combinedResults.addAll(dataChowk
              .map((item) => {
                    'display_name': item['display_name'],
                    'lat': item['lat'],
                    'lon': item['lon'],
                  })
              .toList());
        }

        return combinedResults;
      } else {
        throw Exception('Failed to load locations');
      }
    }

    // Function to display results in a popup
    void showSearchResults(
        BuildContext context, List<Map<String, dynamic>> results) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Searched Places'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (BuildContext context, int index) {
                  final result = results[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(result['display_name']),
                        onTap: () {
                          setState(() {
                            // Update the pickup latitude and longitude
                            mapsearchedplace = result['display_name'];
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                userId: userId,
                                url:
                                    'https://www.openstreetmap.org/search?query=$mapsearchedplace',
                                routeTo: mapsearchedplace,
                              ),
                            ),
                          );
                          print(
                              'Searched Name with URL IS :                     \n \n \n \t                  https://www.openstreetmap.org/search?query=$mapsearchedplace');
                        },
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color.fromARGB(255, 127, 182, 226),
                      Color.fromARGB(255, 211, 135, 224),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          // color: Colors.,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for avatar and welcome message
            Text(
              '$username!',
              style: GoogleFonts.outfit(
                fontSize: 24,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              'हजुर लाई स्वागत छ ,',
              style: GoogleFonts.hind(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),

            SizedBox(height: 20),
            // Search field

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Container(
                    color: Colors.grey[20],
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child:
                        Image(image: AssetImage('assets/homepage_tuktuk.png')),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Container(
                    color: Colors.grey[20],
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Image(
                        image: AssetImage('assets/homepage_motorbike.png')),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Container(
                    color: Colors.grey[20],
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Image(image: AssetImage('assets/homepage_taxi.png')),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 20,
            ),

            GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => MapPage(
                //               userId: userId,
                //             )));

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MapPage(
                      userId: userId,
                    ),
                    transitionDuration: Duration(
                        milliseconds: 200), // Longer duration for bouncy effect
                    reverseTransitionDuration: Duration(
                        milliseconds: 200), // Optional: Set reverse duration
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // Slide from bottom
                      const end = Offset.zero;
                      const curve = Curves.elasticOut; // Bouncy curve
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      // Add a fade transition
                      var fadeTween = Tween(begin: 0.0, end: 1.0);
                      var fadeAnimation = animation.drive(fadeTween);

                      // Add a scale transition with a bouncy curve
                      var scaleTween =
                          Tween(begin: 0.8, end: 1.0); // Scale from 80% to 100%
                      var scaleAnimation = animation.drive(scaleTween
                          .chain(CurveTween(curve: Curves.elasticOut)));

                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: ScaleTransition(
                            scale: scaleAnimation,
                            child: child,
                          ),
                        ),
                      );
                    },
                  ),
                );

                // Navigator.push(
                //   context,
                //   PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) =>
                //         MapPage(
                //       userId: userId,
                //     ),
                //     transitionsBuilder:
                //         (context, animation, secondaryAnimation, child) {
                //       const begin = Offset(1.0, 0.0); // Slide from right
                //       const end = Offset.zero;
                //       const curve = Curves.easeInOut;
                //       var tween = Tween(begin: begin, end: end)
                //           .chain(CurveTween(curve: curve));
                //       var offsetAnimation = animation.drive(tween);

                //       return SlideTransition(
                //         position: offsetAnimation,
                //         child: child,
                //       );
                //     },
                //   ),
                // );
              },
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                shadowColor: Colors.grey.withAlpha(50),
                elevation: 4,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    enabled: false,
                    prefixIcon: Icon(
                      Icons.place,
                      size: 25,
                      color: Colors.blueAccent,
                    ),
                    hintText: 'कहाँ जानू हुन्छ त ?',
                    hintStyle: GoogleFonts.hind(),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer(BuildContext context, String avatarLetterParameter,
      String username, String phoneNumber, String email) {
    double screenTextScaleFactor = MediaQuery.of(context).textScaleFactor;
    print(screenTextScaleFactor);
    return Drawer(
      child: Container(
        // color: Colors.grey[120],
        // color: Color.fromRGBO(65, 95, 207, 1),
        color: Colors.blueAccent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // DrawerHeader(
            //   decoration: BoxDecoration(
            //       // color: Colors.white10.withOpacity(0.1),
            //       ),
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       CircleAvatar(
            //         radius: 30,
            //         backgroundColor: Colors.white,
            //         child: Text(
            //           avatarLetterParameter,
            //           style: TextStyle(
            //             color: Colors.redAccent,
            //             fontSize: 24,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //       SizedBox(height: 10),
            //       FittedBox(
            //         fit: BoxFit.scaleDown,
            //         child: Text(
            //           username,
            //           style: GoogleFonts.outfit(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 20,
            //           ),
            //         ),
            //       ),
            //       Text(
            //         phoneNumber,
            //         style: TextStyle(
            //           color: Colors.white70,
            //           fontSize: 12,
            //         ),
            //       ),
            //       Text(
            //         email,
            //         style: TextStyle(
            //           color: Colors.white70,
            //           fontSize: 12,
            //         ),
            //       ),
            //       GestureDetector(
            //         onTap: () {
            //           // Copy the full userId to the clipboard
            //           Clipboard.setData(ClipboardData(text: userId));
            //           // Show a toast message to indicate the text has been copied
            //           Fluttertoast.showToast(
            //             msg: userId,
            //             toastLength: Toast.LENGTH_SHORT,
            //             gravity: ToastGravity.TOP,
            //             backgroundColor: Colors.blue,
            //             textColor: Colors.white,
            //           );
            //         },
            //         child: Text(
            //           'User ID: ${userId.substring(0, 18)}...',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 13,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            DrawerHeader(
              decoration: BoxDecoration(
                  // color: Colors.white10.withOpacity(0.1),
                  ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: screenTextScaleFactor <= 1.3 ? 20 : 16,
                    backgroundColor: Colors.white,
                    child: Text(
                      avatarLetterParameter,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Use FittedBox to scale down the username text
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      username,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenTextScaleFactor <= 1.3 ? 20 : 12,
                      ),
                    ),
                  ),
                  // Use Flexible to allow the text to wrap or scale
                  Flexible(
                    child: Text(
                      phoneNumber,
                      style: GoogleFonts.montserrat(
                        color: Colors.white70,
                        fontSize: screenTextScaleFactor <= 1.3 ? 12 : 7,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      email,
                      style: GoogleFonts.montserrat(
                        color: Colors.white70,
                        fontSize: screenTextScaleFactor <= 1.3 ? 12 : 7,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Copy the full userId to the clipboard
                      Clipboard.setData(ClipboardData(text: userId));
                      // Show a toast message to indicate the text has been copied
                      Fluttertoast.showToast(
                        msg: userId,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                      );
                    },
                    child: Text(
                      'User ID: ${userId.substring(0, 18)}...',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: screenTextScaleFactor <= 1.3 ? 13 : 5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                title: Text(
                  'Requests',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (BuildContext context) =>
                  //             RequestPage(userId: userId)));

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          RequestPage(
                        userId: userId,
                      ),
                      transitionDuration: Duration(
                          milliseconds:
                              200), // Longer duration for bouncy effect
                      reverseTransitionDuration: Duration(
                          milliseconds: 200), // Optional: Set reverse duration
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); // Slide from bottom
                        const end = Offset.zero;
                        const curve = Curves.elasticOut; // Bouncy curve
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        // Add a fade transition
                        var fadeTween = Tween(begin: 0.0, end: 1.0);
                        var fadeAnimation = animation.drive(fadeTween);

                        // Add a scale transition with a bouncy curve
                        var scaleTween = Tween(
                            begin: 0.8, end: 1.0); // Scale from 80% to 100%
                        var scaleAnimation = animation.drive(scaleTween
                            .chain(CurveTween(curve: Curves.elasticOut)));

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Icon(
                  Icons.chat,
                  color: Colors.white,
                ),
                title: Text(
                  'Chats',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ChatPage(
                        userId: userId,
                      ),
                      transitionDuration: Duration(
                          milliseconds:
                              200), // Longer duration for bouncy effect
                      reverseTransitionDuration: Duration(
                          milliseconds: 200), // Optional: Set reverse duration
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); // Slide from bottom
                        const end = Offset.zero;
                        const curve = Curves.elasticOut; // Bouncy curve
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        // Add a fade transition
                        var fadeTween = Tween(begin: 0.0, end: 1.0);
                        var fadeAnimation = animation.drive(fadeTween);

                        // Add a scale transition with a bouncy curve
                        var scaleTween = Tween(
                            begin: 0.8, end: 1.0); // Scale from 80% to 100%
                        var scaleAnimation = animation.drive(scaleTween
                            .chain(CurveTween(curve: Curves.elasticOut)));

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                ),
                title: Text(
                  'Statistics',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          StatisticsPage(
                        userId: userId,
                      ),
                      transitionDuration: Duration(
                          milliseconds:
                              200), // Longer duration for bouncy effect
                      reverseTransitionDuration: Duration(
                          milliseconds: 200), // Optional: Set reverse duration
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); // Slide from bottom
                        const end = Offset.zero;
                        const curve = Curves.elasticOut; // Bouncy curve
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        // Add a fade transition
                        var fadeTween = Tween(begin: 0.0, end: 1.0);
                        var fadeAnimation = animation.drive(fadeTween);

                        // Add a scale transition with a bouncy curve
                        var scaleTween = Tween(
                            begin: 0.8, end: 1.0); // Scale from 80% to 100%
                        var scaleAnimation = animation.drive(scaleTween
                            .chain(CurveTween(curve: Curves.elasticOut)));

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Icon(
                  Icons.directions_car,
                  color: Colors.white,
                ),
                title: Text(
                  'Trips',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HistoryPage(
                        userId: userId,
                      ),
                      transitionDuration: Duration(
                          milliseconds:
                              200), // Longer duration for bouncy effect
                      reverseTransitionDuration: Duration(
                          milliseconds: 200), // Optional: Set reverse duration
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); // Slide from bottom
                        const end = Offset.zero;
                        const curve = Curves.elasticOut; // Bouncy curve
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        // Add a fade transition
                        var fadeTween = Tween(begin: 0.0, end: 1.0);
                        var fadeAnimation = animation.drive(fadeTween);

                        // Add a scale transition with a bouncy curve
                        var scaleTween = Tween(
                            begin: 0.8, end: 1.0); // Scale from 80% to 100%
                        var scaleAnimation = animation.drive(scaleTween
                            .chain(CurveTween(curve: Curves.elasticOut)));

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Icon(
                  Icons.person_4_sharp,
                  color: Colors.white,
                ),
                title: Text(
                  'Driver Login',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation, secondaryAnimation) =>
                  //         DriverRegistrationPage(),
                  //     transitionDuration: Duration(
                  //         milliseconds: 200), // Duration for the transition
                  //     reverseTransitionDuration: Duration(
                  //         milliseconds: 200), // Optional: Set reverse duration
                  //     transitionsBuilder:
                  //         (context, animation, secondaryAnimation, child) {
                  //       // Add a rotation transition
                  //       var rotateTween = Tween(
                  //           begin: 0.0,
                  //           end: 1.0); // Rotate from 0 to 360 degree (0 to 1 scaling ma ho)s
                  //       var rotateAnimation = animation.drive(rotateTween
                  //           .chain(CurveTween(curve: Curves.easeInOut)));

                  //       // Add a fade transition
                  //       var fadeTween = Tween(begin: 0.0, end: 1.0);
                  //       var fadeAnimation = animation.drive(fadeTween);

                  //       // Add a scale transition
                  //       var scaleTween = Tween(
                  //           begin: 0.5, end: 1.0); // Scale from 50% to 100%
                  //       var scaleAnimation = animation.drive(scaleTween
                  //           .chain(CurveTween(curve: Curves.easeInOut)));

                  //       return FadeTransition(
                  //         opacity: fadeAnimation,
                  //         child: ScaleTransition(
                  //           scale: scaleAnimation,
                  //           child: RotationTransition(
                  //             turns: rotateAnimation,
                  //             child: child,
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // );

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          DriverRegistrationPage(),
                      transitionDuration:
                          Duration(milliseconds: 300), // Smooth 300ms
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        // A gentle fade from 0 to 1
                        final fadeAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves
                              .easeInOut, // standard, smooth curve finishing almost
                        );

                        // A very subtle scale from 95% to 100%
                        final scaleAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        );

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.0)
                                .animate(scaleAnimation), // Very subtle scale
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                title: Text(
                  'Logout',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20.0), // Rounded corners
                        ),
                        elevation: 10, // Shadow
                        backgroundColor: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min, // Fit content height
                            children: [
                              // Icon at the top
                              Icon(
                                Icons.exit_to_app,
                                size: 50,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 16),
                              // Title
                              Text(
                                'Confirm Sign Out',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Subtitle
                              Text(
                                'Are you sure you want to sign out?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              // Buttons Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Cancel Button
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      backgroundColor: Colors.grey[200],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  // Sign Out Button
                                  TextButton(
                                    onPressed: () {
                                      // Sign out and navigate to the SignInPage
                                      FirebaseAuth.instance.signOut();
                                      GoogleSignIn().signOut();
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignInPage(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign Out',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
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
            // Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: ListTile(
            //     leading: Icon(
            //       Icons.person_4_sharp,
            //       color: Colors.white,
            //     ),
            //     title: Text(
            //       'UID: $userId',
            //       style: TextStyle(
            //           color: Colors.white, fontWeight: FontWeight.w500),
            //     ),
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => DriverRegistrationPage(),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Widget _buildStatCard({
  //   required String title,
  //   required String value,
  //   required Color color,
  //   required double screenWidth,
  // }) {
  //   return Card(
  //     elevation: 0.5,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.all(screenWidth * 0.04), // Make padding responsive
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: Text(
  //               title,
  //               style: TextStyle(
  //                 fontSize: 18, // Responsive font size
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //           Text(
  //             value,
  //             style: TextStyle(
  //               fontSize: 18, // Responsive font size
  //               fontWeight: FontWeight.bold,
  //               color: color,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color cardColor,
    required IconData iconData,
    required Color iconColor,
    required double screenWidth,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: cardColor, // Custom card color
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Make padding responsive
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: screenWidth * 0.1, // Responsive icon size
              color: iconColor,
            ),
            SizedBox(
                height: screenWidth * 0.02), // Spacer between icon and text
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.05, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.05, // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color below icon
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieChartSection({
    required String title,
    required double value,
    required Color color,
  }) {
    return PieChartSectionData(
      value: value,
      color: color,
      title: value.toStringAsFixed(2),
      titleStyle: TextStyle(
        fontSize: 0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
