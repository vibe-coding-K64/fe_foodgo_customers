import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/notification_model.dart';
import 'notification_detail_view.dart';
import 'widgets/notification_card.dart';

/// Man hinh Thong bao.
///
/// Hien thi danh sach thong bao cua nguoi dung voi cac tieu chi:
///
/// - AppBar gradient xanh voi tieu de "Thong bao".
/// - Nut "Danh dau da doc" o goc phai AppBar.
/// - Danh sach cac thong bao trong ListView.
/// - Moi thong bao co icon theo loai, tieu de, noi dung, thoi gian.
/// - Thong bao chua doc co nen xanh nhat va cham do nho.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  /// Danh sach thong bao (mock data).
  ///
  /// Gom 5 thong bao mau: 3 chua doc, 2 da doc.
  final List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _notifications.addAll(_buildMockNotifications());
  }

  /// Tao danh sach thong bao mock.
  ///
  /// Cac loai: order (cap nhat don hang), promotion (khuyen mai), system (he thong).
  /// Danh sach gom 5 thong bao:
  ///   1. Don hang da duoc xac nhan - chua doc.
  ///   2. Khuyen mai giam 20% cua cua hang - chua doc.
  ///   3. Thong bao he thong - chua doc.
  ///   4. Don hang da duoc giao thanh cong - da doc.
  ///   5. Ma voucher duoc tang - da doc.
  List<NotificationModel> _buildMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_1',
        type: NotificationType.order,
        title: LanguageService.translate('notification_order_update'),
        body: 'Don hang #ORD001 cua ban da duoc xac nhan va dang duoc chuan bi.',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif_2',
        type: NotificationType.promotion,
        title: LanguageService.translate('notification_promotion'),
        body: 'Cua hang Pho 24 Quan Phu Nhuan dang giam 20% cho tat ca mon an. Dung bo lo!',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif_3',
        type: NotificationType.system,
        title: LanguageService.translate('notification_system'),
        body: 'Ung dung FoodGo da duoc cap nhat len phien ban moi. Hay tra ngay de trai nghiem!',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif_4',
        type: NotificationType.order,
        title: LanguageService.translate('notification_order_update'),
        body: 'Don hang #ORD002 da duoc giao thanh cong. Cam on ban da su dung FoodGo!',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_5',
        type: NotificationType.promotion,
        title: LanguageService.translate('notification_promotion'),
        body: 'Ban duoc tang ma voucher "WELCOME50" giam 50K cho don hang dau tien. Han su dung: 30 ngay.',
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
      ),
    ];
  }

  /// Danh dau tat ca thong bao la da doc.
  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].markAsRead();
      }
    });
    debugPrint('Da danh dau tat ca thong bao la da doc');
  }

  /// Xu ly khi bam vao mot thong bao.
  void _onNotificationTap(NotificationModel notification) {
    // Neu chua doc, danh sach ngay.
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexOf(notification);
        if (index != -1) {
          _notifications[index] = notification.markAsRead();
        }
      });
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
          LanguageService.translate('notification_title'),
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
              LanguageService.translate('notification_mark_all_read'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => _onNotificationTap(notification),
                );
              },
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
            'Chua co thong bao nao',
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
