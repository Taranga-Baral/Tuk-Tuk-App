
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
        
//         final vehicleName = vehicleSnapshot?.docs.isNotEmpty == true
//             ? vehicleSnapshot!.docs.first.data()['name'] ?? 'Unknown'
//             : 'Unknown';

//         final username = userSnapshot.data()?['username'] ?? 'Unknown';

//         return {
//           'tripId': doc.id,
//           'timestamp': tripData['timestamp'],
//           'userId': tripData['userId'],
//           'driverId': tripData['driverId'],
//           'username': username, // Include username here
//           'vehicleName': vehicleName, // Include vehicle name here
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
//                         Text('Vehicle Name: ${trip['vehicleName'] ?? 'N/A'}'), // Display vehicle name
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

      // Fetch user details and vehicle data for each trip
      List<Map<String, dynamic>> tripsData = await Future.wait(tripsSnapshot.docs.map((doc) async {
        final tripData = doc.data() as Map<String, dynamic>;
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(tripData['userId'])
            .get();
        final vehicleSnapshot = tripData['driverId'] != null
            ? await FirebaseFirestore.instance
                .collection('vehicleData')
                .where('driverId', isEqualTo: tripData['driverId'])
                .get()
            : null;
        
        final vehicleData = vehicleSnapshot?.docs.isNotEmpty == true
            ? vehicleSnapshot!.docs.first.data() as Map<String, dynamic>
            : {};
        
        final username = userSnapshot.data()?['username'] ?? 'Unknown';
        final driverPhone = vehicleData['phone'] ?? 'Unknown';

        return {
          'tripId': doc.id,
          'timestamp': tripData['timestamp'],
          'userId': tripData['userId'],
          'driverId': tripData['driverId'],
          'username': username, // Include username here
          'driverPhone': driverPhone, // Include driver phone number here
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
        title: const Text('Trips'),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trip ID: ${trip['tripId']}'),
                        Text('User ID: ${trip['userId']}'),
                        Text('Username: ${trip['username']}'), // Display username
                        Text('Driver ID: ${trip['driverId'] ?? 'N/A'}'),
                        Text('Driver Phone: ${trip['driverPhone'] ?? 'N/A'}'), // Display driver phone number
                        Text('Timestamp: ${trip['timestamp']?.toDate() ?? 'N/A'}'),
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
