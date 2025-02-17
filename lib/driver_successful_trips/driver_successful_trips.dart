// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DriverSuccessfulTrips extends StatefulWidget {
//   final String driverId;

//   const DriverSuccessfulTrips({super.key, required this.driverId});

//   @override
//   _DriverSuccessfulTripsState createState() => _DriverSuccessfulTripsState();
// }

// class _DriverSuccessfulTripsState extends State<DriverSuccessfulTrips> {
//   List<Map<String, dynamic>> successfulTripsData = [];
//   bool isDataLoaded = false;
//   DocumentSnapshot? lastFetchedDocument;
//   bool isLoadingMore = false;
//   final int limit = 10; // Number of records to load at a time

//   @override
//   void initState() {
//     super.initState();
//     _loadSuccessfulTrips(); // Load the initial data
//   }

//   Future<void> _loadSuccessfulTrips() async {
//     if (isLoadingMore) return; // Prevent loading if already loading
//     setState(() {
//       isLoadingMore = true; // Set loading state
//     });

//     try {
//       Query query = FirebaseFirestore.instance
//           .collection('successfulTrips')
//           .where('driverId', isEqualTo: widget.driverId)
//           .orderBy('timestamp',
//               descending:
//                   true) // Order by createdAt in descending order for latest data
//           .limit(limit);

//       // If lastFetchedDocument is set, start after the last fetched document
//       if (lastFetchedDocument != null) {
//         query =
//             query.startAfterDocument(lastFetchedDocument!); // Use null check
//       }

//       final successfulTripsSnapshot = await query.get();

//       // If no more documents are fetched, return early
//       if (successfulTripsSnapshot.docs.isEmpty) {
//         setState(() {
//           isLoadingMore = false; // Reset loading state
//         });
//         return;
//       }

//       // Set the last fetched document to the last document in the snapshot
//       lastFetchedDocument = successfulTripsSnapshot.docs.last;

//       // Fetch user and trip details for each successful trip
//       final tripsData =
//           await Future.wait(successfulTripsSnapshot.docs.map((doc) async {
//         final data = doc.data() as Map<String, dynamic>;

//         // Use a null check to safely access userId
//         final userSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(data['userId']
//                 as String) // Ensure userId is treated as a String
//             .get();
//         final tripSnapshot = await FirebaseFirestore.instance
//             .collection('trips')
//             .doc(data['tripId']
//                 as String) // Ensure tripId is treated as a String
//             .get();

//         return {
//           'successfulTrip': data,
//           'user': userSnapshot.data() ?? {},
//           'trip': tripSnapshot.data() ?? {},
//         };
//       }));

//       setState(() {
//         // Append new data to the top of the list
//         successfulTripsData.insertAll(
//             0, tripsData); // Insert new data at the start
//         isDataLoaded = true; // Mark data as loaded
//         isLoadingMore = false; // Reset loading state
//       });
//     } catch (e) {
//       print('Error loading data: $e');
//       setState(() {
//         isLoadingMore = false; // Reset loading state
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
//         title: 'Successful Trips',
//         driverId: widget.driverId,
//       ),
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (ScrollNotification scrollInfo) {
//           if (!isLoadingMore &&
//               scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
//             _loadSuccessfulTrips(); // Load more data when scrolled to the bottom
//           }
//           return false; // Return false to allow other scroll notifications to occur
//         },
//         child: isDataLoaded
//             ? ListView.builder(
//                 itemCount: successfulTripsData.length,
//                 itemBuilder: (context, index) {
//                   final data = successfulTripsData[index];
//                   final tripData = data['successfulTrip'];
//                   final userData = data['user'];
//                   final tripDetails = data['trip'];

//                   return Card(
//                     margin: EdgeInsets.all(10),
//                     child: ListTile(
//                       title: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '${userData['username'] ?? 'Unknown'}',
//                             style:
//                                 GoogleFonts.outfit(fontWeight: FontWeight.w600),
//                           ),
//                           Text(
//                             '... ${index + 1}',
//                             style: TextStyle(
//                                 color: Colors.black87,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 18),
//                           ),
//                         ],
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 5),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.location_on,
//                                 color: Colors.green,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                   child: Text(
//                                 '${tripDetails['pickupLocation'] ?? 'Unknown'}',
//                                 style: GoogleFonts.comicNeue(),
//                               )),
//                             ],
//                           ),
//                           SizedBox(height: 5),
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6.0),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.withOpacity(0.2),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   Icons.location_on,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                   child: Text(
//                                 '${tripDetails['deliveryLocation'] ?? 'Unknown'}',
//                                 style: GoogleFonts.comicNeue(),
//                               )),
//                             ],
//                           ),
//                           SizedBox(height: 5),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.linear_scale_rounded,
//                                 color: Colors.teal.shade400,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                   child: Text(
//                                 '${double.tryParse(tripDetails['distance'] ?? '0')?.toStringAsFixed(2)} km',
//                                 style: GoogleFonts.comicNeue(),
//                               )),
//                             ],
//                           ),
//                           SizedBox(height: 5),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.money,
//                                 color: Colors.blueAccent.shade200,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                   child: Text(
//                                 'NPR ${tripDetails['fare'] ?? '0'}',
//                                 style: GoogleFonts.comicNeue(),
//                               )),
//                             ],
//                           ),
//                           SizedBox(height: 5),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.call_end,
//                                 color: Colors.amber,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                   child: Text(
//                                 '${userData['phone_number'] ?? 'Unknown'}',
//                                 style: GoogleFonts.comicNeue(),
//                               )),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 5,
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               )
//             : Center(
//                 child: Image(
//                 image: AssetImage('assets/no_data_found.gif'),
//                 height: MediaQuery.of(context).size.height * 0.5,
//                 width: MediaQuery.of(context).size.width * 0.5,
//               )),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

class DriverSuccessfulTrips extends StatefulWidget {
  final String driverId;

  const DriverSuccessfulTrips({super.key, required this.driverId});

  @override
  _DriverSuccessfulTripsState createState() => _DriverSuccessfulTripsState();
}

class _DriverSuccessfulTripsState extends State<DriverSuccessfulTrips> {
  List<Map<String, dynamic>> successfulTripsData = [];
  bool isDataLoaded = false;
  DocumentSnapshot? lastFetchedDocument;
  bool isLoadingMore = false;
  final int limit = 10; // Number of records to load at a time

  @override
  void initState() {
    super.initState();
    _loadSuccessfulTrips(); // Load the initial data
  }

  Future<void> _refresh() async {
    setState(() {
      _loadSuccessfulTrips();
    });
  }

  Future<void> _loadSuccessfulTrips() async {
    if (isLoadingMore) return; // Prevent loading if already loading
    setState(() {
      isLoadingMore = true; // Set loading state
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('successfulTrips')
          .where('driverId', isEqualTo: widget.driverId)
          .orderBy('timestamp', descending: true) // Order by timestamp
          .limit(limit);

      // If lastFetchedDocument is set, start after the last fetched document
      if (lastFetchedDocument != null) {
        query = query.startAfterDocument(lastFetchedDocument!);
      }

      final successfulTripsSnapshot = await query.get();

      // If no more documents are fetched, return early
      if (successfulTripsSnapshot.docs.isEmpty) {
        setState(() {
          isLoadingMore = false; // Reset loading state
        });
        return;
      }

      // Set the last fetched document to the last document in the snapshot
      lastFetchedDocument = successfulTripsSnapshot.docs.last;

      // Fetch user and trip details for each successful trip
      final tripsData =
          await Future.wait(successfulTripsSnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;

        // Fetch user details
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'] as String)
            .get();

        // Fetch trip details
        final tripSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(data['tripId'] as String)
            .get();

        return {
          'successfulTrip': data,
          'user': userSnapshot.data() ?? {},
          'trip': tripSnapshot.data() ?? {},
        };
      }));

      setState(() {
        // Append new data to the top of the list
        successfulTripsData.insertAll(0, tripsData);
        isDataLoaded = true; // Mark data as loaded
        isLoadingMore = false; // Reset loading state
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoadingMore = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarColor: Colors.redAccent,
        appBarIcons: const [
          Icons.history,
          Icons.info_outline,
        ],
        title: 'My Successful Trips',
        driverId: widget.driverId,
      ),

      // appBar: AppBar(
      //   centerTitle: true,
      //   backgroundColor: Colors.redAccent,
      //   title: Text(
      //     'Successful Trips',
      //     style: GoogleFonts.outfit(
      //       color: Colors.white,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: Icon(Icons.history, color: Colors.white),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.info_outline, color: Colors.white),
      //       onPressed: () {
      //         // Add info action
      //       },
      //     ),
      //   ],
      // ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoadingMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _buildShimmerLoading();
            _loadSuccessfulTrips(); // Load more data when scrolled to the bottom
          }
          return false; // Return false to allow other scroll notifications to occur
        },
        child: isDataLoaded
            ? RefreshIndicator(
                onRefresh: _refresh,
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: successfulTripsData.length,
                    itemBuilder: (context, index) {
                      final data = successfulTripsData[index];
                      final tripData = data['successfulTrip'];
                      final userData = data['user'];
                      final tripDetails = data['trip'];

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Card(
                              margin: EdgeInsets.all(10),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${userData['username'] ?? 'Unknown'}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Trip #${successfulTripsData.length - index}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    _buildDetailRow(
                                      icon: Icons.location_on,
                                      iconColor: Colors.green,
                                      text:
                                          'Pickup: ${tripDetails['pickupLocation'] ?? 'Unknown'}',
                                    ),
                                    _buildDetailRow(
                                      icon: Icons.location_on,
                                      iconColor: Colors.red,
                                      text:
                                          'Delivery: ${tripDetails['deliveryLocation'] ?? 'Unknown'}',
                                    ),
                                    _buildDetailRow(
                                      icon: Icons.linear_scale_rounded,
                                      iconColor: Colors.teal,
                                      text:
                                          'Distance: ${double.tryParse(tripDetails['distance'] ?? '0')?.toStringAsFixed(2)} km',
                                    ),
                                    _buildDetailRow(
                                      icon: Icons.money,
                                      iconColor: Colors.blueAccent,
                                      text:
                                          'Fare: NPR ${tripDetails['fare'] ?? '0'}',
                                    ),
                                    // _buildDetailRow(
                                    //   icon: Icons.call_end,
                                    //   iconColor: Colors.amber,
                                    //   text:
                                    //       'Contact: ${userData['phone_number'] ?? 'Unknown'}',
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : _buildShimmerLoading(),
        // : Center(
        //     child: Image.asset(
        //       'assets/no_data_found.gif',
        //       height: MediaQuery.of(context).size.height * 0.5,
        //       width: MediaQuery.of(context).size.width * 0.5,
        //     ),
        //   ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildShimmerLoading() {
  return ListView.builder(
    itemCount: 8, // Number of shimmer placeholders
    itemBuilder: (context, index) {
      return Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title in the middle and Card in the top right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title in the top middle
                    Expanded(
                      child: Container(
                        height: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 30),
                    // Card in the top right
                    Container(
                      width: 30,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Four descriptions below the title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
