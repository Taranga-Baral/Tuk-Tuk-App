// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class StatisticsPage extends StatefulWidget {
//   final String userId;

//   const StatisticsPage({super.key, required this.userId});

//   @override
//   _StatisticsPageState createState() => _StatisticsPageState();
// }

// class _StatisticsPageState extends State<StatisticsPage> {
//   double totalFare = 0.0;
//   double totalDistance = 0.0;
//   int totalDeliveryLocations = 0;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _calculateStatistics();
//   }

//   Future<void> _calculateStatistics() async {
//     try {
//       final successfulTripsSnapshot = await FirebaseFirestore.instance
//           .collection('successfulTrips')
//           .where('userId', isEqualTo: widget.userId)
//           .get();

//       List<String> tripIds = [];
//       for (var doc in successfulTripsSnapshot.docs) {
//         final data = doc.data();
//         final tripId = data['tripId'] as String?;
//         if (tripId != null && tripId.isNotEmpty) {
//           tripIds.add(tripId);
//         }
//       }

//       double fareSum = 0.0;
//       double distanceSum = 0.0;

//       if (tripIds.isNotEmpty) {
//         final tripsSnapshot = await FirebaseFirestore.instance
//             .collection('trips')
//             .where(FieldPath.documentId, whereIn: tripIds)
//             .get();

//         for (var doc in tripsSnapshot.docs) {
//           final data = doc.data();
//           final fare = data['fare'] as String?;
//           final distance = data['distance'] as String?;

//           if (fare != null && fare.isNotEmpty) {
//             fareSum += double.tryParse(fare) ?? 0.0;
//           }

//           if (distance != null && distance.isNotEmpty) {
//             distanceSum += double.tryParse(distance) ?? 0.0;
//           }
//         }
//       }

//       totalDeliveryLocations = successfulTripsSnapshot.docs.length;

//       setState(() {
//         totalFare = fareSum;
//         totalDistance = distanceSum;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error calculating statistics: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back,color: Colors.white,),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text('Statistics Page',style: GoogleFonts.outfit(color: Colors.white),),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView(
//                       children: [
//                         _buildStatCard(
//                           title: 'भुक्तानी गरिएको कुल भाडा',
//                           value: 'NPR ${totalFare.toStringAsFixed(2)}',
//                           color: Colors.lime,
//                           screenWidth: screenWidth,
//                         ),
//                         SizedBox(height: screenHeight * 0.02), // Adjust height based on screen size
//                         _buildStatCard(
//                           title: 'अनुमानित यात्रा',
//                           value: '${totalDistance.toStringAsFixed(2)} km',
//                           color: Colors.green,
//                           screenWidth: screenWidth,
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//                         _buildStatCard(
//                           title: 'यात्रा संख्या',
//                           value: '$totalDeliveryLocations',
//                           color: Colors.orange,
//                           screenWidth: screenWidth,
//                         ),
//                         SizedBox(height: 50),
//                         SizedBox(
//                           height: screenHeight * 0.3, // Make chart height responsive
//                           child: PieChart(
//                             PieChartData(
//                               sections: [
//                                 _buildPieChartSection(
//                                   title: 'Fare',
//                                   value: totalFare,
//                                   color: Colors.lime,
//                                 ),
//                                 _buildPieChartSection(
//                                   title: 'Distance',
//                                   value: totalDistance,
//                                   color: Colors.green,
//                                 ),
//                                 _buildPieChartSection(
//                                   title: 'Locations',
//                                   value: totalDeliveryLocations.toDouble(),
//                                   color: Colors.orange,
//                                 ),
//                               ],
//                               borderData: FlBorderData(show: false),
//                               sectionsSpace: 0,
//                               centerSpaceRadius: screenWidth * 0.1, // Adjust radius responsively
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required Color color,
//     required double screenWidth,
//   }) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04), // Make padding responsive
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18, // Responsive font size
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18, // Responsive font size
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   PieChartSectionData _buildPieChartSection({
//     required String title,
//     required double value,
//     required Color color,
//   }) {
//     return PieChartSectionData(
//       value: value,
//       color: color,
//       title: value.toStringAsFixed(2),
//       titleStyle: TextStyle(
//         fontSize: 0,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsPage extends StatefulWidget {
  final String userId;

  const StatisticsPage({super.key, required this.userId});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  double totalFare = 0.0;
  double totalDistance = 0.0;
  int totalDeliveryLocations = 0;
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _calculateStatistics();
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  Future<void> _calculateStatistics() async {
    try {
      final successfulTripsSnapshot = await FirebaseFirestore.instance
          .collection('successfulTrips')
          .where('userId', isEqualTo: widget.userId)
          .get();

      List<String> tripIds = [];
      for (var doc in successfulTripsSnapshot.docs) {
        final data = doc.data();
        final tripId = data['tripId'] as String?;
        if (tripId != null && tripId.isNotEmpty) {
          tripIds.add(tripId);
        }
      }

      double fareSum = 0.0;
      double distanceSum = 0.0;

      if (tripIds.isNotEmpty) {
        final tripsSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .where(FieldPath.documentId, whereIn: tripIds)
            .get();

        for (var doc in tripsSnapshot.docs) {
          final data = doc.data();
          final fare = data['fare'] as String?;
          final distance = data['distance'] as String?;

          if (fare != null && fare.isNotEmpty) {
            fareSum += double.tryParse(fare) ?? 0.0;
          }

          if (distance != null && distance.isNotEmpty) {
            distanceSum += double.tryParse(distance) ?? 0.0;
          }
        }
      }

      totalDeliveryLocations = successfulTripsSnapshot.docs.length;

      setState(() {
        totalFare = fareSum;
        totalDistance = distanceSum;
        isLoading = false;
      });
    } catch (e) {
      print('Error calculating statistics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Statistics',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? Center()
          : SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatCard(
                        title: 'कुल खर्चिएको रकम',
                        value: 'रु ${totalFare.toStringAsFixed(2)}',
                        icon: Icons.money,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 16),
                      _buildStatCard(
                        title: 'कुल दूरी',
                        value: '${totalDistance.toStringAsFixed(2)} किमी',
                        icon: Icons.directions_car,
                        color: Colors.deepOrange[700]!,
                      ),
                      SizedBox(height: 16),
                      _buildStatCard(
                        title: 'कुल यात्रा (हरु)',
                        value: '$totalDeliveryLocations',
                        icon: Icons.location_on,
                        color: Colors.black87,
                      ),
                      SizedBox(height: 32),
                      Text(
                        'यात्रा विवरण',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          height: screenHeight * 0.3,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: [
                                    _buildPieChartSection(
                                      value: totalFare,
                                      color: Colors.blueAccent,
                                    ),
                                    _buildPieChartSection(
                                      value: totalDistance,
                                      color: Colors.deepOrange[700]!,
                                    ),
                                    _buildPieChartSection(
                                      value: totalDeliveryLocations.toDouble(),
                                      color: Colors.black,
                                    ),
                                  ],
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 50,
                                  startDegreeOffset:
                                      -90, // Rotate chart for better visual appeal
                                ),
                              ),
                              Image.asset(
                                'assets/logo.png',
                                width: 120,
                                height: 120,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieChartSection({
    required double value,
    required Color color,
  }) {
    return PieChartSectionData(
      value: value,
      color: color,
      title: value.toStringAsFixed(2),
      titleStyle: TextStyle(
        fontSize: 0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      radius: 20,
      badgePositionPercentageOffset: 0.98,
    );
  }
}
