import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Widget hien thi chi tiet hoa don o buoc checkout.
/// Cac dong: Tam tinh, Phi giao hang, Giam gia (can hai ben).
class CheckoutSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double discount;

  const CheckoutSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tieu de.
        Text(
          LanguageService.translate('checkout_order_summary'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Cac dong chi tiet.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              _SummaryRow(
                label: LanguageService.translate('checkout_subtotal'),
                value:
                    '${_formatPrice(subtotal)} ${LanguageService.translate('unit_currency')}',
                valueColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: LanguageService.translate('checkout_delivery_fee'),
                value:
                    '+${_formatPrice(deliveryFee)} ${LanguageService.translate('unit_currency')}',
                valueColor: AppColors.textSecondary,
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: LanguageService.translate('checkout_discount'),
                value:
                    '-${_formatPrice(discount)} ${LanguageService.translate('unit_currency')}',
                valueColor: AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
