import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/models/product_model.dart';

/// Một option đã được chọn (chỉ lưu name, không lưu price).
class SelectedOption {
  final String name;
  SelectedOption({required this.name});

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(name: json['name'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'name': name};
}

/// Một nhóm options đã chọn (VD: "Kich thuoc", "Topping").
class SelectedOptionGroup {
  final String name;
  final List<SelectedOption> options;

  SelectedOptionGroup({required this.name, required this.options});

  factory SelectedOptionGroup.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>?)
            ?.map((o) => SelectedOption.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [];
    return SelectedOptionGroup(
      name: json['name'] as String? ?? '',
      options: opts,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

/// Model item trong gio hang.
///
/// Duong dan collection: customer_profiles/{userId}/cart
///
/// Cart KHONG luu gia tri price.
/// Gia cua item duoc tinh dong tu ProductModel (lay tu collection products/{foodId}).
class CartItemModel {
  final String id;
  final String storeId;
  final String foodId;
  int quantity;
  final List<SelectedOptionGroup> selectedOptions;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ProductModel tu collection products/{foodId}. Set khi enrich tu CartState.
  /// Su dung de tinh unitPrice() va totalPrice().
  final ProductModel? product;

  CartItemModel({
    required this.id,
    required this.storeId,
    required this.foodId,
    required this.quantity,
    this.selectedOptions = const [],
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final groups = (data['selectedOptions'] as List<dynamic>?)
            ?.map((g) => SelectedOptionGroup.fromJson(g as Map<String, dynamic>))
            .toList() ??
        [];

    return CartItemModel(
      id: (data['id'] as String?)?.isNotEmpty == true
          ? data['id'] as String
          : doc.id,
      storeId: data['storeId'] as String? ?? '',
      foodId: data['foodId'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      selectedOptions: groups,
      note: data['note'] as String?,
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
      'quantity': quantity,
      if (selectedOptions.isNotEmpty)
        'selectedOptions':
            selectedOptions.map((g) => g.toJson()).toList(),
      if (note != null && note!.isNotEmpty) 'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CartItemModel.fromProduct({
    required String storeId,
    required String productId,
    required int quantity,
    List<SelectedOptionGroup>? selectedOptions,
    String? note,
    ProductModel? product,
  }) {
    final now = DateTime.now();
    return CartItemModel(
      id: '',
      storeId: storeId,
      foodId: productId,
      quantity: quantity,
      selectedOptions: selectedOptions ?? [],
      note: note,
      createdAt: now,
      updatedAt: now,
      product: product,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? storeId,
    String? foodId,
    int? quantity,
    List<SelectedOptionGroup>? selectedOptions,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductModel? product,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      foodId: foodId ?? this.foodId,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }

  /// Tinh don gia cua 1 don vi = basePrice + sizePrice + toppingsTotal.
  double unitPriceOf(ProductModel? product) {
    if (product == null) return 0.0;

    double total = product.basePrice;

    for (final group in selectedOptions) {
      for (final opt in group.options) {
        // Tim price cua option nay trong product optionGroups.
        final productGroup = product.optionGroups
            .where((g) => g.name == group.name)
            .firstOrNull;
        if (productGroup == null) continue;

        final productOption = productGroup.options
            .where((o) => o.name == opt.name)
            .firstOrNull;
        if (productOption != null) {
          total += productOption.price;
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

  /// Tra ve imageUrl tu product, neu null thi tra ve placeholder.
  String get imageUrlOrDefault {
    final url = product?.imageUrl;
    if (url != null && url.isNotEmpty) return url;
    return 'https://picsum.photos/seed/${foodId.hashCode.abs()}/200';
  }

  /// Label hien thi tat ca options da chon (noi tiep bang dau phay).
  String get selectedOptionsLabel {
    if (selectedOptions.isEmpty) return '';
    return selectedOptions
        .expand((g) => g.options.map((o) => o.name))
        .join(', ');
  }
}
