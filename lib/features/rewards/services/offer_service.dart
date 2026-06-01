import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/auth_storage.dart';
import '../models/rewards_model.dart';

/// Thong tin diem va hang thanh vien cua nguoi dung.
class UserRewardInfo {
  final int loyaltyPoints;
  final int? membershipTier;
  /// Thu hang cua nguoi dung (bat dau tu 1).
  final int rank;

  const UserRewardInfo({
    required this.loyaltyPoints,
    this.membershipTier,
    this.rank = 0,
  });

  /// So diem can dat de len hang tiep theo.
  int get nextTierPoints {
    final tier = membershipTier ?? 0;
    switch (tier) {
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
/// Doc truc tiep tu Firebase Firestore, khong goi API.
class OfferService {
  OfferService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay thong tin diem thanh vien va hang hien tai cua nguoi dung.
  ///
  /// Doc tu document cua nguoi dung trong collection `customer_profiles`.
  /// Tra ve [UserRewardInfo] hoac null neu chua dang nhap.
  static Future<UserRewardInfo?> getUserRewardInfo() async {
    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('OfferService: Chua dang nhap, khong lay duoc thong tin diem');
      return null;
    }

    debugPrint('OfferService: Lay thong tin diem cho userId = $userId');

    try {
      final doc = await _firestore.collection('customer_profiles').doc(userId).get();

      if (!doc.exists) {
        debugPrint('OfferService: Khong tim thay document user $userId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      final points = (data['loyaltyPoints'] as num?)?.toInt() ?? 0;
      final tier = (data['membershipTier'] as num?)?.toInt() ?? 0;

      int calculatedRank = 0;
      try {
        final snapshot = await _firestore
            .collection('customer_profiles')
            .where('loyaltyPoints', isGreaterThan: points)
            .get();
        calculatedRank = snapshot.docs.length + 1;
      } catch (e) {
        debugPrint('OfferService: loi tinh rank = $e');
      }

      debugPrint('OfferService: Diem = $points, Hang = $tier, Rank = $calculatedRank');

      return UserRewardInfo(
        loyaltyPoints: points,
        membershipTier: tier,
        rank: calculatedRank,
      );
    } catch (e, st) {
      debugPrint('OfferService: loi khi lay thong tin diem = $e');
      debugPrint('Stack trace: $st');
      return null;
    }
  }

  /// Lay danh sach voucher co the doi diem.
  /// Doc truc tiep tu Firestore collection `vouchers`.
  /// Chi lay voucher toan he thong (storeId = null), con han (expiryDate >= hôm nay).
  static Future<List<ExchangeVoucherModel>> getSystemVouchers() async {
    debugPrint('OfferService: Lay system vouchers tu Firestore');

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Firestore chi cho phep toi da 1 inequality filter nen chi loc
      // isActive va storeId o day, cac dieu kien khac loc bang Dart.
      final snapshot = await _firestore
          .collection('vouchers')
          .where('isActive', isEqualTo: true)
          .where('storeId', isNull: true)
          .get();

      final vouchers = snapshot.docs
          .map((doc) => ExchangeVoucherModel.fromVoucher(doc))
          .where((v) =>
              v.pointsRequired > 0 &&
              v.remaining > 0 &&
              !v.expiryDate.isBefore(today))
          .toList();

      debugPrint('OfferService: Lay duoc ${vouchers.length} system voucher con han');
      return vouchers;
    } catch (e) {
      debugPrint('OfferService: Loi lay system vouchers = $e');
      return [];
    }
  }

  /// Lay danh sach voucher cua nguoi dung.
  /// Doc truc tiep tu Firestore sub-collection `customer_profiles/{userId}/my_vouchers`.
  /// Chi lay voucher con han (expiryDate >= hôm nay).
  static Future<List<MyVoucherModel>> getMyVouchers() async {
    debugPrint('OfferService: Lay my-vouchers tu Firestore');

    final userId = AuthStorage.getUserId();
    if (userId == null) {
      debugPrint('OfferService: Chua dang nhap, tra ve rong');
      return [];
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('my_vouchers')
          .get();

      final vouchers = snapshot.docs
          .map((doc) => MyVoucherModel.fromFirestore(doc))
          .where((v) => !v.expiryDate.isBefore(today))
          .toList();

      debugPrint('OfferService: Lay duoc ${vouchers.length} my voucher con han');
      return vouchers;
    } catch (e) {
      debugPrint('OfferService: Loi lay my vouchers = $e');
      return [];
    }
  }

  /// Dong diem lay voucher qua API `/api/vouchers/exchange`.
  ///
  /// Tra ve [ExchangedVoucherData] neu thanh cong, hoac null neu that bai.
  /// [errorMessage] se chua message loi tu API (neu co).
  static Future<(ExchangedVoucherData?, String?)> exchangeVoucher({
    required String voucherId,
  }) async {
    debugPrint('OfferService: Dong voucher [$voucherId]');

    try {
      final token = AuthStorage.getToken();
      if (token == null) {
        debugPrint('OfferService: Khong co token');
        return (null, 'Ban chua dang nhap. Vui long dang nhap lai.');
      }

      final response = await ApiClient.post<Map<String, dynamic>>(
        '/vouchers/exchange',
        data: {'voucherId': voucherId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data;
      if (data == null) {
        return (null, 'Khong nhan duoc phan hoi tu server.');
      }

      if (data['success'] != true) {
        final msg = data['message'] as String? ?? 'Doi voucher that bai.';
        debugPrint('OfferService: API tra loi loi = $msg');
        return (null, msg);
      }

      final json = data['data'] as Map<String, dynamic>?;
      if (json == null) {
        return (null, 'Khong nhan duoc du lieu voucher.');
      }

      final exchanged = ExchangedVoucherData.fromJson(json);
      debugPrint('OfferService: Doi voucher thanh cong - ${exchanged.name}');
      return (exchanged, null);
    } catch (e, st) {
      debugPrint('OfferService: Loi khi goi API exchange = $e');
      debugPrint('Stack trace: $st');
      return (null, 'Khong the ket noi den server. Vui long thu lai sau.');
    }
  }
}
