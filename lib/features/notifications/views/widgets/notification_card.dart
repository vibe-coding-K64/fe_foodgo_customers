import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';

/// Widget hien thi mot thong bao trong danh sach.
///
/// Trai: Icon theo loai thong bao.
/// Giua: Tieu de in dam (neu chua doc) va noi dung chi tiet.
/// Phai-tren: Thoi gian (VD: "2 gio truoc").
/// Neu chua doc: nen xanh nhat va co cham do nho.
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Mau nen: neu chua doc thi nen xanh nhat, neu da doc thi nen trang.
    final backgroundColor = notification.isRead
        ? AppColors.surface
        : AppColors.primary.withOpacity(0.06);

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon ben trai.
              _buildLeadingIcon(),
              const SizedBox(width: 12),
              // Noi dung: tieu de + chi tiet + thoi gian.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tieu de.
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        // Thoi gian.
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            _formatTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Noi dung chi tiet.
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tao icon ben trai dua tren loai thong bao.
  Widget _buildLeadingIcon() {
    final IconData iconData;
    final Color iconColor;
    final Color bgColor;

    switch (notification.type) {
      case NotificationType.order:
        iconData = Icons.receipt_long_outlined;
        iconColor = AppColors.info;
        bgColor = AppColors.info.withOpacity(0.12);
      case NotificationType.promotion:
        iconData = Icons.local_offer_outlined;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.12);
      case NotificationType.system:
        iconData = Icons.settings_outlined;
        iconColor = AppColors.textSecondary;
        bgColor = AppColors.textSecondary.withOpacity(0.12);
    }

    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: iconColor,
            size: 22,
          ),
        ),
        // Cham do danh dau chua doc.
        if (!notification.isRead)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Chuyen doi thoi gian thanh chuoi hien thi.
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vua xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phut truoc';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} gio truoc';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngay truoc';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
