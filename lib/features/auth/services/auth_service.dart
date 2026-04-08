import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../profile/models/user_model.dart';
import '../../../../core/utils/auth_storage.dart';

/// Exception khi dang nhap that bai.
class LoginException implements Exception {
  final String message;

  LoginException(this.message);

  @override
  String toString() => message;
}

/// Service xu ly cac thao tac xac thuc nguoi dung.
///
/// Su dung Firestore collection `users` de xac thuc.
class AuthService {
  AuthService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _usersCollection = 'users';

  /// Dang nhap voi username (email hoac so dien thoai) va mat khau.
  ///
  /// Buoc 1: Query Firestore tim document co email == username
  ///          hoac phoneNumber == username.
  /// Buoc 2: Neu tim thay, kiem tra truong password co khop khong.
  /// Buoc 3: Neu mat khau khop, kiem tra quyen cua user.
  /// Buoc 4: Neu user khong co quyen Khach hang (role 1), yeu cau dang xuat
  ///          va nem loi. Neu co quyen, luu userId va tra ve true.
  ///
  /// Neu khong tim thay hoac mat khau sai, nem exception.
  static Future<bool> login(String username, String password) async {
    debugPrint('AuthService: Bat dau dang nhap voi username = $username');

    // Lay collection users.
    final CollectionReference usersRef =
        _firestore.collection(_usersCollection);

    // Query 1: Tim theo email.
    QuerySnapshot snapshot = await usersRef.where('email', isEqualTo: username).get();
    debugPrint('AuthService: Query theo email, so ket qua = ${snapshot.docs.length}');

    // Query 2: Neu khong tim thay, tim theo so dien thoai.
    if (snapshot.docs.isEmpty) {
      snapshot = await usersRef.where('phoneNumber', isEqualTo: username).get();
      debugPrint('AuthService: Query theo phoneNumber, so ket qua = ${snapshot.docs.length}');
    }

    // Khong tim thay nguoi dung.
    if (snapshot.docs.isEmpty) {
      debugPrint('AuthService: Khong tim thay nguoi dung voi username = $username');
      throw LoginException('Tai khoan khong ton tai trong he thong');
    }

    // Lay document dau tien tim duoc.
    final doc = snapshot.docs.first;

    debugPrint('AuthService: Tim thay nguoi dung, id = ${doc.id}');

    // Kiem tra mat khau.
    final data = doc.data() as Map<String, dynamic>;
    final storedPassword = data['password'] as String?;
    if (storedPassword == null) {
      debugPrint('AuthService: Nguoi dung khong co truong password');
      throw LoginException('Tai khoan chua duoc cai dat mat khau');
    }

    if (storedPassword != password) {
      debugPrint('AuthService: Mat khau khong khop');
      throw LoginException('Tai khoan hoac mat khau khong chinh xac');
    }

    // Mat khau khop. Kiem tra quyen cua user.
    final userModel = UserModel.fromFirestore(doc);

    // Chi cho phep khach hang (role 1) dang nhap vao app nay.
    if (!userModel.isCustomer) {
      debugPrint('AuthService: User ${doc.id} khong co quyen Khach hang. Yeu cau dang xuat.');
      // Yeu cau Firebase Auth dang xuat ngay de xoa khoi bo nho local.
      try {
        await _auth.signOut();
        debugPrint('AuthService: Da goi signOut() thanh cong');
      } catch (e) {
        debugPrint('AuthService: Loi khi goi signOut(): $e');
      }
      // Tra ve loi chung de tang bao mat (khong tiet lo role thuc su).
      throw LoginException('Tai khoan hoac mat khau khong chinh xac');
    }

    debugPrint('AuthService: User ${doc.id} co quyen Khach hang. Cho phep dang nhap.');

    // Dang nhap thanh cong. Luu userId vao SharedPreferences.
    await AuthStorage.saveUserId(doc.id);
    debugPrint('AuthService: Dang nhap thanh cong, userId = ${doc.id}');

    return true;
  }

  /// Dang xuat. Xoa userId khoi AuthStorage.
  static Future<void> logout() async {
    await AuthStorage.clearUserId();
    debugPrint('AuthService: Dang xuat thanh cong');
  }

  /// Lay thong tin nguoi dung hien tai tu Firestore.
  /// Tra ve null neu chua dang nhap.
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final userId = AuthStorage.getUserId();
    if (userId == null) return null;

    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    if (!doc.exists) return null;

    return doc.data() as Map<String, dynamic>;
  }
}
