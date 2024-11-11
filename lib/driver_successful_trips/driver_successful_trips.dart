// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
// import 'package:flutter/material.dart';

// class DriverSuccessfulTrips extends StatefulWidget {
//   final String driverId;

//   const DriverSuccessfulTrips({super.key, required this.driverId});

//   @override
//   _DriverSuccessfulTripsState createState() => _DriverSuccessfulTripsState();
// }

// class _DriverSuccessfulTripsState extends State<DriverSuccessfulTrips> {
//   List<Map<String, dynamic>> successfulTripsData = [];
//   bool isDataLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSuccessfulTrips();
//   }

//   Future<void> _loadSuccessfulTrips() async {
//     try {
//       // Fetch successful trips for the given driverId
//       final successfulTripsSnapshot = await FirebaseFirestore.instance
//           .collection('successfulTrips')
//           .where('driverId', isEqualTo: widget.driverId)
//           .get();

//       // Fetch user and trip details for each successful trip
//       final tripsData = await Future.wait(successfulTripsSnapshot.docs.map((doc) async {
//         final data = doc.data();
//         final userSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(data['userId'])
//             .get();
//         final tripSnapshot = await FirebaseFirestore.instance
//             .collection('trips')
//             .doc(data['tripId'])
//             .get();

//         return {
//           'successfulTrip': data,
//           'user': userSnapshot.data() ?? {}, // Default to empty map if user data is not found
//           'trip': tripSnapshot.data() ?? {}, // Default to empty map if trip data is not found
//         };
//       }));

//       setState(() {
//         successfulTripsData = tripsData;
//         isDataLoaded = true;
//       });
//     } catch (e) {
//       print('Error loading data: $e');
//       setState(() {
//         isDataLoaded = true; // Ensure that UI reflects data loading error
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
//         title: 'Accepted Requests',
//         driverId: widget.driverId, // Pass the driverId
//       ),
//       body: isDataLoaded
//           ? ListView.builder(
//               itemCount: successfulTripsData.length,
//               itemBuilder: (context, index) {
//                 final data = successfulTripsData[index];
//                 final tripData = data['successfulTrip'];
//                 final userData = data['user'];
//                 final tripDetails = data['trip'];

//                 return Card(
//                   margin: EdgeInsets.all(10),
//                   child: ListTile(
//                     title:  Text('𝗨𝘀𝗲𝗿𝗻𝗮𝗺𝗲: ${userData['username'] ?? 'Unknown'}'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Phone: ${userData['phone_number'] ?? 'Unknown'}'),
//                         Text('Pickup Location: ${tripDetails['pickupLocation'] ?? 'Unknown'}'),
//                         Text('Deliver Location: ${tripDetails['deliveryLocation'] ?? 'Unknown'}'),
//                         Text('Fare: ${tripDetails['fare'] ?? '0'}'),
//                         Text('Distance: ${tripDetails['distance'] ?? '0'}'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/driver_appbar_exprollable/driver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> _loadSuccessfulTrips() async {
    if (isLoadingMore) return; // Prevent loading if already loading
    setState(() {
      isLoadingMore = true; // Set loading state
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('successfulTrips')
          .where('driverId', isEqualTo: widget.driverId)
          .orderBy('timestamp',
              descending:
                  true) // Order by createdAt in descending order for latest data
          .limit(limit);

      // If lastFetchedDocument is set, start after the last fetched document
      if (lastFetchedDocument != null) {
        query =
            query.startAfterDocument(lastFetchedDocument!); // Use null check
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

        // Use a null check to safely access userId
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId']
                as String) // Ensure userId is treated as a String
            .get();
        final tripSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(data['tripId']
                as String) // Ensure tripId is treated as a String
            .get();

        return {
          'successfulTrip': data,
          'user': userSnapshot.data() ?? {},
          'trip': tripSnapshot.data() ?? {},
        };
      }));

      setState(() {
        // Append new data to the top of the list
        successfulTripsData.insertAll(
            0, tripsData); // Insert new data at the start
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
        appBarColor: Colors.teal,
        appBarIcons: const [
          Icons.arrow_back,
          Icons.info_outline,
        ],
        title: 'Successful Trips',
        driverId: widget.driverId,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoadingMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadSuccessfulTrips(); // Load more data when scrolled to the bottom
          }
          return false; // Return false to allow other scroll notifications to occur
        },
        child: isDataLoaded
            ? ListView.builder(
                itemCount: successfulTripsData.length,
                itemBuilder: (context, index) {
                  final data = successfulTripsData[index];
                  final tripData = data['successfulTrip'];
                  final userData = data['user'];
                  final tripDetails = data['trip'];

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${userData['username'] ?? 'Unknown'}',
                            style:
                                GoogleFonts.outfit(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '... ${index + 1}',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Text(
                                '${tripDetails['pickupLocation'] ?? 'Unknown'}',
                                style: GoogleFonts.comicNeue(),
                              )),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Text(
                                '${tripDetails['deliveryLocation'] ?? 'Unknown'}',
                                style: GoogleFonts.comicNeue(),
                              )),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.linear_scale_rounded,
                                color: Colors.teal.shade400,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Text(
                                '${double.tryParse(tripDetails['distance'] ?? '0')?.toStringAsFixed(2)} km',
                                style: GoogleFonts.comicNeue(),
                              )),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.money,
                                color: Colors.blueAccent.shade200,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Text(
                                'NPR ${tripDetails['fare'] ?? '0'}',
                                style: GoogleFonts.comicNeue(),
                              )),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.call_end,
                                color: Colors.amber,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Text(
                                '${userData['phone_number'] ?? 'Unknown'}',
                                style: GoogleFonts.comicNeue(),
                              )),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
