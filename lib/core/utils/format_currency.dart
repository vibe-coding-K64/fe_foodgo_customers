import 'package:flutter/material.dart';
import '../localization/language_service.dart';

/// Format mot so thuc thanh chuoi tien te VND.
/// VD: 45000 -> "45.000", 1234567 -> "1.234.567"
String formatCurrency(double price, BuildContext context) {
  final formatted = price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
  return '$formatted ${context.t('unit_currency')}';
}
