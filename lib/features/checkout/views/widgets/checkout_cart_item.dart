import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Model item trong gio hang o buoc checkout.
/// Co them truong toppings de hien thi lua chon them.
class CheckoutCartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final List<CheckoutTopping> toppings;

  CheckoutCartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.toppings = const [],
  });

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
