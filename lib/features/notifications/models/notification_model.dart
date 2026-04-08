import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum phan loai thong bao.
///
/// Map voi Firestore (so nguyen):
///   0: He thong
///   1: Khuyen mai
///   2: Cap nhat don hang
enum NotificationType {
  /// Thong bao he thong.
  system,

  /// Khuyen mai, uu dai.
  promotion,

  /// Cap nhat trang thai don hang.
  order,
}

/// Model thong bao nguoi dung.
///
/// Su dung cho sub-collection `users/{userId}/notifications`.
class NotificationModel {
  final String id;

  /// Loai thong bao: 0 = He thong, 1 = Khuyen mai, 2 = Don hang.
  final int type;

  /// ID tham chieu (ma don hang, ma voucher, ...).
  final String referenceId;

  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.referenceId,
    required this.createdAt,
    required this.isRead,
  });

  /// Lay enum [NotificationType] tu so type.
  NotificationType get notificationType {
    switch (type) {
      case 0:
        return NotificationType.system;
      case 1:
        return NotificationType.promotion;
      case 2:
        return NotificationType.order;
      default:
        return NotificationType.system;
    }
  }

  /// Khoi tao tu Firestore document.
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parsedDate;
    final rawDate = data['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: doc.id,
      type: (data['type'] as num?)?.toInt() ?? 0,
      referenceId: data['referenceId'] as String? ?? '',
      createdAt: parsedDate,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  /// Tao ban sao da danh dau la da doc.
  NotificationModel markAsRead() {
    return NotificationModel(
      id: id,
      type: type,
      referenceId: referenceId,
      createdAt: createdAt,
      isRead: true,
    );
  }
}
