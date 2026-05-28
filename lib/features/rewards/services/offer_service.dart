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

  /// Lay danh sach voucher co the doi diem tu API `/api/vouchers/system`
  /// (fallback: Firestore `system_vouchers`).
  ///
  /// Tra ve danh sach [ExchangeVoucherModel].
  static Future<List<ExchangeVoucherModel>> getSystemVouchers() async {
    return getSystemVouchersApi();
  }

  /// Lay danh sach voucher cua nguoi dung tu API `/api/vouchers/my-vouchers`
  /// (fallback: Firestore `customer_profiles/{userId}/my_vouchers`).
  ///
  /// Tra ve danh sach [MyVoucherModel].
  static Future<List<MyVoucherModel>> getMyVouchers() async {
    return getMyVouchersApi();
  }

  /// Lay danh sach voucher he thong co the doi diem tu API `/api/vouchers/system`.
  ///
  /// Su dung auth header. Tra ve danh sach [ExchangeVoucherModel].
  /// Neu API fail thi fallback ve Firestore `system_vouchers`.
  static Future<List<ExchangeVoucherModel>> getSystemVouchersApi() async {
    debugPrint('OfferService: Lay danh sach system vouchers tu API');

    try {
      final token = AuthStorage.getToken();
      if (token == null) {
        debugPrint('OfferService: Khong co token, fallback ve Firestore');
        return _fallbackGetSystemVouchers();
      }

      final response = await ApiClient.get<Map<String, dynamic>>(
        '/vouchers/system',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data;
      if (data == null || data['success'] != true) {
        debugPrint('OfferService: API tra loi khong thanh cong, fallback ve Firestore');
        return _fallbackGetSystemVouchers();
      }

      final list = data['data'] as List<dynamic>? ?? [];
      final vouchers = list
          .map((e) => SystemVoucherApi.fromJson(e as Map<String, dynamic>))
          .map((api) => api.toExchangeVoucher())
          .toList();

      debugPrint('OfferService: Lay tu API duoc ${vouchers.length} system voucher');
      return vouchers;
    } catch (e, st) {
      debugPrint('OfferService: Loi goi API system vouchers = $e');
      debugPrint('Stack trace: $st');
      return _fallbackGetSystemVouchers();
    }
  }

  /// Fallback: doc tu Firestore `system_vouchers`.
  static Future<List<ExchangeVoucherModel>> _fallbackGetSystemVouchers() async {
    debugPrint('OfferService: Fallback - doc system_vouchers tu Firestore');
    try {
      final snapshot = await _firestore.collection('system_vouchers').get();
      final vouchers = snapshot.docs
          .map((doc) => ExchangeVoucherModel.fromSystemVoucher(
              SystemVoucherModel.fromFirestore(doc)))
          .toList();
      debugPrint('OfferService: Fallback lay duoc ${vouchers.length} system voucher');
      return vouchers;
    } catch (e) {
      debugPrint('OfferService: Fallback that bai = $e');
      return [];
    }
  }

  /// Lay danh sach voucher cua nguoi dung tu API `/api/vouchers/my-vouchers`.
  ///
  /// Su dung auth header. Tra ve danh sach [MyVoucherModel].
  /// Neu API fail thi fallback ve Firestore sub-collection.
  static Future<List<MyVoucherModel>> getMyVouchersApi() async {
    debugPrint('OfferService: Lay my-vouchers tu API');

    try {
      final token = AuthStorage.getToken();
      if (token == null) {
        debugPrint('OfferService: Khong co token, fallback ve Firestore');
        return _fallbackGetMyVouchers();
      }

      final response = await ApiClient.get<Map<String, dynamic>>(
        '/vouchers/my-vouchers',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data;
      if (data == null || data['success'] != true) {
        debugPrint('OfferService: API tra loi khong thanh cong, fallback ve Firestore');
        return _fallbackGetMyVouchers();
      }

      final list = data['data'] as List<dynamic>? ?? [];
      final vouchers = list
          .map((e) => MyVoucherApi.fromJson(e as Map<String, dynamic>))
          .map((api) => api.toMyVoucher())
          .toList();

      debugPrint('OfferService: Lay tu API duoc ${vouchers.length} my voucher');
      return vouchers;
    } catch (e, st) {
      debugPrint('OfferService: Loi goi API my-vouchers = $e');
      debugPrint('Stack trace: $st');
      return _fallbackGetMyVouchers();
    }
  }

  /// Fallback: doc tu Firestore `customer_profiles/{userId}/my_vouchers`.
  static Future<List<MyVoucherModel>> _fallbackGetMyVouchers() async {
    debugPrint('OfferService: Fallback - doc my_vouchers tu Firestore');
    final userId = AuthStorage.getUserId();
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('my_vouchers')
          .get();
      final vouchers = snapshot.docs
          .map((doc) => MyVoucherModel.fromFirestore(doc))
          .toList();
      debugPrint('OfferService: Fallback lay duoc ${vouchers.length} my voucher');
      return vouchers;
    } catch (e) {
      debugPrint('OfferService: Fallback that bai = $e');
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
