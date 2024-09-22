import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverSuccessfulTrips extends StatefulWidget {
  final String driverId;

  const DriverSuccessfulTrips({super.key, required this.driverId});

  @override
  _DriverSuccessfulTripsState createState() => _DriverSuccessfulTripsState();
}

class _DriverSuccessfulTripsState extends State<DriverSuccessfulTrips> {
  List<Map<String, dynamic>> successfulTripsData = [];
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSuccessfulTrips();
  }

  Future<void> _loadSuccessfulTrips() async {
    try {
      // Fetch successful trips for the given driverId
      final successfulTripsSnapshot = await FirebaseFirestore.instance
          .collection('successfulTrips')
          .where('driverId', isEqualTo: widget.driverId)
          .get();

      // Fetch user and trip details for each successful trip
      final tripsData = await Future.wait(successfulTripsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .get();
        final tripSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(data['tripId'])
            .get();

        return {
          'successfulTrip': data,
          'user': userSnapshot.data() ?? {}, // Default to empty map if user data is not found
          'trip': tripSnapshot.data() ?? {}, // Default to empty map if trip data is not found
        };
      }));

      setState(() {
        successfulTripsData = tripsData;
        isDataLoaded = true;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isDataLoaded = true; // Ensure that UI reflects data loading error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Successful Trips'),
      ),
      body: isDataLoaded
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
                    title:  Text('𝗨𝘀𝗲𝗿𝗻𝗮𝗺𝗲: ${userData['username'] ?? 'Unknown'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone: ${userData['phone_number'] ?? 'Unknown'}'),
                        Text('Pickup Location: ${tripDetails['pickupLocation'] ?? 'Unknown'}'),
                        Text('Deliver Location: ${tripDetails['deliveryLocation'] ?? 'Unknown'}'),
                        Text('Fare: ${tripDetails['fare'] ?? '0'}'),
                        Text('Distance: ${tripDetails['distance'] ?? '0'}'),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
