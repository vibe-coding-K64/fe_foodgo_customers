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
}
