import 'package:flutter/material.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/core/utils/snackbar_helper.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';
import 'package:fe_foodgo_customers/features/order/services/order_service.dart';

/// Cac ly do huy don hang.
enum CancelReason {
  changeMind,
  longWait,
  wrongItem,
  duplicate,
  other,
}

/// Widget dialog huy don hang, dep va co lý do chon san.
///
/// Hien thi header, danh sach ly do, input ly do khac (neu chon),
/// nut huy don (disabled neu chua chon) va loading state.
class CancelOrderDialog extends StatefulWidget {
  final OrderModel order;

  const CancelOrderDialog({
    super.key,
    required this.order,
  });

  /// Hien thi dialog huy don.
  ///
  /// Tra ve CancelOrderResponse neu user xac nhan huy, hoac null neu dong.
  static Future<CancelOrderResponse?> show(BuildContext context, OrderModel order) {
    return showDialog<CancelOrderResponse>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CancelOrderDialog(order: order),
    );
  }

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  CancelReason? _selectedReason;
  final _otherReasonController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  String get _effectiveReason {
    switch (_selectedReason) {
      case CancelReason.changeMind:
        return context.t('cancel_order_reason_change_mind');
      case CancelReason.longWait:
        return context.t('cancel_order_reason_long_wait');
      case CancelReason.wrongItem:
        return context.t('cancel_order_reason_wrong_item');
      case CancelReason.duplicate:
        return context.t('cancel_order_reason_duplicate');
      case CancelReason.other:
        return _otherReasonController.text.trim();
      case null:
        return '';
    }
  }

  bool get _canSubmit {
    if (_selectedReason == null) return false;
    if (_selectedReason == CancelReason.other) {
      return _otherReasonController.text.trim().isNotEmpty;
    }
    return true;
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit || _isSubmitting) return;

    _isSubmitting = true;
    setState(() => _isLoading = true);

    final reason = _effectiveReason;
    final response = await OrderService.cancelOrder(widget.order.id, reason);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      Navigator.of(context).pop(response);
    } else {
      _isSubmitting = false;
      setState(() {});
      showTopSnackBar(
        context,
        message: response.message,
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${context.t('cancel_order_title')} ${widget.order.storeName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.t('cancel_order_body')} ${widget.order.storeName}?',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Label ly do
                  Text(
                    context.t('cancel_order_reason_label'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Danh sach ly do
                  ..._buildReasonItems(),

                  // Input ly do khac
                  if (_selectedReason == CancelReason.other) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherReasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: context.t('cancel_order_reason_hint'),
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.t('common_close'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canSubmit && !_isLoading && !_isSubmitting ? _onSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        disabledBackgroundColor: AppColors.border,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              context.t('cancel_order_btn'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReasonItems() {
    final reasons = [
      (CancelReason.changeMind, 'cancel_order_reason_change_mind'),
      (CancelReason.longWait, 'cancel_order_reason_long_wait'),
      (CancelReason.wrongItem, 'cancel_order_reason_wrong_item'),
      (CancelReason.duplicate, 'cancel_order_reason_duplicate'),
      (CancelReason.other, 'cancel_order_reason_other'),
    ];

    return reasons.map((r) {
      final isSelected = _selectedReason == r.$1;
      return GestureDetector(
        onTap: () => setState(() => _selectedReason = r.$1),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.error.withOpacity(0.08)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.error : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.error : AppColors.border,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.error : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.t(r.$2),
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? AppColors.error
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
