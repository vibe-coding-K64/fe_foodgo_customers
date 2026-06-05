import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Premium profile header cho trang tai khoan.
/// Thiet ke theo phong cach GrabFood/ShopeeFood/Beamin.
/// Khong chinh sua bat ky noi dung nao ben duoi header.
class ProfileHeader extends StatelessWidget {
  /// Ten nguoi dung.
  final String userName;

  /// So dien thoai.
  final String phoneNumber;

  /// URL anh dai dien.
  final String avatarUrl;

  /// Callback khi bam nut chinh sua ho so.
  final VoidCallback? onEditProfile;

  /// So don hang da dat (mock/tu service).
  final int totalOrders;

  /// So voucher san co.
  final int availableVouchers;

  /// Diem thuong hieu.
  final int rewardPoints;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.phoneNumber,
    required this.avatarUrl,
    this.onEditProfile,
    this.totalOrders = 0,
    this.availableVouchers = 0,
    this.rewardPoints = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF43A047),
            Color(0xFF66BB6A),
            Color(0xFF2E7D32),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Hinh tron trang tri phia tren ben trai (mo).
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          // Hinh tron trang tri phia tren ben phai.
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Hinh tron nho phia duoi ben phai.
          Positioned(
            bottom: 10,
            right: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Hinh tron duoi ben trai.
          Positioned(
            bottom: -20,
            left: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Noi dung chinh.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Avatar + Ten + So dien thoai + Badge.
                  _buildUserInfo(context),
                  const SizedBox(height: 16),
                  // The tinh toan (Orders / Vouchers / Points).
                  _buildStatsCard(context),
                  const SizedBox(height: 12),
                  // Nut chinh sua ho so.
                  _buildEditButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Khu vuc avatar, ten, so dien thoai, badge vai tro.
  Widget _buildUserInfo(BuildContext context) {
    return Column(
      children: [
        // Avatar.
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: SizedBox(
              width: 88,
              height: 88,
              child: avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                    )
                  : _buildAvatarPlaceholder(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Ten nguoi dung.
        Text(
          userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (phoneNumber.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            phoneNumber,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  /// Placeholder avatar.
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 44,
        color: Colors.white,
      ),
    );
  }

  /// The thong ke don hang / voucher / diem.
  Widget _buildStatsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            icon: Icons.receipt_long_rounded,
            value: totalOrders.toString(),
            label: context.t('profile_stats_orders'),
            color: AppColors.primary,
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            icon: Icons.local_offer_outlined,
            value: availableVouchers.toString(),
            label: context.t('profile_stats_vouchers'),
            color: AppColors.secondary,
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            icon: Icons.star_rounded,
            value: rewardPoints.toString(),
            label: context.t('profile_stats_points'),
            color: const Color(0xFFFFB300),
          ),
        ],
      ),
    );
  }

  /// Mot cot thong ke.
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Duong ke phan cach giua cac cot thong ke.
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.divider.withOpacity(0.5),
    );
  }

  /// Nut chinh sua ho so (nen trang, chu xanh).
  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onEditProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              context.t('profile_edit'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
