import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String storeId;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final double basePrice;
  final String imageUrl;
  final bool isOutOfStock;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Them thong tin cua hang de hien thi tren card san pham.
  final double? lat;
  final double? lng;
  final double? distance;
  final double? rating;
  final int? reviewCount;
  final String? deliveryTime;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.imageUrl,
    required this.isOutOfStock,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    this.lat,
    this.lng,
    this.distance,
    this.rating,
    this.reviewCount,
    this.deliveryTime,
  });

  /// Parse tu JSON cua my-json-server (db.json).
  /// Cac truong thieu se duoc gan gia tri mac dinh.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      storeId: json['storeId']?.toString() ?? '',
      categoryId: '',
      categoryName: '',
      name: json['name'] as String? ?? '',
      description: '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      isOutOfStock: json['isOutOfStock'] as bool? ??
          json['is_out_of_stock'] as bool? ??
          false,
      isFeatured: json['isFeatured'] as bool? ??
          json['is_featured'] as bool? ??
          false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // Thong tin cua hang (tu API featured_products).
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      deliveryTime: json['deliveryTime'] as String?,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Du lieu Firestore cua ProductModel bi null');
    }
    return ProductModel(
      id: doc.id,
      storeId: data['storeId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String? ?? '',
      isOutOfStock: data['isOutOfStock'] as bool? ?? false,
      isFeatured: data['isFeatured'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'isOutOfStock': isOutOfStock,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? categoryId,
    String? categoryName,
    String? name,
    String? description,
    double? basePrice,
    String? imageUrl,
    bool? isOutOfStock,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? lat,
    double? lng,
    double? distance,
    double? rating,
    int? reviewCount,
    String? deliveryTime,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }
}
