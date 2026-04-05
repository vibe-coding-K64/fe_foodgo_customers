import 'package:flutter/material.dart';

/// Cac mau chu dao cua ung dung FoodGo.
///
/// Toan bo mau deu duoc dinh nghia tai day de dam bao tinh nhat quan
/// cho toan bo ung dung. Khong duoc hardcode mau truc tiep trong widget.
class AppColors {
  AppColors._();

  // ========== MAU CHINH ==========
  // Mau xanh la cay chu dao, dai dien cho thuong hieu FoodGo.
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);

  // ========== MAU PHU ==========
  static const Color secondary = Color(0xFF2EC4B6);
  static const Color secondaryLight = Color(0xFF5DD9CD);
  static const Color secondaryDark = Color(0xFF23A897);

  // ========== GRADIENT ==========
  // Gradient xanh la cho cac header/banner dac thu.
  static const Color greenGradientStart = Color(0xFF81C784);
  static const Color greenGradientEnd = Color(0xFF2E7D32);

  // ========== MAU NEN ==========
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F0);

  // ========== MAU VAN BAN ==========
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // ========== MAU TRANG THAI ==========
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // ========== MAU DUONG KE VA VIEN ==========
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocused = Color(0xFF4CAF50);

  // ========== MAU OVERLAY ==========
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0xFFE0E0E0);

  // ========== MAU THONG BAO CHUA DOC ==========
  // Nen xanh nhat danh dau thong bao chua doc.
  static const Color unreadBackground = Color(0xFFF1F8F1);
}
