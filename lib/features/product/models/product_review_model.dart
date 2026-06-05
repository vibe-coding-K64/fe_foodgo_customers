/// Model danh gia cua mot mon an (theo foodId = productId).
class ProductReviewModel {
  final String id;
  final String productId;   // = foodId
  final String? orderId;
  final String? storeId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final int starRating;
  final String? comment;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? repliedAt;
  final String? replyComment;

  ProductReviewModel({
    required this.id,
    required this.productId,
    this.orderId,
    this.storeId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.starRating,
    this.comment,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.repliedAt,
    this.replyComment,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'] as String? ?? '',
      productId: (json['foodId'] as String?) ??
                 (json['productId'] as String?) ?? '',
      orderId: json['orderId'] as String?,
      storeId: json['storeId'] as String?,
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userAvatarUrl: (json['userAvatarUrl'] as String?) ??
                     (json['avatarUrl'] as String?) ?? '',
      starRating: json['starRating'] as int? ?? 0,
      comment: json['comment'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      repliedAt: _parseNullableDateTime(json['repliedAt']),
      replyComment: json['replyComment'] as String?,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'orderId': orderId,
      'storeId': storeId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'starRating': starRating,
      'comment': comment,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'repliedAt': repliedAt?.toIso8601String(),
      'replyComment': replyComment,
    };
  }

  ProductReviewModel copyWith({
    String? id,
    String? productId,
    String? orderId,
    String? storeId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    int? starRating,
    String? comment,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? repliedAt,
    String? replyComment,
  }) {
    return ProductReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      starRating: starRating ?? this.starRating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      repliedAt: repliedAt ?? this.repliedAt,
      replyComment: replyComment ?? this.replyComment,
    );
  }
}

/// Mock data thong ke so sao.
class ProductReviewStarDistribution {
  final int star5;
  final int star4;
  final int star3;
  final int star2;
  final int star1;

  ProductReviewStarDistribution({
    required this.star5,
    required this.star4,
    required this.star3,
    required this.star2,
    required this.star1,
  });

  int get total => star5 + star4 + star3 + star2 + star1;

  double getPercent(int star) {
    if (total == 0) return 0;
    switch (star) {
      case 5:
        return star5 / total;
      case 4:
        return star4 / total;
      case 3:
        return star3 / total;
      case 2:
        return star2 / total;
      case 1:
        return star1 / total;
      default:
        return 0;
    }
  }
}
