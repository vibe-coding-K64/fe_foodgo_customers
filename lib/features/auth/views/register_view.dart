import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../services/auth_service.dart';
import 'otp_verification_view.dart';

/// Man hinh dang ky tai khoan moi (Register).
///
/// Chuc nang:
///   - Nhap ho va ten.
///   - Nhap email.
///   - Nhap so dien thoai.
///   - Nhap mat khau.
///   - Xac nhan mat khau.
///
/// Duoc goi tu:
///   - LoginView: bam "Dang ky ngay".
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  /// Controller cho o nhap ho va ten.
  final _nameController = TextEditingController();

  /// Controller cho o nhap email.
  final _emailController = TextEditingController();

  /// Controller cho o nhap so dien thoai.
  final _phoneController = TextEditingController();

  /// Controller cho o nhap mat khau.
  final _passwordController = TextEditingController();

  /// Controller cho o xac nhan mat khau.
  final _confirmPasswordController = TextEditingController();

  /// Trang thai an/hi mat khau chinh.
  bool _obscurePassword = true;

  /// Trang thai an/hi xac nhan mat khau.
  bool _obscureConfirmPassword = true;

  /// Form key de validate form.
  final _formKey = GlobalKey<FormState>();

  /// Trang thai loading khi dang ky.
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Xu ly bam nut Dang ky.
  void _onRegisterPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      debugPrint('RegisterView: Nguoi dung bam Dang ky');
      debugPrint('  Ho va ten: ${_nameController.text}');
      debugPrint('  Email: ${_emailController.text}');
      debugPrint('  So dien thoai: ${_phoneController.text}');
      debugPrint('  Mat khau: [${_passwordController.text.replaceAll(RegExp(r'.'), '*')}]');

      setState(() => _isLoading = true);

      try {
        await AuthService.registerVerifyEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationView(
              contactInfo: _phoneController.text.trim(),
              verifyType: 'register',
              registerPassword: _passwordController.text,
              registerFullName: _nameController.text.trim(),
              registerEmail: _emailController.text.trim(),
            ),
          ),
        );
      } on AuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        debugPrint('RegisterView: Loi bat ngooi khi dang ky = $e');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Da xay ra loi, vui long thu lai'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            debugPrint('RegisterView: Nguoi dung bam nut Quay lai');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('auth_register_btn'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Tieu de man hinh.
                Text(
                  context.t('auth_create_account_title'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('auth_register_subtitle'),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // O nhap ho va ten.
                _buildNameField(),
                const SizedBox(height: 16),
                // O nhap email.
                _buildEmailField(),
                const SizedBox(height: 16),
                // O nhap so dien thoai.
                _buildPhoneField(),
                const SizedBox(height: 16),
                // O nhap mat khau.
                _buildPasswordField(),
                const SizedBox(height: 16),
                // O xac nhan mat khau.
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                // Nut Dang ky.
                _buildRegisterButton(),
                const SizedBox(height: 24),
                // Dong footer quay lai Dang nhap.
                _buildLoginFooter(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// O nhap ho va ten.
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: context.t('auth_full_name_label'),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.person_outline,
          color: AppColors.textSecondary,
          size: 22,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.t('auth_error_empty_field');
        }
        if (value.trim().length < 2) {
          return context.t('auth_error_name_short');
        }
        return null;
      },
    );
  }

  /// O nhap email.
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: context.t('auth_email'),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.t('auth_error_empty_field');
        }
        final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return context.t('error_invalid_email');
        }
        return null;
      },
    );
  }

  /// O nhap so dien thoai.
  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: context.t('auth_phone_number_label'),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.phone_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.t('auth_error_empty_field');
        }
        final phoneRegex = RegExp(r'^[0-9]{9,11}$');
        if (!phoneRegex.hasMatch(value.trim())) {
          return context.t('auth_error_invalid_phone');
        }
        return null;
      },
    );
  }

  /// O nhap mat khau.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: context.t('auth_password_label'),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.textSecondary,
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
            debugPrint('RegisterView: ${_obscurePassword ? "An" : "Hien"} mat khau');
          },
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.t('auth_error_empty_field');
        }
        if (value.length < 6) {
          return context.t('auth_error_password_short');
        }
        return null;
      },
    );
  }

  /// O xac nhan mat khau.
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _onRegisterPressed(),
      decoration: InputDecoration(
        labelText: context.t('auth_confirm_password_label'),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.textSecondary,
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
            debugPrint('RegisterView: ${_obscureConfirmPassword ? "An" : "Hien"} xac nhan mat khau');
          },
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.t('auth_error_empty_field');
        }
        if (value != _passwordController.text) {
          return context.t('auth_error_password_mismatch');
        }
        return null;
      },
    );
  }

  /// Nut Dang ky chinh.
  Widget _buildRegisterButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onRegisterPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                context.t('auth_register_btn'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Dong footer quay lai man hinh Dang nhap.
  Widget _buildLoginFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.t('auth_already_have_account'),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            debugPrint('RegisterView: Quay lai man hinh Dang nhap');
            Navigator.pop(context);
          },
          child: Text(
            context.t('auth_sign_in_now'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
