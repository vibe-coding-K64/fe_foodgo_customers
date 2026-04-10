import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../home/models/store_model.dart';

/// Service goi API lay du lieu cua hang / quan an.
class StoreService {
  const StoreService();

  /// Lay danh sach quan gan day.
  ///
  /// Endpoint: GET /nearby_stores
  /// API tra ve truc tiep List. Khong co truong data bao ngoai.
  Future<List<StoreModel>> getNearbyStores() async {
    try {
      final response = await ApiClient.get<List<dynamic>>('/nearby_stores');

      // API tra ve truc tiep Array -> response.data la List.
      final List<dynamic> rawData = response.data ?? [];

      debugPrint('StoreService: Da nhan ${rawData.length} quan gan day');

      return rawData
          .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StoreService: Loi getNearbyStores - $e');
      rethrow;
    }
  }

  /// Tim kiem quan theo tu khoa.
  ///
  /// Endpoint: GET /nearby_stores?q=keyword
  /// API tra ve truc tiep List.
  Future<List<StoreModel>> searchStores(String keyword) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    try {
      final response = await ApiClient.get<List<dynamic>>(
        '/nearby_stores',
        queryParameters: {'q': keyword.trim()},
      );

      final List<dynamic> rawData = response.data ?? [];

      debugPrint(
          'StoreService: Tim kiem [$keyword] -> ${rawData.length} ket qua');

      return rawData
          .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StoreService: Loi searchStores - $e');
      rethrow;
    }
  }
}
