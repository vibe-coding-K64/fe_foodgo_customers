import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/auth_storage.dart';
import '../models/payment_method_model.dart';

/// Service quan ly phuong thuc thanh toan, tuong tac voi Firebase Firestore.
///
/// Ho tro cac thao tac:
/// - Lay danh sach phuong thuc theo Stream (thoi gian thuc)
/// - Dat phuong thuc mac dinh (dung WriteBatch de cap nhat nhieu document)
/// - Xoa phuong thuc khoi Firestore
class PaymentService {
  const PaymentService();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay duong dan sub-collection phuong thuc thanh toan cua nguoi dung hien tai.
  CollectionReference _paymentCollection() {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('PaymentService: Nguoi dung chua dang nhap');
    }
    return _firestore.collection('customer_profiles').doc(userId).collection('payment_methods');
  }

  /// Stream lang nghe danh sach phuong thuc thanh toan cua nguoi dung hien tai.
  Stream<List<PaymentMethodModel>> getPaymentMethodsStream() {
    try {
      return _paymentCollection()
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          debugPrint('PaymentService: Khong co phuong thuc thanh toan nao');
          return <PaymentMethodModel>[];
        }
        final methods = snapshot.docs
            .map((doc) => PaymentMethodModel.fromFirestore(doc))
            .toList();
        debugPrint('PaymentService: Tai ${methods.length} phuong thuc thanh toan');
        return methods;
      });
    } catch (e) {
      debugPrint('PaymentService: Loi lay danh sach phuong thuc - $e');
      return Stream.value([]);
    }
  }

  /// Dat mot phuong thuc thanh toan lam mac dinh.
  ///
  /// Su dung WriteBatch de dam bao tinh toan ven (atomicity):
  /// 1. Quet tat ca document, set isDefault = false
  /// 2. Cap nhat document duoc chon, set isDefault = true
  Future<void> setDefaultPayment(String paymentId) async {
    try {
      final collection = _paymentCollection();
      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) {
        debugPrint('PaymentService: Khong co phuong thuc de dat mac dinh');
        return;
      }

      final batch = _firestore.batch();

      // Tat ca document deu set isDefault = false
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Document duoc chon set isDefault = true
      final targetDoc = collection.doc(paymentId);
      batch.update(targetDoc, {'isDefault': true});

      await batch.commit();
      debugPrint('PaymentService: Dat phuong thuc [$paymentId] lam mac dinh thanh cong');
    } catch (e) {
      debugPrint('PaymentService: Loi dat phuong thuc mac dinh - $e');
      rethrow;
    }
  }

  /// Xoa mot phuong thuc thanh toan khoi Firestore.
  Future<void> deletePayment(String paymentId) async {
    try {
      final docRef = _paymentCollection().doc(paymentId);
      await docRef.delete();
      debugPrint('PaymentService: Xoa phuong thuc [$paymentId] thanh cong');
    } catch (e) {
      debugPrint('PaymentService: Loi xoa phuong thuc - $e');
      rethrow;
    }
  }
}
