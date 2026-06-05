import 'dart:async';

import 'package:flutter/material.dart';
import '../../features/notifications/models/notification_model.dart';
import '../../features/notifications/services/notification_service.dart';
import '../../features/notifications/views/notification_detail_view.dart';

/// Overlay manager hien thi notification banner tren cung (tren tat ca man hinh).
///
/// Hoat dong nhu 1 singleton lang nghe notification stream cua Firestore.
/// Khi co thong bao moi -> hien thi banner tu dong.
/// Khong phu thuoc vao man hinh hien tai.
class NotificationOverlayManager {
  NotificationOverlayManager._internal();

  static final NotificationOverlayManager instance = NotificationOverlayManager._internal();

  static OverlayEntry? _overlayEntry;
  static StreamSubscription<List<NotificationModel>>? _subscription;
  static bool _isListening = false;

  /// Kich hoat lang nghe notification. Goi 1 lan o main.dart.
  void startListening() {
    if (_isListening) return;
    _isListening = true;

    _subscription = NotificationService.getNotificationsStream().listen(
      (notifications) {
        if (notifications.isEmpty) return;

        final latest = notifications.first;
        // Chi hien thi neu la thong bao moi (chua doc).
        if (!latest.isRead) {
          _showOverlay(latest);
        }
      },
      onError: (e) {
        debugPrint('NotificationOverlayManager: Stream error - $e');
      },
    );
  }

  /// Ngung lang nghe. Goi khi app can cleanup.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _removeOverlay();
  }

  /// Lay so thong bao chua doc.
  static Future<int> getUnreadCount() async {
    // TODO: implement neu can badge count
    return 0;
  }

  static void _showOverlay(NotificationModel notification) {
    // Neu dang co overlay -> thay the
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => _NotificationBanner(
        notification: notification,
        onDismiss: _removeOverlay,
        onTap: () {
          _removeOverlay();
          _openNotificationDetail(notification);
        },
      ),
    );

    Overlay.of(
      // ignore: use_build_context_synchronously
      WidgetsBinding.instance.rootElement!,
    ).insert(_overlayEntry!);
  }

  static void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void _openNotificationDetail(NotificationModel notification) {
    // Danh dau da doc
    NotificationService.markAsRead(notification.id);

    // Mo notification detail (dung GlobalKey de lay navigator)
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => NotificationDetailView(
            notification: notification,
          ),
        ),
      );
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

/// Banner hien thi notification o phia tren cung man hinh.
class _NotificationBanner extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotificationBanner({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Tu dong an sau 4s
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getIcon(widget.notification.notificationType),
                              color: Colors.orange.shade700,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.notification.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.notification.body,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _dismiss,
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.restaurant;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.notifications;
    }
  }
}
