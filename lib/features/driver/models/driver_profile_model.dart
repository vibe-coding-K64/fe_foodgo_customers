import 'package:cloud_firestore/cloud_firestore.dart';

/// Model thong tin tai xe, dong bo tu Firebase Firestore.
///
/// Cac truong cua Firestore:
/// - id          : ID document tu Firestore (trung voi userId cua tai xe)
/// - vehiclePlate: Bien so xe may
/// - vehicleType : Loai xe (VD: Honda Wave Alpha)
/// - isActive    : Trang thai san sang nhan don (true = dang hoat dong)
/// - currentLat   : Vi tri GPS - Latitude (co the null khi khong hoat dong)
/// - currentLng   : Vi tri GPS - Longitude (co the null khi khong hoat dong)
/// - rating      : Diem danh gia trung binh cua tai xe
/// - totalTrips   : Tong so chuyen giao hang da hoan thanh
class DriverProfileModel {
  final String id;
  final String vehiclePlate;
  final String vehicleType;
  final bool isActive;
  final double? currentLat;
  final double? currentLng;
  final double rating;
  final int totalTrips;

  const DriverProfileModel({
    required this.id,
    required this.vehiclePlate,
    required this.vehicleType,
    required this.isActive,
    this.currentLat,
    this.currentLng,
    required this.rating,
    required this.totalTrips,
  });

  /// Tao DriverProfileModel tu DocumentSnapshot cua Firestore.
  factory DriverProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverProfileModel(
      id: doc.id,
      vehiclePlate: (data['vehiclePlate'] as String?) ?? '',
      vehicleType: (data['vehicleType'] as String?) ?? '',
      isActive: (data['isActive'] as bool?) ?? false,
      currentLat: (data['currentLat'] as num?)?.toDouble(),
      currentLng: (data['currentLng'] as num?)?.toDouble(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: (data['totalTrips'] as int?) ?? 0,
    );
  }

  /// Chuyen doi thanh Map de ghi vao Firestore.
  Map<String, dynamic> toMap() {
    return {
      'vehiclePlate': vehiclePlate,
      'vehicleType': vehicleType,
      'isActive': isActive,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'rating': rating,
      'totalTrips': totalTrips,
    };
  }

  DriverProfileModel copyWith({
    String? id,
    String? vehiclePlate,
    String? vehicleType,
    bool? isActive,
    double? currentLat,
    double? currentLng,
    double? rating,
    int? totalTrips,
  }) {
    return DriverProfileModel(
      id: id ?? this.id,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      isActive: isActive ?? this.isActive,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
    );
  }
}
