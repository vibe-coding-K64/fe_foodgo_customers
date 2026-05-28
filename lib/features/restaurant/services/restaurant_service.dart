import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/auth_storage.dart';
import '../../home/models/store_model.dart';
import '../../home/models/product_model.dart';
import '../../store/services/product_service.dart';
import '../models/restaurant_category_model.dart';
import '../models/restaurant_detail_response.dart';
import '../models/review_model.dart';

/// Service cung cap du lieu cho trang chi tiet quan an.
///
/// Doc du lieu tu Firestore, fallback ve mock data neu can.
class RestaurantService {
  RestaurantService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================================================================
  // CHI TIET CUA HANG - FIRESTORE + API
  // ================================================================

  /// Lay toan bo thong tin cua hang.
  ///
  /// Step 1: Firestore /stores/{storeId}  -> thong tin co ban (faster)
  /// Step 2: API /products?storeId=...     -> san pham
  /// Step 3: API /categories/{cid}         -> danh muc
  ///
  /// Tinh khoang cach tu vi tri nguoi dung -> toa do cua hang.
  static Future<RestaurantDetailResponse> getRestaurantDetail(
      String storeId) async {
    debugPrint(
        'RestaurantService: Lay chi tiet cua hang [$storeId]');

    // Step 1: Lay store tu Firestore
    late StoreModel store;
    try {
      final firestoreStore = await getStoreById(storeId);
      if (firestoreStore != null) {
        final distance = _calculateDistanceFromUser(firestoreStore.lat, firestoreStore.lng);
        store = firestoreStore.copyWith(distance: distance);
        debugPrint('RestaurantService: Lay store [$storeId] tu Firestore, distance=$distance km');
      } else {
        throw Exception('Store [$storeId] khong ton tai trong Firestore');
      }
    } catch (e) {
      debugPrint('RestaurantService: Loi doc Firestore store [$storeId] - $e, fallback API');
      store = await _fetchStoreFromApi(storeId);
    }

    // Step 2: Lay san pham tu API
    late List<ProductModel> products;
    try {
      final productsResponse = await _apiGet<Map<String, dynamic>>(
        '/products',
        queryParameters: {'storeId': storeId},
      );
      final rawData = _extractListFromResponse(productsResponse.data);
      products = rawData
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
      debugPrint(
          'RestaurantService: Da lay ${products.length} san pham cho store [$storeId]');
    } catch (e) {
      debugPrint('RestaurantService: Loi lay san pham - $e');
      products = [];
    }

    // Step 3: Lay categories tu store.categoryIds
    List<RestaurantCategoryModel> categories;
    try {
      final categoryIds = store.categoryIds;
      categories = [
        RestaurantCategoryModel(id: 'all', name: 'Tất cả', order: 0),
      ];
      for (int i = 0; i < categoryIds.length; i++) {
        final cid = categoryIds[i];
        try {
          final cateResponse = await _apiGet<Map<String, dynamic>>(
            '/categories/$cid',
          );
          if (cateResponse.data != null) {
            final cateJson = cateResponse.data as Map<String, dynamic>;
            categories.add(RestaurantCategoryModel(
              id: cateJson['id']?.toString() ?? cid,
              name: cateJson['name']?.toString() ?? cid,
              order: i + 1,
            ));
          }
        } catch (_) {
          categories.add(RestaurantCategoryModel(
            id: cid,
            name: cid,
            order: i + 1,
          ));
        }
      }
      categories.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      debugPrint('RestaurantService: Loi lay categories - $e');
      categories = [
        RestaurantCategoryModel(id: 'all', name: 'Tất cả', order: 0),
      ];
    }

    final result = RestaurantDetailResponse(
      store: store,
      categories: categories,
      products: products,
    );

    debugPrint(
        'RestaurantService: Da nhan chi tiet - store: ${result.store.name}, '
        'categories: ${result.categories.length}, products: ${result.products.length}');

    return result;
  }

  /// Fallback: lay store tu API khi Firestore that bai.
  static Future<StoreModel> _fetchStoreFromApi(String storeId) async {
    final storeResponse = await _apiGet<Map<String, dynamic>>(
      '/stores/$storeId',
    );
    final storeJson = storeResponse.data as Map<String, dynamic>;
    if (storeJson.containsKey('store') && storeJson['store'] is Map) {
      return StoreModel.fromJson(storeJson['store'] as Map<String, dynamic>);
    }
    return StoreModel.fromJson(storeJson);
  }

  /// Tinh khoang cach (km) tu vi tri nguoi dung den toa do cua hang.
  /// Su dung cong thuc Haversine.
  /// Tra ve 0.0 neu khong co du lieu vi tri.
  static double _calculateDistanceFromUser(double? storeLat, double? storeLng) {
    final userLat = AuthStorage.getUserLatitude();
    final userLng = AuthStorage.getUserLongitude();

    if (storeLat == null || storeLng == null || userLat == null || userLng == null) {
      return 0.0;
    }

    const double earthRadius = 6371; // km
    final dLat = _toRadians(storeLat - userLat);
    final dLng = _toRadians(storeLng - userLng);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(userLat)) *
            math.cos(_toRadians(storeLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    final distance = earthRadius * c;
    return double.parse(distance.toStringAsFixed(2));
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  /// Trich xuat mang tu response.data, xu ly nhieu format khac nhau.
  static List<dynamic> _extractListFromResponse(Map<String, dynamic>? data) {
    if (data == null) return [];
    if (data['data'] is List) return data['data'] as List;
    if (data['items'] is List) return data['items'] as List;
    if (data['products'] is List) return data['products'] as List;
    // Gap mang truc tiep
    if (data['success'] is! bool && data.length <= 3) {
      for (final value in data.values) {
        if (value is List && value.isNotEmpty && value.first is Map) {
          return value;
        }
      }
    }
    if (data is List) return data as List;
    debugPrint('RestaurantService: Khong tim thay mang - keys: ${data.keys.toList()}');
    return [];
  }

  /// Wrapper goi GET qua ApiClient.
  static Future<Response<T>> _apiGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return ApiClient.get<T>(
      path,
      queryParameters: queryParameters,
    );
  }

  // ================================================================
  // FIRESTORE: LAY THONG TIN STORE
  // ================================================================

  /// Lay thong tin chi tiet cua mot quan tu Firestore.
  static Future<StoreModel?> getStoreById(String storeId) async {
    debugPrint('RestaurantService: Lay store [$storeId] tu Firestore');
    try {
      final doc = await _firestore.collection('stores').doc(storeId).get();
      if (!doc.exists || doc.data() == null) {
        debugPrint('RestaurantService: Store [$storeId] khong ton tai');
        return null;
      }
      return StoreModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('RestaurantService: Loi lay store - $e');
      return null;
    }
  }

  // ================================================================
  // FIRESTORE: LAY DANH MUC (TU SYSTEM_CATEGORIES)
  // ================================================================

  /// Lay danh sach danh muc cua mot quan.
  ///
  /// Doc `categoryIds` tu store, map sang `system_categories`.
  /// Tra ve list `RestaurantCategoryModel` voi "Tat ca" o dau.
  /// Fallback ve `getCategories()` (mock) neu store khong co categoryIds.
  static Future<List<RestaurantCategoryModel>> getCategories(String storeId) async {
    debugPrint('RestaurantService: Lay danh muc cho store [$storeId]');

    try {
      final storeDoc =
          await _firestore.collection('stores').doc(storeId).get();

      if (!storeDoc.exists) {
        return _getDefaultCategories();
      }

      final storeData = storeDoc.data()!;
      final categoryIds = (storeData['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];

      if (categoryIds.isEmpty) {
        return _getDefaultCategories();
      }

      final List<RestaurantCategoryModel> result = [
        RestaurantCategoryModel(id: 'all', name: 'Tat ca', order: 0),
      ];

      for (final cid in categoryIds) {
        try {
          final cateDoc = await _firestore
              .collection('system_categories')
              .doc(cid)
              .get();

          if (cateDoc.exists && cateDoc.data() != null) {
            final data = cateDoc.data()!;
            result.add(RestaurantCategoryModel(
              id: cid,
              name: data['name'] as String? ?? cid,
              order: (data['order'] as int? ?? 0) + 1,
            ));
          }
        } catch (e) {
          debugPrint('RestaurantService: Loi doc category [$cid] - $e');
        }
      }

      result.sort((a, b) => a.order.compareTo(b.order));
      debugPrint(
          'RestaurantService: Lay duoc ${result.length} danh muc cho store [$storeId]');
      return result;
    } catch (e) {
      debugPrint('RestaurantService: Loi lay danh muc - $e, fallback ve mock');
      return _getDefaultCategories();
    }
  }

  /// Khoang cach tu nguoi dung den quan (don vi: km).
  static double getMockDistance() {
    return 2.5;
  }

  /// Danh sach category mac dinh (mock).
  static List<RestaurantCategoryModel> _getDefaultCategories() {
    return [
      RestaurantCategoryModel(id: 'all', name: 'Tat ca', order: 0),
      RestaurantCategoryModel(id: 'drinks', name: 'Nuoc uong', order: 1),
      RestaurantCategoryModel(id: 'fast_food', name: 'Do an nhanh', order: 2),
      RestaurantCategoryModel(id: 'vietnamese', name: 'An vat', order: 3),
      RestaurantCategoryModel(id: 'snacks', name: 'Do an vat', order: 4),
      RestaurantCategoryModel(id: 'dessert', name: 'Trang mieng', order: 5),
      RestaurantCategoryModel(id: 'breakfast', name: 'Bua sang', order: 6),
      RestaurantCategoryModel(id: 'seafood', name: 'Hai san', order: 7),
    ];
  }

  // ================================================================
  // FIRESTORE: LAY SAN PHAM THEO CUA HANG
  // ================================================================

  /// Lay toan bo san pham cua mot quan tu API (tra ve Stream).
  static Stream<List<ProductModel>> getProductsByStoreStream(String storeId) {
    debugPrint(
        'RestaurantService: Lay Stream san pham cua store [$storeId] tu Firestore');
    return _firestore
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .where('deletedAt', isNull: true)
        .snapshots()
        .handleError((error) {
      debugPrint('RestaurantService[Loi Stream san pham]: $error');
    }).map((snapshot) {
      debugPrint(
          'RestaurantService: Da nhan ${snapshot.docs.length} san pham cho store [$storeId]');
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Lay toan bo san pham cua mot quan tu API.
  ///
  /// Endpoint: GET /api/products?storeId={storeId}
  static Future<List<ProductModel>> getProductsByStoreId(
      String storeId) async {
    debugPrint(
        'RestaurantService: Lay san pham cua store [$storeId] tu API');
    try {
      return await ProductService().getProductsByStoreId(storeId);
    } catch (e) {
      debugPrint('RestaurantService: Loi lay san pham tu API - $e');
      rethrow;
    }
  }

  /// Lay san pham theo danh muc cua quan tu API.
  ///
  /// [storeId]   : ID cua hang
  /// [categoryId]: ID danh muc he thong (VD: "cate_001").
  ///              Neu la "all" -> tra ve tat ca san pham cua cua hang.
  ///
  /// API tra ve tat ca san pham, loc theo categoryId ben phia client.
  static Future<List<ProductModel>> getProductsByCategory(
    String storeId,
    String categoryId,
  ) async {
    debugPrint(
        'RestaurantService: Lay san pham [$categoryId] cua store [$storeId] tu API');
    try {
      final allProducts = await ProductService().getProductsByStoreId(storeId);

      if (categoryId == 'all') {
        debugPrint(
            'RestaurantService: Tra ve ${allProducts.length} san pham (tat ca)');
        return allProducts;
      }

      final filtered = allProducts
          .where((p) => p.categoryId == categoryId)
          .toList();
      debugPrint(
          'RestaurantService: Tra ve ${filtered.length} san pham theo danh muc [$categoryId]');
      return filtered;
    } catch (e) {
      debugPrint('RestaurantService: Loi lay san pham theo danh muc - $e');
      rethrow;
    }
  }

  // ================================================================
  // MOCK: DANH GIA (dung API)
  // ================================================================

  /// Lay danh sach mock danh gia cho mot quan.
  static List<ReviewModel> getMockReviews(String storeId) {
    debugPrint('RestaurantService: Tra ve danh sach danh gia cua quan [$storeId]');
    return _mockReviews.map((r) => ReviewModel(
      id: r.id,
      storeId: storeId,
      userId: r.userId,
      userName: r.userName,
      userAvatarUrl: r.userAvatarUrl,
      starRating: r.starRating,
      comment: r.comment,
      imageUrls: r.imageUrls,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
  }

  /// Lay thong ke phan bo so sao.
  static ReviewStarDistribution getMockStarDistribution() {
    return ReviewStarDistribution(
      star5: 850,
      star4: 250,
      star3: 100,
      star2: 30,
      star1: 20,
    );
  }

  // ================================================================
  // MOCK DATA - DANH GIA
  // ================================================================

  static final List<ReviewModel> _mockReviews = [
    ReviewModel(
      id: 'r001',
      storeId: 's001',
      userId: 'u001',
      userName: 'Nguyen Van A',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
      starRating: 5,
      comment:
          'Quan an rat ngon, dac biet la com suon nuong that suot. Thuc don da dong du, mon moi deu thu vi. Nhan vien phuc vu nhanh chong va than thien.',
      imageUrls: [
        'https://picsum.photos/seed/review1a/300/300',
        'https://picsum.photos/seed/review1b/300/300',
        'https://picsum.photos/seed/review1c/300/300',
      ],
      createdAt: DateTime(2026, 4, 5, 10, 30),
      updatedAt: DateTime(2026, 4, 5, 10, 30),
    ),
    ReviewModel(
      id: 'r002',
      storeId: 's001',
      userId: 'u002',
      userName: 'Tran Thi B',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=5',
      starRating: 4,
      comment:
          'Khoang cach gan, giao hang nhanh hon mong doi. Mon an duoc goi lan 2 van con ngon, dam bao chat luong on dinh.',
      imageUrls: [],
      createdAt: DateTime(2026, 4, 4, 14, 15),
      updatedAt: DateTime(2026, 4, 4, 14, 15),
    ),
    ReviewModel(
      id: 'r003',
      storeId: 's001',
      userId: 'u003',
      userName: 'Le Van C',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=8',
      starRating: 5,
      comment: null,
      imageUrls: [],
      createdAt: DateTime(2026, 4, 3, 9, 0),
      updatedAt: DateTime(2026, 4, 3, 9, 0),
    ),
    ReviewModel(
      id: 'r004',
      storeId: 's001',
      userId: 'u004',
      userName: 'Pham Thi D',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=12',
      starRating: 3,
      comment:
          'Mon an huu ich, nhung thoi gian giao hang tre hon du kien 15 phut. Ban dau goi tra sua that doan, tra rat thom nhung it ngot hon mong doi.',
      imageUrls: [],
      createdAt: DateTime(2026, 4, 2, 18, 45),
      updatedAt: DateTime(2026, 4, 2, 18, 45),
    ),
    ReviewModel(
      id: 'r005',
      storeId: 's001',
      userId: 'u005',
      userName: 'Hoang Van E',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=20',
      starRating: 4,
      comment:
          'Ga ran that suot, vo gieng, khong bi dai. Pho mai que cung rat ngon, pho mai tan chay vua phai.',
      imageUrls: [
        'https://picsum.photos/seed/review5a/300/300',
      ],
      createdAt: DateTime(2026, 4, 1, 12, 0),
      updatedAt: DateTime(2026, 4, 1, 12, 0),
    ),
    ReviewModel(
      id: 'r006',
      storeId: 's001',
      userId: 'u006',
      userName: 'Vo Thi F',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=25',
      starRating: 2,
      comment:
          'Banh mi cha ca khong tuan thuat nhu luc dau. Bot pho mai, cha ca it, rau thom con la cac o.',
      imageUrls: [],
      createdAt: DateTime(2026, 3, 30, 20, 30),
      updatedAt: DateTime(2026, 3, 30, 20, 30),
    ),
    ReviewModel(
      id: 'r007',
      storeId: 's001',
      userId: 'u007',
      userName: 'Duong Van G',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=33',
      starRating: 1,
      comment:
          'Don hang bi thieu mon, goi 3 mon nhung chi nhan duoc 1 mon. Lien he ho tro khong duoc giai quyet. Rat that vong.',
      imageUrls: [],
      createdAt: DateTime(2026, 3, 28, 22, 0),
      updatedAt: DateTime(2026, 3, 28, 22, 0),
    ),
    ReviewModel(
      id: 'r008',
      storeId: 's001',
      userId: 'u008',
      userName: 'Bui Thi H',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=40',
      starRating: 5,
      comment:
          'Che Thai o day la tot nhat tuoi lam. Rau cau, dua, thach, banh lot, sua dac deu tot. Gian dien qua, that suot.',
      imageUrls: [
        'https://picsum.photos/seed/review8a/300/300',
        'https://picsum.photos/seed/review8b/300/300',
      ],
      createdAt: DateTime(2026, 3, 25, 15, 10),
      updatedAt: DateTime(2026, 3, 25, 15, 10),
    ),
  ];
}
