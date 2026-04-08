import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/notification_model.dart';

/// Man hinh Chi tiet thong bao.
///
/// Nhan vao mot [NotificationModel] va hien thi day du noi dung.
///
/// Hien thi:
///   - Banner image (chi voi thong bao khuyen mai).
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

  /// Lay tieu de hien thi dua tren loai thong bao.
  String _getTitle(BuildContext context) {
    return context.t('notif_type_${notification.type}');
  }

  /// Lay noi dung hien thi dua tren loai va referenceId.
  String _getBody(BuildContext context) {
    switch (notification.type) {
      case 2:
        return 'Don hang #${notification.referenceId} cua ban co cap nhat moi. Vui long kiem tra trang chi tiet don hang de biet thong tin chi tiet.';
      case 1:
        return 'Ma khuyen mai #${notification.referenceId} dang cho ban. Hay su dung ngay de nhan uu dai truoc khi het han!';
      case 0:
      default:
        return 'Thong bao he thong #${notification.referenceId}. Vui long kiem tra de biet thong tin chi tiet.';
    }
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

  /// Lay URL hinh banner dua tren loai thong bao.
  /// Chi khuyen mai moi co banner.
  String? _getBannerUrl() {
    if (notification.type == 1) {
      return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80';
    }
    return null;
  }

  /// Lay icon trai cho banner (neu co).
  IconData? _getBannerOverlayIcon() {
    if (notification.type == 1) {
      return Icons.local_offer;
    }
    return null;
  }

  /// Format thoi gian thanh chuoi "X gio truoc - dd/MM/yyyy".
  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = context.t('notification_time_just_now');
    } else if (difference.inHours < 24) {
      timeAgo = context.t('notification_time_hours_ago')
          .replaceAll('\$1', difference.inHours.toString());
    } else if (difference.inDays < 7) {
      timeAgo = context.t('notification_time_days_ago')
          .replaceAll('\$1', difference.inDays.toString());
    } else {
      timeAgo = context.t('notification_time_days_ago')
          .replaceAll('\$1', difference.inDays.toString());
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dang mo chi tiet don hang #${notification.referenceId}'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 1:
        debugPrint('NotificationDetail: Nguoi dung bam Dung voucher [${notification.referenceId}]');
        // TODO: Chuyen sang trang voucher / khuyen mai.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dang mo voucher #${notification.referenceId}'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
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
    final bannerUrl = _getBannerUrl();

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
                  // Banner hinh anh (chi hien voi khuyen mai).
                  if (bannerUrl != null) _buildBanner(bannerUrl),
                  if (bannerUrl != null) const SizedBox(height: 20),
                  // Tieu de.
                  _buildTitle(context),
                  const SizedBox(height: 8),
                  // Thoi gian nhan.
                  _buildTimeLabel(context),
                  const SizedBox(height: 16),
                  // Divider.
                  _buildDivider(),
                  const SizedBox(height: 16),
                  // Noi dung chi tiet.
                  _buildBody(context),
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

  /// Widget banner hinh chu nhat bo goc.
  Widget _buildBanner(String imageUrl) {
    final overlayIcon = _getBannerOverlayIcon();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Hinh anh.
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                width: double.infinity,
                height: 200,
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: AppColors.textHint,
                ),
              );
            },
          ),
          // Lop phu ban trong suot.
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(25),
                  Colors.black.withAlpha(50),
                ],
              ),
            ),
          ),
          // Icon goc trai tren (neu co).
          if (overlayIcon != null)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  overlayIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget tieu de thong bao (icon + text, in dam).
  Widget _buildTitle(BuildContext context) {
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
            _getTitle(context),
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
  Widget _buildBody(BuildContext context) {
    return Text(
      _getBody(context),
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
