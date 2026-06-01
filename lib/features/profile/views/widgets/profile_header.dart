import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/localization/language_service.dart';

/// Widget hien thi phan header moi cua trang tai khoan.
///
/// Thiet ke theo phong cach GrabFood/ShopeeFood/Baemin:
/// - Gradient xanh dai
/// - Hinh trang trí moBlur phia sau
/// - Avatar lon voi border trang va shadow
/// - Badge glassmorphism cho role
/// - The thong ke noi bat (orders, vouchers, points)
/// - Nut chinh sua noi bat
class ProfileHeader extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final String avatarUrl;
  final VoidCallback? onEditProfile;
  final bool isDriver;
  final bool isCustomer;

  /// So don hang da dat.
  final int totalOrders;

  /// So voucher con han su dung.
  final int availableVouchers;

  /// Diem thuong hieu hien co.
  final int rewardPoints;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.phoneNumber,
    required this.avatarUrl,
    this.onEditProfile,
    this.isDriver = false,
    this.isCustomer = true,
    this.totalOrders = 0,
    this.availableVouchers = 0,
    this.rewardPoints = 0,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
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
        clipBehavior: Clip.none,
        children: [
          // --- Lớp nền trang trí ---
          _buildDecorations(),

          // --- Nội dung chính ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  // Tên ứng dụng nhỏ
                  _buildAppTitle(),
                  const SizedBox(height: 16),

                  // Avatar lớn với border
                  _buildAvatar(),
                  const SizedBox(height: 12),

                  // Tên & SĐT
                  _buildUserInfo(),
                  const SizedBox(height: 10),

                  // Badge role glassmorphism
                  _buildRoleBadge(),
                  const SizedBox(height: 16),

                  // Nút chỉnh sửa nổi bật
                  _buildEditButton(),
                  const SizedBox(height: 20),

                  // Thẻ thống kê nổi
                  _buildStatsCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // NỀN TRANG TRÍ
  // ========================================================================

  Widget _buildDecorations() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Vòng tròn lớn phía trên phải
            Positioned(
              top: -60,
              right: -40,
              child: _DecoCircle(
                size: 180,
                color: Colors.white.withOpacity(0.08),
                blur: 40,
              ),
            ),
            // Vòng tròn nhỏ giữa phải
            Positioned(
              top: 60,
              right: 30,
              child: _DecoCircle(
                size: 70,
                color: Colors.white.withOpacity(0.1),
                blur: 20,
              ),
            ),
            // Vòng tròn lớn dưới trái
            Positioned(
              bottom: 80,
              left: -50,
              child: _DecoCircle(
                size: 160,
                color: Colors.white.withOpacity(0.06),
                blur: 30,
              ),
            ),
            // Vòng tròn nhỏ trên trái
            Positioned(
              top: 100,
              left: -20,
              child: _DecoCircle(
                size: 55,
                color: Colors.white.withOpacity(0.09),
                blur: 15,
              ),
            ),
            // Điểm sáng mềm phía trên
            Positioned(
              top: 0,
              left: 40,
              child: Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // TIÊU ĐỀ APP
  // ========================================================================

  Widget _buildAppTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fastfood_rounded,
                color: Colors.white,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                'FoodGo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========================================================================
  // AVATAR
  // ========================================================================

  Widget _buildAvatar() {
    return Stack(
      children: [
        // Shadow ring
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        // White border ring
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarContent(),
          ),
        ),
        // Badge online indicator
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.5,
              ),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (widget.avatarUrl.isNotEmpty) {
      return Image.network(
        widget.avatarUrl,
        fit: BoxFit.cover,
        width: 108,
        height: 108,
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 56,
        color: Colors.white,
      ),
    );
  }

  // ========================================================================
  // THÔNG TIN NGƯỜI DÙNG
  // ========================================================================

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          widget.userName.isNotEmpty ? widget.userName : 'Khách hàng FoodGo',
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
        if (widget.phoneNumber.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                widget.phoneNumber,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ========================================================================
  // BADGE ROLE - GLASSMORPHISM
  // ========================================================================

  Widget _buildRoleBadge() {
    String label;
    if (widget.isDriver) {
      label = 'Khách hàng & Đối tác';
    } else if (widget.isCustomer) {
      label = 'Khách hàng';
    } else {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isDriver ? Icons.star_rounded : Icons.person_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // NÚT CHỈNH SỬA
  // ========================================================================

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: widget.onEditProfile,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF2E7D32),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Chỉnh sửa hồ sơ',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF4CAF50),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // THẺ THỐNG KÊ
  // ========================================================================

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: [
            _buildStatItem(
              icon: Icons.receipt_long_rounded,
              iconColor: const Color(0xFF43A047),
              iconBg: const Color(0xFFE8F5E9),
              value: widget.totalOrders.toString(),
              label: context.t('profile_stat_orders'),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.local_offer_rounded,
              iconColor: const Color(0xFFFF7043),
              iconBg: const Color(0xFFFBE9E7),
              value: widget.availableVouchers.toString(),
              label: context.t('profile_stat_vouchers'),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.stars_rounded,
              iconColor: const Color(0xFFFFB300),
              iconBg: const Color(0xFFFFF8E1),
              value: widget.rewardPoints.toString(),
              label: context.t('profile_stat_points'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey.shade200,
    );
  }
}

// ========================================================================
// WIDGET TRANG TRÍ: VÒNG TRÒN MO
// ========================================================================

class _DecoCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const _DecoCircle({
    required this.size,
    required this.color,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: blur,
          ),
        ],
      ),
    );
  }
}
