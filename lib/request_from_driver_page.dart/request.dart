import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  final String userId;

  RequestPage({required this.userId});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List<DocumentSnapshot> requests = [];
  bool isDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests Page'),
      ),
      body: isDataLoaded
          ? ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final tripId = request['tripId'];
                final driverId = request['driverId'];
                final userId = request['userId'];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('Trip ID: $tripId'),
                    subtitle: Text('Driver ID: $driverId'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        confirmRequest(userId, driverId, tripId, index);
                      },
                      child: Text('Confirm'),
                    ),
                  ),
                );
              },
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('requestsofDrivers')
                  .where('userId', isEqualTo: widget.userId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No requests available.'));
                }

                requests = snapshot.data!.docs;
                isDataLoaded = true;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final tripId = request['tripId'];
                    final driverId = request['driverId'];
                    final userId = request['userId'];

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('Trip ID: $tripId'),
                        subtitle: Text('Driver ID: $driverId'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            confirmRequest(userId, driverId, tripId, index);
                          },
                          child: Text('Confirm'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Method to confirm the request, store it in Firebase, and remove the card from the UI
  void confirmRequest(String userId, String driverId, String tripId, int index) async {
    try {
      // Step 1: Add the confirmed request to the "confirmedDrivers" collection in Firebase
      await FirebaseFirestore.instance.collection('confirmedDrivers').add({
        'userId': userId,
        'driverId': driverId,
        'tripId': tripId,
        'confirmedAt': FieldValue.serverTimestamp(), // Optional timestamp
      });

      // Step 2: Remove the card from the local list
      setState(() {
        requests.removeAt(index);
      });

      // Step 3: Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request confirmed and stored in Firebase.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming request: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
