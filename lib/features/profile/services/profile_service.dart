import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/auth_storage.dart';
import '../models/profile_stats.dart';
import '../models/user_model.dart';

/// Service quan ly thong tin ho so nguoi dung.
///
/// Su dung Firebase Firestore cho tat ca thong tin nguoi dung.
class ProfileService {
  const ProfileService();

  /// Lay header Authorization voi Bearer token (chi dung cho update).
  Options _authOptions() {
    final token = AuthStorage.getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Lay thong tin nguoi dung hien tai tu Firestore `/users/{userId}`.
  Future<UserModel?> getCurrentUser() async {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('ProfileService: Khong co userId');
      return null;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        debugPrint('ProfileService: Khong tim thay user doc');
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('ProfileService: loi doc user - $e');
      return null;
    }
  }

  /// Stream lang nghe thong tin nguoi dung hien tai.
  ///
  /// Su dung Stream<Firestore> de nhan cap nhat real-time khi Firestore thay doi.
  /// Tra ve StreamBuilder-friendly stream (khong tao moi Future moi lan build).
  Stream<UserModel?> getCurrentUserStream() {
    debugPrint('ProfileService.getCurrentUserStream: Bat dau lang nghe Firestore');
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('ProfileService.getCurrentUserStream: Khong co userId, tra ve Stream rong');
      return Stream.value(null);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        debugPrint('ProfileService: Firestore doc khong ton tai');
        return null;
      }
      return UserModel.fromFirestore(doc);
    });
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
        updates['photoUrl'] = avatarUrl.trim();
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

      await AuthStorage.saveAuthData(
        token: AuthStorage.getToken() ?? '',
        tokenType: AuthStorage.getTokenType() ?? 'Bearer',
        user: updatedUser.toJson(),
        expiresIn: AuthStorage.getExpiresIn() ?? 0,
        refreshToken: AuthStorage.getRefreshToken() ?? '',
        refreshExpiresIn: AuthStorage.getRefreshExpiresIn() ?? 0,
      );

      debugPrint('ProfileService: Cap nhat ho so thanh cong');
      return updatedUser;
    } on DioException catch (e) {
      final message = _handleDioError(e);
      debugPrint('ProfileService: loi cap nhat ho so - $message');
      throw Exception(message);
    } catch (e) {
      debugPrint('ProfileService: loi cap nhat ho so - $e');
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

  /// Cap nhat ho so voi avatar (multipart/form-data).
  ///
  /// Neu [avatarFile] khac null -> gui kem file avatar.
  /// Neu [fullName] khac null -> gui kem fullName.
  /// Neu [email] khac null -> gui kem email.
  /// Chi gui nhung truong thuc su thay doi.
  Future<UserModel?> updateProfileWithAvatar({
    File? avatarFile,
    String? fullName,
    String? email,
    required String password,
  }) async {
    try {
      final formData = FormData();

      // Neu co file avatar, them vao formData
      if (avatarFile != null) {
        final fileName = avatarFile.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            avatarFile.path,
            filename: fileName,
          ),
        ));
        debugPrint('ProfileService: Co file avatar - $fileName');
      }

      // Neu co fullName, them vao formData
      if (fullName != null && fullName.trim().isNotEmpty) {
        formData.fields.add(MapEntry('fullName', fullName.trim()));
        debugPrint('ProfileService: Co fullName - $fullName');
      }

      // Neu co email, them vao formData
      if (email != null && email.trim().isNotEmpty) {
        formData.fields.add(MapEntry('email', email.trim()));
        debugPrint('ProfileService: Co email - $email');
      }

      // Gui kem password xac thuc
      formData.fields.add(MapEntry('password', password));

      if (formData.fields.isEmpty && formData.files.isEmpty) {
        debugPrint('ProfileService: Khong co truong nao de cap nhat');
        return null;
      }

      debugPrint('ProfileService: Cap nhat ho so voi avatar (formData)');

      final response = await ApiClient.putFormData<Map<String, dynamic>>(
        '/customers/profile',
        data: formData,
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

      await AuthStorage.saveAuthData(
        token: AuthStorage.getToken() ?? '',
        tokenType: AuthStorage.getTokenType() ?? 'Bearer',
        user: updatedUser.toJson(),
        expiresIn: AuthStorage.getExpiresIn() ?? 0,
        refreshToken: AuthStorage.getRefreshToken() ?? '',
        refreshExpiresIn: AuthStorage.getRefreshExpiresIn() ?? 0,
      );

      debugPrint('ProfileService: Cap nhat ho so thanh cong');
      return updatedUser;
    } on DioException catch (e) {
      final message = _handleDioError(e);
      debugPrint('ProfileService: loi cap nhat ho so - $message');
      throw Exception(message);
    } catch (e) {
      debugPrint('ProfileService: loi cap nhat ho so - $e');
      rethrow;
    }
  }

  /// Lay thong ke nguoi dung (don hang, voucher, diem) tu Firestore.
  Future<ProfileStats> getUserStats() async {
    final userId = AuthStorage.getUserId();
    debugPrint('=== getUserStats START ===');
    debugPrint('AuthStorage.getUserId() = ${userId ?? "null"}');
    if (userId == null || userId.isEmpty) {
      debugPrint('ProfileService: Khong co userId, tra ve stats mac dinh');
      return const ProfileStats();
    }

    final firestore = FirebaseFirestore.instance;

    try {
      int orderCount = 0;
      int voucherCount = 0;
      int loyaltyPoints = 0;

      // Dem so don hang da hoan thanh (status == 3).
      debugPrint('Query orders with userId=$userId');
      final orderSnap = await firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      debugPrint('orders query: ${orderSnap.size} docs found');
      debugPrint('orders docs: ${orderSnap.docs.map((d) => '${d.id} status=${(d.data() as Map<String, dynamic>)['status']}').join(', ')}');
      orderCount = orderSnap.docs.where((doc) {
        final status = (doc.data() as Map<String, dynamic>)['status'];
        return status == 3;
      }).length;
      debugPrint('orderCount=$orderCount (status==3 only)');

      // Dem so voucher con han su dung.
      debugPrint('Query my_vouchers under customer_profiles/$userId');
      final voucherSnap = await firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('my_vouchers')
          .get();
      debugPrint('my_vouchers query: ${voucherSnap.size} docs found');
      final now = DateTime.now().toUtc();
      voucherCount = voucherSnap.docs.where((doc) {
        final rawExpiry = (doc.data() as Map<String, dynamic>)['expiryDate'];
        if (rawExpiry == null) return false;
        try {
          DateTime expiry;
          if (rawExpiry is Timestamp) {
            expiry = rawExpiry.toDate();
          } else if (rawExpiry is String) {
            expiry = DateTime.parse(rawExpiry);
          } else {
            return false;
          }
          final isValid = expiry.isAfter(now);
          debugPrint('  voucher ${doc.id}: expiry=$expiry, isValid=$isValid');
          return isValid;
        } catch (_) {
          return false;
        }
      }).length;
      debugPrint('voucherCount=$voucherCount');

      // Lay loyaltyPoints.
      debugPrint('Query customer_profiles/$userId');
      final profileSnap = await firestore
          .collection('customer_profiles')
          .doc(userId)
          .get();
      debugPrint('profileSnap exists=${profileSnap.exists}');
      if (profileSnap.exists) {
        final data = profileSnap.data() as Map<String, dynamic>?;
        debugPrint('profileSnap data keys: ${data?.keys.join(', ')}');
        loyaltyPoints = (data?['loyaltyPoints'] as int?) ?? 0;
      } else {
        debugPrint('WARNING: customer_profiles/$userId document does NOT exist!');
      }
      debugPrint('loyaltyPoints=$loyaltyPoints');
      debugPrint('=== getUserStats END: orders=$orderCount, vouchers=$voucherCount, points=$loyaltyPoints ===');

      return ProfileStats(
        totalOrders: orderCount,
        availableVouchers: voucherCount,
        rewardPoints: loyaltyPoints,
      );
    } catch (e) {
      debugPrint('ProfileService: loi getUserStats - $e');
      return const ProfileStats();
    }
  }
}
