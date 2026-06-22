import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../services/auth_service.dart';
import '../../../../features/main/views/main_view.dart';
import 'reset_password_view.dart';

/// Man hinh Xac thuc OTP.
///
/// Nguoi dung nhap ma 6 so sau khi dang ky hoac yeu cau dat lai mat khau.
///
/// Duoc goi tu:
///   - RegisterView sau khi bam "Dang ky".
///   - ForgotPasswordView sau khi bam "Gui ma xac nhan".
class OtpVerificationView extends StatefulWidget {
  /// So dien thoai hoac email nhan ma OTP.
  final String contactInfo;

  /// Kieu xac thuc: 'register' hoac 'forgot_password'.
  final String verifyType;

  /// Thong tin dang ky (chi can khi verifyType == 'register').
  final String? registerPassword;
  final String? registerFullName;
  final String? registerEmail;

  const OtpVerificationView({
    super.key,
    required this.contactInfo,
    this.verifyType = 'register',
    this.registerPassword,
    this.registerFullName,
    this.registerEmail,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _countdownSeconds = 60;
  bool _canResend = false;
  Timer? _countdownTimer;

  String get _currentOtp =>
      _controllers.map((c) => c.text.trim()).join();

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startCountdown();
    debugPrint('OtpVerificationView: Khoi tao cho ${widget.contactInfo}, kieu ${widget.verifyType}');
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownSeconds = 60;
      _canResend = false;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdownSeconds--;
        if (_countdownSeconds <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _onResendPressed() async {
    if (!_canResend) return;
    final email = widget.verifyType == 'register'
        ? widget.registerEmail ?? widget.contactInfo
        : widget.contactInfo;
    debugPrint('OtpVerificationView: Gui lai OTP toi $email');

    try {
      await AuthService.resendOtp(email);
      _startCountdown();
      if (!mounted) return;
      showAppToast(
        context,
        message: context.t('auth_otp_resent'),
        type: AppToastType.success,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      showAppToast(
        context,
        message: e.message,
        type: AppToastType.error,
      );
    }
  }

  Future<void> _onConfirmPressed() async {
    if (!_isOtpComplete) {
      showAppToast(
        context,
        message: context.t('auth_otp_empty'),
        type: AppToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    debugPrint('OtpVerificationView: Xac thuc OTP [$_currentOtp], kieu [${widget.verifyType}]');

    try {
      if (widget.verifyType == 'forgot_password') {
        final result = await AuthService.verifyOtp(widget.contactInfo, _currentOtp);
        debugPrint('OtpVerificationView: verifyOtp FORGOT_PASSWORD thanh cong - tempToken: ${result.tempToken}');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordView(
              contactInfo: widget.contactInfo,
              tempToken: result.tempToken,
            ),
          ),
        );
      } else {
        final email = widget.registerEmail ?? widget.contactInfo;
        await AuthService.registerComplete(
          email: email,
          otpCode: _currentOtp,
        );

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainView()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      debugPrint('OtpVerificationView: AuthException = ${e.message}');
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppToast(
        context,
        message: e.message,
        type: AppToastType.error,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('OtpVerificationView: Loi bat ngooi = $e');
      setState(() => _isLoading = false);
      showAppToast(
        context,
        message: 'Da xay ra loi, vui long thu lai',
        type: AppToastType.error,
      );
    } finally {
      if (mounted && !Navigator.of(context).canPop()) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.message_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                context.t('auth_otp_title'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                context.t('auth_otp_desc'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              _buildOtpInput(),

              const SizedBox(height: 16),
              if (widget.verifyType == 'register') ...[
                const SizedBox(height: 8),
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: _onResendPressed,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: Text(
                            context.t('auth_otp_resend'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Text(
                          'Gửi lại mã sau ${_countdownSeconds}s',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onConfirmPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.6),
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
                          context.t('auth_confirm'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 46,
            height: 56,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                }
                setState(() {});
              },
              onSubmitted: (_) {
                if (index == 5) {
                  _focusNodes[0].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
