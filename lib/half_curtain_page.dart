// import 'package:flutter/material.dart';


// class HalfCurtainPage extends StatelessWidget {
//   final String username;

//   HalfCurtainPage({required this.username});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.5),
//       body: Align(
//         alignment: Alignment.bottomCenter,
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.5, // Half the screen
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(30),
//               topRight: Radius.circular(30),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 spreadRadius: 5,
//                 blurRadius: 7,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Welcome, $username',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('Close'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
