import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_cart_item.dart';

/// Model tuy chon topping (size, topping) cua mon an trong don hang.
///
/// Tuong thich voi response cua API checkout:
///   { "name": "M", "price": 0.0 }
class ToppingOption {
  final String name;
  final double price;

  const ToppingOption({
    required this.name,
    required this.price,
  });

  factory ToppingOption.fromJson(Map<String, dynamic> json) {
    return ToppingOption(
      name: (json['name'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name};
}

/// Model mot mon an trong don hang, tuong thich voi API checkout.
class CheckoutOrderItem {
  final String foodId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  /// Cac options da chon, su dung CheckoutOption (co groupName).
  final List<CheckoutOption> options;
  final String? note;

  const CheckoutOrderItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.options = const [],
    this.note,
  });

  factory CheckoutOrderItem.fromJson(Map<String, dynamic> json) {
    return CheckoutOrderItem(
      foodId: (json['foodId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['imageUrl'] as String?,
      options: (json['selectedOptions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .expand((group) {
                final groupName = (group['name'] as String?) ?? '';
                final opts = (group['options'] as List<dynamic>?)
                        ?.whereType<Map<String, dynamic>>()
                        .map((o) => CheckoutOption(
                              name: (o['name'] as String?) ?? '',
                              price: (o['price'] as num?)?.toDouble() ?? 0.0,
                              groupName: groupName,
                            ))
                        .toList() ??
                    [];
                return opts;
              })
              .toList() ??
          [],
      note: json['note'] as String?,
    );
  }
}

/// Request body gui len API checkout.
///
/// Endpoint: POST /orders/checkout
///
/// Request body:
///   userId, addressId, paymentMethod, storeId, items (danh sach mon da chon),
///   note (order-level), discountVoucherId, shopVoucherId, freeshipVoucherId.
class CheckoutRequest {
  final String userId;
  final String addressId;
  final String paymentMethod;
  final String storeId;
  final List<CheckoutOrderItem> items;
  final String? discountVoucherId;
  final String? shopVoucherId;
  final String? freeshipVoucherId;
  final String? note;

  const CheckoutRequest({
    required this.userId,
    required this.addressId,
    required this.paymentMethod,
    required this.storeId,
    required this.items,
    this.discountVoucherId,
    this.shopVoucherId,
    this.freeshipVoucherId,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      'storeId': storeId,
      'items': items.map((item) {
        // Group options theo groupName de gui len backend
        final grouped = <String, List<Map<String, dynamic>>>{};
        for (final opt in item.options) {
          grouped.putIfAbsent(opt.groupName, () => []).add(opt.toJson());
        }
        final selectedOptions = grouped.entries.map((e) => {
          'name': e.key,
          'options': e.value,
        }).toList();

        return {
          'foodId': item.foodId,
          'name': item.name,
          'quantity': item.quantity,
          'imageUrl': item.imageUrl,
          'selectedOptions': selectedOptions,
          if (item.note != null && item.note!.isNotEmpty) 'note': item.note,
        };
      }).toList(),
      if (discountVoucherId != null && discountVoucherId!.isNotEmpty)
        'discountVoucherId': discountVoucherId,
      if (shopVoucherId != null && shopVoucherId!.isNotEmpty)
        'shopVoucherId': shopVoucherId,
      if (freeshipVoucherId != null && freeshipVoucherId!.isNotEmpty)
        'freeshipVoucherId': freeshipVoucherId,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}

/// Response tra ve tu API checkout thanh cong.
class CheckoutResponse {
  final String orderId;
  final String orderCode;
  final String storeId;
  final String storeName;
  final String userId;
  final List<CheckoutOrderItem> items;
  final double totalAmount;
  final double deliveryFee;
  final double discountAmount;
  final double finalAmount;
  final String paymentMethod;
  final String deliveryAddress;
  final int status;
  final String createdAt;
  final String? note;

  const CheckoutResponse({
    required this.orderId,
    required this.orderCode,
    required this.storeId,
    required this.storeName,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.deliveryFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
    this.note,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: (json['orderId'] as String?) ?? '',
      orderCode: (json['orderCode'] as String?) ?? '',
      storeId: (json['storeId'] as String?) ?? '',
      storeName: (json['storeName'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => CheckoutOrderItem.fromJson(e))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: (json['paymentMethod'] as String?) ?? '',
      deliveryAddress: (json['deliveryAddress'] as String?) ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] as String?) ?? '',
      note: json['note'] as String?,
    );
  }
}

/// Loi tra ve tu API checkout that bai.
class CheckoutError {
  final bool success;
  final int code;
  final String message;

  const CheckoutError({
    required this.success,
    required this.code,
    required this.message,
  });

  factory CheckoutError.fromJson(Map<String, dynamic> json) {
    return CheckoutError(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as num?)?.toInt() ?? 0,
      message: (json['message'] as String?) ?? '',
    );
  }
}
