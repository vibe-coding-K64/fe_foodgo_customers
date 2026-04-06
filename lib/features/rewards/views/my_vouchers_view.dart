import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/rewards_model.dart';
import 'widgets/rewards_voucher_card.dart';

/// Man hinh "Tat ca voucher" cua nguoi dung.
///
/// Hien thi danh sach day du tat ca voucher da nhan / da doi.
///
/// Duoc goi tu:
///   - RewardsView: bam "Xem tat ca" o section voucher.
class MyVouchersView extends StatelessWidget {
  /// Danh sach voucher cua nguoi dung.
  final List<MyVoucherModel> vouchers;

  const MyVouchersView({
    super.key,
    required this.vouchers,
  });

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
            debugPrint('MyVouchers: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          LanguageService.translate('rewards_all_vouchers_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: vouchers.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vouchers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                return RewardsVoucherCard(
                  voucher: voucher,
                  onUse: () {
                    debugPrint('MyVouchers: Nguoi dung bam dung ngay [${voucher.code}]');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Dang su dung voucher ${voucher.code}',
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  /// Widget trang thai rong (khong co voucher nao).
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: AppColors.textHint.withAlpha(100),
          ),
          const SizedBox(height: 12),
          Text(
            LanguageService.translate('reward_no_vouchers'),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
