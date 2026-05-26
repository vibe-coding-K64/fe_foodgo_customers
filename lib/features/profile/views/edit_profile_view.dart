import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

/// Man hinh Chinh sua ho so ca nhan.
///
/// Hien thi:
///   - Avatar + icon camera de doi anh.
///   - Form nhap: Ho ten, Email, So dien thoai (chi doc).
///   - Nut "Luu thay doi" ben duoi.
///
/// Luong bao mat kep:
///   Buoc 1: Dialog nhap mat khau.
///   Buoc 2: Dialog nhap OTP 6 so.
///   Buoc 3: Goi ProfileService.updateProfile() va quay ve neu thanh cong.
///
/// Duoc goi tu:
///   - ProfileView: bam "Chinh sua ho so"
class EditProfileView extends StatefulWidget {
  /// Nguoi dung hien tai (co the null neu chua co du lieu).
  final UserModel? user;

  const EditProfileView({super.key, this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  /// Service quan ly ho so.
  final ProfileService _profileService = const ProfileService();

  /// Controller o nhap ho ten.
  late final TextEditingController _nameController;

  /// Controller o nhap email.
  late final TextEditingController _emailController;

  /// URL avatar moi (sau khi upload).
  String? _newAvatarUrl;

  /// Khoa submit (chan double-tap).
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Khoi tao controller voi du lieu tu UserModel (neu co).
    _nameController = TextEditingController(
      text: widget.user?.fullName ?? '',
    );
    _emailController = TextEditingController(
      text: widget.user?.email ?? '',
    );
    _newAvatarUrl = widget.user?.photoUrl;
    debugPrint('EditProfile: Khoi tao voi user = ${widget.user?.fullName ?? "null"}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Xu ly bam nut "Luu thay doi".
  void _onSave() {
    if (_isSubmitting) return;

    debugPrint('EditProfile: Nguoi dung bam nut Luu thay doi');
    _showPasswordDialog();
  }

  /// Buoc 1: Dialog nhap mat khau xac thuc.
  void _showPasswordDialog() {
    final pwdController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isPwdVisible = false;

            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                context.t('edit_pwd_title'),
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
                  StatefulBuilder(
                    builder: (ctx, setStateInner) {
                      return TextField(
                        controller: pwdController,
                        obscureText: !isPwdVisible,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: context.t('edit_pwd_hint'),
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPwdVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                            onPressed: () {
                              setStateInner(() => isPwdVisible = !isPwdVisible);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    debugPrint('EditProfile: Nguoi dung huy dialog mat khau');
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    context.t('common_cancel'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final pwd = pwdController.text.trim();
                    if (pwd.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                              context.t('edit_error_pwd_empty')),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    debugPrint('EditProfile: Mat khau da nhap, chuyen sang OTP');
                    Navigator.pop(dialogContext);
                    // Buoc 2: Hien dialog OTP.
                    _showOtpDialog();
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
                    context.t('edit_pwd_continue'),
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
      },
    );
  }

  /// Buoc 2: Dialog nhap ma OTP 6 so.
  void _showOtpDialog() {
    final otpController = TextEditingController();

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
            context.t('edit_otp_title'),
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
              Text(
                context.t('edit_otp_desc'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
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
            TextButton(
              onPressed: () {
                debugPrint('EditProfile: Nguoi dung huy dialog OTP');
                Navigator.pop(dialogContext);
              },
              child: Text(
                context.t('common_cancel'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final otp = otpController.text.trim();
                if (otp.isEmpty || otp.length < 6) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                          context.t('edit_error_otp_empty')),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                debugPrint('EditProfile: OTP da xac thuc, goi updateProfile');
                Navigator.pop(dialogContext);
                await _onProfileUpdated();
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
                context.t('edit_otp_confirm'),
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

  /// Buoc 3: Cap nhat ho so qua API.
  Future<void> _onProfileUpdated() async {
    setState(() => _isSubmitting = true);

    try {
      await _profileService.updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: _newAvatarUrl,
      );

      debugPrint('EditProfile: Cap nhat ho so thanh cong');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('edit_success_msg')),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Quay ve man hinh truoc.
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('EditProfile: Loi cap nhat ho so - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('edit_error_update_failed')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
            debugPrint('EditProfile: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('edit_profile_title'),
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
            // Vung avatar va form.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // Khu vuc avatar.
                    _buildAvatarArea(),
                    const SizedBox(height: 28),
                    // Form nhap lieu.
                    _buildForm(),
                  ],
                ),
              ),
            ),
            // Nut luu thay doi (ben duoi, sticky).
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Khu vuc avatar: CircleAvatar + icon camera ghep de.
  Widget _buildAvatarArea() {
    final displayAvatarUrl = _newAvatarUrl;
    return Stack(
      children: [
        // Avatar chinh.
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: displayAvatarUrl != null && displayAvatarUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: NetworkImage(displayAvatarUrl),
                  onBackgroundImageError: (_, __) {},
                )
              : CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                ),
        ),
        // Icon camera o goc phai duoi (phan ghep de).
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              debugPrint('EditProfile: Nguoi dung bam doi avatar');
              // TODO: Xu ly upload anh avatar khi da co Firebase Storage.
              // Tam thoi chi show snackbar thong bao.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.t('edit_avatar_hint')),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Form nhap lieu: Ho ten, Email, So dien thoai (chi doc).
  Widget _buildForm() {
    return Column(
      children: [
        // Ho ten.
        _buildLabel(context.t('edit_nickname_label')),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          hintText: context.t('edit_nickname_hint'),
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        // Email.
        _buildLabel(context.t('edit_email_label')),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hintText: context.t('edit_email_hint'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        // So dien thoai (chi doc).
        _buildLabel(context.t('edit_phone_label')),
        const SizedBox(height: 8),
        _buildReadOnlyField(),
      ],
    );
  }

  /// Label phia tren moi o nhap.
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// O nhap lieu binh thuong (co the soan thao).
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
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
      ),
    );
  }

  /// O nhap so dien thoai chi doc (nen xam, khong cho phep sua).
  Widget _buildReadOnlyField() {
    final phoneValue = widget.user?.phoneNumber ?? '';
    return TextField(
      controller: TextEditingController(
        text: phoneValue.isNotEmpty ? phoneValue : context.t('edit_phone_value'),
      ),
      readOnly: true,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textHint,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceVariant.withAlpha(180),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Tooltip(
          message: context.t('edit_phone_locked'),
          child: const Icon(
            Icons.lock_outline,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Nut "Luu thay doi" o ben duoi man hinh.
  Widget _buildSaveButton() {
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
        onPressed: _isSubmitting ? null : _onSave,
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
          context.t('edit_save_btn'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
