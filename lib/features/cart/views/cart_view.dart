import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/state/cart_state.dart';
import '../../../core/utils/auth_storage.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../features/product/views/product_detail_bottom_sheet.dart';
import '../../../features/restaurant/services/restaurant_service.dart';
import '../../checkout/views/checkout_view.dart';
import '../models/cart_item_model.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/cart_bottom_bar.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  void _startListening() {
    final userId = AuthStorage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      CartState.of(context).startListening(userId);
    }
  }

  @override
  void dispose() {
    CartState.of(context).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('CartView: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('cart_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: CartState.of(context),
        builder: (context, _) {
          final cartState = CartState.of(context);

          if (cartState.isLoading) {
            return _buildLoadingState();
          }

          if (cartState.errorMessage != null) {
            return _buildErrorState(cartState.errorMessage!);
          }

          if (cartState.isEmpty) {
            return _buildEmptyState();
          }

          return _CartContent(cartState: cartState);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _CartItemSkeleton(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              context.t('error_server'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(context.t('common_retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.t('cart_empty_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t('cart_empty_desc'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                debugPrint('CartView: Quay lai trang chu xem thuc don');
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(context.t('cart_add_items')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends StatefulWidget {
  final CartState cartState;

  const _CartContent({required this.cartState});

  @override
  State<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<_CartContent> {
  final Set<String> _selectedIds = {};
  String? _activeStoreId;

  final Map<String, String> _storeNames = {};

  @override
  void initState() {
    super.initState();
    _loadStoreNames();
  }

  @override
  void didUpdateWidget(covariant _CartContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartState.items != widget.cartState.items) {
      _loadStoreNames();
    }
  }

  Future<void> _loadStoreNames() async {
    final uniqueStoreIds =
        widget.cartState.items.map((e) => e.storeId).toSet();

    for (final storeId in uniqueStoreIds) {
      if (!_storeNames.containsKey(storeId)) {
        final store = await RestaurantService.getStoreById(storeId);
        if (mounted && store != null) {
          setState(() {
            _storeNames[storeId] = store.name;
          });
        }
      }
    }
  }

  void _onTapItem(CartItemModel item) {
    final product = item.product;
    if (product != null && mounted) {
      showProductDetailSheet(context, product);
    } else if (mounted) {
      showTopSnackBar(
        context,
        message: 'Khong lay duoc thong tin san pham',
        backgroundColor: AppColors.error,
      );
    }
  }

  double _itemTotalPrice(CartItemModel item) {
    return item.totalPriceOf(item.product);
  }

  double get _subtotal {
    return widget.cartState.items
        .where((item) =>
            _activeStoreId != null &&
            item.storeId == _activeStoreId &&
            _selectedIds.contains(item.id))
        .fold<double>(0, (sum, item) => sum + _itemTotalPrice(item));
  }

  int get _selectedCount => _selectedIds.length;

  void _onToggleItem(String itemId, bool selected, String itemStoreId) {
    setState(() {
      if (selected) {
        if (_activeStoreId != null && _activeStoreId != itemStoreId) {
          _selectedIds.clear();
        }
        _activeStoreId = itemStoreId;
        _selectedIds.add(itemId);
      } else {
        _selectedIds.remove(itemId);
        final stillSelected = widget.cartState.items
            .where((i) => _selectedIds.contains(i.id) && i.storeId == itemStoreId)
            .toList();
        if (stillSelected.isEmpty) {
          _activeStoreId = null;
        }
      }
    });
  }

  void _onIncrease(CartItemModel item) {
    final userId = AuthStorage.getUserId();
    if (userId == null) return;
    widget.cartState.updateQuantity(userId, item.id, item.quantity + 1);
  }

  void _onDecrease(CartItemModel item) {
    final userId = AuthStorage.getUserId();
    if (userId == null) return;
    if (item.quantity > 1) {
      widget.cartState.updateQuantity(userId, item.id, item.quantity - 1);
    }
  }

  bool _isStoreFullySelected(String storeId) {
    final storeItems = widget.cartState.items.where((i) => i.storeId == storeId).toList();
    return storeItems.isNotEmpty && storeItems.every((i) => _selectedIds.contains(i.id));
  }

  void _onToggleStoreAll(String storeId) {
    final storeItems = widget.cartState.items.where((i) => i.storeId == storeId).toList();
    final isFullySelected = _isStoreFullySelected(storeId);

    setState(() {
      if (isFullySelected) {
        for (final item in storeItems) {
          _selectedIds.remove(item.id);
        }
      } else {
        if (_activeStoreId != null && _activeStoreId != storeId) {
          _selectedIds.clear();
        }
        _activeStoreId = storeId;
        for (final item in storeItems) {
          if (!(item.product?.isOutOfStock ?? false)) {
            _selectedIds.add(item.id);
          }
        }
      }
      if (_selectedIds.isEmpty) {
        _activeStoreId = null;
      }
    });
  }

  void _onQuantityChanged(CartItemModel item, int qty) {
    final userId = AuthStorage.getUserId();
    if (userId == null) return;
    widget.cartState.updateQuantity(userId, item.id, qty);
  }

  void _onDismissItem(CartItemModel item) {
    final userId = AuthStorage.getUserId();
    if (userId == null) return;
    final productName = item.product?.name;
    _selectedIds.remove(item.id);
    if (_activeStoreId == item.storeId) {
      final stillInCart = widget.cartState.items
          .where((i) => i.id != item.id && i.storeId == item.storeId)
          .toList();
      if (stillInCart.isEmpty) {
        _activeStoreId = null;
      }
    }
    widget.cartState.removeItem(userId, item.id);
    showTopSnackBar(
      context,
      message: '${productName ?? 'Mon an'} ${context.t('cart_item_removed')}',
      backgroundColor: AppColors.textSecondary,
    );
  }

  void _onCheckout() {
    final selectedItems = widget.cartState.items
        .where((item) => _selectedIds.contains(item.id))
        .toList();

    if (selectedItems.isEmpty) {
      showTopSnackBar(
        context,
        message: context.t('cart_checkout_no_selection'),
        backgroundColor: AppColors.error,
      );
      return;
    }

    debugPrint(
      'CartView: Chuyen sang trang thanh toan voi ${selectedItems.length} mon da chon',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutView(
          selectedCartItems: selectedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.cartState.items;
    final isEmpty = items.isEmpty;

    final grouped = <String, List<CartItemModel>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.storeId, () => []).add(item);
    }
    final storeIds = grouped.keys.toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: storeIds.length,
            itemBuilder: (context, index) {
              final storeId = storeIds[index];
              final storeItems = grouped[storeId]!;
              final storeName = _storeNames[storeId] ?? '...';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 4,
                      bottom: 8,
                      top: index > 0 ? 8 : 0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            storeName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            debugPrint('CartView: Toggle chon tat ca cua hang [$storeName]');
                            _onToggleStoreAll(storeId);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isStoreFullySelected(storeId)
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isStoreFullySelected(storeId)
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 16,
                                  color: _isStoreFullySelected(storeId)
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  context.t('cart_select_all'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _isStoreFullySelected(storeId)
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...storeItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CartItemWidget(
                        item: item,
                        product: item.product,
                        isSelected: _selectedIds.contains(item.id),
                        isOutOfStock: item.product?.isOutOfStock ?? false,
                        onSelectionChanged: (selected) =>
                            _onToggleItem(item.id, selected, item.storeId),
                        onIncrease: () => _onIncrease(item),
                        onDecrease: () => _onDecrease(item),
                        onDismiss: () => _onDismissItem(item),
                        onItemTap: () => _onTapItem(item),
                        onQuantityChanged: (qty) => _onQuantityChanged(item, qty),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        if (!isEmpty)
          CartBottomBar(
            selectedCount: _selectedCount,
            subtotal: _subtotal,
            onCheckout: _onCheckout,
          ),
      ],
    );
  }
}

class _CartItemSkeleton extends StatelessWidget {
  const _CartItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
