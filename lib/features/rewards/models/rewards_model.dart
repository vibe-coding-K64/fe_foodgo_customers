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
    } else if (rawDate is Map) {
      // Firestore Timestamp duoc serialize thanh {epochSecond, nano}.
      // Su dung dynamic cast de phong truong hop gia tri la double.
      final secondsRaw = rawDate['epochSecond'] as dynamic;
      final nanosRaw = rawDate['nano'] as dynamic?;
      final seconds = (secondsRaw is num) ? secondsRaw.toInt() : null;
      final nanos = (nanosRaw is num) ? nanosRaw.toInt() : 0;
      if (seconds != null) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanos ~/ 1000000,
          isUtc: true,
        );
      } else {
        parsedDate = DateTime.now();
      }
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
  bool get isValid {
    final now = DateTime.now();
    final expiry = expiryDate;
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
    return !expiryDay.isBefore(today);
  }

  /// So ngay con lai truoc khi het han.
  int get daysRemaining {
    final now = DateTime.now().toUtc();
    return expiryDate.toUtc().difference(now).inDays;
  }

  /// Tra ve text hien thi gia tri giam.
  String get discountText {
    if (type == 1) {
      return '${value.toInt()}%';
    } else {
      final k = (value / 1000).round();
      return '${k}K';
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

/// Khoi tao tu Firestore document cua collection `vouchers`.
  factory ExchangeVoucherModel.fromVoucher(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExchangeVoucherModel(
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
      final k = (value / 1000).round();
      return '${k}K';
    }
  }
}

// ---------------------------------------------------------------------------
// API Response Models (tu backend server)
// ---------------------------------------------------------------------------

/// Model voucher nhan duoc tu API `/api/vouchers/system`.
/// API tra ve List<SystemVoucherApi>, mapped tu field `data`.
class SystemVoucherApi {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  /// 1=%, 2=gia (VND).
  final int type;
  final double value;
  final String terms;
  final int pointsRequired;
  final int remaining;
  final double minOrderValue;
  final bool isActive;
  final bool coTheDoi;
  final String message;

  const SystemVoucherApi({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    required this.value,
    required this.terms,
    required this.pointsRequired,
    required this.remaining,
    required this.minOrderValue,
    required this.isActive,
    required this.coTheDoi,
    required this.message,
  });

  factory SystemVoucherApi.fromJson(Map<String, dynamic> json) {
    return SystemVoucherApi(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      type: (json['type'] as num?)?.toInt() ?? 1,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      terms: json['terms'] as String? ?? '',
      pointsRequired: (json['pointsRequired'] as num?)?.toInt() ?? 0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      coTheDoi: json['coTheDoi'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  /// Chuyen sang [ExchangeVoucherModel] de dung chung UI.
  ExchangeVoucherModel toExchangeVoucher() {
    return ExchangeVoucherModel(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      type: type,
      value: value,
      pointsRequired: pointsRequired,
      remaining: remaining,
      terms: terms,
      minOrderValue: minOrderValue,
    );
  }
}

/// Data cua voucher sau khi doi thanh cong tu API `/api/vouchers/exchange`.
class ExchangedVoucherData {
  final String myVoucherId;
  final String name;
  final String code;
  final String description;
  /// 1=%, 2=gia (VND).
  final int type;
  final double value;
  final double minOrderValue;
  final DateTime expiryDate;
  final int diemDaDung;
  final int diemConLai;
  final String message;

  const ExchangedVoucherData({
    required this.myVoucherId,
    required this.name,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.minOrderValue,
    required this.expiryDate,
    required this.diemDaDung,
    required this.diemConLai,
    required this.message,
  });

  factory ExchangedVoucherData.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final rawDate = json['expiryDate'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is Map) {
      // Firestore Timestamp serialized.
      final secondsRaw = rawDate['epochSecond'] as dynamic;
      final nanosRaw = rawDate['nano'] as dynamic?;
      final seconds = (secondsRaw is num) ? secondsRaw.toInt() : null;
      final nanos = (nanosRaw is num) ? nanosRaw.toInt() : 0;
      if (seconds != null) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanos ~/ 1000000,
          isUtc: true,
        );
      } else {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return ExchangedVoucherData(
      myVoucherId: json['myVoucherId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: (json['type'] as num?)?.toInt() ?? 1,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      expiryDate: parsedDate,
      diemDaDung: (json['diemDaDung'] as num?)?.toInt() ?? 0,
      diemConLai: (json['diemConLai'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
    );
  }

  /// Tra ve text hien thi gia tri giam.
  String get discountText {
    if (type == 1) {
      return '${value.toInt()}%';
    } else {
      final k = (value / 1000).round();
      return '${k}K';
    }
  }
}

/// Model voucher nhan duoc tu API `/api/vouchers/my-vouchers`.
class MyVoucherApi {
  final String id;
  final String name;
  final String code;
  final String description;
  /// 1=%, 2=gia (VND).
  final int type;
  final double value;
  final double minOrderValue;
  final DateTime expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MyVoucherApi({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.minOrderValue,
    required this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyVoucherApi.fromJson(Map<String, dynamic> json) {
    DateTime parseDateField(dynamic raw) {
      if (raw is String) {
        return DateTime.tryParse(raw) ?? DateTime.now();
      } else if (raw is Map) {
        final secondsRaw = raw['epochSecond'] as dynamic;
        final nanosRaw = raw['nano'] as dynamic?;
        final seconds = (secondsRaw is num) ? secondsRaw.toInt() : null;
        final nanos = (nanosRaw is num) ? nanosRaw.toInt() : 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + nanos ~/ 1000000,
            isUtc: true,
          );
        }
      }
      return DateTime.now();
    }

    return MyVoucherApi(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: (json['type'] as num?)?.toInt() ?? 1,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      expiryDate: parseDateField(json['expiryDate']),
      createdAt: parseDateField(json['createdAt']),
      updatedAt: parseDateField(json['updatedAt']),
    );
  }

  /// Chuyen sang [MyVoucherModel] de dung chung UI.
  MyVoucherModel toMyVoucher() {
    return MyVoucherModel(
      id: id,
      name: name,
      code: code,
      description: description,
      type: type,
      value: value,
      minOrderValue: minOrderValue,
      expiryDate: expiryDate,
    );
  }
}

/// Ket qua tra ve chung cho cac API voucher.
class VoucherApiResponse<T> {
  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final DateTime timestamp;

  const VoucherApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    required this.timestamp,
  });
}
