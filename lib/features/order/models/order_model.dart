import 'package:cloud_firestore/cloud_firestore.dart';

/// Model don hang, dong bo tu Firebase Firestore.
///
/// Cac truong tu Firestore collection `orders`:
/// - id             : ID document
/// - userId         : ID nguoi dat hang
/// - storeId        : ID cua hang
/// - storeName      : Ten cua hang
/// - items          : Danh sach mon an (List dynamic)
/// - totalAmount    : Tong tien (double)
/// - deliveryFee    : Phi giao hang (double)
/// - status         : Trang thai don hang (int: 0-4)
/// - deliveryAddress: Dia chi giao hang
/// - paymentMethod  : Phuong thuc thanh toan
/// - createdAt      : Thoi diem tao don
/// - driverId       : ID tai xe (co the null)
/// - driverName     : Ten tai xe (co the null)
/// - driverPhone    : SDT tai xe (co the null)
/// - vehiclePlate   : Bien so xe (co the null)
class OrderModel {
  final String id;
  final String userId;
  final String storeId;
  final String storeName;
  final List<OrderItemModel> items;
  final double totalAmount;
  final double deliveryFee;
  final int status;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;

  OrderModel({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.totalAmount,
    required this.deliveryFee,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
  });

  /// Tao OrderModel tu DocumentSnapshot cua Firestore.
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse items tu List<dynamic> sang List<OrderItemModel>
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
      status: (data['status'] as num?)?.toInt() ?? 0,
      deliveryAddress: (data['deliveryAddress'] as String?) ?? '',
      paymentMethod: (data['paymentMethod'] as String?) ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      driverId: data['driverId'] as String?,
      driverName: data['driverName'] as String?,
      driverPhone: data['driverPhone'] as String?,
      vehiclePlate: data['vehiclePlate'] as String?,
    );
  }

  /// Parse ngay thang an toan tu Firestore.
  /// Ho tro Timestamp, String, hoac null.
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Tra ve true neu don hang dang o trang thai dang xu ly (0, 1, 2).
  bool get isActive => status == 0 || status == 1 || status == 2;

  /// Tra ve true neu don hang da hoan thanh (status == 3).
  bool get isCompleted => status == 3;

  /// Tra ve true neu don hang da bi huy (status == 4).
  bool get isCancelled => status == 4;

  /// Tra ve so luong mon an.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Tra ve ten mon chinh (mon dau tien).
  String? get mainItemName => items.isNotEmpty ? items.first.name : null;

  /// Tra ve true neu co thong tin tai xe.
  bool get hasDriverInfo =>
      driverName != null &&
      driverName!.isNotEmpty &&
      driverId != null &&
      driverId!.isNotEmpty;
}

/// Model mon an trong don hang.
///
/// Cac truong tu Firestore:
/// - foodId     : ID mon an
/// - name       : Ten mon an
/// - price      : Don gia
/// - quantity   : So luong
/// - imageUrl   : Duong dan anh (co the null)
/// - options    : Lua chon them (co the null)
class OrderItemModel {
  final String foodId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final List<Map<String, dynamic>>? options;

  OrderItemModel({
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.options,
  });

  /// Tao OrderItemModel tu Map (doc tu Firestore).
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      foodId: (map['foodId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: map['imageUrl'] as String?,
      options: (map['options'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .toList(),
    );
  }
}
