
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/chat/chat_display_page.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String userId;

  ChatPage({required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> confirmedDriversData = [];

  @override
  void initState() {
    super.initState();
    fetchConfirmedDriversData();
  }

Future<void> fetchConfirmedDriversData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query confirmedDrivers where userId matches
  QuerySnapshot confirmedDriversSnapshot = await firestore
      .collection('confirmedDrivers')
      .where('userId', isEqualTo: widget.userId)
      .get();

  List<Map<String, dynamic>> fetchedData = [];

  for (var doc in confirmedDriversSnapshot.docs) {
    var confirmedDriverData = doc.data() as Map<String, dynamic>;

    // Fetch details from trips using tripId
    DocumentSnapshot tripSnapshot = await firestore
        .collection('trips')
        .doc(confirmedDriverData['tripId'])
        .get();
    var tripData = tripSnapshot.data() as Map<String, dynamic>;

    // Fetch details from vehicleData using driverId
    DocumentSnapshot driverSnapshot = await firestore
        .collection('vehicleData')
        .doc(confirmedDriverData['driverId'])
        .get();
    var driverData = driverSnapshot.data() as Map<String, dynamic>;

    // Combine the data from both collections and include profile picture
    fetchedData.add({
      'id': doc.id,
      'pickupLocation': tripData['pickupLocation'],
      'deliveryLocation': tripData['deliveryLocation'],
      'distance': tripData['distance'],
      'fare': tripData['fare'],
      'driverName': driverData['name'],
      'driverPhone': driverData['phone'],
      'profilePictureUrl': driverData['profilePictureUrl'] ?? '', // Fetch profile picture
      'driverId': confirmedDriverData['driverId'],
      'tripId': confirmedDriverData['tripId'],
    });
  }

  setState(() {
    confirmedDriversData = fetchedData;
  });
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Chat with Drivers'),
    ),
    body: confirmedDriversData.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: confirmedDriversData.length,
              itemBuilder: (context, index) {
                var data = confirmedDriversData[index];
                String driverId = data['driverId'];
                String tripId = data['tripId'];
                String profilePictureUrl = data['profilePictureUrl'];

                return Card(
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : AssetImage('assets/default_profile.png')
                              as ImageProvider, // Fallback image if no URL
                    ),
                    title: Text('Driver: ${data['driverName']}'),
                    subtitle: Text(
                      'Pickup: ${data['pickupLocation']}\n'
                      'Delivery: ${data['deliveryLocation']}\n'
                      'Phone: ${data['driverPhone']}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.chat),
                      onPressed: () {
                        // Navigate to ChatDetailPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailPage(
                              userId: widget.userId,
                              driverId: driverId,
                              tripId: tripId,
                              driverName: data['driverName'],
                              pickupLocation: data['pickupLocation'],
                              deliveryLocation: data['deliveryLocation'],
                              distance: data['distance'],
                              fare: data['fare'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
  );
}
}
