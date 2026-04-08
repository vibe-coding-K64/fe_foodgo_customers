import 'package:cloud_firestore/cloud_firestore.dart';

/// Model nguoi dung, dong bo tu Firebase Firestore.
///
/// Cac truong cua Firestore:
/// - id        : ID document tu Firestore
/// - email     : Dia chi email (bat buoc)
/// - fullName  : Ho ten day du
/// - phoneNumber: So dien thoai (bat buoc)
/// - photoUrl  : Duong dan anh dai dien (co the null)
/// - createdAt : Thoi diem tao tai khoan
/// - updatedAt : Thoi diem cap nhat gan nhat
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Tao UserModel tu DocumentSnapshot cua Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: (data['email'] as String?) ?? '',
      fullName: (data['fullName'] as String?) ?? '',
      phoneNumber: (data['phoneNumber'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
