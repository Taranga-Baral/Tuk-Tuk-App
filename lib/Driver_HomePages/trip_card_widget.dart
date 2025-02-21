import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // Future<Map<String, double>> _convertPlaceNameToLatLong(
  //     String placeName) async {
  //   final String url =
  //       'https://nominatim.openstreetmap.org/search?q=$placeName&format=json&limit=1';
  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     final List data = json.decode(response.body);
  //     if (data.isNotEmpty) {
  //       final latitude = double.parse(data[0]['lat']);
  //       final longitude = double.parse(data[0]['lon']);
  //       return {'latitude': latitude, 'longitude': longitude};
  //     } else {
  //       throw Exception('Place not found');
  //     }
  //   } else {
  //     throw Exception('Failed to fetch location data');
  //   }
  // }

// Function to check if a document exists in the requestsofDrivers collection
  Future<bool> checkRequestExists(
      String tripId, String userId, String driverId) async {
    try {
      // Reference to the requestsofDrivers collection
      CollectionReference requestCollection =
          FirebaseFirestore.instance.collection('requestsofDrivers');

      // Query to check for any matching document
      QuerySnapshot querySnapshot = await requestCollection
          .where('tripId', isEqualTo: tripId)
          .where('userId', isEqualTo: userId)
          .where('driverId', isEqualTo: driverId)
          .get();

      // If there are any documents that match, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle any errors
      print('Error checking request existence: $e');
      rethrow;
    }
  }

// Function to upload data to Firestore
  Future<void> _uploadDistanceData({
    required String tripId,
    required String driverId,
    required String userId,
    required double distance,
  }) async {
    try {
      // Check if a document matching the criteria exists in requestsofDrivers collection
      bool requestExists = await checkRequestExists(tripId, userId, driverId);

      // If no matching document found, proceed to upload distance data
      if (!requestExists) {
        // Prepare the data to be stored in the new collection
        Map<String, dynamic> distanceData = {
          'tripId': tripId,
          'userId': userId,
          'driverId': driverId,
          'distance_between_driver_and_passenger': distance,
        };

        // Reference to the new collection
        CollectionReference distanceCollection = FirebaseFirestore.instance
            .collection('distance_between_driver_and_passenger');

        // Add or update the document in the new collection
        await distanceCollection.add(distanceData);

        print('Distance data uploaded successfully.');
      } else {
        print(
            'Matching request document found in requestsofDrivers collection. Skipping upload.');
      }
    } catch (e) {
      // Handle any errors
      print('Error uploading distance data: $e');
      rethrow; // Re-throw the error for potential further handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       '${widget.tripData.username}',
            //       style: GoogleFonts.outfit(
            //           fontWeight: FontWeight.w400, fontSize: 16),
            //     ),
            //     Text(
            //       '${widget.tripData.distance.toStringAsFixed(1)} Km',
            //       style: GoogleFonts.outfit(
            //           fontWeight: FontWeight.w400, fontSize: 16),
            //     ),
            //     Text(
            //       'NPR ${widget.tripData.fare}',
            //       style: GoogleFonts.outfit(
            //           fontWeight: FontWeight.w400, fontSize: 16),
            //     ),
            //   ],
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.tripData.username}',
                    textAlign:
                        TextAlign.center, // Adjust text alignment if necessary
                    style: GoogleFonts.outfit(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 10), // Add spacing between texts
                Expanded(
                  child: Text(
                    '${widget.tripData.distance.toStringAsFixed(1)} Km',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'NPR ${widget.tripData.fare}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            Divider(),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Container(
            //       // height: MediaQuery.of(context).size.height * 0.1,
            //       height: MediaQuery.of(context).size.height <= 500
            //           ? MediaQuery.of(context).size.height * 0.2
            //           : MediaQuery.of(context).size.height * 0.08,
            //       width: MediaQuery.of(context).size.width * 0.25,
            //       decoration: BoxDecoration(
            //           image: DecorationImage(
            //               image: widget.tripData.vehicleType == 'Tuk Tuk'
            //                   ? AssetImage('assets/homepage_tuktuk.png')
            //                   : widget.tripData.vehicleType == 'Motor Bike'
            //                       ? AssetImage('assets/homepage_motorbike.png')
            //                       : AssetImage('assets/homepage_taxi.png'))),
            //     ),
            //     Container(
            //       // height: MediaQuery.of(context).size.height * 0.1,
            //       height: MediaQuery.of(context).size.height <= 500
            //           ? MediaQuery.of(context).size.height * 0.2
            //           : MediaQuery.of(context).size.height * 0.08,

            //       width: MediaQuery.of(context).size.width * 0.35,
            //       decoration: BoxDecoration(
            //           image: DecorationImage(
            //               image: widget.tripData.noofPerson == 1
            //                   ? AssetImage('assets/driver_1_passenger.png')
            //                   : widget.tripData.noofPerson == 2
            //                       ? AssetImage('assets/driver_2_passenger.png')
            //                       : widget.tripData.noofPerson == 3
            //                           ? AssetImage(
            //                               'assets/driver_3_passenger.png')
            //                           : widget.tripData.noofPerson == 4
            //                               ? AssetImage(
            //                                   'assets/driver_4_passenger.png')
            //                               : AssetImage(
            //                                   'assets/driver_5_passenger.png'))),
            //     ),
            //     Container(
            //       // height: MediaQuery.of(context).size.height * 0.1,
            //       height: MediaQuery.of(context).size.height <= 500
            //           ? MediaQuery.of(context).size.height * 0.2
            //           : MediaQuery.of(context).size.height * 0.08,
            //       width: MediaQuery.of(context).size.width * 0.25,
            //       decoration: BoxDecoration(
            //           image: DecorationImage(
            //               image: widget.tripData.vehicleMode == 'Electric'
            //                   ? AssetImage(
            //                       'assets/driver_homepage_electric.png')
            //                   : AssetImage(
            //                       'assets/driver_homepage_petrol.png'))),
            //     ),
            //   ],
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    height: MediaQuery.of(context).size.height <= 500
                        ? MediaQuery.of(context).size.height * 0.2
                        : MediaQuery.of(context).size.height * 0.045,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit
                            .contain, // Ensure image fits without overflow
                        image: widget.tripData.vehicleType == 'Tuk Tuk'
                            ? AssetImage('assets/homepage_tuktuk.png')
                            : widget.tripData.vehicleType == 'Motor Bike'
                                ? AssetImage('assets/homepage_motorbike.png')
                                : AssetImage('assets/homepage_taxi.png'),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Add spacing between containers
                Flexible(
                  child: Container(
                    height: MediaQuery.of(context).size.height <= 500
                        ? MediaQuery.of(context).size.height * 0.2
                        : MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.35,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit
                            .contain, // Ensure image fits without overflow
                        image: widget.tripData.noofPerson == 1
                            ? AssetImage('assets/driver_1_passenger.png')
                            : widget.tripData.noofPerson == 2
                                ? AssetImage('assets/driver_2_passenger.png')
                                : widget.tripData.noofPerson == 3
                                    ? AssetImage(
                                        'assets/driver_3_passenger.png')
                                    : widget.tripData.noofPerson == 4
                                        ? AssetImage(
                                            'assets/driver_4_passenger.png')
                                        : AssetImage(
                                            'assets/driver_5_passenger.png'),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: Container(
                    height: MediaQuery.of(context).size.height <= 500
                        ? MediaQuery.of(context).size.height * 0.2
                        : MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit
                            .contain, // Ensure image fits without overflow
                        image: widget.tripData.vehicleMode == 'Electric'
                            ? AssetImage('assets/driver_homepage_electric.png')
                            : AssetImage('assets/driver_homepage_petrol.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                  '${widget.tripData.pickupLocation}',
                  style: GoogleFonts.comicNeue(),
                )),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                  '${widget.tripData.deliveryLocation}',
                  style: GoogleFonts.comicNeue(),
                )),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Icon(
                  Icons.holiday_village_sharp,
                  color: Colors.orangeAccent,
                ),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                  '${widget.tripData.municipalityDropdown}',
                  style: GoogleFonts.comicNeue(),
                )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.send,
                  ),
                  onPressed: widget.isButtonDisabled
                      ? null
                      : () async {
                          // showDialog(
                          //   context: context,
                          //   barrierDismissible:
                          //       false, // Prevent user from dismissing the dialog
                          //   builder: (BuildContext context) {
                          //     return Dialog(
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(20.0),
                          //         child: Column(
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: const [
                          //             // CircularProgressIndicator(), // Display a loading indicator
                          //             // SizedBox(height: 10),
                          //             // Text('Processing ...')
                          //           ],
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // );

// Automatically close the dialog after 5 seconds
                          Future.delayed(const Duration(seconds: 5), () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          });

                          try {
                            // Check location permission
                            LocationPermission permission =
                                await Geolocator.checkPermission();
                            if (permission == LocationPermission.denied) {
                              // Request permission
                              permission = await Geolocator.requestPermission();
                              if (permission != LocationPermission.whileInUse &&
                                  permission != LocationPermission.always) {
                                // Permission denied
                                Navigator.pop(context); // Close the dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Location permission is required to proceed.'),
                                  ),
                                );
                                return;
                              }
                            }

                            // Check if location services are enabled
                            if (!await Geolocator.isLocationServiceEnabled()) {
                              // Location services are not enabled
                              Navigator.pop(context); // Close the dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please enable location services.'),
                                ),
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

                            // 3. Check if pickupLocation is a GeoPoint (lat, long) or a place name (aaile directly available in fb db)

                            pickupLatitude = tripData['pickupLatitude'];
                            pickupLongitude = tripData['pickupLongitude'];

                            widget.onRequestTap();

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
                          } catch (e) {
                            // Handle error if needed
                            print('Error: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'An error occurred. Please try again later.'),
                              ),
                            );
                          } finally {
                            // Close the loading dialog if it's still open
                            setState(() {
                              setState(() {});
                            });
                          }
                        },
                  color: widget.isButtonDisabled ? Colors.grey : Colors.blue,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.phone,
                    color: Colors.blueGrey,
                  ),
                  onPressed: widget.onPhoneTap,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.blueGrey,
                  ),
                  onPressed: widget.onMapTap,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.tripData.timestamp}',
                  style:
                      GoogleFonts.comicNeue(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
