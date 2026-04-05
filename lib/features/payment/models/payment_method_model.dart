/// Loai phuong thuc thanh toan.
enum PaymentMethodType {
  /// Thanh toan tien mat (COD).
  cash,

  /// The tin dung / ghi no (Visa, Mastercard...).
  card,

  /// Vi dien tu (MoMo, ZaloPay...).
  wallet,
}

/// Loai the cu the (chi dung voi type = card).
enum CardBrand {
  visa,
  mastercard,
  jcb,
  amex,
  unknown,
}

/// Loai vi dien tu (chi dung voi type = wallet).
enum WalletBrand {
  momo,
  zalopay,
  vnpay,
  zalo,
  unknown,
}

/// Model phuong thuc thanh toan.
class PaymentMethodModel {
  final String id;
  final PaymentMethodType type;
  final bool isDefault;
  final DateTime createdAt;

  // Chi dung voi type = card.
  final CardBrand? cardBrand;
  final String? last4Digits; // 4 chu so cuoi the.

  // Chi dung voi type = wallet.
  final WalletBrand? walletBrand;
  final bool isLinked; // da lien ket hay chua.

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
