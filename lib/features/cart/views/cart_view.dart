import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../checkout/views/checkout_view.dart';
import 'widgets/cart_item_model.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/cart_bottom_bar.dart';

/// Man hinh Gio hang (CartView).
///
/// Hien thi danh sach mon da chon voi cac chuc nang:
/// - Checkbox chon/tick mon de tinh tam tinh
/// - Dismissible (vuot trai xoa mon)
/// - Bo dem so luong +/-
/// - Sticky Bottom Bar: chon tat ca, tam tinh chi tien cac mon duoc tick,
///   nut "Mua hang (X)"
///
/// Luong: HomeView [FAB Gio hang] -> CartView -> CheckoutView
class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  /// Danh sach mon trong gio hang.
  late List<CartItemViewModel> _items;

  /// Khoi tao du lieu gia cho gio hang.
  @override
  void initState() {
    super.initState();
    _items = [
      CartItemViewModel(
        id: 'cart_001',
        name: 'Tra Sua Tran Chau Duong',
        imageUrl: 'https://picsum.photos/seed/milktea1/200',
        unitPrice: 35000,
        quantity: 2,
        isSelected: true,
        toppings: [
          CartTopping(name: 'Tran chau', price: 5000),
          CartTopping(name: 'Thach ca phe', price: 8000),
        ],
      ),
      CartItemViewModel(
        id: 'cart_002',
        name: 'Ca phe sua da',
        imageUrl: 'https://picsum.photos/seed/coffee2/200',
        unitPrice: 29000,
        quantity: 1,
        isSelected: true,
        toppings: [
          CartTopping(name: 'Da', price: 0),
        ],
      ),
      CartItemViewModel(
        id: 'cart_003',
        name: 'Tra vai Thach Vuive',
        imageUrl: 'https://picsum.photos/seed/greentea3/200',
        unitPrice: 42000,
        quantity: 1,
        isSelected: true,
        toppings: [
          CartTopping(name: 'Trai cay', price: 12000),
          CartTopping(name: 'Pudding', price: 6000),
        ],
      ),
      CartItemViewModel(
        id: 'cart_004',
        name: 'Banh mi cha bong',
        imageUrl: 'https://picsum.photos/seed/baguette4/200',
        unitPrice: 25000,
        quantity: 1,
        isSelected: false,
        toppings: [],
      ),
    ];
  }

  /// Tinh tam tinh chi tong tien cac mon dang duoc tick.
  double get _subtotal {
    return _items
        .where((item) => item.isSelected)
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  /// Dem so mon dang duoc tick.
  int get _selectedCount {
    return _items.where((item) => item.isSelected).length;
  }

  /// Kiem tra tat ca duoc tick chua.
  bool get _isAllSelected {
    return _items.isNotEmpty && _items.every((item) => item.isSelected);
  }

  /// Xu ly khi bam checkbox chon tat ca.
  void _onToggleSelectAll() {
    final newValue = !_isAllSelected;
    setState(() {
      for (final item in _items) {
        item.isSelected = newValue;
      }
    });
    debugPrint('CartView: Chon tat ca = $newValue');
  }

  /// Xu ly khi bam checkbox cua mot mon.
  void _onToggleItem(int index, bool selected) {
    setState(() {
      _items[index].isSelected = selected;
    });
  }

  /// Xu ly khi tang so luong.
  void _onIncrease(int index) {
    setState(() {
      _items[index].quantity++;
    });
  }

  /// Xu ly khi giam so luong.
  void _onDecrease(int index) {
    if (_items[index].quantity > 1) {
      setState(() {
        _items[index].quantity--;
      });
    }
  }

  /// Xu ly khi vuot xoa mot mon.
  void _onDismissItem(int index) {
    final removedItem = _items[index];
    setState(() {
      _items.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${removedItem.name} ${LanguageService.translate('cart_item_removed')}',
        ),
        backgroundColor: AppColors.textSecondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Xu ly khi bam nut "Mua hang".
  void _onCheckout() {
    debugPrint('CartView: Chuyen sang trang thanh toan');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutView(),
      ),
    );
  }

  /// Hien thi giao dien khi gio hang trong.
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
              LanguageService.translate('cart_empty_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LanguageService.translate('cart_empty_desc'),
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(LanguageService.translate('cart_add_items')),
            ),
          ],
        ),
      ),
    );
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
          LanguageService.translate('cart_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          // Nut xoa tat ca (chi hien khi co mon).
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              onPressed: () {
                debugPrint('CartView: Nguoi dung bam xoa tat ca');
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      LanguageService.translate('cart_clear'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      LanguageService.translate('cart_clear_confirm'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          LanguageService.translate('common_cancel'),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _items.clear();
                          });
                          debugPrint('CartView: Da xoa tat ca mon trong gio hang');
                        },
                        child: Text(
                          LanguageService.translate('common_delete'),
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Danh sach mon.
          Expanded(
            child: _items.isEmpty
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
          if (_items.isNotEmpty)
            CartBottomBar(
              isAllSelected: _isAllSelected,
              selectedCount: _selectedCount,
              totalCount: _items.length,
              subtotal: _subtotal,
              onSelectAllChanged: _onToggleSelectAll,
              onCheckout: _onCheckout,
            ),
        ],
      ),
    );
  }
}
