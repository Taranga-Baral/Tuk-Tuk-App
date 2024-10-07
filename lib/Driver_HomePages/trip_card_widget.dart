// // lib/driver_home_page/trip_card_widget.dart
// import 'package:flutter/material.dart';
// import 'trip_model.dart';

// class TripCardWidget extends StatelessWidget {
//   final TripModel tripData;
//   final int index; // Add this line to include index
//   final VoidCallback onPhoneTap;
//   final VoidCallback onMapTap;
//   final VoidCallback onRequestTap;

//   const TripCardWidget({
//     Key? key,
//     required this.tripData,
//     required this.index, // Accept index as a parameter
//     required this.onPhoneTap,
//     required this.onMapTap,
//     required this.onRequestTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool _isButtonDisabled = false; // To track if the button should be disabled

//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${index + 1}.  ${tripData.username}  -  ${tripData.noofPerson} Passenger  -  ${tripData.vehicleMode}', // Add index + 1
//               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
//             ),
//             Divider(),
//             Text('Pickup Location: ${tripData.pickupLocation}'),
//             Divider(),
//             Text('Delivery Location: ${tripData.deliveryLocation}'),
//             Divider(),
//             Text('Municipality: ${tripData.municipalityDropdown}'),
//             Divider(),
//             Text('Fare: ${tripData.fare}'),
//             Divider(),
//             Text('Distance: ${tripData.distance}'),
//             Divider(),
//             Text('Timestamp: ${tripData.timestamp}'),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.phone),
//                   onPressed: onPhoneTap,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.map),
//                   onPressed: onMapTap,
//                 ),
//                 TextButton(
//   // ignore: dead_code
//   onPressed: _isButtonDisabled ? null : () {
//     onRequestTap;
//   },
//   style: TextButton.styleFrom(
//     // ignore: dead_code
//     backgroundColor: _isButtonDisabled ? Colors.grey : Colors.blue, // Change color based on state
//     // Other styling...
//   ),
//   child: const Text('Send'),
// ),

//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/driver_home_page/trip_card_widget.dart
import 'package:flutter/material.dart';
import 'trip_model.dart';

class TripCardWidget extends StatelessWidget {
  final TripModel tripData;
  final int index;
  final VoidCallback onPhoneTap;
  final VoidCallback onMapTap;
  final VoidCallback onRequestTap;
  final bool isButtonDisabled; // Add this line

  const TripCardWidget({
    Key? key,
    required this.tripData,
    required this.index,
    required this.onPhoneTap,
    required this.onMapTap,
    required this.onRequestTap,
    required this.isButtonDisabled, // Accept disabled state as a parameter
  }) : super(key: key);

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
              '${index + 1}.  ${tripData.username}  -  ${tripData.noofPerson} Passenger  -  ${tripData.vehicleMode}',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            Divider(),
            Text('Pickup Location: ${tripData.pickupLocation}'),
            Divider(),
            Text('Delivery Location: ${tripData.deliveryLocation}'),
            Divider(),
            Text('Municipality: ${tripData.municipalityDropdown}'),
            Divider(),
            Text('Fare: ${tripData.fare}'),
            Divider(),
            Text('Distance: ${tripData.distance}'),
            Divider(),
            Text('Timestamp: ${tripData.timestamp}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isButtonDisabled
                        ? null
                        : () {
                            onRequestTap();
                          },
                    color: isButtonDisabled ? Colors.grey : Colors.blue),
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: onPhoneTap,
                ),
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: onMapTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
