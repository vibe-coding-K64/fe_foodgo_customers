import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Widget hien thi chi tiet hoa don o buoc checkout.
class CheckoutSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double shopDiscount;
  final double freeshipDiscount;

  const CheckoutSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.shopDiscount,
    required this.freeshipDiscount,
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
          context.t('checkout_order_summary'),
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
                label: context.t('checkout_subtotal'),
                value:
                    '${_formatPrice(subtotal)} ${context.t('unit_currency')}',
                valueColor: AppColors.textPrimary,
              ),
              if (discount > 0) ...[
                const SizedBox(height: 10),
                _SummaryRow(
                  label: context.t('checkout_discount'),
                  value:
                      '-${_formatPrice(discount)} ${context.t('unit_currency')}',
                  valueColor: AppColors.success,
                ),
              ],
              if (shopDiscount > 0) ...[
                const SizedBox(height: 10),
                _SummaryRow(
                  label: context.t('checkout_shop_discount'),
                  value:
                      '-${_formatPrice(shopDiscount)} ${context.t('unit_currency')}',
                  valueColor: AppColors.success,
                ),
              ],
              const SizedBox(height: 10),
              _SummaryRow(
                label: context.t('checkout_delivery_fee'),
                value:
                    '+${_formatPrice(deliveryFee)} ${context.t('unit_currency')}',
                valueColor: AppColors.textSecondary,
              ),
              if (freeshipDiscount > 0) ...[
                const SizedBox(height: 10),
                _SummaryRow(
                  label: context.t('checkout_freeship_discount'),
                  value:
                      '-${_formatPrice(freeshipDiscount)} ${context.t('unit_currency')}',
                  valueColor: AppColors.success,
                ),
              ],
              // Dong tong
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              _SummaryRow(
                label: context.t('checkout_total_payment'),
                value:
                    '${_formatPrice(subtotal + deliveryFee - discount - shopDiscount - freeshipDiscount)} ${context.t('unit_currency')}',
                valueColor: AppColors.primary,
                isBold: true,
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
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
