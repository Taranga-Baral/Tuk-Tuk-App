import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverAcceptedPage extends StatelessWidget {
  final String driverId; // The driverId passed from the previous page

  DriverAcceptedPage({required this.driverId});

  Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()!;
    } else {
      return {'username': 'Unknown', 'phone': 'Unknown'};
    }
  }

  Future<Map<String, dynamic>> _fetchTripDetails(String tripId) async {
    final tripDoc = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    if (tripDoc.exists) {
      return tripDoc.data()!;
    } else {
      return {
        'pickupLocation': 'Unknown',
        'deliveryLocation': 'Unknown',
        'fare': '0',
        'distance': '0',
      };
    }
  }

  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  Future<Map<String, double>> _geocodeAddress(String address) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'latitude': double.parse(data[0]['lat']),
          'longitude': double.parse(data[0]['lon']),
        };
      }
    }
    throw Exception('Failed to geocode address');
  }

  Future<void> _launchOpenStreetMapWithDirections(String pickupLocation, String deliveryLocation) async {
    try {
      final pickupCoords = _parseCoordinates(pickupLocation) ?? await _geocodeAddress(pickupLocation);
      final deliveryCoords = _parseCoordinates(deliveryLocation) ?? await _geocodeAddress(deliveryLocation);

      final pickupLatitude = pickupCoords['latitude']!;
      final pickupLongitude = pickupCoords['longitude']!;
      final deliveryLatitude = deliveryCoords['latitude']!;
      final deliveryLongitude = deliveryCoords['longitude']!;

      final String openStreetMapUrl =
          'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

      final Uri launchUri = Uri.parse(openStreetMapUrl);

      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print('Could not launch $launchUri');
      }
    } catch (e) {
      print('Error fetching trip details: $e');
    }
  }

  Map<String, double>? _parseCoordinates(String location) {
    final parts = location.split(',');
    if (parts.length == 2) {
      final latitude = double.tryParse(parts[0]);
      final longitude = double.tryParse(parts[1]);
      if (latitude != null && longitude != null) {
        return {'latitude': latitude, 'longitude': longitude};
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accepted Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('confirmedDrivers')
            .where('driverId', isEqualTo: driverId) // Filter by driverId
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No accepted requests for this driver.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final userId = request['userId'];
              final tripId = request['tripId'];

              return FutureBuilder(
                future: Future.wait([
                  _fetchUserDetails(userId),
                  _fetchTripDetails(tripId),
                ]),
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return Center(child: Text('Error loading details'));
                  }

                  final userDetails = snapshot.data![0];
                  final tripDetails = snapshot.data![1];

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text('Trip ID: $tripId'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: $userId'),
                          Text('Username: ${userDetails['username']}'),
                          Text('Phone: ${userDetails['phone']}'),
                          Text('Pickup Location: ${tripDetails['pickupLocation']}'),
                          Text('Delivery Location: ${tripDetails['deliveryLocation']}'),
                          Text('Fare: ${tripDetails['fare']}'),
                          Text('Distance: ${tripDetails['distance']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () {
                              final phoneNumber = userDetails['phone'] ?? '';
                              if (phoneNumber.isNotEmpty) {
                                _launchPhoneNumber(phoneNumber);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.map),
                            onPressed: () {
                              final pickupLocation = tripDetails['pickupLocation'] ?? '';
                              final deliveryLocation = tripDetails['deliveryLocation'] ?? '';
                              if (pickupLocation.isNotEmpty && deliveryLocation.isNotEmpty) {
                                _launchOpenStreetMapWithDirections(pickupLocation, deliveryLocation);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
