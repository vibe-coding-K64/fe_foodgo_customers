import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../home/models/product_model.dart';

/// Model topping trong gio hang.
///
/// Gia cua topping hien thi duoc tinh dong tu optionGroups cua Product.
/// Field [price] chi dung de gui len API, khong dung de tinh gia hien thi.
class CartTopping {
  final String name;
  final double price;

  CartTopping({required this.name, this.price = 0.0});

  factory CartTopping.fromJson(Map<String, dynamic> json) {
    return CartTopping(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

/// Model item trong gio hang.
///
/// Duong dan collection: customer_profiles/{userId}/cart
///
/// Cart KHONG luu gia tri price/sizePrice/toppings[].price.
/// Gia cua item duoc tinh dong tu ProductModel (lay tu collection products/{foodId}).
class CartItemModel {
  final String id;
  final String storeId;
  final String foodId;
  final String name;
  int quantity;
  final String? selectedSize;
  final List<CartTopping> selectedToppings;
  final String? note;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ProductModel tu collection products/{foodId}. Set khi enrich tu CartState.
  /// Su dung de tinh unitPrice() va totalPrice().
  final ProductModel? product;

  CartItemModel({
    required this.id,
    required this.storeId,
    required this.foodId,
    required this.name,
    required this.quantity,
    this.selectedSize,
    this.selectedToppings = const [],
    this.note,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final toppingsList = (data['toppings'] as List<dynamic>?)
            ?.map((t) => CartTopping.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    return CartItemModel(
      id: (data['id'] as String?)?.isNotEmpty == true
          ? data['id'] as String
          : doc.id,
      storeId: data['storeId'] as String? ?? '',
      foodId: data['foodId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      selectedSize: data['size'] as String?,
      selectedToppings: toppingsList,
      note: data['note'] as String?,
      imageUrl: data['imageUrl'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
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
      if (id.isNotEmpty) 'id': id,
      'storeId': storeId,
      'foodId': foodId,
      'name': name,
      'quantity': quantity,
      if (selectedSize != null) 'selectedSize': selectedSize,
      if (selectedToppings.isNotEmpty)
        'selectedToppings':
            selectedToppings.map((t) => t.toJson()).toList(),
      if (note != null && note!.isNotEmpty) 'note': note,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CartItemModel.fromProduct({
    required String storeId,
    required String productId,
    required String productName,
    required int quantity,
    String? size,
    List<CartTopping>? toppings,
    String? note,
    String? imageUrl,
    ProductModel? product,
  }) {
    final now = DateTime.now();
    return CartItemModel(
      id: '',
      storeId: storeId,
      foodId: productId,
      name: productName,
      quantity: quantity,
      selectedSize: size,
      selectedToppings: toppings ?? [],
      note: note,
      imageUrl: imageUrl,
      createdAt: now,
      updatedAt: now,
      product: product,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? storeId,
    String? foodId,
    String? name,
    int? quantity,
    String? selectedSize,
    List<CartTopping>? selectedToppings,
    String? note,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductModel? product,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedToppings: selectedToppings ?? this.selectedToppings,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }

  bool _isSizeGroup(String groupName) {
    final lower = groupName.toLowerCase();
    return lower.contains('size') ||
        lower.contains('kich thuoc') ||
        lower.contains('kích thước');
  }

  bool _isToppingGroup(String groupName) {
    return groupName.toLowerCase().contains('topping');
  }

  /// Tinh don gia cua 1 don vi = basePrice + sizePrice + toppingsTotal.
  double unitPriceOf(ProductModel? product) {
    if (product == null) return 0.0;

    double total = product.basePrice;

    if (selectedSize != null) {
      for (final group in product.optionGroups) {
        if (_isSizeGroup(group.name)) {
          for (final opt in group.options) {
            if (opt.name == selectedSize) {
              total += opt.price;
              break;
            }
          }
          break;
        }
      }
    }

    for (final topping in selectedToppings) {
      for (final group in product.optionGroups) {
        if (_isToppingGroup(group.name)) {
          for (final opt in group.options) {
            if (opt.name == topping.name) {
              total += opt.price;
              break;
            }
          }
        }
      }
    }

    return total;
  }

  /// Don gia cua 1 don vi.
  double get unitPrice => unitPriceOf(product);

  /// Tong gia = don gia * so luong.
  double get totalPrice => unitPrice * quantity;

  /// Tinh tong gia voi product cho truoc.
  double totalPriceOf(ProductModel? product) => unitPriceOf(product) * quantity;

  /// Tra ve imageUrl, neu null hoac rong thi tra ve placeholder.
  String get imageUrlOrDefault {
    final url = (imageUrl != null && imageUrl!.isNotEmpty)
        ? imageUrl!
        : 'https://picsum.photos/seed/${foodId.hashCode.abs()}/200';
    return url;
  }

  /// Label hien thi topping (noi tiep bang dau phay).
  String get toppingsLabel {
    if (selectedToppings.isEmpty) return '';
    return selectedToppings.map((t) => t.name).join(', ');
  }
}
