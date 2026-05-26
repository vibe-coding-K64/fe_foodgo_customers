/// Model danh gia cua mot quan an.
class ReviewModel {
  final String id;
  final String? orderId;
  final String storeId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final int starRating;
  final String? comment;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    this.orderId,
    required this.storeId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.starRating,
    this.comment,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String?,
      storeId: json['storeId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: (json['userAvatarUrl'] as String?) ?? '',
      starRating: json['starRating'] as int,
      comment: json['comment'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}

/// Mock data thong ke so sao.
class ReviewStarDistribution {
  final int star5;
  final int star4;
  final int star3;
  final int star2;
  final int star1;

  ReviewStarDistribution({
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
