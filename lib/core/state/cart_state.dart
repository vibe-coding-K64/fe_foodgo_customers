import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../features/cart/models/cart_item_model.dart';
import '../../features/cart/services/cart_service.dart';
import '../../features/home/models/product_model.dart';

/// Ket qua them san pham vao gio hang.
enum CartAddResult {
  success,
  differentStore,
  outOfStock,
  notFound,
  otherError,
}

/// State quan ly gio hang, dong bo voi Firestore.
///
/// Tat ca thao tac doc/ghi deu thong qua collection
/// customer_profiles/{userId}/cart.
///
/// Gia cua item duoc tinh dong tu collection products/{foodId}.
class CartState extends ChangeNotifier {
  final CartService _cartService = const CartService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;
  StreamSubscription<List<CartItemModel>>? _cartSubscription;
  /// Stream lang nghe cac product documents trong cart.
  /// Key = foodId, Value = subscription cua document do.
  final Map<String, StreamSubscription<DocumentSnapshot>> _productSubscriptions =
      {};

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get uniqueItemCount => _items.length;

  /// Tong gia cua gio hang. Chi tinh khi cac item da co product.
  double get subtotal => _items.fold<double>(0, (sum, item) {
        if (item.product != null) {
          return sum + item.totalPriceOf(item.product);
        }
        return sum;
      });

  String? _differentStoreErrorMessage;
  String? get differentStoreErrorMessage => _differentStoreErrorMessage;

  Map<String, List<CartItemModel>> get itemsByStore {
    final Map<String, List<CartItemModel>> grouped = {};
    for (final item in _items) {
      grouped.putIfAbsent(item.storeId, () => []).add(item);
    }
    return grouped;
  }

  /// Lay danh sach gio hang tu Firestore (fetch 1 lan).
  ///
  /// 1. Doc cart items tu collection customer_profiles/{userId}/cart.
  /// 2. Enrich moi item voi ProductModel tu collection products/{foodId}.
  Future<void> _fetchCart() async {
    if (_currentUserId == null) return;
    try {
      _isLoading = true;
      notifyListeners();

      final cartItems = await _cartService.getCart(_currentUserId!);
      _items = await _enrichItems(cartItems);
      _errorMessage = null;
    } catch (e) {
      debugPrint('CartState: loi fetchCart - $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enrich danh sach cart items voi ProductModel tu Firestore.
  Future<List<CartItemModel>> _enrichItems(List<CartItemModel> items) async {
    return Future.wait(
      items.map((item) async {
        try {
          final productDoc = await FirebaseFirestore.instance
              .collection('products')
              .doc(item.foodId)
              .get();

          if (!productDoc.exists) return item;

          final product = ProductModel.fromFirestore(productDoc);
          return item.copyWith(
            imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : null,
            product: product,
          );
        } catch (e) {
          debugPrint('CartState: Loi enrich item [${item.foodId}] - $e');
          return item;
        }
      }),
    );
  }

  /// Lang nghe realtime cac product documents trong cart.
  ///
  /// Moi khi product nao do thay doi (vi du isOutOfStock),
  /// se enrich lai item tuong ung va thong bao UI cap nhat.
  void _subscribeToProducts(List<CartItemModel> items) {
    // Huy cac subscription cu.
    for (final sub in _productSubscriptions.values) {
      sub.cancel();
    }
    _productSubscriptions.clear();

    if (items.isEmpty) return;

    for (final item in items) {
      _productSubscriptions[item.foodId] = FirebaseFirestore.instance
          .collection('products')
          .doc(item.foodId)
          .snapshots()
          .listen(
        (doc) async {
          if (!doc.exists) return;

          // Tim item trong _items hien tai.
          final idx = _items.indexWhere((i) => i.id == item.id);
          if (idx < 0) return;

          final product = ProductModel.fromFirestore(doc);
          _items[idx] = _items[idx].copyWith(
            imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : null,
            product: product,
          );
          notifyListeners();
        },
        onError: (e) {
          debugPrint('CartState: Loi stream product [${item.foodId}] - $e');
        },
      );
    }
  }

  /// Khoi dong - lang nghe gio hang theo thoi gian thuc.
  ///
  /// 1. Fetch lan dau ngay de co du lieu (neu co).
  /// 2. Sau do lang nghe stream cart de cap nhat khi cart thay doi.
  /// 3. Dong thoi lang nghe tung product document trong cart de phat hien isOutOfStock.
  Future<void> startListening(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _fetchCart();

    // Lang nghe cac product documents trong cart.
    _subscribeToProducts(_items);

    await _cartSubscription?.cancel();

    // Lang nghe stream cart (cho phep add/remove items).
    _cartSubscription = _cartService.getCartStream(userId).listen(
      (items) async {
        _items = await _enrichItems(items);
        _isLoading = false;
        _errorMessage = null;
        // Cap nhat product subscriptions khi cart items thay doi.
        _subscribeToProducts(_items);
        notifyListeners();
      },
      onError: (e) {
        debugPrint('CartState: Stream error - $e');
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Dung lang nghe stream khi thoat khoi man hinh gio hang.
  void stopListening() {
    _cartSubscription?.cancel();
    _cartSubscription = null;
    for (final sub in _productSubscriptions.values) {
      sub.cancel();
    }
    _productSubscriptions.clear();
    _currentUserId = null;
  }

  void reset() {
    for (final sub in _productSubscriptions.values) {
      sub.cancel();
    }
    _productSubscriptions.clear();
    _items = [];
    _isLoading = false;
    _errorMessage = null;
    _differentStoreErrorMessage = null;
    _currentUserId = null;
    notifyListeners();
  }

  String _extractStoreId(dynamic product) {
    final direct = product.storeId as String?;
    if (direct != null && direct.isNotEmpty) return direct;

    final nested = product.store?.id as String?;
    if (nested != null && nested.isNotEmpty) return nested;

    throw ArgumentError('Khong the lay storeId tu product');
  }

  String _extractFoodId(dynamic product) {
    final id = product.id as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Food ID khong hop le: $id');
    }
    return id;
  }

  String _extractName(dynamic product) {
    final name = product.name as String?;
    if (name != null && name.isNotEmpty) return name;
    throw ArgumentError('Khong the lay name tu product');
  }

  String? _extractImageUrl(dynamic product) {
    final url = product.imageUrl as String?;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// Them mot san pham vao gio hang (goi API).
  ///
  /// Sau khi API tra ve, fetch lai cart de enrich gia.
  Future<CartAddResult> addItem(
    String userId,
    dynamic product, {
    String? selectedSize,
    List<Map<String, dynamic>> selectedToppings = const [],
    String? note,
    int quantity = 1,
  }) async {
    if (quantity < 1) {
      throw ArgumentError('So luong phai lon hon 0');
    }

    final storeId = _extractStoreId(product);
    final foodId = _extractFoodId(product);

    try {
      await _cartService.addToCart(
        userId: userId,
        storeId: storeId,
        foodId: foodId,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedToppings: selectedToppings.isNotEmpty
            ? selectedToppings
                .map((t) => CartTopping(name: t['name'] as String))
                .toList()
            : null,
        note: note,
      );

      await _fetchCart();
      _errorMessage = null;
      _differentStoreErrorMessage = null;
      return CartAddResult.success;
    } catch (e) {
      debugPrint('CartState: loi addItem - $e');
      _errorMessage = e.toString();
      notifyListeners();
      return CartAddResult.otherError;
    }
  }

  /// Xoa gio hang hien tai roi them san pham moi.
  Future<CartAddResult> replaceCartAndAddItem(
    String userId,
    dynamic product, {
    String? selectedSize,
    List<Map<String, dynamic>> selectedToppings = const [],
    String? note,
    int quantity = 1,
  }) async {
    _differentStoreErrorMessage = null;
    notifyListeners();

    try {
      await _cartService.clearCart(userId);
      _items = [];
    } catch (e) {
      debugPrint('CartState: loi clearCart khi replace - $e');
    }

    return addItem(
      userId,
      product,
      selectedSize: selectedSize,
      selectedToppings: selectedToppings,
      note: note,
      quantity: quantity,
    );
  }

  /// Cap nhat so luong cua mot mon trong gio hang (Firestore).
  Future<void> updateQuantity(
      String userId, String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(userId, cartItemId);
      return;
    }

    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index < 0) return;

    final oldItem = _items[index];

    _items = [
      for (int i = 0; i < _items.length; i++)
        if (i == index) _items[i].copyWith(quantity: newQuantity)
        else _items[i],
    ];
    notifyListeners();

    try {
      await _cartService.updateQuantity(userId, cartItemId, newQuantity);
      _errorMessage = null;
    } catch (e) {
      _items = [
        for (int i = 0; i < _items.length; i++)
          if (i == index) oldItem else _items[i],
      ];
      notifyListeners();
      debugPrint('CartState: loi updateQuantity - $e');
      rethrow;
    }
  }

  /// Xoa mot mon khoi gio hang (Firestore).
  Future<void> removeItem(String userId, String cartItemId) async {
    try {
      await _cartService.removeFromCart(userId, cartItemId);
      _items = _items.where((i) => i.id != cartItemId).toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('CartState: loi removeItem - $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Xoa toan bo gio hang (Firestore).
  Future<void> clearCart(String userId) async {
    final savedItems = List<CartItemModel>.from(_items);
    _items = [];
    notifyListeners();

    try {
      await _cartService.clearCart(userId);
      _errorMessage = null;
    } catch (e) {
      debugPrint('CartState: loi clearCart - $e');
      _items = savedItems;
      notifyListeners();
      rethrow;
    }
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
