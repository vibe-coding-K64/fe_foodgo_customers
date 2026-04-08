import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Trang thai chi tiet cua don hang (hien thi dong sub-status).
/// Chi ap dung cho don dang xu ly.
enum SubOrderStatus {
  preparing,     // Nguoi ban dang chuan bi.
  driverComing,  // Tai xe dang toi nha hang.
  delivering,    // Tai xe dang giao hang.
}

/// Model mock cho don hang.
class OrderModel {
  final String id;
  final String storeName;
  final String mainItem;
  final int itemCount;
  final double totalPrice;
  final DateTime orderDate;
  final OrderStatus status;
  final SubOrderStatus? subStatus; // Chi co gia tri khi status == ordered.

  const OrderModel({
    required this.id,
    required this.storeName,
    required this.mainItem,
    required this.itemCount,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    this.subStatus,
  });
}

/// Trang thai don hang.
enum OrderStatus {
  ordered,   // Da dat (dang xu ly).
  received,  // Da nhan (hoan thanh).
  cancelled, // Da huy.
}

/// Widget Card hien thi thong tin mot don hang.
class ActivityOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onViewDetail;
  final VoidCallback? onReorder;
  final VoidCallback? onCancel;

  const ActivityOrderCard({
    super.key,
    required this.order,
    this.onViewDetail,
    this.onReorder,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Phan header: ten quan va trang thai.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hinh dai dien quan.
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                // Thong tin don hang.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.storeName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Hien thi sub-status neu co (chi cho don dang xu ly).
                      if (order.subStatus != null) ...[
                        const SizedBox(height: 2),
                        _buildSubStatusRow(context),
                      ],
                      Text(
                        _formatItemCountText(context),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(order.totalPrice, context),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge trang thai.
                _buildStatusBadge(context),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Ngay gio dat hang.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(order.orderDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          // Nut hanh dong.
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Nut xem chi tiet (outline).
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDetail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      context.t('activity_btn_detail'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nut hanh dong thu hai: Huy don (neu ordered) hoac Dat lai (neu received/cancelled).
                Expanded(
                  child: _buildActionButton(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.ordered:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        statusText = context.t('activity_status_ordered');
        break;
      case OrderStatus.received:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        statusText = context.t('activity_status_received');
        break;
      case OrderStatus.cancelled:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        statusText = context.t('activity_status_cancelled');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Dong sub-status hien thi trang thai chi tiet cua don dang xu ly.
  Widget _buildSubStatusRow(BuildContext context) {
    // Chi hien thi neu subStatus co gia tri (don dang xu ly).
    if (order.subStatus == null) return const SizedBox.shrink();

    String text;
    Color textColor;

    switch (order.subStatus!) {
      case SubOrderStatus.preparing:
        text = context.t('activity_status_preparing');
        textColor = Colors.blue.shade700;
        break;
      case SubOrderStatus.driverComing:
        text = context.t('activity_status_driver_coming');
        textColor = Colors.orange.shade700;
        break;
      case SubOrderStatus.delivering:
        text = context.t('activity_status_delivering');
        textColor = Colors.orange.shade700;
        break;
    }

    return Row(
      children: [
        Icon(
          Icons.arrow_forward_ios,
          size: 10,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  /// Nut hanh dong thu hai, thay doi theo trang thai don hang:
  ///   - ordered: nut "Huy don" (OutlineButton, chu do).
  ///   - received/cancelled: nut "Dat lai" (ElevatedButton, xanh la).
  Widget _buildActionButton(BuildContext context) {
    if (order.status == OrderStatus.ordered) {
      // Nut Huy don: OutlineButton voi chu mau do.
      return OutlinedButton(
        onPressed: () {
          debugPrint('ActivityOrderCard: Nguoi dung bam Huy don [${order.id}]');
          onCancel?.call();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          context.t('activity_btn_cancel'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Nut Dat lai: ElevatedButton xanh la (cho received va cancelled).
    return ElevatedButton(
      onPressed: () {
        debugPrint('ActivityOrderCard: Nguoi dung bam Dat lai [${order.id}]');
        onReorder?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        context.t('activity_btn_reorder'),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatPrice(double price, BuildContext context) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formatted ${context.t('unit_currency')}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Format text so luong mon an them (VD: "+ 2 mon" hoac "+ 2 items").
  String _formatItemCountText(BuildContext context) {
    if (order.itemCount <= 1) {
      return order.mainItem;
    }
    final suffix = context.t('order_item_count_suffix')
        .replaceAll('\$1', (order.itemCount - 1).toString());
    return '${order.mainItem} + $suffix';
  }
}
