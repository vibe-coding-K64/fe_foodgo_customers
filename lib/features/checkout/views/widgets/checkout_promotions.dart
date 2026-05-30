import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../features/payment/models/payment_method_model.dart';

/// Widget hien thi phan uu dai va phuong thuc thanh toan o buoc checkout.
/// Bao gom: Voucher, Ghi chu don hang, Phuong thuc thanh toan.
class CheckoutPromotions extends StatelessWidget {
  final VoidCallback? onVoucherTap;
  final VoidCallback? onPaymentMethodTap;
  final String? selectedVouchersSummary;
  final String selectedPaymentMethod;
  final PaymentMethodModel? selectedPaymentMethodInfo;
  final String orderNote;
  final ValueChanged<String>? onNoteChanged;

  const CheckoutPromotions({
    super.key,
    this.onVoucherTap,
    this.onPaymentMethodTap,
    this.selectedVouchersSummary,
    this.selectedPaymentMethod = 'cash',
    this.selectedPaymentMethodInfo,
    this.orderNote = '',
    this.onNoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PromoRow(
          icon: Icons.local_offer_outlined,
          label: selectedVouchersSummary?.isNotEmpty == true
              ? context.t('checkout_vouchers_selected')
              : context.t('checkout_voucher'),
          iconColor: AppColors.secondary,
          valueColor: selectedVouchersSummary?.isNotEmpty == true
              ? AppColors.primary
              : AppColors.textHint,
          onTap: onVoucherTap,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedVouchersSummary?.isNotEmpty == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedVouchersSummary!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
        _NoteRow(
          note: orderNote,
          onNoteChanged: onNoteChanged,
        ),
        const SizedBox(height: 10),
        _PromoRow(
          icon: Icons.payment_outlined,
          label: context.t('checkout_payment_method'),
          iconColor: AppColors.primary,
          value: selectedPaymentMethodInfo?.name ??
              _getPaymentLabel(context, selectedPaymentMethod),
          valueColor: AppColors.textPrimary,
          onTap: onPaymentMethodTap,
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
                      _getPaymentIconForWidget(
                          selectedPaymentMethodInfo, selectedPaymentMethod),
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      selectedPaymentMethodInfo?.name ??
                          _getPaymentLabel(context, selectedPaymentMethod),
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

  String _getPaymentLabel(BuildContext context, String method) {
    switch (method) {
      case 'cash':
        return context.t('checkout_payment_cash');
      case 'momo':
        return context.t('checkout_payment_momo');
      case 'zalo':
        return context.t('checkout_payment_zalo');
      case 'card':
        return context.t('checkout_payment_card');
      default:
        return method;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money_outlined;
      case 'momo':
        return Icons.wallet_outlined;
      case 'zalo':
        return Icons.account_balance_wallet_outlined;
      case 'card':
        return Icons.credit_card_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  IconData _getPaymentIconForWidget(
      PaymentMethodModel? methodInfo, String fallbackMethod) {
    if (methodInfo != null) {
      switch (methodInfo.type) {
        case PaymentMethodType.cash:
          return Icons.money_outlined;
        case PaymentMethodType.wallet:
          final brand = methodInfo.walletBrand?.toLowerCase();
          if (brand == 'momo') return Icons.wallet_outlined;
          return Icons.account_balance_wallet_outlined;
        case PaymentMethodType.card:
          return Icons.credit_card_outlined;
      }
    }
    return _getPaymentIcon(fallbackMethod);
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
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _NoteRow extends StatefulWidget {
  final String note;
  final ValueChanged<String>? onNoteChanged;

  const _NoteRow({
    required this.note,
    this.onNoteChanged,
  });

  @override
  State<_NoteRow> createState() => _NoteRowState();
}

class _NoteRowState extends State<_NoteRow> {
  bool _isExpanded = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note);
  }

  @override
  void didUpdateWidget(_NoteRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note != widget.note && _controller.text != widget.note) {
      _controller.text = widget.note;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.note_outlined,
                  color: AppColors.secondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isExpanded
                        ? context.t('checkout_order_note')
                        : (widget.note.isEmpty
                            ? context.t('checkout_add_note')
                            : widget.note),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: widget.note.isEmpty && !_isExpanded
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                    maxLines: _isExpanded ? null : 1,
                    overflow:
                        _isExpanded ? null : TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textHint,
                  size: 22,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 2,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: context.t('checkout_note_hint'),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: widget.onNoteChanged,
            ),
          ],
        ],
      ),
    );
  }
}
