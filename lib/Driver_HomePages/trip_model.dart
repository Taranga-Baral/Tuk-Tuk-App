// lib/driver_home_page/trip_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  String? tripId;
  String? username;
  String? phoneNumber;
  String? pickupLocation;
  String? deliveryLocation;
  String? vehicleMode;
  String? municipalityDropdown;
  int? noofPerson;
  double fare;
  double distance;
  DateTime timestamp;

  TripModel({
    this.tripId,
    this.username,
    this.phoneNumber,
    this.pickupLocation,
    this.deliveryLocation,
    this.municipalityDropdown,
    this.vehicleMode,
    this.noofPerson,
    required this.fare,
    required this.distance,
    required this.timestamp,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      tripId: json['tripId'] as String?,
      username: json['username'] as String?,
      phoneNumber: json['phone'] as String?,
      pickupLocation: json['pickupLocation'] as String?,
      deliveryLocation: json['deliveryLocation'] as String?,
      vehicleMode: json['vehicle_mode'] as String?,
      municipalityDropdown: json['municipalityDropdown'] as String?,
      noofPerson: json['no_of_person'] as int?,
      fare: (json['fare'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
