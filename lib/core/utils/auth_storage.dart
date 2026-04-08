import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lop luu tru thong tin xac thuc cua nguoi dung.
///
/// Su dung SharedPreferences de luu tru userId cua nguoi dang nhap,
/// giup kiem tra trang thai dang nhap khi app khoi dong.
class AuthStorage {
  AuthStorage._();

  static SharedPreferences? _prefs;

  /// Khoa luu tru userId trong SharedPreferences.
  static const String _userIdKey = 'auth_user_id';

  /// Khoi tao SharedPreferences (goi 1 lan).
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('AuthStorage: Khoi tao thanh cong');
  }

  /// Lay userId da luu. Tra ve null neu chua dang nhap.
  static String? getUserId() {
    final value = _prefs?.getString(_userIdKey);
    debugPrint('AuthStorage: Lay userId = ${value ?? "null"}');
    return value;
  }

  /// Luu userId sau khi dang nhap thanh cong.
  static Future<void> saveUserId(String userId) async {
    await _prefs?.setString(_userIdKey, userId);
    debugPrint('AuthStorage: Luu userId thanh cong = $userId');
  }

  /// Xoa userId khi dang xuat.
  static Future<void> clearUserId() async {
    await _prefs?.remove(_userIdKey);
    debugPrint('AuthStorage: Xoa userId thanh cong');
  }

  /// Kiem tra nguoi dung da dang nhap chua.
  static bool isLoggedIn() {
    final userId = getUserId();
    return userId != null && userId.isNotEmpty;
  }
}
