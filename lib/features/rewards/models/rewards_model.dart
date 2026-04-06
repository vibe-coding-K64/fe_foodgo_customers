/// Model voucher cua nguoi dung (da doi / da nhan).
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

  /// Kiem tra voucher con han su dung hay khong.
  bool get isValid => expiryDate.isAfter(DateTime.now());

  /// So ngay con lai truoc khi het han.
  int get daysRemaining {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }
}

/// Model voucher co the doi diem.
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
}
