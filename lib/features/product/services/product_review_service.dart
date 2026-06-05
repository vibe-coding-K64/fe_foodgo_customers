import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../models/product_review_model.dart';

/// Service cung cap du lieu danh gia theo mon an (foodId).
class ProductReviewService {
  ProductReviewService._();

  /// Lay danh sach danh gia cua mot mon an.
  ///
  /// Endpoint: GET /reviews?storeId=xxx&foodId=yyy
  static Future<List<ProductReviewModel>> getReviewsByProduct({
    required String productId,
    required String storeId,
  }) async {
    debugPrint('========== [ProductReviewService] BAT DAU ==========');
    debugPrint('>>> REQUEST: GET /reviews');
    debugPrint('>>>   storeId = $storeId');
    debugPrint('>>>   foodId   = $productId');

    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/reviews',
        queryParameters: {
          'storeId': storeId,
          'foodId': productId,
        },
      );

      final data = response.data;
      debugPrint('<<< RESPONSE: ${data?.toString()}');
      debugPrint('<<< success  = ${data?['success']}');

      final responseData = data?['data'];
      debugPrint('<<< data.runtimeType = ${responseData?.runtimeType}');

      if (data == null || data['success'] != true) {
        throw Exception(data?['message'] ?? 'Loi lay danh sach danh gia');
      }

      // Backend tra ve: { "total": N, "reviews": [...] }
      // reviews la mot List con nam trong key "reviews"
      List<dynamic>? rawList;
      if (responseData is List) {
        // Phong chan: neu backend tra ve List truc tiep (sai cu phap)
        rawList = responseData;
        debugPrint('<<< RAW LIST (direct) length = ${rawList.length}');
      } else if (responseData is Map) {
        // Dung cu phap: lay key "reviews"
        rawList = responseData['reviews'] as List<dynamic>?;
        debugPrint('<<< RAW LIST (from reviews key) length = ${rawList?.length}');
        debugPrint('<<< total field = ${responseData['total']}');
      } else {
        rawList = null;
        debugPrint('!!! responseData khong phai List hay Map, runtimeType = ${responseData?.runtimeType}');
      }

      if (rawList == null || rawList.isEmpty) {
        debugPrint('!!! rawList rong hoac null — API tra ve danh sach trong');
        throw Exception('Danh sach danh gia trong');
      }

      if (rawList.isNotEmpty) {
        debugPrint('<<< RAW ITEM[0] = ${rawList[0]}');
      }

      final reviews = rawList!
          .map((item) => ProductReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('>>> Parsed ${reviews.length} reviews — DUNG API THAT');
      debugPrint('========== [ProductReviewService] XONG (API) ==========');
      return reviews;
    } catch (e) {
      debugPrint('!!! ProductReviewService ERROR: $e');
      debugPrint('!!! Fallback sang MOCK DATA — API chua san sang hoac loi');
      debugPrint('========== [ProductReviewService] XONG (MOCK) ==========');
      return _mockReviews;
    }
  }

  // ================================================================
  // MOCK DATA — xoa khi API da san sang
  // ================================================================

  static final List<ProductReviewModel> _mockReviews = [
    ProductReviewModel(
      id: 'pr001',
      productId: 'p001',
      userId: 'u001',
      userName: 'Nguyen Van A',
      userAvatarUrl: '',
      starRating: 5,
      comment: 'Mon an rat ngon, gui nhanh, dong goi dep. Se goi lai!',
      imageUrls: [],
      createdAt: DateTime(2026, 5, 28, 12, 30),
      updatedAt: DateTime(2026, 5, 28, 12, 30),
    ),
    ProductReviewModel(
      id: 'pr002',
      productId: 'p001',
      userId: 'u002',
      userName: 'Tran Thi B',
      userAvatarUrl: '',
      starRating: 4,
      comment: 'Huong vi cuon, nhung phan topping it hon mot chut so voi anh.',
      imageUrls: [],
      createdAt: DateTime(2026, 5, 27, 18, 45),
      updatedAt: DateTime(2026, 5, 27, 18, 45),
    ),
    ProductReviewModel(
      id: 'pr003',
      productId: 'p001',
      userId: 'u003',
      userName: 'Le Van C',
      userAvatarUrl: '',
      starRating: 5,
      comment: 'That tuyet voi! Mon nay la mon yeu thich cua ca gia dinh.',
      imageUrls: [],
      createdAt: DateTime(2026, 5, 26, 20, 10),
      updatedAt: DateTime(2026, 5, 26, 20, 10),
    ),
    ProductReviewModel(
      id: 'pr004',
      productId: 'p001',
      userId: 'u004',
      userName: 'Pham Thi D',
      userAvatarUrl: '',
      starRating: 3,
      comment: 'Tam duoc, nhung gia ca hon moi that.',
      imageUrls: [],
      createdAt: DateTime(2026, 5, 25, 11, 0),
      updatedAt: DateTime(2026, 5, 25, 11, 0),
    ),
    ProductReviewModel(
      id: 'pr005',
      productId: 'p001',
      userId: 'u005',
      userName: 'Hoang Van E',
      userAvatarUrl: '',
      starRating: 4,
      comment: 'Mon an tuoi ngon, nhan vien than thien.',
      imageUrls: [],
      createdAt: DateTime(2026, 5, 24, 14, 20),
      updatedAt: DateTime(2026, 5, 24, 14, 20),
    ),
    ProductReviewModel(
      id: 'pr006',
      productId: 'p001',
      userId: 'u006',
      userName: 'Vu Thi F',
      userAvatarUrl: '',
      starRating: 5,
      comment: '',
      imageUrls: [],
      createdAt: DateTime(2026, 5, 23, 9, 30),
      updatedAt: DateTime(2026, 5, 23, 9, 30),
    ),
    ProductReviewModel(
      id: 'pr007',
      productId: 'p001',
      userId: 'u007',
      userName: 'Dinh Van G',
      userAvatarUrl: '',
      starRating: 2,
      comment: 'Lan nay mon den tre hon thoi gian du kien.',
      imageUrls: [],
      createdAt: DateTime(2026, 5, 22, 19, 0),
      updatedAt: DateTime(2026, 5, 22, 19, 0),
    ),
    ProductReviewModel(
      id: 'pr008',
      productId: 'p001',
      userId: 'u008',
      userName: 'Bui Thi H',
      userAvatarUrl: '',
      starRating: 4,
      comment: 'Ngon, se quay lai lan nua.',
      imageUrls: [],
      createdAt: DateTime(2026, 5, 21, 16, 40),
      updatedAt: DateTime(2026, 5, 21, 16, 40),
    ),
  ];
}
