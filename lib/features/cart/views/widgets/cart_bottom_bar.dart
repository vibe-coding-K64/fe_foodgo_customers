import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Widget thanh hanh dong bam day (Sticky Bottom Bar) cua trang gio hang.
/// Hien thi: checkbox chon tat ca, tam tinh, va nut mua hang.
class CartBottomBar extends StatelessWidget {
  final bool isAllSelected;
  final int selectedCount;
  final int totalCount;
  final double subtotal;
  final VoidCallback onSelectAllChanged;
  final VoidCallback onCheckout;

  const CartBottomBar({
    super.key,
    required this.isAllSelected,
    required this.selectedCount,
    required this.totalCount,
    required this.subtotal,
    required this.onSelectAllChanged,
    required this.onCheckout,
  });

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0).replaceAllMapped(
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
          // Checkbox chon tat ca.
          Transform.scale(
            scale: 1.05,
            child: Checkbox(
              value: isAllSelected,
              onChanged: (_) {
                debugPrint(
                    'CartView: Checkbox chon tat ca = ${!isAllSelected}');
                onSelectAllChanged();
              },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(
                color:
                    isAllSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            context.t('cart_select_all'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Tam tinh.
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                context.t('cart_estimated_total'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
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
          const SizedBox(width: 12),
          // Nut mua hang.
          GestureDetector(
            onTap: isEnabled
                ? () {
                    debugPrint(
                        'CartView: Nguoi dung bam nut mua hang ($selectedCount mon)');
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
                context.t('cart_buy_btn')
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
