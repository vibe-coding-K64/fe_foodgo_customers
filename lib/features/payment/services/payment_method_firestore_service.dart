import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/auth_storage.dart';
import '../models/payment_method_model.dart';

/// Service doc phuong thuc thanh toan tu Firestore.
///
/// Doc tu collection: customer_profiles/{userId}/payment_methods
///
/// Firestore fields (tu firebase_collections.md):
/// - id           : String
/// - type         : Number  (1=Tien mat, 2=Vi dien tu, 3=The ngan hang)
/// - isDefault    : Boolean
/// - cardBrand    : String? (null neu type!=3)
/// - last4Digits  : String? (null neu type!=3)
/// - walletBrand  : String? (null neu type!=2)  values: momo, zalopay, vnpay, zalo
/// - isLinked     : Boolean
/// - createdAt    : Timestamp
/// - updatedAt    : Timestamp
class PaymentMethodFirestoreService {
  const PaymentMethodFirestoreService();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getUserId() {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('PaymentMethodFirestoreService: Nguoi dung chua dang nhap');
    }
    return userId;
  }

  /// Lay danh sach phuong thuc thanh toan tu Firestore.
  ///
  /// Doc tu: customer_profiles/{userId}/payment_methods
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final userId = _getUserId();
    debugPrint('PaymentMethodFirestoreService: Lay payment methods cho user [$userId]');

    try {
      final snap = await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('payment_methods')
          .get();

      final methods = snap.docs.map((doc) {
        return _fromFirestore(doc.data(), doc.id);
      }).toList();

      // Neu rong, tra ve default: chi co cash.
      if (methods.isEmpty) {
        debugPrint('PaymentMethodFirestoreService: Khong co payment method nao, tra ve mac dinh [cash]');
        return [
          PaymentMethodModel(
            id: 'cash',
            name: 'Tiền mặt',
            type: PaymentMethodType.cash,
            details: 'Thanh toán khi nhận hàng (COD)',
            isDefault: true,
            isLinked: true,
            createdAt: DateTime.now(),
          ),
        ];
      }

      // Sap xep: mac dinh truoc, khong mac dinh theo sau.
      methods.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return 0;
      });

      debugPrint('PaymentMethodFirestoreService: Da lay ${methods.length} phuong thuc');
      return methods;
    } catch (e) {
      debugPrint('PaymentMethodFirestoreService: Loi lay payment methods - $e');
      // Loi thi tra ve default cash.
      return [
        PaymentMethodModel(
          id: 'cash',
          name: 'Tiền mặt',
          type: PaymentMethodType.cash,
          details: 'Thanh toán khi nhận hàng (COD)',
          isDefault: true,
          isLinked: true,
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  /// Lay phuong thuc mac dinh tu Firestore.
  Future<PaymentMethodModel?> getDefaultPaymentMethod() async {
    final userId = _getUserId();
    try {
      final snap = await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('payment_methods')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;
      return _fromFirestore(snap.docs.first.data(), snap.docs.first.id);
    } catch (e) {
      debugPrint('PaymentMethodFirestoreService: Loi getDefaultPaymentMethod - $e');
      return null;
    }
  }

  /// Stream lang nghe payment methods real-time.
  Stream<List<PaymentMethodModel>> watchPaymentMethods() {
    final userId = _getUserId();
    return _firestore
        .collection('customer_profiles')
        .doc(userId)
        .collection('payment_methods')
        .snapshots()
        .map((snap) {
      final methods = snap.docs.map((doc) {
        return _fromFirestore(doc.data(), doc.id);
      }).toList();

      if (methods.isEmpty) {
        return [
          PaymentMethodModel(
            id: 'cash',
            name: 'Tiền mặt',
            type: PaymentMethodType.cash,
            details: 'Thanh toán khi nhận hàng (COD)',
            isDefault: true,
            isLinked: true,
            createdAt: DateTime.now(),
          ),
        ];
      }

      methods.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return 0;
      });
      return methods;
    });
  }

  /// Dam bao nguoi dung co phuong thuc thanh toan tien mat (type=1).
  /// Neu chua co thi tao ngay mot phuong thuc tien mat va dat lam mac dinh.
  Future<void> ensureDefaultCashPayment() async {
    final userId = _getUserId();
    debugPrint('PaymentMethodFirestoreService: Kiem tra payment method type=1 cho user [$userId]');

    try {
      final snap = await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('payment_methods')
          .where('type', isEqualTo: 1)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        debugPrint('PaymentMethodFirestoreService: Da co payment method type=1, khong can tao them');
        return;
      }

      debugPrint('PaymentMethodFirestoreService: Chua co type=1, tao moi phuong thuc tien mat');

      final now = FieldValue.serverTimestamp();
      await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('payment_methods')
          .add({
        'type': 1,
        'isDefault': true,
        'isLinked': true,
        'createdAt': now,
        'updatedAt': now,
      });

      debugPrint('PaymentMethodFirestoreService: Da tao payment method type=1 thanh cong');
    } catch (e) {
      debugPrint('PaymentMethodFirestoreService: Loi khi dam bao cash payment - $e');
    }
  }

  /// Chuyen tu Firestore document sang PaymentMethodModel.
  PaymentMethodModel _fromFirestore(Map<String, dynamic> data, String docId) {
    final typeInt = data['type'] as int? ?? 1;
    final type = PaymentMethodTypeExtension.fromInt(typeInt);

    String name = _buildName(type, data);
    String details = _buildDetails(type, data);

    return PaymentMethodModel(
      id: docId,
      name: name,
      type: type,
      details: details,
      isDefault: data['isDefault'] as bool? ?? false,
      cardBrand: data['cardBrand'] as String?,
      last4Digits: data['last4Digits'] as String?,
      walletBrand: data['walletBrand'] as String?,
      isLinked: data['isLinked'] as bool? ?? false,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestampNullable(data['updatedAt']),
    );
  }

  String _buildName(PaymentMethodType type, Map<String, dynamic> data) {
    switch (type) {
      case PaymentMethodType.cash:
        return 'Tiền mặt';
      case PaymentMethodType.card:
        final brand = (data['cardBrand'] as String?)?.toLowerCase();
        if (brand == 'visa') return 'Thẻ Visa';
        if (brand == 'mastercard') return 'Thẻ Mastercard';
        return 'Thẻ ngân hàng';
      case PaymentMethodType.wallet:
        final brand = (data['walletBrand'] as String?)?.toLowerCase();
        if (brand == 'momo') return 'Ví MoMo';
        if (brand == 'zalopay') return 'Ví ZaloPay';
        if (brand == 'vnpay') return 'Ví VNPay';
        if (brand == 'zalo') return 'Ví Zalo';
        return 'Ví điện tử';
    }
  }

  String _buildDetails(PaymentMethodType type, Map<String, dynamic> data) {
    switch (type) {
      case PaymentMethodType.cash:
        return 'Thanh toán khi nhận hàng (COD)';
      case PaymentMethodType.card:
        final last4 = data['last4Digits'] as String?;
        final brand = (data['cardBrand'] as String?)?.toLowerCase();
        final brandName = brand == 'visa'
            ? 'Visa'
            : brand == 'mastercard'
                ? 'Mastercard'
                : 'Thẻ';
        return last4 ?? brandName;
      case PaymentMethodType.wallet:
        final brand = (data['walletBrand'] as String?)?.toLowerCase();
        if (brand == 'momo') return 'Ví MoMo đã liên kết';
        if (brand == 'zalopay') return 'Ví ZaloPay đã liên kết';
        if (brand == 'vnpay') return 'Ví VNPay đã liên kết';
        if (brand == 'zalo') return 'Ví Zalo đã liên kết';
        return 'Ví điện tử đã liên kết';
    }
  }

  DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  DateTime? _parseTimestampNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
