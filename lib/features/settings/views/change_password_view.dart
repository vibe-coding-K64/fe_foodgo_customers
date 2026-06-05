import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../profile/services/profile_service.dart';

/// Man hinh Doi mat khau.
///
/// Hien thi form nhap:
///   - Mat khau hien tai.
///   - Mat khau moi.
///   - Xac nhan mat khau moi.
///
/// Moi truong can: Bieu tuong mat (con mat) de bat/tat hien thi.
/// Khi bam "Gui yeu cau": Goi PUT /api/customers/password.
///
/// Duoc goi tu:
///   - SettingsView: bam "Doi mat khau"
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  /// Service quan ly ho so.
  final ProfileService _profileService = const ProfileService();

  /// Controller o nhap mat khau hien tai.
  final _oldPwdController = TextEditingController();

  /// Controller o nhap mat khau moi.
  final _newPwdController = TextEditingController();

  /// Controller o xac nhan mat khau moi.
  final _confirmPwdController = TextEditingController();

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

  /// Xu ly khi bam "Gui yeu cau" — goi API doi mat khau truc tiep.
  Future<void> _onSubmit() async {
    if (_isSubmitting) return;

    final oldPwd = _oldPwdController.text.trim();
    final newPwd = _newPwdController.text.trim();
    final confirmPwd = _confirmPwdController.text.trim();

    // Kiem tra rong.
    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      debugPrint('ChangePassword: Co o nhap bi trong');
      showAppToast(
        context,
        message: context.t('pwd_error_empty'),
        type: AppToastType.error,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Kiem tra mat khau moi khớp xac nhan.
    if (newPwd != confirmPwd) {
      debugPrint('ChangePassword: Mat khau xac nhan khong khop');
      showAppToast(
        context,
        message: context.t('pwd_error_mismatch'),
        type: AppToastType.error,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Kiem tra do dai mat khau moi (theo validation backend: toi thieu 6 ky tu).
    if (newPwd.length < 6) {
      debugPrint('ChangePassword: Mat khau moi qua ngan');
      showAppToast(
        context,
        message: context.t('pwd_error_too_short'),
        type: AppToastType.error,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    debugPrint('ChangePassword: Gui yeu cau doi mat khau');

    setState(() => _isSubmitting = true);

    try {
      await _profileService.changePassword(
        oldPassword: oldPwd,
        newPassword: newPwd,
      );

      debugPrint('ChangePassword: Doi mat khau thanh cong');

      // Xoa noi dung form.
      _oldPwdController.clear();
      _newPwdController.clear();
      _confirmPwdController.clear();

      if (!mounted) return;

      showAppToast(
        context,
        message: context.t('pwd_success_msg'),
        type: AppToastType.success,
        duration: const Duration(seconds: 2),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('ChangePassword: Loi doi mat khau - $e');
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');
      showAppToast(
        context,
        message: message,
        type: AppToastType.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
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
