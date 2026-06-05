import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../home/models/product_model.dart';
import '../../product/models/product_detail_info.dart';

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

      debugPrint('ProductService: Raw response type: ${response.data.runtimeType}');
      debugPrint('ProductService: Raw response keys: ${response.data?.keys.toList()}');
      debugPrint('ProductService: Raw response: ${response.data}');

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

    // 1. Thuong gap: { success: true, data: [...] }
    if (data['data'] is List) {
      debugPrint('ProductService: Tim thay key "data"');
      return data['data'] as List;
    }

    // 2. Thuong gap: { success: true, items: [...] }
    if (data['items'] is List) {
      debugPrint('ProductService: Tim thay key "items"');
      return data['items'] as List;
    }

    // 3. Gap truc tiep: [...] (mang truc tiep, khong co wrapper)
    if (data['success'] is! bool && data.length <= 3) {
      for (final value in data.values) {
        if (value is List && value.isNotEmpty && value.first is Map) {
          debugPrint('ProductService: Phat hien mang truc tiep - keys: ${data.keys.toList()}');
          return value;
        }
      }
    }

    // 4. Fallback: neu chinh no la 1 List
    if (data is List) {
      debugPrint('ProductService: Response la List truc tiep');
      return data as List;
    }

    debugPrint('ProductService: Khong tim thay mang - keys: ${data.keys.toList()}, type: ${data.runtimeType}');
    return [];
  }

  /// Lay danh sach san pham theo ID cua hang.
  ///
  /// Endpoint: GET /api/products?storeId={storeId}
  Future<List<ProductModel>> getProductsByStoreId(String storeId) async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {'storeId': storeId},
      );

      final List<dynamic> rawData = _extractList(response.data);

      debugPrint(
          'ProductService: Da nhan ${rawData.length} san pham cho store [$storeId]');

      return rawData
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ProductService: loi getProductsByStoreId - $e');
      rethrow;
    }
  }

  /// Lay thong tin mot san pham theo foodId.
  ///
  /// Endpoint: GET /api/products/{foodId}
  /// Su dung de lay imageUrl thuc cua san pham trong gio hang.
  Future<ProductModel?> getProductById(String foodId) async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/products/$foodId',
      );

      if (response.data == null) return null;

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data?['data'] as Map<String, dynamic>?);

      if (data == null) return null;

      debugPrint('ProductService: Lay product [$foodId] tu API');
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('ProductService: Product [$foodId] khong tim thay');
        return null;
      }
      debugPrint('ProductService: loi getProductById - $e');
      return null;
    } catch (e) {
      debugPrint('ProductService: loi getProductById - $e');
      return null;
    }
  }

  /// Lay rating va reviewCount cua san pham tu Firestore.
  ///
  /// Doc tu collection `products/{productId}` fields `rating` va `reviewCount`.
  Future<ProductDetailInfo?> getProductDetailInfo(String productId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return ProductDetailInfo(
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: data['reviewCount'] as int? ?? 0,
      );
    } catch (e) {
      debugPrint('ProductService: loi getProductDetailInfo - $e');
      return null;
    }
  }
}
