// import 'package:flutter/material.dart';
// import 'package:galli_vector_package/galli_vector_package.dart';

// class BookingOptions extends StatefulWidget {
//   const BookingOptions({super.key});

//   @override
//   State<BookingOptions> createState() => _BookingOptionsState();
// }

// class _BookingOptionsState extends State<BookingOptions> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Scaffold(
//             body: SingleChildScrollView(
//       child: Column(
//         children: [
//           GalliMap(
//               scrollGestureEnabled: true,
//               doubleClickZoomEnabled: true,
//               zoomGestureEnabled: true,
//               tiltGestureEnabled: true,
//               rotateGestureEnabled: true,

//               size: (height: 500, width: double.infinity),
//               authToken: '1b040d87-2d67-47d5-aa97-f8b47d301fec'),
//           Container(
//             height: MediaQuery.of(context).size.height,
//             color: Colors.teal,
//             width: double.infinity,
//           ),
//         ],
//       ),
//     )));
//   }
// }

import 'package:final_menu/api_service.dart';
import 'package:flutter/material.dart';
import 'package:galli_vector_package/galli_vector_package.dart';

class BookingOptions extends StatefulWidget {
  const BookingOptions({super.key});

  @override
  State<BookingOptions> createState() => _BookingOptionsState();
}

class _BookingOptionsState extends State<BookingOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Map Section (Interactive and Gesture-Controlled)
          SizedBox(
            height: 500, // Fixed height for the map
            child: Listener(
              onPointerMove: (_) {
                // Absorb pointer events to prevent parent scrolling
              },
              child: GalliMap(
                scrollGestureEnabled: true,
                doubleClickZoomEnabled: true,
                zoomGestureEnabled: true,
                tiltGestureEnabled: true,
                rotateGestureEnabled: true,
                size: (height: 500, width: double.infinity),
                authToken: '1b040d87-2d67-47d5-aa97-f8b47d301fec',
              ),
            ),
          ),
          // Page Content Section (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.teal,
                width: double.infinity,
                child: Column(
                  children: List.generate(
                    20,
                    (index) => ListTile(
                      title: Text('Item $index'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
