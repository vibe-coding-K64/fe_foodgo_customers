import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum AppToastType { success, error, info, warning }

void showTopSnackBar(
  BuildContext context, {
  required String message,
  Color backgroundColor = AppColors.primary,
  Duration duration = const Duration(milliseconds: 1000),
}) {
  final type = backgroundColor == AppColors.error
      ? AppToastType.error
      : backgroundColor == AppColors.warning
      ? AppToastType.warning
      : backgroundColor == AppColors.info
      ? AppToastType.info
      : AppToastType.success;

  showAppToast(
    context,
    message: message,
    type: type,
    duration: duration,
  );
}

void showAppToast(
  BuildContext context, {
  required String message,
  AppToastType type = AppToastType.success,
  Duration duration = const Duration(milliseconds: 1000),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: _CenterToastWidget(
              message: message,
              style: _AppToastStyle.fromType(type),
              duration: duration,
              onDismiss: () => overlayEntry.remove(),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
}

class _AppToastStyle {
  final Color backgroundColor;
  final String assetPath;

  const _AppToastStyle({
    required this.backgroundColor,
    required this.assetPath,
  });

  factory _AppToastStyle.fromType(AppToastType type) {
    switch (type) {
      case AppToastType.error:
        return const _AppToastStyle(
          backgroundColor: Color(0xFFFFFFFF),
          assetPath: 'asset/icon/err.png',
        );
      case AppToastType.info:
        return const _AppToastStyle(
          backgroundColor: Color(0xFFFFFFFF),
          assetPath: 'asset/icon/err.png',
        );
      case AppToastType.warning:
        return const _AppToastStyle(
          backgroundColor: Color(0xFFFFFFFF),
          assetPath: 'asset/icon/err.png',
        );
      case AppToastType.success:
        return const _AppToastStyle(
          backgroundColor: Color(0xFFFFFFFF),
          assetPath: 'asset/icon/sus.png',
        );
    }
  }
}

class _CenterToastWidget extends StatefulWidget {
  final String message;
  final _AppToastStyle style;
  final Duration duration;
  final VoidCallback onDismiss;

  const _CenterToastWidget({
    required this.message,
    required this.style,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_CenterToastWidget> createState() => _CenterToastWidgetState();
}

class _CenterToastWidgetState extends State<_CenterToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(minWidth: 128, maxWidth: 168),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: widget.style.backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.style.assetPath,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.check_rounded,
                  color: widget.style.backgroundColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
