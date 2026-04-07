import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../models/rewards_model.dart';
import '../voucher_applicable_products_view.dart';
import 'rewards_voucher_card.dart';

/// Section hien thi danh sach voucher cua nguoi dung.
///
/// Su dung [RewardsVoucherCard] (reusable) de hien thi moi item.
///
/// Duoc su dung trong [RewardsView].
class RewardsMyVouchers extends StatelessWidget {
  /// Danh sach voucher.
  final List<MyVoucherModel> vouchers;

  /// Ham goi khi bam "Xem tat ca".
  final VoidCallback? onViewAll;

  const RewardsMyVouchers({
    super.key,
    required this.vouchers,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('rewards_my_vouchers'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  debugPrint('RewardsMyVouchers: Nguoi dung bam xem tat ca voucher');
                  onViewAll?.call();
                },
                child: Text(
                  context.t('common_see_all'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vouchers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final voucher = vouchers[index];
            return RewardsVoucherCard(
              voucher: voucher,
              onUse: () {
                debugPrint('RewardsMyVouchers: Nguoi dung bam dung ngay [${voucher.code}]');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoucherApplicableProductsView(voucher: voucher),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
