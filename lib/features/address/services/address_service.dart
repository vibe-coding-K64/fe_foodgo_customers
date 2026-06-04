import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/auth_storage.dart';
import '../models/address_model.dart';

/// Service quan ly dia chi nguoi dung, tuong tac voi API `/api/addresses`.
///
/// Ho tro cac thao tac:
/// - Lay danh sach dia chi (GET /api/addresses)
/// - Tao dia chi moi (POST /api/addresses)
/// - Cap nhat dia chi (PUT /api/addresses/{id})
/// - Dat dia chi lam mac dinh (PUT /api/addresses/{id}/default)
/// - Xoa dia chi (DELETE /api/addresses/{id})
class AddressService {
  const AddressService();

  static const String _basePath = '/addresses';

  /// Lay userId tu AuthStorage, throw neu chua dang nhap.
  String _getUserId() {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('AddressService: Nguoi dung chua dang nhap');
    }
    return userId;
  }

  /// Lay danh sach dia chi cua nguoi dung hien tai.
  ///
  /// GET /api/addresses?userId={userId}
  Future<List<AddressModel>> getAddresses() async {
    try {
      final userId = _getUserId();
      debugPrint('AddressService: Dang lay danh sach dia chi cho user [$userId]');

      final response = await ApiClient.get<Map<String, dynamic>>(
        _basePath,
        queryParameters: {'userId': userId},
      );

      final rawData = response.data;
      final List<dynamic> items = _extractList(rawData);

      final addresses = items
          .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sap xep: mac dinh truoc, khong mac dinh theo sau.
      addresses.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return 0;
      });

      debugPrint('AddressService: Da lay ${addresses.length} dia chi');
      return addresses;
    } on DioException catch (e) {
      debugPrint('AddressService: Loi lay danh sach dia chi - ${e.message}');
      rethrow;
    }
  }

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lay dia chi mac dinh tu Firestore.
  ///
  /// Doc tu collection customer_profiles/{userId}/addresses,
  /// loc document co isDefault = true.
  Future<AddressModel?> getDefaultAddressFromFirestore() async {
    final userId = _getUserId();
    try {
      final snap = await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;
      return AddressModel.fromFirestore(snap.docs.first);
    } catch (e) {
      debugPrint('AddressService: Loi lay dia chi mac dinh tu Firestore - $e');
      return null;
    }
  }

  /// Lay tat ca dia chi tu Firestore.
  ///
  /// Doc tu collection customer_profiles/{userId}/addresses.
  /// Sap xep: dia chi mac dinh truoc.
  Future<List<AddressModel>> getAddressesFromFirestore() async {
    final userId = _getUserId();
    try {
      final snap = await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('addresses')
          .get();

      final addresses = snap.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();

      // Sap xep: mac dinh truoc.
      addresses.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return 0;
      });

      debugPrint('AddressService: Da lay ${addresses.length} dia chi tu Firestore');
      return addresses;
    } catch (e) {
      debugPrint('AddressService: Loi lay dia chi tu Firestore - $e');
      return [];
    }
  }

  /// Luu dia chi moi hoac cap nhat dia chi cu vao Firestore.
  ///
  /// Neu [isDefault] = true, bo isDefault cac dia chi cu trong Firestore.
  Future<AddressModel> saveAddressToFirestore({
    required String name,
    required String address,
    required String receiverName,
    required String receiverPhone,
    double? lat,
    double? lng,
    bool isDefault = false,
    String? existingId,
  }) async {
    final userId = _getUserId();
    try {
      if (isDefault) {
        await _clearDefaultInFirestore(userId);
      }

      final addressRef = existingId != null
          ? _firestore
              .collection('customer_profiles')
              .doc(userId)
              .collection('addresses')
              .doc(existingId)
          : _firestore
              .collection('customer_profiles')
              .doc(userId)
              .collection('addresses')
              .doc();

      final data = {
        'userId': userId,
        'name': name,
        'address': address,
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'lat': lat,
        'lng': lng,
        'isDefault': isDefault,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await addressRef.set(data, SetOptions(merge: true));

      final doc = await addressRef.get();
      final saved = AddressModel.fromFirestore(doc);
      debugPrint('AddressService: Da luu dia chi [${saved.id}] vao Firestore');
      return saved;
    } catch (e) {
      debugPrint('AddressService: Loi luu dia chi vao Firestore - $e');
      rethrow;
    }
  }

  /// Xoa dia chi khoi Firestore.
  Future<void> deleteAddressInFirestore(String addressId) async {
    final userId = _getUserId();
    try {
      await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
      debugPrint('AddressService: Da xoa dia chi [$addressId] khoi Firestore');
    } catch (e) {
      debugPrint('AddressService: Loi xoa dia chi khoi Firestore - $e');
      rethrow;
    }
  }

  /// Bo isDefault tat ca dia chi trong Firestore cho user hien tai.
  Future<void> _clearDefaultInFirestore(String userId) async {
    final snap = await _firestore
        .collection('customer_profiles')
        .doc(userId)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  /// Dat mot dia chi lam mac dinh trong Firestore.
  ///
  /// Bo isDefault cac dia chi cu, dat isDefault = true cho dia chi duoc chon.
  Future<void> setDefaultAddressInFirestore(String addressId) async {
    final userId = _getUserId();
    try {
      await _clearDefaultInFirestore(userId);

      await _firestore
          .collection('customer_profiles')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .update({'isDefault': true});

      debugPrint('AddressService: Da dat dia chi [$addressId] lam mac dinh trong Firestore');
    } catch (e) {
      debugPrint('AddressService: Loi dat dia chi mac dinh trong Firestore - $e');
      rethrow;
    }
  }

  List<dynamic> _extractList(Map<String, dynamic>? data) {
    if (data == null) return [];
    if (data['data'] is List) return data['data'] as List;
    if (data['items'] is List) return data['items'] as List;
    return [];
  }

  /// Tao dia chi moi cho nguoi dung hien tai.
  ///
  /// POST /api/addresses
  ///
  /// Neu [isDefault] = true, backend se tu dong bo mac dinh cac dia chi cu.
  /// Tra ve AddressModel da duoc backend tao (gom id duoc gan).
  Future<AddressModel> createAddress({
    required String name,
    required String address,
    required String receiverName,
    required String receiverPhone,
    double? lat,
    double? lng,
    bool isDefault = false,
  }) async {
    try {
      final userId = _getUserId();
      debugPrint('AddressService: Tao dia chi moi cho user [$userId]');

      final body = {
        'userId': userId,
        'name': name,
        'address': address,
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'lat': lat,
        'lng': lng,
        'isDefault': isDefault,
      };

      final response = await ApiClient.post<Map<String, dynamic>>(
        _basePath,
        data: body,
      );

      if (response.data == null) {
        throw Exception('AddressService: Response data la null khi tao dia chi');
      }

      final data = response.data!;
      if (data['success'] != true) {
        throw Exception('AddressService: Tao dia chi that bai - ${data['message']}');
      }

      final created = AddressModel.fromJson(data['data'] as Map<String, dynamic>);
      debugPrint('AddressService: Da tao dia chi [${created.id}]');
      return created;
    } on DioException catch (e) {
      debugPrint('AddressService: Loi tao dia chi - ${e.message}');
      rethrow;
    }
  }

  /// Cap nhat thong tin dia chi.
  ///
  /// PUT /api/addresses/{id}
  ///
  /// Neu [isDefault] = true, backend se tu dong bo mac dinh cac dia chi cu.
  Future<AddressModel> updateAddress({
    required String addressId,
    required String name,
    required String address,
    required String receiverName,
    required String receiverPhone,
    double? lat,
    double? lng,
    bool? isDefault,
  }) async {
    try {
      final userId = _getUserId();
      debugPrint('AddressService: Cap nhat dia chi [$addressId] cho user [$userId]');

      final body = {
        'userId': userId,
        'name': name,
        'address': address,
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'lat': lat,
        'lng': lng,
        if (isDefault != null) 'isDefault': isDefault,
      };

      final response = await ApiClient.put<Map<String, dynamic>>(
        '$_basePath/$addressId',
        data: body,
      );

      if (response.data == null) {
        throw Exception('AddressService: Response data la null khi cap nhat dia chi');
      }

      final data = response.data!;
      if (data['success'] != true) {
        throw Exception('AddressService: Cap nhat dia chi that bai - ${data['message']}');
      }

      final updated = AddressModel.fromJson(data['data'] as Map<String, dynamic>);
      debugPrint('AddressService: Da cap nhat dia chi [${updated.id}]');
      return updated;
    } on DioException catch (e) {
      debugPrint('AddressService: Loi cap nhat dia chi - ${e.message}');
      rethrow;
    }
  }

  /// Dat mot dia chi lam mac dinh.
  ///
  /// PUT /api/addresses/{id}/default?userId={userId}
  ///
  /// Backend se quet tat ca dia chi cua nguoi dung, bo flag isDefault cua
  /// cac dia chi cu, sau do dat flag isDefault = true cho dia chi duoc yeu cau.
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final userId = _getUserId();
      debugPrint('AddressService: Dat dia chi [$addressId] lam mac dinh');

      final response = await ApiClient.put<Map<String, dynamic>>(
        '$_basePath/$addressId/default',
        queryParameters: {'userId': userId},
      );

      if (response.data == null) {
        throw Exception('AddressService: Response data la null khi dat mac dinh');
      }

      final data = response.data!;
      if (data['success'] != true) {
        throw Exception('AddressService: Dat dia chi mac dinh that bai - ${data['message']}');
      }

      debugPrint('AddressService: Da dat dia chi [$addressId] lam mac dinh thanh cong');
    } on DioException catch (e) {
      debugPrint('AddressService: Loi dat dia chi mac dinh - ${e.message}');
      rethrow;
    }
  }

  /// Xoa mot dia chi.
  ///
  /// DELETE /api/addresses/{id}?userId={userId}
  ///
  /// Phuong thuc nay la idempotent - tra ve thanh cong ke ca khi dia chi
  /// khong ton tai.
  Future<void> deleteAddress(String addressId) async {
    try {
      final userId = _getUserId();
      debugPrint('AddressService: Xoa dia chi [$addressId]');

      final response = await ApiClient.delete<Map<String, dynamic>>(
        '$_basePath/$addressId',
        queryParameters: {'userId': userId},
      );

      if (response.data == null) {
        throw Exception('AddressService: Response data la null khi xoa dia chi');
      }

      final data = response.data!;
      if (data['success'] != true) {
        throw Exception('AddressService: Xoa dia chi that bai - ${data['message']}');
      }

      debugPrint('AddressService: Da xoa dia chi [$addressId] thanh cong');
    } on DioException catch (e) {
      debugPrint('AddressService: Loi xoa dia chi - ${e.message}');
      rethrow;
    }
  }

  /// Lay dia chi mac dinh dau tien.
  ///
  /// Su dung getAddresses() roi loc dia chi co isDefault = true.
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final addresses = await getAddresses();
      return addresses.where((a) => a.isDefault).firstOrNull;
    } catch (e) {
      debugPrint('AddressService: Loi lay dia chi mac dinh - $e');
      return null;
    }
  }

  /// Lay toa do GPS hien tai cua may.
  ///
  /// Tra ve `Position` neu lay thanh cong, `null` neu:
  ///  - Quyen truy cap vi tri bi tu choi
  ///  - Dich vu GPS bi tat
  ///  - Bat ky loi nao khac
  static Future<Position?> getGpsPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('AddressService[GPS]: Dich vu vi tri bi tat');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('AddressService[GPS]: Quyen truy cap vi tri bi tu choi');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('AddressService[GPS]: Quyen truy cap vi tri bi tu choi vinh vien');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      debugPrint(
          'AddressService[GPS]: Lay duoc vi tri - lat=${position.latitude}, lng=${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('AddressService[GPS]: Loi khi lay vi tri - $e');
      return null;
    }
  }

  /// Stream lang nghe dia chi mac dinh cua nguoi dung hien tai.
  ///
  /// Su dung Timer.periodic de poll API moi 5 giay, tra ve dia chi mac dinh.
  /// Tra ve Stream<void> chua du lieu gi, consumer goi lai getDefaultAddress().
  /// Hoac su dung HomeHeaderFuture thay the.
  Stream<AddressModel?> getDefaultAddressStream() {
    return Stream.periodic(const Duration(seconds: 5), (_) => null)
        .asyncMap((_) => getDefaultAddress());
  }
}
