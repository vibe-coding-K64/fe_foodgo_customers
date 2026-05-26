import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../features/cart/models/cart_item_model.dart';
import '../../features/cart/services/cart_service.dart';
import '../../features/home/models/product_model.dart';

/// State quan ly gio hang, dong bo real-time voi Firestore.
///
/// Lang nghe thay doi tu Firestore thong qua getCartStream,
/// dong thoi ho tro thao tac CRUD (them, cap nhat, xoa).
class CartState extends ChangeNotifier {
  final CartService _cartService = const CartService();

  List<CartItemModel> _items = [];
  StreamSubscription<List<CartItemModel>>? _subscription;
  bool _isLoading = true;
  String? _errorMessage;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get uniqueItemCount => _items.length;

  double get subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  Map<String, List<CartItemModel>> get itemsByStore {
    final Map<String, List<CartItemModel>> grouped = {};
    for (final item in _items) {
      grouped.putIfAbsent(item.storeId, () => []).add(item);
    }
    return grouped;
  }

  void startListening(String userId) {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _cartService.getCartStream(userId).listen(
      (items) {
        _items = items;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('CartState: Loi stream - $error');
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Reset toan bo state ve ban dau.
  /// Can goi khi nguoi dung dang nhap / chuyen doi tai khoan / dang xuat.
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _items = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Them mot san pham vao gio hang.
  ///
  /// Tu dong tao CartItemModel tu ProductModel + cac tuy chon nguoi dung da chon.
  Future<void> addItem(
    String userId,
    ProductModel product, {
    String? selectedSize,
    double? sizePrice,
    List<Map<String, dynamic>> selectedToppings = const [],
    String? note,
    int quantity = 1,
  }) async {
    try {
      // Tinh don gia: basePrice + sizePrice + tong gia toppings.
      final toppings = selectedToppings
          .map((t) => CartTopping(
                name: t['name'] as String,
                price: (t['price'] as num).toDouble(),
              ))
          .toList();

      final toppingsTotal =
          toppings.fold<double>(0, (sum, t) => sum + t.price);
      final unitPrice = product.basePrice + (sizePrice ?? 0) + toppingsTotal;

      final item = CartItemModel.fromProduct(
        storeId: product.storeId,
        productId: product.id,
        productName: product.name,
        unitPrice: unitPrice,
        quantity: quantity,
        size: selectedSize,
        sizePrice: sizePrice,
        toppings: toppings,
        note: note,
        imageUrl: product.imageUrl,
      );

      await _cartService.addToCart(userId, item);
    } catch (e) {
      debugPrint('CartState: Loi addItem - $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(
      String userId, String cartItemId, int newQuantity) async {
    try {
      await _cartService.updateQuantity(userId, cartItemId, newQuantity);
    } catch (e) {
      debugPrint('CartState: Loi updateQuantity - $e');
      rethrow;
    }
  }

  Future<void> removeItem(String userId, String cartItemId) async {
    try {
      await _cartService.removeFromCart(userId, cartItemId);
    } catch (e) {
      debugPrint('CartState: Loi removeItem - $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  static CartState of(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<CartStateScope>();

    if (element == null) {
      throw FlutterError(
          'Khong tim thay CartState. Dam bao rang app duoc wrap trong CartStateScope.');
    }

    final widget = element.widget;
    if (widget is CartStateScope) {
      final notifier = widget.notifier;
      if (notifier is CartState) {
        return notifier;
      }
    }

    throw FlutterError(
        'CartState khong dung kieu. Dam bao rang CartStateScope duoc khoi tao dung.');
  }
}

/// Widget trung gian cung cap CartState xuong widget tree.
class CartStateScope extends InheritedNotifier<CartState> {
  const CartStateScope({
    required CartState notifier,
    required super.child,
  }) : super(notifier: notifier);
}
