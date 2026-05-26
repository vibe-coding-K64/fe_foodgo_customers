/// Loai phuong thuc thanh toan (map tu int cua Firestore).
/// Firestore: 1 = Tien mat, 2 = Vi dien tu, 3 = The ngan hang.
enum PaymentMethodType {
  /// Thanh toan tien mat (COD) - gia tri int 1.
  cash,

  /// Vi dien tu (MoMo, ZaloPay...) - gia tri int 2.
  wallet,

  /// The tin dung / ghi no (Visa, Mastercard...) - gia tri int 3.
  card,
}

extension PaymentMethodTypeExtension on PaymentMethodType {
  /// Chuyen enum thanh int de ghi xuong Firestore.
  int toInt() {
    switch (this) {
      case PaymentMethodType.cash:
        return 1;
      case PaymentMethodType.wallet:
        return 2;
      case PaymentMethodType.card:
        return 3;
    }
  }

  /// Tao PaymentMethodType tu int cua Firestore.
  static PaymentMethodType fromInt(int value) {
    switch (value) {
      case 1:
        return PaymentMethodType.cash;
      case 2:
        return PaymentMethodType.wallet;
      case 3:
        return PaymentMethodType.card;
      default:
        return PaymentMethodType.cash;
    }
  }
}

/// Loai the cu the (chi dung voi type = card).
enum CardBrand {
  visa,
  mastercard,
  jcb,
  amex,
  unknown,
}

extension CardBrandExtension on CardBrand {
  /// Chuyen enum thanh string de ghi xuong Firestore.
  String toFirestoreString() {
    switch (this) {
      case CardBrand.visa:
        return 'visa';
      case CardBrand.mastercard:
        return 'mastercard';
      case CardBrand.jcb:
        return 'jcb';
      case CardBrand.amex:
        return 'amex';
      case CardBrand.unknown:
        return 'unknown';
    }
  }

  /// Tao CardBrand tu string cua Firestore.
  static CardBrand fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'visa':
        return CardBrand.visa;
      case 'mastercard':
        return CardBrand.mastercard;
      case 'jcb':
        return CardBrand.jcb;
      case 'amex':
        return CardBrand.amex;
      default:
        return CardBrand.unknown;
    }
  }
}

/// Loai vi dien tu (chi dung voi type = wallet).
enum WalletBrand {
  momo,
  zalopay,
  vnpay,
  zalo,
  unknown,
}

extension WalletBrandExtension on WalletBrand {
  /// Chuyen enum thanh string de ghi xuong Firestore.
  String toFirestoreString() {
    switch (this) {
      case WalletBrand.momo:
        return 'momo';
      case WalletBrand.zalopay:
        return 'zalopay';
      case WalletBrand.vnpay:
        return 'vnpay';
      case WalletBrand.zalo:
        return 'zalo';
      case WalletBrand.unknown:
        return 'unknown';
    }
  }

  /// Tao WalletBrand tu string cua Firestore.
  static WalletBrand fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'momo':
        return WalletBrand.momo;
      case 'zalopay':
        return WalletBrand.zalopay;
      case 'vnpay':
        return WalletBrand.vnpay;
      case 'zalo':
        return WalletBrand.zalo;
      default:
        return WalletBrand.unknown;
    }
  }
}

/// Model phuong thuc thanh toan tu API backend.
class PaymentMethodModel {
  final String id;
  final String name;
  final PaymentMethodType type;
  final String details;
  final bool isDefault;
  final String? cardBrand;
  final String? last4Digits;
  final String? walletBrand;
  final bool isLinked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    this.details = '',
    this.isDefault = false,
    this.cardBrand,
    this.last4Digits,
    this.walletBrand,
    this.isLinked = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Parse tu JSON cua API /api/payments.
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'cash';

    return PaymentMethodModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _typeFromString(typeStr),
      details: json['details'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      cardBrand: json['cardBrand'] as String?,
      last4Digits: json['last4Digits'] as String?,
      walletBrand: json['walletBrand'] as String?,
      isLinked: json['isLinked'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTimeNullable(json['updatedAt']),
    );
  }

  static PaymentMethodType _typeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'card':
        return PaymentMethodType.card;
      case 'momo':
      case 'zalo':
      case 'wallet':
        return PaymentMethodType.wallet;
      default:
        return PaymentMethodType.cash;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Tra ve ten hien thi cua nha cung cap.
  String get displayName {
    switch (type) {
      case PaymentMethodType.cash:
        return name.isNotEmpty ? name : 'payment_cash';
      case PaymentMethodType.card:
        switch (cardBrand?.toLowerCase()) {
          case 'visa':
            return 'payment_visa';
          case 'mastercard':
            return 'payment_mastercard';
          default:
            return name.isNotEmpty ? name : 'payment_card';
        }
      case PaymentMethodType.wallet:
        switch (walletBrand?.toLowerCase()) {
          case 'momo':
            return 'payment_momo';
          case 'zalopay':
            return 'payment_zalopay';
          case 'vnpay':
            return 'payment_vnpay';
          default:
            return name.isNotEmpty ? name : 'payment_wallet';
        }
    }
  }

  /// Tra ve chuoi the hien thi (VD: "**** 1234").
  String get maskedNumber {
    if (last4Digits == null) return details;
    return '**** $last4Digits';
  }
}
