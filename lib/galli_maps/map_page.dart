// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:galli_vector_package/galli_vector_package.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:location/location.dart';
// import 'package:tuk_tuk_practise/models/api.dart';
// import 'package:http/http.dart' as http;

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   MapLibreMapController? controller;
//   Line? _selectedLine;
//   Symbol? _selectedSymbol;
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();

//   GalliMethods methods = GalliMethods("1b040d87-2d67-47d5-aa97-f8b47d301fec");
//   List<Symbol> markers = [];
//   late void Function() clearMarkers;
//   LocationData? _currentLocation;
//   ApiModels apimodels = ApiModels();
//   List<Line> _routeLines = [];

//   @override
//   void initState() {
//     super.initState();
//     _getUserLocation();
//     _fetchLocation();
//     _searchController.addListener(updateLiveText);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(updateLiveText);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void updateLiveText() {
//     setState(() {
//       _searchQuery = _searchController.text;
//     });
//   }

//   Future<void> _fetchLocation() async {
//     Location location = Location();

//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) return;
//     }

//     PermissionStatus permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) return;
//     }

//     LocationData locationData = await location.getLocation();
//     setState(() {
//       _currentLocation = locationData;
//     });
//   }

//   Future<void> _getUserLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 color: Colors.transparent,
//                 height: MediaQuery.of(context).size.height * 0.7,
//                 width: double.infinity,
//                 child: GalliMap(
//                   showThree60Widget: false,
//                   showSearchWidget: false,
//                   doubleClickZoomEnabled: true,
//                   dragEnabled: true,
//                   showCurrentLocation: true,
//                   showCurrentLocationButton: true,
//                   authToken: "1b040d87-2d67-47d5-aa97-f8b47d301fec",
//                   size: (
//                     height: MediaQuery.of(context).size.height,
//                     width: MediaQuery.of(context).size.width,
//                   ),
//                   compassPosition: (
//                     position: CompassViewPosition.topRight,
//                     offset: const Point(32, 82)
//                   ),
//                   showCompass: true,
//                   onMapCreated: (newC) {
//                     controller = newC;
//                     setState(() {});
//                   },
//                   onMapClick: (LatLng latLng) {},
//                   onMapLongPress: (LatLng latlng) {},
//                   children: [
//                     if (_searchQuery.isNotEmpty)
//                       Positioned(
//                         top: 40.0,
//                         left: 16.0,
//                         child: Container(
//                           color: Colors.white,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 12.0, vertical: 8.0),
//                           child: Text(
//                             'Place : $_searchQuery',
//                             style: TextStyle(fontSize: 16.0),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               Positioned(
//                 top: 10,
//                 child:
//                     GestureDetector(onTap: showPopup, child: Icon(Icons.abc)),
//               ),
//               Text(_searchController.text),
//               Positioned(
//                 top: 30,
//                 child: Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: TextField(
//                     onSubmitted: _handleSearch,
//                     controller: _searchController,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void showPopup() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           elevation: 1,
//           insetPadding: EdgeInsets.zero,
//           child: Container(
//             width: double.infinity,
//             height: MediaQuery.of(context).size.height,
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   child: Text(
//                     'Results',
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.lexend(
//                         fontSize: 22, fontWeight: FontWeight.w500),
//                   ),
//                 ),
//                 Expanded(
//                   child: FutureBuilder(
//                     future: apimodels.getLocation(
//                         double.parse(
//                             _currentLocation!.latitude!.toStringAsFixed(6)),
//                         double.parse(
//                             _currentLocation!.longitude!.toStringAsFixed(6)),
//                         _searchController.text,
//                         "1b040d87-2d67-47d5-aa97-f8b47d301fec"),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Center(child: Text('Error fetching data.'));
//                       } else if (!snapshot.hasData || snapshot.data.isEmpty) {
//                         return Center(child: Text('No data found.'));
//                       } else {
//                         List<dynamic> searchData = snapshot.data;
//                         return ListView.builder(
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemCount: searchData.length,
//                           itemBuilder: (context, index) {
//                             var myData = snapshot.data[index];
//                             return GestureDetector(
//                               onTap: () async {
//                                 var coordinates = await getLocationCoordinates(
//                                     double.parse(_currentLocation!.latitude!
//                                         .toStringAsFixed(6)),
//                                     double.parse(_currentLocation!.longitude!
//                                         .toStringAsFixed(6)),
//                                     _searchController.text,
//                                     "1b040d87-2d67-47d5-aa97-f8b47d301fec");
//                                 if (coordinates != null) {
//                                   await clearRoutes(); // Clear existing routes
//                                   await drawRoute(
//                                       coordinates); // Draw new route
//                                   Navigator.of(context).pop(); // Close dialog

// //                                   String? locationString = await controller!
// //                 .reverGeoCoding(LatLng(27.67686348105365, 85.32227904529707));

// // if (locationString != null) {
// //   print("Reverse Geocoded Location: $locationString");
// // } else {
// //   print("Reverse Geocoding failed or no location found.");
// // }
// // methods.reverse(latLng)

//                                   print('ok starttttt');
//                                 }
//                               },
//                               child: Card(
//                                 elevation: 1,
//                                 margin: EdgeInsets.symmetric(
//                                     vertical: 3.0, horizontal: 0),
//                                 child: ListTile(
//                                   hoverColor: Colors.grey[200],
//                                   selectedTileColor: Colors.green[100],
//                                   title: Text(
//                                     myData['name'],
//                                     textAlign: TextAlign.left,
//                                     style: GoogleFonts.outfit(
//                                         fontSize: 15, letterSpacing: 0.1),
//                                   ),
//                                   subtitle: Text(
//                                     '${myData['district']}, ${myData['province']}',
//                                     textAlign: TextAlign.left,
//                                     style: GoogleFonts.lexend(
//                                       letterSpacing: 0.1,
//                                       fontSize: 10,
//                                     ),
//                                   ),
//                                   leading: Column(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceEvenly,
//                                     children: [
//                                       Icon(
//                                         Icons.location_on_rounded,
//                                         color: Colors.black54,
//                                         size: 14,
//                                       ),
//                                       Text(
//                                         '${myData['distance']} km',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.w700,
//                                             color: (double.parse(
//                                                         myData['distance'])) <=
//                                                     20
//                                                 ? Colors.green[600]
//                                                 : double.parse(myData[
//                                                             'distance']) >
//                                                         50
//                                                     ? Colors.red[300]
//                                                     : Colors.orangeAccent),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 TextButton(
//                   style: ButtonStyle(
//                     backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
//                     foregroundColor:
//                         WidgetStateProperty.all<Color>(Colors.white),
//                     padding: WidgetStateProperty.all<EdgeInsets>(
//                       EdgeInsets.symmetric(vertical: 16.0),
//                     ),
//                     shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     'Close',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<LatLng?> getLocationCoordinates(double currentLat, double currentLng,
//       String locationName, String authToken) async {
//     String url = 'https://route-init.gallimap.com/api/v1/search/currentLocation'
//         '?accessToken=$authToken'
//         '&name=$locationName'
//         '&currentLat=$currentLat'
//         '&currentLng=$currentLng';

//     try {
//       var response = await http
//           .get(Uri.parse(url), headers: {'accept': 'application/json'});

//       if (response.statusCode == 200) {
//         var jsonData = jsonDecode(response.body);
//         var features = jsonData['data']['features'];
//         if (features != null && features.isNotEmpty) {
//           var coordinates = features[0]['geometry']['coordinates'];
//           return LatLng(coordinates[1], coordinates[0]);
//         }
//       }
//     } catch (e) {
//       print('Error fetching location coordinates: $e');
//     }
//     return null;
//   }

//   Future<void> clearRoutes() async {
//     if (controller != null && _routeLines.isNotEmpty) {
//       for (var line in _routeLines) {
//         await controller!.removeLine(line);
//       }
//       _routeLines.clear(); // Clear the list of route lines
//     }
//   }

//   Future<void> drawRoute(LatLng destination) async {
//     if (controller == null || _currentLocation == null) return;

//     String url =
//         'https://route-init.gallimap.com/api/v1/routing?mode=driving&srcLat=${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}&srcLng=${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}&dstLat=${destination.latitude}&dstLng=${destination.longitude}&accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec';

//     try {
//       var response = await http.get(Uri.parse(url), headers: {
//         'accept': 'application/json',
//       });

//       if (response.statusCode == 200) {
//         var jsonData = json.decode(response.body);

//         if (jsonData['success']) {
//           var routeData = jsonData['data']['data'];
//           List<LineOptions> lineOptionsList = [];

//           for (var route in routeData) {
//             var latlngs = route['latlngs'];
//             List<LatLng> geometry = [];

//             for (var latlng in latlngs) {
//               geometry.add(LatLng(latlng[1], latlng[0]));
//             }

//             lineOptionsList.add(LineOptions(
//               geometry: geometry,
//               lineColor: "#0000ff",
//               lineWidth: 4.0,
//               lineOpacity: 0.5,
//               draggable: false,
//               lineJoin: 'round',
//               lineGapWidth: 2,
//               lineBlur: 3,
//               lineOffset: 2,
//             ));
//           }

//           // Clear existing routes before drawing new ones
//           await clearRoutes();

//           // Add new routes and store them in _routeLines
//           for (var options in lineOptionsList) {
//             var line = await controller!.addLine(options);
//             _routeLines.add(line);

//             Future<String?> fetchLocationName() async {
//               final String destinationnameURL =
//                   "https://route-init.gallimap.com/api/v1/reverse/generalReverse?accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec&lat=${destination.latitude}&lng=${destination.longitude}";

//               final String pickupnameURL =
//                   "https://route-init.gallimap.com/api/v1/reverse/generalReverse?accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec&lat=${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}&lng=${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}";

//               try {
//                 // Make the HTTP GET request
//                 final response = await http.get(Uri.parse(destinationnameURL));
//                 final response1 = await http.get(Uri.parse(pickupnameURL));

//                 // Check if the request was successful
//                 if (response.statusCode == 200 && response1.statusCode == 200) {
//                   // Parse the JSON response
//                   final Map<String, dynamic> jsonResponse =
//                       json.decode(response.body);

//                   final Map<String, dynamic> jsonResponse1 =
//                       json.decode(response1.body);

//                   // Check if the response indicates success
//                   if (jsonResponse['success'] == true &&
//                       jsonResponse1['success'] == true) {
//                     // Extract the location name from the JSON data
//                     final String locationName =
//                         jsonResponse['data']['generalName'];

//                     final String locationName1 =
//                         jsonResponse['data']['generalName'];

//                     print('Hi there Delivery locname is : $locationName');
//                     print('Hi there Delivery locname is : $locationName1');
//                     return locationName;
//                   } else {
//                     // Handle the case where the response is not successful
//                     print('Error: ${jsonResponse['message']}');
//                     return null;
//                   }
//                 } else {
//                   // Handle the case where the HTTP request fails
//                   print('Failed to load data: ${response.statusCode}');
//                   return null;
//                 }
//               } catch (e) {
//                 // Handle any exceptions that occur during the request
//                 print('Exception caught: $e');
//                 return null;
//               }
//             }

//             Future<String?> fetchPickupLocationName() async {
//               final String pickupnameURL =
//                   "https://route-init.gallimap.com/api/v1/reverse/generalReverse?accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec&lat=${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}&lng=${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}";

//               try {
//                 // Make the HTTP GET request
//                 final response = await http.get(Uri.parse(pickupnameURL));

//                 // Check if the request was successful
//                 if (response.statusCode == 200) {
//                   // Parse the JSON response
//                   final Map<String, dynamic> jsonResponse =
//                       json.decode(response.body);

//                   // Check if the response indicates success
//                   if (jsonResponse['success'] == true) {
//                     // Extract the location name from the JSON data
//                     final String locationName =
//                         jsonResponse['data']['generalName'];

//                     print('Hi there Pickup locname is : $locationName');
//                     return locationName;
//                   } else {
//                     // Handle the case where the response is not successful
//                     print('Error: ${jsonResponse['message']}');
//                     return null;
//                   }
//                 } else {
//                   // Handle the case where the HTTP request fails
//                   print('Failed to load data: ${response.statusCode}');
//                   return null;
//                 }
//               } catch (e) {
//                 // Handle any exceptions that occur during the request
//                 print('Exception caught: $e');
//                 return null;
//               }
//             }

//             // Create a list of LatLng coordinates
//             List<LatLng> markerCoordinates = [
//               LatLng(
//                 double.parse(_currentLocation!.latitude!.toStringAsFixed(6)),
//                 double.parse(_currentLocation!.longitude!.toStringAsFixed(6)),
//               ),

//               LatLng(
//                   destination.latitude ?? 0.00, destination.longitude ?? 0.00),

//               // Add more coordinates as needed
//             ];

// // Create a list of GalliMarkerOptions using the LatLng coordinates
//             List<SymbolOptions> markerOptionsList =
//                 markerCoordinates.map((LatLng latLng) {
//               return SymbolOptions(
//                 geometry: latLng,
//                 iconAnchor: 'center',
//                 iconSize: 0.5,
//                 iconHaloBlur: 10,
//                 iconHaloWidth: 2,
//                 iconOpacity: 0.9,
//                 iconOffset: Offset(0, 0.8),
//                 iconColor: '#0077FF',
//                 iconHaloColor: '#FFFFFF',
//                 iconImage: 'images/bank.png',
//                 draggable: true,
//               );
//             }).toList();

//             await controller!.addSymbol(markerOptionsList as SymbolOptions);

// // Example usage
//             fetchLocationName();
//             fetchPickupLocationName();
//           }
//         }
//       }
//     } catch (e) {
//       print('Error fetching routes: $e');
//     }
//   }

//   void _handleSearch(String query) {
//     setState(() {
//       _searchQuery = query;
//     });
//     showPopup();
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:galli_vector_package/galli_vector_package.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:final_menu/models/api.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? controller;
  Line? _selectedLine;
  Symbol? _selectedSymbol;
  Symbol? _selectedSymbol1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  GalliMethods methods = GalliMethods("1b040d87-2d67-47d5-aa97-f8b47d301fec");
  List<Symbol> markers = [];
  late void Function() clearMarkers;
  LocationData? _currentLocation;
  ApiModels apimodels = ApiModels();
  final List<Line> _routeLines = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchLocation();
    _searchController.addListener(updateLiveText);
  }

  @override
  void dispose() {
    _searchController.removeListener(updateLiveText);
    _searchController.dispose();
    super.dispose();
  }

  void updateLiveText() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  Future<void> _fetchLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: Colors.transparent,
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: GalliMap(
                    showThree60Widget: false,
                    showSearchWidget: false,
                    doubleClickZoomEnabled: true,
                    dragEnabled: true,
                    showCurrentLocation: true,
                    showCurrentLocationButton: true,
                    authToken: "1b040d87-2d67-47d5-aa97-f8b47d301fec",
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
                      setState(() {});
                    },
                    onMapClick: (LatLng latLng) {},
                    onMapLongPress: (LatLng latlng) {},
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 35,
                              left: 20,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_outlined,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 35),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.78,
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter Location";
                                    }
                                    return null; // Return null if validation passes
                                  },
                                  onFieldSubmitted: _handleSearch,

                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    // Add a hint text
                                    hintText: 'Full Location',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    // Add a prefix icon (e.g., a search icon)
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.blue[700],
                                      size: 24,
                                    ),
                                    // Add a border with rounded corners
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color: Colors.blue[700]!,
                                        width: 2.0,
                                      ),
                                    ),
                                    // Customize the focused border
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color: Colors.blue[700]!,
                                        width: 2.0,
                                      ),
                                    ),
                                    // Customize the enabled border
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey[400]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    // Add a filled background color
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        200, 255, 255, 255),
                                    // Add a suffix icon (e.g., a clear button)
                                    suffixIcon:
                                        _searchController.text.trim().isNotEmpty
                                            ? IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.grey[600],
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  setState(() {});
                                                },
                                              )
                                            : null,
                                    // Add padding inside the TextField
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 5.0,
                                      horizontal: 20.0,
                                    ),
                                  ),
                                  // Customize the text style
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // Add cursor customization
                                  cursorColor: Colors.blue[700],
                                  cursorWidth: 2.0,
                                  cursorRadius: Radius.circular(2.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_searchQuery.isNotEmpty)
                        Positioned(
                          bottom: 50.0,
                          left: 16.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: const Color.fromARGB(235, 80, 91, 247),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    _searchQuery,
                                    style: GoogleFonts.outfit(
                                        fontSize: 16.0, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showPopup() {
    if (_searchController.text.isEmpty) {
      Dialog(
        elevation: 1,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Please Enter Proper Location',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              Center(
                child: Text(
                  'No Proper Location is Found',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }
    print('Search Data is :${_searchController.text}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 1,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Results',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                        fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: apimodels.getLocation(
                        double.parse(
                            _currentLocation!.latitude!.toStringAsFixed(6)),
                        double.parse(
                            _currentLocation!.longitude!.toStringAsFixed(6)),
                        _searchController.text.trim(),
                        "1b040d87-2d67-47d5-aa97-f8b47d301fec"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error fetching data.'));
                      } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                        return Center(child: Text('Enter Proper Location.'));
                      } else {
                        List<dynamic> searchData = snapshot.data;
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: searchData.length,
                          itemBuilder: (context, index) {
                            var myData = snapshot.data[index];
                            return GestureDetector(
                              onTap: () async {
                                var coordinates = await getLocationCoordinates(
                                    double.parse(_currentLocation!.latitude!
                                        .toStringAsFixed(6)),
                                    double.parse(_currentLocation!.longitude!
                                        .toStringAsFixed(6)),
                                    // _searchController.text.trim(),
                                    myData['name'],
                                    myData['province'],
                                    myData['district'],
                                    myData['municipality'],
                                    myData['ward'],
                                    "1b040d87-2d67-47d5-aa97-f8b47d301fec");
                                if (coordinates != null) {
                                  await clearRoutes(); // Clear existing routes
                                  await drawRoute(
                                      coordinates); // Draw new route
                                  Navigator.of(context).pop(); // Close dialog

                                  // Fetch and print pickup and delivery location names
                                  await fetchPickupLocationName();
                                  await fetchLocationName(coordinates);
                                }
                              },
                              child: Card(
                                elevation: 1,
                                margin: EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 0),
                                child: ListTile(
                                  hoverColor: Colors.grey[200],
                                  selectedTileColor: Colors.green[100],
                                  title: Text(
                                    myData['name'],
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.outfit(
                                        fontSize: 15, letterSpacing: 0.1),
                                  ),
                                  subtitle: Text(
                                    '${myData['district']}, ${myData['province']}',
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.lexend(
                                      letterSpacing: 0.1,
                                      fontSize: 10,
                                    ),
                                  ),
                                  leading: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.black54,
                                        size: 14,
                                      ),
                                      Text(
                                        '${myData['distance']} km',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: (double.parse(
                                                        myData['distance'])) <=
                                                    20
                                                ? Colors.green[600]
                                                : double.parse(myData[
                                                            'distance']) >
                                                        50
                                                    ? Colors.red[300]
                                                    : Colors.orangeAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<LatLng?> getLocationCoordinates(
      double currentLat,
      double currentLng,
      String locationName,
      String province,
      String district,
      String municipality,
      String ward,
      String authToken) async {
    String url = 'https://route-init.gallimap.com/api/v1/search/currentLocation'
        '?accessToken=$authToken'
        '&name=$locationName'
        '&currentLat=$currentLat'
        '&currentLng=$currentLng';

    try {
      var response = await http
          .get(Uri.parse(url), headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var features = jsonData['data']['features'];
        if (features != null && features.isNotEmpty) {
          var coordinates = features[0]['geometry']['coordinates'];
          return LatLng(coordinates[1], coordinates[0]);
        }
      }
    } catch (e) {
      print('Error fetching location coordinates: $e');

      var response = await http
          .get(Uri.parse(url), headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var features = jsonData['data']['features'];
        if (features != null && features.isNotEmpty) {
          // var coordinates = features[0]['geometry']['coordinates'];
          // return LatLng(coordinates[1], coordinates[0]);

          for (var feature in features) {
            var properties = feature['properties'];

            // Check if all criteria match
            if (properties['province'] == province &&
                properties['district'] == district &&
                properties['municipality'] == municipality &&
                properties['ward'] == ward) {
              // Return coordinates of the matched location
              // var coordinates = feature['geometry']['coordinates'];
              // return LatLng(coordinates[1], coordinates[0]);

              var geometry = feature['geometry'];
              if (geometry != null && geometry['coordinates'] != null) {
                var coordinates = geometry['coordinates'];
                if (coordinates.length >= 2) {
                  // Ensure there are at least two elements
                  return LatLng(coordinates[1], coordinates[0]);
                }
              }
            }

            if (feature['geometry']['type'] == 'Polygon') {
              var polygonCoordinates = feature['geometry']['coordinates'];
              if (polygonCoordinates.isNotEmpty) {
                var firstCoordinates = polygonCoordinates[0]
                    [0]; // Assuming the first set of coordinates
                return LatLng(firstCoordinates[1], firstCoordinates[0]);
              }
            }
          }
        }
      }
    }
    return null;
  }

  Future<void> drawRoute(LatLng destination) async {
    if (controller == null || _currentLocation == null) return;

    String url =
        'https://route-init.gallimap.com/api/v1/routing?mode=driving&srcLat=${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}&srcLng=${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}&dstLat=${destination.latitude}&dstLng=${destination.longitude}&accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec';

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
              lineColor: "#5a7dff",
              lineWidth: 4.0,
              lineOpacity: 0.5,
              draggable: false,
              lineJoin: 'round',
              lineGapWidth: 2,
              lineBlur: 3,
              lineOffset: 2,
            ));
          }

          // Clear existing routes before drawing new ones
          await clearRoutes();

          // Add new routes and store them in _routeLines
          for (var options in lineOptionsList) {
            var line = await controller!.addLine(options);
            _routeLines.add(line);
          }

          // Add markers for pickup and delivery locations
          List<LatLng> markerCoordinates = [
            LatLng(
              double.parse(_currentLocation!.latitude!.toStringAsFixed(6)),
              double.parse(_currentLocation!.longitude!.toStringAsFixed(6)),
            ),
            LatLng(destination.latitude ?? 0.00, destination.longitude ?? 0.00),
          ];

          //  List<SymbolOptions> markerOptionsList =
          //             markerCoordinates.map((LatLng latLng) {
          //           return SymbolOptions(
          //             geometry: latLng,
          //             iconAnchor: 'center',
          //             iconSize: 0.5,
          //             iconHaloBlur: 10,
          //             iconHaloWidth: 2,
          //             iconOpacity: 0.9,
          //             iconOffset: Offset(0, 0.8),
          //             iconColor: '#0077FF',
          //             iconHaloColor: '#FFFFFF',
          //             iconImage: 'images/bank.jpg',
          //             draggable: true,
          //           );
          //         }).toList();

          //start

          // void _addMarker(LatLng point) {
          //   if (_selectedSymbol != null) {
          //     controller!.addSymbol(SymbolOptions(
          //       geometry: point,
          //       iconAnchor: 'center ',
          //       iconSize: 0.3,
          //       iconHaloBlur: 10,
          //       iconHaloWidth: 2,
          //       iconOpacity: 1,
          //       iconOffset: Offset(0, 0.8),
          //       iconColor: '#0077FF',
          //       iconHaloColor: '#FFFFFF',
          //       iconImage: 'images/pickup.png',
          //       draggable: false,
          //     ));
          //   }
          // }

          Future<void> addGalliMarker(LatLng point) async {
            if (_selectedSymbol == null && controller != null) {
              _selectedSymbol = await controller!.addSymbol(SymbolOptions(
                geometry: point,
                iconAnchor: 'center ',
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
            }
          }

          addGalliMarker(LatLng(_currentLocation!.latitude ?? 27.24444,
              _currentLocation!.longitude ?? 84.332));

          // void _addMarker1(LatLng point) {
          //   if (_selectedSymbol != null) {
          //     controller!.addSymbol(SymbolOptions(
          // geometry: point,
          // iconAnchor: 'center ',
          // iconSize: 0.2,
          // iconHaloBlur: 10,
          // iconHaloWidth: 2,
          // iconOpacity: 0.95,
          // iconOffset: Offset(0, 0.8),
          // iconColor: '#0077FF',
          // iconHaloColor: '#FFFFFF',
          // iconImage: 'images/destination.png',
          // draggable: false,
          //     ));
          //   }
          // }

          Future<void> addGalliMarker1(LatLng point) async {
            if (_selectedSymbol1 == null && controller != null) {
              _selectedSymbol1 = await controller!.addSymbol(SymbolOptions(
                geometry: point,
                iconAnchor: 'center ',
                iconSize: 0.2,
                iconHaloBlur: 10,
                iconHaloWidth: 2,
                iconOpacity: 0.85,
                iconOffset: Offset(0, 0.8),
                iconColor: '#0077FF',
                iconHaloColor: '#FFFFFF',
                iconImage: 'images/destination.png',
                draggable: false,
              ));
            }
          }

          addGalliMarker1(LatLng(destination.latitude, destination.longitude));

          //end

          // await controller!.addSymbol(markerOptionsList as SymbolOptions);
        }
      }
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  Future<void> fetchLocationName(LatLng destination) async {
    final String destinationnameURL =
        "https://route-init.gallimap.com/api/v1/reverse/generalReverse?accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec&lat=${destination.latitude}&lng=${destination.longitude}";

    try {
      final response = await http.get(Uri.parse(destinationnameURL));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final String locationName = jsonResponse['data']['generalName'];
          print('Hi there Delivery locname is : $locationName');
        } else {
          print('Error: ${jsonResponse['message']}');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Future<void> fetchPickupLocationName() async {
    final String pickupnameURL =
        "https://route-init.gallimap.com/api/v1/reverse/generalReverse?accessToken=1b040d87-2d67-47d5-aa97-f8b47d301fec&lat=${double.parse(_currentLocation!.latitude!.toStringAsFixed(6))}&lng=${double.parse(_currentLocation!.longitude!.toStringAsFixed(6))}";

    try {
      final response = await http.get(Uri.parse(pickupnameURL));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final String locationName = jsonResponse['data']['generalName'];
          print('Hi there Pickup locname is : $locationName');
        } else {
          print('Error: ${jsonResponse['message']}');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  void _handleSearch(String query) {
    setState(() {
      if (_formKey.currentState!.validate()) {
        _searchQuery = query;
      } else {
        // Validation failed, do not submit
        print("Validation failed");
        // Optionally show an error message or take other actions
      }
    });
    showPopup();
  }

  Future<void> clearRoutes() async {
    if (controller != null && _routeLines.isNotEmpty) {
      for (var line in _routeLines) {
        await controller!.removeLine(line);
      }
      _routeLines.clear(); // Clear the list of route lines

      Future<void> removeGalliMarker() async {
        if (_selectedSymbol != null && controller != null) {
          await controller!.removeSymbol(_selectedSymbol!);
          _selectedSymbol = null; // Reset selected marker after removal
        }
      }

      Future<void> removeGalliMarker1() async {
        if (_selectedSymbol1 != null && controller != null) {
          await controller!.removeSymbol(_selectedSymbol1!);
          _selectedSymbol1 = null; // Reset selected marker after removal
        }
      }

      removeGalliMarker();
      removeGalliMarker1();
    }
  }
}
