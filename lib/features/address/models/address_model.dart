import 'package:cloud_firestore/cloud_firestore.dart';

/// Model dia chi nguoi dung, tuong thich voi API response `/api/addresses`.
///
/// Cac truong tu API response:
/// - id            : ID document do backend tao (VD: "addr_001")
/// - userId        : ID nguoi dung so huu dia chi
/// - name          : Nhan dia chi (VD: "Nha rieng", "Cong ty")
/// - address       : Dia chi chi tiet day du (VD: "123 Nguyen Hue, Quan 1, TP.HCM")
/// - receiverName  : Ho ten nguoi nhan (bat buoc)
/// - receiverPhone : So dien thoai nguoi nhan (bat buoc)
/// - lat           : Vi do (latitude)
/// - lng           : Kinh do (longitude)
/// - isDefault     : La dia chi mac dinh hay khong
/// - createdAt     : Thoi diem tao (ISO8601 String)
/// - updatedAt     : Thoi diem cap nhat gan nhat (ISO8601 String)
/// - deletedAt     : Thoi diem xoa (neu co soft delete, nullable)
class AddressModel {
  final String id;
  final String userId;
  final String name;
  final String address;
  final String receiverName;
  final String receiverPhone;
  final double? lat;
  final double? lng;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.receiverName,
    required this.receiverPhone,
    this.lat,
    this.lng,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Tao AddressModel tu JSON cua API response.
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'] as String)
          : null,
    );
  }

  /// Tao AddressModel tu Firestore document.
  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AddressModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      receiverName: data['receiverName'] as String? ?? '',
      receiverPhone: data['receiverPhone'] as String? ?? '',
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      deletedAt: _parseTimestamp(data['deletedAt']),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Chuyen AddressModel thanh Map de gui len API (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'userId': userId,
      'name': name,
      'address': address,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    String? receiverName,
    String? receiverPhone,
    double? lat,
    double? lng,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
