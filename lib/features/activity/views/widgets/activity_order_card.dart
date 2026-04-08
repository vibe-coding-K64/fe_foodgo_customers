import 'package:flutter/material.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';

/// Widget Card hien thi thong tin mot don hang.
///
/// Su dung OrderModel tu Firebase Firestore.
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
                      if (order.isActive) ...[
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
                        _formatPrice(order.totalAmount, context),
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
                  _formatDateTime(order.createdAt),
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
                // Nut hanh dong thu hai: Huy don (neu active) hoac Dat lai (neu completed/cancelled).
                Expanded(child: _buildActionButton(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tao badge trang thai voi mau sac phu hop.
  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (order.status) {
      case 0:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 1:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 2:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 3:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 4:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        context.t(order.statusTextKey),
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
    Color textColor;

    switch (order.status) {
      case 0:
        textColor = Colors.blue.shade700;
        break;
      case 1:
        textColor = Colors.blue.shade700;
        break;
      case 2:
        textColor = Colors.orange.shade700;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(Icons.arrow_forward_ios, size: 10, color: textColor),
        const SizedBox(width: 4),
        Text(
          context.t(order.statusTextKey),
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
  ///   - active (0, 1, 2): nut "Huy don" (OutlineButton, chu do).
  ///   - completed/cancelled (3, 4): nut "Dat lai" (ElevatedButton, xanh la).
  Widget _buildActionButton(BuildContext context) {
    if (order.isActive) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          context.t('activity_btn_cancel'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        context.t('activity_btn_reorder'),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Format gia tien thanh chuoi VND.
  String _formatPrice(double price, BuildContext context) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formatted ${context.t('unit_currency')}';
  }

  /// Format ngay gio tao don hang.
  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Format text so luong mon an them (VD: "+ 2 mon" hoac "+ 2 items").
  String _formatItemCountText(BuildContext context) {
    if (order.itemCount <= 1) {
      return order.mainItemName ?? 'Mon an';
    }
    final suffix = context
        .t('order_item_count_suffix')
        .replaceAll('\$1', (order.itemCount - 1).toString());
    return '${order.mainItemName ?? 'Mon an'} + $suffix';
  }
}
