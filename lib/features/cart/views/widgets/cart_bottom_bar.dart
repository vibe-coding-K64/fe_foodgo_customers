import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Widget thanh hanh dong bam day (Sticky Bottom Bar) cua trang gio hang.
/// Hien thi: tam tinh, va nut mua hang.
class CartBottomBar extends StatelessWidget {
  final int selectedCount;
  final double subtotal;
  final VoidCallback onCheckout;

  const CartBottomBar({
    super.key,
    required this.selectedCount,
    required this.subtotal,
    required this.onCheckout,
  });

  String _formatPrice(double price) {
    final str = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = selectedCount > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tam tinh.
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('cart_estimated_total'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                const SizedBox(height: 2),
                Text(
                  isEnabled
                      ? '~ ${_formatPrice(subtotal)} ${context.t('unit_currency')}'
                      : '~ 0 ${context.t('unit_currency')}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? AppColors.primary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Nut mua hang.
          GestureDetector(
            onTap: isEnabled
                ? () {
                    debugPrint(
                      'CartView: Nguoi dung bam nut mua hang ($selectedCount mon)',
                    );
                    onCheckout();
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.primary
                    : AppColors.textHint.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                context
                    .t('cart_buy_btn')
                    .replaceAll('{count}', '$selectedCount'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
