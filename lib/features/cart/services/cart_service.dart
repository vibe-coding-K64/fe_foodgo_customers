import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/cart_item_model.dart';

/// Service tuong tac voi Firestore de quan ly gio hang.
///
/// Duong dan collection: customer_profiles/{userId}/cart
///
/// Cart KHONG luu gia tri price/sizePrice/toppings[].price.
/// Gia duoc tinh dong khi hien thi bang cach lay tu collection products.
class CartService {
  const CartService();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _cartCollection(String userId) {
    return _firestore
        .collection('customer_profiles')
        .doc(userId)
        .collection('cart');
  }

  /// Lay danh sach gio hang (doc 1 lan, khong stream).
  ///
  /// Tra ve danh sach CartItemModel TU cart collection.
  /// Gia chua duoc tinh o day - can goi enrich o CartState.
  Future<List<CartItemModel>> getCart(String userId) async {
    try {
      final snapshot = await _cartCollection(userId).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('CartService: Gio hang rong');
        return <CartItemModel>[];
      }
      final items = snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
      debugPrint('CartService: Da doc ${items.length} items tu Firestore');
      return items;
    } catch (e) {
      debugPrint('CartService: loi getCart - $e');
      rethrow;
    }
  }

  /// Stream lang nghe danh sach gio hang real-time.
  Stream<List<CartItemModel>> getCartStream(String userId) {
    return _cartCollection(userId).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        debugPrint('CartService: Gio hang rong');
        return <CartItemModel>[];
      }
      final items = snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
      debugPrint('CartService: Da nhan ${items.length} items tu Firestore');
      return items;
    });
  }

  /// Them mon vao gio hang qua API.
  ///
  /// POST /cart/add
  /// Body: { userId, storeId, foodId, selectedOptions[], note, quantity }
  Future<void> addToCart({
    required String userId,
    required String storeId,
    required String foodId,
    required List<SelectedOptionGroup>? selectedOptions,
    required String? note,
    required int quantity,
  }) async {
    try {
      await ApiClient.post(
        '/cart/add',
        data: {
          'userId': userId,
          'storeId': storeId,
          'foodId': foodId,
          'quantity': quantity,
          if (selectedOptions != null && selectedOptions.isNotEmpty)
            'selectedOptions':
                selectedOptions.map((g) => g.toJson()).toList(),
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      debugPrint('CartService: Them mon [$foodId] vao gio hang qua API');
    } catch (e) {
      debugPrint('CartService: loi addToCart - $e');
      rethrow;
    }
  }

  /// Them mon vao gio hang (dang CartItemModel) qua API.
  Future<void> addToCartFromItem(String userId, CartItemModel item) async {
    try {
      await ApiClient.post(
        '/cart/add',
        data: {
          'userId': userId,
          'storeId': item.storeId,
          'foodId': item.foodId,
          'quantity': item.quantity,
          if (item.selectedOptions.isNotEmpty)
            'selectedOptions':
                item.selectedOptions.map((g) => g.toJson()).toList(),
          if (item.note != null && item.note!.isNotEmpty) 'note': item.note,
        },
      );
      debugPrint('CartService: Them mon [${item.foodId}] vao gio hang qua API');
    } catch (e) {
      debugPrint('CartService: loi addToCartFromItem - $e');
      rethrow;
    }
  }

  /// Cap nhat so luong cua mot mon trong gio hang.
  Future<void> updateQuantity(
      String userId, String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(userId, cartItemId);
        return;
      }

      await _cartCollection(userId).doc(cartItemId).update({
        'quantity': newQuantity,
        'updatedAt': Timestamp.now(),
      });
      debugPrint(
          'CartService: Cap nhat so luong [$newQuantity] cho item [$cartItemId]');
    } catch (e) {
      debugPrint('CartService: loi updateQuantity - $e');
      rethrow;
    }
  }

  /// Xoa mot mon khoi gio hang.
  Future<void> removeFromCart(String userId, String cartItemId) async {
    try {
      await _cartCollection(userId).doc(cartItemId).delete();
      debugPrint('CartService: Xoa item [$cartItemId] khoi gio hang');
    } catch (e) {
      debugPrint('CartService: loi removeFromCart - $e');
      rethrow;
    }
  }

  /// Xoa toan bo gio hang.
  Future<void> clearCart(String userId) async {
    try {
      final snapshot = await _cartCollection(userId).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('CartService: Da xoa toan bo gio hang');
    } catch (e) {
      debugPrint('CartService: loi clearCart - $e');
      rethrow;
    }
  }
}
