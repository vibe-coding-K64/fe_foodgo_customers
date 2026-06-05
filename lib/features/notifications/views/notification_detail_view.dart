import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../models/notification_model.dart';

/// Man hinh Chi tiet thong bao.
///
/// Nhan vao mot [NotificationModel] va hien thi day du noi dung.
///
/// Hien thi:
///   - Tieu de, thoi gian, noi dung chi tiet.
///   - Nut hanh dong thay doi theo loai thong bao.
///
/// Duoc goi tu:
///   - NotificationsView: bam vao item thong bao bat ky.
class NotificationDetailView extends StatelessWidget {
  /// Thong bao can hien thi chi tiet.
  final NotificationModel notification;

  const NotificationDetailView({
    super.key,
    required this.notification,
  });

  /// Lay tieu de hien thi.
  String _getTitle() {
    return notification.title;
  }

  /// Lay noi dung hien thi.
  String _getBody() {
    return notification.body;
  }

  /// Lay nut hanh dong dua tren loai thong bao.
  String _getActionLabel(BuildContext context) {
    switch (notification.type) {
      case 2:
        return context.t('notif_action_view_order');
      case 1:
        return context.t('notif_action_use_voucher');
      case 0:
      default:
        return context.t('notif_action_go_home');
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

  /// Lay icon dua tren loai thong bao.
  IconData _getIcon() {
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

  /// Format thoi gian thanh chuoi "X gio truoc - dd/MM/yyyy".
  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final createdUtc = dateTime.toUtc();
    final nowUtc = now.toUtc();
    final difference = nowUtc.difference(createdUtc);

    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = context.t('notification_time_just_now');
    } else if (difference.inMinutes < 60) {
      timeAgo = context.t('notification_time_minutes_ago')
          .replaceAll('\$1', difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      timeAgo = context.t('notification_time_hours_ago')
          .replaceAll('\$1', difference.inHours.toString());
    } else if (difference.inDays < 7) {
      timeAgo = context.t('notification_time_days_ago')
          .replaceAll('\$1', difference.inDays.toString());
    } else {
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      return '$day/$month/$year';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$timeAgo - $day/$month/$year';
  }

  /// Xu ly khi bam nut hanh dong.
  void _onActionTap(BuildContext context) {
    switch (notification.type) {
      case 2:
        debugPrint('NotificationDetail: Nguoi dung bam Xem don hang [${notification.referenceId}]');
        // TODO: Chuyen sang trang chi tiet don hang voi referenceId.
        showAppToast(
          context,
          message: 'Dang mo chi tiet don hang #${notification.referenceId}',
          type: AppToastType.success,
        );
        break;
      case 1:
        debugPrint('NotificationDetail: Nguoi dung bam Dung voucher [${notification.referenceId}]');
        // TODO: Chuyen sang trang voucher / khuyen mai.
        showAppToast(
          context,
          message: 'Dang mo voucher #${notification.referenceId}',
          type: AppToastType.success,
        );
        break;
      case 0:
      default:
        debugPrint('NotificationDetail: Nguoi dung bam Ve trang chu');
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('NotificationDetail: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('notif_detail_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Noi dung cuon.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 8),
                  // Thoi gian nhan.
                  _buildTimeLabel(context),
                  const SizedBox(height: 16),
                  // Divider.
                  _buildDivider(),
                  const SizedBox(height: 16),
                  // Noi dung chi tiet.
                  _buildBody(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Nut hanh dong ben duoi (sticky).
          _buildActionButton(context),
        ],
      ),
    );
  }

  /// Widget tieu de thong bao (icon + text, in dam).
  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon theo loai.
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getIconColor().withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Tieu de.
        Expanded(
          child: Text(
            _getTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget thoi gian nhan (text xam nho).
  Widget _buildTimeLabel(BuildContext context) {
    return Text(
      _formatDateTime(context, notification.createdAt),
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  /// Widget divider phan cach.
  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: BoxDecoration(
        color: AppColors.divider.withAlpha(80),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  /// Widget noi dung chi tiet.
  Widget _buildBody() {
    return Text(
      _getBody(),
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        height: 1.7,
      ),
    );
  }

  /// Widget nut hanh dong ben duoi man hinh.
  Widget _buildActionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
        child: ElevatedButton(
        onPressed: () => _onActionTap(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          _getActionLabel(context),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
