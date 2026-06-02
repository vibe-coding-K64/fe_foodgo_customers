import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../order/models/order_model.dart';

class FoodReviewException implements Exception {
  final String message;
  FoodReviewException(this.message);
  @override
  String toString() => message;
}

/// Model một mục đánh giá — đại diện cho một productId đã gom.
/// Mỗi dòng trên UI là 1 FoodReviewItemModel.
class FoodReviewItemModel {
  final String productId;
  final String foodName;
  final String? foodImageUrl;
  int totalQuantity;
  final double price;
  int starRating;
  String comment;
  List<XFile> pickedImages;
  List<String> uploadedUrls;

  FoodReviewItemModel({
    required this.productId,
    required this.foodName,
    this.foodImageUrl,
    required this.totalQuantity,
    required this.price,
    this.starRating = 0,
    this.comment = '',
    List<XFile>? pickedImages,
    List<String>? uploadedUrls,
  })  : pickedImages = pickedImages ?? [],
        uploadedUrls = uploadedUrls ?? [];

  bool get hasImages => pickedImages.isNotEmpty || uploadedUrls.isNotEmpty;
}

/// Service xử lý đánh giá món ăn.
class FoodReviewService {
  FoodReviewService._();

  static final _imagePicker = ImagePicker();

  /// Gom cac item trong order theo productId.
  /// Items cung productId → gop thanh 1 dong, cong so luong.
  static List<FoodReviewItemModel> getReviewItemsFromOrder(OrderModel order) {
    debugPrint(
        'FoodReviewService: Tao danh sach gom tu don [${order.id}] — ${order.items.length} items');

    final Map<String, FoodReviewItemModel> grouped = {};

    for (final item in order.items) {
      if (grouped.containsKey(item.foodId)) {
        grouped[item.foodId]!.totalQuantity += item.quantity;
      } else {
        grouped[item.foodId] = FoodReviewItemModel(
          productId: item.foodId,
          foodName: item.name,
          foodImageUrl: item.imageUrl,
          totalQuantity: item.quantity,
          price: item.price,
        );
      }
    }

    final result = grouped.values.toList();
    debugPrint(
        'FoodReviewService: Gop thanh ${result.length} dong danh gia');
    return result;
  }

  /// Mo image picker cho phep chon nhieu anh tu gallery.
  static Future<void> pickImagesForItem(FoodReviewItemModel item) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );
      if (images.isEmpty) return;

      final maxImages = 5 - item.pickedImages.length;
      if (maxImages <= 0) return;

      item.pickedImages.addAll(images.take(maxImages));
      debugPrint(
          'FoodReviewService: Da chon ${images.length} anh cho "${item.foodName}" (tong: ${item.pickedImages.length})');
    } catch (e) {
      debugPrint('FoodReviewService: Loi pickImages — $e');
    }
  }

  /// Chup anh moi tu camera.
  static Future<void> takePhotoForItem(FoodReviewItemModel item) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo == null) return;
      if (item.pickedImages.length >= 5) return;

      item.pickedImages.add(photo);
      debugPrint(
          'FoodReviewService: Da chup anh cho "${item.foodName}" (tong: ${item.pickedImages.length})');
    } catch (e) {
      debugPrint('FoodReviewService: Loi takePhoto — $e');
    }
  }

  /// Xoa 1 anh da chon.
  static void removeImage(FoodReviewItemModel item, int index) {
    if (index >= 0 && index < item.pickedImages.length) {
      item.pickedImages.removeAt(index);
    }
  }

  /// Gui danh gia — tat ca trong 1 request multipart.
  ///
  /// Luong:
  ///   1. Build metadata JSON
  ///   2. Gan toan bo anh vao FormData
  ///   3. Goi 1 lan POST /reviews/batch
  ///
  /// Backend endpoint: POST /reviews/batch
  ///   Content-Type: multipart/form-data
  ///   Part "metadata": JSON string (orderId, storeId, userId, userName, userAvatarUrl, items)
  ///   Part "images": binary files (0-n file anh)
  ///
  /// Response:
  ///   { "success": true, "message": "...", "data": { "count": 2, "reviewIds": [...] } }
  static Future<bool> submitFoodReviews({
    required String orderId,
    required String storeId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required List<FoodReviewItemModel> items,
  }) async {
    // Chi gui nhung dong co sao
    final ratedItems =
        items.where((item) => item.starRating > 0).toList();
    if (ratedItems.isEmpty) {
      throw FoodReviewException('Vui long chon it nhat 1 sao de danh gia.');
    }

    // === LOG GUI ===
    debugPrint('==========================================');
    debugPrint('📤 FOOD REVIEW — GUI REQUEST');
    debugPrint('==========================================');
    debugPrint('Endpoint : POST /reviews/batch');
    debugPrint('Order ID : $orderId');
    debugPrint('Store ID : $storeId');
    debugPrint('User ID  : $userId');
    debugPrint('User     : $userName');
    debugPrint('Avatar   : ${userAvatarUrl ?? "khong co"}');
    debugPrint('Items    : ${ratedItems.length}');
    for (final item in ratedItems) {
      debugPrint(
          '  ★ ${item.starRating} | "${item.foodName}" (${item.productId}) | Comment: "${item.comment}" | Anh local: ${item.pickedImages.length} file(s)');
    }
    debugPrint('==========================================');

    // 1. Build metadata JSON
    final metadata = {
      'orderId': orderId,
      'storeId': storeId,
      'userId': userId,
      'userName': userName,
      if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
      'items': ratedItems.map((item) => {
        'productId': item.productId,
        'starRating': item.starRating,
        'comment': item.comment,
        'imageUrls': <String>[], // backend se gan URL sau khi upload anh
      }).toList(),
    };

    debugPrint('Metadata JSON: ${jsonEncode(metadata)}');

    // 2. Build FormData — gan metadata + toan bo anh
    final formData = FormData.fromMap({
      'metadata': jsonEncode(metadata),
    });

    for (final item in ratedItems) {
      for (final imageFile in item.pickedImages) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.name,
            ),
          ),
        );
      }
    }

    debugPrint('FormData fields : ${formData.fields.map((f) => '${f.key}: ${f.value}').join(' | ')}');
    debugPrint('FormData files  : ${formData.files.map((f) => '${f.key}: ${f.value.filename}').join(' | ')}');

    // 3. Goi API that
    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/reviews/batch',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      // === LOG NHAN ===
      debugPrint('==========================================');
      debugPrint('📥 FOOD REVIEW — NHAN RESPONSE');
      debugPrint('==========================================');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Body: ${response.data}');

      final data = response.data;
      if (data == null) {
        throw FoodReviewException('Khong nhan duoc phan hoi tu server.');
      }
      if (data['success'] != true) {
        throw FoodReviewException(
          data['message'] as String? ?? 'Gui danh gia that bai.',
        );
      }

      final count = data['data']?['count'] as int? ?? ratedItems.length;
      debugPrint('✅ FOOD REVIEW — THANH CONG ($count danh gia)');
      debugPrint('==========================================');

      return true;
    } on DioException catch (e) {
      debugPrint('==========================================');
      debugPrint('❌ FOOD REVIEW — LOI NETWORK');
      debugPrint('==========================================');
      debugPrint('Type    : ${e.type}');
      debugPrint('Message : ${e.message}');
      debugPrint('Status  : ${e.response?.statusCode}');
      debugPrint('Body    : ${e.response?.data}');
      debugPrint('==========================================');
      throw FoodReviewException(
        e.response?.data?['message'] as String? ??
            'Gui danh gia that bai. Vui long thu lai.',
      );
    }
  }
}
