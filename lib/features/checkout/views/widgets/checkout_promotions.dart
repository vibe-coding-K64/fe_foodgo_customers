import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Widget hien thi phan uu dai va phuong thuc thanh toan o buoc checkout.
/// Bao gom: Voucher, Diem tich luy (Switch), Phuong thuc thanh toan.
class CheckoutPromotions extends StatelessWidget {
  final VoidCallback? onVoucherTap;
  final VoidCallback? onPaymentMethodTap;
  final bool isPointsEnabled;
  final String? selectedVoucher;
  final String selectedPaymentMethod;

  const CheckoutPromotions({
    super.key,
    this.onVoucherTap,
    this.onPaymentMethodTap,
    this.isPointsEnabled = false,
    this.selectedVoucher,
    this.selectedPaymentMethod = 'cash',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DONG 1: Voucher.
        _PromoRow(
          icon: Icons.local_offer_outlined,
          label: selectedVoucher ??
              LanguageService.translate('checkout_voucher'),
          iconColor: AppColors.secondary,
          valueColor:
              selectedVoucher != null ? AppColors.primary : AppColors.textHint,
          onTap: () {
            debugPrint('Checkout: Nguoi dung bam chon voucher');
            onVoucherTap?.call();
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedVoucher != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedVoucher!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 22,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // DONG 2: Diem tich luy (Switch).
        _PointsRow(
          isEnabled: isPointsEnabled,
          onToggle: (value) {
            debugPrint('Checkout: Nguoi dung ${value ? 'bat' : 'tat'} diem tich luy');
          },
        ),
        const SizedBox(height: 10),
        // DONG 3: Phuong thuc thanh toan.
        _PromoRow(
          icon: Icons.payment_outlined,
          label: LanguageService.translate('checkout_payment_method'),
          iconColor: AppColors.primary,
          value: _getPaymentLabel(selectedPaymentMethod),
          valueColor: AppColors.textPrimary,
          onTap: () {
            debugPrint('Checkout: Nguoi dung bam doi phuong thuc thanh toan');
            onPaymentMethodTap?.call();
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentIcon(selectedPaymentMethod),
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPaymentLabel(selectedPaymentMethod),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 22,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPaymentLabel(String method) {
    switch (method) {
      case 'cash':
        return LanguageService.translate('checkout_payment_cash');
      case 'wallet':
        return LanguageService.translate('checkout_payment_wallet');
      case 'card':
        return LanguageService.translate('checkout_payment_card');
      default:
        return method;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'card':
        return Icons.credit_card_outlined;
      default:
        return Icons.payment_outlined;
    }
  }
}

class _PromoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color iconColor;
  final Color valueColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _PromoRow({
    required this.icon,
    required this.label,
    this.value,
    required this.iconColor,
    required this.valueColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      value!,
                      style: TextStyle(
                        fontSize: 13,
                        color: valueColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _PointsRow extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;

  const _PointsRow({
    required this.isEnabled,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Icon(Icons.star_outline, color: Colors.amber[700], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.translate('checkout_use_points'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  LanguageService.translate('checkout_points_note'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
