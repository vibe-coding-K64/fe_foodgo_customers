import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';

///=============================================================================
/// SECTION: MODELS
///=============================================================================

/// Model topping cua mot mon an.
class OrderToppingModel {
  final String name;
  final double price;

  const OrderToppingModel({
    required this.name,
    required this.price,
  });
}

/// Model mot mon an trong don hang.
class OrderItemModel {
  final String name;
  final int quantity;
  final double unitPrice;
  final List<OrderToppingModel> toppings;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.toppings = const [],
  });

  double get totalPrice {
    final toppingTotal = toppings.fold<double>(
      0,
      (sum, topping) => sum + topping.price,
    );
    return (unitPrice + toppingTotal) * quantity;
  }
}

/// Model thong tin tai xe.
class DriverInfoModel {
  final String name;
  final String phone;
  final String avatarUrl;
  final String vehiclePlate;

  const DriverInfoModel({
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.vehiclePlate,
  });
}

/// Model don hang day du cho trang chi tiet.
class OrderDetailModel {
  final String id;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double voucherDiscount;
  final double total;
  final String paymentMethod; // "cash", "wallet"
  final DateTime orderDate;
  final OrderDetailStatus status;
  final DriverInfoModel? driverInfo;
  final String? cancelReason;

  const OrderDetailModel({
    required this.id,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.voucherDiscount,
    required this.total,
    required this.paymentMethod,
    required this.orderDate,
    required this.status,
    this.driverInfo,
    this.cancelReason,
  });
}

/// Trang thai cua don hang trong trang chi tiet.
enum OrderDetailStatus {
  delivering,  // Dang giao.
  received,    // Da hoan thanh.
  cancelled,   // Da huy.
}

///=============================================================================
/// SECTION: VIEW
///=============================================================================

/// Man hinh chi tiet don hang.
///
/// Hien thi day du thong tin don hang cung cac hanh dong theo trang thai.
/// Phan giao dien dong (driver section, rating, huy don) thay doi theo status.
class OrderDetailView extends StatelessWidget {
  final OrderDetailModel order;

  const OrderDetailView({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          LanguageService.translate('order_detail_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Phan co dinh: ma don hang.
            _buildOrderIdSection(context),
            const SizedBox(height: 12),
            // Phan co dinh: dia chi (Tu -> Den).
            _buildAddressSection(),
            const SizedBox(height: 12),
            // Phan co dinh: danh sach mon.
            _buildProductListSection(),
            const SizedBox(height: 12),
            // Phan co dinh: chi tiet thanh toan.
            _buildPaymentDetailSection(),
            const SizedBox(height: 12),
            // Phan co dinh: phuong thuc thanh toan.
            _buildPaymentMethodSection(),
            const SizedBox(height: 12),
            // Phan dong: nut Tro giup.
            _buildHelpSection(context),
            const SizedBox(height: 12),
            // Phan giao dien dong theo trang thai.
            _buildDynamicSection(context),
            // Khoang trong cuoi de tranh bi遮 boi bottom bar.
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  ///=============================================================================
  /// PHAN CO DINH
  ///=============================================================================

  Widget _buildOrderIdSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Text(
            '#${order.id}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              debugPrint('OrderDetailView: Sao chep ma don hang [${order.id}]');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${LanguageService.translate('order_id')}: #${order.id} '
                    '${LanguageService.translate('order_copy')}',
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: Text(LanguageService.translate('order_copy')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Tu: Thong tin cua hang.
          _buildAddressItem(
            icon: Icons.store_outlined,
            iconColor: AppColors.primary,
            label: LanguageService.translate('order_from'),
            name: order.storeName,
            detail: order.storeAddress,
            phone: order.storePhone,
          ),
          const SizedBox(height: 12),
          // Duong noi.
          Container(
            margin: const EdgeInsets.only(left: 22),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 16,
                  color: AppColors.divider,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.divider,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.local_shipping_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Den: Dia chi giao hang cua khach.
          _buildAddressItem(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.error,
            label: LanguageService.translate('order_to'),
            name: order.customerName,
            detail: order.deliveryAddress,
            phone: order.customerPhone,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String name,
    required String detail,
    required String phone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductListSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.translate('order_items'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          ...order.items.map((item) => _buildProductItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // So luong.
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                item.quantity.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Ten mon va topping.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.toppings.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ...item.toppings.map(
                    (topping) => Text(
                      '+ ${topping.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Don gia.
          Text(
            _formatPrice(item.unitPrice),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildPaymentRow(
            label: LanguageService.translate('order_subtotal'),
            value: _formatPrice(order.subtotal),
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            label: LanguageService.translate('order_delivery_fee'),
            value: _formatPrice(order.deliveryFee),
            valueColor: AppColors.textPrimary,
          ),
          if (order.voucherDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildPaymentRow(
              label: LanguageService.translate('order_voucher_discount'),
              value: '- ${_formatPrice(order.voucherDiscount)}',
              valueColor: AppColors.error,
              isDiscount: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LanguageService.translate('order_total'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _formatPrice(order.total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String value,
    required Color valueColor,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: isDiscount ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
            decoration: isDiscount ? TextDecoration.none : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    String methodText;
    IconData methodIcon;

    if (order.paymentMethod == 'cash') {
      methodText = LanguageService.translate('order_cash_on_delivery');
      methodIcon = Icons.payments_outlined;
    } else {
      methodText = LanguageService.translate('order_wallet');
      methodIcon = Icons.account_balance_wallet_outlined;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            methodIcon,
            size: 22,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.translate('order_payment_method'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  methodText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () {
          debugPrint('OrderDetailView: Nguoi dung bam Tro giup, chuyen sang trang Tro giup');
          // Navigator.push(context, MaterialPageRoute(...));
        },
        icon: const Icon(Icons.support_agent_outlined, size: 20),
        label: Text(LanguageService.translate('order_need_help')),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.divider),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  ///=============================================================================
  /// PHAN GIAO DIEN DONG
  ///=============================================================================

  Widget _buildDynamicSection(BuildContext context) {
    switch (order.status) {
      case OrderDetailStatus.delivering:
        return _buildDeliveringSection(context);
      case OrderDetailStatus.received:
        return _buildReceivedSection(context);
      case OrderDetailStatus.cancelled:
        return _buildCancelledSection();
    }
  }

  /// Giao diện khi đang giao: khối tài xế đầy đủ + nút Map/Chat + Hủy đơn.
  Widget _buildDeliveringSection(BuildContext context) {
    final driver = order.driverInfo;
    if (driver == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Khối thông tin tài xế.
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageService.translate('order_driver_info'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // Avatar tài xế.
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: NetworkImage(driver.avatarUrl),
                    onBackgroundImageError: (_, __) {},
                    child: driver.avatarUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 28,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              driver.vehiclePlate,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              driver.phone,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Nút Mo ban do va Chat voi tai xe.
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        debugPrint('OrderDetailView: Mo ban do cho tai xe [${driver.name}]');
                      },
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(LanguageService.translate('order_open_map')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        debugPrint('OrderDetailView: Chat voi tai xe [${driver.name}]');
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: Text(LanguageService.translate('order_chat_driver')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Nut Huy don.
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton(
            onPressed: () {
              debugPrint('OrderDetailView: Nguoi dung bam Huy don [${order.id}]');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              LanguageService.translate('order_cancel_order'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Giao diện khi đã hoàn thành: khối tài xế ẩn SĐT/nút + 2 nút đánh giá.
  Widget _buildReceivedSection(BuildContext context) {
    final driver = order.driverInfo;

    return Column(
      children: [
        if (driver != null) ...[
          // Khối tài xế rút gọn (chỉ Avatar + Tên).
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: driver.avatarUrl.isNotEmpty
                      ? NetworkImage(driver.avatarUrl)
                      : null,
                  onBackgroundImageError: (_, __) {},
                  child: driver.avatarUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 26,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Khối 2 nút đánh giá.
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageService.translate('order_rating_title'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              // Nút đánh giá món ăn.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    debugPrint('OrderDetailView: Nguoi dung bam Danh gia mon an');
                  },
                  icon: const Icon(Icons.restaurant_outlined, size: 18),
                  label: Text(LanguageService.translate('order_rate_food')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Nút đánh giá tài xế.
              if (driver != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('OrderDetailView: Nguoi dung bam Danh gia tai xe');
                    },
                    icon: const Icon(Icons.directions_car_outlined, size: 18),
                    label: Text(LanguageService.translate('order_rate_driver')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Giao diện khi đã hủy: dòng text đỏ nổi bật + lý do hủy.
  Widget _buildCancelledSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cancel_outlined,
            size: 40,
            color: AppColors.error,
          ),
          const SizedBox(height: 8),
          Text(
            LanguageService.translate('order_cancelled_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          if (order.cancelReason != null && order.cancelReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${LanguageService.translate('order_cancel_reason')}: ${order.cancelReason}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  ///=============================================================================
  /// THANH DAM DAY
  ///=============================================================================

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            debugPrint('OrderDetailView: Nguoi dung bam Huy don [${order.id}]');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LanguageService.translate('order_cancel_order')),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            LanguageService.translate('order_cancel_order'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  ///=============================================================================
  /// UTILITIES
  ///=============================================================================

  /// Format gia thanh chuoi VND (VD: "85.000 VND").
  String _formatPrice(double price) {
    if (price >= 1000) {
      final formatted = price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return '$formatted ${LanguageService.translate('unit_currency')}';
    }
    return '${price.toStringAsFixed(0)} ${LanguageService.translate('unit_currency')}';
  }
}

///=============================================================================
/// SECTION: MOCK DATA
///=============================================================================

/// Mock data 1: Trang thai DANG GIAO (tai xe dang giao).
final mockOrderDelivering = OrderDetailModel(
  id: 'ORD-123456',
  storeName: 'Com Tam Oi Den',
  storeAddress: '123 Nguyen Hue, Quan 1, TP.HCM',
  storePhone: '028 1234 5678',
  customerName: 'Nguyen Van A',
  customerPhone: '090 123 4567',
  deliveryAddress: '456 Le Dai Hanh, Quan 11, TP.HCM',
  items: const [
    OrderItemModel(
      name: 'Com tam bi cha',
      quantity: 2,
      unitPrice: 35000,
      toppings: [
        OrderToppingModel(name: 'Trung cut', price: 5000),
        OrderToppingModel(name: 'Dua chuot', price: 3000),
      ],
    ),
    OrderItemModel(
      name: 'Tra sua tran chau',
      quantity: 1,
      unitPrice: 28000,
      toppings: [
        OrderToppingModel(name: 'Tran chau den', price: 5000),
      ],
    ),
  ],
  subtotal: 113000,
  deliveryFee: 15000,
  voucherDiscount: 10000,
  total: 118000,
  paymentMethod: 'cash',
  orderDate: DateTime.now().subtract(const Duration(hours: 3)),
  status: OrderDetailStatus.delivering,
  driverInfo: const DriverInfoModel(
    name: 'Le Van B',
    phone: '091 234 5678',
    avatarUrl: '',
    vehiclePlate: '59A-123.45',
  ),
);

/// Mock data 2: Trang thai DA HOAN THANH (da nhan hang).
final mockOrderReceived = OrderDetailModel(
  id: 'ORD-789012',
  storeName: 'Bun Bo Hue Ba Trieu',
  storeAddress: '88 Ba Trieu, Quan 5, TP.HCM',
  storePhone: '028 2345 6789',
  customerName: 'Tran Thi C',
  customerPhone: '093 456 7890',
  deliveryAddress: '22 Hoang Van Thu, Quan Phu Nhuan, TP.HCM',
  items: const [
    OrderItemModel(
      name: 'Bun bo hue lon',
      quantity: 1,
      unitPrice: 50000,
      toppings: [
        OrderToppingModel(name: 'Vit', price: 15000),
      ],
    ),
    OrderItemModel(
      name: 'Nem chua ran',
      quantity: 1,
      unitPrice: 25000,
      toppings: [],
    ),
  ],
  subtotal: 90000,
  deliveryFee: 20000,
  voucherDiscount: 0,
  total: 110000,
  paymentMethod: 'wallet',
  orderDate: DateTime.now().subtract(const Duration(days: 2)),
  status: OrderDetailStatus.received,
  driverInfo: const DriverInfoModel(
    name: 'Pham Van D',
    phone: '097 345 6789',
    avatarUrl: '',
    vehiclePlate: '58B-234.56',
  ),
);

/// Mock data 3: Trang thai DA HUY (da huy don).
final mockOrderCancelled = OrderDetailModel(
  id: 'ORD-345678',
  storeName: 'Lau De Nha Hang Song Than',
  storeAddress: '999 Dien Bien Phu, Quan 3, TP.HCM',
  storePhone: '028 3456 7890',
  customerName: 'Ho Van E',
  customerPhone: '095 567 8901',
  deliveryAddress: '12 Nguyen Van Qua, Quan 3, TP.HCM',
  items: const [
    OrderItemModel(
      name: 'Lau de 4 nguoi',
      quantity: 1,
      unitPrice: 350000,
      toppings: [],
    ),
  ],
  subtotal: 350000,
  deliveryFee: 30000,
  voucherDiscount: 50000,
  total: 330000,
  paymentMethod: 'cash',
  orderDate: DateTime.now().subtract(const Duration(days: 7)),
  status: OrderDetailStatus.cancelled,
  cancelReason: 'Khong co nguoi nhan duoc hang',
);
