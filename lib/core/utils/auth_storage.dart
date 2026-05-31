import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lop luu tru thong tin xac thuc cua nguoi dung.
///
/// Su dung SharedPreferences de luu tru JWT token va thong tin nguoi dung,
/// giup kiem tra trang thai dang nhap khi app khoi dong.
class AuthStorage {
  AuthStorage._();

  static SharedPreferences? _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _tokenTypeKey = 'auth_token_type';
  static const String _expiresInKey = 'auth_expires_in';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _refreshExpiresInKey = 'auth_refresh_expires_in';

  /// Khoi tao SharedPreferences (goi 1 lan).
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('AuthStorage: Khoi tao thanh cong');
  }

  /// Lay JWT token da luu. Tra ve null neu chua dang nhap.
  static String? getToken() {
    final value = _prefs?.getString(_tokenKey);
    debugPrint('AuthStorage: Lay token = ${value != null ? "[ Present ]" : "null"}');
    return value;
  }

  /// Lay token type (thuong la "Bearer").
  static String? getTokenType() {
    return _prefs?.getString(_tokenTypeKey);
  }

  /// Lay expiresIn (milliseconds).
  static int? getExpiresIn() {
    return _prefs?.getInt(_expiresInKey);
  }

  /// Lay refreshToken.
  static String? getRefreshToken() {
    return _prefs?.getString(_refreshTokenKey);
  }

  /// Lay refreshExpiresIn (milliseconds).
  static int? getRefreshExpiresIn() {
    return _prefs?.getInt(_refreshExpiresInKey);
  }

  /// Lay thong tin nguoi dung da luu.
  static Map<String, dynamic>? getUser() {
    final value = _prefs?.getString(_userKey);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AuthStorage: Loi parse user JSON: $e');
      return null;
    }
  }

  /// Lay userId tu thong tin nguoi dung da luu.
  static String? getUserId() {
    final user = getUser();
    return user?['id'] as String?;
  }

  /// Luu thong tin sau khi dang nhap thanh cong.
  static Future<void> saveAuthData({
    required String token,
    required String tokenType,
    required Map<String, dynamic> user,
    required int expiresIn,
    required String refreshToken,
    required int refreshExpiresIn,
  }) async {
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setString(_tokenTypeKey, tokenType);
    await _prefs?.setString(_userKey, jsonEncode(user));
    await _prefs?.setInt(_expiresInKey, expiresIn);
    await _prefs?.setString(_refreshTokenKey, refreshToken);
    await _prefs?.setInt(_refreshExpiresInKey, refreshExpiresIn);
    debugPrint('AuthStorage: Luu auth data thanh cong. userId = ${user['id']}');
  }

  /// Xoa toan bo thong tin xac thuc khi dang xuat.
  static Future<void> clearAuth() async {
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_tokenTypeKey);
    await _prefs?.remove(_userKey);
    await _prefs?.remove(_expiresInKey);
    await _prefs?.remove(_refreshTokenKey);
    await _prefs?.remove(_refreshExpiresInKey);
    debugPrint('AuthStorage: Xoa auth data thanh cong');
  }

  /// Kiem tra nguoi dung da dang nhap chua.
  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // --- Location Storage ---

  static const String _userLatKey = 'user_latitude';
  static const String _userLngKey = 'user_longitude';

  /// Lay vi do nguoi dung da luu. Tra ve null neu chua luu.
  static double? getUserLatitude() {
    return _prefs?.getDouble(_userLatKey);
  }

  /// Lay kinh do nguoi dung da luu. Tra ve null neu chua luu.
  static double? getUserLongitude() {
    return _prefs?.getDouble(_userLngKey);
  }

  /// Luu vi tri nguoi dung (thuong lay tu GPS hoac chon tren ban do).
  static Future<void> saveUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _prefs?.setDouble(_userLatKey, latitude);
    await _prefs?.setDouble(_userLngKey, longitude);
    debugPrint('AuthStorage: Luu vi tri - lat=$latitude, lng=$longitude');
  }

  /// Xoa vi tri da luu.
  static Future<void> clearUserLocation() async {
    await _prefs?.remove(_userLatKey);
    await _prefs?.remove(_userLngKey);
    debugPrint('AuthStorage: Xoa vi tri da luu');
  }
}
