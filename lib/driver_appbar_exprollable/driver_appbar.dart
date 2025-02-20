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
//   Size get preferredSize => Size.fromHeight(kToolbarHeight);

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
//               style: GoogleFonts.outfit(color: Colors.black87, fontSize: 18),
//             );
//           },
//         ),
//       ),
//       centerTitle: true,
//       actions: [
//         IconButton(
//           icon: Icon(widget.appBarIcons[1], color: Colors.black54, size: 19),
//           onPressed: () {
//             // Show driver info in a dialog
//             _showDriverInfoDialog(context);
//           },
//         ),
//       ],
//     );
//   }

//   void _showDriverInfoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return FutureBuilder<DocumentSnapshot>(
//           future: _driverInfoFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError || !snapshot.hasData) {
//               return AlertDialog(
//                 title: Text('Error'),
//                 content: Text('Driver information not found.'),
//                 actions: [
//                   TextButton(
//                     child: Text('OK'),
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
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: widget.appBarColor,
//                   ),
//                 ),
//                 content: Container(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Row(
//                             children: [
//                               SizedBox(width: 15),
//                               CircleAvatar(
//                                 radius: 40,
//                                 backgroundImage: NetworkImage(
//                                   data['profilePictureUrl'] ?? '',
//                                 ),
//                               ),
//                               SizedBox(width: 15),
//                               CircleAvatar(
//                                 radius: 40,
//                                 backgroundImage: NetworkImage(
//                                   data['selfieWithCitizenshipUrl'] ?? '',
//                                 ),
//                               ),
//                               SizedBox(width: 15),
//                               CircleAvatar(
//                                 radius: 40,
//                                 backgroundImage: NetworkImage(
//                                   data['selfieWithLicenseUrl'] ?? '',
//                                 ),
//                               ),
//                               SizedBox(width: 15),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           data['name'] ?? 'Unknown',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: widget.appBarColor,
//                           ),
//                         ),
//                         Divider(),
//                         Text(
//                           'Address: ${data['address'] ?? 'Unknown Address'}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.black54),
//                         ),
//                         Divider(),
//                         Text(
//                           'Number Plate: ${data['numberPlate'] ?? 'Unknown'}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.black54),
//                         ),
//                         Divider(),
//                         Text(
//                           'Vehicle: ${data['vehicleType'] ?? 'Unknown'}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.black54),
//                         ),
//                         Divider(),
//                         Text(
//                           'Phone: ${data['phone'] ?? 'Unknown'}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.black54),
//                         ),
//                         Divider(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     child: Text('Close'),
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
      leading: IconButton(
        onPressed: () {},
        icon: Icon(widget.appBarIcons[0], color: Colors.white),
      ),
      backgroundColor: Colors.redAccent, // Red accent color
      title: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vehicleData')
              .doc(widget.driverId)
              .snapshots(),
          builder: (context, snapshot) {
            // if (!snapshot.hasData) {
            //   return Text(
            //     widget.title,
            //     style: GoogleFonts.outfit(
            //       color: Colors.white, // White text for contrast
            //       fontSize: 20,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   );
            // }

            // var displayName = snapshot.data!['name'];

            return Text(
              widget.title,
              style: GoogleFonts.outfit(
                color: Colors.white, // White text for contrast
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            widget.appBarIcons[1],
            color: Colors.white, // White icon for contrast
            size: 24,
          ),
          onPressed: () {
            // Show driver info in a dialog
            _showDriverInfoDialog(context);
          },
        ),
      ],
    );
  }

//   void _showDriverInfoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return FutureBuilder<DocumentSnapshot>(
//           future: _driverInfoFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError || !snapshot.hasData) {
//               return AlertDialog(
//                 title: Text('Error'),
//                 content: Text('Driver information not found.'),
//                 actions: [
//                   TextButton(
//                     child: Text('OK'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               );
//             } else {
//               var data = snapshot.data!.data() as Map<String, dynamic>;
//               return Dialog(
//                 backgroundColor:
//                     Colors.transparent, // Transparent background for gradient
//                 elevation: 0,
//                 child: AnimatedContainer(
//                   duration: Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.redAccent, Colors.orangeAccent],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Title
//                         Text(
//                           'Driver Info',
//                           style: GoogleFonts.outfit(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         // Images in a horizontal scrollable row
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Row(
//                             children: [
//                               _buildImageCard(data['profilePictureUrl'] ?? ''),
//                               SizedBox(width: 10),
//                               _buildImageCard(
//                                   data['selfieWithCitizenshipUrl'] ?? ''),
//                               SizedBox(width: 10),
//                               _buildImageCard(
//                                   data['selfieWithLicenseUrl'] ?? ''),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         // Driver Name
//                         Text(
//                           data['name'] ?? 'Unknown',
//                           style: GoogleFonts.outfit(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         // Driver Details
//                         _buildDetailRow(
//                             'Address', data['address'] ?? 'Unknown Address'),
//                         _buildDetailRow(
//                             'Number Plate', data['numberPlate'] ?? 'Unknown'),
//                         _buildDetailRow(
//                             'Vehicle', data['vehicleType'] ?? 'Unknown'),
//                         _buildDetailRow('Phone', data['phone'] ?? 'Unknown'),
//                         SizedBox(height: 20),
//                         // Close Button
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 30, vertical: 12),
//                             backgroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             elevation: 5,
//                           ),
//                           child: Text(
//                             'Close',
//                             style: GoogleFonts.outfit(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.redAccent,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }
//           },
//         );
//       },
//     );
//   }

// // Helper function to build image cards
//   Widget _buildImageCard(String imageUrl) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(15),
//         child: Image.network(
//           imageUrl,
//           width: 100,
//           height: 100,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Container(
//               width: 100,
//               height: 100,
//               color: Colors.grey[200],
//               child: Icon(Icons.person, size: 40, color: Colors.grey[500]),
//             );
//           },
//         ),
//       ),
//     );
//   }

// // Helper function to build detail rows
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: GoogleFonts.outfit(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: GoogleFonts.outfit(
//                 fontSize: 16,
//                 color: Colors.white.withOpacity(0.9),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

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
              return Dialog(
                backgroundColor: Colors.white, // White background
                elevation: 10, // Shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          'Driver Info',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w700, // Bold title
                            color: Colors.redAccent, // Red accent color
                          ),
                        ),
                        SizedBox(height: 20),
                        // Images in a horizontal scrollable row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildImageCard(
                                  context, data['profilePictureUrl'] ?? ''),
                              SizedBox(width: 10),
                              _buildImageCard(context,
                                  data['selfieWithCitizenshipUrl'] ?? ''),
                              SizedBox(width: 10),
                              _buildImageCard(
                                  context, data['selfieWithLicenseUrl'] ?? ''),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Driver Name
                        Text(
                          data['name'] ?? 'Unknown',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w600, // Semi-bold
                            color: Colors.redAccent.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Driver Details
                        _buildDetailRow(
                            'Address', data['address'] ?? 'Unknown Address'),
                        _buildDetailRow(
                            'Number Plate', data['numberPlate'] ?? 'Unknown'),
                        _buildDetailRow(
                            'Vehicle', data['vehicleType'] ?? 'Unknown'),
                        _buildDetailRow(
                            'Type', data['vehicleMode'] ?? 'Unknown'),
                        _buildDetailRow('Phone', data['phone'] ?? 'Unknown'),
                        SizedBox(height: 20),
                        // Close Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            backgroundColor:
                                Colors.redAccent, // Red accent color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600, // Semi-bold
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

// Helper function to build image cards with full-screen on tap
  Widget _buildImageCard(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Show full-screen image on tap
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Stack(
                children: [
                  // Full-screen image
                  InteractiveViewer(
                    panEnabled: true, // Allow panning
                    minScale: 0.5, // Minimum zoom level
                    maxScale: 3, // Maximum zoom level
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.error, size: 40, color: Colors.red),
                        );
                      },
                    ),
                  ),
                  // Close button for full-screen image
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close full-screen image
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: Icon(Icons.person, size: 40, color: Colors.grey[500]),
              );
            },
          ),
        ),
      ),
    );
  }

// Helper function to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.comicNeue(
              fontSize: 16,
              fontWeight: FontWeight.bold, // Medium weight
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.comicNeue(
                fontSize: 16,
                fontWeight: FontWeight.w400, // Regular weight
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
