import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';

/// Man hinh Doi mat khau.
///
/// Hien thi form nhap:
///   - Mat khau hien tai.
///   - Mat khau moi.
///   - Xac nhan mat khau moi.
///
/// Moi truong can: Bieu tuong mat (con mat) de bat/tat hien thi.
/// Khi bam "Gui yeu cau": Hien AlertDialog nhap OTP 6 so.
/// Khi bam "Xac nhan" o Popup: Hien SnackBar thanh cong.
///
/// Duoc goi tu:
///   - SettingsView: bam "Doi mat khau"
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  /// Controller o nhap mat khau hien tai.
  final _oldPwdController = TextEditingController();

  /// Controller o nhap mat khau moi.
  final _newPwdController = TextEditingController();

  /// Controller o xac nhan mat khau moi.
  final _confirmPwdController = TextEditingController();

  /// Controller o nhap OTP.
  final _otpController = TextEditingController();

  /// Trang thai an/hoi mat khau hien tai.
  bool _isOldPwdVisible = false;

  /// Trang thai an/hoi mat khau moi.
  bool _isNewPwdVisible = false;

  /// Trang thai an/hoi xac nhan mat khau.
  bool _isConfirmPwdVisible = false;

  /// Khoa form (chan double-submit khi dang xu ly).
  bool _isSubmitting = false;

  @override
  void dispose() {
    _oldPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Tao mot o nhap mat khau co icon con mat bat/tat hien thi.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.textHint,
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  /// Xu ly khi bam "Gui yeu cau".
  void _onSubmit() {
    final oldPwd = _oldPwdController.text.trim();
    final newPwd = _newPwdController.text.trim();
    final confirmPwd = _confirmPwdController.text.trim();

    // Kiem tra rong.
    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      debugPrint('ChangePassword: Co o nhap bi trong');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('pwd_error_empty')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Kiem tra mat khau moi khớp xac nhan.
    if (newPwd != confirmPwd) {
      debugPrint('ChangePassword: Mat khau xac nhan khong khop');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('pwd_error_mismatch')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    debugPrint('ChangePassword: Gui yeu cau doi mat khau');
    _showOtpDialog(context);
  }

  /// Hien AlertDialog nhap ma OTP 6 so.
  void _showOtpDialog(BuildContext ctx) {
    // Reset o nhap OTP moi lan mo.
    _otpController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            ctx.t('pwd_otp_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mo ta.
              Text(
                ctx.t('pwd_otp_desc'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // O nhap OTP.
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: AppColors.textHint.withAlpha(100),
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Nut huy (phia trai).
            TextButton(
              onPressed: () {
                debugPrint('ChangePassword: Nguoi dung huy nhap OTP');
                Navigator.pop(dialogContext);
              },
              child: Text(
                ctx.t('common_cancel'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Nut xac nhan (phia phai, xanh la).
            ElevatedButton(
              onPressed: () {
                debugPrint('ChangePassword: Nguoi dung xac nhan OTP');
                Navigator.pop(dialogContext);
                _onPasswordChanged();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                ctx.t('pwd_otp_confirm'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  /// Xu ly sau khi xac thuc OTP thanh cong.
  void _onPasswordChanged() {
    // Xoa noi dung form.
    _oldPwdController.clear();
    _newPwdController.clear();
    _confirmPwdController.clear();

    debugPrint('ChangePassword: Doi mat khau thanh cong');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('pwd_success_msg')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Quay ve man hinh truoc.
    Navigator.pop(context);
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
            debugPrint('ChangePassword: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('pwd_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Vung form nhap lieu.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mat khau hien tai.
                    Text(
                      context.t('pwd_old_hint'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _oldPwdController,
                      hintText: context.t('pwd_old_hint'),
                      isVisible: _isOldPwdVisible,
                      onToggleVisibility: () {
                        setState(() => _isOldPwdVisible = !_isOldPwdVisible);
                      },
                    ),
                    const SizedBox(height: 20),
                    // Mat khau moi.
                    Text(
                      context.t('pwd_new_hint'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _newPwdController,
                      hintText: context.t('pwd_new_hint'),
                      isVisible: _isNewPwdVisible,
                      onToggleVisibility: () {
                        setState(() => _isNewPwdVisible = !_isNewPwdVisible);
                      },
                    ),
                    const SizedBox(height: 20),
                    // Xac nhan mat khau moi.
                    Text(
                      context.t('pwd_confirm_hint'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _confirmPwdController,
                      hintText: context.t('pwd_confirm_hint'),
                      isVisible: _isConfirmPwdVisible,
                      onToggleVisibility: () {
                        setState(
                            () => _isConfirmPwdVisible = !_isConfirmPwdVisible);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Nut gui yeu cau (ben duoi).
            Container(
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
                onPressed: _isSubmitting ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withAlpha(120),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.t('pwd_submit_btn'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
