import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../home/models/product_model.dart';

/// Service goi API lay du lieu san pham.
class ProductService {
  const ProductService();

  /// Lay danh sach san pham noi bat.
  ///
  /// Endpoint: GET /featured_products
  /// API tra ve truc tiep List. Khong co truong data bao ngoai.
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response =
          await ApiClient.get<List<dynamic>>('/featured_products');

      // API tra ve truc tiep Array -> response.data la List.
      final List<dynamic> rawData = response.data ?? [];

      debugPrint('ProductService: Da nhan ${rawData.length} san pham noi bat');

      return rawData
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ProductService: Loi getFeaturedProducts - $e');
      rethrow;
    }
  }
}
