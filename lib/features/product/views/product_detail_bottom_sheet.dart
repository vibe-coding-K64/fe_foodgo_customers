import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/state/cart_state.dart';
import '../../../core/utils/auth_storage.dart';
import '../../cart/models/cart_item_model.dart';
import '../../home/models/product_model.dart';

/// Mo bottom sheet chi tiet mon an voi ProductModel.
void showProductDetailSheet(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductDetailBottomSheet(product: product),
  );
}

/// Widget Bottom Sheet chi tiet mon an.
/// Render dong optionGroups tu ProductModel.
/// Tinh tong gia real-time va goi CartState.addItem() khi bam "Them vao gio hang".
class ProductDetailBottomSheet extends StatefulWidget {
  final ProductModel product;

  const ProductDetailBottomSheet({super.key, required this.product});

  @override
  State<ProductDetailBottomSheet> createState() =>
      _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState
    extends State<ProductDetailBottomSheet> {
  int _quantity = 1;

  /// Map: groupName -> Set of selected option names.
  /// Dung cho tat ca optionGroups (cả single-select và multi-select).
  final Map<String, Set<String>> _selectedOptions = {};

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDefaultSelections();
  }

  /// Khoi tao selection mac dinh: voi single-select chon option dau tien,
  /// voi multi-select khong chon gi (hoac co the chon option dau tien tuy y).
  void _initDefaultSelections() {
    for (final group in widget.product.optionGroups) {
      if (group.options.isEmpty) continue;

      if (group.isSingleSelect) {
        // Single-select: chon option dau tien.
        _selectedOptions[group.name] = {group.options.first.name};
      } else {
        // Multi-select: khong chon gi mac dinh (user tu chon).
        _selectedOptions[group.name] = {};
      }
    }
  }

  /// Lay gia tri cua tat ca options dang duoc chon.
  double get _optionsTotal {
    double total = 0;
    for (final group in widget.product.optionGroups) {
      for (final option in group.options) {
        if (_selectedOptions[group.name]?.contains(option.name) == true) {
          total += option.price;
        }
      }
    }
    return total;
  }

  double get _totalPrice {
    return (widget.product.basePrice + _optionsTotal) * _quantity;
  }

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return str;
  }

  void _onSingleSelect(String groupName, String optionName) {
    setState(() {
      _selectedOptions[groupName] = {optionName};
    });
  }

  void _onMultiSelect(String groupName, String optionName) {
    setState(() {
      final current = _selectedOptions[groupName] ?? {};
      if (current.contains(optionName)) {
        current.remove(optionName);
      } else {
        current.add(optionName);
      }
      _selectedOptions[groupName] = current;
    });
  }

  Future<void> _onAddToCart() async {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('auth_login')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Build selectedOptions tu _selectedOptions map.
    final selectedOptions = <SelectedOptionGroup>[];
    for (final group in widget.product.optionGroups) {
      final selectedNames = _selectedOptions[group.name];
      if (selectedNames == null || selectedNames.isEmpty) continue;
      selectedOptions.add(SelectedOptionGroup(
        name: group.name,
        options: selectedNames
            .map((name) => SelectedOption(name: name))
            .toList(),
      ));
    }

    final cartState = CartState.of(context);
    final result = await cartState.addItem(
      userId,
      widget.product,
      selectedOptions: selectedOptions,
      note: _noteController.text.trim(),
      quantity: _quantity,
    );

    if (!mounted) return;

    switch (result) {
      case CartAddResult.success:
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('success_add_to_cart')),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case CartAddResult.differentStore:
        _showDifferentStoreDialog(cartState);
        break;
      case CartAddResult.outOfStock:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartState.errorMessage ?? 'Mon an dang het hang.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case CartAddResult.notFound:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartState.errorMessage ?? 'San pham khong ton tai.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case CartAddResult.otherError:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartState.errorMessage ?? 'Loi them vao gio hang.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  void _showDifferentStoreDialog(CartState cartState) {
    final message = cartState.differentStoreErrorMessage ??
        'Gio hang hien co mon tu cua hang khac. Ban co muon xoa gio hang hien tai de them mon nay?';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cua hang khac'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Huy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final userId = AuthStorage.getUserId();
              if (userId == null) return;

              final result = await cartState.replaceCartAndAddItem(
                userId,
                widget.product,
                selectedOptions: () {
                  final groups = <SelectedOptionGroup>[];
                  for (final group in widget.product.optionGroups) {
                    final selectedNames = _selectedOptions[group.name];
                    if (selectedNames == null || selectedNames.isEmpty) continue;
                    groups.add(SelectedOptionGroup(
                      name: group.name,
                      options: selectedNames
                          .map((name) => SelectedOption(name: name))
                          .toList(),
                    ));
                  }
                  return groups;
                }(),
                note: _noteController.text.trim(),
                quantity: _quantity,
              );

              if (!mounted) return;

              if (result == CartAddResult.success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.t('success_add_to_cart')),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cartState.errorMessage ?? 'Loi them vao gio hang.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xoa va them moi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ========== NOI DUNG CUON ==========
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ANH MON AN ---
                  _buildProductImage(screenHeight),

                  // --- THONG TIN MON AN ---
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
                          '${_formatPrice(widget.product.basePrice)} ${context.t('unit_currency')}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        if (widget.product.description.isNotEmpty) ...[
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
                      ],
                    ),
                  ),

                  // --- DYNAMIC OPTION GROUPS ---
                  if (widget.product.optionGroups.isNotEmpty) ...[
                    const Divider(color: AppColors.divider, height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: widget.product.optionGroups
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final group = entry.value;
                          return Column(
                            children: [
                              _buildOptionGroup(group),
                              if (index <
                                  widget.product.optionGroups.length - 1)
                                const Divider(
                                    color: AppColors.divider, height: 24),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // --- GHI CHU ---
                  const Divider(color: AppColors.divider, height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _buildNoteSection(),
                  ),

                  SizedBox(height: bottomPadding > 0 ? 0 : 16),
                ],
              ),
            ),
          ),

          // ========== STICKY BOTTOM BAR ==========
          _buildStickyBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProductImage(double screenHeight) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Image.network(
            widget.product.imageUrl,
            width: double.infinity,
            height: screenHeight * 0.3,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: screenHeight * 0.3,
              color: AppColors.surfaceVariant,
              child: const Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
          ),
        ),
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
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionGroup(OptionGroupModel group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ten nhom + badge required/optional.
        Row(
          children: [
            Text(
              group.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: group.isRequired
                    ? AppColors.error.withAlpha(20)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                group.isRequired
                    ? context.t('required')
                    : context.t('optional'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: group.isRequired
                      ? AppColors.error
                      : AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Danh sach options.
        ...group.options.map((option) {
          final isSelected =
              _selectedOptions[group.name]?.contains(option.name) == true;
          return _buildOptionItem(
            group: group,
            option: option,
            isSelected: isSelected,
          );
        }),
      ],
    );
  }

  Widget _buildOptionItem({
    required OptionGroupModel group,
    required OptionModel option,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          if (group.isSingleSelect) {
            _onSingleSelect(group.name, option.name);
          } else {
            _onMultiSelect(group.name, option.name);
          }
        },
        child: Row(
          children: [
            // Radio / Checkbox.
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape:
                    group.isSingleSelect ? BoxShape.circle : BoxShape.rectangle,
                borderRadius:
                    group.isSingleSelect ? null : BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      group.isSingleSelect ? Icons.circle : Icons.check,
                      size: group.isSingleSelect ? 10 : 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.name,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (option.price > 0)
              Text(
                '+${_formatPrice(option.price)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
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
          style:
              const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar() {
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
          _buildQuantityControl(),
          const SizedBox(width: 16),
          // Nut them vao gio hang.
          Expanded(
            child: GestureDetector(
              onTap: _onAddToCart,
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
                      _formatPrice(_totalPrice),
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

  Widget _buildQuantityControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _quantity > 1
                ? () => setState(() => _quantity--)
                : null,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                color:
                    _quantity > 1 ? AppColors.primary : AppColors.textHint,
                size: 20,
              ),
            ),
          ),
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
          GestureDetector(
            onTap: () => setState(() => _quantity++),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
