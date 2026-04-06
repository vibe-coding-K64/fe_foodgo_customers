/// Model item trong gio hang o buoc checkout.
/// Co them truong toppings de hien thi lua chon them.
class CheckoutCartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final List<CheckoutTopping> toppings;
  final String note;

  CheckoutCartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.toppings = const [],
    this.note = '',
  });

  CheckoutCartItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
    List<CheckoutTopping>? toppings,
    String? note,
  }) {
    return CheckoutCartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      toppings: toppings ?? this.toppings,
      note: note ?? this.note,
    );
  }

  double get totalPrice {
    final toppingTotal =
        toppings.fold<double>(0, (sum, t) => sum + (t.price * quantity));
    return unitPrice * quantity + toppingTotal;
  }

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
