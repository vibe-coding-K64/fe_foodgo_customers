import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';

/// Service chua cac ham goi du lieu tu Firestore cho trang chu.
class HomeService {
  HomeService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================================================================
  // STREAM: DANH MUC (Categories)
  // ================================================================

  /// Lay danh sach danh muc (categories) theo thoi gian thuc.
  /// Chi lay categories he thong (storeId = null).
  /// Sap xep theo field 'order' tang dan (sort in-memory vi khong co index).
  static Stream<List<CategoryModel>> getCategoriesStream() {
    debugPrint('HomeService: Dang lay Stream danh muc tu Firestore');
    return _firestore
        .collection('categories')
        .where('storeId', isNull: true)
        .snapshots()
        .handleError((error) {
      debugPrint('HomeService[Loi Stream danh muc]: $error');
    })
        .map((snapshot) {
      debugPrint('HomeService: Da nhan ${snapshot.docs.length} danh muc');
      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
      // Sap xep theo 'order' tang dan trong bo nho.
      categories.sort((a, b) => a.order.compareTo(b.order));
      return categories;
    });
  }

  // ================================================================
  // STREAM: QUAN (Stores)
  // ================================================================

  /// Lay danh sach quan (stores) theo thoi gian thuc.
  /// Chi lay nhung ban ghi chua bi xoa mem.
  static Stream<List<StoreModel>> getStoresStream({int limit = 20}) {
    debugPrint('HomeService: Dang lay Stream danh sach quan tu Firestore');
    return _firestore
        .collection('stores')
        .where('deletedAt', isNull: true)
        .limit(limit)
        .snapshots()
        .handleError((error) {
      debugPrint('HomeService[Loi Stream danh sach quan]: $error');
    })
        .map((snapshot) {
      debugPrint('HomeService: Da nhan ${snapshot.docs.length} quan');
      return snapshot.docs
          .map((doc) => StoreModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Lay danh sach quan noi bat (featured).
  /// Sap xep theo rating giam dan trong bo nho (khong dung orderBy vi khong co index).
  static Stream<List<StoreModel>> getFeaturedStoresStream({int limit = 10}) {
    debugPrint('HomeService: Dang lay Stream quan noi bat tu Firestore');
    return _firestore
        .collection('stores')
        .where('deletedAt', isNull: true)
        .where('isOpen', isEqualTo: true)
        .limit(limit * 2)
        .snapshots()
        .handleError((error) {
      debugPrint('HomeService[Loi Stream quan noi bat]: $error');
    })
        .map((snapshot) {
      final stores = snapshot.docs
          .map((doc) => StoreModel.fromFirestore(doc))
          .toList();
      stores.sort((a, b) => b.rating.compareTo(a.rating));
      debugPrint('HomeService: Da nhan ${stores.length} quan noi bat (sau sort)');
      return stores.take(limit).toList();
    });
  }

  /// Lay danh sach quan gan day (dang mo cua).
  /// Sap xep theo rating giam dan trong bo nho (khong dung orderBy vi khong co index).
  static Stream<List<StoreModel>> getNearbyStoresStream({int limit = 10}) {
    debugPrint('HomeService: Dang lay Stream quan gan day tu Firestore');
    return _firestore
        .collection('stores')
        .where('deletedAt', isNull: true)
        .where('isOpen', isEqualTo: true)
        .limit(limit * 2) // Lay nhieu hon de dam bao du khi filter
        .snapshots()
        .handleError((error) {
      debugPrint('HomeService[Loi Stream quan gan day]: $error');
    })
        .map((snapshot) {
      final stores = snapshot.docs
          .map((doc) => StoreModel.fromFirestore(doc))
          .toList();
      // Sap xep theo rating giam dan trong bo nho.
      stores.sort((a, b) => b.rating.compareTo(a.rating));
      debugPrint('HomeService: Da nhan ${stores.length} quan gan day (sau sort)');
      return stores.take(limit).toList();
    });
  }

  // ================================================================
  // STREAM: SAN PHAM (Products)
  // ================================================================

  /// Lay danh sach san pham (products) theo thoi gian thuc.
  /// Chi lay nhung san pham con hang (isOutOfStock = false).
  static Stream<List<ProductModel>> getProductsStream({int limit = 20}) {
    debugPrint('HomeService: Dang lay Stream danh sach san pham tu Firestore');
    return _firestore
        .collection('products')
        .where('deletedAt', isNull: true)
        .where('isOutOfStock', isEqualTo: false)
        .limit(limit)
        .snapshots()
        .handleError((error) {
      debugPrint('HomeService[Loi Stream danh sach san pham]: $error');
    })
        .map((snapshot) {
      debugPrint('HomeService: Da nhan ${snapshot.docs.length} san pham');
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Lay danh sach san pham theo danh muc.
  static Stream<List<ProductModel>> getProductsByCategoryStream(
    String categoryId, {
    int limit = 10,
  }) {
    debugPrint(
        'HomeService: Dang lay Stream san pham theo danh muc [$categoryId]');
    return _firestore
        .collection('products')
        .where('deletedAt', isNull: true)
        .where('categoryId', isEqualTo: categoryId)
        .where('isOutOfStock', isEqualTo: false)
        .limit(limit)
        .snapshots()
        .handleError((error) {
      debugPrint('HomeService[Loi Stream san pham theo danh muc]: $error');
    })
        .map((snapshot) {
      debugPrint(
          'HomeService: Da nhan ${snapshot.docs.length} san pham theo danh muc');
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Lay danh sach san pham noi bat (recommended).
  /// Chi lay nhung san pham co isFeatured = true va con hang.
  static Stream<List<ProductModel>> getFeaturedProductsStream({
    int limit = 10,
  }) {
    debugPrint('HomeService: Dang lay Stream san pham noi bat tu Firestore');
    return _firestore
        .collection('products')
        .where('deletedAt', isNull: true)
        .where('isOutOfStock', isEqualTo: false)
        .where('isFeatured', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .handleError((error) {
      debugPrint('HomeService[Loi Stream san pham noi bat]: $error');
    })
        .map((snapshot) {
      debugPrint('HomeService: Da nhan ${snapshot.docs.length} san pham noi bat');
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  // ================================================================
  // STREAM: BANNER (Banners)
  // ================================================================

  /// Lay danh sach banner quang cao (dang hoat dong).
  /// Sap xep theo field 'order' tang dan trong bo nho (khong dung orderBy).
  static Stream<List<BannerModel>> getBannersStream() {
    debugPrint('HomeService: Dang lay Stream banner tu Firestore');
    return _firestore
        .collection('banners')
        .where('deletedAt', isNull: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .handleError((error) {
      debugPrint('HomeService[Loi Stream banner]: $error');
    })
        .map((snapshot) {
      final banners = snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
      // Sap xep theo 'order' tang dan trong bo nho.
      banners.sort((a, b) => a.order.compareTo(b.order));
      debugPrint('HomeService: Da nhan ${banners.length} banner');
      return banners;
    });
  }
}
