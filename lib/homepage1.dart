import 'dart:convert';
import 'package:final_menu/splash_screen/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid;
    } else {
      // Handle case where currentUser is null or userId initialization fails
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

        String avatarLetter =
            username.isNotEmpty ? username[0].toUpperCase() : 'U';

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      avatarLetter,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ],
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 10,
                ),
                Image(
                    image: AssetImage(
                      'assets/signin_signup_logo.png',
                    ),
                    height: 40,
                    width: 40),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Tuk Tuk',
                  style: GoogleFonts.comicNeue(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'सवारी बुक',
                              subtitle: 'Get a ride quickly',
                              icon: Icons.map_rounded,
                              onTap: () {
                                String url =
                                    'https://www.openstreetmap.org/directions#map=8/28.401/84.430';

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(
                                      routeTo: '',
                                      url: url,
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
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Sign Out'),
                                content:
                                    Text('Are you sure you want to sign out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Sign out and navigate to the SignInPage
                                      FirebaseAuth.instance.signOut();
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignInPage(),
                                        ),
                                      );
                                    },
                                    child: Text('Sign Out'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
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

    if (title == 'सवारी बुक') {
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
        // color: Colors.transparent,
        elevation: 0.01,

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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      // Remove the overflow property to allow the text to wrap
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.comicNeue(fontSize: 16),
                overflow: TextOverflow.ellipsis, // Subtitle can still overflow
              ),
            ],
          ),
        ),
      ),
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
                                      'https://www.openstreetmap.org/search?query=$mapsearchedplace'
                                      ,routeTo: mapsearchedplace,
                                      ),
                            ),
                            
                          );
                          print('Searched Name with URL IS :                     \n \n \n \t                  https://www.openstreetmap.org/search?query=$mapsearchedplace');
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.transparent,
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
            Text(
              'हजुर लाई स्वागत छ ,',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
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
}
