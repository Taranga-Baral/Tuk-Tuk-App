import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filterOption = 'All'; 

  // Function to fetch trips based on userId and filter based on driverId
  Future<List<Map<String, dynamic>>> _fetchTrips(String filterOption) async {
    try {
      // Query trips where userId matches
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('userId', isEqualTo: widget.userId)
          .get();

      List<Map<String, dynamic>> tripsData;

      if (filterOption == 'Approved') {
        // Filter trips to only include those with a driverId (Approved)
        tripsData = querySnapshot.docs
            .where((doc) => (doc.data() as Map<String, dynamic>).containsKey('driverId'))
            .map((doc) => {'tripId': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      } else if (filterOption == 'Pending') {
        // Filter trips to only include those without a driverId (Pending)
        tripsData = querySnapshot.docs
            .where((doc) => !(doc.data() as Map<String, dynamic>).containsKey('driverId'))
            .map((doc) => {'tripId': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      } else {
        // "All" filter: Show all trips made by the user
        tripsData = querySnapshot.docs
            .map((doc) => {'tripId': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      }

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
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _filterOption = result; // Change filter based on selection
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('All'),
              ),
              const PopupMenuItem<String>(
                value: 'Approved',
                child: Text('Approved'),
              ),
              const PopupMenuItem<String>(
                value: 'Pending',
                child: Text('Pending'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTrips(_filterOption), // Fetch trips based on the filter option
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching trips.'));
          }

          // Data fetched successfully
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>> trips = snapshot.data!;

            // Display the list of trips
            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> trip = trips[index];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Trip ID: ${trip['tripId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User ID: ${trip['userId']}'),
                        Text('Pickup Location: ${trip['pickupLocation']}'),
                        Text('Delivery Location: ${trip['deliveryLocation']}'),
                        Text('Distance: ${trip['distance']} km'),
                        Text('Fare: ${trip['fare']}'),
                        if (trip.containsKey('driverId'))
                          Text('Driver ID: ${trip['driverId']}'), 
                        Text('Timestamp: ${trip['timestamp'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                    },
                  ),
                );
              },
            );
          }

          // No trips found
          return const Center(child: Text('No trips found.'));
        },
      ),
    );
  }
}
