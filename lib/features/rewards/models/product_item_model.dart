/// Model san pham co the ap dung voucher.
///
/// Dung cho trang VoucherApplicableProductsView.
class ProductItemModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String storeName;

  const ProductItemModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.storeName,
  });
}
