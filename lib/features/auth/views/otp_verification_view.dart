import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
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

  const OtpVerificationView({
    super.key,
    required this.contactInfo,
    this.verifyType = 'register',
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  /// Danh sach controllers cho 6 o nhap OTP.
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  /// Danh sach FocusNode tuong ung voi tung o nhap.
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  /// Trang thai loading khi xac thuc.
  bool _isLoading = false;

  /// So giay con lai de gui lai ma.
  int _countdownSeconds = 60;

  /// Da het thoi gian chua gui lai duoc chua.
  bool _canResend = false;

  /// Timer dem nguoc.
  Timer? _countdownTimer;

  /// Chuoi OTP hien tai (ghep 6 ky tu).
  String get _currentOtp =>
      _controllers.map((c) => c.text.trim()).join();

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startCountdown();
    debugPrint('OtpVerificationView: Khoi tao man hinh xac thuc OTP cho ${widget.contactInfo}');
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

  /// Bat dau dem nguoc 60 giay.
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

  /// Xu ly gui lai ma OTP.
  void _onResendPressed() {
    if (!_canResend) return;
    debugPrint('OtpVerificationView: Nguoi dung bam Gui lai ma OTP');
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LanguageService.translate('auth_verification_email_sent')),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Xu ly bam nut Xac nhan.
  void _onConfirmPressed() {
    if (!_isOtpComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageService.translate('auth_otp_empty')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    debugPrint('OtpVerificationView: Xac thuc OTP [$_currentOtp], kieu [${widget.verifyType}]');

    // Gia lap goi API, sau 1.5s xu ly chuyen trang theo luong.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (widget.verifyType == 'forgot_password') {
        // Luong quen mat khau: chuyen sang trang Dat lai mat khau.
        debugPrint('OtpVerificationView: Chuyen sang trang Dat lai mat khau');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordView(
              contactInfo: widget.contactInfo,
            ),
          ),
        );
      } else {
        // Luong dang ky: chuyen sang man hinh chinh, xoa toan bo lich su Auth.
        debugPrint('OtpVerificationView: Xac thuc thanh cong, chuyen sang man hinh chinh');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainView()),
          (route) => false,
        );
      }
    });
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Icon dai dien.
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

              // Tieu de.
              Text(
                LanguageService.translate('auth_otp_title'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Mo ta.
              Text(
                LanguageService.translate('auth_otp_desc'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // O nhap OTP.
              _buildOtpInput(),

              const SizedBox(height: 16),

              // Khoang trong cho phan dem nguoc.
              const SizedBox(height: 8),

              // Dòng dem nguoc hoac nut gui lai.
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _onResendPressed,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        child: Text(
                          LanguageService.translate('auth_otp_resend'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          text: LanguageService.translate('auth_otp_resend_countdown'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
              ),

              // Day nut xac nhan xuong duoi cung.
              const Spacer(),

              // Nut Xac nhan.
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
                          LanguageService.translate('auth_confirm'),
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

  /// Xay dung o nhap OTP gom 6 TextField nho nam canh nhau.
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
                // Khi nguoi dung nhap mot ky tu, chuyen focus sang o tiep theo.
                if (value.isNotEmpty && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                }
                setState(() {});
              },
              onSubmitted: (_) {
                // Khi an Done tren o cuoi, chuyen focus ve o dau tien.
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
