import 'package:cloud_firestore/cloud_firestore.dart';

/// Model voucher cua nguoi dung (da doi / da nhan).
///
/// Su dung cho sub-collection `users/{userId}/my_vouchers`.
class MyVoucherModel {
  final String id;
  final String name;
  final String code;
  final String description;
  final DateTime expiryDate;
  final double discountValue;
  final bool isPercentage;
  final double minOrderValue;

  const MyVoucherModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.expiryDate,
    required this.discountValue,
    required this.isPercentage,
    required this.minOrderValue,
  });

  /// Khoi tao tu Firestore document.
  factory MyVoucherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parsedDate;
    final rawDate = data['expiryDate'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      parsedDate = DateTime.now();
    }

    return MyVoucherModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '',
      description: data['description'] as String? ?? '',
      expiryDate: parsedDate,
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0.0,
      isPercentage: data['isPercentage'] as bool? ?? false,
      minOrderValue: (data['minOrderValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Kiem tra voucher con han su dung hay khong.
  bool get isValid => expiryDate.isAfter(DateTime.now());

  /// So ngay con lai truoc khi het han.
  int get daysRemaining {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }
}

/// Model voucher co the doi diem tu he thong.
///
/// Su dung cho collection `system_vouchers`.
class SystemVoucherModel {
  final String id;
  final String title;
  final String subtitle;
  final int pointsRequired;
  final String imageUrl;
  final int remaining;
  final String terms;
  final double minOrderValue;

  const SystemVoucherModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pointsRequired,
    required this.imageUrl,
    required this.remaining,
    this.terms = '',
    this.minOrderValue = 0,
  });

  /// Khoi tao tu Firestore document.
  factory SystemVoucherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SystemVoucherModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      pointsRequired: (data['pointsRequired'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      remaining: (data['remaining'] as num?)?.toInt() ?? 0,
      terms: data['terms'] as String? ?? '',
      minOrderValue: (data['minOrderValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Model voucher co the doi diem.
///
/// Su dung cho UI hien thi (RewardsExchangeSection, RewardDetailView).
/// Tao tu [SystemVoucherModel] qua factory constructor.
class ExchangeVoucherModel {
  final String id;
  final String title;
  final String subtitle;
  final int pointsRequired;
  final String imageUrl;
  final int remaining;
  final String terms;
  final double minOrderValue;

  const ExchangeVoucherModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pointsRequired,
    required this.imageUrl,
    required this.remaining,
    this.terms = '',
    this.minOrderValue = 0,
  });

  /// Tao ExchangeVoucherModel tu SystemVoucherModel (de tuong thich voi UI).
  factory ExchangeVoucherModel.fromSystemVoucher(SystemVoucherModel model) {
    return ExchangeVoucherModel(
      id: model.id,
      title: model.title,
      subtitle: model.subtitle,
      pointsRequired: model.pointsRequired,
      imageUrl: model.imageUrl,
      remaining: model.remaining,
      terms: model.terms,
      minOrderValue: model.minOrderValue,
    );
  }
}
