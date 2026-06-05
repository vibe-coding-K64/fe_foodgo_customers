import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'notification_detail_view.dart';
import 'widgets/notification_card.dart';

/// Man hinh Thong bao.
///
/// Hien thi danh sach thong bao cua nguoi dung voi Stream thoi gian thuc tu Firestore.
///
/// - AppBar gradient xanh voi tieu de "Thong bao".
/// - Nut "Danh dau da doc" o goc phai AppBar.
/// - Danh sach cac thong bao trong ListView su dung StreamBuilder.
/// - Moi thong bao co icon theo loai, tieu de, noi dung, thoi gian.
/// - Thong bao chua doc co nen xanh nhat va cham do nho.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  /// Stream danh sach thong bao (thoi gian thuc tu Firestore).
  late final Stream<List<NotificationModel>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = NotificationService.getNotificationsStream();
  }

  /// Danh dau tat ca thong bao la da doc.
  void _markAllAsRead() async {
    await NotificationService.markAllAsRead();
    debugPrint('NotificationsView: Da goi danh dau tat ca thong bao da doc');
  }

  /// Xu ly khi bam vao mot thong bao.
  void _onNotificationTap(NotificationModel notification) async {
    // Danh dau da doc (neu chua doc).
    if (!notification.isRead) {
      await NotificationService.markAsRead(notification.id);
    }

    debugPrint('NotificationsView: Nguoi dung bam vao thong bao [${notification.id}]');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailView(notification: notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.greenGradientStart,
                AppColors.greenGradientEnd,
              ],
            ),
          ),
        ),
        title: Text(
          context.t('notification_title'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              context.t('notification_mark_all_read'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          // Dang tai.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // Loi.
          if (snapshot.hasError) {
            debugPrint('NotificationsView: Loi Stream = ${snapshot.error}');
            return _buildErrorState();
          }

          // Du lieu.
          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () => _onNotificationTap(notification),
              );
            },
          );
        },
      ),
    );
  }

  /// Widget trang thai dang tai.
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Widget trang thai loi.
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            context.t('error_unknown'),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _notificationsStream = NotificationService.getNotificationsStream();
              });
            },
            child: Text(context.t('common_retry')),
          ),
        ],
      ),
    );
  }

  /// Widget hien thi khi danh sach thong bao rong.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            context.t('notification_empty'),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
