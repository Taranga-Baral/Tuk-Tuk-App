// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class HistoryPage extends StatefulWidget {
//   final String userId;

//   const HistoryPage({super.key, required this.userId});

//   @override
//   _HistoryPageState createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   Future<List<Map<String, dynamic>>> _fetchTrips() async {
//     try {
//       // Fetch trips for the given userId
//       QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
//           .collection('successfulTrips')
//           .where('userId', isEqualTo: widget.userId)
//           .get();

//       // Fetch trip details and vehicle data for each trip
//       List<Map<String, dynamic>> tripsData =
//           await Future.wait(tripsSnapshot.docs.map((doc) async {
//         final tripData = doc.data() as Map<String, dynamic>;

//         // Fetch trip details
//         final tripDetailsSnapshot = await FirebaseFirestore.instance
//             .collection('trips')
//             .doc(tripData['tripId'])
//             .get();
//         final tripDetails = tripDetailsSnapshot.data() as Map<String, dynamic>;

//         // Fetch vehicle data using email as the document ID
//         final vehicleDoc = await FirebaseFirestore.instance
//             .collection('vehicleData')
//             .doc(tripData['driverId']) // Assuming driverId is the email here
//             .get();
//         final vehicleData = vehicleDoc.exists
//             ? vehicleDoc.data() as Map<String, dynamic>
//             : {'name': 'Unknown Driver'}; // Default name if no data

//         return {
//           'tripId': doc.id,
//           'pickupLocation': tripDetails['pickupLocation'] ?? 'N/A',
//           'deliveryLocation': tripDetails['deliveryLocation'] ?? 'N/A',
//           'distance': tripDetails['distance'] ?? 'N/A',
//           'fare': tripDetails['fare'] ?? 'N/A',
//           'vehicleType': tripDetails['vehicleType'] ?? 'N/A',
//           'no_of_person': tripDetails['no_of_person'] ?? 'N/A',
//           'vehicle_mode': tripDetails['vehicle_mode'] ?? 'N/A',
//           'driverName': vehicleData['name'] ?? 'Unknown Driver', // Driver name
//           'profilePictureUrl':
//               vehicleData['profilePictureUrl'] ?? '', // Driver name
//         };
//       }));

//       return tripsData;
//     } catch (e) {
//       print('Error fetching trips: $e');
//       return [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         backgroundColor: Colors.blueAccent,
//         title: Text(
//           'Trip History',
//           style: GoogleFonts.outfit(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchTrips(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return const Center(child: Text('Error fetching trips.'));
//           }

//           if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//             List<Map<String, dynamic>> trips = snapshot.data!;

//             return ListView.builder(
//               itemCount: trips.length,
//               itemBuilder: (context, index) {
//                 var trip = trips[index];

//                 return Card(
//                   elevation: 2,
//                   // color: Colors.white,
//                   margin: const EdgeInsets.all(8),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${index + 1}. ${trip['driverName']}',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on,
//                               color: Colors.green,
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Expanded(child: Text('${trip['pickupLocation']}')),
//                           ],
//                         ),
//                         SizedBox(height: 5),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on,
//                               color: Colors.red,
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Expanded(
//                                 child: Text('${trip['deliveryLocation']}')),
//                           ],
//                         ),
//                         SizedBox(height: 5),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.info,
//                               color: Colors.indigo.shade400,
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                                 child: Text(
//                                     '${double.tryParse(trip['distance'])?.toStringAsFixed(2)} कि.मि, ${trip['vehicleType']}, ${trip['vehicle_mode']}, ${trip['no_of_person']}, ${trip['fare']} रुपैय')),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );

//                 // return Container(
//                 //   color: Colors.grey,
//                 //   child: Column(
//                 //     children: [
//                 //       Container(
//                 //         color: Colors.red,
//                 //         child: ,
//                 //       ),
//                 //     ],
//                 //   ),
//                 // );
//               },
//             );
//           }

//           return Center(
//             child: Image(
//               image: AssetImage('assets/no_data_found.gif'),
//               height: MediaQuery.of(context).size.height * 0.5,
//               width: MediaQuery.of(context).size.width * 0.5,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';

// class HistoryPage extends StatefulWidget {
//   final String userId;

//   const HistoryPage({super.key, required this.userId});

//   @override
//   _HistoryPageState createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   late Future<List<Map<String, dynamic>>> _tripsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _tripsFuture = _fetchTrips();
//   }

//   Future<List<Map<String, dynamic>>> _fetchTrips() async {
//     try {
//       QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
//           .collection('successfulTrips')
//           .where('userId', isEqualTo: widget.userId)
//           .get();

//       List<Map<String, dynamic>> tripsData =
//           await Future.wait(tripsSnapshot.docs.map((doc) async {
//         final tripData = doc.data() as Map<String, dynamic>;

//         final tripDetailsSnapshot = await FirebaseFirestore.instance
//             .collection('trips')
//             .doc(tripData['tripId'])
//             .get();
//         final tripDetails = tripDetailsSnapshot.data() as Map<String, dynamic>;

//         final vehicleDoc = await FirebaseFirestore.instance
//             .collection('vehicleData')
//             .doc(tripData['driverId'])
//             .get();
//         final vehicleData = vehicleDoc.exists
//             ? vehicleDoc.data() as Map<String, dynamic>
//             : {'name': 'Unknown Driver'};

//         return {
//           'tripId': doc.id,
//           'pickupLocation': tripDetails['pickupLocation'] ?? 'N/A',
//           'deliveryLocation': tripDetails['deliveryLocation'] ?? 'N/A',
//           'distance': tripDetails['distance'] ?? 'N/A',
//           'fare': tripDetails['fare'] ?? 'N/A',
//           'vehicleType': tripDetails['vehicleType'] ?? 'N/A',
//           'no_of_person': tripDetails['no_of_person'] ?? 'N/A',
//           'vehicle_mode': tripDetails['vehicle_mode'] ?? 'N/A',
//           'driverName': vehicleData['name'] ?? 'Unknown Driver',
//           'profilePictureUrl': vehicleData['profilePictureUrl'] ?? '',
//         };
//       }));

//       return tripsData;
//     } catch (e) {
//       print('Error fetching trips: $e');
//       throw Exception('Failed to load trips');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         backgroundColor: Colors.blueAccent,
//         title: Text(
//           'Trip History',
//           style: GoogleFonts.outfit(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _tripsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return _buildShimmerLoading();
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Error: ${snapshot.error}',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return _buildNoDataFound();
//           }

//           return _buildTripList(snapshot.data!);
//         },
//       ),
//     );
//   }

//   Widget _buildShimmerLoading() {
//     return ListView.builder(
//       itemCount: 5, // Number of shimmer placeholders
//       itemBuilder: (context, index) {
//         return Card(
//           margin: const EdgeInsets.all(8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Shimmer.fromColors(
//             baseColor: Colors.grey[300]!,
//             highlightColor: Colors.grey[100]!,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 150,
//                     height: 20,
//                     color: Colors.white,
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Container(
//                         width: 24,
//                         height: 24,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Container(
//                           height: 20,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Row(
//                     children: [
//                       Container(
//                         width: 24,
//                         height: 24,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Container(
//                           height: 20,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildNoDataFound() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset(
//             'assets/no_data_found.gif',
//             height: MediaQuery.of(context).size.height * 0.5,
//             width: MediaQuery.of(context).size.width * 0.5,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No trips found!',
//             style: GoogleFonts.outfit(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTripList(List<Map<String, dynamic>> trips) {
//     return ListView.builder(
//       itemCount: trips.length,
//       itemBuilder: (context, index) {
//         var trip = trips[index];

//         return Card(
//           elevation: 2,
//           margin: const EdgeInsets.all(8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${index + 1}. ${trip['driverName']}',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 _buildTripDetailRow(
//                   icon: Icons.location_on,
//                   iconColor: Colors.green,
//                   text: trip['pickupLocation'],
//                 ),
//                 const SizedBox(height: 5),
//                 _buildTripDetailRow(
//                   icon: Icons.location_on,
//                   iconColor: Colors.red,
//                   text: trip['deliveryLocation'],
//                 ),
//                 const SizedBox(height: 5),
//                 _buildTripDetailRow(
//                   icon: Icons.info,
//                   iconColor: Colors.indigo.shade400,
//                   text:
//                       '${double.tryParse(trip['distance'])?.toStringAsFixed(2)} कि.मि, ${trip['vehicleType']}, ${trip['vehicle_mode']}, ${trip['no_of_person']}, ${trip['fare']} रुपैय',
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTripDetailRow({
//     required IconData icon,
//     required Color iconColor,
//     required String text,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, color: iconColor),
//         const SizedBox(width: 10),
//         Expanded(child: Text(text)),
//       ],
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class HistoryPage extends StatefulWidget {
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = _fetchTrips();
  }

  Future<List<Map<String, dynamic>>> _fetchTrips() async {
    try {
      QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection('successfulTrips')
          .where('userId', isEqualTo: widget.userId)
          .get();

      List<Map<String, dynamic>> tripsData =
          await Future.wait(tripsSnapshot.docs.map((doc) async {
        final tripData = doc.data() as Map<String, dynamic>;

        final tripDetailsSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(tripData['tripId'])
            .get();
        final tripDetails = tripDetailsSnapshot.data() as Map<String, dynamic>;

        final vehicleDoc = await FirebaseFirestore.instance
            .collection('vehicleData')
            .doc(tripData['driverId'])
            .get();
        final vehicleData = vehicleDoc.exists
            ? vehicleDoc.data() as Map<String, dynamic>
            : {'name': 'Unknown Driver'};

        return {
          'tripId': doc.id,
          'pickupLocation': tripDetails['pickupLocation'] ?? 'N/A',
          'deliveryLocation': tripDetails['deliveryLocation'] ?? 'N/A',
          'distance': tripDetails['distance'] ?? 'N/A',
          'fare': tripDetails['fare'] ?? 'N/A',
          'vehicleType': tripDetails['vehicleType'] ?? 'N/A',
          'no_of_person': tripDetails['no_of_person'] ?? 'N/A',
          'vehicle_mode': tripDetails['vehicle_mode'] ?? 'N/A',
          'driverName': vehicleData['name'] ?? 'Unknown Driver',
          'profilePictureUrl': vehicleData['profilePictureUrl'] ?? '',
        };
      }));

      return tripsData;
    } catch (e) {
      print('Error fetching trips: $e');
      throw Exception('Failed to load trips');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _tripsFuture = _fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Trip History',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _tripsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildNoDataFound();
            }

            return _buildTripList(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5, // Number of shimmer placeholders
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
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 20,
                          color: Colors.white,
                        ),
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong.',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/no_data_found.gif',
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.5,
          ),
          const SizedBox(height: 16),
          Text(
            'No trips found!',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(List<Map<String, dynamic>> trips) {
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        var trip = trips[index];

        return Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: trip['profilePictureUrl'] != null &&
                                  trip['profilePictureUrl'].isNotEmpty
                              ? NetworkImage(trip['profilePictureUrl'])
                              : null,
                          child: trip['profilePictureUrl'] == null ||
                                  trip['profilePictureUrl'].isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${trip['driverName']}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTripDetailRow(
                      icon: Icons.location_on,
                      iconColor: Colors.green,
                      text: trip['pickupLocation'],
                    ),
                    const SizedBox(height: 8),
                    _buildTripDetailRow(
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      text: trip['deliveryLocation'],
                    ),
                    const SizedBox(height: 8),
                    _buildTripDetailRow(
                      icon: Icons.info,
                      iconColor: Colors.amber[700]!,
                      text:
                          '${double.tryParse(trip['distance'])?.toStringAsFixed(2)} कि.मि, ${trip['vehicleType']}, ${trip['vehicle_mode']}, ${trip['no_of_person']}, ${trip['fare']} रुपैय',
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
                child: Container(
                  color: Colors.blue,
                  height: 30,
                  width: 50,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildTripDetailRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
