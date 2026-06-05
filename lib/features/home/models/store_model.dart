import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String name;
  final String address;
  final String description;
  final double rating;
  final int reviewCount;
  final String avtUrl;
  final String backUrl;
  final bool isOpen;
  final String deliveryTime;
  final double deliveryFee;
  final double? lat;
  final double? lng;
  final double distance;
  final List<String> categoryIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.avtUrl,
    required this.backUrl,
    required this.isOpen,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.distance,
    required this.categoryIds,
    required this.createdAt,
    required this.updatedAt,
    this.lat,
    this.lng,
  });

  /// Parse tu JSON cua my-json-server (db.json).
  /// Cac truong thieu se duoc gan gia tri mac dinh.
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final rawCategoryIds = json['categoryIds'];
    List<String> categoryIds = [];
    if (rawCategoryIds is List) {
      categoryIds = rawCategoryIds
          .whereType<String>()
          .toList();
    } else if (rawCategoryIds is String && rawCategoryIds.isNotEmpty) {
      categoryIds = rawCategoryIds
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return StoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      avtUrl: _parseImageUrl(json, 'avtUrl', 'logoUrl', 'avatarUrl', 'avatar', 'imageUrl', 'image'),
      backUrl: _parseImageUrl(json, 'backUrl', 'coverImageUrl', 'coverImage', 'coverUrl', 'imageUrl', 'image'),
      isOpen: json['isOpen'] as bool? ?? json['isAcceptingOrders'] as bool? ?? true,
      deliveryTime: json['deliveryTime'] as String? ?? '15-25 phut',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      categoryIds: categoryIds,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lat: (json['lat'] as num?)?.toDouble() ?? (json['latitude'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble() ?? (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Parse image URL voi nhieu fallback key name.
  static String _parseImageUrl(
    Map<String, dynamic> json,
    String primary,
    String fallback1,
    String fallback2,
    String fallback3,
    String fallback4,
    String fallback5,
  ) {
    return (json[primary] as String?) ??
        (json[fallback1] as String?) ??
        (json[fallback2] as String?) ??
        (json[fallback3] as String?) ??
        (json[fallback4] as String?) ??
        (json[fallback5] as String?) ??
        '';
  }

  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Du lieu Firestore cua StoreModel bi null');
    }

    final rawCategoryIds = data['categoryIds'];
    List<String> categoryIds = [];
    if (rawCategoryIds is List) {
      categoryIds = rawCategoryIds
          .whereType<String>()
          .toList();
    } else if (rawCategoryIds is String && rawCategoryIds.isNotEmpty) {
      categoryIds = rawCategoryIds
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return StoreModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      description: data['description'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      avtUrl: data['avtUrl'] as String? ?? data['avt_url'] as String? ?? '',
      backUrl: data['backUrl'] as String? ?? data['back_url'] as String? ?? '',
      isOpen: data['isOpen'] as bool? ?? false,
      deliveryTime: data['deliveryTime'] as String? ?? '',
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      distance: (data['distance'] as num?)?.toDouble() ?? 0.0,
      categoryIds: categoryIds,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
      'avtUrl': avtUrl,
      'backUrl': backUrl,
      'isOpen': isOpen,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'distance': distance,
      'categoryIds': categoryIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }

  StoreModel copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    double? rating,
    int? reviewCount,
    String? avtUrl,
    String? backUrl,
    bool? isOpen,
    String? deliveryTime,
    double? deliveryFee,
    double? distance,
    List<String>? categoryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? lat,
    double? lng,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      avtUrl: avtUrl ?? this.avtUrl,
      backUrl: backUrl ?? this.backUrl,
      isOpen: isOpen ?? this.isOpen,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      distance: distance ?? this.distance,
      categoryIds: categoryIds ?? this.categoryIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
