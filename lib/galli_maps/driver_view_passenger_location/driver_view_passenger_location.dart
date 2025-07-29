import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/api_service.dart';
import 'package:flutter/material.dart';
import 'package:galli_vector_package/galli_vector_package.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class DriverViewPassengerLocation extends StatefulWidget {
  final String tripId;

  const DriverViewPassengerLocation({super.key, required this.tripId});

  @override
  State<DriverViewPassengerLocation> createState() =>
      _DriverViewPassengerLocationState();
}

class _DriverViewPassengerLocationState
    extends State<DriverViewPassengerLocation> {
  MapLibreMapController? controller;
  Line? _redRouteLine;
  Line? _blueRouteLine;
  Symbol? _driverMarker;
  Symbol? _pickupMarker;
  Symbol? _deliveryMarker;
  LocationData? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _deliveryLocation;
  final List<Line> _routeLines = [];
  Symbol? _selectedSymbol;
  Symbol? _selectedSymbol1;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchTripDetails();
  }

  Future<void> _fetchTripDetails() async {
    // Fetch trip details from Firebase using widget.tripId
    // Example: Fetch pickup and delivery locations from Firebase
    var tripDetails = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();
    _pickupLocation =
        LatLng(tripDetails['pickupLatitude'], tripDetails['pickupLongitude']);
    _deliveryLocation = LatLng(double.parse(tripDetails['deliveryLatitude']),
        double.parse(tripDetails['deliveryLongitude']));

    // // For now, use hardcoded values
    // _pickupLocation = LatLng(27.8172, 85.7240); // Example pickup location
    // _deliveryLocation = LatLng(27.7600, 85.5000); // Example delivery location

    setState(() {});
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Location location = Location();
    _currentLocation = await location.getLocation();
    _updateDriverMarker(_currentLocation!);

    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
      _updateDriverMarker(currentLocation);
      _checkArrivalAtPickupLocation();
    });
  }

  void _updateDriverMarker(LocationData location) async {
    if (controller != null) {
      // Remove the old driver marker
      if (_driverMarker != null) {
        controller!.removeSymbol(_driverMarker!);
      }

      // Add a new driver marker at the updated location
      _driverMarker = await controller!.addSymbol(SymbolOptions(
        geometry: LatLng(location.latitude!, location.longitude!),
        iconAnchor: 'center',
        iconSize: 0.3,
        iconHaloBlur: 10,
        iconHaloWidth: 2,
        iconOpacity: 1,
        iconOffset: Offset(0, 0.8),
        iconColor: '#0077FF',
        iconHaloColor: '#FFFFFF',
        iconImage: 'images/driverCurrentLocation.png',
        draggable: false,
      ));
    }
  }

  void _checkArrivalAtPickupLocation() {
    if (_currentLocation == null || _pickupLocation == null) return;

    double distance = Geolocator.distanceBetween(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      _pickupLocation!.latitude,
      _pickupLocation!.longitude,
    );

    // if (distance < 100) {
    //   setState(() {});
    //   // 100 meters threshold
    //   _removeRedRoute();
    //   _drawBlueRoute();
    //   _addMarkers();
    //   setState(() {});
    // }
    setState(() {});
    _drawRedRoute();
    _drawBlueRoute();
    _addMarkers();
    setState(() {});
  }

  Future<void> _drawRedRoute() async {
    if (controller == null ||
        _currentLocation == null ||
        _pickupLocation == null) {
      return;
    }

    String url =
        'https://route-init.gallimap.com/api/v1/routing?mode=driving&srcLat=${_currentLocation!.latitude!}&srcLng=${_currentLocation!.longitude!}&dstLat=${_pickupLocation!.latitude}&dstLng=${_pickupLocation!.longitude}&accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
      });

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['success']) {
          var routeData = jsonData['data']['data'];
          List<LineOptions> lineOptionsList = [];

          for (var route in routeData) {
            var latlngs = route['latlngs'];
            List<LatLng> geometry = [];

            for (var latlng in latlngs) {
              geometry.add(LatLng(latlng[1], latlng[0]));
            }

            lineOptionsList.add(LineOptions(
              geometry: geometry,
              lineColor: '#FF0000', // Red color for the route
              lineWidth: 4.0,
              lineOpacity: 1,
              draggable: false,
              lineJoin: 'round',
              lineGapWidth: 2,
              lineBlur: 3,
              lineOffset: 2,
            ));
          }

          _redRouteLine = await controller!.addLine(lineOptionsList[0]);
        }
      }
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  Future<void> _drawBlueRoute() async {
    if (controller == null ||
        _pickupLocation == null ||
        _deliveryLocation == null) {
      return;
    }

    String url =
        'https://route-init.gallimap.com/api/v1/routing?mode=driving&srcLat=${_pickupLocation!.latitude}&srcLng=${_pickupLocation!.longitude}&dstLat=${_deliveryLocation!.latitude}&dstLng=${_deliveryLocation!.longitude}&accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
      });

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['success']) {
          var routeData = jsonData['data']['data'];
          List<LineOptions> lineOptionsList = [];

          for (var route in routeData) {
            var latlngs = route['latlngs'];
            List<LatLng> geometry = [];

            for (var latlng in latlngs) {
              geometry.add(LatLng(latlng[1], latlng[0]));
            }

            lineOptionsList.add(LineOptions(
              geometry: geometry,
              lineColor: '#0000FF', // Blue color for the route
              lineWidth: 4.0,
              lineOpacity: 1,
              draggable: false,
              lineJoin: 'round',
              lineGapWidth: 2,
              lineBlur: 3,
              lineOffset: 2,
            ));
          }

          _blueRouteLine = await controller!.addLine(lineOptionsList[0]);
        }
      }
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  void _removeRedRoute() {
    if (_redRouteLine != null) {
      controller!.removeLine(_redRouteLine!);
      _redRouteLine = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: GalliMap(
                  initialCameraPostion: CameraPosition(
                      target: LatLng(_currentLocation?.latitude ?? 27.7172,
                          _currentLocation?.longitude ?? 85.3240)),
                  showThree60Widget: false,
                  showSearchWidget: false,
                  doubleClickZoomEnabled: true,
                  dragEnabled: true,
                  showCurrentLocation: true,
                  showCurrentLocationButton: true,
                  authToken: '1b040d87-2d67-47d5-aa97-f8b47d301fec',
                  size: (
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                  compassPosition: (
                    position: CompassViewPosition.topRight,
                    offset: const Point(32, 82)
                  ),
                  showCompass: true,
                  onMapCreated: (newC) {
                    controller = newC;
                    _addMarkers();
                    _drawRedRoute();
                    setState(() {});
                  },
                  onMapClick: (LatLng latLng) {},
                  onMapLongPress: (LatLng latlng) {},
                ),
              ),
            ],
          ),
          Positioned(
              top: 60,
              left: 40,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        color: Colors.white,
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Icon(
                            Icons.menu,
                            color: Colors.black,
                            // size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Future<void> _addMarkers() async {
    if (controller == null ||
        _currentLocation == null ||
        _pickupLocation == null ||
        _deliveryLocation == null) {
      return;
    }

    _pickupMarker = await controller!.addSymbol(SymbolOptions(
      geometry: _pickupLocation!,
      iconAnchor: 'center',
      iconSize: 0.3,
      iconHaloBlur: 10,
      iconHaloWidth: 2,
      iconOpacity: 1,
      iconOffset: Offset(0, 0.8),
      iconColor: '#0077FF',
      iconHaloColor: '#FFFFFF',
      iconImage: 'images/pickup.png',
      draggable: false,
    ));

    _deliveryMarker = await controller!.addSymbol(SymbolOptions(
      geometry: _deliveryLocation!,
      iconAnchor: 'center',
      iconSize: 0.3,
      iconHaloBlur: 10,
      iconHaloWidth: 2,
      iconOpacity: 1,
      iconOffset: Offset(0, 0.8),
      iconColor: '#0077FF',
      iconHaloColor: '#FFFFFF',
      iconImage: 'images/destination.png',
      draggable: false,
    ));
  }
}
