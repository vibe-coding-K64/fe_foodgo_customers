import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/checkout_models.dart';

/// Service goi API checkout.
///
/// Endpoint: POST /api/orders/checkout
class CheckoutService {
  CheckoutService._();

  static const String _checkoutPath = '/orders/checkout';

  /// Thuc hien dat hang (checkout).
  ///
  /// [request] chua: userId, addressId, paymentMethod, storeId, items,
  /// note, discountVoucherId, shopVoucherId, freeshipVoucherId.
  ///
  /// Tra ve [CheckoutResponse] neu thanh cong.
  /// Nem [CheckoutError] neu that bai.
  static Future<CheckoutResponse> checkout(CheckoutRequest request) async {
    debugPrint('[CheckoutService] Bat dau checkout cho userId=${request.userId}');

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        _checkoutPath,
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response data is null');
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final error = CheckoutError.fromJson(data);
        debugPrint('[CheckoutService] Checkout that bai: code=${error.code}, message=${error.message}');
        throw CheckoutException(error);
      }

      final checkoutResponse = CheckoutResponse.fromJson(
        data['data'] as Map<String, dynamic>? ?? {},
      );

      debugPrint('[CheckoutService] Response JSON: $data');
      debugPrint(
        '[CheckoutService] Checkout thanh cong: orderId=${checkoutResponse.orderId}, '
        'orderCode=${checkoutResponse.orderCode}, finalAmount=${checkoutResponse.finalAmount}',
      );

      return checkoutResponse;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData != null) {
        final error = CheckoutError.fromJson(errorData as Map<String, dynamic>);
        debugPrint('[CheckoutService] DioException: code=${error.code}, message=${error.message}');
        throw CheckoutException(error);
      }
      debugPrint('[CheckoutService] DioException: ${e.message}');
      rethrow;
    }
  }
}

/// Exception khi checkout that bai, chua thong tin loi tu API.
class CheckoutException implements Exception {
  final CheckoutError error;

  CheckoutException(this.error);

  @override
  String toString() => 'CheckoutException(code=${error.code}, message=${error.message})';

  bool get isEmptyCart => error.code == 400 && error.message.contains('Gio hang');
  bool get isOutOfRange => error.code == 400 && error.message.contains('khoang cach');
  bool get isInvalidVoucher => error.code == 400 && error.message.contains('Voucher');
  bool get isOutOfStock => error.code == 400 && error.message.contains('het hang');
  bool get isAddressNotFound => error.code == 404;
}
