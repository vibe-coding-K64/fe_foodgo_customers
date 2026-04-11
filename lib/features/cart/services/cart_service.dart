import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

/// Service tuong tac voi Firestore de quan ly gio hang.
///
/// Duong dan collection: customer_profiles/{userId}/cart
class CartService {
  const CartService();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay duong dan sub-collection cart cua nguoi dung.
  CollectionReference _cartCollection(String userId) {
    return _firestore
        .collection('customer_profiles')
        .doc(userId)
        .collection('cart');
  }

  /// Stream lang nghe danh sach gio hang real-time.
  ///
  /// Su dung snapshot() de lang nghe thay doi tu Firestore.
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

  /// Them mon vao gio hang.
  ///
  /// Neu mon da ton tai (cung foodId), tang quantity len.
  /// Neu chua ton tai, tao document moi.
  Future<void> addToCart(String userId, CartItemModel item) async {
    try {
      final collection = _cartCollection(userId);

      // Tim xem mon nay da co trong gio chua (theo foodId).
      final querySnapshot = await collection
          .where('foodId', isEqualTo: item.foodId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Da ton tai -> tang so luong.
        final existingDoc = querySnapshot.docs.first;
        final existingData = existingDoc.data()! as Map<String, dynamic>;
        final currentQuantity = (existingData['quantity'] as num?)?.toInt() ?? 1;
        final newQuantity = currentQuantity + item.quantity;

        await existingDoc.reference.update({
          'quantity': newQuantity,
          'updatedAt': Timestamp.now(),
        });
        debugPrint(
            'CartService: Tang so luong [$newQuantity] cho mon [${item.name}]');
      } else {
        // Chua ton tai -> them moi.
        final now = Timestamp.now();
        final newItem = CartItemModel(
          id: '',
          storeId: item.storeId,
          foodId: item.foodId,
          name: item.name,
          price: item.price,
          quantity: item.quantity,
          imageUrl: item.imageUrl,
          createdAt: now.toDate(),
          updatedAt: now.toDate(),
        );
        await collection.add(newItem.toFirestore());
        debugPrint('CartService: Them mon [${item.name}] vao gio hang');
      }
    } catch (e) {
      debugPrint('CartService: Loi addToCart - $e');
      rethrow;
    }
  }

  /// Cap nhat so luong cua mot mon trong gio hang.
  Future<void> updateQuantity(
      String userId, String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        // Neu so luong <= 0, xoa khoi gio hang.
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
      debugPrint('CartService: Loi updateQuantity - $e');
      rethrow;
    }
  }

  /// Xoa mot mon khoi gio hang.
  Future<void> removeFromCart(String userId, String cartItemId) async {
    try {
      await _cartCollection(userId).doc(cartItemId).delete();
      debugPrint('CartService: Xoa item [$cartItemId] khoi gio hang');
    } catch (e) {
      debugPrint('CartService: Loi removeFromCart - $e');
      rethrow;
    }
  }
}
