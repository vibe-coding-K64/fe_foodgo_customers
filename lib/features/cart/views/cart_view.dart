import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../checkout/views/checkout_view.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/cart_bottom_bar.dart';

/// Man hinh Gio hang (CartView).
///
/// Su dung FutureBuilder goi CartService.getCart() de lay du lieu tu API.
///
/// Hien thi danh sach mon da chon voi cac chuc nang:
///   - Checkbox chon/tick mon de tinh tam tinh
///   - Dismissible (vuot trai xoa mon)
///   - Bo dem so luong +/-
///   - Sticky Bottom Bar: chon tat ca, tam tinh chi tien cac mon duoc tick,
///     nut "Mua hang (X)"
///
/// Luong: HomeView [FAB Gio hang] -> CartView -> CheckoutView
class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final CartService _cartService = const CartService();

  late final Future<CartModel> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCart();
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
      body: FutureBuilder<CartModel>(
        future: _cartFuture,
        builder: (context, snapshot) {
          // Dang tai.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // Co loi.
          if (snapshot.hasError) {
            debugPrint('CartView: loi tai gio hang - ${snapshot.error}');
            return _buildErrorState(snapshot.error.toString());
          }

          final cart = snapshot.data;

          if (cart == null || cart.isEmpty) {
            return _buildEmptyState();
          }

          // Co du lieu -> hien thi danh sach + bottom bar.
          return _CartContent(
            cart: cart,
            onRetry: () {
              setState(() {
                _cartFuture = _cartService.getCart();
              });
            },
          );
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
              onPressed: () {
                setState(() {
                  _cartFuture = _cartService.getCart();
                });
              },
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

/// Noi dung chinh cua gio hang, quan ly trang thai local (tick, so luong).
///
/// tach rieng de StateFulWidget co the cap nhat local state.
class _CartContent extends StatefulWidget {
  final CartModel cart;
  final VoidCallback onRetry;

  const _CartContent({required this.cart, required this.onRetry});

  @override
  State<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<_CartContent> {
  late List<CartItem> _items;

  @override
  void initState() {
    super.initState();
    // Tao ban sao items de quan ly trang thai local.
    _items = widget.cart.items.map((item) => item.copyWith()).toList();
  }

  double get _subtotal {
    return _items
        .where((item) => item.isSelected)
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  int get _selectedCount {
    return _items.where((item) => item.isSelected).length;
  }

  bool get _isAllSelected {
    return _items.isNotEmpty && _items.every((item) => item.isSelected);
  }

  void _onToggleSelectAll() {
    final newValue = !_isAllSelected;
    setState(() {
      for (final item in _items) {
        item.isSelected = newValue;
      }
    });
    debugPrint('CartView: Chon tat ca = $newValue');
  }

  void _onToggleItem(int index, bool selected) {
    setState(() {
      _items[index].isSelected = selected;
    });
  }

  void _onIncrease(int index) {
    setState(() {
      _items[index].quantity++;
    });
  }

  void _onDecrease(int index) {
    if (_items[index].quantity > 1) {
      setState(() {
        _items[index].quantity--;
      });
    }
  }

  void _onDismissItem(int index) {
    final removedItem = _items[index];
    setState(() {
      _items.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.name} ${context.t('cart_item_removed')}'),
        backgroundColor: AppColors.textSecondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onCheckout() {
    debugPrint('CartView: Chuyen sang trang thanh toan');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _items.isEmpty;

    return Column(
      children: [
        // Thong tin cua hang (neu co).
        if (!isEmpty) _buildStoreHeader(),
        // Danh sach mon.
        Expanded(
          child: isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return CartItemWidget(
                      item: item,
                      onSelectionChanged: (selected) =>
                          _onToggleItem(index, selected),
                      onIncrease: () => _onIncrease(index),
                      onDecrease: () => _onDecrease(index),
                      onDismiss: () => _onDismissItem(index),
                    );
                  },
                ),
        ),
        // Sticky Bottom Bar (chi hien khi co mon).
        if (!isEmpty)
          CartBottomBar(
            isAllSelected: _isAllSelected,
            selectedCount: _selectedCount,
            totalCount: _items.length,
            subtotal: _subtotal,
            onSelectAllChanged: _onToggleSelectAll,
            onCheckout: _onCheckout,
          ),
      ],
    );
  }

  Widget _buildStoreHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              widget.cart.storeImageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 40,
                color: AppColors.surfaceVariant,
                child: Icon(Icons.store, color: AppColors.textHint, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cart.storeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.cart.itemCount} ${context.t('unit_items')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.t('cart_empty_title'),
              style: const TextStyle(
                fontSize: 16,
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
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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

/// Skeleton item khi loading gio hang.
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
