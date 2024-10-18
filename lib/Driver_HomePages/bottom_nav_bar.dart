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
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
import 'package:final_menu/driver_chat_page/driver_chat_page.dart';
import 'package:final_menu/driver_filter_trips/driver_filter_page.dart';
import 'package:final_menu/driver_successful_trips/driver_successful_trips.dart';
import 'package:flutter/material.dart';

class BottomNavBarPage extends StatefulWidget {
  final String driverEmail;

  BottomNavBarPage({required this.driverEmail});

  @override
  _BottomNavBarPageState createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends State<BottomNavBarPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to refresh the current page
  void _refreshCurrentPage() {
    // Re-initialize the page to refresh it
    setState(() {
      _pages[_selectedIndex] = _createPage(_selectedIndex);
    });
  }

  Widget _createPage(int index) {
    switch (index) {
      case 0:
        return DriverHomePage(driverEmail: widget.driverEmail);
      case 1:
        return DriverAcceptedPage(driverId: widget.driverEmail);
      case 2:
        return DriverFilterPage(driverId: widget.driverEmail);
      case 3:
        return DriverSuccessfulTrips(driverId: widget.driverEmail);
      case 4:
        return DriverChatPage(driverId: widget.driverEmail);
      default:
        return DriverHomePage(driverEmail: widget.driverEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: FluidNavBar(
        icons: [
          FluidNavBarIcon(icon: Icons.home),
          FluidNavBarIcon(icon: Icons.check_circle),
          FluidNavBarIcon(icon: Icons.filter_alt),
          FluidNavBarIcon(icon: Icons.history),
          FluidNavBarIcon(icon: Icons.chat),
        ],
        onChange: _onItemTapped,
        style: FluidNavBarStyle(
          iconBackgroundColor: Colors.transparent,
          iconSelectedForegroundColor: Colors.teal.shade200,
          iconUnselectedForegroundColor: Colors.white,
          barBackgroundColor: Colors.teal.shade500,

        ),
        scaleFactor: 1.5, // Adjust the scale factor for floating effect
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshCurrentPage,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Align to the left
    );
  }
}
