import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

  /// File avatar moi (da chon tu thu vien, chua upload).
  File? _newAvatarFile;

  /// Khoa submit (chan double-tap).
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
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

  /// Dialog nhap mat khau xac thuc (buoc duy nhat).
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
                context.t('edit_confirm_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('edit_confirm_desc'),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          hintText: 'Nhập mật khẩu',
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
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(context.t('edit_error_pwd_empty')),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    debugPrint('EditProfile: Mat khau da nhap, goi updateProfile');
                    Navigator.pop(dialogContext);
                    _onProfileUpdated(pwd);
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
                    context.t('edit_confirm_btn'),
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

  /// Cap nhat ho so qua API.
  Future<void> _onProfileUpdated(String password) async {
    // Kiem tra xem co thay doi gi khong
    final hasNameChanged = _nameController.text.trim() != (widget.user?.fullName ?? '');
    final hasEmailChanged = _emailController.text.trim() != (widget.user?.email ?? '');
    final hasAvatarChanged = _newAvatarFile != null;

    if (!hasNameChanged && !hasEmailChanged && !hasAvatarChanged) {
      debugPrint('EditProfile: Khong co thay doi nao');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('edit_no_changes')),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Hien thi loading overlay
    _showLoadingOverlay();

    try {
      debugPrint('EditProfile: Goi updateProfileWithAvatar');
      await _profileService.updateProfileWithAvatar(
        avatarFile: hasAvatarChanged ? _newAvatarFile : null,
        fullName: hasNameChanged ? _nameController.text.trim() : null,
        email: hasEmailChanged ? _emailController.text.trim() : null,
        password: password,
      );

      debugPrint('EditProfile: Cap nhat ho so thanh cong');

      if (mounted) {
        _hideLoadingOverlay();

        // Quay ve man hinh truoc (SnackBar se tu dong an sau 2s)
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('EditProfile: Loi cap nhat ho so - $e');
      if (mounted) {
        _hideLoadingOverlay();

        // Revert ve gia tri cu khi that bai
        _nameController.text = widget.user?.fullName ?? '';
        _emailController.text = widget.user?.email ?? '';
        _newAvatarFile = null;
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('edit_error_update_failed')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
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

  /// Hien thi loading overlay
  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Container(
          color: Colors.black.withAlpha(100),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  /// An loading overlay
  void _hideLoadingOverlay() {
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                debugPrint('EditProfile: Nguoi dung bam nut back');
                Navigator.pop(context);
              },
            ),
            title: Text(
              context.t('edit_profile_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Gradient header với avatar
                _buildHeader(),

                // Form content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                  child: Column(
                    children: [
                      // Section: Thông tin cá nhân
                      _buildSectionHeader(
                        icon: Icons.person_outline,
                        title: 'Thông tin cá nhân',
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard(),

                      const SizedBox(height: 24),

                      // Section: Liên hệ
                      _buildSectionHeader(
                        icon: Icons.contact_phone_outlined,
                        title: 'Liên hệ',
                      ),
                      const SizedBox(height: 12),
                      _buildContactCard(),

                      const SizedBox(height: 24),

                      // Lưu ý bảo mật
                      _buildSecurityNote(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Nút Lưu thay đổi cố định bên dưới
      bottomSheet: _buildSaveButton(),
    );
  }

  /// Gradient header với avatar
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF43A047),
            Color(0xFF66BB6A),
            Color(0xFF2E7D32),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            children: [
              // Avatar
              _buildAvatarArea(),

              const SizedBox(height: 16),

              // Tên user
              Text(
                _nameController.text.isNotEmpty
                    ? _nameController.text
                    : context.t('profile_no_name'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 4),

              // Email
              if (_emailController.text.isNotEmpty)
                Text(
                  _emailController.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Khu vuc avatar
  Widget _buildAvatarArea() {
    final displayAvatarUrl = _newAvatarUrl;
    final hasNewAvatar = _newAvatarFile != null;

    return GestureDetector(
      onTap: _showImageSourcePicker,
      child: Stack(
        children: [
          // Avatar chinh
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: hasNewAvatar
                  ? Image.file(
                      _newAvatarFile!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                    )
                  : (displayAvatarUrl != null && displayAvatarUrl.isNotEmpty
                      ? Image.network(
                          displayAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                        )
                      : _buildAvatarPlaceholder()),
            ),
          ),

          // Icon camera
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(100),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hien thi bottom sheet chon nguon anh
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.t('edit_pick_avatar_title'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  context.t('edit_pick_avatar_library'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  context.t('edit_pick_avatar_library_desc'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Chon anh tu thu vien
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _newAvatarFile = File(pickedFile.path);
        });
        debugPrint('EditProfile: Da chon anh - ${pickedFile.path}');
      }
    } catch (e) {
      debugPrint('EditProfile: Loi chon anh - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('edit_pick_avatar_error')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.person,
        size: 52,
        color: AppColors.textHint,
      ),
    );
  }

  /// Section header với icon
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Card form thông tin cá nhân
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Họ tên
          _buildFormField(
            label: context.t('edit_nickname_label'),
            hint: context.t('edit_nickname_hint'),
            controller: _nameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            prefixIcon: Icons.badge_outlined,
          ),

          const SizedBox(height: 8),

          // Email
          _buildFormField(
            label: context.t('edit_email_label'),
            hint: context.t('edit_email_hint'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
        ],
      ),
    );
  }

  /// Card form liên hệ
  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildReadOnlyField(),
    );
  }

  /// Field nhập liệu
  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required IconData prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // TextField with border
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    prefixIcon,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    textCapitalization: textCapitalization,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textHint,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Trường chỉ đọc (số điện thoại)
  Widget _buildReadOnlyField() {
    final phoneValue = widget.user?.phoneNumber ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            context.t('edit_phone_label'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // Container with border
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_android,
                  size: 20,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    phoneValue.isNotEmpty ? phoneValue : context.t('edit_phone_value'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                Tooltip(
                  message: context.t('edit_phone_locked'),
                  child: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.textHint.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ghi chú bảo mật
  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withAlpha(40),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('edit_security_note_title'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.t('edit_security_note_desc'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nút Lưu thay đổi
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
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
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          context.t('edit_save_btn'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
