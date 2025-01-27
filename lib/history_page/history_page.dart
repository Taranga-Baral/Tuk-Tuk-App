import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      List<Map<String, dynamic>> tripsData =
          await Future.wait(tripsSnapshot.docs.map((doc) async {
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
            .doc(tripData['driverId']) // Assuming driverId is the email here
            .get();
        final vehicleData = vehicleDoc.exists
            ? vehicleDoc.data() as Map<String, dynamic>
            : {'name': 'Unknown Driver'}; // Default name if no data

        return {
          'tripId': doc.id,
          'pickupLocation': tripDetails['pickupLocation'] ?? 'N/A',
          'deliveryLocation': tripDetails['deliveryLocation'] ?? 'N/A',
          'distance': tripDetails['distance'] ?? 'N/A',
          'fare': tripDetails['fare'] ?? 'N/A',
          'vehicleType': tripDetails['vehicleType'] ?? 'N/A',
          'no_of_person': tripDetails['no_of_person'] ?? 'N/A',
          'vehicle_mode': tripDetails['vehicle_mode'] ?? 'N/A',
          'driverName': vehicleData['name'] ?? 'Unknown Driver', // Driver name
          'profilePictureUrl':
              vehicleData['profilePictureUrl'] ?? '', // Driver name
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Trip History',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
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
                  elevation: 2,
                  // color: Colors.white,
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
                          '${index + 1}. ${trip['driverName']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(child: Text('${trip['pickupLocation']}')),
                          ],
                        ),
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
                                child: Text('${trip['deliveryLocation']}')),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.indigo.shade400,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                                child: Text(
                                    '${double.tryParse(trip['distance'])?.toStringAsFixed(2)} कि.मि, ${trip['vehicleType']}, ${trip['vehicle_mode']}, ${trip['no_of_person']}, ${trip['fare']} रुपैय')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                // return Container(
                //   color: Colors.grey,
                //   child: Column(
                //     children: [
                //       Container(
                //         color: Colors.red,
                //         child: ,
                //       ),
                //     ],
                //   ),
                // );
              },
            );
          }

          return Center(
            child: Image(
              image: AssetImage('assets/no_data_found.gif'),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
            ),
          );
        },
      ),
    );
  }
}
