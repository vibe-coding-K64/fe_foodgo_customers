import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../features/cart/models/cart_item_model.dart';
import '../../features/cart/services/cart_api_service.dart';

/// Ket qua them san pham vao gio hang.
enum CartAddResult {
  success,
  differentStore,
  outOfStock,
  notFound,
  otherError,
}

/// State quan ly gio hang, dong bo voi API server.
///
/// Cac endpoint API:
///
///   GET    /api/cart                  - Lay danh sach gio hang
///   POST   /api/cart/add             - Them mon vao gio hang
///   PUT    /api/cart/{itemId}/quantity - Cap nhat so luong
///   DELETE /api/cart/{itemId}       - Xoa mot mon
///   DELETE /api/cart                - Xoa toan bo gio hang
///
/// Sau moi thao tac them/cap-nhat/xoa, goi lai GET /api/cart de lay
/// state moi nhat tu server.
class CartState extends ChangeNotifier {
  final CartApiService _apiService = const CartApiService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get uniqueItemCount => _items.length;

  double get subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  /// Thong tin loi khac cua hang.
  String? _differentStoreErrorMessage;

  /// Thong bao loi chung (khac cua hang).
  String? get differentStoreErrorMessage => _differentStoreErrorMessage;

  Map<String, List<CartItemModel>> get itemsByStore {
    final Map<String, List<CartItemModel>> grouped = {};
    for (final item in _items) {
      grouped.putIfAbsent(item.storeId, () => []).add(item);
    }
    return grouped;
  }

  /// Lay danh sach gio hang tu API.
  Future<void> _fetchCart() async {
    if (_currentUserId == null) return;
    try {
      final responseData = await _apiService.getCart(userId: _currentUserId!);
      final data = responseData['data'] as Map<String, dynamic>?;
      final itemsList = (data?['items'] as List<dynamic>?) ?? [];

      _items = itemsList
          .map((item) =>
              CartItemModel.fromApiJson(item as Map<String, dynamic>))
          .toList();
      _errorMessage = null;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ?? e.message ?? 'Loi lay gio hang';
      debugPrint('CartState: loi fetchCart - $message');
      _errorMessage = message;
    } catch (e) {
      debugPrint('CartState: loi fetchCart - $e');
      _errorMessage = e.toString();
    }
  }

  /// Khoi dong - goi API lay gio hang.
  Future<void> startListening(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _fetchCart();
    _isLoading = false;
    notifyListeners();
  }

  /// Dung listener. Khong goi API nua.
  void stopListening() {
    _currentUserId = null;
  }

  /// Reset toan bo state ve ban dau.
  /// Can goi khi nguoi dung dang xuat.
  void reset() {
    _items = [];
    _isLoading = false;
    _errorMessage = null;
    _differentStoreErrorMessage = null;
    _currentUserId = null;
    notifyListeners();
  }

  /// Lay storeId cua product - uu tien field top-level, fallback sang nested store.id.
  String _extractStoreId(dynamic product) {
    final direct = product.storeId as String?;
    if (direct != null && direct.isNotEmpty) return direct;

    final nested = product.store?.id as String?;
    if (nested != null && nested.isNotEmpty) return nested;

    throw ArgumentError('Khong the lay storeId tu product. '
        'product.storeId=$direct, product.store?.id=$nested');
  }

  /// Lay foodId cua product.
  String _extractFoodId(dynamic product) {
    final id = product.id as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Food ID khong hop le: $id');
    }
    return id;
  }

  /// Them mot san pham vao gio hang qua API.
  ///
  /// Tra ve [CartAddResult] de UI xu ly dialog neu can.
  /// Sau khi goi POST thanh cong, fetch lai cart tu server de dam bao state chinh xac.
  Future<CartAddResult> addItem(
    String userId,
    dynamic product, {
    String? selectedSize,
    double? sizePrice,
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
      await _apiService.addToCart(
        userId: userId,
        storeId: storeId,
        foodId: foodId,
        quantity: quantity,
        size: selectedSize,
        toppings: selectedToppings.isNotEmpty ? selectedToppings : null,
        note: note,
      );

      await _fetchCart();
      _errorMessage = null;
      _differentStoreErrorMessage = null;
      notifyListeners();
      return CartAddResult.success;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message =
          e.response?.data?['message'] as String? ?? e.message ?? 'Loi them mon';
      debugPrint('CartState: loi addItem - status=$statusCode, msg=$message');

      if (statusCode == 400) {
        if (message.contains('cua hang') || message.contains('mot cua hang')) {
          _differentStoreErrorMessage = message;
          notifyListeners();
          return CartAddResult.differentStore;
        }
        if (message.contains('het hang') || message.contains('out of stock')) {
          _errorMessage = message;
          notifyListeners();
          return CartAddResult.outOfStock;
        }
      }

      if (statusCode == 404) {
        _errorMessage = message;
        notifyListeners();
        return CartAddResult.notFound;
      }

      _errorMessage = message;
      notifyListeners();
      return CartAddResult.otherError;
    } catch (e) {
      debugPrint('CartState: loi addItem - $e');
      return CartAddResult.otherError;
    }
  }

  /// Xoa gio hang hien tai roi them san pham moi.
  Future<CartAddResult> replaceCartAndAddItem(
    String userId,
    dynamic product, {
    String? selectedSize,
    double? sizePrice,
    List<Map<String, dynamic>> selectedToppings = const [],
    String? note,
    int quantity = 1,
  }) async {
    _differentStoreErrorMessage = null;
    notifyListeners();

    try {
      await _apiService.clearCart(userId: userId);
      _items = [];
    } catch (e) {
      debugPrint('CartState: loi clearCart khi replace - $e');
    }

    return addItem(
      userId,
      product,
      selectedSize: selectedSize,
      sizePrice: sizePrice,
      selectedToppings: selectedToppings,
      note: note,
      quantity: quantity,
    );
  }

  /// Cap nhat so luong cua mot mon trong gio hang qua API.
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
      await _apiService.updateQuantity(
        itemId: cartItemId,
        userId: userId,
        quantity: newQuantity,
      );
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

  /// Xoa mot mon khoi gio hang qua API.
  Future<void> removeItem(String userId, String cartItemId) async {
    final savedItems = List<CartItemModel>.from(_items);
    _items = _items.where((i) => i.id != cartItemId).toList();
    notifyListeners();

    try {
      await _apiService.removeFromCart(itemId: cartItemId, userId: userId);
      _errorMessage = null;
    } catch (e) {
      debugPrint('CartState: loi removeItem - $e');
      _items = savedItems;
      notifyListeners();
      rethrow;
    }
  }

  /// Xoa toan bo gio hang qua API.
  Future<void> clearCart(String userId) async {
    final savedItems = List<CartItemModel>.from(_items);
    _items = [];
    notifyListeners();

    try {
      await _apiService.clearCart(userId: userId);
      _errorMessage = null;
    } on DioException {
      _items = savedItems;
      notifyListeners();
      rethrow;
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
