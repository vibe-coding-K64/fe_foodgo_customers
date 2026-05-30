/// Model item trong gio hang o buoc checkout.
/// Co them truong toppings de hien thi lua chon them.
class CheckoutCartItem {
  final String id;
  final String foodId;
  final String storeId;
  final String name;
  final String imageUrl;
  /// Gia goc cua mon (chua tinh topping).
  final double basePrice;
  /// Tong gia cua 1 don vi = basePrice + topping per item.
  final double unitPrice;
  final int quantity;
  final List<CheckoutTopping> toppings;
  final String note;

  CheckoutCartItem({
    required this.id,
    this.foodId = '',
    this.storeId = '',
    required this.name,
    required this.imageUrl,
    required this.basePrice,
    required this.unitPrice,
    required this.quantity,
    this.toppings = const [],
    this.note = '',
  });

  CheckoutCartItem copyWith({
    String? id,
    String? foodId,
    String? storeId,
    String? name,
    String? imageUrl,
    double? basePrice,
    double? unitPrice,
    int? quantity,
    List<CheckoutTopping>? toppings,
    String? note,
  }) {
    return CheckoutCartItem(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      toppings: toppings ?? this.toppings,
      note: note ?? this.note,
    );
  }

  double get toppingsTotal =>
      toppings.fold<double>(0, (sum, t) => sum + (t.price * quantity));

  double get totalPrice => unitPrice * quantity;

  String get toppingsLabel {
    if (toppings.isEmpty) return '';
    return toppings.map((t) => t.name).join(', ');
  }
}

class CheckoutTopping {
  final String name;
  final double price;

  CheckoutTopping({required this.name, required this.price});
}
