import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'trip_model.dart';

class TripCardWidget extends StatefulWidget {
  final TripModel tripData;
  final int index;
  final VoidCallback onPhoneTap;
  final VoidCallback onMapTap;
  final VoidCallback onRequestTap;
  final bool isButtonDisabled; // Add this line
  final String userId; // New parameter
  final String tripId; // New parameter
  final String driverId; // New parameter

  const TripCardWidget({
    super.key,
    required this.tripData,
    required this.index,
    required this.onPhoneTap,
    required this.onMapTap,
    required this.onRequestTap,
    required this.isButtonDisabled, // Accept disabled state as a parameter
    required this.userId, // Accept userId as a parameter
    required this.tripId, // Accept tripId as a parameter
    required this.driverId, // Accept driverId as a parameter
  });

  @override
  State<TripCardWidget> createState() => _TripCardWidgetState();
}

class _TripCardWidgetState extends State<TripCardWidget> {
  // Function to get the user's current location
  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Function to calculate the distance between two points
  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
            startLatitude, startLongitude, endLatitude, endLongitude) /
        1000; // Convert to kilometers
  }

  // Function to fetch pickup location from Firestore
  Future<Map<String, dynamic>> _getPickupLocation(String tripId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    return snapshot.data()!;
  }

  // Function to convert place name to lat-long using OSM Nominatim API
  Future<Map<String, double>> _convertPlaceNameToLatLong(
      String placeName) async {
    final String url =
        'https://nominatim.openstreetmap.org/search?q=$placeName&format=json&limit=1';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final latitude = double.parse(data[0]['lat']);
        final longitude = double.parse(data[0]['lon']);
        return {'latitude': latitude, 'longitude': longitude};
      } else {
        throw Exception('Place not found');
      }
    } else {
      throw Exception('Failed to fetch location data');
    }
  }

  // Function to upload data to Firestore
  Future<void> _uploadDistanceData({
    required String tripId,
    required String driverId,
    required String userId,
    required double distance,
  }) async {
    await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
      'distance_between_driver_and_passenger': distance,
      'driverId': driverId,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.index + 1}.  ${widget.tripData.username}  -  ${widget.tripData.noofPerson} Passenger  -  ${widget.tripData.vehicleMode}',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            Divider(),
            Text('Pickup Location: ${widget.tripData.pickupLocation}'),
            Divider(),
            Text('Delivery Location: ${widget.tripData.deliveryLocation}'),
            Divider(),
            Text('Municipality: ${widget.tripData.municipalityDropdown}'),
            Divider(),
            Text('Fare: ${widget.tripData.fare}'),
            Divider(),
            Text('Distance: ${widget.tripData.distance}'),
            Divider(),
            Text('Timestamp: ${widget.tripData.timestamp}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: widget.isButtonDisabled
                      ? null
                      : () async {
                          // Check location permission
                          LocationPermission permission =
                              await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            // Request permission
                            permission = await Geolocator.requestPermission();
                            if (permission != LocationPermission.whileInUse &&
                                permission != LocationPermission.always) {
                              // Permission denied
                              // You can show a dialog or a Snackbar to inform the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Location permission is required to proceed.')),
                              );
                              return;
                            }
                          }

                          // Check if location services are enabled
                          if (!await Geolocator.isLocationServiceEnabled()) {
                            // Location services are not enabled
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please enable location services.')),
                            );
                            return;
                          }

                          // 1. Get current location
                          Position userPosition = await _getCurrentLocation();

                          // 2. Fetch pickup location from Firestore
                          Map<String, dynamic> tripData =
                              await _getPickupLocation(widget.tripId);
                          var pickupLocation = tripData['pickupLocation'];

                          double pickupLatitude;
                          double pickupLongitude;

                          // 3. Check if pickupLocation is a GeoPoint (lat, long) or a place name
                          if (pickupLocation is GeoPoint) {
                            // If it's a GeoPoint, extract lat and long
                            pickupLatitude = pickupLocation.latitude;
                            pickupLongitude = pickupLocation.longitude;
                          } else {
                            // If it's a place name, convert to lat-long using Nominatim
                            Map<String, double> latLong =
                                await _convertPlaceNameToLatLong(
                                    pickupLocation);
                            pickupLatitude = latLong['latitude']!;
                            pickupLongitude = latLong['longitude']!;
                          }

                          // 4. Calculate the distance between user's location and pickup location
                          double distance = _calculateDistance(
                            userPosition.latitude,
                            userPosition.longitude,
                            pickupLatitude,
                            pickupLongitude,
                          );

                          // 5. Upload the distance and other information to Firestore
                          await _uploadDistanceData(
                            tripId: widget.tripId,
                            driverId: widget.driverId,
                            userId: widget.userId,
                            distance: distance,
                          );

                          print('Distance successfully uploaded');
                          widget.onRequestTap();
                        },
                  color: widget.isButtonDisabled ? Colors.grey : Colors.blue,
                ),
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: widget.onPhoneTap,
                ),
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: widget.onMapTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
