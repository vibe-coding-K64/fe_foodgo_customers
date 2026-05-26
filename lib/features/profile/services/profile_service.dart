import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/auth_storage.dart';
import '../models/user_model.dart';

/// Service quan ly thong tin ho so nguoi dung.
///
/// Su dung backend API `/api/customers/*` de lay va cap nhat thong tin.
/// Ket hop voi Firebase Firestore cho loyalty/reward data.
class ProfileService {
  const ProfileService();

  /// Lay header Authorization voi Bearer token.
  Options _authOptions() {
    final token = AuthStorage.getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Lay thong tin nguoi dung hien tai tu API.
  ///
  /// Goi GET /api/customers/profile
  /// Tra ve UserModel neu thanh cong, null neu that bai.
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/customers/profile',
        options: _authOptions(),
      );

      final data = response.data;
      if (data == null) return null;

      final success = data['success'] as bool? ?? false;
      if (!success) {
        debugPrint('ProfileService: API tra ve success=false');
        return null;
      }

      final userData = data['data'] as Map<String, dynamic>?;
      if (userData == null) return null;

      debugPrint('ProfileService: Lay thong tin thanh cong');
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      debugPrint('ProfileService: Loi lay thong tin - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('ProfileService: Loi khong xac dinh - $e');
      return null;
    }
  }

  /// Stream lang nghe thong tin nguoi dung hien tai.
  ///
  /// Goi API lay thong tin ban dau, tra ve Stream don (khong phai real-time).
  /// De real-time, can backend ho tro WebSocket/SSE.
  Stream<UserModel?> getCurrentUserStream() {
    return Stream.fromFuture(getCurrentUser());
  }

  /// Cap nhat ho so nguoi dung.
  ///
  /// Goi PUT /api/customers/profile
  /// Chi cap nhat cac truong duoc truyen vao: [fullName] va [avatarUrl].
  /// Tra ve UserModel da cap nhat neu thanh cong, null neu that bai.
  Future<UserModel?> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null && fullName.trim().isNotEmpty) {
        updates['fullName'] = fullName.trim();
      }

      if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
        updates['avatarUrl'] = avatarUrl.trim();
      }

      if (updates.isEmpty) {
        debugPrint('ProfileService: Khong co truong nao de cap nhat');
        return null;
      }

      debugPrint('ProfileService: Cap nhat ho so - $updates');

      final response = await ApiClient.put<Map<String, dynamic>>(
        '/customers/profile',
        data: updates,
        options: _authOptions(),
      );

      final data = response.data;
      if (data == null) return null;

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final message = data['message'] as String? ?? 'Cap nhat that bai';
        throw Exception(message);
      }

      final userData = data['data'] as Map<String, dynamic>?;
      if (userData == null) return null;

      final updatedUser = UserModel.fromJson(userData);

      // Cap nhat lai AuthStorage voi thong tin moi.
      await AuthStorage.saveAuthData(
        token: AuthStorage.getToken() ?? '',
        tokenType: AuthStorage.getTokenType() ?? 'Bearer',
        user: updatedUser.toJson(),
      );

      debugPrint('ProfileService: Cap nhat ho so thanh cong');
      return updatedUser;
    } on DioException catch (e) {
      final message = _handleDioError(e);
      debugPrint('ProfileService: Loi cap nhat ho so - $message');
      throw Exception(message);
    } catch (e) {
      debugPrint('ProfileService: Loi cap nhat ho so - $e');
      rethrow;
    }
  }

  /// Xu ly loi tu Dio.
  String _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 'Da xay ra loi';
    }

    switch (statusCode) {
      case 401:
        return 'Chua xac thuc. Vui long dang nhap lai.';
      case 404:
        return 'Khong tim thay tai khoan.';
      case 400:
        return 'Yeu cau khong hop le.';
      default:
        return 'Da xay ra loi. Vui long thu lai sau.';
    }
  }
}
