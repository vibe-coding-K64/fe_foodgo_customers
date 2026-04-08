import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../models/payment_method_model.dart';

/// Widget hien thi mot phuong thuc thanh toan trong danh sach quan ly.
///
/// Chia theo 3 loai:
///   - [PaymentMethodType.cash]: hien thi icon tien mat, nut radio trai.
///   - [PaymentMethodType.card]: hien thi logo the + 4 so cuoi + nut xoa.
///   - [PaymentMethodType.wallet]: hien thi icon vi + trang thai lien ket.
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel method;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: method.isDefault
              ? Border.all(color: AppColors.primary, width: 1.5)
              : Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (method.type) {
      case PaymentMethodType.cash:
        return _buildCashContent(context);
      case PaymentMethodType.card:
        return _buildCardContent(context);
      case PaymentMethodType.wallet:
        return _buildWalletContent(context);
    }
  }

  /// Noi dung cho phuong thuc tien mat.
  Widget _buildCashContent(BuildContext ctx) {
    return Row(
      children: [
        // Icon tien mat.
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.payments_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.t('payment_cash'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                ctx.t('payment_cash_desc'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Radio mac dinh.
        _buildRadio(),
      ],
    );
  }

  /// Noi dung cho phuong thuc the.
  Widget _buildCardContent(BuildContext ctx) {
    return Row(
      children: [
        // Logo the.
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getCardBgColor(),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              _getCardAbbrev(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _getCardTextColor(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCardBrandName(ctx),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                method.maskedNumber,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Radio mac dinh.
        _buildRadio(),
        const SizedBox(width: 8),
        // Nut xoa the.
        if (onDelete != null)
          GestureDetector(
            onTap: () {
              debugPrint(
                  'PaymentMethods: Nguoi dung bam xoa the [${method.id}]');
              onDelete?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }

  /// Noi dung cho phuong thuc vi dien tu.
  Widget _buildWalletContent(BuildContext ctx) {
    return Row(
      children: [
        // Icon vi.
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getWalletBgColor(),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              _getWalletIcon(),
              color: _getWalletIconColor(),
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getWalletName(ctx),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: method.isLinked
                      ? AppColors.primary.withAlpha(15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  method.isLinked
                      ? ctx.t('payment_linked')
                      : ctx.t('payment_not_linked'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: method.isLinked
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Radio mac dinh.
        _buildRadio(),
        const SizedBox(width: 8),
        // Nut xoa vi (neu da lien ket).
        if (onDelete != null && method.isLinked)
          GestureDetector(
            onTap: () {
              debugPrint(
                  'PaymentMethods: Nguoi dung bam xoa vi [${method.id}]');
              onDelete?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }

  /// Nut radio chon lam mac dinh.
  Widget _buildRadio() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: method.isDefault ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: method.isDefault
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }

  /// Lay ten nhan hien thi cua nha the.
  String _getCardBrandName() {
    switch (method.cardBrand) {
      case CardBrand.visa:
        return LanguageService.translate('payment_visa');
      case CardBrand.mastercard:
        return LanguageService.translate('payment_mastercard');
      case CardBrand.jcb:
        return 'JCB';
      case CardBrand.amex:
        return 'American Express';
      default:
        return LanguageService.translate('payment_card');
    }
  }

  /// Lay chu viet tat hien thi tren logo the.
  String _getCardAbbrev() {
    switch (method.cardBrand) {
      case CardBrand.visa:
        return 'VISA';
      case CardBrand.mastercard:
        return 'MC';
      case CardBrand.jcb:
        return 'JCB';
      case CardBrand.amex:
        return 'AMEX';
      default:
        return '****';
    }
  }

  /// Lay mau nen logo the.
  Color _getCardBgColor() {
    switch (method.cardBrand) {
      case CardBrand.visa:
        return const Color(0xFF1A1F71);
      case CardBrand.mastercard:
        return const Color(0xFFEB001B);
      case CardBrand.jcb:
        return const Color(0xFF0E4D95);
      case CardBrand.amex:
        return const Color(0xFF007BC1);
      default:
        return AppColors.surfaceVariant;
    }
  }

  /// Lay mau chu tren logo the.
  Color _getCardTextColor() {
    switch (method.cardBrand) {
      case CardBrand.visa:
        return Colors.white;
      case CardBrand.mastercard:
        return Colors.white;
      case CardBrand.jcb:
        return Colors.white;
      case CardBrand.amex:
        return Colors.white;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Lay ten hien thi cua vi.
  String _getWalletName() {
    switch (method.walletBrand) {
      case WalletBrand.momo:
        return LanguageService.translate('payment_momo');
      case WalletBrand.zalopay:
        return LanguageService.translate('payment_zalopay');
      case WalletBrand.vnpay:
        return LanguageService.translate('payment_vnpay');
      default:
        return LanguageService.translate('payment_wallet');
    }
  }

  /// Lay icon vi.
  IconData _getWalletIcon() {
    switch (method.walletBrand) {
      case WalletBrand.momo:
        return Icons.savings_outlined;
      case WalletBrand.zalopay:
        return Icons.account_balance_wallet_outlined;
      case WalletBrand.vnpay:
        return Icons.payment;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  /// Lay mau nen icon vi.
  Color _getWalletBgColor() {
    switch (method.walletBrand) {
      case WalletBrand.momo:
        return const Color(0xFFA50064);
      case WalletBrand.zalopay:
        return const Color(0xFF0068FF);
      case WalletBrand.vnpay:
        return const Color(0xFFAE2C1B);
      default:
        return AppColors.surfaceVariant;
    }
  }

  /// Lay mau icon vi.
  Color _getWalletIconColor() {
    switch (method.walletBrand) {
      case WalletBrand.momo:
      case WalletBrand.zalopay:
      case WalletBrand.vnpay:
        return Colors.white;
      default:
        return AppColors.textSecondary;
    }
  }
}
