/// Model voucher tu API backend.
///
/// Backend tra ve 1 JSON chua 3 mang:
///   myVouchers      - voucher da luu cua user
///   vouchers        - voucher giam gia (isFreeship = false)
///   freeshipVouchers - voucher freeship (isFreeship = true)
///
/// API: GET /api/vouchers?userId={userId}&storeId={storeId}
class VoucherModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final DateTime expiryDate;
  final int type; // 1 = percent, 2 = fixed amount
  final double value;
  final double minOrderValue;
  final String? storeId;
  final bool isFreeship;
  final String? imageUrl;
  final int? remaining;
  final String? terms;

  const VoucherModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.expiryDate,
    required this.type,
    required this.value,
    required this.minOrderValue,
    this.storeId,
    required this.isFreeship,
    this.imageUrl,
    this.remaining,
    this.terms,
  });

  /// Tuong thich voi myVouchers (khong co isFreeship, storeId).
  factory VoucherModel.fromMyVoucher(Map<String, dynamic> json) {
    return VoucherModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      description: json['description'] as String?,
      expiryDate: _parseDate(json['expiryDate']),
      type: (json['type'] as num?)?.toInt() ?? 2,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      isFreeship: false,
    );
  }

  /// Tuong thich voi vouchers / freeshipVouchers (co isFreeship, storeId).
  factory VoucherModel.fromPublicVoucher(Map<String, dynamic> json) {
    return VoucherModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? (json['title'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      description: json['description'] as String? ?? json['terms'] as String?,
      expiryDate: _parseDate(json['expiryDate']),
      type: (json['type'] as num?)?.toInt() ?? 2,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      storeId: json['storeId'] as String?,
      isFreeship: (json['isFreeship'] as bool?) ?? false,
      imageUrl: json['imageUrl'] as String?,
      remaining: (json['remaining'] as num?)?.toInt(),
      terms: json['terms'] as String?,
    );
  }

  /// Parse tu JSON (tu dong nhan dien loai).
  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('isFreeship') || json.containsKey('storeId')) {
      return VoucherModel.fromPublicVoucher(json);
    }
    return VoucherModel.fromMyVoucher(json);
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now().add(const Duration(days: 30));
    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now().add(const Duration(days: 30));
    }
    return DateTime.now().add(const Duration(days: 30));
  }

  /// La voucher he thong (khong thuoc cua hang cu the).
  bool get isSystemVoucher => storeId == null;

  /// Con han su dung.
  bool get isValid => expiryDate.isAfter(DateTime.now());
}

/// Wrapper cho data tra ve tu API (success, data, message).
class VoucherResponse {
  final bool success;
  final VoucherListData? data;
  final String message;

  const VoucherResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory VoucherResponse.fromJson(Map<String, dynamic> json) {
    VoucherListData? listData;
    final rawData = json['data'] as Map<String, dynamic>?;
    if (rawData != null) {
      listData = VoucherListData.fromJson(rawData);
    }
    return VoucherResponse(
      success: json['success'] as bool? ?? false,
      data: listData,
      message: (json['message'] as String?) ?? '',
    );
  }
}

/// Chua 3 mang voucher tra ve tu API.
class VoucherListData {
  final List<VoucherModel> myVouchers;
  final List<VoucherModel> vouchers;
  final List<VoucherModel> freeshipVouchers;

  const VoucherListData({
    required this.myVouchers,
    required this.vouchers,
    required this.freeshipVouchers,
  });

  factory VoucherListData.fromJson(Map<String, dynamic> json) {
    return VoucherListData(
      myVouchers: (json['myVouchers'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => VoucherModel.fromJson(e))
              .toList() ??
          [],
      vouchers: (json['vouchers'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => VoucherModel.fromJson(e))
              .toList() ??
          [],
      freeshipVouchers: (json['freeshipVouchers'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => VoucherModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// Mã giảm giá: myVouchers (khong co storeId) + vouchers co storeId == null.
  List<VoucherModel> get discountVouchers {
    return [...myVouchers, ...vouchers.where((v) => v.storeId == null)];
  }

  /// Giảm giá của shop: vouchers co storeId != null.
  List<VoucherModel> get shopVouchers {
    return vouchers.where((v) => v.storeId != null).toList();
  }
}
