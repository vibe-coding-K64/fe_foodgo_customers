import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/voucher_model.dart';

/// Service doc voucher truc tiep tu Firestore (thay the VoucherService goi API).
///
/// Doc tu 2 collection:
///   - customer_profiles/{userId}/my_vouchers  - voucher da doi cua user
///   - vouchers                                - voucher he thong / cua hang
///
/// Logic loc 3 tab tren VoucherSelectionSheet:
///   Tab Giam gia:  my_vouchers (isFreeship=false)
///                 + vouchers (isFreeship=false, storeId==null, pointsRequired==0)
///   Tab Shop:      vouchers (storeId!=null)
///   Tab Freeship:  my_vouchers (isFreeship=true)
///                 + vouchers (isFreeship=true, pointsRequired==0)
class MyVoucherFirestoreService {
  MyVoucherFirestoreService._();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Doc voucher tu my_vouchers (da doi cua user).
  static Future<List<VoucherModel>> getMyVouchers(String userId) async {
    debugPrint(
        '[MyVoucherFirestore] Doc my_vouchers cho userId=$userId');
    try {
      final snap = await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('my_vouchers')
          .get();

      debugPrint(
          '[MyVoucherFirestore] Da doc ${snap.docs.length} voucher tu my_vouchers');
      return snap.docs
          .map((doc) => VoucherModel.fromMyVoucher(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[MyVoucherFirestore] Loi doc my_vouchers: $e');
      rethrow;
    }
  }

  /// Doc voucher tu collection vouchers (root).
  /// Lay cac voucher co isActive=true.
  /// Loc them theo storeId neu can.
  static Future<List<VoucherModel>> getPublicVouchers({
    String? storeId,
    bool? isFreeship,
  }) async {
    debugPrint(
        '[MyVoucherFirestore] Doc vouchers: storeId=$storeId, isFreeship=$isFreeship');
    try {
      CollectionReference<Map<String, dynamic>> col = _firestore.collection('vouchers');

      // Loc isActive=true
      Query<Map<String, dynamic>> query = col.where('isActive', isEqualTo: true);

      final snap = await query.get();

      var vouchers = snap.docs
          .map((doc) => VoucherModel.fromPublicVoucher(doc.data()))
          .toList();

      // Loc them theo storeId
      if (storeId != null) {
        vouchers = vouchers.where((v) {
          // Lay voucher he thong (storeId==null) hoac voucher cua cua hang nay
          return v.storeId == null || v.storeId == storeId;
        }).toList();
      }

      // Loc them theo isFreeship
      if (isFreeship != null) {
        vouchers = vouchers.where((v) => v.isFreeship == isFreeship).toList();
      }

      debugPrint(
          '[MyVoucherFirestore] Da doc ${vouchers.length} voucher tu vouchers');
      return vouchers;
    } catch (e) {
      debugPrint('[MyVoucherFirestore] Loi doc vouchers: $e');
      rethrow;
    }
  }

  /// Lay voucher cho checkout: gop my_vouchers + vouchers, da loc theo 3 tab.
  ///
  /// [userId]  - ID nguoi dung hien tai.
  /// [storeId] - ID cua hang (dung de loc voucher shop).
  static Future<VoucherListData> getVouchersForCheckout({
    required String userId,
    String? storeId,
  }) async {
    debugPrint(
        '[MyVoucherFirestore] Lay voucher checkout: userId=$userId, storeId=$storeId');

    // Doc ca 2 collection cung luc
    final results = await Future.wait([
      getMyVouchers(userId),
      getPublicVouchers(storeId: storeId),
    ]);

    final myVouchers = results[0];
    final publicVouchers = results[1];

    // --- Tab Giam gia (discount) ---
    // my_vouchers: khong freeship (da doi roi, dung duoc)
    final myDiscount = myVouchers.where((v) => !v.isFreeship).toList();
    // vouchers: khong freeship, he thong (storeId==null), khong can diem (pointsRequired==0)
    final pubDiscount = publicVouchers
        .where((v) =>
            !v.isFreeship && v.storeId == null && v.pointsRequired == 0)
        .toList();

    // --- Tab Shop ---
    // vouchers co storeId != null (voucher cua cua hang cu the)
    final shopVouchers =
        publicVouchers.where((v) => v.storeId != null).toList();

    // --- Tab Freeship ---
    // my_vouchers: freeship (da doi roi, dung duoc)
    final myFreeship = myVouchers.where((v) => v.isFreeship).toList();
    // vouchers: freeship, khong can diem (pointsRequired==0)
    final pubFreeship = publicVouchers
        .where((v) => v.isFreeship && v.pointsRequired == 0)
        .toList();

    debugPrint(
        '[MyVoucherFirestore] Ket qua: discount=${myDiscount.length}+${pubDiscount.length}, '
        'shop=${shopVouchers.length}, freeship=${myFreeship.length}+${pubFreeship.length}');

    return VoucherListData(
      myVouchers: [...myDiscount, ...pubDiscount],
      vouchers: shopVouchers,
      freeshipVouchers: [...myFreeship, ...pubFreeship],
    );
  }
}
