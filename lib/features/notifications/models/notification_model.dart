/// Enum phan loai thong bao.
enum NotificationType {
  /// Cap nhat trang thai don hang.
  order,

  /// Khuyen mai, uu dai.
  promotion,

  /// Thong bao he thong.
  system,
}

/// Model thong bao nguoi dung.
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  /// Tao ban sao da danh dau la da doc.
  NotificationModel markAsRead() {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: true,
    );
  }
}
