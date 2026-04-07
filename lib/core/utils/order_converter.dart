import '../../features/activity/views/widgets/activity_order_card.dart';
import '../../features/activity/views/order_detail_view.dart';
import '../localization/language_service.dart';

/// Chuyen doi [OrderModel] (tu activity_order_card) thanh [OrderDetailModel]
/// de su dung cho trang chi tiet don hang.
///
/// Cac truong con thieu (storeAddress, customerPhone, items, ...) duoc
/// dien vao bang mock data tam thoi. Se duoc thay the boi API thuc te.
OrderDetailModel orderModelToDetail(OrderModel order) {
  return OrderDetailModel(
    id: order.id,
    storeName: order.storeName,
    storeAddress: '123 Nguyen Hue, Quan 1, TP.HCM',
    storePhone: '028 1234 5678',
    customerName: 'Nguyen Van A',
    customerPhone: '090 123 4567',
    deliveryAddress: '456 Le Dai Hanh, Quan 11, TP.HCM',
    items: [
      OrderItemModel(
        name: order.mainItem,
        quantity: order.itemCount,
        unitPrice: order.totalPrice / order.itemCount,
        toppings: const [],
      ),
    ],
    subtotal: order.totalPrice * 0.85,
    deliveryFee: 15000,
    voucherDiscount: 0,
    total: order.totalPrice,
    paymentMethod: 'cash',
    orderDate: order.orderDate,
    status: _mapStatus(order.status),
    driverInfo: order.status == OrderStatus.ordered
        ? const DriverInfoModel(
            name: 'Le Van B',
            phone: '091 234 5678',
            avatarUrl: '',
            vehiclePlate: '59A-123.45',
          )
        : null,
    cancelReason: order.status == OrderStatus.cancelled
        ? LanguageService.translate('order_cancel_reason_default')
        : null,
  );
}

/// Map [OrderStatus] (tu activity_order_card) sang [OrderDetailStatus].
OrderDetailStatus _mapStatus(OrderStatus status) {
  switch (status) {
    case OrderStatus.ordered:
      return OrderDetailStatus.delivering;
    case OrderStatus.received:
      return OrderDetailStatus.received;
    case OrderStatus.cancelled:
      return OrderDetailStatus.cancelled;
  }
}
