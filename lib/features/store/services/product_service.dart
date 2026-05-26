import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../home/models/product_model.dart';

/// Service goi API lay du lieu san pham.
class ProductService {
  const ProductService();

  /// Lay danh sach san pham noi bat.
  ///
  /// Endpoint: GET /api/products/featured
  /// Params:
  ///   - limit (mặc định: 10): Số lượng món trả về
  ///   - categoryId (optional): Lọc theo danh mục
  /// Response bao gồm nested `store` info (name, avtUrl, rating, deliveryFee, deliveryTime).
  Future<List<ProductModel>> getFeaturedProducts({
    int limit = 10,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await ApiClient.get<Map<String, dynamic>>(
        '/products/featured',
        queryParameters: queryParams,
      );

      final List<dynamic> rawData = _extractList(response.data);

      debugPrint(
          'ProductService: Da nhan ${rawData.length} san pham noi bat');

      return rawData
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ProductService: loi getFeaturedProducts - $e');
      rethrow;
    }
  }

  List<dynamic> _extractList(Map<String, dynamic>? data) {
    if (data == null) return [];
    if (data['data'] is List) return data['data'] as List;
    if (data['items'] is List) return data['items'] as List;
    return [];
  }
}
