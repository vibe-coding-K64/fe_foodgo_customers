import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/auth_storage.dart';

/// Exception khi xac thuc that bai.
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

/// Response data cua API login/register.
class AuthUser {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? photoUrl;
  final List<int> roles;

  AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.photoUrl,
    required this.roles,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e is int ? e : (e is num ? e.toInt() : 0))
              .where((e) => e != 0)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
        'roles': roles,
      };

  bool get isCustomer => roles.contains(1);
}

/// Ket qua login thanh cong.
class LoginResult {
  final String token;
  final String tokenType;
  final AuthUser user;

  LoginResult({
    required this.token,
    required this.tokenType,
    required this.user,
  });
}

/// Ket qua verify OTP thanh cong.
class OtpVerifyResult {
  final String tempToken;
  final String tokenType;
  final int expiresIn;
  final DateTime? expiresAt;

  OtpVerifyResult({
    required this.tempToken,
    required this.tokenType,
    required this.expiresIn,
    this.expiresAt,
  });
}

/// Service xu ly cac thao tac xac thuc nguoi dung.
///
/// Su dung backend API (/api/auth/*) de xac thuc.
class AuthService {
  AuthService._();

  /// Dang nhap voi email va mat khau.
  ///
  /// Goi POST /api/auth/login.
  /// Tra ve LoginResult neu thanh cong.
  /// Nem AuthException neu that bai.
  static Future<LoginResult> login(String email, String password) async {
    debugPrint('AuthService: Dang nhap voi email = $email');

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;
      if (data == null) {
        throw AuthException('Khong nhan duoc phan hoi tu server');
      }

      // Xu ly phan hoi thanh cong (co token).
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw AuthException('Phan hoi khong chua token');
      }

      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        throw AuthException('Phan hoi khong chua thong tin nguoi dung');
      }

      final user = AuthUser.fromJson(userJson);

      // Chi cho phep khach hang (role 1) dang nhap vao app nay.
      if (!user.isCustomer) {
        throw AuthException('Tai khoan hoac mat khau khong chinh xac');
      }

      // Luu token va thong tin nguoi dung.
      final tokenType = data['tokenType'] as String? ?? 'Bearer';
      final expiresIn = data['expiresIn'] as int? ?? 0;
      final refreshToken = data['refreshToken'] as String? ?? '';
      final refreshExpiresIn = data['refreshExpiresIn'] as int? ?? 0;
      await AuthStorage.saveAuthData(
        token: token,
        tokenType: tokenType,
        user: user.toJson(),
        expiresIn: expiresIn,
        refreshToken: refreshToken,
        refreshExpiresIn: refreshExpiresIn,
      );

      debugPrint('AuthService: Dang nhap thanh cong. userId = ${user.id}');
      return LoginResult(token: token, tokenType: tokenType, user: user);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Dang xuat. Xoa token khoi AuthStorage.
  static Future<void> logout() async {
    await AuthStorage.clearAuth();
    debugPrint('AuthService: Dang xuat thanh cong');
  }

  /// Lay thong tin nguoi dung hien tai.
  static Map<String, dynamic>? getCurrentUser() {
    return AuthStorage.getUser();
  }

  /// Lay userId hien tai.
  static String? getCurrentUserId() {
    return AuthStorage.getUserId();
  }

  /// Gui ma OTP den email hoac so dien thoai.
  ///
  /// Goi POST /api/auth/send-otp.
  static Future<void> sendOtp(String emailOrPhone) async {
    debugPrint('AuthService: Gui OTP toi $emailOrPhone');

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/send-otp',
        data: {'emailOrPhone': emailOrPhone.trim()},
      );
      debugPrint('AuthService: Gui OTP thanh cong - response: ${response.data}');
    } on DioException catch (e) {
      debugPrint('AuthService: Gui OTP loi - response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  /// Gui lai ma OTP.
  ///
  /// Goi POST /api/auth/resend-otp.
  static Future<void> resendOtp(String emailOrPhone) async {
    debugPrint('AuthService: Gui lai OTP toi $emailOrPhone');

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/resend-otp',
        data: {'emailOrPhone': emailOrPhone.trim()},
      );
      debugPrint('AuthService: Gui lai OTP thanh cong - response: ${response.data}');
    } on DioException catch (e) {
      debugPrint('AuthService: Gui lai OTP loi - response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  /// Buoc 1: Dang ky tai khoan moi + gui OTP ve email.
  ///
  /// Goi POST /api/auth/register/verify-email.
  /// Sau buoc nay se hien trang nhap OTP.
  static Future<void> registerVerifyEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    debugPrint('AuthService: Buoc 1 - Dang ky gui OTP ve email = $email');

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/register/verify-email',
        data: {
          'email': email.trim(),
          'password': password,
          'fullName': fullName.trim(),
          'phoneNumber': phoneNumber.trim(),
        },
      );
      debugPrint('AuthService: Buoc 1 - Dang ky thanh cong, OTP da gui ve email - response: ${response.data}');
    } on DioException catch (e) {
      debugPrint('AuthService: Buoc 1 - Dang ky loi - response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  /// Buoc 2: Hoan tat dang ky sau khi xac thuc OTP.
  ///
  /// Goi POST /api/auth/register/complete.
  /// Tra ve LoginResult (token + user) neu thanh cong.
  static Future<LoginResult> registerComplete({
    required String email,
    required String otpCode,
  }) async {
    debugPrint('AuthService: Buoc 2 - Hoan tat dang ky email = $email, OTP = $otpCode');

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/register/complete',
        data: {
          'email': email.trim(),
          'otpCode': otpCode.trim(),
        },
      );

      final data = response.data;
      if (data == null) {
        throw AuthException('Khong nhan duoc phan hoi tu server');
      }

      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw AuthException('Phan hoi khong chua token');
      }

      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        throw AuthException('Phan hoi khong chua thong tin nguoi dung');
      }

      final user = AuthUser.fromJson(userJson);
      final tokenType = data['tokenType'] as String? ?? 'Bearer';
      final expiresIn = data['expiresIn'] as int? ?? 0;
      final refreshToken = data['refreshToken'] as String? ?? '';
      final refreshExpiresIn = data['refreshExpiresIn'] as int? ?? 0;

      await AuthStorage.saveAuthData(
        token: token,
        tokenType: tokenType,
        user: user.toJson(),
        expiresIn: expiresIn,
        refreshToken: refreshToken,
        refreshExpiresIn: refreshExpiresIn,
      );

      debugPrint('AuthService: Buoc 2 - Hoan tat dang ky thanh cong. userId = ${user.id}');
      return LoginResult(token: token, tokenType: tokenType, user: user);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Xac thuc ma OTP.
  ///
  /// Goi POST /api/auth/verify-otp.
  /// Tra ve OtpVerifyResult chua tempToken neu thanh cong.
  static Future<OtpVerifyResult> verifyOtp(
    String emailOrPhone,
    String otpCode,
  ) async {
    debugPrint('AuthService: Xac thuc OTP [$otpCode] cho $emailOrPhone');

    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/verify-otp',
        data: {
          'emailOrPhone': emailOrPhone.trim(),
          'otpCode': otpCode.trim(),
        },
      );

      final data = response.data;
      if (data == null) {
        throw AuthException('Khong nhan duoc phan hoi tu server');
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final message = data['message'] as String? ?? 'Xac thuc OTP that bai';
        throw AuthException(message);
      }

      final tempToken = data['tempToken'] as String?;
      if (tempToken == null || tempToken.isEmpty) {
        throw AuthException('Phan hoi khong chua tempToken');
      }

      final tokenType = data['tokenType'] as String? ?? 'Bearer';
      final expiresIn = data['expiresIn'] as int? ?? 0;
      DateTime? expiresAt;
      final expiresAtStr = data['expiresAt'] as String?;
      if (expiresAtStr != null) {
        expiresAt = DateTime.tryParse(expiresAtStr);
      }

      debugPrint('AuthService: Xac thuc OTP thanh cong - response: $data');
      return OtpVerifyResult(
        tempToken: tempToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
        expiresAt: expiresAt,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Dat lai mat khau moi.
  ///
  /// Goi POST /api/auth/reset-password.
  static Future<void> resetPassword(String tempToken, String newPassword) async {
    debugPrint('AuthService: Dat lai mat khau moi');

    try {
      await ApiClient.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: {
          'tempToken': tempToken,
          'newPassword': newPassword,
        },
      );
      debugPrint('AuthService: Dat lai mat khau thanh cong');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Xu ly loi tu Dio.
  static AuthException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String message;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? 'Da xay ra loi';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Khong the ket noi den server. Vui long kiem tra mang.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Server phan hoi qua cham. Vui long thu lai sau.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Khong the ket noi den server. Vui long kiem tra mang.';
    } else if (statusCode == 401) {
      message = 'Tai khoan hoac mat khau khong chinh xac';
    } else if (statusCode == 400) {
      final msg = data is Map<String, dynamic> ? data['message'] : null;
      message = msg as String? ?? 'Yeu cau khong hop le';
    } else if (statusCode == 404) {
      message = 'Khong tim thay tai khoan trong he thong';
    } else {
      message = 'Da xay ra loi. Vui long thu lai sau.';
    }

    debugPrint('AuthService: Loi API - status=$statusCode, message=$message');
    return AuthException(message);
  }
}
