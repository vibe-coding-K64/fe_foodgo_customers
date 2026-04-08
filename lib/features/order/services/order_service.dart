import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/auth_storage.dart';
import '../models/order_model.dart';

/// Service xu ly cac thao tac lien quan den don hang.
///
/// Su dung Firestore collection `orders`.
class OrderService {
  OrderService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';

  /// Lay danh sach don hang cua nguoi dung hien tai.
  /// Tra ve Stream de StreamBuilder co the lang nghe.
  ///
  /// Chi lay don hang cua user dang nhap va co deletedAt == null.
  /// Sap xep theo thoi gian tao giam dan (moi nhat len truoc).
  static Stream<List<OrderModel>> getMyOrdersStream() {
    return Stream.value(null).asyncMap((_) async {
      final userId = AuthStorage.getUserId();
      if (userId == null) {
        debugPrint('OrderService: Chua dang nhap, tra ve danh sach rong');
        return <OrderModel>[];
      }

      debugPrint('OrderService: Lay danh sach don hang cua userId = $userId');

      final querySnapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .where('deletedAt', isEqualTo: null)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      debugPrint('OrderService: Da lay ${orders.length} don hang');
      return orders;
    });
  }

  /// Lay danh sach don hang cua nguoi dung hien tai (Future version).
  /// Su dung khi khong can Stream.
  static Future<List<OrderModel>> getMyOrders() async {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('OrderService: Chua dang nhap, tra ve danh sach rong');
      return [];
    }

    debugPrint('OrderService: Lay don hang (Future) cho userId = $userId');

    final querySnapshot = await _firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .where('deletedAt', isEqualTo: null)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList();
  }

  /// Lay mot don hang cu the theo ID.
  static Future<OrderModel?> getOrderById(String orderId) async {
    try {
      debugPrint('OrderService: Lay don hang orderId = $orderId');

      final docSnapshot = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();

      if (!docSnapshot.exists) {
        debugPrint('OrderService: Khong tim thay don hang $orderId');
        return null;
      }

      return OrderModel.fromFirestore(docSnapshot);
    } catch (e) {
      debugPrint('OrderService: Loi khi lay don hang $orderId: $e');
      return null;
    }
  }

  /// Huy mot don hang.
  /// Dat status = 4 (Da huy).
  ///
  /// Tra ve true neu thanh cong, false neu that bai.
  static Future<bool> cancelOrder(String orderId) async {
    try {
      debugPrint('OrderService: Bat dau huy don hang orderId = $orderId');

      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': 4,
        'updatedAt': Timestamp.now(),
      });

      debugPrint('OrderService: Huy don hang $orderId thanh cong');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('OrderService: FirebaseException khi huy don $orderId: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('OrderService: Loi khi huy don hang $orderId: $e');
      return false;
    }
  }

  /// Lay don hang theo trang thai.
  ///
  /// [status] la ma so trang thai: 0=Cho xac nhan, 1=Dang chuan bi,
  /// 2=Dang giao, 3=Hoan thanh, 4=Da huy.
  static Future<List<OrderModel>> getOrdersByStatus(int status) async {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('OrderService: Chua dang nhap, tra ve danh sach rong');
      return [];
    }

    debugPrint('OrderService: Lay don hang theo status = $status cho userId = $userId');

    final querySnapshot = await _firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .where('deletedAt', isEqualTo: null)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList();
  }
}
