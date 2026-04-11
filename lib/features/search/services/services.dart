import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/auth_storage.dart';
import '../../../core/network/api_client.dart';
import '../models/search_history_model.dart';
import '../models/search_result_item.dart';

/// Service quan ly lich su tim kiem, tuong tac voi Firebase Firestore.
///
/// Ho tro cac thao tac:
/// - Lay danh sach lich su tim kiem theo Stream (thoi gian thuc)
/// - Them tu khoa tim kiem (neu da co thi cap nhat thoi gian)
/// - Xoa 1 item lich su
/// - Xoa tat ca lich su (dung WriteBatch)
class SearchService {
  const SearchService();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay duong dan sub-collection lich su tim kiem cua nguoi dung hien tai.
  /// Duong dan: users/{userId}/search_history.
  CollectionReference _searchHistoryCollection() {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('SearchService: Nguoi dung chua dang nhap');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('search_history');
  }

  /// Stream lang nghe danh sach lich su tim kiem cua nguoi dung hien tai.
  /// Sap xep: theo thoi gian tao moi nhat, gioi han 10 ket qua.
  Stream<List<SearchHistoryModel>> getSearchHistoryStream() {
    try {
      return _searchHistoryCollection()
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              debugPrint('SearchService: Khong co lich su tim kiem nao');
              return <SearchHistoryModel>[];
            }
            final histories = snapshot.docs
                .map((doc) => SearchHistoryModel.fromFirestore(doc))
                .toList();
            debugPrint(
              'SearchService: Tai ${histories.length} lich su tim kiem',
            );
            return histories;
          });
    } catch (e) {
      debugPrint('SearchService: Loi lay danh sach lich su - $e');
      return Stream.value([]);
    }
  }

  /// Them tu khoa tim kiem moi hoac cap nhat thoi gian neu da ton tai.
  ///
  /// Neu tu khoa da ton tai trong lich su, cap nhat createdAt de no troi
  /// len dau danh sach. Neu chua co thi them document moi.
  Future<void> addSearchKeyword(String keyword) async {
    final trimmedKeyword = keyword.trim();

    // Kiem tra rong.
    if (trimmedKeyword.isEmpty) {
      debugPrint('SearchService: Tu khoa rong, khong luu');
      return;
    }

    try {
      final collection = _searchHistoryCollection();

      // Kiem tra tu khoa da ton tai chua.
      final querySnapshot = await collection
          .where('keyword', isEqualTo: trimmedKeyword)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Da ton tai -> cap nhat createdAt.
        final existingDoc = querySnapshot.docs.first;
        await existingDoc.reference.update({
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint(
          'SearchService: Cap nhat thoi gian cho tu khoa [$trimmedKeyword]',
        );
      } else {
        // Chua ton tai -> them moi.
        await collection.add({
          'keyword': trimmedKeyword,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('SearchService: Them tu khoa [$trimmedKeyword] thanh cong');
      }
    } catch (e) {
      debugPrint('SearchService: Loi khi them tu khoa - $e');
      rethrow;
    }
  }

  /// Xoa 1 item lich su tim kiem theo id.
  Future<void> deleteSearchHistory(String id) async {
    try {
      final docRef = _searchHistoryCollection().doc(id);
      await docRef.delete();
      debugPrint('SearchService: Xoa lich su [$id] thanh cong');
    } catch (e) {
      debugPrint('SearchService: Loi xoa lich su - $e');
      rethrow;
    }
  }

  /// Xoa tat ca lich su tim kiem cua nguoi dung hien tai.
  ///
  /// Su dung WriteBatch de dam bao tinh toan ven: lay tat ca document
  /// roi xoa nhieu document cung luc trong 1 batch.
  Future<void> clearAllHistory() async {
    try {
      final collection = _searchHistoryCollection();
      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) {
        debugPrint('SearchService: Khong co lich su de xoa');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint(
        'SearchService: Xoa ${snapshot.docs.length} lich su thanh cong',
      );
    } catch (e) {
      debugPrint('SearchService: Loi xoa tat ca lich su - $e');
      rethrow;
    }
  }
}

/// Service goi API lay du lieu tim kiem (tu my-json-server).
class ApiSearchService {
  const ApiSearchService();

  /// Lay danh sach tu khoa tim kiem pho bien.
  ///
  /// Endpoint: GET /popular_keywords
  /// API tra ve truc tiep List. Khong co truong data bao ngoai.
  Future<List<String>> getPopularKeywords() async {
    try {
      final response =
          await ApiClient.get<List<dynamic>>('/popular_keywords');

      // API tra ve truc tiep Array<String>.
      final List<dynamic> rawData = response.data ?? [];

      debugPrint(
          'ApiSearchService: Da nhan ${rawData.length} tu khoa pho bien');

      return rawData.cast<String>();
    } catch (e) {
      debugPrint('ApiSearchService: Loi getPopularKeywords - $e');
      rethrow;
    }
  }

  /// Lay danh sach ket qua tim kiem tu Mock API.
  ///
  /// Endpoint: GET /search_results
  /// Server da xu ly filter/search phia backend, tra ve day du danh sach.
  /// Tra ve List<SearchResultItem>.
  Future<List<SearchResultItem>> fetchSearchResults(String keyword) async {
    try {
      final response = await ApiClient.get<List<dynamic>>('/SearchResultItem');

      final List<dynamic> rawData = response.data ?? [];

      debugPrint(
          'ApiSearchService: Da nhan ${rawData.length} ket qua');

      return rawData
          .map((json) =>
              SearchResultItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ApiSearchService: Loi fetchSearchResults - $e');
      rethrow;
    }
  }
}
