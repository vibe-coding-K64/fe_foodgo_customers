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

/// Model item trong gio hang, dong bo tu API.
class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double unitPrice;
  int quantity;
  bool isSelected;
  final List<CartTopping> toppings;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.isSelected = true,
    this.toppings = const [],
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    List<CartTopping> toppingsList = [];
    final rawToppings = json['toppings'];
    if (rawToppings is List) {
      toppingsList = rawToppings
          .whereType<Map<String, dynamic>>()
          .map((t) => CartTopping.fromJson(t))
          .toList();
    }

    return CartItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isSelected: json['isSelected'] as bool? ?? true,
      toppings: toppingsList,
    );
  }

  /// Tinh tong gia mot mon (da nhan so luong, bao gom topping).
  double get totalPrice {
    final toppingTotal = toppings.fold<double>(
      0,
      (sum, t) => sum + (t.price * quantity),
    );
    return unitPrice * quantity + toppingTotal;
  }

  /// Tao chuoi topping hien thi (noi tiep bang dau phay).
  String get toppingsLabel {
    if (toppings.isEmpty) return '';
    return toppings.map((t) => t.name).join(', ');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'isSelected': isSelected,
    'toppings': toppings.map((t) => t.toJson()).toList(),
  };

  CartItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
    bool? isSelected,
    List<CartTopping>? toppings,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      toppings: toppings ?? this.toppings,
    );
  }
}

/// Model gio hang, dong bo tu API /cart.
class CartModel {
  final String storeId;
  final String storeName;
  final String storeImageUrl;
  final List<CartItem> items;

  CartModel({
    required this.storeId,
    required this.storeName,
    required this.storeImageUrl,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItem> itemsList = [];
    final rawItems = json['items'];
    if (rawItems is List) {
      itemsList = rawItems
          .whereType<Map<String, dynamic>>()
          .map((item) => CartItem.fromJson(item))
          .toList();
    }

    return CartModel(
      storeId: json['storeId'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      storeImageUrl: json['storeImageUrl'] as String? ?? '',
      items: itemsList,
    );
  }

  /// Gio hang rong hay khong.
  bool get isEmpty => items.isEmpty;

  /// Tong so item trong gio.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Tinh tam tinh chi tong tien cac mon dang duoc tick.
  double get subtotal {
    return items
        .where((item) => item.isSelected)
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  /// Dem so mon dang duoc tick.
  int get selectedCount => items.where((item) => item.isSelected).length;

  /// Kiem tra tat ca duoc tick chua.
  bool get isAllSelected =>
      items.isNotEmpty && items.every((item) => item.isSelected);

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'storeName': storeName,
    'storeImageUrl': storeImageUrl,
    'items': items.map((item) => item.toJson()).toList(),
  };
}
