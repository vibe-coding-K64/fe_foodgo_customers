import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/core/utils/snackbar_helper.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';
import 'package:fe_foodgo_customers/features/order/services/order_service.dart';
import 'package:fe_foodgo_customers/features/checkout/views/checkout_view.dart';
import 'package:fe_foodgo_customers/features/support/views/support_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/driver_chat_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/order_tracking_map_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/food_review_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/widgets/cancel_order_dialog.dart';

///=============================================================================
/// SECTION: VIEW
///=============================================================================

/// Buoc trong tracker trang thai don hang.
class _TrackerStep {
  final IconData icon;
  final String label;
  final int status;

  const _TrackerStep({
    required this.icon,
    required this.label,
    required this.status,
  });
}

/// Man hinh chi tiet don hang.
///
/// Hien thi day du thong tin don hang tu Firebase Firestore.
/// Doc real-time tu Firestore, dong thoi join du lieu tu address va stores.
/// Cac hanh dong thay doi theo trang thai don hang.
class OrderDetailView extends StatefulWidget {
  final String orderId;

  const OrderDetailView({super.key, required this.orderId});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  OrderModel? _order;
  bool _loading = true;
  StreamSubscription<OrderModel?>? _orderSubscription;

  @override
  void initState() {
    super.initState();
    _orderSubscription = OrderService.getOrderByIdStream(widget.orderId)
        .listen((order) {
      if (mounted) {
        setState(() {
          _order = order;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            context.t('order_detail_title'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            context.t('order_detail_title'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(context.t('order_not_found'), style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final order = _order!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          context.t('order_detail_title'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildStatusTracker(context, order),
            const SizedBox(height: 12),
            _buildOrderIdSection(context, order),
            const SizedBox(height: 12),
            _buildAddressSection(context, order),
            const SizedBox(height: 12),
            _buildOrderNoteSection(context, order),
            const SizedBox(height: 12),
            _buildProductListSection(context, order),
            const SizedBox(height: 12),
            _buildPaymentDetailSection(context, order),
            const SizedBox(height: 12),
            _buildPaymentMethodSection(context, order),
            const SizedBox(height: 12),
            _buildHelpSection(context, order),
            const SizedBox(height: 12),
            _buildDynamicSection(context, order),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, order),
    );
  }

  ///=============================================================================
  /// PHAN CO DINH
  ///=============================================================================

  Widget _buildOrderIdSection(BuildContext context, OrderModel order) {
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
              showAppToast(
                context,
                message: '${context.t('order_id')}: #${order.id} '
                    '${context.t('order_copy')}',
                type: AppToastType.success,
                duration: const Duration(seconds: 1),
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

  /// Widget hien thi tracker trang thai don hang.
  ///
  /// Hien thi 4 buoc: Xac nhan -> Chuan bi -> Dang giao -> Hoan thanh
  /// Buoc hien tai duoc to mau, cac buoc truoc da xong se to cham,
  /// buoc sau chua den se mo.
  Widget _buildStatusTracker(BuildContext context, OrderModel order) {
    final int currentStatus = order.status;

    // Cac buoc tracker: xac nhan(0), chuan bi(1), dang giao(2), hoan thanh(3).
    // Huy(4) la trang thai dac biet, hien thi o _buildCancelledSection.
    final List<_TrackerStep> steps = [
      _TrackerStep(
        icon: Icons.check_circle_outline,
        label: context.t('status_pending'),
        status: 0,
      ),
      _TrackerStep(
        icon: Icons.restaurant_outlined,
        label: context.t('status_preparing'),
        status: 1,
      ),
      _TrackerStep(
        icon: Icons.delivery_dining,
        label: context.t('status_delivering'),
        status: 2,
      ),
      _TrackerStep(
        icon: Icons.done_all,
        label: context.t('status_completed'),
        status: 3,
      ),
    ];

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
            context.t('order_status_title'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          _buildStatusLabel(context, currentStatus),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Duong noi giua cac buoc.
                final stepIndex = index ~/ 2;
                final isFilled = currentStatus > steps[stepIndex].status;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isFilled ? AppColors.primary : AppColors.divider,
                  ),
                );
              }
              // Buoc (icon + label).
              final stepIndex = index ~/ 2;
              final step = steps[stepIndex];
              final isCompleted = currentStatus > step.status;
              final isCurrent = currentStatus == step.status;
              return _buildStepItem(
                step: step,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(BuildContext ctx, int status) {
    Color color;
    String text;
    switch (status) {
      case 0:
        color = AppColors.warning;
        text = ctx.t('status_pending');
        break;
      case 1:
        color = AppColors.info;
        text = ctx.t('status_preparing');
        break;
      case 2:
        color = AppColors.primary;
        text = ctx.t('status_delivering');
        break;
      case 3:
        color = AppColors.success;
        text = ctx.t('status_completed');
        break;
      case 4:
        color = AppColors.error;
        text = ctx.t('status_cancelled');
        break;
      default:
        color = AppColors.textSecondary;
        text = ctx.t('status_pending');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required _TrackerStep step,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = AppColors.divider;
    final Color activeTextColor = AppColors.primary;
    final Color inactiveTextColor = AppColors.textSecondary;

    final Color iconColor = isCompleted || isCurrent ? activeColor : inactiveColor;
    final Color textColor = isCompleted || isCurrent ? activeTextColor : inactiveTextColor;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent
                ? activeColor.withValues(alpha: 0.12)
                : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            step.icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext ctx, OrderModel order) {
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
          _buildAddressItem(
            ctx: ctx,
            icon: Icons.store_outlined,
            iconColor: AppColors.primary,
            label: ctx.t('order_from'),
            name: order.storeName,
            detail: order.storeAddress ?? order.deliveryAddress,
            phone: '',
            imageUrl: order.storeAvatar,
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(left: 22),
            child: Row(
              children: [
                Container(width: 2, height: 16, color: AppColors.divider),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 1, color: AppColors.divider)),
                const SizedBox(width: 8),
                const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildAddressItem(
            ctx: ctx,
            icon: Icons.location_on_outlined,
            iconColor: AppColors.error,
            label: ctx.t('order_to'),
            name: order.receiverName ?? order.addressName ?? 'Khach hang',
            detail: order.deliveryAddress,
            phone: order.receiverPhone ?? '',
            imageUrl: order.userAvatar,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNoteSection(BuildContext ctx, OrderModel order) {
    final note = order.note;
    if (note == null || note.trim().isEmpty) {
      return const SizedBox.shrink();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.note_outlined, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctx.t('checkout_order_note'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(note, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
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
    String? imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: iconColor),
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

  Widget _buildProductListSection(BuildContext ctx, OrderModel order) {
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
          Row(
            children: [
              Text(
                ctx.t('order_items'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text(
                '${order.itemCount} ${ctx.t('unit_items')}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          ...order.items.map((item) => _buildProductItem(ctx, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext ctx, OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hinh anh mon an - trai.
            _buildProductImage(item),
            const SizedBox(width: 12),
            // Noi dung trung tam.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ten mon + so luong.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quantity badge - phai.
                      _buildQuantityBadge(item.quantity),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Variant + Toppings trong container xam nhat.
                  if (item.options != null && item.options!.isNotEmpty) ...[
                    _buildOptionsContainer(ctx, item),
                    const SizedBox(height: 8),
                  ],
                  // Don gia.
                  Text(
                    _formatPrice(item.price, ctx),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(OrderItemModel item) {
    final Widget placeholder = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.restaurant_outlined, size: 28, color: AppColors.textSecondary),
    );

    if (item.imageUrl == null || item.imageUrl!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        item.imageUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantityBadge(int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'x$quantity',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildOptionsContainer(BuildContext ctx, OrderItemModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildGroupedToppings(ctx, item.options ?? []),
      ),
    );
  }

  /// Tao danh sach topping, cung groupName thi xuat hien tren 1 dong.
  /// VD: "Lựa chọn: Trà sữa Size L" | "Lựa chọn: Pudding, Trân châu"
  List<Widget> _buildGroupedToppings(BuildContext ctx, List<ToppingOption> options) {
    if (options.isEmpty) return [];

    // Group theo groupName.
    final Map<String, List<ToppingOption>> grouped = {};
    for (final opt in options) {
      final key = opt.groupName.isEmpty ? ctx.t('order_options') : opt.groupName;
      grouped.putIfAbsent(key, () => []).add(opt);
    }

    return grouped.entries.map((entry) {
      final toppingNames = entry.value.map((o) => o.name).join(' · ');
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  children: [
                    TextSpan(
                      text: '${entry.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(text: toppingNames),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPaymentDetailSection(BuildContext ctx, OrderModel order) {
    // Tinh subtotal: tong tien chua tinh topping (basePrice * quantity).
    double subtotal = 0.0;
    for (final item in order.items) {
      double itemBasePrice = item.price;
      if (item.options != null) {
        for (final opt in item.options!) {
          itemBasePrice -= opt.price;
        }
      }
      subtotal += itemBasePrice * item.quantity;
    }
    final discount = order.discountAmount;

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
          // Tam tinh.
          _buildPaymentRow(
            ctx: ctx,
            label: ctx.t('order_subtotal'),
            value: _formatPrice(subtotal, ctx),
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          // Giam gia (tu voucher).
          if (discount > 0) ...[
            _buildPaymentRow(
              ctx: ctx,
              label: ctx.t('order_voucher_discount'),
              value: '-${_formatPrice(discount, ctx)}',
              valueColor: AppColors.primary,
              isDiscount: true,
            ),
            const SizedBox(height: 8),
          ],
          // Phi van chuyen.
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
          // Tong cong.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ctx.t('order_total'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(_formatPrice(order.finalAmount, ctx), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
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

  Widget _buildPaymentMethodSection(BuildContext ctx, OrderModel order) {
    String methodText;
    IconData methodIcon;

    switch (order.paymentMethod) {
      case 'cash':
        methodText = ctx.t('order_cash_on_delivery');
        methodIcon = Icons.payments_outlined;
        break;
      case 'momo':
        methodText = ctx.t('order_payment_momo');
        methodIcon = Icons.account_balance_wallet_outlined;
        break;
      case 'zalo':
        methodText = ctx.t('order_payment_zalopay');
        methodIcon = Icons.account_balance_wallet_outlined;
        break;
      case 'vnpay':
        methodText = ctx.t('order_payment_vnpay');
        methodIcon = Icons.account_balance_wallet_outlined;
        break;
      case 'card':
        methodText = ctx.t('payment_card');
        methodIcon = Icons.credit_card_outlined;
        break;
      default:
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

  Widget _buildHelpSection(BuildContext context, OrderModel order) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () {
          debugPrint('OrderDetailView: Nguoi dung bam Tro giup, chuyen sang trang Tro giop voi ma don [${order.id}]');
          Navigator.push(context, MaterialPageRoute(builder: (context) => SupportView(orderId: order.id)));
        },
        icon: const Icon(Icons.support_agent_outlined, size: 20),
        label: Text(context.t('order_need_help')),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.divider),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  ///=============================================================================
  /// PHAN GIAO DIEN DONG
  ///=============================================================================

  Widget _buildDynamicSection(BuildContext context, OrderModel order) {
    switch (order.status) {
      case 0:
      case 1:
      case 2:
        return _buildDeliveringSection(context, order);
      case 3:
        return _buildReceivedSection(context, order);
      case 4:
        return _buildCancelledSection(context, order);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDeliveringSection(BuildContext context, OrderModel order) {
    final hasDriver = order.hasDriverInfo;

    return Column(
      children: [
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
                      context.t('finding_driver'),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
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
                                driverId: order.driverId ?? '',
                                driverName: order.driverName ?? '',
                                driverPhone: order.driverPhone ?? '',
                                vehiclePlate: order.vehiclePlate ?? '',
                                driverLat: order.driverLat,
                                driverLng: order.driverLng,
                                storeLat: order.storeLat,
                                storeLng: order.storeLng,
                                storeName: order.storeName,
                                addressLat: order.addressLat,
                                addressLng: order.addressLng,
                                receiverName: order.receiverName ?? order.addressName,
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
                      child: OutlinedButton.icon(
                        onPressed: () => _callDriver(context, order.driverPhone ?? ''),
                        icon: const Icon(Icons.phone_outlined, size: 18),
                        label: Text(context.t('order_call_driver')),
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
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (order.status == 0) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                debugPrint(
                  'OrderDetailView: Nguoi dung bam Huy don [${order.id}]',
                );
                _showCancelDialog(context, order);
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
      ],
    );
  }

  Future<void> _showCancelDialog(BuildContext context, OrderModel order) async {
    await CancelOrderDialog.show(context, order);
  }

  Widget _buildReceivedSection(BuildContext context, OrderModel order) {
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                debugPrint(
                  'OrderDetailView: Nguoi dung bam Danh gia mon an');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodReviewView(order: order),
                  ),
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
          // TODO: [Driver Rating] Uncomment when backend API is ready
          // if (order.hasDriverInfo) ...[
          //   SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton.icon(
          //       onPressed: () {
          //         debugPrint(
          //           'OrderDetailView: Nguoi dung bam Danh gia tai xe',
          //         );
          //       },
          //       icon: const Icon(Icons.directions_car_outlined, size: 18),
          //       label: Text(context.t('order_rate_driver')),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: AppColors.secondary,
          //         foregroundColor: Colors.white,
          //         padding: const EdgeInsets.symmetric(vertical: 12),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         elevation: 0,
          //       ),
          //     ),
          //   ),
          //   const SizedBox(height: 10),
          // ],
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

  Widget _buildCancelledSection(BuildContext context, OrderModel order) {
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

  Widget _buildBottomBar(BuildContext context, OrderModel order) {
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

  Future<void> _callDriver(BuildContext context, String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showAppToast(
          context,
          message: context.t('error_cannot_call'),
          type: AppToastType.error,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

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
