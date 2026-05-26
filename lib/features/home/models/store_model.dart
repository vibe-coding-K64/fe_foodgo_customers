import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final String avtUrl;
  final String backUrl;
  final bool isOpen;
  final String deliveryTime;
  final double deliveryFee;
  final double distance;
  final List<String> categoryIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
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
  });

  /// Parse tu JSON cua my-json-server (db.json).
  /// Cac truong thieu se duoc gan gia tri mac dinh.
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      avtUrl: json['avtUrl'] as String? ?? '',
      backUrl: json['backUrl'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? true,
      deliveryTime: json['deliveryTime'] as String? ?? '15-25 phut',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      categoryIds: (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Du lieu Firestore cua StoreModel bi null');
    }
    return StoreModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      avtUrl: data['avtUrl'] as String? ?? data['avt_url'] as String? ?? '',
      backUrl: data['backUrl'] as String? ?? data['back_url'] as String? ?? '',
      isOpen: data['isOpen'] as bool? ?? false,
      deliveryTime: data['deliveryTime'] as String? ?? '',
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      distance: (data['distance'] as num?)?.toDouble() ?? 0.0,
      categoryIds: (data['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
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
    };
  }

  StoreModel copyWith({
    String? id,
    String? name,
    String? address,
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
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
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
    );
  }
}
