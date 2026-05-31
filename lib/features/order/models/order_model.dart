import 'package:cloud_firestore/cloud_firestore.dart';

/// Model tuy chon topping (size, topping) cua mon an.
///
/// Tuong thich voi Firestore va API checkout.
class ToppingOption {
  final String name;
  final double price;

  const ToppingOption({
    required this.name,
    required this.price,
  });

  factory ToppingOption.fromMap(Map<String, dynamic> map) {
    return ToppingOption(
      name: (map['name'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'price': price};
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
      options: (map['options'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map((e) => ToppingOption.fromMap(e))
          .toList(),
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
  final String? storeAvatar;

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
    this.storeAvatar,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    List<OrderItemModel> parsedItems = [];
    final itemsData = data['items'];
    if (itemsData is List) {
      parsedItems = itemsData
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderItemModel.fromMap(e))
          .toList();
    }

    return OrderModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      storeId: (data['storeId'] as String?) ?? '',
      storeName: (data['storeName'] as String?) ?? '',
      items: parsedItems,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (data['finalAmount'] as num?)?.toDouble() ?? 0.0,
      status: (data['status'] as num?)?.toInt() ?? 0,
      deliveryAddress: (data['deliveryAddress'] as String?) ?? '',
      paymentMethod: (data['paymentMethod'] as String?) ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      note: data['note'] as String?,
      orderCode: data['orderCode'] as String?,
      driverId: data['driverId'] as String?,
      driverName: data['driverName'] as String?,
      driverPhone: data['driverPhone'] as String?,
      vehiclePlate: data['vehiclePlate'] as String?,
      storeAvatar: data['storeAvatar'] as String?,
    );
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

  bool get isActive => status == 0 || status == 1 || status == 2;
  bool get isCompleted => status == 3;
  bool get isCancelled => status == 4;

  OrderModel copyWith({String? storeAvatar}) {
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
      driverId: driverId,
      driverName: driverName,
      driverPhone: driverPhone,
      vehiclePlate: vehiclePlate,
      storeAvatar: storeAvatar ?? this.storeAvatar,
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
