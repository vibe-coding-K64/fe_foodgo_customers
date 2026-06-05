import 'package:cloud_firestore/cloud_firestore.dart';

/// Model danh muc mon an trong trang chi tiet quan an.
class RestaurantCategoryModel {
  final String id;
  final String name;
  final int order;
  final String? storeId;

  RestaurantCategoryModel({
    required this.id,
    required this.name,
    required this.order,
    this.storeId,
  });

  factory RestaurantCategoryModel.fromJson(Map<String, dynamic> json) {
    return RestaurantCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      storeId: json['storeId'] as String?,
    );
  }

  factory RestaurantCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return RestaurantCategoryModel(
      id: doc.id,
      name: data?['name'] as String? ?? '',
      order: data?['order'] as int? ?? 0,
      storeId: data?['storeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'storeId': storeId,
    };
  }
}
