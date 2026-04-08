import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/auth_storage.dart';
import '../models/notification_model.dart';

/// Service xu ly thong bao nguoi dung.
///
/// Giao tiep voi sub-collection `users/{userId}/notifications`.
class NotificationService {
  NotificationService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay Stream danh sach thong bao cua nguoi dung hien tai.
  ///
  /// Sap xep theo [createdAt] giam dan (thong bao moi nhat len dau).
  /// Tra ve [Stream] de lang nghe thay doi theo thoi gian thuc.
  static Stream<List<NotificationModel>> getNotificationsStream() {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('NotificationService: Chua dang nhap, tra ve Stream rong');
      return Stream.value([]);
    }

    debugPrint('NotificationService: Tao Stream thong bao cho userId = $userId');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Danh dau mot thong bao la da doc.
  ///
  /// [notifId] la ID cua thong bao can cap nhat.
  static Future<void> markAsRead(String notifId) async {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('NotificationService: Chua dang nhap, khong the danh dau da doc');
      return;
    }

    debugPrint('NotificationService: Danh dau da doc thong bao [$notifId]');

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notifId)
          .update({'isRead': true});
      debugPrint('NotificationService: Cap nhat thanh cong');
    } catch (e, st) {
      debugPrint('NotificationService: Loi khi danh dau da doc = $e');
      debugPrint('Stack trace: $st');
    }
  }

  /// Danh dau tat ca thong bao chua doc la da doc.
  ///
  /// Su dung [WriteBatch] de toi uu hoa nhieu thao tac ghi cung luc.
  static Future<void> markAllAsRead() async {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('NotificationService: Chua dang nhap, khong the danh dau tat ca');
      return;
    }

    debugPrint('NotificationService: Danh dau tat ca thong bao la da doc');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('NotificationService: Khong co thong bao chua doc');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      debugPrint('NotificationService: Da danh dau ${snapshot.docs.length} thong bao');
    } catch (e, st) {
      debugPrint('NotificationService: Loi khi danh dau tat ca = $e');
      debugPrint('Stack trace: $st');
    }
  }
}
