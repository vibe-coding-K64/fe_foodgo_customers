import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/review_model.dart';

/// Exception khi thao tac danh gia that bai.
class ReviewException implements Exception {
  final String message;

  ReviewException(this.message);

  @override
  String toString() => message;
}

/// Service xu ly cac thao tac lien quan den danh gia.
///
/// Su dung backend API (/api/reviews/*) de lay danh sach va tao danh gia.
class ReviewService {
  ReviewService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  /// Lay danh sach danh gia theo cua hang.
  ///
  /// Endpoint: GET /api/reviews?storeId=xxx
  /// Response:
  /// {
  ///   "success": true,
  ///   "code": 200,
  ///   "message": "...",
  ///   "data": [ ... ]
  /// }
  static Future<List<ReviewModel>> getReviewsByStore(String storeId) async {
    debugPrint('ReviewService: Lay danh sach danh gia cua quan [$storeId]');

    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/reviews',
        queryParameters: {'storeId': storeId},
      );

      final data = response.data;
      if (data == null) {
        throw ReviewException('Khong nhan duoc phan hoi tu server');
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final message = data['message'] as String? ?? 'Khong the lay danh sach danh gia';
        throw ReviewException(message);
      }

      final dataList = data['data'] as List<dynamic>?;
      if (dataList == null) {
        return [];
      }

      final reviews = dataList
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('ReviewService: Da nhan ${reviews.length} danh gia');
      return reviews;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Lay danh sach URL avatar tu Firestore cho nhieu user cung luc.
  ///
  /// Doc tu collection `users/{userId}` field `photoUrl`.
  /// Tra ve Map<userId, avatarUrl>.
  static Future<Map<String, String>> getUserAvatars(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final uniqueIds = userIds.toSet().toList();
    final avatarMap = <String, String>{};

    await Future.wait(
      uniqueIds.map((userId) async {
        try {
          final doc = await _firestore
              .collection(_usersCollection)
              .doc(userId)
              .get();
          final photoUrl = doc.data()?['photoUrl'] as String?;
          if (photoUrl != null && photoUrl.isNotEmpty) {
            avatarMap[userId] = photoUrl;
          }
        } catch (e) {
          debugPrint('ReviewService: Loi khi lay avatar userId=$userId: $e');
        }
      }),
    );

    return avatarMap;
  }

  /// Lay avatar cua mot user cu the tu Firestore.
  static Future<String?> getUserAvatar(String userId) async {
    if (userId.isEmpty) return null;

    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      final photoUrl = doc.data()?['photoUrl'] as String?;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        return photoUrl;
      }
    } catch (e) {
      debugPrint('ReviewService: Loi khi lay avatar userId=$userId: $e');
    }
    return null;
  }

  /// Tao mot danh gia moi cho don hang da nhan.
  ///
  /// Endpoint: POST /api/reviews
  /// Body: { orderId, storeId, userId, userName, userAvatarUrl?, starRating, comment, imageUrls? }
  /// Response:
  /// {
  ///   "success": true,
  ///   "code": 200,
  ///   "message": "Tao danh gia thanh cong.",
  ///   "data": { ... }
  /// }
  ///
  /// [orderId]  : ID don hang da nhan (status = 3).
  /// [storeId]  : ID cua hang.
  /// [userId]   : ID nguoi dung.
  /// [userName] : Ho ten nguoi danh gia.
  /// [userAvatarUrl] : URL avatar (khong bat buoc).
  /// [starRating]    : So sao danh gia (1-5).
  /// [comment]       : Noi dung binh luan.
  /// [imageUrls]     : Danh sach URL hinh anh (khong bat buoc).
  static Future<ReviewModel> createReview({
    required String orderId,
    required String storeId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required int starRating,
    required String comment,
    List<String>? imageUrls,
  }) async {
    debugPrint('ReviewService: Tao danh gia cho don hang [$orderId]');

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/reviews',
        data: {
          'orderId': orderId,
          'storeId': storeId,
          'userId': userId,
          'userName': userName,
          if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
          'starRating': starRating,
          'comment': comment,
          if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        },
      );

      final data = response.data;
      if (data == null) {
        throw ReviewException('Khong nhan duoc phan hoi tu server');
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final message = data['message'] as String? ?? 'Tao danh gia that bai';
        throw ReviewException(message);
      }

      final dataBody = data['data'] as Map<String, dynamic>?;
      if (dataBody == null) {
        throw ReviewException('Phan hoi khong chua du lieu danh gia');
      }

      final review = ReviewModel.fromJson(dataBody);
      debugPrint('ReviewService: Tao danh gia thanh cong - id=${review.id}');
      return review;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Xu ly loi tu Dio.
  static ReviewException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String message;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? 'Da xay ra loi';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Khong the ket noi den server. Vui long kiem tra mang.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Server phan hoi qua cham. Vui long thu lai sau.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Khong the ket noi den server. Vui long kiem tra mang.';
    } else if (statusCode == 400) {
      if (data is Map<String, dynamic>) {
        final msg = data['message'] as String?;
        if (msg != null) {
          if (msg.contains('da danh gia')) {
            message = 'Don hang nay da duoc danh gia truoc do.';
          } else if (msg.contains('chua duoc giao') || msg.contains('trang thai')) {
            message = 'Chi co the danh gia khi don hang da hoan thanh.';
          } else {
            message = msg;
          }
        } else {
          message = 'Yeu cau khong hop le';
        }
      } else {
        message = 'Yeu cau khong hop le';
      }
    } else if (statusCode == 403) {
      message = 'Ban khong co quyen danh gia don hang nay.';
    } else if (statusCode == 404) {
      message = 'Don hang khong ton tai.';
    } else {
      message = 'Da xay ra loi. Vui long thu lai sau.';
    }

    debugPrint('ReviewService: Loi API - status=$statusCode, message=$message');
    return ReviewException(message);
  }
}
