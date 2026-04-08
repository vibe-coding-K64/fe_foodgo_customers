import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/auth_storage.dart';
import '../models/address_model.dart';

/// Service quan ly dia chi nguoi dung, tuong tac voi Firebase Firestore.
///
/// Ho tro cac thao tac:
/// - Lay danh sach dia chi theo Stream (thoi gian thuc)
/// - Dat dia chi mac dinh (dung WriteBatch de cap nhat nhieu document)
/// - Xoa dia chi khoi Firestore
class AddressService {
  const AddressService();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay duong dan sub-collection dia chi cua nguoi dung hien tai.
  CollectionReference _addressCollection() {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('AddressService: Nguoi dung chua dang nhap');
    }
    return _firestore.collection('customer_profiles').doc(userId).collection('addresses');
  }

  /// Stream lang nghe danh sach dia chi cua nguoi dung hien tai.
  ///
  /// Sap xep: dia chi mac dinh (isDefault == true) nam truoc, cac dia chi
  /// khac nam sau. Tra ve danh sach rong neu chua co dia chi nao.
  Stream<List<AddressModel>> getAddressesStream() {
    try {
      return _addressCollection()
          .orderBy('isDefault', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          debugPrint('AddressService: Khong co dia chi nao');
          return <AddressModel>[];
        }
        final addresses = snapshot.docs
            .map((doc) => AddressModel.fromFirestore(doc))
            .toList();
        // Sap xep lai: mac dinh truoc, khong mac dinh theo thu tu goc
        addresses.sort((a, b) {
          if (a.isDefault && !b.isDefault) return -1;
          if (!a.isDefault && b.isDefault) return 1;
          return 0;
        });
        debugPrint('AddressService: Tai ${addresses.length} dia chi');
        return addresses;
      });
    } catch (e) {
      debugPrint('AddressService: Loi lay danh sach dia chi - $e');
      return Stream.value([]);
    }
  }

  /// Dat mot dia chi lam mac dinh.
  ///
  /// Su dung WriteBatch de dam bao tinh toan ven (atomicity):
  /// 1. Quet tat ca document, set isDefault = false
  /// 2. Cap nhat document duoc chon, set isDefault = true
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final collection = _addressCollection();
      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) {
        debugPrint('AddressService: Khong co dia chi de dat mac dinh');
        return;
      }

      final batch = _firestore.batch();

      // Tat ca document deu set isDefault = false
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Document duoc chon set isDefault = true
      final targetDoc = collection.doc(addressId);
      batch.update(targetDoc, {'isDefault': true});

      await batch.commit();
      debugPrint('AddressService: Dat dia chi [$addressId] lam mac dinh thanh cong');
    } catch (e) {
      debugPrint('AddressService: Loi dat dia chi mac dinh - $e');
      rethrow;
    }
  }

  /// Xoa mot dia chi khoi Firestore.
  Future<void> deleteAddress(String addressId) async {
    try {
      final docRef = _addressCollection().doc(addressId);
      await docRef.delete();
      debugPrint('AddressService: Xoa dia chi [$addressId] thanh cong');
    } catch (e) {
      debugPrint('AddressService: Loi xoa dia chi - $e');
      rethrow;
    }
  }
}
