import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/auth_storage.dart';
import '../models/order_model.dart';

/// Service xu ly cac thao tac lien quan den don hang.
///
/// Su dung Firestore collection `orders`.
class OrderService {
  OrderService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';
  static const String _storesCollection = 'stores';
  static const String _usersCollection = 'users';

  /// Lay danh sach don hang cua nguoi dung hien tai.
  /// Tra ve Stream de StreamBuilder co the lang nghe.
  ///
  /// Chi lay don hang cua user dang nhap va co deletedAt == null.
  /// Sap xep theo thoi gian tao giam dan (moi nhat len truoc).
  /// Su dung snapshots() de realtime — tu dong emit khi Firestore thay doi.
  static Stream<List<OrderModel>> getMyOrdersStream() {
    return _ordersStream().asyncExpand((orders) async* {
      yield orders;
    });
  }

  /// Stream goc: lang nghe Firestore query, join store avatar, tra ve orders.
  static Stream<List<OrderModel>> _ordersStream() {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      return Stream.value(<OrderModel>[]);
    }

    return _firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .where('deletedAt', isEqualTo: null)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((querySnapshot) => _enrichOrdersWithAvatars(querySnapshot.docs));
  }

  /// Parse docs thanh OrderModel roi join store avatar.
  static Future<List<OrderModel>> _enrichOrdersWithAvatars(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final orders = docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

    final storeIds = orders
        .map((o) => o.storeId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final avatarResults = await Future.wait(
      storeIds.map((storeId) async {
        try {
          final storeDoc = await _firestore
              .collection(_storesCollection)
              .doc(storeId)
              .get();
          final avtUrl = storeDoc.data()?['avtUrl'] as String?;
          return MapEntry(storeId, avtUrl);
        } catch (e) {
          debugPrint('OrderService: Loi khi lay avatar storeId=$storeId: $e');
          return MapEntry(storeId, '');
        }
      }),
    );

    final avatarMap = Map.fromEntries(avatarResults);

    return orders.map((order) {
      final avatar = avatarMap[order.storeId];
      return avatar != null && avatar.isNotEmpty
          ? order.copyWith(storeAvatar: avatar)
          : order;
    }).toList();
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
  /// Ghi chu: Day la Future, chi goi 1 lan. Su dung getOrderByIdStream
  /// neu can real-time cap nhat.
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

      var order = OrderModel.fromFirestore(docSnapshot);

      String? storeAvatar;
      String? userAvatar;

      try {
        final storeDoc = await _firestore
            .collection(_storesCollection)
            .doc(order.storeId)
            .get();
        storeAvatar = storeDoc.data()?['avtUrl'] as String?;
      } catch (_) {}

      try {
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(order.userId)
            .get();
        userAvatar = userDoc.data()?['photoUrl'] as String?;
      } catch (_) {}

      if (storeAvatar != null || userAvatar != null) {
        order = order.copyWith(
          storeAvatar: storeAvatar ?? order.storeAvatar,
          userAvatar: userAvatar ?? order.userAvatar,
        );
      }

      return order;
    } catch (e) {
      debugPrint('OrderService: Loi khi lay don hang $orderId: $e');
      return null;
    }
  }

  /// Lay mot don hang cu the theo ID, real-time stream.
  /// Lang nghe thay doi tu Firestore va tu dong cap nhat khi document thay doi.
  /// Dong thoi join dữ liệu từ address sub-collection, stores, va users.
  static Stream<OrderModel?> getOrderByIdStream(String orderId) {
    return _firestore
        .collection(_ordersCollection)
        .doc(orderId)
        .snapshots()
        .asyncMap((docSnapshot) async {
      if (!docSnapshot.exists) return null;

      var order = OrderModel.fromFirestore(docSnapshot);

      // Join address tu customer_profiles/{userId}/addresses/{addressId}.
      final addressId = docSnapshot.data()?['addressId'] as String?;
      if (addressId != null && addressId.isNotEmpty) {
        try {
          final addrDoc = await _firestore
              .collection('customer_profiles')
              .doc(order.userId)
              .collection('addresses')
              .doc(addressId)
              .get();
          if (addrDoc.exists) {
            final addrData = addrDoc.data()!;
            order = order.copyWith(
              addressName: addrData['name'] as String?,
              addressLat: (addrData['lat'] as num?)?.toDouble(),
              addressLng: (addrData['lng'] as num?)?.toDouble(),
              receiverName: addrData['receiverName'] as String?,
              receiverPhone: addrData['receiverPhone'] as String?,
            );
          }
        } catch (e) {
          debugPrint('OrderService: Loi khi lay address: $e');
        }
      }

      // Join store tu stores/{storeId}.
      try {
        final storeDoc = await _firestore
            .collection(_storesCollection)
            .doc(order.storeId)
            .get();
        if (storeDoc.exists) {
          final storeData = storeDoc.data()!;
          final storeAvatar = storeData['avtUrl'] as String?;
          final storeAddress = storeData['address'] as String?;
          final storeLat = (storeData['lat'] as num?)?.toDouble();
          final storeLng = (storeData['lng'] as num?)?.toDouble();
          if (storeAvatar != null || storeAddress != null || storeLat != null) {
            order = order.copyWith(
              storeAvatar: storeAvatar ?? order.storeAvatar,
              storeAddress: storeAddress ?? order.storeAddress,
              storeLat: storeLat ?? order.storeLat,
              storeLng: storeLng ?? order.storeLng,
            );
          }
        }
      } catch (e) {
        debugPrint('OrderService: Loi khi lay store: $e');
      }

      // Join user avatar tu users/{userId}.
      try {
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(order.userId)
            .get();
        if (userDoc.exists) {
          final userAvatar = userDoc.data()?['photoUrl'] as String?;
          if (userAvatar != null) {
            order = order.copyWith(userAvatar: userAvatar);
          }
        }
      } catch (e) {
        debugPrint('OrderService: Loi khi lay user avatar: $e');
      }

      return order;
    });
  }

  /// Huy mot don hang qua API.
  /// Dat status = 4 (Da huy).
  ///
  /// [orderId] : ID don hang can huy.
  /// [reason]  : Ly do huy (bat buoc).
  ///
  /// Tra ve CancelOrderResponse chua success, message, va data cua don hang da cap nhat.
  static Future<CancelOrderResponse> cancelOrder(String orderId, String reason) async {
    try {
      debugPrint('OrderService: Bat dau huy don hang orderId = $orderId');

      final response = await ApiClient.post<Map<String, dynamic>>(
        '/orders/$orderId/cancel',
        data: {'reason': reason},
      );

      final cancelResponse = CancelOrderResponse.fromJson(response.data!);

      debugPrint('OrderService: Huy don hang $orderId thanh cong');

      // Dong thoi cap nhat Firestore de dong bo local state.
      try {
        await _firestore.collection(_ordersCollection).doc(orderId).update({
          'status': 4,
          'updatedAt': Timestamp.now(),
        });
      } catch (_) {
        // Firestore chi la backup, khong anh huong ket qua tra ve.
      }

      return cancelResponse;
    } catch (e) {
      debugPrint('OrderService: Loi khi huy don hang $orderId: $e');
      return CancelOrderResponse(
        success: false,
        message: 'Huỷ đơn thất bại. Vui lòng thử lại.',
      );
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
