import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model tuy chon topping (size, topping) cua mon an.
///
/// Tuong thich voi Firestore va API checkout.
///
/// - [groupName] : Nhom tuy chon, VD: "Kich thuoc", "Topping"
/// - [name]      : Gia tri tuy chon, VD: "M", "Trân châu"
/// - [price]     : Gia tri them cua tuy chon
class ToppingOption {
  final String groupName;
  final String name;
  final double price;

  const ToppingOption({
    this.groupName = '',
    required this.name,
    required this.price,
  });

  factory ToppingOption.fromMap(Map<String, dynamic> map) {
    return ToppingOption(
      groupName: (map['groupName'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {'groupName': groupName, 'name': name, 'price': price};
}

/// Model mon an trong don hang.
class OrderItemModel {
  final String foodId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final List<ToppingOption>? options;

  OrderItemModel({
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.options,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      foodId: (map['foodId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: map['imageUrl'] as String?,
      options: (map['options'] is List)
          ? (map['options'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map((e) => ToppingOption.fromMap(e))
              .toList()
          : null,
    );
  }
}

/// Model don hang, dong bo tu Firebase Firestore.
///
/// Cac truong tu Firestore collection `orders`:
/// - id              : ID document
/// - userId          : ID nguoi dat hang
/// - storeId         : ID cua hang
/// - storeName       : Ten cua hang
/// - items           : Danh sach mon an
/// - totalAmount     : Tong tien hang (chua tinh ship/giam gia)
/// - deliveryFee     : Phi giao hang
/// - discountAmount  : So tien duoc giam (voucher)
/// - finalAmount     : Tong so tien phai thanh toan
/// - status          : Trang thai don hang (int: 0-4)
/// - deliveryAddress : Dia chi giao hang
/// - paymentMethod   : Phuong thuc thanh toan
/// - createdAt       : Thoi diem tao don
/// - note            : Ghi chu cho don hang
/// - orderCode       : Ma don hang (6 ky tu)
///
/// Cac truong driver (co the null):
/// - driverId, driverName, driverPhone, vehiclePlate
///
/// Cac truong address (tu address sub-collection):
/// - addressId, addressName, deliveryLat, deliveryLng
/// - receiverName, receiverPhone
class OrderModel {
  final String id;
  final String userId;
  final String storeId;
  final String storeName;
  final List<OrderItemModel> items;
  final double totalAmount;
  final double deliveryFee;
  final double discountAmount;
  final double finalAmount;
  final int status;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final String? note;
  final String? orderCode;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;
  final double? driverLat;
  final double? driverLng;
  final String? storeAvatar;
  final String? storeAddress;
  final double? storeLat;
  final double? storeLng;
  final String? userAvatar;
  final String? addressId;
  final String? addressName;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? receiverName;
  final String? receiverPhone;
  final DateTime? deletedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.totalAmount,
    required this.deliveryFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.note,
    this.orderCode,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.driverLat,
    this.driverLng,
    this.storeAvatar,
    this.storeAddress,
    this.storeLat,
    this.storeLng,
    this.userAvatar,
    this.addressId,
    this.addressName,
        this.deliveryLat,
        this.deliveryLng,
    this.receiverName,
    this.receiverPhone,
    this.deletedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};

      // Parse items — ho tro ca String (JSON) va List.
      List<OrderItemModel> parsedItems = [];
      try {
        final itemsData = data['items'];
        if (itemsData is List) {
          parsedItems = itemsData
              .whereType<Map<String, dynamic>>()
              .map((e) => OrderItemModel.fromMap(e))
              .toList();
        } else if (itemsData is String && itemsData.isNotEmpty) {
          try {
            final decoded = jsonDecode(itemsData);
            if (decoded is List) {
              parsedItems = (decoded as List)
                  .whereType<Map<String, dynamic>>()
                  .map((e) => OrderItemModel.fromMap(e))
                  .toList();
            }
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('OrderModel.fromFirestore: Loi parse items: $e');
        parsedItems = [];
      }

      // Parse don gian cac truong con lai, bat buoc.
      String userId = '';
      String storeId = '';
      String storeName = '';
      try {
        userId = (data['userId'] as String?) ?? '';
        storeId = (data['storeId'] as String?) ?? '';
        storeName = (data['storeName'] as String?) ?? '';
      } catch (e) {
        debugPrint('OrderModel.fromFirestore: Loi parse ids [$userId/$storeId]: $e');
      }

      double totalAmount = 0.0;
      double deliveryFee = 0.0;
      double discountAmount = 0.0;
      double finalAmount = 0.0;
      try {
        totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
        discountAmount = (data['discountAmount'] as num?)?.toDouble() ?? 0.0;
        finalAmount = (data['finalAmount'] as num?)?.toDouble() ?? 0.0;
      } catch (e) {
        debugPrint('OrderModel.fromFirestore: Loi parse amount [$totalAmount/$deliveryFee/$finalAmount]: $e');
      }

      int status = 0;
      try {
        status = (data['status'] as num?)?.toInt() ?? 0;
      } catch (e) {
        debugPrint('OrderModel.fromFirestore: Loi parse status: $e');
      }

      return OrderModel(
        id: doc.id,
        userId: userId,
        storeId: storeId,
        storeName: storeName,
        items: parsedItems,
        totalAmount: totalAmount,
        deliveryFee: deliveryFee,
        discountAmount: discountAmount,
        finalAmount: finalAmount,
        status: status,
        deliveryAddress: _parseString(data['deliveryAddress']),
        paymentMethod: _parseString(data['paymentMethod']),
        createdAt: _parseDateTime(data['createdAt']),
        note: _parseStringNullable(data['note']),
        orderCode: _parseStringNullable(data['orderCode']),
        driverId: _parseStringNullable(data['driverId']),
        driverName: _parseStringNullable(data['driverName']),
        driverPhone: _parseStringNullable(data['driverPhone']),
        vehiclePlate: _parseStringNullable(data['vehiclePlate']),
        driverLat: (data['driverLat'] as num?)?.toDouble(),
        driverLng: (data['driverLng'] as num?)?.toDouble(),
        storeAvatar: _parseStringNullable(data['storeAvatar']),
        storeAddress: _parseStringNullable(data['storeAddress']),
        storeLat: (data['storeLat'] as num?)?.toDouble(),
        storeLng: (data['storeLng'] as num?)?.toDouble(),
        userAvatar: _parseStringNullable(data['userAvatar']),
        addressId: _parseStringNullable(data['addressId']),
        addressName: _parseStringNullable(data['addressName']),
        deliveryLat: (data['deliveryLat'] as num?)?.toDouble(),
        deliveryLng: (data['deliveryLng'] as num?)?.toDouble(),
        receiverName: _parseStringNullable(data['receiverName']),
        receiverPhone: _parseStringNullable(data['receiverPhone']),
        deletedAt: _parseDateTime(data['deletedAt']),
      );
    } catch (e, stack) {
      debugPrint('OrderModel.fromFirestore ERROR doc[${doc.id}]: $e\n$stack');
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Parse string tu bat ky kieu nao (String, int, double...).
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  /// Parse string cho phep null.
  static String? _parseStringNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  bool get isActive => status == 0 || status == 1 || status == 2;
  bool get isCompleted => status == 3;
  bool get isCancelled => status == 4;

  OrderModel copyWith({
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? vehiclePlate,
    double? driverLat,
    double? driverLng,
    String? storeAvatar,
    String? storeAddress,
    double? storeLat,
    double? storeLng,
    String? userAvatar,
    String? addressId,
    String? addressName,
    double? deliveryLat,
    double? deliveryLng,
    String? receiverName,
    String? receiverPhone,
    DateTime? deletedAt,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      storeId: storeId,
      storeName: storeName,
      items: items,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      status: status,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      note: note,
      orderCode: orderCode,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      storeAvatar: storeAvatar ?? this.storeAvatar,
      storeAddress: storeAddress ?? this.storeAddress,
      storeLat: storeLat ?? this.storeLat,
      storeLng: storeLng ?? this.storeLng,
      userAvatar: userAvatar ?? this.userAvatar,
      addressId: addressId ?? this.addressId,
      addressName: addressName ?? this.addressName,
      deliveryLat: deliveryLat ?? this.deliveryLat,
      deliveryLng: deliveryLng ?? this.deliveryLng,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String? get mainItemName => items.isNotEmpty ? items.first.name : null;

  bool get hasDriverInfo =>
      driverName != null &&
      driverName!.isNotEmpty &&
      driverId != null &&
      driverId!.isNotEmpty;

  String get statusTextKey {
    switch (status) {
      case 0:
        return 'status_pending';
      case 1:
        return 'status_preparing';
      case 2:
        return 'status_delivering';
      case 3:
        return 'status_completed';
      case 4:
        return 'status_cancelled';
      default:
        return 'status_pending';
    }
  }
}

/// Response tra ve tu API huy don hang.
class CancelOrderResponse {
  final bool success;
  final String message;
  final CancelOrderData? data;

  CancelOrderResponse({required this.success, required this.message, this.data});

  factory CancelOrderResponse.fromJson(Map<String, dynamic> json) {
    return CancelOrderResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? CancelOrderData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CancelOrderData {
  final String id;
  final int status;
  final DateTime updatedAt;

  CancelOrderData({required this.id, required this.status, required this.updatedAt});

  factory CancelOrderData.fromJson(Map<String, dynamic> json) {
    return CancelOrderData(
      id: json['id'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 4,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
