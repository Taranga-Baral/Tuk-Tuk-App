import 'package:final_menu/driver_accepted_page/driver_accepted_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Color appBarColor;
  final List<IconData> appBarIcons;
  final String title;
  final String driverId;

  const CustomAppBar({
    Key? key,
    required this.appBarColor,
    required this.appBarIcons,
    required this.title,
    required this.driverId,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late Future<DocumentSnapshot> _driverInfoFuture;

  @override
  void initState() {
    super.initState();
    _fetchDriverInfo(); // Fetch driver info on init
  }

  void _fetchDriverInfo() {
    _driverInfoFuture = FirebaseFirestore.instance
        .collection('vehicleData')
        .doc(widget.driverId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.appBarColor,
      title: Text(
        widget.title,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(widget.appBarIcons[1], color: Colors.white),
          onPressed: () {
            // Show driver info in a dialog
            _showDriverInfoDialog(context);
          },
        ),
      ],
      leading: IconButton(
        icon: Icon(widget.appBarIcons[0], color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _refreshData() {
    // Re-fetch driver info and call setState to refresh UI
    setState(() {
      _fetchDriverInfo();
    });
  }

  // Method to show the driver info in a dialog
  void _showDriverInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<DocumentSnapshot>(
          future: _driverInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.data!.exists) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Driver information not found.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text(
                  'Driver Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.appBarColor,
                  ),
                ),
                content: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              data['profilePictureUrl'] ?? '',
                            ),
                          ),
                          Divider(thickness: 2,color: Colors.grey,),
                          Text(
                            data['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.appBarColor,
                            ),
                          ),
                          Divider(),
                          Text(
                            'Address: ${data['address'] ?? 'Unknown Address'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Divider(),
                          Text(
                            'Number Plate: ${data['numberPlate'] ?? 'Unknown'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Divider(),
                          Text(
                            'Vehicle: ${data['vehicleType'] ?? 'Unknown'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Divider(),
                          Text(
                            'Phone: ${data['phone'] ?? 'Unknown'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}
