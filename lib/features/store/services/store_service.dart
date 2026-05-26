import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../home/models/store_model.dart';

/// Service goi API lay du lieu cua hang / quan an.
class StoreService {
  const StoreService();

  /// Lay danh sach quan gan day.
  ///
  /// Endpoint: GET /api/stores/nearby
  /// Params:
  ///   - lat (bắt buộc): Vĩ độ người dùng
  ///   - lng (bắt buộc): Kinh độ người dùng
  ///   - radius (mặc định: 5000): Bán kính tìm kiếm (mét)
  ///   - limit (mặc định: 10): Số lượng quán trả về
  ///   - categoryId (optional): Lọc theo danh mục
  Future<List<StoreModel>> getNearbyStores({
    required double lat,
    required double lng,
    int radius = 5000,
    int limit = 10,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'radius': radius,
        'limit': limit,
      };
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await ApiClient.get<Map<String, dynamic>>(
        '/stores/nearby',
        queryParameters: queryParams,
      );

      final List<dynamic> rawData = _extractList(response.data);

      debugPrint('StoreService: Da nhan ${rawData.length} quan gan day');

      return rawData
          .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StoreService: loi getNearbyStores - $e');
      rethrow;
    }
  }

  /// Lay danh sach quan pho bien.
  ///
  /// Endpoint: GET /api/stores/popular
  /// Params:
  ///   - limit (mặc định: 10): Số lượng quán trả về
  ///   - categoryId (optional): Lọc theo danh mục
  ///   - minRating (mặc định: 0): Lọc rating tối thiểu
  Future<List<StoreModel>> getPopularStores({
    int limit = 10,
    String? categoryId,
    double minRating = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'minRating': minRating,
      };
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await ApiClient.get<Map<String, dynamic>>(
        '/stores/popular',
        queryParameters: queryParams,
      );

      final List<dynamic> rawData = _extractList(response.data);

      debugPrint('StoreService: Da nhan ${rawData.length} quan pho bien');

      return rawData
          .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StoreService: loi getPopularStores - $e');
      rethrow;
    }
  }

  /// Tim kiem quan theo tu khoa.
  ///
  /// Endpoint: GET /api/stores/nearby?q=keyword
  Future<List<StoreModel>> searchStores(String keyword) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/stores/nearby',
        queryParameters: {'q': keyword.trim()},
      );

      final List<dynamic> rawData = _extractList(response.data);

      debugPrint(
          'StoreService: Tim kiem [$keyword] -> ${rawData.length} ket qua');

      return rawData
          .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StoreService: loi searchStores - $e');
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
