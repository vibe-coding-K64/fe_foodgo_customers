import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/state/cart_state.dart';
import '../../../../features/main/views/main_view.dart';
import '../services/auth_service.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';

/// Man hinh dang nhap (Login).
///
/// Chuc nang:
///   - Nhap email va mat khau.
///   - Hien thi/an mat khau.
///   - Quen mat khau.
///   - Chuyen sang man hinh Dang ky.
///
/// Duoc goi tu:
///   - MainView khi chua dang nhap.
///   - SplashScreen.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  /// Controller cho o nhap email.
  final _emailController = TextEditingController();

  /// Controller cho o nhap mat khau.
  final _passwordController = TextEditingController();

  /// Trang thai an/hi mat khau.
  bool _obscurePassword = true;

  /// Form key de validate form.
  final _formKey = GlobalKey<FormState>();

  /// Trang thai loading khi dang nhap.
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Xu ly bam nut Dang nhap.
  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      _handleLogin();
    }
  }

  /// Xu ly dang nhap thuc te: goi AuthService, hien thi loading, xu ly loi.
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint('LoginView: Nguoi dung bam Dang nhap');
    debugPrint('  Email: $email');

    setState(() => _isLoading = true);

    try {
      await AuthService.login(email, password);

      // Reset CartState truoc khi chuyen sang MainView cua user moi.
      CartState.of(context).reset();

      // Dang nhap thanh cong. Chuyen sang MainView, xoa lich su stack.
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainView()),
        (route) => false,
      );
    } on AuthException catch (e) {
      // Loi tu AuthService - hien thi thong bao.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Loi khong xac dinh.
      if (!mounted) return;
      debugPrint('LoginView: Loi bat ngooi khi dang nhap = $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Da xay ra loi, vui long thu lai sau'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Xu ly bam nut Quen mat khau.
  void _onForgotPasswordPressed() {
    debugPrint('LoginView: Nguoi dung bam Quen mat khau');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordView()),
    );
  }

  /// Xu ly bam chuyen sang man hinh Dang ky.
  void _onRegisterTap() {
    debugPrint('LoginView: Chuyen sang man hinh Dang ky');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    // Phan Logo va tieu de.
                    _buildHeader(),
                    const SizedBox(height: 40),
                    // O nhap email.
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    // O nhap mat khau.
                    _buildPasswordField(),
                    // Nut Quen mat khau.
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _onForgotPasswordPressed,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        child: Text(
                          context.t('auth_forgot_password_link'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Nut Dang nhap.
                    _buildLoginButton(),
                    const SizedBox(height: 32),
                    // Dong chuyen sang Dang ky.
                    _buildRegisterFooter(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Hien thi loading overlay khi dang xu ly.
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Phan Logo va tieu de chao mung.
  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Logo app: Icon to mau xanh la.
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'asset/img/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.t('auth_welcome_title'),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.t('auth_login_subtitle'),
          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// O nhap email.
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: context.t('auth_phone_email_hint'),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
        return null;
      },
    );
  }

  /// O nhap mat khau co nut bat/tat hien thi.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _onLoginPressed(),
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
            debugPrint(
              'LoginView: ${_obscurePassword ? "An" : "Hien"} mat khau',
            );
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
        if (value.length < 6) {
          return context.t('auth_error_password_short');
        }
        return null;
      },
    );
  }

  /// Nut Dang nhap chinh.
  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _onLoginPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          context.t('auth_login_btn'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Dong footer chuyen sang man hinh Dang ky.
  Widget _buildRegisterFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.t('auth_dont_have_account'),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: _onRegisterTap,
          child: Text(
            context.t('auth_sign_up_now'),
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
