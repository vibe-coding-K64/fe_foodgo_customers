import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../../home/models/product_model.dart';
import '../../models/cart_item_model.dart';

/// Widget hien thi mot item trong danh sach gio hang.
///
/// [product] duoc truyen vao de tinh gia chinh xac (basePrice + sizePrice + toppings).
/// [isOutOfStock] cho biet san pham co dang het hang hay khong.
/// Neu het hang: item bi mo di, checkbox bi disable, khong cho tang/giam so luong.
class CartItemWidget extends StatefulWidget {
  final CartItemModel item;
  final ProductModel? product;
  final bool isSelected;
  final bool isOutOfStock;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDismiss;
  final VoidCallback onItemTap;
  final ValueChanged<int> onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    this.product,
    required this.isSelected,
    required this.isOutOfStock,
    required this.onSelectionChanged,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDismiss,
    required this.onItemTap,
    required this.onQuantityChanged,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController _quantityController;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '${widget.item.quantity}');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity && !_isEditing) {
      _quantityController.text = '${widget.item.quantity}';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _submitQuantity();
    }
  }

  void _submitQuantity() {
    _isEditing = false;
    final text = _quantityController.text.trim();
    if (text.isEmpty) {
      _quantityController.text = '${widget.item.quantity}';
      return;
    }
    final qty = int.tryParse(text);
    if (qty == null || qty <= 0) {
      _quantityController.text = '${widget.item.quantity}';
      return;
    }
    if (qty != widget.item.quantity) {
      final diff = qty - widget.item.quantity;
      if (diff > 0) {
        for (int i = 0; i < diff; i++) {
          widget.onIncrease();
        }
      } else {
        for (int i = 0; i < (-diff); i++) {
          widget.onDecrease();
        }
      }
    }
    FocusScope.of(context).unfocus();
  }

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
      key: Key(widget.item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        debugPrint('CartView: Vuot xoa mon [${widget.product?.name ?? widget.item.foodId}]');
        widget.onDismiss();
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
      child: Opacity(
        opacity: widget.isOutOfStock ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
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
                  value: widget.isSelected,
                  onChanged: widget.isOutOfStock
                      ? null
                      : (value) {
                          debugPrint(
                              'CartView: Checkbox mon [${widget.product?.name ?? widget.item.foodId}] = ${value ?? false}');
                          widget.onSelectionChanged(value ?? false);
                        },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: widget.isSelected
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
                  widget.item.imageUrlOrDefault,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    debugPrint('CartItemImage: [${widget.product?.name ?? widget.item.foodId}] Dang tai anh: ${widget.item.imageUrlOrDefault}');
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
                    debugPrint('CartItemImage: [${widget.product?.name ?? widget.item.foodId}] Loi tai anh: ${widget.item.imageUrlOrDefault}');
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
              // Thong tin san pham (tap de xem chi tiet).
              Expanded(
                child: GestureDetector(
                  onTap: widget.onItemTap,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product?.name ?? '...',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Hien thi tung option da chon, bo qua neu khong tim thay trong product.
                      ..._buildOptionLines(),
                      if (widget.item.note != null && widget.item.note!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          context
                              .t('cart_item_note')
                              .replaceFirst('\$1', widget.item.note!),
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
                      Text(
                        '${_formatPrice(widget.product != null ? widget.item.unitPriceOf(widget.product) : 0.0)} ${context.t('unit_currency')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Bo dem so luong.
                      _buildQuantityControl(),
                      if (widget.isOutOfStock) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            context.t('product_out_of_stock'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build cac dong hien thi options da chon, gop theo nhom.
  /// VD: "Topping: Tran chau, Pudding", "Kich thuoc: Lon".
  List<Widget> _buildOptionLines() {
    if (widget.product == null || widget.item.selectedOptions.isEmpty) return [];

    final lines = <String>[];
    for (final group in widget.item.selectedOptions) {
      final productGroup = widget.product!.optionGroups
          .where((g) => g.name == group.name)
          .firstOrNull;
      if (productGroup == null) continue;

      final validNames = <String>[];
      for (final opt in group.options) {
        final productOption = productGroup.options
            .where((o) => o.name == opt.name)
            .firstOrNull;
        if (productOption != null) {
          validNames.add(opt.name);
        }
      }
      if (validNames.isEmpty) continue;

      lines.add('${group.name}: ${validNames.join(', ')}');
    }

    return lines
        .map((line) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ))
        .toList();
  }

  Widget _buildQuantityControl() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nut giam.
          GestureDetector(
            onTap: !widget.isOutOfStock && widget.item.quantity > 1
                ? () {
                    debugPrint(
                        'CartView: Giam so luong mon [${widget.product?.name ?? widget.item.foodId}] = ${widget.item.quantity - 1}');
                    FocusScope.of(context).unfocus();
                    widget.onDecrease();
                  }
                : null,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                color:
                    !widget.isOutOfStock && widget.item.quantity > 1 ? AppColors.primary : AppColors.textHint,
                size: 22,
              ),
            ),
          ),
          // So luong nhap tay.
          Container(
            width: 52,
            height: 40,
            alignment: Alignment.center,
            child: TextField(
              controller: _quantityController,
              focusNode: _focusNode,
              enabled: !widget.isOutOfStock,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              onTap: () {
                _isEditing = true;
              },
              onSubmitted: (_) => _submitQuantity(),
              onChanged: (_) {
                _isEditing = true;
              },
            ),
          ),
          // Nut tang.
          GestureDetector(
            onTap: widget.isOutOfStock
                ? null
                : () {
                    debugPrint(
                        'CartView: Tang so luong mon [${widget.product?.name ?? widget.item.foodId}] = ${widget.item.quantity + 1}');
                    FocusScope.of(context).unfocus();
                    widget.onIncrease();
                  },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                color: widget.isOutOfStock ? AppColors.textHint : AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
