import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model topping trong gio hang.
class CartTopping {
  final String name;
  final double price;

  CartTopping({required this.name, required this.price});

  factory CartTopping.fromJson(Map<String, dynamic> json) {
    return CartTopping(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

/// Model item trong gio hang, dong bo tu Firestore.
///
/// Duong dan collection: customer_profiles/{userId}/cart
///
/// Cau truc Firestore:
/// {
///   "id": "cart_item_001",
///   "storeId": "store_001",
///   "foodId": "prod_001",
///   "name": "Com tam suon bi cha",
///   "price": 45000.0,          // don gia (chua nhan so luong, da bao gom size/topping)
///   "quantity": 2,
///   "size": "M",               // kich thuoc (null neu khong co)
///   "sizePrice": 0.0,          // gia them cua size
///   "toppings": [              // danh sach topping da chon
///     {"name": "Tran chau trang", "price": 10000.0},
///     {"name": "Thach trai cay", "price": 8000.0}
///   ],
///   "note": "It cay",          // ghi chu (null neu khong co)
///   "imageUrl": "https://...",
///   "createdAt": <Firestore Timestamp>,
///   "updatedAt": <Firestore Timestamp>
/// }
class CartItemModel {
  final String id;
  final String storeId;
  final String foodId;
  final String name;
  final double price;         // don gia cua 1 don vi (da bao gom basePrice + size + toppings)
  int quantity;
  final String? size;
  final double? sizePrice;
  final List<CartTopping> toppings;
  final String? note;
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
    this.size,
    this.sizePrice,
    this.toppings = const [],
    this.note,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final toppingsList = (data['toppings'] as List<dynamic>?)
            ?.map((t) => CartTopping.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    return CartItemModel(
      id: data['id'] as String? ?? doc.id,
      storeId: data['storeId'] as String? ?? '',
      foodId: data['foodId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      size: data['size'] as String?,
      sizePrice: (data['sizePrice'] as num?)?.toDouble(),
      toppings: toppingsList,
      note: data['note'] as String?,
      imageUrl: data['imageUrl'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  /// Parse tu API response (POST /api/cart/add response.data).
  ///
  /// API tra ve: { "success": true, "code": 200, "data": { ... } }
  /// trong do data chua day du cac truong cua item.
  factory CartItemModel.fromApiJson(Map<String, dynamic> json) {
    final toppingsList = (json['toppings'] as List<dynamic>?)
            ?.map((t) => CartTopping.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    return CartItemModel(
      id: json['id'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      foodId: json['foodId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      size: json['size'] as String?,
      sizePrice: (json['sizePrice'] as num?)?.toDouble(),
      toppings: toppingsList,
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'storeId': storeId,
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      if (size != null) 'size': size,
      if (sizePrice != null) 'sizePrice': sizePrice,
      'toppings': toppings.map((t) => t.toJson()).toList(),
      if (note != null && note!.isNotEmpty) 'note': note,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Tao nhanh CartItemModel tu ProductModel khi nguoi dung chon topping.
  factory CartItemModel.fromProduct({
    required String storeId,
    required String productId,
    required String productName,
    required double unitPrice,
    required int quantity,
    String? size,
    double? sizePrice,
    List<CartTopping>? toppings,
    String? note,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    return CartItemModel(
      id: '',
      storeId: storeId,
      foodId: productId,
      name: productName,
      price: unitPrice,
      quantity: quantity,
      size: size,
      sizePrice: sizePrice,
      toppings: toppings ?? [],
      note: note,
      imageUrl: imageUrl,
      createdAt: now,
      updatedAt: now,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? storeId,
    String? foodId,
    String? name,
    double? price,
    int? quantity,
    String? size,
    double? sizePrice,
    List<CartTopping>? toppings,
    String? note,
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
      size: size ?? this.size,
      sizePrice: sizePrice ?? this.sizePrice,
      toppings: toppings ?? this.toppings,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Tong gia cua item = don gia * so luong.
  double get totalPrice => price * quantity;

  /// Tra ve imageUrl, neu null hoac rong thi tra ve placeholder.
  String get imageUrlOrDefault {
    final url = (imageUrl != null && imageUrl!.isNotEmpty)
        ? imageUrl!
        : 'https://picsum.photos/seed/${foodId.hashCode.abs()}/200';
    debugPrint('CartItem [$name] imageUrlOrDefault = $url (original = $imageUrl)');
    return url;
  }

  /// Tong gia toppings = sum of each topping price * quantity.
  double get toppingsTotal =>
      toppings.fold<double>(0, (sum, t) => sum + t.price);

  /// Label hien thi topping (noi tiep bang dau phay).
  String get toppingsLabel {
    if (toppings.isEmpty) return '';
    return toppings.map((t) => t.name).join(', ');
  }

  /// Chuyen thanh map JSON de luu local.
  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'storeId': storeId,
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      if (size != null) 'size': size,
      if (sizePrice != null) 'sizePrice': sizePrice,
      'toppings': toppings.map((t) => t.toJson()).toList(),
      if (note != null && note!.isNotEmpty) 'note': note,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Tao CartItemModel tu JSON local (da luu bang SharedPreferences).
  factory CartItemModel.fromLocalJson(Map<String, dynamic> json) {
    final toppingsList = (json['toppings'] as List<dynamic>?)
            ?.map((t) => CartTopping.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    return CartItemModel(
      id: json['id'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      foodId: json['foodId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      size: json['size'] as String?,
      sizePrice: (json['sizePrice'] as num?)?.toDouble(),
      toppings: toppingsList,
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
