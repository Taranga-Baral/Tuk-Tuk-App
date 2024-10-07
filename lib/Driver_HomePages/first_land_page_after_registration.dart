import 'dart:async';
import 'dart:convert';
import 'package:final_menu/Driver_HomePages/sorting_pages.dart';
import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trip_model.dart';
import 'trip_card_widget.dart';

class DriverHomePage extends StatefulWidget {
  final String driverEmail;

  const DriverHomePage({super.key, required this.driverEmail});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String _selectedSortOption = 'Timestamp Newest First';
  final int _itemsPerPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  List<bool> _isButtonDisabledList =
      []; // List to hold button states for each trip

  final List<TripModel> _tripDataList = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      SnackBar(content: Text('Could not launch Location'));
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

  Future<void> _launchOpenStreetMapWithDirections(String tripId) async {
    try {
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();

      if (tripSnapshot.exists) {
        final data = tripSnapshot.data() as Map<String, dynamic>;
        final pickupLocation = data['pickupLocation'] as String;
        final deliveryLocation = data['deliveryLocation'] as String;

        // Try to parse as coordinates
        final pickupCoords = _parseCoordinates(pickupLocation);
        final deliveryCoords = _parseCoordinates(deliveryLocation);

        double pickupLatitude;
        double pickupLongitude;
        double deliveryLatitude;
        double deliveryLongitude;

        if (pickupCoords != null) {
          pickupLatitude = pickupCoords['latitude']!;
          pickupLongitude = pickupCoords['longitude']!;
        } else {
          final pickupData = await _geocodeAddress(pickupLocation);
          pickupLatitude = pickupData['latitude']!;
          pickupLongitude = pickupData['longitude']!;
        }

        if (deliveryCoords != null) {
          deliveryLatitude = deliveryCoords['latitude']!;
          deliveryLongitude = deliveryCoords['longitude']!;
        } else {
          final deliveryData = await _geocodeAddress(deliveryLocation);
          deliveryLatitude = deliveryData['latitude']!;
          deliveryLongitude = deliveryData['longitude']!;
        }

        final String openStreetMapUrl =
            'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

        final Uri launchUri = Uri.parse(openStreetMapUrl);

        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        } else {
          print('Could not launch $launchUri');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip details not found')),
          );
        }
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

  String _getSortField() => _selectedSortOption == 'Timestamp Newest First'
      ? 'timestamp'
      : 'timestamp';

  bool _getSortDescending() => _selectedSortOption == 'Timestamp Newest First';

  int _sortTrips(TripModel a, TripModel b) {
    switch (_selectedSortOption) {
      case 'Price Expensive First':
        return _compareByIntegerPart(b.fare, a.fare);
      case 'Price Cheap First':
        return _compareByIntegerPart(a.fare, b.fare);
      case 'Distance Largest First':
        return _compareByIntegerPart(b.distance, a.distance);
      case 'Distance Smallest First':
        return _compareByIntegerPart(a.distance, b.distance);
      default: // Timestamp Newest First
        return b.timestamp.compareTo(a.timestamp);
    }
  }

  int _compareByIntegerPart(double a, double b) {
    return a.compareTo(b);
  }

  Future<void> _navigateToSortingPage() async {
    final selectedOption = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SortingPage(selectedSortOption: _selectedSortOption)),
    );

    if (selectedOption != null) {
      setState(() {
        _selectedSortOption = selectedOption;
        _tripDataList.sort((a, b) => _sortTrips(a, b));
      });
    }
  }

  // Other existing methods...
  Future<void> _fetchTrips() async {
  if (_isLoading || !_hasMore) return; // Check if already loading or no more trips
  setState(() => _isLoading = true); // Set loading state to true

  Query query = FirebaseFirestore.instance
      .collection('trips')
      .orderBy(_getSortField(), descending: _getSortDescending())
      .limit(_itemsPerPage); // Limit results to items per page

  if (_lastDocument != null) {
    query = query.startAfterDocument(_lastDocument!); // Start after last fetched document
  }

  try {
    final querySnapshot = await query.get();
    if (querySnapshot.docs.isEmpty) {
      setState(() => _hasMore = false); // No more trips to load
    } else {
      _lastDocument = querySnapshot.docs.last; // Update last document
      var newTrips = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['distance'] = double.tryParse(data['distance'] as String ?? '') ?? 0.0;
        data['fare'] = double.tryParse(data['fare'] as String ?? '') ?? 0.0;
        data['tripId'] = doc.id; // Get trip ID
        return TripModel.fromJson(data);
      }).toList();

      _tripDataList.addAll(newTrips); // Add new trips to the list

      // Initialize button states for newly added trips
      for (var trip in newTrips) {
        _isButtonDisabledList.add(false); // Set initial state as enabled
      }

      // Load button states after new trips are fetched
      await _loadButtonStates();

      // Sort the complete trip list
      _tripDataList.sort((a, b) => _sortTrips(a, b));

      if (mounted) setState(() {}); // Update UI
    }
  } catch (e) {
    print('Error fetching trips: $e'); // Handle any errors
  } finally {
    if (mounted) setState(() => _isLoading = false); // Set loading state to false
  }
}


  _loadButtonStates() async {
    final prefs = await SharedPreferences.getInstance();
    _isButtonDisabledList
        .clear(); // Clear the existing list to avoid duplicates
    for (var trip in _tripDataList) {
      final isDisabled =
          prefs.getBool(trip.tripId!) ?? false; // Fetch the state for each trip
      _isButtonDisabledList.add(isDisabled); // Add the state to the list
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadButtonStates(); // Load button states
    _fetchTrips();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchTrips();
      }
    });
  }

void _setButtonState(int index) async {
  setState(() {
    _isButtonDisabledList[index] = true; // Disable the button
  });

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_tripDataList[index].tripId!, true); // Save state in SharedPreferences
}

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'accepted_trips':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverAcceptedPage(
              driverEmail: widget.driverEmail,
              driverId: widget.driverEmail,
            ),
          ),
        );
        break;
      case 'driver_filter':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverFilterPage(
              driverId: widget.driverEmail,
            ),
          ),
        );
        break;
      case 'successful_trips':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverSuccessfulTrips(
              driverId: widget.driverEmail,
            ),
          ),
        );
        break;
      case 'view_messages':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverChatPage(
              driverId: widget.driverEmail,
            ),
          ),
        );
        break;
      case 'passenger_mode':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignInPage(), // Replace with your SignInPage
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: _onMenuItemSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                    value: 'accepted_trips', child: Text('Accepted Trips')),
                const PopupMenuItem(
                    value: 'driver_filter', child: Text('Driver Filter Page')),
                const PopupMenuItem(
                    value: 'successful_trips', child: Text('Successful Trips')),
                const PopupMenuItem(
                    value: 'view_messages', child: Text('View Messages')),
                const PopupMenuItem(
                    value: 'passenger_mode', child: Text('Passenger Mode')),
              ];
            },
          ),
        ],
      ),
      body: _isLoading && _tripDataList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
                    controller: _scrollController,
                            itemCount: _tripDataList.length + (_hasMore ? 1 : 0), // Loading indicator if more trips are available
              itemBuilder: (context, index) {
                 if (index == _tripDataList.length) {
          return Center(child: CircularProgressIndicator()); // Loading indicator at the end
        }
                final tripData = _tripDataList[index];
                // Check the index against the length of _isButtonDisabledList
                final isButtonDisabled = index < _isButtonDisabledList.length
                    ? _isButtonDisabledList[index]
                    : false; // Default to false if index is out of bounds

                return TripCardWidget(
                  tripData: _tripDataList[index],
                  onPhoneTap: () {
                    
                    
                    if (tripData.phoneNumber != null && tripData.phoneNumber!.isNotEmpty) {
                      _launchPhoneNumber(tripData.phoneNumber!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Phone number not available')),
                      );
                    }



                  },
                  onMapTap: () => _launchOpenStreetMapWithDirections(tripData.tripId!),
                  onRequestTap: () {
                    _setButtonState(index); // Call to disable the button
                    showTripAndUserIdInSnackBar(_tripDataList[index], context, index);
                  },
                  index: index,
                  isButtonDisabled:
                      isButtonDisabled, // Use the checked value here
                );
              },
            ),
    );
  }


  Future<void> showTripAndUserIdInSnackBar(
    TripModel tripData, BuildContext context, int index) async {
  final tripId = tripData.tripId ?? 'No Trip ID';
  final userId = tripData.userId ?? 'No User ID';
  final driverId = widget.driverEmail;

  if (tripId == 'No Trip ID' || userId == 'No User ID') {
    // Show error if tripId or userId is missing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid Trip or User ID.'),
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  

    try {
      // Step 1: Add the userId, driverId, and tripId to the new "requestsofDrivers" collection
      await FirebaseFirestore.instance.collection('requestsofDrivers').add({
        'tripId': tripId,
        'userId': userId,
        'driverId': driverId,
        'requestTimestamp':
            FieldValue.serverTimestamp(), // Optional: Add a timestamp
      });

      // Step 2: Darken the button and show a SnackBar
      _setButtonState(index); // Call to disable the button after confirmation

      // Show a SnackBar with tripId, userId, and driverId
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request sent successfully!',
          ),
          duration: const Duration(seconds: 10), // Show for 10 seconds
        ),
      );
    } catch (e) {
      // Handle error (e.g., if something goes wrong during the Firebase write)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  
}

}
