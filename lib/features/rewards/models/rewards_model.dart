import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model voucher cua nguoi dung (da doi / da nhan).
///
/// Su dung cho sub-collection `customer_profiles/{userId}/my_vouchers`.
class MyVoucherModel {
  final String id;
  final String name;
  final String code;
  final String description;
  final DateTime expiryDate;
  /// Loai giam gia: 1=%, 2=gia (VND).
  final int type;
  /// Gia tri giam (type=1: %; type=2: VND).
  final double value;
  final double minOrderValue;
  /// URL anh voucher.
  final String imageUrl;

  const MyVoucherModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.expiryDate,
    required this.type,
    required this.value,
    required this.minOrderValue,
    this.imageUrl = '',
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
      type: (data['type'] as num?)?.toInt() ?? 1,
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (data['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  /// Kiem tra voucher con han su dung hay khong.
  bool get isValid => expiryDate.isAfter(DateTime.now());

  /// So ngay con lai truoc khi het han.
  int get daysRemaining {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  /// Tra ve text hien thi gia tri giam.
  String get discountText {
    if (type == 1) {
      return '${value.toInt()}%';
    } else {
      return '${value.toInt()}K';
    }
  }
}

/// Model voucher co the doi diem tu he thong.
///
/// Su dung cho collection `system_vouchers`.
class SystemVoucherModel {
  final String id;
  final String title;
  final String subtitle;
  /// Loai giam gia: 1=%, 2=gia (VND).
  final int type;
  /// Gia tri giam (type=1: %; type=2: VND).
  final double value;
  final int pointsRequired;
  final String imageUrl;
  final int remaining;
  final String terms;
  final double minOrderValue;

  const SystemVoucherModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.value,
    required this.pointsRequired,
    required this.imageUrl,
    required this.remaining,
    this.terms = '',
    this.minOrderValue = 0,
  });

  /// Khoi tao tu Firestore document.
  factory SystemVoucherModel.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    if (raw == null) {
      debugPrint('SystemVoucherModel.fromFirestore: doc.data() is null for ${doc.id}');
      return SystemVoucherModel(
        id: doc.id,
        title: '',
        subtitle: '',
        type: 1,
        value: 0,
        pointsRequired: 0,
        imageUrl: '',
        remaining: 0,
      );
    }
    final data = raw as Map<String, dynamic>;

    return SystemVoucherModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      type: (data['type'] as num?)?.toInt() ?? 1,
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      pointsRequired: (data['pointsRequired'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      remaining: (data['remaining'] as num?)?.toInt() ?? 0,
      terms: data['terms'] as String? ?? '',
      minOrderValue: (data['minOrderValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Tra ve text hien thi gia tri giam.
  String get discountText {
    if (type == 1) {
      return '${value.toInt()}%';
    } else {
      return '${value.toInt()}K';
    }
  }
}

/// Model voucher co the doi diem (dung cho UI).
///
/// Tao tu [SystemVoucherModel] qua factory constructor.
class ExchangeVoucherModel {
  final String id;
  final String title;
  final String subtitle;
  /// Loai giam gia: 1=%, 2=gia (VND).
  final int type;
  /// Gia tri giam (type=1: %; type=2: VND).
  final double value;
  final int pointsRequired;
  final String imageUrl;
  final int remaining;
  final String terms;
  final double minOrderValue;

  const ExchangeVoucherModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.value,
    required this.pointsRequired,
    required this.imageUrl,
    required this.remaining,
    this.terms = '',
    this.minOrderValue = 0,
  });

  factory ExchangeVoucherModel.fromSystemVoucher(SystemVoucherModel model) {
    return ExchangeVoucherModel(
      id: model.id,
      title: model.title,
      subtitle: model.subtitle,
      type: model.type,
      value: model.value,
      pointsRequired: model.pointsRequired,
      imageUrl: model.imageUrl,
      remaining: model.remaining,
      terms: model.terms,
      minOrderValue: model.minOrderValue,
    );
  }

  /// Tra ve text hien thi gia tri giam.
  String get discountText {
    if (type == 1) {
      return '${value.toInt()}%';
    } else {
      return '${value.toInt()}K';
    }
  }
}
