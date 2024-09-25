
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

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
//       // Fetch all trips for the user and calculate fare and distance
//       final tripsSnapshot = await FirebaseFirestore.instance
//           .collection('trips')
//           .where('userId', isEqualTo: widget.userId)
//           .get();

//       double fareSum = 0.0;
//       double distanceSum = 0.0;

//       for (var doc in tripsSnapshot.docs) {
//         final data = doc.data();
//         final fare = data['fare'] as String?;
//         final distance = data['distance'] as String?;

//         if (fare != null && fare.isNotEmpty) {
//           fareSum += double.tryParse(fare) ?? 0.0;
//         }

//         if (distance != null && distance.isNotEmpty) {
//           distanceSum += double.tryParse(distance) ?? 0.0;
//         }
//       }

//       // Fetch successful trips for the user and count delivery locations
//       final successfulTripsSnapshot = await FirebaseFirestore.instance
//           .collection('successfulTrips')
//           .where('userId', isEqualTo: widget.userId)
//           .get();

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
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Statistics Page'),
//         backgroundColor: Colors.lime,
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
//                           title: 'Total Fare Paid',
//                           value: 'NPR ${totalFare.toStringAsFixed(2)}',
//                           color: Colors.lime,
//                         ),
//                         SizedBox(height: 16),
//                         _buildStatCard(
//                           title: 'Total Distance Traveled',
//                           value: '${totalDistance.toStringAsFixed(2)} km',
//                           color: Colors.green,
//                         ),
//                         SizedBox(height: 16),
//                         _buildStatCard(
//                           title: 'Total Locations',
//                           value: '$totalDeliveryLocations',
//                           color: Colors.orange,
//                         ),
//                         SizedBox(height: 16),
//                         SizedBox(
//                           height: 300, // Set height for the chart
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
//                               centerSpaceRadius: 40,
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
//   }) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
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
//         fontSize: 14,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  final String userId;

  const StatisticsPage({super.key, required this.userId});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  double totalFare = 0.0;
  double totalDistance = 0.0;
  int totalDeliveryLocations = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }

  Future<void> _calculateStatistics() async {
    try {
      // Fetch all successful trips for the user
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

      // Fetch all trips for the user's tripIds and calculate fare and distance
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

      // Count delivery locations based on the number of successful trips
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics Page'),
        backgroundColor: Colors.lime,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildStatCard(
                          title: 'भुक्तानी गरिएको कुल भाडा',
                          value: 'NPR ${totalFare.toStringAsFixed(2)}',
                          color: Colors.lime,
                        ),
                        SizedBox(height: 16),
                        _buildStatCard(
                          title: 'अनुमानित यात्रा',
                          value: '${totalDistance.toStringAsFixed(2)} km',
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        _buildStatCard(
                          title: 'यात्रा संख्या',
                          value: '$totalDeliveryLocations',
                          color: Colors.orange,
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 300, // Set height for the chart
                          child: PieChart(
                            PieChartData(
                              sections: [
                                _buildPieChartSection(
                                  title: 'Fare',
                                  value: totalFare,
                                  color: Colors.lime,
                                ),
                                _buildPieChartSection(
                                  title: 'Distance',
                                  value: totalDistance,
                                  color: Colors.green,
                                ),
                                _buildPieChartSection(
                                  title: 'Locations',
                                  value: totalDeliveryLocations.toDouble(),
                                  color: Colors.orange,
                                ),
                              ],
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                            ),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieChartSection({
    required String title,
    required double value,
    required Color color,
  }) {
    return PieChartSectionData(
      value: value,
      color: color,
      title: value.toStringAsFixed(2),
      titleStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
