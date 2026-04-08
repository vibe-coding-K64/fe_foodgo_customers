import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/auth_storage.dart';
import '../models/user_model.dart';

/// Service quan ly thong tin ho so nguoi dung, tuong tac voi Firebase Firestore.
///
/// Ho tro cac thao tac:
/// - Lay thong tin nguoi dung hien tai theo Stream (thoi gian thuc)
/// - Cap nhat ho so (fullName, email)
/// - Lay thong tin diem thanh vien (loyaltyPoints, membershipTier)
class ProfileService {
  const ProfileService();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay duong dan document cua nguoi dung hien tai trong bang goc `users`.
  DocumentReference _userDoc() {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('ProfileService: Nguoi dung chua dang nhap');
    }
    return _firestore.collection('users').doc(userId);
  }

  /// Lay duong dan document cua nguoi dung hien tai trong nhanh `customer_profiles`.
  DocumentReference _customerProfileDoc() {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('ProfileService: Nguoi dung chua dang nhap');
    }
    return _firestore.collection('customer_profiles').doc(userId);
  }

  /// Stream lang nghe thong tin nguoi dung hien tai.
  ///
  /// Lang nghe document `users/{userId}` de cap nhat UI thoi gian thuc
  /// khi co thay doi ho so.
  Stream<UserModel?> getCurrentUserStream() {
    try {
      return _userDoc().snapshots().map((snapshot) {
        if (!snapshot.exists) {
          debugPrint('ProfileService: Document nguoi dung khong ton tai');
          return null;
        }
        debugPrint('ProfileService: Tai thong tin nguoi dung thanh cong');
        return UserModel.fromFirestore(snapshot);
      });
    } catch (e) {
      debugPrint('ProfileService: Loi lay thong tin nguoi dung - $e');
      return Stream.value(null);
    }
  }

  /// Lay thong tin diem thanh vien tu nhanh `customer_profiles`.
  ///
  /// Tra ve Map chua [loyaltyPoints] va [membershipTier].
  /// Tra ve null neu chua dang nhap hoac khong tim thay document.
  Future<Map<String, int>?> getCustomerRewardInfo() async {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('ProfileService: Nguoi dung chua dang nhap');
      return null;
    }

    try {
      final doc = await _customerProfileDoc().get();

      if (!doc.exists) {
        debugPrint('ProfileService: Khong tim thay customer_profile cua user $userId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      final loyaltyPoints = (data['loyaltyPoints'] as num?)?.toInt() ?? 0;
      final membershipTier = (data['membershipTier'] as num?)?.toInt() ?? 0;

      debugPrint('ProfileService: Lay diem thanh vien - Diem=$loyaltyPoints, Hang=$membershipTier');

      return {
        'loyaltyPoints': loyaltyPoints,
        'membershipTier': membershipTier,
      };
    } catch (e) {
      debugPrint('ProfileService: Loi khi lay thong tin diem thanh vien - $e');
      return null;
    }
  }

  /// Cap nhat ho so nguoi dung.
  ///
  /// Chi cap nhat cac truong duoc truyen vao: [fullName] va [email].
  /// Mot so truong khac (nhu phoneNumber) khong duoc phep sua.
  ///
  /// TODO: Xu ly upload anh avatar sau khi da co tich hop Firebase Storage.
  Future<void> updateProfile({
    String? fullName,
    String? email,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null && fullName.trim().isNotEmpty) {
        updates['fullName'] = fullName.trim();
      }

      if (email != null && email.trim().isNotEmpty) {
        updates['email'] = email.trim();
      }

      if (updates.isEmpty) {
        debugPrint('ProfileService: Khong co truong nao de cap nhat');
        return;
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _userDoc().update(updates);
      debugPrint('ProfileService: Cap nhat ho so thanh cong - $updates');
    } catch (e) {
      debugPrint('ProfileService: Loi cap nhat ho so - $e');
      rethrow;
    }
  }
}
