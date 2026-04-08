import 'package:cloud_firestore/cloud_firestore.dart';

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

/// Model phuong thuc thanh toan, dong bo tu Firebase Firestore.
class PaymentMethodModel {
  final String id;
  final PaymentMethodType type;
  final bool isDefault;
  final DateTime createdAt;

  // Chi dung voi type = card.
  final CardBrand? cardBrand;
  final String? last4Digits;

  // Chi dung voi type = wallet.
  final WalletBrand? walletBrand;
  final bool isLinked;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    this.isDefault = false,
    required this.createdAt,
    this.cardBrand,
    this.last4Digits,
    this.walletBrand,
    this.isLinked = false,
  });

  /// Tao PaymentMethodModel tu DocumentSnapshot cua Firestore.
  factory PaymentMethodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentMethodModel(
      id: doc.id,
      type: PaymentMethodTypeExtension.fromInt(data['type'] as int? ?? 1),
      isDefault: (data['isDefault'] as bool?) ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cardBrand: CardBrandExtension.fromString(data['cardBrand'] as String?),
      last4Digits: data['last4Digits'] as String?,
      walletBrand: WalletBrandExtension.fromString(data['walletBrand'] as String?),
      isLinked: (data['isLinked'] as bool?) ?? false,
    );
  }

  PaymentMethodModel copyWith({
    String? id,
    PaymentMethodType? type,
    bool? isDefault,
    DateTime? createdAt,
    CardBrand? cardBrand,
    String? last4Digits,
    WalletBrand? walletBrand,
    bool? isLinked,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      cardBrand: cardBrand ?? this.cardBrand,
      last4Digits: last4Digits ?? this.last4Digits,
      walletBrand: walletBrand ?? this.walletBrand,
      isLinked: isLinked ?? this.isLinked,
    );
  }

  /// Tra ve ten hien thi cua nha cung cap.
  String get displayName {
    switch (type) {
      case PaymentMethodType.cash:
        return 'payment_cash';
      case PaymentMethodType.card:
        switch (cardBrand) {
          case CardBrand.visa:
            return 'payment_visa';
          case CardBrand.mastercard:
            return 'payment_mastercard';
          case CardBrand.jcb:
            return 'JCB';
          case CardBrand.amex:
            return 'American Express';
          default:
            return 'payment_card';
        }
      case PaymentMethodType.wallet:
        switch (walletBrand) {
          case WalletBrand.momo:
            return 'payment_momo';
          case WalletBrand.zalopay:
            return 'payment_zalopay';
          case WalletBrand.vnpay:
            return 'payment_vnpay';
          default:
            return 'payment_wallet';
        }
    }
  }

  /// Tra ve chuoi the hien thi (VD: "**** 1234").
  String get maskedNumber {
    if (last4Digits == null) return '';
    return '**** $last4Digits';
  }
}
