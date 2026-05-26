/// Model ket qua tim kiem tu API /api/search.
///
/// Model nay dong hop thong tin san pham + thong tin cua hang de hien thi
/// trang ket qua tim kiem (hinh anh, ten mon, ten cua hang, gia, danh gia).
class SearchResultItem {
  final String productId;
  final String productName;
  final String storeId;
  final String storeName;
  final double price;
  final double rating;
  final int reviewCount;
  final double distance;
  final String imageUrl;

  const SearchResultItem({
    required this.productId,
    required this.productName,
    required this.storeId,
    required this.storeName,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.imageUrl,
  });

  /// Parse tu JSON tra ve tu API /api/search.
  ///
  /// JSON mau:
  /// ```json
  /// {
  ///   "productId": "prod_001",
  ///   "productName": "Com tam suon bi cha",
  ///   "storeId": "store_001",
  ///   "storeName": "Com tam Phuc Loc Tho",
  ///   "price": 45000.0,
  ///   "rating": 4.8,
  ///   "reviewCount": 500,
  ///   "distance": 2.1,
  ///   "imageUrl": "https://..."
  /// }
  /// ```
  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
