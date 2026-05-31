import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

/// Service goi API Cart.
///
/// Base URL: /api/cart
///
/// Cac endpoint:
///   GET    /api/cart                  - Lay danh sach gio hang
///   POST   /api/cart/add              - Them mon vao gio hang
///   PUT    /api/cart/{itemId}/quantity - Cap nhat so luong
///   DELETE /api/cart/{itemId}        - Xoa mot mon
///   DELETE /api/cart                 - Xoa toan bo gio hang
class CartApiService {
  const CartApiService();

  /// Lay toan bo gio hang cua nguoi dung.
  ///
  /// [userId] : ID nguoi dung.
  ///
  /// Tra ve response data.data: { "items": [...], "storeId": "...", "storeName": "...", "storeImageUrl": "..." }
  /// throws [DioException] neu co loi.
  Future<Map<String, dynamic>> getCart({required String userId}) async {
    final response = await ApiClient.get<Map<String, dynamic>>(
      '/cart',
      queryParameters: {'userId': userId},
    );

    final responseData = response.data;
    if (responseData == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Response data is null',
      );
    }

    final success = responseData['success'] as bool? ?? false;
    if (!success) {
      final code = responseData['code'] as int? ?? 0;
      final message = responseData['message'] as String? ?? 'Unknown error';
      throw DioException(
        requestOptions: response.requestOptions,
        error: message,
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: code,
          data: responseData,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return responseData;
  }

  /// Them mot mon vao gio hang.
  ///
  /// [userId]        : ID nguoi dung.
  /// [storeId]       : ID cua hang chua mon an.
  /// [foodId]        : ID san pham/mon an.
  /// [quantity]      : So luong them vao (>= 1).
  /// [selectedOptions]: Danh sach nhom options da chon. Moi nhom gom
  ///                   { "name": "Kich thuoc", "options": [{ "name": "Lon" }] }.
  /// [note]          : Ghi chu cho cua hang. Co the null.
  ///
  /// Tra ve response data (data.data cua API response).
  /// throws [DioException] neu co loi.
  Future<Map<String, dynamic>> addToCart({
    required String userId,
    required String storeId,
    required String foodId,
    required int quantity,
    List<Map<String, dynamic>>? selectedOptions,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'storeId': storeId,
      'foodId': foodId,
      'quantity': quantity,
    };

    if (selectedOptions != null && selectedOptions.isNotEmpty) {
      body['selectedOptions'] = selectedOptions;
    }

    if (note != null && note.isNotEmpty) {
      body['note'] = note;
    }

    final response = await ApiClient.post<Map<String, dynamic>>(
      '/cart/add',
      data: body,
    );

    final responseData = response.data;
    if (responseData == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Response data is null',
      );
    }

    final success = responseData['success'] as bool? ?? false;
    if (!success) {
      final code = responseData['code'] as int? ?? 0;
      final message = responseData['message'] as String? ?? 'Unknown error';
      throw DioException(
        requestOptions: response.requestOptions,
        error: message,
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: code,
          data: responseData,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return responseData;
  }

  /// Cap nhat so luong cua mot mon trong gio hang.
  ///
  /// [itemId]   : ID cua item trong gio hang (cartItemId).
  /// [userId]   : ID nguoi dung.
  /// [quantity] : So luong moi (>= 1).
  ///
  /// throws [DioException] neu so luong khong hop le hoac item khong ton tai.
  Future<void> updateQuantity({
    required String itemId,
    required String userId,
    required int quantity,
  }) async {
    final response = await ApiClient.put<Map<String, dynamic>>(
      '/cart/$itemId/quantity',
      data: {
        'userId': userId,
        'quantity': quantity,
      },
    );

    final responseData = response.data;
    if (responseData == null) return;

    final success = responseData['success'] as bool? ?? false;
    if (!success) {
      final code = responseData['code'] as int? ?? 0;
      final message = responseData['message'] as String? ?? 'Unknown error';
      throw DioException(
        requestOptions: response.requestOptions,
        error: message,
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: code,
          data: responseData,
        ),
        type: DioExceptionType.badResponse,
      );
    }
  }

  /// Xoa mot mon khoi gio hang.
  ///
  /// [itemId] : ID cua item trong gio hang (cartItemId).
  /// [userId] : ID nguoi dung.
  ///
  /// Phuong thuc nay idempotent - tra ve thanh cong ke ca khi
  /// item khong ton tai trong gio hang.
  Future<void> removeFromCart({
    required String itemId,
    required String userId,
  }) async {
    final response = await ApiClient.delete<Map<String, dynamic>>(
      '/cart/$itemId',
      queryParameters: {'userId': userId},
    );

    final responseData = response.data;
    if (responseData == null) return;

    final success = responseData['success'] as bool? ?? false;
    if (!success) {
      final code = responseData['code'] as int? ?? 0;
      final message = responseData['message'] as String? ?? 'Unknown error';
      throw DioException(
        requestOptions: response.requestOptions,
        error: message,
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: code,
          data: responseData,
        ),
        type: DioExceptionType.badResponse,
      );
    }
  }

  /// Xoa toan bo gio hang cua nguoi dung.
  ///
  /// [userId] : ID nguoi dung.
  Future<void> clearCart({required String userId}) async {
    final response = await ApiClient.delete<Map<String, dynamic>>(
      '/cart',
      queryParameters: {'userId': userId},
    );

    final responseData = response.data;
    if (responseData == null) return;

    final success = responseData['success'] as bool? ?? false;
    if (!success) {
      final code = responseData['code'] as int? ?? 0;
      final message = responseData['message'] as String? ?? 'Unknown error';
      throw DioException(
        requestOptions: response.requestOptions,
        error: message,
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: code,
          data: responseData,
        ),
        type: DioExceptionType.badResponse,
      );
    }
  }
}
