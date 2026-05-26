import 'package:cloud_firestore/cloud_firestore.dart';

/// Model nguoi dung, dong bo tu Firebase Firestore.
///
/// Cac truong cua Firestore:
/// - id         : ID document tu Firestore
/// - email      : Dia chi email (bat buoc)
/// - fullName   : Ho ten day du
/// - phoneNumber: So dien thoai (bat buoc)
/// - photoUrl   : Duong dan anh dai dien (co the null)
/// - roles      : Danh sach quyen cua nguoi dung (1=Customer, 2=Driver, 9=Admin)
/// - createdAt  : Thoi diem tao tai khoan
/// - updatedAt  : Thoi diem cap nhat gan nhat
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? photoUrl;
  final List<int> roles;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Quyen mac dinh neu khong co truong roles trong Firestore.
  static const List<int> _defaultRoles = [1];

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.photoUrl,
    this.roles = _defaultRoles,
    required this.createdAt,
    this.updatedAt,
  });

  /// Tra ve true neu nguoi dung co quyen khach hang.
  bool get isCustomer => roles.contains(1);

  /// Tra ve true neu nguoi dung co quyen tai xe.
  bool get isDriver => roles.contains(2);

  /// Tra ve true neu nguoi dung co quyen quan tri.
  bool get isAdmin => roles.contains(9);

  /// Tao UserModel tu JSON (API response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesData = json['roles'];
    List<int> parsedRoles;

    if (rolesData is List) {
      parsedRoles = rolesData
          .map((e) => e is int ? e : (e is num ? e.toInt() : 0))
          .where((e) => e != 0)
          .toList();
    } else {
      parsedRoles = List<int>.from(_defaultRoles);
    }

    if (parsedRoles.isEmpty) {
      parsedRoles = List<int>.from(_defaultRoles);
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      roles: parsedRoles,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  /// Tao UserModel tu DocumentSnapshot cua Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rolesData = data['roles'];
    List<int> parsedRoles;

    if (rolesData is List) {
      parsedRoles = rolesData
          .map((e) => e is int ? e : (e is num ? e.toInt() : 0))
          .where((e) => e != 0)
          .toList();
    } else {
      parsedRoles = List<int>.from(_defaultRoles);
    }

    if (parsedRoles.isEmpty) {
      parsedRoles = List<int>.from(_defaultRoles);
    }

    return UserModel(
      id: doc.id,
      email: (data['email'] as String?) ?? '',
      fullName: (data['fullName'] as String?) ?? '',
      phoneNumber: (data['phoneNumber'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      roles: parsedRoles,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'roles': roles,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
    List<int>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
