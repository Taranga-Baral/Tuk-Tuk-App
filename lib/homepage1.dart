// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
// import 'package:final_menu/Statistics_page/Statistics-Page.dart';
// import 'package:final_menu/chat/chat.dart';
// import 'package:final_menu/history_page/history_page.dart';
// import 'package:final_menu/homepage.dart';
// import 'package:final_menu/login_screen/sign_in_page.dart';
// import 'package:final_menu/request_from_driver_page.dart/request.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HomePage1 extends StatelessWidget {
//   final String pickupLatitude = '';
//   final String pickupLongitude = '';
//   final String deliveryLatitude = '27.6098';
//   final String deliveryLongitude = '84.5119';

//   const HomePage1({super.key});

//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String? message =
//         ModalRoute.of(context)?.settings.arguments as String?;
//     final User? currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       return Scaffold(
//         body: Center(
//           child: Text('No user is logged in'),
//         ),
//       );
//     }

//     final String userId = currentUser.uid;
//     CollectionReference users = FirebaseFirestore.instance.collection('users');

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (message != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message)),
//         );
//       }
//     });

//     return FutureBuilder<DocumentSnapshot>(
//       future: users.doc(userId).get(),
//       builder:
//           (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(
//                 child: Text('Error loading user data: ${snapshot.error}')),
//           );
//         }

//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return Scaffold(
//             body: Center(child: Text('User data not found. User ID: $userId')),
//           );
//         }

//         Map<String, dynamic> data =
//             snapshot.data!.data() as Map<String, dynamic>;
//         String username = data['username'] ?? 'Unknown User';
//         String phoneNumber = data['phone_number'] ?? 'No Phone Number';
//         String email = currentUser.email ?? 'No Email';

//         return Scaffold(
//           appBar: AppBar(
//             title: Text('Tuk Tuk'),
//           ),
// body: LayoutBuilder(
//   builder: (BuildContext context, BoxConstraints constraints) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.only(left: 0,right: 0),
//             child: _buildUserDetailsCard(
//               context: context,
//               username: username,
//               avatarLetter: username.isNotEmpty
//                   ? username[0].toUpperCase()
//                   : 'U',
//             ),
//           ),
//           SizedBox(height: 25),
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: constraints.maxWidth * 0.05),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildCard(

//                     context: context,
//                     title: 'Ride',
//                     subtitle: 'Get a ride quickly',
//                     icon: Icons.map_rounded,
//                     onTap: () {
//                       String url =
//                           'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => HomePage(url: url),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: _buildCard(
//                     context: context,
//                     title: 'Approve',
//                     subtitle: 'Approve Drivers',
//                     icon: Icons.send,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => RequestPage(
//                             userId: userId,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: constraints.maxWidth * 0.05),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildCard(
//                     context: context,
//                     title: 'Statistics',
//                     subtitle: 'Your Stats',
//                     icon: Icons.calculate,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => StatisticsPage(
//                             userId: userId,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: _buildCard(
//                     context: context,
//                     title: 'Chats',
//                     subtitle: 'Communicate',
//                     icon: Icons.chat,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ChatPage(
//                             userId: userId,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: constraints.maxWidth * 0.05),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildCard(
//                     context: context,
//                     title: 'View History',
//                     subtitle: 'Past rides',
//                     icon: Icons.history,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => HistoryPage(
//                             userId: userId,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: _buildCard(
//                     context: context,
//                     title: 'Driver',
//                     subtitle: 'Start driving',
//                     icon: Icons.electric_rickshaw_outlined,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               DriverRegistrationPage(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(height: 20),
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: constraints.maxWidth * 0.05),
//             child: _buildCard(
//               context: context,
//               title: 'Passenger Signout',
//               subtitle: 'Sign out safely',
//               icon: Icons.logout,
//               isFullWidth: true,
//               onTap: () {
//                 FirebaseAuth.instance.signOut();
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SignInPage(),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   },
// ),
//       );
//     },
//   );
// }

// Widget _buildCard({
//   required BuildContext context,
//   required String title,
//   required String subtitle,
//   required IconData icon,
//   required VoidCallback onTap,
//   bool isFullWidth = false,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Card(

//       margin: EdgeInsets.only(bottom: 20),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon),
//                 SizedBox(width: 10),
//                 Flexible(
//                   child: Text(
//                     title,
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     overflow: TextOverflow.ellipsis, // Prevent overflow
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(subtitle, overflow: TextOverflow.ellipsis),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// Widget _buildUserDetailsCard({
//   required BuildContext context,
//   required String username,
//   required String avatarLetter,
// }) {
//   // Controller for the search field
//   TextEditingController searchController = TextEditingController();

//   // Function to handle Nominatim API search
//   Future<List<Map<String, dynamic>>> searchLocations(String query) async {
//     final url =
//         'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5';
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data
//           .map((item) => {
//                 'display_name': item['display_name'],
//                 'lat': item['lat'],
//                 'lon': item['lon'],
//               })
//           .toList();
//     } else {
//       throw Exception('Failed to load locations');
//     }
//   }

//   // Function to display results in a popup
// void showSearchResults(BuildContext context, List<Map<String, dynamic>> results) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Search Results'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: results.length,
//             itemBuilder: (BuildContext context, int index) {
//               final result = results[index];
//               return ListTile(
//                 title: Text(result['display_name']),
//                 onTap: () {
//                   // Store the selected value in the global variable
//                   var pacetogo = result['display_name'];

//                   Navigator.of(context).pop(); // Close the popup on tap

//                   // You can handle additional actions here if needed
//                 },
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Close'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
//     child: Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         gradient: LinearGradient(
//           colors: [Colors.blueAccent, Colors.lightBlueAccent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Row for avatar and welcome message
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Circle Avatar
//               CircleAvatar(
//                 radius: 25,
//                 backgroundColor: Colors.white,
//                 child: Text(
//                   avatarLetter,
//                   style: TextStyle(
//                     color: Colors.blueAccent,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10),
//             ],
//           ),
//           SizedBox(height: 20),
//           // Welcome message
//           Text(
//             'Welcome back,',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           Text(
//             '$username!',
//             style: TextStyle(
//               fontSize: 24,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 20),
//           // Row for "Tuk Tuk" button and calendar icon
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Tuk Tuk Button
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   "We need your Help",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               // Calendar Icon
//               IconButton(
//                 icon: Icon(
//                   Icons.electric_rickshaw_rounded,
//                   color: Colors.white,
//                 ),
//                 onPressed: () {
//                   // Handle calendar action here
//                 },
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           // Search Bar
//           TextField(
//             controller: searchController,
//             onSubmitted: (query) async {
//               if (query.isNotEmpty) {
//                 // Search for locations using Nominatim API
//                 List<Map<String, dynamic>> results = await searchLocations(query);
//                 // Show the results in a popup
//                 showSearchResults(context, results);
//               }
//             },
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               prefixIcon: Icon(Icons.search, color: Colors.grey),
//               hintText: 'Where do you want to go ?',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// }

import 'dart:convert';
import 'package:final_menu/main.dart';
import 'package:final_menu/splash_screen/splash_screen.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  _HomePage1State createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
  String mapsearchedplace = '';
  final String deliveryLatitude = '27.6098';
  final String deliveryLongitude = '84.5119';

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? message =
        ModalRoute.of(context)?.settings.arguments as String?;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('No user is logged in'),
        ),
      );
    }
    IconData iconData;
    Color iconColor;
    final String userId = currentUser.uid;
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: SplashScreen()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
                child: Text('Error loading user data: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text('User data not found. User ID: $userId')),
          );
        }

        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        String username = data['username'] ?? 'Unknown User';
        String phoneNumber = data['phone_number'] ?? 'No Phone Number';
        String email = currentUser.email ?? 'No Email';

        return Scaffold(
          appBar: AppBar(
            title: Text('Tuk Tuk'),
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: Column(
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
                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'टुक टुक बोलौने',
                              subtitle: 'Get a ride quickly',
                              icon: Icons.map_rounded,
                              onTap: () {
                                String url = 'https://www.openstreetmap.org/';

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(url: url),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'जान राजी चालक',
                              subtitle: 'Approve Drivers',
                              icon: Icons.send,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RequestPage(
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'हजुरको विवरण',
                              subtitle: 'Your Stats',
                              icon: Icons.calculate,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StatisticsPage(
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'चालक संग वार्तालाप',
                              subtitle: 'Communicate',
                              icon: Icons.chat,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'पुर्व यत्रा',
                              subtitle: 'Past ride',
                              icon: Icons.history,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HistoryPage(
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'चालक मोड',
                              subtitle: 'Start driving',
                              icon: Icons.electric_rickshaw_outlined,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DriverRegistrationPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05),
                      child: _buildCard(
                        context: context,
                        title: 'बाहिर निस्किने ?',
                        subtitle: 'Signout Safely',
                        icon: Icons.logout,
                        isFullWidth: true,
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ... (rest of the widget code, including _buildCard and _buildUserDetailsCard)

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
                                  url:
                                      'https://www.openstreetmap.org/search?query=$mapsearchedplace'),
                            ),
                          );
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
                    colors: [
                      const Color.fromARGB(255, 127, 182, 226),
                      const Color.fromARGB(255, 211, 135, 224),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
                        
              const Color.fromARGB(255, 201, 78, 223),
              const Color.fromARGB(255, 136, 100, 235),
              const Color.fromARGB(255, 69, 178, 228),
              
        
            
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for avatar and welcome message
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circle Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Text(
                    avatarLetter,
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'हजुर लाई स्वागत छ ,',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            Text(
              '$username!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Search field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'कहाँ जानू हुन्छ त ?',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              // Inside _buildUserDetailsCard TextField onSubmitted callback
              onSubmitted: (value) async {
                final results = await searchLocations(value);
                showSearchResults(context, results);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    // Determine the color of the icon based on the title
    Color iconColor;

    if (title == 'टुक टुक बोलौने') {
      iconColor = const Color.fromARGB(255, 226, 93, 52).withOpacity(0.8);
    } else if (title == 'जान राजी चालक') {
      iconColor = const Color.fromARGB(255, 70, 153, 221);
    } else if (title == 'हजुरको विवरण') {
      iconColor = const Color.fromARGB(255, 181, 197, 37);
    } else if (title == 'चालक संग वार्तालाप') {
      iconColor = const Color.fromARGB(255, 75, 182, 130).withOpacity(0.9);
    } else if (title == 'पुर्व यत्रा') {
      iconColor = const Color.fromARGB(255, 226, 183, 54);
    } else if (title == 'चालक मोड') {
      iconColor = const Color.fromARGB(255, 127, 94, 185);
    } else {
      iconColor = Colors.red; // Default color if title doesn't match
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Set the color of the icon dynamically
                  Icon(icon, color: iconColor),

                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      // Remove the overflow property to allow the text to wrap
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis, // Subtitle can still overflow
              ),
            ],
          ),
        ),
      ),
    );
  }
}
