// import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
// import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
// import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
// import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
// import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
// import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
// import 'package:flutter/material.dart';

// class BottomNavBarPage extends StatefulWidget {
//   final String driverEmail;

//   BottomNavBarPage({required this.driverEmail});

//   @override
//   _BottomNavBarPageState createState() => _BottomNavBarPageState();
// }

// class _BottomNavBarPageState extends State<BottomNavBarPage> {
//   int _selectedIndex = 0;
//   late final List<Widget> _pages;

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
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: FluidNavBar(
//         icons: [
//           FluidNavBarIcon(icon: Icons.home),
//           FluidNavBarIcon(icon: Icons.check_circle),
//           FluidNavBarIcon(icon: Icons.filter_alt),
//           FluidNavBarIcon(icon: Icons.history),
//           FluidNavBarIcon(icon: Icons.chat),
//         ],
//         onChange: _onItemTapped,
//         style: FluidNavBarStyle(
//           iconBackgroundColor: Colors.transparent,
//           iconSelectedForegroundColor: Colors.teal,
//           iconUnselectedForegroundColor: Colors.white,
//           barBackgroundColor: Colors.teal,
//         ),
//         scaleFactor: 1.5, // Adjust the scale factor for floating effect
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
import 'package:final_menu/driver_chat_page/driver_chat_page.dart';

class BottomNavBarPage extends StatefulWidget {
  final String driverEmail;

  BottomNavBarPage({required this.driverEmail});

  @override
  _BottomNavBarPageState createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends State<BottomNavBarPage> with SingleTickerProviderStateMixin {
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
    _controller.forward(from: 0); // Restart the animation when a new item is tapped
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildCustomBottomNavBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simulate refresh
        },
        child: Icon(Icons.refresh,color: Colors.white,),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context) {
  // Use MediaQuery to make the layout responsive
  double iconSize = MediaQuery.of(context).size.width * 0.07; // Responsive icon size
  double labelSize = MediaQuery.of(context).size.width * 0.03; // Responsive label size

  return Column(
    mainAxisSize: MainAxisSize.min, // Ensures the bottom nav bar takes minimal space
    children: [
      Divider( // Thin grey line
        color: Colors.grey,
        height: 1,
        thickness: 0.2,
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.home, 'Home', 0, iconSize, labelSize),
            _buildNavBarItem(Icons.check_circle, 'Accepted', 1, iconSize, labelSize),
            _buildNavBarItem(Icons.filter_alt, 'Filter', 2, iconSize, labelSize),
            _buildNavBarItem(Icons.history, 'Trips', 3, iconSize, labelSize),
            _buildNavBarItem(Icons.chat, 'Chat', 4, iconSize, labelSize),
          ],
        ),
      ),
    ],
  );
}


  Widget _buildNavBarItem(IconData icon, String label, int index, double iconSize, double labelSize) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
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
              color: isSelected ? Colors.teal : Colors.grey,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              color: isSelected ? Colors.teal : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
