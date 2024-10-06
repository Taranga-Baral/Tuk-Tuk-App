import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return SliderDrawer(
      slider: _buildDrawer(context, currentUser),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Text('Main Content Here'),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, User? currentUser) {
    return Container(
      color: Colors.blueGrey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Avatar
          Container(
            padding: EdgeInsets.all(16.0),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: currentUser != null && currentUser.photoURL != null
                  ? NetworkImage(currentUser.photoURL!)
                  : null,
              child: currentUser == null || currentUser.photoURL == null
                  ? Text(
  (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty)
    ? currentUser.displayName![0] // Using ! to assert non-null, after check
    : 'U', // Default character if displayName is null or empty
  style: TextStyle(fontSize: 40, color: Colors.blueGrey.shade900),
)

                  : null,
            ),
          ),
          // Drawer Options
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  title: 'Book a Ride',
                  icon: Icons.electric_rickshaw_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/bookRide');
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'View Request',
                  icon: Icons.send,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewRequest');
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'View History',
                  icon: Icons.history,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewHistory');
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'Driver Mode',
                  icon: Icons.electric_rickshaw,
                  onTap: () {
                    Navigator.pushNamed(context, '/driverMode');
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'View Statistics',
                  icon: Icons.show_chart,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewStatistics');
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'Chat with Driver',
                  icon: Icons.chat,
                  onTap: () {
                    Navigator.pushNamed(context, '/chatWithDriver');
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'Additional Info',
                  icon: Icons.info_outline,
                  onTap: () {
                    Navigator.pushNamed(context, '/additionalInfo');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
