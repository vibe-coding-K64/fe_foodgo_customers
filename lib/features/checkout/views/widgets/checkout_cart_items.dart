import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import 'checkout_cart_item.dart';

/// Widget danh sach cac mon an da chon o buoc checkout.
/// Hien thi danh sach voi Dismissible (vuot trai de xoa) va bo dem +/-.
class CheckoutCartItems extends StatelessWidget {
  final List<CheckoutCartItem> items;
  final void Function(int index, int newQuantity) onQuantityChanged;
  final void Function(int index) onItemRemoved;
  final VoidCallback? onAddMoreTap;

  const CheckoutCartItems({
    super.key,
    required this.items,
    required this.onQuantityChanged,
    required this.onItemRemoved,
    this.onAddMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tieu de.
        Row(
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              LanguageService.translate('checkout_your_order'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Danh sach mon.
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _CartItemCard(
              item: items[index],
              onDecrease: () {
                final newQty = items[index].quantity - 1;
                if (newQty >= 1) {
                  onQuantityChanged(index, newQty);
                }
              },
              onIncrease: () {
                onQuantityChanged(index, items[index].quantity + 1);
              },
              onDismiss: () {
                debugPrint('Xoa mon: ${items[index].name}');
                onItemRemoved(index);
              },
            );
          },
        ),
        const SizedBox(height: 12),
        // Nut them mon khac.
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              debugPrint('Checkout: Nguoi dung bam them mon khac');
              onAddMoreTap?.call();
            },
            icon: const Icon(Icons.add, size: 20),
            label: Text(LanguageService.translate('checkout_add_more')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CheckoutCartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onDismiss;

  const _CartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
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
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Hinh anh mon an.
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.fastfood, color: AppColors.textHint),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Thong tin mon an.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.toppings.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.toppingsLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${_formatPrice(item.unitPrice)} ${LanguageService.translate('unit_currency')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Bo dem so luong.
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildCounterButton(
                    icon: Icons.remove,
                    onTap: item.quantity > 1 ? onDecrease : null,
                    enabled: item.quantity > 1,
                  ),
                  SizedBox(
                    width: 32,
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
                  _buildCounterButton(
                    icon: Icons.add,
                    onTap: onIncrease,
                    enabled: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textHint,
          size: 16,
        ),
      ),
    );
  }
}
