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
          return item.copyWith(product: product);
        } catch (e) {
          debugPrint('CartState: Loi enrich item [${item.foodId}] - $e');
          return item;
        }
      }),
    );
  }

  /// Stream lang nghe cac product documents trong cart.
  ///
  /// Moi khi product nao do thay doi (vi du isOutOfStock, basePrice),
  /// se cap nhat product cua item tuong ung ngay trong _items
  /// ma KHONG lam mat subscription.
  ///
  /// Moi foodId chi duoc subscribe 1 lan - cac goi tiep theo se bi skip
  /// neu da co subscription cho foodId do.
  void _subscribeToProducts(List<CartItemModel> items) {
    for (final item in items) {
      // Skip neu da co subscription cho foodId nay.
      if (_productSubscriptions.containsKey(item.foodId)) continue;

      _productSubscriptions[item.foodId] = FirebaseFirestore.instance
          .collection('products')
          .doc(item.foodId)
          .snapshots()
          .listen(
        (doc) {
          if (!doc.exists) return;

          // Tim item trong _items hien tai theo cartItemId (item.id),
          // vi cartItemId khong thay doi khi product thay doi.
          final idx = _items.indexWhere((i) => i.id == item.id);
          if (idx < 0) return;

          final product = ProductModel.fromFirestore(doc);
          _items[idx] = _items[idx].copyWith(product: product);
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
  /// Co 2 stream chay song song, KHONG phu thuoc nhau:
  ///  1. Cart stream: lang nghe cart collection -> cap nhat danh sach items
  ///  2. Product subscriptions: lang nghe tung product document -> cap nhat product cua item
  ///
  /// Cach phan tach nay dam bao:
  ///  - Khi product thay doi (isOutOfStock, gia...) -> chi product subscription emit
  ///  - Khi cart thay doi (quantity, options...)  -> chi cart stream emit
  ///  - Khong co tinh trang subscription bi cancel/tao lai giua chung
  Future<void> startListening(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Huy subscription cu neu co (khi goi lai startListening).
    await _cartSubscription?.cancel();
    for (final sub in _productSubscriptions.values) {
      sub.cancel();
    }
    _productSubscriptions.clear();

    // --- Lan dau: fetch cart + products ngay de co du lieu hien thi ---
    final cartItems = await _cartService.getCart(userId);
    _items = await _enrichItems(cartItems);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();

    // Bat dau product subscriptions cho lan dau.
    _subscribeToProducts(_items);

    // --- Cart stream: lang nghe them/xoa/sua quantity/options ---
    _cartSubscription = _cartService.getCartStream(userId).listen(
      (items) {
      // Tao map cartItemId -> foodId cu de khi item bi xoa van biet can cancel subscription nao.
      final cartItemIdToFoodId = {for (final i in _items) i.id: i.foodId};

      // Cap nhat danh sach _items giu nguyen product hien co.
      _items = items.map((newItem) {
        // Neu item da co trong danh sach cu -> giu lai product cu
        final old = _items.where((o) => o.id == newItem.id).firstOrNull;
        if (old != null) {
          return newItem.copyWith(product: old.product);
        }
        // Item moi -> se duoc enrich boi product subscription
        return newItem;
      }).toList();

      // Huy product subscription cua items bi xoa.
      final newIds = _items.map((i) => i.id).toSet();
      for (final cartItemId in cartItemIdToFoodId.keys) {
        if (!newIds.contains(cartItemId)) {
          final foodId = cartItemIdToFoodId[cartItemId]!;
          _productSubscriptions[foodId]?.cancel();
          _productSubscriptions.remove(foodId);
        }
      }

        // Moi items moi chua co product -> bat dau subscription.
        _subscribeToProducts(_items);

        _errorMessage = null;
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

  /// Them mot san pham vao gio hang (goi API).
  ///
  /// Sau khi API tra ve, fetch lai cart de enrich gia.
  Future<CartAddResult> addItem(
    String userId,
    dynamic product, {
    List<SelectedOptionGroup>? selectedOptions,
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
        selectedOptions: selectedOptions,
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
    List<SelectedOptionGroup>? selectedOptions,
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
      selectedOptions: selectedOptions,
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
