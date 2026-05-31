/// Mot option da chon trong gio hang checkout.
class CheckoutOption {
  final String name;
  final double price;
  final String groupName;

  const CheckoutOption({
    required this.name,
    required this.price,
    this.groupName = '',
  });
}

/// Model item trong gio hang o buoc checkout.
class CheckoutCartItem {
  final String id;
  final String foodId;
  final String storeId;
  final String name;
  final String imageUrl;
  /// Gia goc cua mon (chua tinh options).
  final double basePrice;
  /// Tong gia cua 1 don vi = basePrice + options per item.
  final double unitPrice;
  final int quantity;
  /// Cac options da chon (kem gia).
  final List<CheckoutOption> selectedOptions;
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
    this.selectedOptions = const [],
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
    List<CheckoutOption>? selectedOptions,
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
      selectedOptions: selectedOptions ?? this.selectedOptions,
      note: note ?? this.note,
    );
  }

  double get totalPrice => unitPrice * quantity;

  /// Tra ve danh sach cac option lines de hien thi.
  /// Cac option cung nhom duoc gop vao 1 dong: "Topping: Tran chau, Pudding".
  List<String> get optionLines {
    // Voi CheckoutOption da phang (khong co group name), moi option la 1 dong.
    // Neu muon gop theo nhom thi can truyen them group info.
    return selectedOptions.map((o) => o.name).toList();
  }

  /// Tra ve danh sach cac dong option, nhom cac option cung loai lai.
  /// VD: "Topping: Tran chau, Pudding", "Kich thuoc: Lon".
  List<String> get groupedOptionLines {
    final lines = <String>[];
    final grouped = <String, List<String>>{};
    for (final opt in selectedOptions) {
      grouped.putIfAbsent(opt.groupName, () => []).add(opt.name);
    }
    for (final entry in grouped.entries) {
      lines.add('${entry.key}: ${entry.value.join(', ')}');
    }
    return lines;
  }
}
