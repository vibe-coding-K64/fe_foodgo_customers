/// Service quan ly ket noi va tuong tac voi Firebase.
/// Cac chuc nang chinh: xac thuc, truy cap Firestore, luu tru file.
class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  /// Khoi tao ket noi Firebase.
  Future<void> init() async {
    // TODO: Khoi tao Firebase core.
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  }

  /// Xac thuc nguoi dung bang email va mat khau.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // TODO: Implement sign in with email and password.
  }

  /// Tao tai khoan nguoi dung moi bang email va mat khau.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // TODO: Implement sign up with email and password.
  }

  /// Dang xuat tai khoan hien tai.
  Future<void> signOut() async {
    // TODO: Implement sign out.
  }

  /// Lay thong tin nguoi dung hien dang nhap.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    // TODO: Implement get current user.
    return null;
  }

  /// Doc du lieu tu Firestore theo duong dan collection/document.
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    // TODO: Implement get document from Firestore.
    return null;
  }

  /// Ghi du lieu vao Firestore.
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    // TODO: Implement set document to Firestore.
  }

  /// Cap nhat du lieu trong Firestore.
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    // TODO: Implement update document in Firestore.
  }

  /// Xoa document trong Firestore.
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    // TODO: Implement delete document from Firestore.
  }

  /// Lay danh sach du lieu tu Firestore.
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
    String? whereField,
    dynamic whereValue,
    int? limit,
  }) async {
    // TODO: Implement get collection from Firestore.
    return [];
  }
}
