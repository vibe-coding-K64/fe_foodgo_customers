/// Model topping trong gio hang (chi dung o tier view).
class CartTopping {
  final String name;
  final double price;

  CartTopping({required this.name, required this.price});
}

/// Model item trong gio hang, day du hon CartItemModel (data layer).
/// Co them truong toppings va isSelected phuc vu giao dien.
class CartItemViewModel {
  final String id;
  final String name;
  final String imageUrl;
  final double unitPrice;
  int quantity;
  bool isSelected;
  final List<CartTopping> toppings;

  CartItemViewModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.isSelected = true,
    this.toppings = const [],
  });

  /// Tinh tong gia mot mon (da nhan so luong, bao gom topping).
  double get totalPrice {
    final toppingTotal =
        toppings.fold<double>(0, (sum, t) => sum + (t.price * quantity));
    return unitPrice * quantity + toppingTotal;
  }

  /// Tao chuoi topping hien thi (noi tiep bang dau phay).
  String get toppingsLabel {
    if (toppings.isEmpty) return '';
    return toppings.map((t) => t.name).join(', ');
  }

  /// Tu copy voi truong moi.
  CartItemViewModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
    bool? isSelected,
    List<CartTopping>? toppings,
  }) {
    return CartItemViewModel(
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
