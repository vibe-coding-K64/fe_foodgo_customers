/// Model ket hop san pham + thong tin cua hang.
///
/// Tai vi ProductModel khong co storeName va rating, can mot model trung gian
/// de hien thi ket qua tim kiem day du (hinh anh, ten mon, ten cua hang,
/// gia, danh gia, nut them).
class SearchResultItem {
  final String id;
  final String productName;
  final String productImageUrl;
  final double price;
  final String storeName;
  final double rating;
  final int reviewCount;
  final bool isOutOfStock;
  final String productId;
  final String storeId;

  const SearchResultItem({
    required this.id,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.storeName,
    required this.rating,
    required this.reviewCount,
    required this.isOutOfStock,
    required this.productId,
    required this.storeId,
  });

  /// Parse tu JSON tra ve tu my-json-server.
  ///
  /// JSON mau:
  /// ```json
  /// {
  ///   "id": "search_001",
  ///   "productName": "iPhone 15 Pro Max 256GB",
  ///   "productImageUrl": "https://example.com/images/iphone15.jpg",
  ///   "price": 29990000.0,
  ///   "storeName": "Apple Store Official",
  ///   "rating": 4.9,
  ///   "reviewCount": 1250,
  ///   "isOutOfStock": false,
  ///   "productId": "p_apple_15pm",
  ///   "storeId": "s_apple_vn"
  /// }
  /// ```
  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productImageUrl: json['productImageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      storeName: json['storeName'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      isOutOfStock: json['isOutOfStock'] as bool? ?? false,
      productId: json['productId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
    );
  }
}
