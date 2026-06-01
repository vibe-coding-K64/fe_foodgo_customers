/// Model thong ke nguoi dung hien thi tren profile header.
///
/// Lay du lieu tu:
///   - orders (dem so don hang da dat cua user)
///   - customer_profiles/{userId}/my_vouchers (dem voucher da co)
///   - customer_profiles/{userId} (loyaltyPoints)
class ProfileStats {
  /// Tong so don hang da dat.
  final int totalOrders;

  /// Tong so voucher da doi/nhan.
  final int availableVouchers;

  /// Diem tich luy (loyaltyPoints).
  final int rewardPoints;

  const ProfileStats({
    this.totalOrders = 0,
    this.availableVouchers = 0,
    this.rewardPoints = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalOrders: json['totalOrders'] as int? ?? 0,
      availableVouchers: json['availableVouchers'] as int? ?? 0,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
    );
  }
}
