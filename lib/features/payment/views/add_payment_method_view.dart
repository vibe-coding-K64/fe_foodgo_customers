import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/payment_method_model.dart';

/// Man hinh Them moi phuong thuc thanh toan (the / vi).
///
/// Hien thi:
///   - Form nhap thong tin the (so the, ten chu the, han su dung, CVV).
///   - Phan lien ket vi dien tu (MoMo, ZaloPay).
///
/// Tra ve:
///   - [PaymentMethodModel] neu nguoi dung xac nhan thanh cong.
///   - [null] neu nguoi dung bam Back.
class AddPaymentMethodView extends StatefulWidget {
  /// Callback khi nguoi dung xac nhan.
  final void Function(PaymentMethodModel method)? onConfirm;

  const AddPaymentMethodView({
    super.key,
    this.onConfirm,
  });

  @override
  State<AddPaymentMethodView> createState() => _AddPaymentMethodViewState();
}

class _AddPaymentMethodViewState extends State<AddPaymentMethodView> {
  /// Controller cac o nhap the.
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  /// FocusNode de quyen di chuyen giua cac o.
  final _cardNumberFocus = FocusNode();
  final _cardHolderFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();

  /// Co luu the cho lan sau.
  bool _isSaveCard = true;

  /// Trang thai loading khi submit.
  bool _isConfirming = false;

  /// Cac loi validate (key = index field).
  final Map<int, String> _fieldErrors = {};

  /// The duoc nhan dang (hien thi logo phia duoi o so the).
  CardBrand? _detectedCardBrand;

  @override
  void initState() {
    super.initState();
    // Lang nghe thay doi so the de nhan dang loai.
    _cardNumberController.addListener(_onCardNumberChanged);
  }

  /// Nhan dang loai the dua tren so dau.
  void _onCardNumberChanged() {
    final digits = _cardNumberController.text.replaceAll(' ', '');
    CardBrand? brand;
    if (digits.startsWith('4')) {
      brand = CardBrand.visa;
    } else if (digits.length >= 2) {
      final prefix2 = int.tryParse(digits.substring(0, 2));
      if (prefix2 != null && (prefix2 >= 51 && prefix2 <= 55)) {
        brand = CardBrand.mastercard;
      }
    }
    if (brand != _detectedCardBrand) {
      setState(() => _detectedCardBrand = brand);
    }
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_onCardNumberChanged);
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNumberFocus.dispose();
    _cardHolderFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  /// Tao style InputDecoration.
  InputDecoration _buildDecoration({
    required BuildContext ctx,
    required String labelKey,
    required String hintKey,
    int? errorFieldIndex,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: ctx.t(labelKey),
      hintText: ctx.t(hintKey),
      labelStyle: const TextStyle(fontSize: 14),
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      errorText:
          errorFieldIndex != null ? _fieldErrors[errorFieldIndex] : null,
      errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
      suffixIcon: suffix,
    );
  }

  /// Logo hien thi phia sau o so the.
  Widget _buildCardBrandLogo() {
    if (_detectedCardBrand == null) {
      return const Icon(
        Icons.credit_card,
        color: AppColors.textHint,
        size: 22,
      );
    }
    return _detectedCardBrand == CardBrand.visa
        ? _buildVisaLogo()
        : _buildMastercardLogo();
  }

  Widget _buildVisaLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F71),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'VISA',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMastercardLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEB001B),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'MC',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Validate form.
  bool _validate(BuildContext context) {
    final t = context.t;
    final errors = <int, String>{};

    if (_cardNumberController.text.replaceAll(' ', '').length < 13) {
      errors[0] = t('payment_add_card_number_required');
    }
    if (_cardHolderController.text.trim().isEmpty) {
      errors[1] = t('payment_add_card_holder_required');
    }
    if (_expiryController.text.trim().isEmpty) {
      errors[2] = t('payment_add_card_expiry_required');
    } else if (!_isValidExpiry(_expiryController.text.trim())) {
      errors[2] = t('payment_add_card_invalid_expiry');
    }
    if (_cvvController.text.trim().isEmpty) {
      errors[3] = t('payment_add_card_cvv_required');
    } else if (_cvvController.text.trim().length < 3) {
      errors[3] = t('payment_add_card_invalid_cvv');
    }

    setState(() {
      _fieldErrors.clear();
      _fieldErrors.addAll(errors);
    });

    final isValid = errors.isEmpty;
    debugPrint('AddPaymentMethod: Validate = $isValid, loi: $errors');
    return isValid;
  }

  /// Kiem tra dinh dang MM/YY.
  bool _isValidExpiry(String value) {
    // Dinh dang: MM/YY, MM 01-12.
    final parts = value.split('/');
    if (parts.length != 2) return false;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12) return false;
    if (year == null || parts[1].length != 2) return false;
    return true;
  }

  /// Xu ly xac nhan them the.
  void _onConfirm() {
    if (!_validate(context)) return;

    setState(() => _isConfirming = true);

    final last4 = _cardNumberController.text.replaceAll(' ', '').substring(
        _cardNumberController.text.replaceAll(' ', '').length - 4);

    final method = PaymentMethodModel(
      id: 'pm_card_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentMethodType.card,
      isDefault: _isSaveCard,
      createdAt: DateTime.now(),
      cardBrand: _detectedCardBrand ?? CardBrand.unknown,
      last4Digits: last4,
    );

    debugPrint(
        'AddPaymentMethod: Xac nhan them the [${method.id}] - ${method.cardBrand}, **** $last4');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('payment_add_card_saved')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onConfirm?.call(method);
    Navigator.pop(context, method);
  }

  /// Xu ly lien ket vi dien tu.
  void _onLinkWallet(BuildContext context, WalletBrand brand) {
    debugPrint('AddPaymentMethod: Nguoi dung bam lien ket vi ${brand.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('payment_add_wallet_linked')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final method = PaymentMethodModel(
      id: 'pm_wallet_${brand.name}_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentMethodType.wallet,
      isDefault: false,
      createdAt: DateTime.now(),
      walletBrand: brand,
      isLinked: true,
    );

    widget.onConfirm?.call(method);
    Navigator.pop(context, method);
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
            debugPrint('AddPaymentMethod: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('payment_add_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== PHAN 1: FORM THE =====
            _buildSectionTitle(context, 'payment_add_card_section_title'),
            const SizedBox(height: 14),
            _buildCardNumberField(context),
            const SizedBox(height: 14),
            _buildCardHolderField(context),
            const SizedBox(height: 14),
            _buildExpiryAndCvvRow(context),
            const SizedBox(height: 14),
            _buildSaveCardSwitch(context),
            const SizedBox(height: 28),

            // ===== PHAN 2: LIEN KET VI =====
            _buildSectionTitle(context, 'payment_add_wallet_section_title'),
            const SizedBox(height: 14),
            _buildWalletLinkSection(context),
            const SizedBox(height: 24),

            SizedBox(height: 80 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
      bottomSheet: _buildStickyBottomBar(context),
    );
  }

  Widget _buildSectionTitle(BuildContext ctx, String labelKey) {
    return Text(
      ctx.t(labelKey),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// O nhap so the.
  Widget _buildCardNumberField(BuildContext ctx) {
    return TextField(
      controller: _cardNumberController,
      focusNode: _cardNumberFocus,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CardNumberFormatter(),
        LengthLimitingTextInputFormatter(19),
      ],
      onSubmitted: (_) => _cardHolderFocus.requestFocus(),
      decoration: _buildDecoration(
        ctx: ctx,
        labelKey: 'payment_add_card_number',
        hintKey: 'payment_add_card_number_hint',
        errorFieldIndex: 0,
        suffix: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildCardBrandLogo(),
        ),
      ),
    );
  }

  /// O nhap ten chu the.
  Widget _buildCardHolderField(BuildContext ctx) {
    return TextField(
      controller: _cardHolderController,
      focusNode: _cardHolderFocus,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.characters,
      onSubmitted: (_) => _expiryFocus.requestFocus(),
      decoration: _buildDecoration(
        ctx: ctx,
        labelKey: 'payment_add_card_holder',
        hintKey: 'payment_add_card_holder_hint',
        errorFieldIndex: 1,
      ),
    );
  }

  /// Row chia 2: Ngay het han | CVV.
  Widget _buildExpiryAndCvvRow(BuildContext ctx) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _expiryController,
            focusNode: _expiryFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ExpiryDateFormatter(),
              LengthLimitingTextInputFormatter(5),
            ],
            onSubmitted: (_) => _cvvFocus.requestFocus(),
            decoration: _buildDecoration(
              ctx: ctx,
              labelKey: 'payment_expire_label',
              hintKey: 'payment_add_card_expiry_hint',
              errorFieldIndex: 2,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextField(
            controller: _cvvController,
            focusNode: _cvvFocus,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            obscureText: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            onSubmitted: (_) {
              _cvvFocus.unfocus();
              _onConfirm();
            },
            decoration: _buildDecoration(
              ctx: ctx,
              labelKey: 'payment_cvv_label',
              hintKey: 'payment_add_card_cvv_hint',
              errorFieldIndex: 3,
            ),
          ),
        ),
      ],
    );
  }

  /// Switch luu the.
  Widget _buildSaveCardSwitch(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ctx.t('payment_add_save_card'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _isSaveCard,
              onChanged: (value) {
                debugPrint('AddPaymentMethod: Switch luu the = $value');
                setState(() => _isSaveCard = value);
              },
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  /// Nut lien ket MoMo / ZaloPay.
  Widget _buildWalletLinkSection(BuildContext ctx) {
    return Row(
      children: [
        Expanded(child: _buildWalletButton(ctx, WalletBrand.momo)),
        const SizedBox(width: 12),
        Expanded(child: _buildWalletButton(ctx, WalletBrand.zalopay)),
      ],
    );
  }

  Widget _buildWalletButton(BuildContext ctx, WalletBrand brand) {
    final isMoMo = brand == WalletBrand.momo;
    final bgColor = isMoMo ? const Color(0xFFA50064) : const Color(0xFF0068FF);
    final icon = isMoMo ? Icons.savings_outlined : Icons.account_balance_wallet_outlined;
    final label = isMoMo
        ? ctx.t('payment_momo')
        : ctx.t('payment_zalopay');

    return GestureDetector(
      onTap: () => _onLinkWallet(context, brand),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: bgColor.withAlpha(80), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: bgColor, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: bgColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              ctx.t('payment_add_wallet_link_now'),
              style: TextStyle(
                fontSize: 11,
                color: bgColor.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sticky Bottom Bar.
  Widget _buildStickyBottomBar(BuildContext ctx) {
    return Container(
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
      child: GestureDetector(
        onTap: _isConfirming ? null : _onConfirm,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _isConfirming
                ? AppColors.primary.withAlpha(150)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isConfirming
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Text(
                  ctx.t('payment_add_confirm_btn'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Text input formatter: tu dong them khoang trang sau moi 4 chu so.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 16) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Text input formatter: tu dong them dau '/' sau 2 chu so thang.
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
