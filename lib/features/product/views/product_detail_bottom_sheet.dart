import 'package:flutter/material.dart';
import '../../home/models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Mo bottom sheet chi tiet mon an voi ProductModel.
void showProductDetailSheet(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductDetailBottomSheet(product: product),
  );
}

/// Widget Bottom Sheet chi tiet mon an (chon Topping).
class ProductDetailBottomSheet extends StatefulWidget {
  final ProductModel product;

  const ProductDetailBottomSheet({super.key, required this.product});

  @override
  State<ProductDetailBottomSheet> createState() => _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
  // So luong mon.
  int _quantity = 1;

  // Lua chon size (Radio - chi 1).
  String _selectedSize = 'small';
  final Map<String, double> _sizePrices = {
    'small': 0,
    'medium': 5000,
    'large': 10000,
  };

  // Lua chon muc do da (Radio - chi 1).
  String _selectedIceLevel = '100';
  final List<String> _iceLevels = ['100', '70', '50', 'none'];

  // Lua chon topping (Checkbox - nhieu).
  final Set<String> _selectedToppings = {};
  final Map<String, double> _toppingPrices = {
    'pearl': 10000,
    'fruit_jelly': 8000,
    'pudding': 12000,
    'cheese': 15000,
  };

  // Noi dung ghi chu.
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Tinh tong gia cua cac topping da chon.
  double get _toppingTotal {
    return _selectedToppings.fold(0, (sum, key) => sum + (_toppingPrices[key] ?? 0));
  }

  /// Tinh them gia size.
  double get _sizeExtra {
    return _sizePrices[_selectedSize] ?? 0;
  }

  /// Tinh tong tien moi mon (chua nhan so luong).
  double get _itemPrice {
    return widget.product.basePrice + _sizeExtra + _toppingTotal;
  }

  /// Tinh tong thanh toan (da nhan so luong).
  double get _totalPrice {
    return _itemPrice * _quantity;
  }

  /// Tao chuoi gia hien thi (VD: +10.000d).
  String _formatPrice(double price) {
    if (price == 0) return '';
    final str = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '+$str';
  }

  /// Tao chuoi gia tien day du (VD: 25.000d).
  String _formatFullPrice(double price) {
    final str = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '$str';
  }

  /// Tao label cho tuy chon size.
  String _getSizeLabel(BuildContext context, String size) {
    switch (size) {
      case 'small':
        return context.t('product_size_small');
      case 'medium':
        return context.t('product_size_medium');
      case 'large':
        return context.t('product_size_large');
      default:
        return size;
    }
  }

  /// Tao label cho muc do da.
  String _getIceLabel(BuildContext context, String level) {
    switch (level) {
      case '100':
        return context.t('product_ice_100');
      case '70':
        return context.t('product_ice_70');
      case '50':
        return context.t('product_ice_50');
      case 'none':
        return context.t('product_ice_none');
      default:
        return level;
    }
  }

  /// Tao label cho topping.
  String _getToppingLabel(BuildContext context, String topping) {
    switch (topping) {
      case 'pearl':
        return context.t('product_topping_pearl');
      case 'fruit_jelly':
        return context.t('product_topping_fruit_jelly');
      case 'pudding':
        return context.t('product_topping_pudding');
      case 'cheese':
        return context.t('product_topping_cheese');
      default:
        return topping;
    }
  }

  /// Tra ve widget nut giam so luong.
  Widget _buildMinusButton() {
    return GestureDetector(
      onTap: _quantity > 1
          ? () {
              setState(() => _quantity--);
              debugPrint('Giam so luong: $_quantity');
            }
          : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _quantity > 1 ? AppColors.surfaceVariant : AppColors.border.withAlpha(80),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.remove,
          color: _quantity > 1 ? AppColors.textPrimary : AppColors.textHint,
          size: 20,
        ),
      ),
    );
  }

  /// Tra ve widget nut tang so luong.
  Widget _buildPlusButton() {
    return GestureDetector(
      onTap: () {
        setState(() => _quantity++);
        debugPrint('Tang so luong: $_quantity');
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// Tra ve widget phan lua chon size (Radio).
  Widget _buildSizeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.t('product_size'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._sizePrices.keys.map((size) {
          final extra = _sizePrices[size] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSizeItem(context, size, extra),
          );
        }),
      ],
    );
  }

  Widget _buildSizeItem(BuildContext context, String size, double extra) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSize = size);
        debugPrint('Chon size: ${_getSizeLabel(context, size)}, gia them: $extra');
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedSize == size ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: _selectedSize == size
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            _getSizeLabel(context, size),
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
          if (extra > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatPrice(extra),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (size == 'small') ...[
            const Spacer(),
            Text(
              context.t('common_confirm').toLowerCase().replaceFirst(
                context.t('common_confirm')[0],
                context.t('common_confirm')[0].toUpperCase(),
              ),
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }

  /// Tra ve widget phan lua chon muc do da (Radio).
  Widget _buildIceLevelSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.t('product_ice_level'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _iceLevels.map((level) {
            final isSelected = _selectedIceLevel == level;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedIceLevel = level);
                debugPrint('Chon muc do da: ${_getIceLabel(context, level)}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withAlpha(25) : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _getIceLabel(context, level),
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Tra ve widget phan lua chon topping (Checkbox).
  Widget _buildToppingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('product_topping'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._toppingPrices.entries.map((entry) {
          final isSelected = _selectedToppings.contains(entry.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedToppings.remove(entry.key);
                  } else {
                    _selectedToppings.add(entry.key);
                  }
                });
                debugPrint(
                  'Topping: ${_getToppingLabel(context, entry.key)} - ${isSelected ? 'bo chon' : 'chon'}',
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getToppingLabel(context, entry.key),
                      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    _formatPrice(entry.value),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Tra ve widget ghi chu nhap lieu nhieu dong.
  Widget _buildNoteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('cart_note'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.t('product_note_hint'),
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
            contentPadding: const EdgeInsets.all(14),
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  /// Tra ve widget thanh hanh dong bat chan (Sticky Bottom Bar).
  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
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
          // Bo dem so luong.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _buildMinusButton(),
                const SizedBox(width: 4),
                SizedBox(
                  width: 32,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildPlusButton(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Nut them vao gio hang.
          Expanded(
            child: GestureDetector(
              onTap: () {
                debugPrint('Them vao gio hang: $_quantity x ${widget.product.name}');
                debugPrint('  Size: ${_getSizeLabel(context, _selectedSize)} (+${_formatPrice(_sizeExtra)})');
                debugPrint('  Muc do da: ${_getIceLabel(context, _selectedIceLevel)}');
                debugPrint('  Topping: ${_selectedToppings.map((t) => _getToppingLabel(context, t)).join(', ')}');
                debugPrint('  Ghi chu: ${_noteController.text}');
                debugPrint('  Tong tien: ${_formatFullPrice(_totalPrice)}');
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.t('product_add_to_cart'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatFullPrice(_totalPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Noi dung co the cuon.
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========== ANH MON AN ==========
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          widget.product.imageUrl,
                          width: double.infinity,
                          height: screenHeight * 0.3,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: screenHeight * 0.3,
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: AppColors.textHint,
                              ),
                            );
                          },
                        ),
                      ),
                      // Nut dong.
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.overlay,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ========== THONG TIN MON AN ==========
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFullPrice(widget.product.basePrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: AppColors.divider, height: 24),
                  ),

                  // ========== LUA CHON SIZE ==========
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSizeSection(context),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: AppColors.divider, height: 24),
                  ),

                  // ========== LUA CHON MUC DO DA ==========
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildIceLevelSection(context),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: AppColors.divider, height: 24),
                  ),

                  // ========== LUA CHON TOPPING ==========
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildToppingSection(context),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: AppColors.divider, height: 24),
                  ),

                  // ========== GHI CHU ==========
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _buildNoteSection(context),
                  ),

                  // Khoang trong duoi cung cua phan cuon (truoc sticky bar).
                  SizedBox(height: bottomPadding > 0 ? 0 : 16),
                ],
              ),
            ),
          ),

          // ========== STICKY BOTTOM BAR ==========
          _buildStickyBottomBar(context),
        ],
      ),
    );
  }
}
