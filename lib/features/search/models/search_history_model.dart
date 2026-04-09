import 'package:cloud_firestore/cloud_firestore.dart';

/// Model lich su tim kiem cua khach hang, dong bo tu Firebase Firestore.
///
/// Cac truong cua Firestore:
/// - id        : ID document tu Firestore
/// - keyword    : Tu khoa tim kiem
/// - createdAt : Thoi gian tao/tao lai lich su
class SearchHistoryModel {
  final String id;
  final String keyword;
  final DateTime createdAt;

  SearchHistoryModel({
    required this.id,
    required this.keyword,
    required this.createdAt,
  });

  /// Tao SearchHistoryModel tu DocumentSnapshot cua Firestore.
  ///
  /// Xu ly ep kieu an toan cho createdAt:
  /// - Neu la Timestamp thi chuyen sang DateTime.
  /// - Neu la String thi parse tu ISO8601.
  /// - Neu khong co hoac null thi lay thoi gian hien tai.
  factory SearchHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parsedCreatedAt;
    final createdAtField = data['createdAt'];

    if (createdAtField is Timestamp) {
      parsedCreatedAt = createdAtField.toDate();
    } else if (createdAtField is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return SearchHistoryModel(
      id: doc.id,
      keyword: (data['keyword'] as String?) ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  /// Chuyen SearchHistoryModel thanh Map de ghi xuong Firestore.
  Map<String, dynamic> toMap() {
    return {
      'keyword': keyword,
      'createdAt': createdAt,
    };
  }

  SearchHistoryModel copyWith({
    String? id,
    String? keyword,
    DateTime? createdAt,
  }) {
    return SearchHistoryModel(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
