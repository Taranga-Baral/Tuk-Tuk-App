// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:rxdart/rxdart.dart';

// class ChatDetailPage extends StatefulWidget {
//   final String userId;
//   final String driverId;
//   final String tripId;
//   final String driverName;
//   final String pickupLocation;
//   final String deliveryLocation;
//   final String distance;
//   final String fare;
//   final int no_of_person;
//   final String vehicle_mode;

//   const ChatDetailPage({
//     super.key,
//     required this.userId,
//     required this.driverId,
//     required this.tripId,
//     required this.driverName,
//     required this.pickupLocation,
//     required this.deliveryLocation,
//     required this.distance,
//     required this.fare,
//     required this.no_of_person,
//     required this.vehicle_mode,
//   });

//   @override
//   State<ChatDetailPage> createState() => _ChatDetailPageState();
// }

// class _ChatDetailPageState extends State<ChatDetailPage> {
//   Future<String?> fetchDriverProfilePicture() async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     final driverSnapshot =
//         await firestore.collection('vehicleData').doc(widget.driverId).get();
//     return driverSnapshot.data()?['profilePictureUrl'];
//   }

//   Stream<List<Map<String, dynamic>>> _getMessages() {
//     final userChatsStream = FirebaseFirestore.instance
//         .collection('userChats')
//         .where('tripId', isEqualTo: widget.tripId)
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         data['collection'] = 'userChats';
//         return data;
//       }).toList();
//     });

//     final driverChatsStream = FirebaseFirestore.instance
//         .collection('driverChats')
//         .where('tripId', isEqualTo: widget.tripId)
//         .orderBy('timestamp', descending: false)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         data['collection'] = 'driverChats';
//         return data;
//       }).toList();
//     });

//     return Rx.combineLatest2(userChatsStream, driverChatsStream,
//         (userChats, driverChats) {
//       List<Map<String, dynamic>> allChats = [];
//       allChats.addAll(userChats);
//       allChats.addAll(driverChats);
//       allChats.sort((a, b) {
//         final timestampA = a['timestamp'] as Timestamp?;
//         final timestampB = b['timestamp'] as Timestamp?;
//         if (timestampA == null || timestampB == null) {
//           return 0;
//         }
//         return timestampA.compareTo(timestampB);
//       });
//       return allChats;
//     });
//   }

//   void _showTripDetails(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Trip Details'),
//         content: SingleChildScrollView(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'चालकको नाम : ${widget.driverName}',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'उठाउने स्थान : ${widget.pickupLocation}',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'डेलिभरी स्थान : ${widget.deliveryLocation}',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'दूरी : ${widget.distance} km',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'भाडा : NPR ${widget.fare}',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'यात्री (हरू) : ${widget.no_of_person}',
//                   textAlign: TextAlign.left,
//                 ),
//                 Divider(),
//                 Text(
//                   'सवारी साधनको प्रकार : ${widget.vehicle_mode}',
//                   textAlign: TextAlign.left,
//                 ),
//               ],
//             ),
//           ]),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.blueAccent,
//             ),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     TextEditingController messageController = TextEditingController();

//     return Scaffold(
//       resizeToAvoidBottomInset:
//           true, // Ensure the body resizes to avoid the keyboard
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             backgroundColor: Colors.blueAccent,
//             expandedHeight: 200.0,
//             floating: false,
//             stretch: true,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               centerTitle: true,
//               title: FutureBuilder<String?>(
//                 future: fetchDriverProfilePicture(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     // return Text('Loading...');
//                     return Center(
//                       child: Image(image: AssetImage('assets/logo.png')),
//                     );
//                   }
//                   if (snapshot.hasError || !snapshot.hasData) {
//                     // return Text('Driver: $driverName');
//                     return Center(
//                       child: Image(image: AssetImage('assets/logo.png')),
//                     );
//                   }
//                   String? profilePictureUrl = snapshot.data;
//                   return GestureDetector(
//                     onTap: () => _showTripDetails(context),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         AvatarGlow(
//                           glowColor: Colors.blueAccent,
//                           duration: Duration(milliseconds: 2000),
//                           repeat: true,
//                           child: CircleAvatar(
//                             radius: 20,
//                             // backgroundImage: profilePictureUrl != null
//                             //     ? NetworkImage(profilePictureUrl)
//                             //     : AssetImage('assets/tuktuk1.png')
//                             //         as ImageProvider,
//                             backgroundImage: NetworkImage(profilePictureUrl!),
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Text(
//                           widget.driverName,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               background: LayoutBuilder(
//                 builder: (context, constraints) {
//                   final double maxHeight = constraints.maxHeight;
//                   const double minHeight = kToolbarHeight;
//                   final double currentHeight = constraints.biggest.height;
//                   final double opacity =
//                       (currentHeight - minHeight) / (maxHeight - minHeight);

//                   return FutureBuilder<String?>(
//                     future: fetchDriverProfilePicture(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       }
//                       if (snapshot.hasError || !snapshot.hasData) {
//                         return Center(child: Icon(Icons.error));
//                       }
//                       String? profilePictureUrl = snapshot.data;
//                       return Opacity(
//                         opacity: opacity.clamp(1, 1.0),
//                         child: Image.network(
//                           profilePictureUrl!,
//                           fit: BoxFit.cover,
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             leading: InkWell(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildListDelegate([
//               // Chat messages
//               StreamBuilder<List<Map<String, dynamic>>>(
//                 stream: _getMessages(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }

//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return Center(child: Text('No messages.'));
//                   }

//                   final messages = snapshot.data!;

//                   return ListView.builder(
//                     padding: EdgeInsets.all(10.0),
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final chatData = messages[index];
//                       final isDriverMessage =
//                           chatData['collection'] == 'driverChats';

//                       return Align(
//                         alignment: isDriverMessage
//                             ? Alignment.centerLeft
//                             : Alignment.centerRight,
//                         child: Container(
//                           margin: EdgeInsets.symmetric(
//                               vertical: 6.0, horizontal: 10.0),
//                           padding: EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             color: isDriverMessage
//                                 ? Colors.green.withOpacity(0.3)
//                                 : Colors.blueAccent.withOpacity(0.8),
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(20),
//                               topRight: Radius.circular(20),
//                               bottomLeft: isDriverMessage
//                                   ? Radius.circular(20)
//                                   : Radius.circular(0),
//                               bottomRight: isDriverMessage
//                                   ? Radius.circular(0)
//                                   : Radius.circular(20),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 5,
//                                 offset: Offset(0, 3),
//                               )
//                             ],
//                           ),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.7),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 chatData['message'],
//                                 style: TextStyle(
//                                   color: isDriverMessage
//                                       ? Colors.black87
//                                       : Colors.white,
//                                   fontSize: 16.0,
//                                 ),
//                               ),
//                               SizedBox(height: 5.0),
//                               Text(
//                                 chatData['timestamp'] != null
//                                     ? chatData['timestamp'].toDate().toString()
//                                     : 'Sending...',
//                                 style: TextStyle(
//                                   color: isDriverMessage
//                                       ? Colors.grey[700]
//                                       : Colors.white70,
//                                   fontSize: 12.0,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ]),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context)
//               .viewInsets
//               .bottom, // Adjust padding for keyboard
//         ),
//         child: Container(
//           padding: EdgeInsets.all(8.0),
//           color: Colors.white,
//           child: Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(25.0),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         spreadRadius: 1,
//                         blurRadius: 5,
//                         offset: Offset(0, 3),
//                       )
//                     ],
//                   ),
//                   child: TextField(
//                     controller: messageController,
//                     minLines: 1,
//                     maxLines: null,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.0),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.blueAccent,
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: Icon(Icons.send, color: Colors.white),
//                   onPressed: () async {
//                     if (messageController.text.isNotEmpty) {
//                       await FirebaseFirestore.instance
//                           .collection('userChats')
//                           .add({
//                         'userId': widget.userId,
//                         'driverId': widget.driverId,
//                         'tripId': widget.tripId,
//                         'message': messageController.text,
//                         'timestamp': FieldValue.serverTimestamp(),
//                       });

//                       messageController.clear();
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';

class ChatDetailPage extends StatefulWidget {
  final String userId;
  final String driverId;
  final String tripId;
  final String driverName;
  final String pickupLocation;
  final String deliveryLocation;
  final String distance;
  final String fare;
  final int no_of_person;
  final String vehicle_mode;

  const ChatDetailPage({
    super.key,
    required this.userId,
    required this.driverId,
    required this.tripId,
    required this.driverName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.distance,
    required this.fare,
    required this.no_of_person,
    required this.vehicle_mode,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  String? _cachedProfilePictureUrl;
  bool _isLoadingProfilePicture = true;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final driverSnapshot =
          await firestore.collection('vehicleData').doc(widget.driverId).get();
      if (mounted) {
        setState(() {
          _cachedProfilePictureUrl =
              driverSnapshot.data()?['profilePictureUrl'];
          _isLoadingProfilePicture = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfilePicture = false;
        });
      }
    }
  }

  Stream<List<Map<String, dynamic>>> _getMessages() {
    final userChatsStream = FirebaseFirestore.instance
        .collection('userChats')
        .where('tripId', isEqualTo: widget.tripId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['collection'] = 'userChats';
        return data;
      }).toList();
    });

    final driverChatsStream = FirebaseFirestore.instance
        .collection('driverChats')
        .where('tripId', isEqualTo: widget.tripId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['collection'] = 'driverChats';
        return data;
      }).toList();
    });

    return Rx.combineLatest2(userChatsStream, driverChatsStream,
        (userChats, driverChats) {
      List<Map<String, dynamic>> allChats = [];
      allChats.addAll(userChats);
      allChats.addAll(driverChats);
      allChats.sort((a, b) {
        final timestampA = a['timestamp'] as Timestamp?;
        final timestampB = b['timestamp'] as Timestamp?;
        if (timestampA == null || timestampB == null) {
          return 0;
        }
        return timestampA.compareTo(timestampB);
      });
      return allChats;
    });
  }

  //start
  void _showTripDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.only(top: 12, bottom: 8),
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trip Summary',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueAccent),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 24),
                        color: Colors.grey[600],
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      // Driver Card
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 80,
                          maxWidth: double.infinity,
                        ),
                        child: _buildInfoCard(
                          icon: Icons.person_outline_rounded,
                          iconColor: Colors.indigo,
                          title: 'Driver',
                          value: widget.driverName,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Location Cards
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 80,
                          maxWidth: double.infinity,
                        ),
                        child: _buildLocationCard(
                          icon: Icons.location_on,
                          iconColor: Colors.green[600]!,
                          title: 'Pickup Location',
                          value: widget.pickupLocation,
                          backgroundColor: Colors.green[50]!,
                        ),
                      ),

                      SizedBox(height: 12),

                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 80,
                          maxWidth: double.infinity,
                        ),
                        child: _buildLocationCard(
                          icon: Icons.location_on,
                          iconColor: Colors.red[600]!,
                          title: 'Delivery Location',
                          value: widget.deliveryLocation,
                          backgroundColor: Colors.red[50]!,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Details Grid - Using Wrap instead of GridView
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 72) / 2,
                            child: _buildDetailChip(
                              icon: Icons.speed_rounded,
                              label: 'Kilometer',
                              value: double.parse(widget.distance)
                                  .toStringAsFixed(1),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 72) / 2,
                            child: _buildDetailChip(
                              icon: Icons.currency_rupee,
                              label: 'NPR',
                              value: '${widget.fare}',
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 72) / 2,
                            child: _buildDetailChip(
                              icon: Icons.people_alt_rounded,
                              label: 'Passengers',
                              value: widget.no_of_person.toString(),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 72) / 2,
                            child: _buildDetailChip(
                              icon: _getVehicleIcon(),
                              label: 'Vehicle',
                              value: widget.vehicle_mode,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Button
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      minimumSize: Size(double.infinity, 56),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close Details',
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: iconColor),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: iconColor.withOpacity(0.8),
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo[600]),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon() {
    switch (widget.vehicle_mode.toLowerCase()) {
      case 'taxi':
        return Icons.local_taxi_rounded;
      case 'bike':
        return Icons.electric_bike_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  //end
  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.blueAccent,
            expandedHeight: 200.0,
            floating: false,
            stretch: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: _isLoadingProfilePicture
                  ? Center(
                      child: Image(image: AssetImage('assets/logo.png')),
                    )
                  : _cachedProfilePictureUrl == null
                      ? Center(
                          child: Image(image: AssetImage('assets/logo.png')))
                      : GestureDetector(
                          onTap: () => _showTripDetails(context),
                          child: Row(
                            // mainAxisSize: MainAxisSize.space,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              AvatarGlow(
                                glowColor: Colors.blueAccent,
                                duration: Duration(milliseconds: 2000),
                                repeat: true,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      NetworkImage(_cachedProfilePictureUrl!),
                                ),
                              ),
                              // SizedBox(width: 12),
                              Text(
                                widget.driverName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 35,
                              ),
                            ],
                          ),
                        ),
              background: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxHeight = constraints.maxHeight;
                  const double minHeight = kToolbarHeight;
                  final double currentHeight = constraints.biggest.height;
                  final double opacity =
                      (currentHeight - minHeight) / (maxHeight - minHeight);

                  return _isLoadingProfilePicture
                      ? Center(child: CircularProgressIndicator())
                      : _cachedProfilePictureUrl == null
                          ? Center(child: Icon(Icons.error))
                          : Opacity(
                              opacity: opacity.clamp(1, 1.0),
                              child: Image.network(
                                _cachedProfilePictureUrl!,
                                fit: BoxFit.cover,
                                cacheWidth: (MediaQuery.of(context).size.width *
                                        MediaQuery.of(context).devicePixelRatio)
                                    .round(),
                              ),
                            );
                },
              ),
            ),
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                        color: Colors.redAccent.withAlpha(230),
                        height: 35,
                        width: double.infinity,
                        child: Center(
                            child: Text(
                          'No any Messages',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        )));
                  }

                  final messages = snapshot.data!;

                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final chatData = messages[index];
                      final isDriverMessage =
                          chatData['collection'] == 'driverChats';

                      return Align(
                        alignment: isDriverMessage
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 10.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isDriverMessage
                                ? Colors.redAccent.withOpacity(0.3)
                                : Colors.blueAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: isDriverMessage
                                  ? Radius.circular(20)
                                  : Radius.circular(0),
                              bottomRight: isDriverMessage
                                  ? Radius.circular(0)
                                  : Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatData['message'],
                                style: TextStyle(
                                  color: isDriverMessage
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                chatData['timestamp'] != null
                                    ? chatData['timestamp'].toDate().toString()
                                    : 'Sending...',
                                style: TextStyle(
                                  color: isDriverMessage
                                      ? Colors.grey[700]
                                      : Colors.white70,
                                  fontSize: 12.0,
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
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(8.0),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () async {
                    if (messageController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('userChats')
                          .add({
                        'userId': widget.userId,
                        'driverId': widget.driverId,
                        'tripId': widget.tripId,
                        'message': messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      messageController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
