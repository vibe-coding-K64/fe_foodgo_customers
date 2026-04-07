/// Model danh muc mon an trong trang chi tiet quan an.
class RestaurantCategoryModel {
  final String id;
  final String name;
  final int order;

  RestaurantCategoryModel({
    required this.id,
    required this.name,
    required this.order,
  });

  factory RestaurantCategoryModel.fromJson(Map<String, dynamic> json) {
    return RestaurantCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
    };
  }
}
