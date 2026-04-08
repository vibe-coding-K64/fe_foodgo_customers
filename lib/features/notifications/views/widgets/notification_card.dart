import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
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

  /// Lay tieu de hien thi dua tren loai thong bao.
  String _getTitle(BuildContext context) {
    return LanguageService.translate('notif_type_${notification.type}');
  }

  /// Lay noi dung hien thi dua tren loai va referenceId.
  String _getBody(BuildContext context) {
    switch (notification.type) {
      case 2:
        // Don hang.
        return 'Don hang #${notification.referenceId} cua ban co cap nhat moi.';
      case 1:
        // Khuyen mai.
        return 'Ma khuyen mai #${notification.referenceId} dang cho ban. Hay su dung ngay!';
      case 0:
      default:
        // He thong.
        return 'Thong bao he thong #${notification.referenceId}.';
    }
  }

  /// Lay icon dua tren loai thong bao.
  IconData _getIconData() {
    switch (notification.type) {
      case 2:
        return Icons.receipt_long_outlined;
      case 1:
        return Icons.local_offer_outlined;
      case 0:
      default:
        return Icons.settings_outlined;
    }
  }

  /// Lay mau icon dua tren loai thong bao.
  Color _getIconColor() {
    switch (notification.type) {
      case 2:
        return AppColors.info;
      case 1:
        return AppColors.primary;
      case 0:
      default:
        return AppColors.textSecondary;
    }
  }

  /// Lay mau nen icon dua tren loai thong bao.
  Color _getIconBgColor() {
    final iconColor = _getIconColor();
    return iconColor.withOpacity(0.12);
  }

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
                            _getTitle(context),
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
                            _formatTime(context, notification.createdAt),
                            style: const TextStyle(
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
                      _getBody(context),
                      style: const TextStyle(
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

  /// Widget icon ben trai voi cham do (neu chua doc).
  Widget _buildLeadingIcon() {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getIconBgColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconData(),
            color: _getIconColor(),
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
  String _formatTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return LanguageService.translate('notification_time_just_now');
    } else if (difference.inMinutes < 60) {
      return LanguageService.translate('notification_time_minutes_ago')
          .replaceAll('\$1', difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return LanguageService.translate('notification_time_hours_ago')
          .replaceAll('\$1', difference.inHours.toString());
    } else if (difference.inDays < 7) {
      return LanguageService.translate('notification_time_days_ago')
          .replaceAll('\$1', difference.inDays.toString());
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year}';
    }
  }
}
