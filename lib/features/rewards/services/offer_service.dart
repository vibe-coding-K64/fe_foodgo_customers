import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/auth_storage.dart';
import '../models/rewards_model.dart';

/// Thong tin diem va hang thanh vien cua nguoi dung.
class UserRewardInfo {
  final int loyaltyPoints;
  final int membershipTier;

  const UserRewardInfo({
    required this.loyaltyPoints,
    required this.membershipTier,
  });

  /// So diem can dat de len hang tiep theo.
  int get nextTierPoints {
    switch (membershipTier) {
      case 0:
        return 1000;
      case 1:
        return 2000;
      case 2:
        return 3000;
      default:
        return 0;
    }
  }
}

/// Service xu ly cac thao tac lay du lieu uu dai.
class OfferService {
  OfferService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay thong tin diem thanh vien va hang hien tai cua nguoi dung.
  ///
  /// Doc tu document cua nguoi dung trong collection `users`.
  /// Tra ve [UserRewardInfo] hoac null neu chua dang nhap.
  static Future<UserRewardInfo?> getUserRewardInfo() async {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('OfferService: Chua dang nhap, khong lay duoc thong tin diem');
      return null;
    }

    debugPrint('OfferService: Lay thong tin diem cho userId = $userId');

    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        debugPrint('OfferService: Khong tim thay document user $userId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      final points = (data['loyaltyPoints'] as num?)?.toInt() ?? 0;
      final tier = (data['membershipTier'] as num?)?.toInt() ?? 0;

      debugPrint('OfferService: Diem = $points, Hang = $tier');

      return UserRewardInfo(
        loyaltyPoints: points,
        membershipTier: tier,
      );
    } catch (e, st) {
      debugPrint('OfferService: Loi khi lay thong tin diem = $e');
      debugPrint('Stack trace: $st');
      return null;
    }
  }

  /// Lay danh sach voucher co the doi diem tu collection `system_vouchers`.
  ///
  /// Tra ve danh sach [SystemVoucherModel].
  static Future<List<SystemVoucherModel>> getSystemVouchers() async {
    debugPrint('OfferService: Lay danh sach system_vouchers');

    try {
      final snapshot = await _firestore.collection('system_vouchers').get();

      final vouchers = snapshot.docs
          .map((doc) => SystemVoucherModel.fromFirestore(doc))
          .toList();

      debugPrint('OfferService: Lay duoc ${vouchers.length} system voucher');

      return vouchers;
    } catch (e, st) {
      debugPrint('OfferService: Loi khi lay system_vouchers = $e');
      debugPrint('Stack trace: $st');
      return [];
    }
  }

  /// Lay danh sach voucher cua nguoi dung tu sub-collection
  /// `users/{userId}/my_vouchers`.
  ///
  /// Tra ve danh sach [MyVoucherModel].
  static Future<List<MyVoucherModel>> getMyVouchers() async {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('OfferService: Chua dang nhap, khong lay duoc voucher');
      return [];
    }

    debugPrint('OfferService: Lay my_vouchers cho userId = $userId');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_vouchers')
          .get();

      final vouchers = snapshot.docs
          .map((doc) => MyVoucherModel.fromFirestore(doc))
          .toList();

      debugPrint('OfferService: Lay duoc ${vouchers.length} my voucher');

      return vouchers;
    } catch (e, st) {
      debugPrint('OfferService: Loi khi lay my_vouchers = $e');
      debugPrint('Stack trace: $st');
      return [];
    }
  }
}
