import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/rewards_model.dart';

/// Man hinh Chi tiet uu dai (doi diem).
///
/// Nhan vao mot [ExchangeVoucherModel] va hien thi day du noi dung.
///
/// Hien thi:
///   - Hinh anh cover tran vien.
///   - Tieu de, mo ta, dieu khoan.
///   - Sticky bottom bar: Diem can doi + nut "Doi diem ngay".
///
/// Duoc goi tu:
///   - RewardsView: bam vao item trong section "Doi diem".
class RewardDetailView extends StatelessWidget {
  /// Voucher can hien thi chi tiet.
  final ExchangeVoucherModel voucher;

  const RewardDetailView({
    super.key,
    required this.voucher,
  });

  /// Format so diem thanh chuoi co dau phay.
  String _formatPoints(int points) {
    final formatted = points.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},');
    return formatted;
  }

  /// Xu ly khi bam nut "Doi diem ngay".
  void _onExchangeTap(BuildContext context) {
    final bodyTemplate = LanguageService.translate('reward_exchange_confirm_body');
    final bodyText = bodyTemplate.replaceAll('\$1', _formatPoints(voucher.pointsRequired));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            LanguageService.translate('reward_exchange_confirm_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            bodyText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('RewardDetail: Nguoi dung huy dong diem');
                Navigator.pop(dialogContext);
              },
              child: Text(
                LanguageService.translate('common_cancel'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                debugPrint('RewardDetail: Nguoi dung dong y doi diem [${voucher.id}]');
                Navigator.pop(dialogContext);
                _showSuccessAndPop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                LanguageService.translate('common_confirm'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  /// Hien thi thanh cong roi quay ve.
  void _showSuccessAndPop(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LanguageService.translate('reward_exchange_success')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('RewardDetail: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          LanguageService.translate('reward_detail_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Noi dung cuon.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hinh anh cover tran vien.
                  _buildCoverImage(),
                  const SizedBox(height: 20),
                  // Tieu de va mo ta.
                  _buildHeader(),
                  const SizedBox(height: 16),
                  // Divider.
                  _buildDivider(),
                  const SizedBox(height: 16),
                  // Dieu khoan.
                  _buildTerms(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Sticky bottom bar: Diem + Nut doi diem.
          _buildBottomBar(context),
        ],
      ),
    );
  }

  /// Widget hinh anh cover tran vien.
  Widget _buildCoverImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: voucher.imageUrl.isNotEmpty
          ? Image.network(
              voucher.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  /// Placeholder khi khong co anh.
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.local_offer_outlined,
          size: 64,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  /// Widget tieu de va mo ta.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de.
          Text(
            voucher.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          // Mo ta ngắn.
          Text(
            voucher.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget divider.
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 1,
        decoration: BoxDecoration(
          color: AppColors.divider.withAlpha(80),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  /// Widget dieu khoan ap dung.
  Widget _buildTerms() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de "Dieu khoan".
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                LanguageService.translate('reward_terms'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Noi dung dieu khoan.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withAlpha(120),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withAlpha(80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Han su dung.
                _buildTermItem(
                  icon: Icons.calendar_today_outlined,
                  text: voucher.terms.isNotEmpty
                      ? voucher.terms
                      : 'Uu dai co hieu luc trong 30 ngay tu ngay doi.',
                ),
                if (voucher.minOrderValue > 0) ...[
                  const SizedBox(height: 10),
                  // Don hang toi thieu.
                  _buildTermItem(
                    icon: Icons.shopping_cart_outlined,
                    text: '${LanguageService.translate('reward_min_order')}: '
                        '${voucher.minOrderValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}đ',
                  ),
                ],
                const SizedBox(height: 10),
                // So luong con lai.
                _buildTermItem(
                  icon: Icons.inventory_2_outlined,
                  text: 'Con lai: ${voucher.remaining} voucher',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mot dong trong khoi dieu khoan.
  Widget _buildTermItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget sticky bottom bar.
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // So diem can doi (trai).
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stars,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_formatPoints(voucher.pointsRequired)} ${LanguageService.translate('reward_points_required')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Nut "Doi diem ngay" (phai).
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onExchangeTap(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                LanguageService.translate('reward_action_exchange_now'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
