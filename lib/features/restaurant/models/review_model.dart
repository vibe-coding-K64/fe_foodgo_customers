/// Model danh gia cua mot quan an.
///
/// Mo phong du lieu tu Firestore de test UI.
class ReviewModel {
  final String id;
  final String storeId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final int starRating;
  final String? comment;
  final List<String> imageUrls;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.starRating,
    this.comment,
    this.imageUrls = const [],
    required this.createdAt,
  });
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
