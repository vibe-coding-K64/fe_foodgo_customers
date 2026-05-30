import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/voucher_model.dart';

/// Service goi API lay danh sach voucher.
///
/// API: GET /api/vouchers?userId={userId}&storeId={storeId}
class VoucherService {
  VoucherService._();

  static const String _vouchersPath = '/vouchers';

  /// Lay danh sach voucher (myVouchers + vouchers + freeshipVouchers).
  ///
  /// [userId]  - ID nguoi dung hien tai.
  /// [storeId] - ID cua hang (lay tu cart items, co the null neu chi lay voucher he thong).
  ///
  /// Tra ve [VoucherListData] neu thanh cong.
  /// Nem [VoucherException] neu that bai.
  static Future<VoucherListData> getVouchers({
    required String userId,
    String? storeId,
  }) async {
    debugPrint('[VoucherService] Lay voucher: userId=$userId, storeId=$storeId');

    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        _vouchersPath,
        queryParameters: {
          'userId': userId,
          if (storeId != null) 'storeId': storeId,
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response data is null');
      }

      final voucherResponse = VoucherResponse.fromJson(data);

      if (!voucherResponse.success) {
        debugPrint('[VoucherService] API tra ve success=false: ${voucherResponse.message}');
        throw VoucherException(voucherResponse.message);
      }

      if (voucherResponse.data == null) {
        debugPrint('[VoucherService] Khong co data tra ve');
        throw VoucherException('Khong co du lieu voucher');
      }

      debugPrint(
        '[VoucherService] Lay thanh cong: myVouchers=${voucherResponse.data!.myVouchers.length}, '
        'vouchers=${voucherResponse.data!.vouchers.length}, '
        'freeship=${voucherResponse.data!.freeshipVouchers.length}',
      );

      return voucherResponse.data!;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String message = 'Khong the lay danh sach voucher';
      if (errorData != null && errorData is Map<String, dynamic>) {
        message = (errorData['message'] as String?) ?? message;
      }
      debugPrint('[VoucherService] DioException: $message');
      throw VoucherException(message);
    } catch (e) {
      debugPrint('[VoucherService] Exception: $e');
      rethrow;
    }
  }
}

/// Exception khi lay voucher that bai.
class VoucherException implements Exception {
  final String message;

  VoucherException(this.message);

  @override
  String toString() => 'VoucherException: $message';
}
