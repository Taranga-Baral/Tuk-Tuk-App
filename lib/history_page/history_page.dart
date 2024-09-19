
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

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

//       // Fetch user details and vehicle data for each trip
//       List<Map<String, dynamic>> tripsData = await Future.wait(tripsSnapshot.docs.map((doc) async {
//         final tripData = doc.data() as Map<String, dynamic>;
//         final userSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(tripData['userId'])
//             .get();
//         final vehicleSnapshot = tripData['driverId'] != null
//             ? await FirebaseFirestore.instance
//                 .collection('vehicleData')
//                 .where('driverId', isEqualTo: tripData['driverId'])
//                 .get()
//             : null;
        
//         final vehicleData = vehicleSnapshot?.docs.isNotEmpty == true
//             ? vehicleSnapshot!.docs.first.data()
//             : {};
        
//         final username = userSnapshot.data()?['username'] ?? 'Unknown';
//         final driverPhone = vehicleData['phone'] ?? 'Unknown';

//         return {
//           'tripId': doc.id,
//           'timestamp': tripData['timestamp'],
//           'userId': tripData['userId'],
//           'driverId': tripData['driverId'],
//           'username': username, // Include username here
//           'driverPhone': driverPhone, // Include driver phone number here
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
//         backgroundColor: Colors.amber.shade300,
//         title: const Text('Trips'),
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
//                   elevation: 5,
//                   margin: const EdgeInsets.all(8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Trip ID: ${trip['tripId']}'),
//                         Text('User ID: ${trip['userId']}'),
//                         Text('Username: ${trip['username']}'), // Display username
//                         Text('Driver ID: ${trip['driverId'] ?? 'N/A'}'),
//                         Text('Driver Phone: ${trip['driverPhone'] ?? 'N/A'}'), // Display driver phone number
//                         Text('Timestamp: ${trip['timestamp']?.toDate() ?? 'N/A'}'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }

//           return const Center(child: Text('No trips found.'));
//         },
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
Future<List<Map<String, dynamic>>> _fetchTrips() async {
  try {
    // Fetch trips for the given userId
    QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
        .collection('successfulTrips')
        .where('userId', isEqualTo: widget.userId)
        .get();

    // Fetch trip details and vehicle data for each trip
    List<Map<String, dynamic>> tripsData = await Future.wait(tripsSnapshot.docs.map((doc) async {
      final tripData = doc.data() as Map<String, dynamic>;

      // Fetch trip details
      final tripDetailsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripData['tripId'])
          .get();
      final tripDetails = tripDetailsSnapshot.data() as Map<String, dynamic>;

      // Fetch vehicle data using email as the document ID
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicleData')
          .doc(tripData['driverId'])  // Assuming driverId is the email here
          .get();
      final vehicleData = vehicleDoc.exists
          ? vehicleDoc.data() as Map<String, dynamic>
          : {'name': 'Unknown Driver'};  // Default name if no data

      return {
        'tripId': doc.id,
        'pickupLocation': tripDetails['pickupLocation'] ?? 'N/A',
        'deliveryLocation': tripDetails['deliveryLocation'] ?? 'N/A',
        'distance': tripDetails['distance'] ?? 'N/A',
        'fare': tripDetails['fare'] ?? 'N/A',
        'driverName': vehicleData['name'] ?? 'Unknown Driver', // Driver name
      };
    }));

    return tripsData;
  } catch (e) {
    print('Error fetching trips: $e');
    return [];
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade300,
        title: const Text('Trip History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching trips.'));
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>> trips = snapshot.data!;

            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                var trip = trips[index];
                
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trip['driverName']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Pickup Location: ${trip['pickupLocation']}'),
                        Text('Delivery Location: ${trip['deliveryLocation']}'),
                        Text('Distance: ${trip['distance']} km'),
                        Text('Fare: NPR ${trip['fare']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No trips found.'));
        },
      ),
    );
  }
}
