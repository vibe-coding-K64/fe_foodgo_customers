import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../models/rewards_model.dart';

/// Widget hien thi mot voucher cua nguoi dung.
///
/// Duoc su dung chung cho:
///   - Trang chinh RewardsView (danh sach ngan).
///   - Trang "Tat ca voucher" (MyVouchersView).
///
/// Thiet ke:
///   - Trai: Nen cam vang nhat chua so % / K giam.
///   - Phai: Ten, ma code, han su dung, nut "Dung ngay".
class RewardsVoucherCard extends StatelessWidget {
  /// Voucher can hien thi.
  final MyVoucherModel voucher;

  /// Ham goi khi bam nut "Dung ngay".
  final VoidCallback? onUse;

  const RewardsVoucherCard({
    super.key,
    required this.voucher,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    // Kiem tra voucher con han su dung.
    final isExpired = !voucher.isValid;

    return Container(
      decoration: BoxDecoration(
        color: isExpired ? AppColors.surfaceVariant.withAlpha(150) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? AppColors.border.withAlpha(100) : AppColors.divider,
        ),
        boxShadow: isExpired
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Ben trai: Nen cam vang nhat voi so % / K giam.
            _buildLeftSection(isExpired),
            // Ben phai: Thong tin voucher va nut dung ngay.
            Expanded(
              child: _buildRightSection(context, isExpired),
            ),
          ],
        ),
      ),
    );
  }

  /// Phan ben trai: So % giam gia trong o vuong cam vang.
  Widget _buildLeftSection(bool isExpired) {
    final discountText = voucher.isPercentage
        ? '${voucher.discountValue.toInt()}%'
        : '${voucher.discountValue.toInt()}K';

    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.surfaceVariant
            : const Color(0xFFFFF3E0),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            discountText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isExpired ? AppColors.textHint : AppColors.primary,
            ),
          ),
          Text(
            'GIAM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isExpired ? AppColors.textHint : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Phan ben phai: Ten, ma code, HSD, nut "Dung ngay".
  Widget _buildRightSection(BuildContext context, bool isExpired) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ten voucher.
          Text(
            voucher.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isExpired ? AppColors.textHint : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Ma code.
          Text(
            voucher.code,
            style: TextStyle(
              fontSize: 12,
              color: isExpired ? AppColors.textHint : AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          // Han su dung.
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 12,
                color: isExpired ? AppColors.textHint : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${LanguageService.translate('rewards_expires')}: '
                '${voucher.expiryDate.day.toString().padLeft(2, '0')}/'
                '${voucher.expiryDate.month.toString().padLeft(2, '0')}/'
                '${voucher.expiryDate.year}',
                style: TextStyle(
                  fontSize: 11,
                  color: isExpired ? AppColors.textHint : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Nut su dung (chi hien khi chua het han).
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isExpired
                  ? null
                  : () {
                      debugPrint('RewardsVoucherCard: Nguoi dung bam dung ngay [${voucher.code}]');
                      onUse?.call();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isExpired ? AppColors.surfaceVariant : AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceVariant,
                disabledForegroundColor: AppColors.textHint,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                LanguageService.translate('rewards_use_now'),
                style: const TextStyle(
                  fontSize: 13,
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
