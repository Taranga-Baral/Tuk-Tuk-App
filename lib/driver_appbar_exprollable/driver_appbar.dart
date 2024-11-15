// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
//   final Color appBarColor;
//   final List<IconData> appBarIcons;
//   final String title;
//   final String driverId;

//   const CustomAppBar({
//     super.key,
//     required this.appBarColor,
//     required this.appBarIcons,
//     required this.title,
//     required this.driverId,
//   });

//   @override
//   Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

//   @override
//   _CustomAppBarState createState() => _CustomAppBarState();
// }

// class _CustomAppBarState extends State<CustomAppBar> {
//   late Future<DocumentSnapshot> _driverInfoFuture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDriverInfo(); // Fetch driver info on init
//   }

//   void _fetchDriverInfo() {
//     _driverInfoFuture = FirebaseFirestore.instance
//         .collection('vehicleData')
//         .doc(widget.driverId)
//         .get();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       leading: Padding(
//         padding: const EdgeInsets.only(left: 20, top: 2),
//         child: Image(image: AssetImage('assets/fordriverlogo.png')),
//       ),
//       // backgroundColor: widget.appBarColor,
//       backgroundColor: Colors.transparent,

//       elevation: 0,

//       title: Center(
//         child: StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('vehicleData')
//               .doc(widget.driverId)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Text('');
//             }

//             var displayName = snapshot.data!['name'];

//             return Text(
//               displayName ?? 'No Name',
//               style: GoogleFonts.josefinSans(color: Colors.black87, fontSize: 18),
//             );
//           },
//         ),
//       ),
//       centerTitle: true,
//       actions: [
//         IconButton(
//           icon: Icon(widget.appBarIcons[1], color: Colors.black54,size: 19,),
//           onPressed: () {
//             // Show driver info in a dialog
//             _showDriverInfoDialog(context);
//           },
//         ),
//       ],
//     );
//   }

//   void _refreshData() {
//     // Re-fetch driver info and call setState to refresh UI
//     setState(() {
//       _fetchDriverInfo();
//     });
//   }

//   // Method to show the driver info in a dialog
//   void _showDriverInfoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return FutureBuilder<DocumentSnapshot>(
//           future: _driverInfoFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError || !snapshot.data!.exists) {
//               return AlertDialog(
//                 title: const Text('Error'),
//                 content: const Text('Driver information not found.'),
//                 actions: [
//                   TextButton(
//                     child: const Text('OK'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               );
//             } else {
//               var data = snapshot.data!.data() as Map<String, dynamic>;
//               return AlertDialog(
//                 backgroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 title: Text(
//                   'Driver Info',
//                   style: TextStyle(
//                     fontSize: MediaQuery.of(context).size.width *
//                         0.06, // Responsive title font size
//                     fontWeight: FontWeight.bold,
//                     color: widget.appBarColor,
//                   ),
//                 ),
//                 content: Container(
//                   width: MediaQuery.of(context).size.width *
//                       0.8, // Responsive dialog width
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: 15,
//                             ),
//                             CircleAvatar(
//                               radius: MediaQuery.of(context).size.width *
//                                   0.1, // Responsive avatar size
//                               backgroundImage: NetworkImage(
//                                 data['profilePictureUrl'] ?? '',
//                               ),
//                             ),
//                             SizedBox(
//                               width: 15,
//                             ),
//                             CircleAvatar(
//                               radius: MediaQuery.of(context).size.width *
//                                   0.1, // Responsive avatar size
//                               backgroundImage: NetworkImage(
//                                 data['selfieWithCitizenshipUrl'] ?? '',
//                               ),
//                             ),
//                             SizedBox(
//                               width: 15,
//                             ),
//                             CircleAvatar(
//                               radius: MediaQuery.of(context).size.width *
//                                   0.1, // Responsive avatar size
//                               backgroundImage: NetworkImage(
//                                 data['selfieWithLicenseUrl'] ?? '',
//                               ),
//                             ),
//                             SizedBox(
//                               width: 15,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         data['name'] ?? 'Unknown',
//                         style: TextStyle(
//                           fontSize: MediaQuery.of(context).size.width *
//                               0.045, // Responsive text size
//                           fontWeight: FontWeight.bold,
//                           color: widget.appBarColor,
//                         ),
//                       ),
//                       Divider(),
//                       Text(
//                         'Address: ${data['address'] ?? 'Unknown Address'}',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.black54),
//                       ),
//                       Divider(),
//                       Text(
//                         'Number Plate: ${data['numberPlate'] ?? 'Unknown'}',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.black54),
//                       ),
//                       Divider(),
//                       Text(
//                         'Vehicle: ${data['vehicleType'] ?? 'Unknown'}',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.black54),
//                       ),
//                       Divider(),
//                       Text(
//                         'Phone: ${data['phone'] ?? 'Unknown'}',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.black54),
//                       ),
//                       Divider(),
//                     ],
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     child: const Text('Close'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               );
//             }
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Color appBarColor;
  final List<IconData> appBarIcons;
  final String title;
  final String driverId;

  const CustomAppBar({
    super.key,
    required this.appBarColor,
    required this.appBarIcons,
    required this.title,
    required this.driverId,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late Future<DocumentSnapshot> _driverInfoFuture;

  @override
  void initState() {
    super.initState();
    _fetchDriverInfo(); // Fetch driver info on init
  }

  void _fetchDriverInfo() {
    _driverInfoFuture = FirebaseFirestore.instance
        .collection('vehicleData')
        .doc(widget.driverId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 2),
        child: Image(image: AssetImage('assets/fordriverlogo.png')),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vehicleData')
              .doc(widget.driverId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('');
            }

            var displayName = snapshot.data!['name'];

            return Text(
              displayName ?? 'No Name',
              style: GoogleFonts.outfit(color: Colors.black87, fontSize: 18),
            );
          },
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(widget.appBarIcons[1], color: Colors.black54, size: 19),
          onPressed: () {
            // Show driver info in a dialog
            _showDriverInfoDialog(context);
          },
        ),
      ],
    );
  }

  void _showDriverInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<DocumentSnapshot>(
          future: _driverInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Driver information not found.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text(
                  'Driver Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.appBarColor,
                  ),
                ),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(width: 15),
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  data['profilePictureUrl'] ?? '',
                                ),
                              ),
                              SizedBox(width: 15),
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  data['selfieWithCitizenshipUrl'] ?? '',
                                ),
                              ),
                              SizedBox(width: 15),
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  data['selfieWithLicenseUrl'] ?? '',
                                ),
                              ),
                              SizedBox(width: 15),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          data['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.appBarColor,
                          ),
                        ),
                        Divider(),
                        Text(
                          'Address: ${data['address'] ?? 'Unknown Address'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        Divider(),
                        Text(
                          'Number Plate: ${data['numberPlate'] ?? 'Unknown'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        Divider(),
                        Text(
                          'Vehicle: ${data['vehicleType'] ?? 'Unknown'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        Divider(),
                        Text(
                          'Phone: ${data['phone'] ?? 'Unknown'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}
