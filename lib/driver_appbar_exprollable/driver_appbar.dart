import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

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
    fetchTotalFare(widget.driverId); // Fetch total fare on init
  }

  Future<double> fetchPaidAmount(String driverId) async {
    try {
      // Get the document where documentID == driverId from 'balance' collection
      DocumentSnapshot balanceDoc = await FirebaseFirestore.instance
          .collection('balance')
          .doc(driverId)
          .get();

      if (balanceDoc.exists) {
        // Extract the 'paid' field (assuming it's a number)
        double paidAmount = balanceDoc['paid']?.toDouble() ?? 0.0;
        return paidAmount;
      } else {
        print('No balance record found for driver: $driverId');
        return 0.0; // Default value if document doesn't exist
      }
    } catch (e) {
      print('Error fetching paid amount: $e');
      return 0.0; // Fallback in case of error
    }
  }

  void _fetchDriverInfo() {
    _driverInfoFuture = FirebaseFirestore.instance
        .collection('vehicleData')
        .doc(widget.driverId)
        .get();
  }

  double driverTotalBalance = 0.00;
  double driverTotalMoneyToPay = 0.00;
  double paid = 0.00;
//driver blalnce
  Future<double> fetchTotalFare(String driverId) async {
    // double driverTotalBalance = 0.00;
    // double driverTotalMoneyToPay = 0.00;
    double totalFare = 0.0;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    paid = await fetchPaidAmount(driverId);

    // Step 1: Query confirmedDrivers collection for matching driverId
    QuerySnapshot confirmedDriversSnapshot = await firestore
        .collection('confirmedDrivers')
        .where('driverId', isEqualTo: driverId)
        .get();

    // Step 2: Iterate through matched documents and get tripId
    for (var doc in confirmedDriversSnapshot.docs) {
      String tripId = doc['tripId'];

      // Step 3: Query trips collection using tripId and fetch fare
      DocumentSnapshot tripSnapshot =
          await firestore.collection('trips').doc(tripId).get();

      if (tripSnapshot.exists) {
        double fare = double.parse(tripSnapshot['fare']);
        totalFare += fare; // Step 4: Add fare to totalFare
      }
    }

    // Step 5: Calculate the total money to pay (3% of total fare)
    double totalMoneyToPay = 0.03 * totalFare;

    // Step 6: Update or create a document in the 'balance' collection
    await firestore.collection('balance').doc(driverId).set(
        {
          'driverTotalBalance': totalFare * 0.97, // 97% of total fare
          'driverTotalMoneyToPay': totalMoneyToPay,
        },
        SetOptions(
            merge: true)); // Merge to update existing fields or create new ones

    // Step 7: Update the state (if this is part of a Flutter widget)
    if (mounted) {
      setState(() {
        driverTotalBalance = totalFare;
        driverTotalMoneyToPay = totalMoneyToPay;
      });
    }

    // Step 8: Print the results (optional)
    print('Total Fare: $totalFare');
    print('Total Money to Pay: $totalMoneyToPay');
    print('Total Paid Upto Now: $totalMoneyToPay');

    return totalFare;
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

  void _showDriverInfoDialog(BuildContext context) {
    // Create streams for both driver data and balance
    final driverStream = FirebaseFirestore.instance
        .collection('vehicleData')
        .doc(widget.driverId)
        .snapshots();

    final balanceStream = FirebaseFirestore.instance
        .collection('balance')
        .doc(widget.driverId)
        .snapshots();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: driverStream,
          builder: (context, driverSnapshot) {
            return StreamBuilder<DocumentSnapshot>(
              stream: balanceStream,
              builder: (context, balanceSnapshot) {
                // Loading state - replaced with subtle shimmer/skeleton loader
                if (driverSnapshot.connectionState == ConnectionState.waiting ||
                    balanceSnapshot.connectionState ==
                        ConnectionState.waiting) {
                  return _buildSkeletonLoader();
                }

                // Error state - improved error UI
                if (driverSnapshot.hasError || balanceSnapshot.hasError) {
                  return _buildErrorWidget(context);
                }

                // Data processing (unchanged)
                final driverData =
                    driverSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                final balanceData =
                    balanceSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                final totalEarnings =
                    (balanceData['driverTotalBalance'] ?? 0.0).toDouble();
                final totalToPay =
                    (balanceData['driverTotalMoneyToPay'] ?? 0.0).toDouble();
                final paidAmount = (balanceData['paid'] ?? 0.0)
                    .toDouble()
                    .clamp(0, double.infinity);
                final remainingToPay =
                    (totalToPay - paidAmount).clamp(0, double.infinity);

                return Container(
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        margin: EdgeInsets.only(bottom: 12),
                      ),

                      // Header
                      Text(
                        'चालक जानकारी',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Images in a compact grid
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.9,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildImageCard(
                              driverData['profilePictureUrl'] ?? ''),
                          _buildImageCard(
                              driverData['selfieWithCitizenshipUrl'] ?? ''),
                          _buildImageCard(
                              driverData['selfieWithLicenseUrl'] ?? ''),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Driver info card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverData['name'] ?? 'Unknown',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildDetailItem(Icons.location_on, 'ठेगाना',
                                driverData['address'] ?? 'Unknown'),
                            _buildDetailItem(Icons.directions_car, 'सवारी',
                                '${driverData['vehicleType'] ?? 'Unknown'} (${driverData['vehicleMode'] ?? 'Unknown'})'),
                            _buildDetailItem(
                                Icons.confirmation_number,
                                'नम्बर प्लेट',
                                driverData['numberPlate'] ?? 'Unknown'),
                            _buildDetailItem(Icons.phone, 'फोन नम्बर',
                                driverData['phone'] ?? 'Unknown'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Financial card
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildFinancialRow('Total Earnings', totalEarnings,
                                Colors.black87),
                            // SizedBox(height: 8),
                            // _buildFinancialRow(
                            //     'Pending Payment',
                            //     remainingToPay,
                            //     remainingToPay > 0
                            //         ? Colors.orange[700]!
                            //         : Colors.green[700]!),

                            SizedBox(height: 8),
                            _buildFinancialRow(
                                'Token Left',
                                remainingToPay + 100,
                                remainingToPay > 0
                                    ? Colors.redAccent
                                    : Colors.green[700]!),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.redAccent),
                              ),
                              child: Text('Close',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.blueGrey[800])),
                            ),
                          ),
                          if (remainingToPay > 0) SizedBox(width: 12),
                          if (remainingToPay > 0)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handlePayment(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                child: Text('Buy Token',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.white)),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true, // Allows the sheet to take up more screen space
    //   backgroundColor: Colors.transparent, // Makes the background transparent
    //   builder: (BuildContext context) {
    //     return StreamBuilder<DocumentSnapshot>(
    //       stream: driverStream,
    //       builder: (context, driverSnapshot) {
    //         return StreamBuilder<DocumentSnapshot>(
    //           stream: balanceStream,
    //           builder: (context, balanceSnapshot) {
    //             // Loading state
    //             if (driverSnapshot.connectionState == ConnectionState.waiting ||
    //                 balanceSnapshot.connectionState ==
    //                     ConnectionState.waiting) {
    //               return Center(child: SizedBox());
    //             }

    //             // Error state
    //             if (driverSnapshot.hasError || balanceSnapshot.hasError) {
    //               return AlertDialog(
    //                 title: Text('Error'),
    //                 content: Text('Could not load driver information'),
    //                 actions: [
    //                   TextButton(
    //                     child: Text('OK'),
    //                     onPressed: () => Navigator.pop(context),
    //                   ),
    //                 ],
    //               );
    //             }

    //             // Data available
    //             final driverData =
    //                 driverSnapshot.data?.data() as Map<String, dynamic>? ?? {};
    //             final balanceData =
    //                 balanceSnapshot.data?.data() as Map<String, dynamic>? ?? {};

    //             // Calculate values with validation
    //             final totalEarnings =
    //                 (balanceData['driverTotalBalance'] ?? 0.0).toDouble();
    //             final totalToPay =
    //                 (balanceData['driverTotalMoneyToPay'] ?? 0.0).toDouble();
    //             final paidAmount = (balanceData['paid'] ?? 0.0)
    //                 .toDouble()
    //                 .clamp(0, double.infinity);
    //             final remainingToPay =
    //                 (totalToPay - paidAmount).clamp(0, double.infinity);

    //             return Container(
    //               margin: EdgeInsets.only(top: 20),
    //               decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(20),
    //                   topRight: Radius.circular(20),
    //                 ),
    //               ),
    //               padding: EdgeInsets.all(20),
    //               child: SingleChildScrollView(
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     Text(
    //                       'चालक जानकारी',
    //                       style: GoogleFonts.hind(
    //                         fontSize: 24,
    //                         fontWeight: FontWeight.w600,
    //                       ),
    //                     ),
    //                     SizedBox(height: 20),

    //                     // Image row
    //                     SingleChildScrollView(
    //                       scrollDirection: Axis.horizontal,
    //                       child: Row(
    //                         children: [
    //                           _buildImageCard(context,
    //                               driverData['profilePictureUrl'] ?? ''),
    //                           SizedBox(width: 10),
    //                           _buildImageCard(context,
    //                               driverData['selfieWithCitizenshipUrl'] ?? ''),
    //                           SizedBox(width: 10),
    //                           _buildImageCard(context,
    //                               driverData['selfieWithLicenseUrl'] ?? ''),
    //                         ],
    //                       ),
    //                     ),
    //                     SizedBox(height: 20),

    //                     // Driver name
    //                     Row(
    //                       children: [
    //                         Text(
    //                           driverData['name'] ?? 'Unknown',
    //                           style: GoogleFonts.outfit(
    //                             fontSize: 20,
    //                             fontWeight: FontWeight.w700,
    //                             color: Colors.redAccent,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     SizedBox(height: 10),

    //                     // Details section
    //                     SingleChildScrollView(
    //                       child: Column(
    //                         children: [
    //                           _buildDetailRow(
    //                               'ठेगाना', driverData['address'] ?? 'Unknown'),
    //                           _buildDetailRow('नम्बर प्लेट',
    //                               driverData['numberPlate'] ?? 'Unknown'),
    //                           _buildDetailRow('सवारी',
    //                               driverData['vehicleType'] ?? 'Unknown'),
    //                           _buildDetailRow('सवारी प्रकार',
    //                               driverData['vehicleMode'] ?? 'Unknown'),
    //                           _buildDetailRow('फोन नम्बर',
    //                               driverData['phone'] ?? 'Unknown'),

    //                           Divider(color: Colors.green, thickness: 0.3),

    //                           // Financial info
    //                           _buildDetailRow('कमाएको कुल रकम:',
    //                               totalEarnings.toStringAsFixed(0)),
    //                           _buildDetailRow('तिर्नु पर्ने रकम:',
    //                               remainingToPay.toStringAsFixed(0)),
    //                         ],
    //                       ),
    //                     ),
    //                     SizedBox(height: 20),

    //                     // Buttons
    //                     Row(
    //                       mainAxisAlignment: remainingToPay > 0
    //                           ? MainAxisAlignment.spaceBetween
    //                           : MainAxisAlignment.center,
    //                       children: [
    //                         ElevatedButton(
    //                           onPressed: () => Navigator.pop(context),
    //                           style: ElevatedButton.styleFrom(
    //                             backgroundColor: Colors.redAccent,
    //                             padding: EdgeInsets.symmetric(
    //                                 horizontal: 30, vertical: 12),
    //                           ),
    //                           child: Text(
    //                             'Close',
    //                             style: TextStyle(color: Colors.white),
    //                           ),
    //                         ),
    //                         if (remainingToPay > 0)
    //                           ElevatedButton(
    //                             onPressed: () => _handlePayment(context),
    //                             style: ElevatedButton.styleFrom(
    //                                 backgroundColor: Colors.green,
    //                                 padding: EdgeInsets.symmetric(
    //                                     horizontal: 20, vertical: 12)),
    //                             child: Text(
    //                               'Pay Now',
    //                               style: TextStyle(color: Colors.white),
    //                             ),
    //                           ),
    //                       ],
    //                     ),
    //                     SizedBox(
    //                         height: MediaQuery.of(context).viewInsets.bottom),
    //                   ],
    //                 ),
    //               ),
    //             );
    //           },
    //         );
    //       },
    //     );
    //   },
    // );
  }

// New payment handler
  void _handlePayment(BuildContext context) async {
    // Implement your payment logic here
    // This will automatically trigger a UI update through the streams
    print('Payment initiated');
  }

// // Helper function to build image cards with full-screen on tap
//   Widget _buildImageCard(BuildContext context, String imageUrl) {
//     return GestureDetector(
//       onTap: () {
//         // Show full-screen image on tap
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return Dialog(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               child: Stack(
//                 children: [
//                   // Full-screen image
//                   InteractiveViewer(
//                     panEnabled: true, // Allow panning
//                     minScale: 0.5, // Minimum zoom level
//                     maxScale: 3, // Maximum zoom level
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Center(
//                           child: Icon(Icons.error, size: 40, color: Colors.red),
//                         );
//                       },
//                     ),
//                   ),
//                   // Close button for full-screen image
//                   Positioned(
//                     top: 10,
//                     right: 10,
//                     child: IconButton(
//                       icon: Icon(Icons.close, color: Colors.white, size: 30),
//                       onPressed: () {
//                         Navigator.of(context).pop(); // Close full-screen image
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(15),
//           child: Image.network(
//             imageUrl,
//             width: 100,
//             height: 100,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.grey[200],
//                 child: Icon(Icons.person, size: 40, color: Colors.grey[500]),
//               );
//             },
//           ),
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
//             style: GoogleFonts.hind(
//               fontSize: 18,
//               fontWeight: FontWeight.w600, // Medium weight
//               color: Colors.black54,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: GoogleFonts.comicNeue(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400, // Regular weight
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// Helper Widgets
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey[400]),
          SizedBox(width: 8),
          Text('$label: ',
              style: GoogleFonts.hind(
                fontWeight: FontWeight.w500,
              )),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.blueGrey[600])),
        Text(
          'Rs. ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight:
                label == 'Token Left' ? FontWeight.w800 : FontWeight.w400,
            fontSize: label == 'Token Left' ? 22 : 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.grey[200],
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Center(child: Icon(Icons.image, color: Colors.grey[400])),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          SizedBox(height: 16),
          Text('Failed to load data', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      height: 600,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Container(width: 100, height: 20, color: Colors.white),
            SizedBox(height: 20),
            Row(children: [
              Expanded(child: Container(height: 100, color: Colors.white)),
              SizedBox(width: 10),
              Expanded(child: Container(height: 100, color: Colors.white)),
              SizedBox(width: 10),
              Expanded(child: Container(height: 100, color: Colors.white)),
            ]),
            SizedBox(height: 20),
            Container(width: double.infinity, height: 150, color: Colors.white),
            SizedBox(height: 20),
            Container(width: double.infinity, height: 130, color: Colors.white),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    color: Colors.white),
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
