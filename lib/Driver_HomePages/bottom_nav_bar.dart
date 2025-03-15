// import 'package:flutter/material.dart';
// import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
// import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
// import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
// import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
// import 'package:final_menu/driver_chat_page/driver_chat_page.dart';

// class BottomNavBarPage extends StatefulWidget {
//   final String driverEmail;

//   BottomNavBarPage({required this.driverEmail});

//   @override
//   _BottomNavBarPageState createState() => _BottomNavBarPageState();
// }

// class _BottomNavBarPageState extends State<BottomNavBarPage> with SingleTickerProviderStateMixin {
//   int _selectedIndex = 0;
//   late final List<Widget> _pages;
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       DriverHomePage(driverEmail: widget.driverEmail),
//       DriverAcceptedPage(driverId: widget.driverEmail),
//       DriverFilterPage(driverId: widget.driverEmail),
//       DriverSuccessfulTrips(driverId: widget.driverEmail),
//       DriverChatPage(driverId: widget.driverEmail),
//     ];

//     // Initialize the AnimationController
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     // Create the animation
//     _animation = Tween<double>(begin: 0, end: 10).animate(_controller)
//       ..addListener(() {
//         setState(() {});
//       });
//   }

//   @override
//   void dispose() {
//     // Dispose the controller to avoid memory leaks
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _controller.forward(from: 0); // Restart the animation when a new item is tapped
//   }

//     void _refreshCurrentPage() {

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: _buildCustomBottomNavBar(context),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//                      _refreshCurrentPage();
//         },
//         child: Icon(Icons.refresh,color: Colors.white,),
//         backgroundColor: Colors.redAccent.shade200,
//       ),
//     );
//   }

//   Widget _buildCustomBottomNavBar(BuildContext context) {
//   // double iconSize = MediaQuery.of(context).size.width * 0.07; // Responsive icon size
//   // double labelSize = MediaQuery.of(context).size.width * 0.03; // Responsive label size
//   double iconSize = 18;
//   double labelSize = 18;

//   return Column(
//     mainAxisSize: MainAxisSize.min, // Ensures the bottom nav bar takes minimal space
//     children: [
//       Divider( // Thin grey line
//         color: Colors.grey,
//         height: 1,
//         thickness: 0.2,
//       ),
//       Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavBarItem(Icons.home, 'Home', 0, iconSize, labelSize),
//             _buildNavBarItem(Icons.check_circle, 'Accepted', 1, iconSize, labelSize),
//             _buildNavBarItem(Icons.filter_alt, 'Filter', 2, iconSize, labelSize),
//             _buildNavBarItem(Icons.history, 'Trips', 3, iconSize, labelSize),
//             _buildNavBarItem(Icons.chat, 'Chat', 4, iconSize, labelSize),
//           ],
//         ),
//       ),
//     ],
//   );
// }

//   Widget _buildNavBarItem(IconData icon, String label, int index, double iconSize, double labelSize) {
//     bool isSelected = _selectedIndex == index;
//     return GestureDetector(
//       onTap: () => _onItemTapped(index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [

//           AnimatedContainer(
//             duration: Duration(milliseconds: 200),
//             height: isSelected ? iconSize + 10 : iconSize,
//             width: isSelected ? iconSize + 10 : iconSize,
//             curve: Curves.easeInOut,
//             child: Icon(
//               icon,
//               size: isSelected ? iconSize + 5 : iconSize,
//               color: isSelected ? Colors.redAccent.shade200 : Colors.grey,
//             ),
//           ),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: labelSize,
//               color: isSelected ? Colors.redAccent : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:final_menu/homepage1.dart';
import 'package:flutter/material.dart';
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBarPage extends StatefulWidget {
  final String driverEmail;

  const BottomNavBarPage({super.key, required this.driverEmail});

  @override
  _BottomNavBarPageState createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends State<BottomNavBarPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pages = [
      DriverHomePage(driverEmail: widget.driverEmail),
      DriverAcceptedPage(driverId: widget.driverEmail),
      DriverFilterPage(driverId: widget.driverEmail),
      DriverSuccessfulTrips(driverId: widget.driverEmail),
      DriverChatPage(driverId: widget.driverEmail),
    ];

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create the animation
    _animation = Tween<double>(begin: 0, end: 10).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    // Dispose the controller to avoid memory leaks
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward(
        from: 0); // Restart the animation when a new item is tapped
  }

  void _refreshCurrentPage() {
    if (_pages[_selectedIndex] is RefreshablePage) {
      final RefreshablePage currentPage =
          _pages[_selectedIndex] as RefreshablePage;
      currentPage.refresh(); // Call refresh method of the current page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildCustomBottomNavBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage1()));
        },
        backgroundColor: Colors.redAccent.shade200,
        child: Icon(
          Icons.person_4_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context) {
    double iconSize = 15;
    double labelSize = 12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.2,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // _buildNavBarItem(Icons.home, 'Home', 0, iconSize, labelSize),
              // _buildNavBarItem(
              //     Icons.check_circle, 'Accepted', 1, iconSize, labelSize),
              // _buildNavBarItem(
              //     Icons.filter_alt, 'Filter', 2, iconSize, labelSize),
              // _buildNavBarItem(
              //     Icons.history, 'Success', 3, iconSize, labelSize),
              // _buildNavBarItem(Icons.chat, 'Chat', 4, iconSize, labelSize),

              _buildNavBarItem(
                  Icons.home, 'यात्री खोज', 0, iconSize, labelSize),
              _buildNavBarItem(Icons.check_circle, 'कुरिरहेका/पुरौनु पर्ने', 1,
                  iconSize, labelSize),
              _buildNavBarItem(
                  Icons.filter_alt, 'चाहिएको यात्री', 2, iconSize, labelSize),
              _buildNavBarItem(
                  Icons.history, 'मेरो यात्रा', 3, iconSize, labelSize),
              _buildNavBarItem(
                  Icons.chat, 'यात्री वार्तालाप', 4, iconSize, labelSize),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index,
      double iconSize, double labelSize) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: isSelected ? iconSize + 10 : iconSize,
              width: isSelected ? iconSize + 10 : iconSize,
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                size: isSelected ? iconSize + 5 : iconSize,
                color: isSelected ? Colors.redAccent.shade200 : Colors.grey,
              ),
            ),
            Text(
              label,
              // style: TextStyle(
              //   fontSize: labelSize,
              //   color: isSelected ? Colors.redAccent : Colors.grey,
              // ),
              style: isSelected
                  ? GoogleFonts.ubuntu(
                      fontSize: labelSize + 1,
                      color: isSelected ? Colors.redAccent : Colors.grey)
                  : GoogleFonts.ubuntu(
                      fontSize: labelSize,
                      color: isSelected ? Colors.redAccent : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class RefreshablePage {
  void refresh();
}
