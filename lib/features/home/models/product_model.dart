import 'package:cloud_firestore/cloud_firestore.dart';

/// Model mot option trong optionGroup (VD: size M, topping trân châu).
class OptionModel {
  final String name;
  final double price;

  OptionModel({required this.name, required this.price});

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

/// Model mot nhom tuy chon (VD: Kích thước, Topping).
class OptionGroupModel {
  final String name;
  final bool isRequired;
  final bool isSingleSelect;
  final List<OptionModel> options;

  OptionGroupModel({
    required this.name,
    required this.isRequired,
    required this.isSingleSelect,
    required this.options,
  });

  factory OptionGroupModel.fromJson(Map<String, dynamic> json) {
    final optionsList = (json['options'] as List<dynamic>?)
            ?.map((o) => OptionModel.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [];

    return OptionGroupModel(
      name: json['name'] as String? ?? '',
      isRequired: json['isRequired'] as bool? ?? json['required'] as bool? ?? false,
      isSingleSelect: json['isSingleSelect'] as bool? ??
          json['singleSelect'] as bool? ??
          _inferIsSingleSelect(json['name'] as String?),
      options: optionsList,
    );
  }

  /// Infer isSingleSelect tu ten group khi API khong tra ve field nay.
  /// Topping -> multi-select (false), Kich thuoc -> single-select (true).
  static bool _inferIsSingleSelect(String? name) {
    if (name == null) return true;
    final lower = name.toLowerCase();
    if (lower.contains('topping')) return false;
    if (lower.contains('size') ||
        lower.contains('kich thuoc') ||
        lower.contains('kích thước')) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'isRequired': isRequired,
        'isSingleSelect': isSingleSelect,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

/// Thong tin cua hang ngan gon, nested trong FeaturedProductResponse.
class StoreSummary {
  final String id;
  final String name;
  final double rating;
  final String avtUrl;
  final double deliveryFee;
  final String deliveryTime;

  StoreSummary({
    required this.id,
    required this.name,
    required this.rating,
    required this.avtUrl,
    required this.deliveryFee,
    required this.deliveryTime,
  });

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    final avtUrl = (json['avtUrl'] as String?) ??
        (json['logoUrl'] as String?) ??
        (json['avatarUrl'] as String?) ??
        (json['imageUrl'] as String?) ??
        '';
    return StoreSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      avtUrl: avtUrl,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      deliveryTime: json['deliveryTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rating': rating,
        'avtUrl': avtUrl,
        'deliveryFee': deliveryFee,
        'deliveryTime': deliveryTime,
      };
}

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
  final List<OptionGroupModel> optionGroups;

  // Thong tin cua hang de hien thi tren card san pham.
  final double? lat;
  final double? lng;
  final double? distance;
  final double? rating;
  final int? reviewCount;
  final String? deliveryTime;

  /// Nested store info tu API /products/featured.
  final StoreSummary? store;

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
    this.optionGroups = const [],
    this.lat,
    this.lng,
    this.distance,
    this.rating,
    this.reviewCount,
    this.deliveryTime,
    this.store,
  });

  /// Parse tu JSON cua my-json-server (db.json).
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    StoreSummary? storeSummary;
    if (json['store'] != null) {
      storeSummary =
          StoreSummary.fromJson(json['store'] as Map<String, dynamic>);
    }

    // Parse optionGroups tu API (flat structure: optionGroups[].options[])
    final groups = (json['optionGroups'] as List<dynamic>?)
            ?.map((g) =>
                OptionGroupModel.fromJson(g as Map<String, dynamic>))
            .toList() ??
        [];

    return ProductModel(
      id: json['id']?.toString() ?? '',
      storeId: json['storeId']?.toString() ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      imageUrl:
          json['imageUrl'] as String? ??
          json['image_url'] as String? ??
          json['image'] as String? ??
          json['imgUrl'] as String? ??
          json['photoUrl'] as String? ??
          json['thumbnail'] as String? ??
          '',
      isOutOfStock: json['isOutOfStock'] as bool? ??
          json['is_out_of_stock'] as bool? ??
          false,
      isFeatured: json['isFeatured'] as bool? ??
          json['is_featured'] as bool? ??
          false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      optionGroups: groups,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      deliveryTime: json['deliveryTime'] as String?,
      store: storeSummary,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Du lieu Firestore cua ProductModel bi null');
    }

    final groups = (data['optionGroups'] as List<dynamic>?)
            ?.map((g) =>
                OptionGroupModel.fromJson(g as Map<String, dynamic>))
            .toList() ??
        [];

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
      optionGroups: groups,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      distance: (data['distance'] as num?)?.toDouble(),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewCount: data['reviewCount'] as int?,
      deliveryTime: data['deliveryTime'] as String?,
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
      'store': store?.toJson(),
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
    List<OptionGroupModel>? optionGroups,
    double? lat,
    double? lng,
    double? distance,
    double? rating,
    int? reviewCount,
    String? deliveryTime,
    StoreSummary? store,
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
      optionGroups: optionGroups ?? this.optionGroups,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      store: store ?? this.store,
    );
  }
}
