import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../home/models/store_model.dart';

/// Service goi API lay du lieu cua hang / quan an.
class StoreService {
  StoreService._();

  static final StoreService _instance = StoreService._();
  factory StoreService() => _instance;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay danh sach quan gan day.
  ///
  /// Step 1: Lay store list tu API (khong co lat/lng)
  /// Step 2: Batch-fetch lat/lng tu Firestore /stores/{id}
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

      final stores = rawData
          .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return _mergeCoordinatesFromFirestore(stores);
    } catch (e) {
      debugPrint('StoreService: loi getNearbyStores - $e');
      rethrow;
    }
  }

  /// Lay danh sach quan pho bien.
  ///
  /// Endpoint: GET /api/stores/popular
  /// Params:
  ///   - lat (bắt buộc): Vĩ độ người dùng
  ///   - lng (bắt buộc): Kinh độ người dùng
  ///   - limit (mặc định: 10): Số lượng quán trả về
  ///   - categoryId (optional): Lọc theo danh mục
  ///   - minRating (mặc định: 0): Lọc rating tối thiểu
  Future<List<StoreModel>> getPopularStores({
    required double lat,
    required double lng,
    int limit = 10,
    String? categoryId,
    double minRating = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'lat': lat,
        'lng': lng,
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

    // 1. Thuong gap: { success: true, data: [...] }
    if (data['data'] is List) {
      return data['data'] as List;
    }

    // 2. Thuong gap: { success: true, items: [...] }
    if (data['items'] is List) {
      return data['items'] as List;
    }

    // 3. Gap truc tiep: [...] (mang truc tiep, khong co wrapper)
    if (data['success'] is! bool && data.length <= 3) {
      for (final value in data.values) {
        if (value is List && value.isNotEmpty && value.first is Map) {
          debugPrint('StoreService: Phat hien mang truc tiep trong response');
          return value;
        }
      }
    }

    // 4. Fallback: neu chinh no la 1 List
    if (data is List) {
      return data as List;
    }

    debugPrint('StoreService: Khong tim thay mang trong response - keys: ${data.keys.toList()}');
    return [];
  }

  /// Batch-fetch lat/lng tu Firestore cho cac store, tra ve list da merge.
  Future<List<StoreModel>> _mergeCoordinatesFromFirestore(
      List<StoreModel> stores) async {
    if (stores.isEmpty) return stores;

    final storeIds = stores.map((s) => s.id).toList();

    try {
      // Batch fetch: docRef.get() cho tung store
      final futures = storeIds.map((id) async {
        final doc = await _firestore.collection('stores').doc(id).get();
        if (!doc.exists || doc.data() == null) return (id, null, null);
        final data = doc.data()!;
        final lat = (data['lat'] as num?)?.toDouble();
        final lng = (data['lng'] as num?)?.toDouble();
        return (id, lat, lng);
      });

      final results = await Future.wait(futures);
      final coordMap = {for (var r in results) r.$1: (r.$2, r.$3)};

      int merged = 0;
      final result = stores.map((store) {
        final coord = coordMap[store.id];
        if (coord != null && coord.$1 != null && coord.$2 != null) {
          merged++;
          return store.copyWith(lat: coord.$1, lng: coord.$2);
        }
        return store;
      }).toList();

      debugPrint('StoreService: Merged coordinates for $merged/${stores.length} stores from Firestore');
      return result;
    } catch (e) {
      debugPrint('StoreService: Loi batch-fetch Firestore coordinates - $e');
      return stores;
    }
  }
}
