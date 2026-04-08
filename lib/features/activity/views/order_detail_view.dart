import 'package:flutter/material.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';
import 'package:fe_foodgo_customers/features/order/services/order_service.dart';
import 'package:fe_foodgo_customers/features/checkout/views/checkout_view.dart';
import 'package:fe_foodgo_customers/features/support/views/support_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/driver_chat_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/order_tracking_map_view.dart';

///=============================================================================
/// SECTION: VIEW
///=============================================================================

/// Man hinh chi tiet don hang.
///
/// Hien thi day du thong tin don hang tu Firebase Firestore.
/// Cac hanh dong thay doi theo trang thai don hang.
class OrderDetailView extends StatelessWidget {
  final OrderModel order;

  const OrderDetailView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          context.t('order_detail_title'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            _buildAddressSection(context),
            const SizedBox(height: 12),
            // Phan co dinh: danh sach mon.
            _buildProductListSection(context),
            const SizedBox(height: 12),
            // Phan co dinh: chi tiet thanh toan.
            _buildPaymentDetailSection(context),
            const SizedBox(height: 12),
            // Phan co dinh: phuong thuc thanh toan.
            _buildPaymentMethodSection(context),
            const SizedBox(height: 12),
            // Phan co dinh: nut Tro giup.
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
                    '${context.t('order_id')}: #${order.id} '
                    '${context.t('order_copy')}',
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: Text(context.t('order_copy')),
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

  Widget _buildAddressSection(BuildContext ctx) {
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
            ctx: ctx,
            icon: Icons.store_outlined,
            iconColor: AppColors.primary,
            label: ctx.t('order_from'),
            name: order.storeName,
            detail: order.deliveryAddress,
            phone: '',
          ),
          const SizedBox(height: 12),
          // Duong noi.
          Container(
            margin: const EdgeInsets.only(left: 22),
            child: Row(
              children: [
                Container(width: 2, height: 16, color: AppColors.divider),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 1, color: AppColors.divider)),
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
            ctx: ctx,
            icon: Icons.location_on_outlined,
            iconColor: AppColors.error,
            label: ctx.t('order_to'),
            name: 'Khach hang',
            detail: order.deliveryAddress,
            phone: '',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem({
    required BuildContext ctx,
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
          child: Icon(icon, size: 20, color: iconColor),
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
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductListSection(BuildContext ctx) {
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
            ctx.t('order_items'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          ...order.items.map((item) => _buildProductItem(ctx, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext ctx, OrderItemModel item) {
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
                if (item.options != null && item.options!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ...item.options!.map(
                    (option) => Text(
                      '+ ${option['name'] ?? ''}',
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
            _formatPrice(item.price, ctx),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailSection(BuildContext ctx) {
    final subtotal = order.totalAmount - order.deliveryFee;

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
            ctx: ctx,
            label: ctx.t('order_subtotal'),
            value: _formatPrice(subtotal, ctx),
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            ctx: ctx,
            label: ctx.t('order_delivery_fee'),
            value: _formatPrice(order.deliveryFee, ctx),
            valueColor: AppColors.textPrimary,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ctx.t('order_total'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _formatPrice(order.totalAmount, ctx),
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
    required BuildContext ctx,
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

  Widget _buildPaymentMethodSection(BuildContext ctx) {
    String methodText;
    IconData methodIcon;

    if (order.paymentMethod == 'cash') {
      methodText = ctx.t('order_cash_on_delivery');
      methodIcon = Icons.payments_outlined;
    } else {
      methodText = ctx.t('order_wallet');
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
          Icon(methodIcon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctx.t('order_payment_method'),
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
          debugPrint(
            'OrderDetailView: Nguoi dung bam Tro giup, chuyen sang trang Tro giop voi ma don [${order.id}]',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupportView(orderId: order.id),
            ),
          );
        },
        icon: const Icon(Icons.support_agent_outlined, size: 20),
        label: Text(context.t('order_need_help')),
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
    // Phan loai theo trang thai tu OrderModel
    switch (order.status) {
      case 0:
      case 1:
      case 2:
        // Don hang dang xu ly: hien thi phan tai xe + nut huy
        return _buildDeliveringSection(context);
      case 3:
        // Don hang da hoan thanh: hien thi phan danh gia
        return _buildReceivedSection(context);
      case 4:
        // Don hang da huy: hien thi thong tin huy
        return _buildCancelledSection(context);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Giao dien khi don hang dang xu ly: hien thi thong tin tai xe (neu co) + nut huy.
  Widget _buildDeliveringSection(BuildContext context) {
    final hasDriver = order.hasDriverInfo;

    return Column(
      children: [
        // Khoi thong tin tai xe.
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
                context.t('order_driver_info'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              if (!hasDriver) ...[
                // Khong co thong tin tai xe: hien thi loading
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dang tim tai xe...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Co thong tin tai xe: hien thi day du
                Row(
                  children: [
                    // Avatar tai xe.
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.person,
                        size: 28,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.driverName ?? 'Tai xe',
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
                                order.vehiclePlate ?? '',
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
                                order.driverPhone ?? '',
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
                // Nut Mo ban do va Chat voi tai xe.
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          debugPrint(
                            'OrderDetailView: Mo ban do theo doi tai xe [${order.driverName}]',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderTrackingMapView(
                                orderId: order.id,
                                driverName: order.driverName ?? '',
                                driverPhone: order.driverPhone ?? '',
                                vehiclePlate: order.vehiclePlate ?? '',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: Text(context.t('order_open_map')),
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
                          debugPrint(
                            'OrderDetailView: Chat voi tai xe [${order.driverName}]',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverChatView(
                                chat: DriverChatModel(
                                  driverName: order.driverName ?? '',
                                  vehiclePlate: order.vehiclePlate ?? '',
                                  driverPhone: order.driverPhone ?? '',
                                  driverAvatarUrl: '',
                                  messages: const [],
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(context.t('order_chat_driver')),
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
              debugPrint(
                'OrderDetailView: Nguoi dung bam Huy don [${order.id}]',
              );
              _showCancelDialog(context);
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
              context.t('order_cancel_order'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  /// Hien thi dialog xac nhan huy don hang.
  Future<void> _showCancelDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan huy don'),
        content: Text('Ban co chac chan muon huy don hang ${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Khong'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Co, huy don'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!context.mounted) return;

    // Hien thi loading.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Goi service huy don.
    final success = await OrderService.cancelOrder(order.id);

    // Dong loading.
    if (context.mounted) {
      Navigator.pop(context);

      // Hien thi snackbar thong bao.
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Huy don hang thanh cong'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Dong man hinh chi tiet sau khi huy thanh cong.
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Huy don hang that bai, vui long thu lai'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Giao dien khi don hang da hoan thanh: hien thi phan danh gia + nut dat lai.
  Widget _buildReceivedSection(BuildContext context) {
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
            context.t('order_rating_title'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          // Nut danh gia mon an.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                debugPrint(
                  'OrderDetailView: Nguoi dung bam Danh gia mon an',
                );
              },
              icon: const Icon(Icons.restaurant_outlined, size: 18),
              label: Text(context.t('order_rate_food')),
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
          // Nut danh gia tai xe (neu co thong tin tai xe).
          if (order.hasDriverInfo) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint(
                    'OrderDetailView: Nguoi dung bam Danh gia tai xe',
                  );
                },
                icon: const Icon(Icons.directions_car_outlined, size: 18),
                label: Text(context.t('order_rate_driver')),
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
            const SizedBox(height: 10),
          ],
          // Nut Dat lai don hang.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                debugPrint(
                  'OrderDetailView: Nguoi dung bam Dat lai, chuyen sang Checkout voi ma don [${order.id}]',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutView(initialOrder: order),
                  ),
                );
              },
              icon: const Icon(Icons.replay_outlined, size: 18),
              label: Text(context.t('order_reorder_btn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
    );
  }

  /// Giao dien khi don hang da huy: hien thi thong tin huy + nut dat lai.
  Widget _buildCancelledSection(BuildContext context) {
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
          Icon(Icons.cancel_outlined, size: 40, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            context.t('order_cancelled_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          // Nut Dat lai don hang.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                debugPrint(
                  'OrderDetailView: Nguoi dung bam Dat lai tu man hinh da huy, chuyen sang Checkout voi ma don [${order.id}]',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutView(initialOrder: order),
                  ),
                );
              },
              icon: const Icon(Icons.replay_outlined, size: 18),
              label: Text(context.t('order_reorder_btn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
            debugPrint('OrderDetailView: Nguoi dung bam Dong man hinh chi tiet don hang');
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textSecondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            context.t('btn_close'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  ///=============================================================================
  /// UTILITIES
  ///=============================================================================

  /// Format gia thanh chuoi VND (VD: "85.000 VND").
  String _formatPrice(double price, BuildContext ctx) {
    if (price >= 1000) {
      final formatted = price
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return '$formatted ${ctx.t('unit_currency')}';
    }
    return '${price.toStringAsFixed(0)} ${ctx.t('unit_currency')}';
  }
}
