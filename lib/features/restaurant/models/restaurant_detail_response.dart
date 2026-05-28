import '../../home/models/product_model.dart';
import '../../home/models/store_model.dart';
import 'restaurant_category_model.dart';

/// Response model tong hop cho trang chi tiet cua hang.
///
/// Gom du lieu tu 3 nguon: store, categories, products.
/// Tra ve tu 1 API duy nhat: GET /api/stores/{storeId}
class RestaurantDetailResponse {
  final StoreModel store;
  final List<RestaurantCategoryModel> categories;
  final List<ProductModel> products;

  RestaurantDetailResponse({
    required this.store,
    required this.categories,
    required this.products,
  });

  factory RestaurantDetailResponse.fromJson(Map<String, dynamic> json) {
    // Parse store — API tra store truc tiep o root, KHONG trong key "store"
    final StoreModel store;
    if (json.containsKey('store') && json['store'] is Map) {
      store = StoreModel.fromJson(json['store'] as Map<String, dynamic>);
    } else {
      // Store o root nhu API tra ve
      store = StoreModel.fromJson(json);
    }

    // Parse categories (bao gom "Tat ca" o dau)
    final List<RestaurantCategoryModel> categories;
    if (json['categories'] is List) {
      categories = (json['categories'] as List)
          .map((c) =>
              RestaurantCategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } else {
      categories = [];
    }

    // Parse products
    final List<ProductModel> products;
    if (json['products'] is List) {
      products = (json['products'] as List)
          .map((p) =>
              ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } else if (json['items'] is List) {
      products = (json['items'] as List)
          .map((p) =>
              ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } else if (json['data'] is List) {
      products = (json['data'] as List)
          .map((p) =>
              ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } else {
      products = [];
    }

    return RestaurantDetailResponse(
      store: store,
      categories: categories,
      products: products,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store': store.toJson(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}
