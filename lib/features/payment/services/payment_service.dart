import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/auth_storage.dart';
import '../models/payment_method_model.dart';

/// Service quan ly phuong thuc thanh toan, goi API /api/payments.
///
/// Ho tro cac thao tac:
/// - GET /api/payments             : Lay danh sach
/// - GET /api/payments/{id}        : Lay 1 phuong thuc
/// - POST /api/payments            : Them moi
/// - PUT /api/payments/{id}/default : Dat mac dinh
/// - DELETE /api/payments/{id}     : Xoa
class PaymentService {
  const PaymentService();

  /// Lay header Authorization voi Bearer token.
  Options _authOptions() {
    final token = AuthStorage.getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Lay danh sach phuong thuc thanh toan.
  ///
  /// GET /api/payments
  /// Tra ve List<PaymentMethodModel>.
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/payments',
        options: _authOptions(),
      );

      final data = response.data;
      if (data == null) return [];

      final success = data['success'] as bool? ?? false;
      if (!success) {
        debugPrint('PaymentService: API tra ve success=false');
        return [];
      }

      final items = data['data'] as List<dynamic>? ?? [];

      debugPrint('PaymentService: Da nhan ${items.length} phuong thuc thanh toan');

      return items
          .map((json) => PaymentMethodModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('PaymentService: Loi getPaymentMethods - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('PaymentService: Loi khong xac dinh - $e');
      return [];
    }
  }

  /// Stream lang nghe danh sach phuong thuc thanh toan.
  ///
  /// Goi API lay du lieu ban dau.
  /// De real-time, can backend ho tro WebSocket/SSE.
  Stream<List<PaymentMethodModel>> getPaymentMethodsStream() {
    return Stream.fromFuture(getPaymentMethods());
  }

  /// Lay 1 phuong thuc thanh toan theo ID.
  ///
  /// GET /api/payments/{id}
  Future<PaymentMethodModel?> getPaymentMethod(String id) async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/payments/$id',
        options: _authOptions(),
      );

      final data = response.data;
      if (data == null) return null;

      final success = data['success'] as bool? ?? false;
      if (!success) return null;

      final itemData = data['data'] as Map<String, dynamic>?;
      if (itemData == null) return null;

      return PaymentMethodModel.fromJson(itemData);
    } catch (e) {
      debugPrint('PaymentService: Loi getPaymentMethod($id) - $e');
      return null;
    }
  }

  /// Them phuong thuc thanh toan moi.
  ///
  /// POST /api/payments
  /// Tra ve PaymentMethodModel da tao neu thanh cong, null neu that bai.
  Future<PaymentMethodModel?> addPaymentMethod({
    required String type,
    required String name,
    String? details,
    bool isDefault = false,
  }) async {
    try {
      final body = <String, dynamic>{
        'type': type,
        'name': name,
        'isDefault': isDefault,
      };

      if (details != null && details.isNotEmpty) {
        body['details'] = details;
      }

      final response = await ApiClient.post<Map<String, dynamic>>(
        '/payments',
        data: body,
        options: _authOptions(),
      );

      final data = response.data;
      if (data == null) return null;

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final message = data['message'] as String? ?? 'Them that bai';
        throw Exception(message);
      }

      final itemData = data['data'] as Map<String, dynamic>?;
      if (itemData == null) return null;

      debugPrint('PaymentService: Them phuong thuc thanh cong');
      return PaymentMethodModel.fromJson(itemData);
    } on DioException catch (e) {
      final message = _handleDioError(e);
      debugPrint('PaymentService: Loi them phuong thuc - $message');
      throw Exception(message);
    } catch (e) {
      debugPrint('PaymentService: Loi them phuong thuc - $e');
      rethrow;
    }
  }

  /// Dat phuong thuc thanh toan lam mac dinh.
  ///
  /// PUT /api/payments/{id}/default
  Future<void> setDefaultPayment(String paymentId) async {
    try {
      final response = await ApiClient.put<Map<String, dynamic>>(
        '/payments/$paymentId/default',
        options: _authOptions(),
      );

      final data = response.data;
      if (data == null) return;

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final message = data['message'] as String? ?? 'Dat mac dinh that bai';
        throw Exception(message);
      }

      debugPrint('PaymentService: Dat [$paymentId] lam mac dinh thanh cong');
    } on DioException catch (e) {
      final message = _handleDioError(e);
      debugPrint('PaymentService: Loi dat mac dinh - $message');
      throw Exception(message);
    } catch (e) {
      debugPrint('PaymentService: Loi dat mac dinh - $e');
      rethrow;
    }
  }

  /// Xoa phuong thuc thanh toan.
  ///
  /// DELETE /api/payments/{id}
  Future<void> deletePayment(String paymentId) async {
    try {
      final response = await ApiClient.delete<Map<String, dynamic>>(
        '/payments/$paymentId',
        options: _authOptions(),
      );

      final data = response.data;
      if (data == null) return;

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final message = data['message'] as String? ?? 'Xoa that bai';
        throw Exception(message);
      }

      debugPrint('PaymentService: Xoa [$paymentId] thanh cong');
    } on DioException catch (e) {
      final message = _handleDioError(e);
      debugPrint('PaymentService: Loi xoa phuong thuc - $message');
      throw Exception(message);
    } catch (e) {
      debugPrint('PaymentService: Loi xoa phuong thuc - $e');
      rethrow;
    }
  }

  /// Xu ly loi tu Dio.
  String _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 'Da xay ra loi';
    }

    switch (statusCode) {
      case 401:
        return 'Chua xac thuc. Vui long dang nhap lai.';
      case 404:
        return 'Phuong thuc thanh toan khong ton tai.';
      default:
        return 'Da xay ra loi. Vui long thu lai sau.';
    }
  }
}
