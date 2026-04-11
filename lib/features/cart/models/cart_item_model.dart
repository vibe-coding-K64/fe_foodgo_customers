import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String storeId;
  final String foodId;
  final String name;
  final double price;
  int quantity;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItemModel({
    required this.id,
    required this.storeId,
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse tu DocumentSnapshot cua Firestore.
  ///
  /// Xu ly Timestamp cua Firebase -> DateTime cua Dart.
  /// Duong dan collection: customer_profiles/{userId}/cart
  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: data['id'] as String? ?? doc.id,
      storeId: data['storeId'] as String? ?? '',
      foodId: data['foodId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: data['imageUrl'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  /// Chuyen doi Timestamp Firestore sang DateTime.
  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Chuyen doi thanh Map de ghi xuong Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'storeId': storeId,
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CartItemModel copyWith({
    String? id,
    String? storeId,
    String? foodId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Tong gia cua item (don gia * so luong).
  double get totalPrice => price * quantity;
}
