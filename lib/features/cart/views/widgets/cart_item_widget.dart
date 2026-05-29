import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../models/cart_item_model.dart';

/// Widget hien thi mot item trong danh sach gio hang.
///
/// Co checkbox, hinh anh, ten, don gia, bo dem +/-, va Dismissible xoa.
class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDismiss;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDismiss,
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
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        debugPrint('CartView: Vuot xoa mon [${item.name}]');
        onDismiss();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 26,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox chon mon.
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  debugPrint(
                      'CartView: Checkbox mon [${item.name}] = ${value ?? false}');
                  onSelectionChanged(value ?? false);
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Hinh anh san pham.
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrlOrDefault,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  debugPrint('CartItemImage: [${item.name}] Dang tai anh: ${item.imageUrlOrDefault}');
                  return Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textHint,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('CartItemImage: [${item.name}] Loi tai anh: ${item.imageUrlOrDefault}');
                  debugPrint('CartItemImage: Error = $error, stack = $stackTrace');
                  return Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      color: AppColors.textHint,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Thong tin san pham.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.size != null && item.size!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      context
                          .t('cart_item_size')
                          .replaceFirst('\$1', item.size!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (item.toppings.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      context
                          .t('cart_item_topping')
                          .replaceFirst('\$1', item.toppingsLabel),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      context
                          .t('cart_item_note')
                          .replaceFirst('\$1', item.note!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${_formatPrice(item.price)} ${context.t('unit_currency')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (item.quantity > 1) ...[
                        const SizedBox(width: 6),
                        Text(
                          'x${item.quantity}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatPrice(item.totalPrice)} ${context.t('unit_currency')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Bo dem so luong.
                  _buildQuantityControl(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nut giam.
          GestureDetector(
            onTap: item.quantity > 1
                ? () {
                    debugPrint(
                        'CartView: Giam so luong mon [${item.name}] = ${item.quantity - 1}');
                    onDecrease();
                  }
                : null,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                color:
                    item.quantity > 1 ? AppColors.primary : AppColors.textHint,
                size: 16,
              ),
            ),
          ),
          // So luong hien thi.
          SizedBox(
            width: 36,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Nut tang.
          GestureDetector(
            onTap: () {
              debugPrint(
                  'CartView: Tang so luong mon [${item.name}] = ${item.quantity + 1}');
              onIncrease();
            },
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
