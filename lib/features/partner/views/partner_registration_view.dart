import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../address/views/map_picker_view.dart';

/// Loai doi tac dang ky.
enum PartnerRole {
  seller,
  driver,
}

/// Man hinh Dang ky doi tac (Nguoi ban / Tai xe).
///
/// Hien thi:
///   - Banner gioi thieu voi tieu de va quyen loi.
///   - Form nhap thong tin: ho ten, so dien thoai, CCCD, khu vuc.
///
/// Duoc goi tu:
///   - Tab Tai khoan (ProfileView): bam "Tro thanh nguoi ban" hoac "Tro thanh tai xe"
class PartnerRegistrationView extends StatefulWidget {
  /// Loai doi tac mac dinh khi mo trang (seller / driver).
  final PartnerRole? initialRole;

  const PartnerRegistrationView({
    super.key,
    this.initialRole,
  });

  @override
  State<PartnerRegistrationView> createState() =>
      _PartnerRegistrationViewState();
}

class _PartnerRegistrationViewState extends State<PartnerRegistrationView> {
  /// Loai doi tac dang chon.
  late PartnerRole _selectedRole;

  /// Controller cac o nhap lieu.
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idCardController = TextEditingController();
  final _areaController = TextEditingController();

  /// FocusNode.
  final _fullnameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _idCardFocus = FocusNode();
  final _areaFocus = FocusNode();

  /// Trang thai loading khi submit.
  bool _isSubmitting = false;

  /// Cac loi validate.
  final Map<int, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? PartnerRole.seller;
    debugPrint(
        'PartnerRegistration: Mo trang voi loai doi tac ${_selectedRole.name}');
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _areaController.dispose();
    _fullnameFocus.dispose();
    _phoneFocus.dispose();
    _idCardFocus.dispose();
    _areaFocus.dispose();
    super.dispose();
  }

  /// Tao style InputDecoration.
  InputDecoration _buildDecoration({
    required String labelKey,
    required String hintKey,
    int? errorFieldIndex,
  }) {
    return InputDecoration(
      labelText: LanguageService.translate(labelKey),
      hintText: LanguageService.translate(hintKey),
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
      errorText: errorFieldIndex != null ? _fieldErrors[errorFieldIndex] : null,
      errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
    );
  }

  /// Validate form.
  bool _validate() {
    final t = LanguageService.translate;
    final errors = <int, String>{};

    if (_fullnameController.text.trim().isEmpty) {
      errors[0] = t('partner_fullname_required');
    }
    if (_phoneController.text.trim().isEmpty) {
      errors[1] = t('partner_phone_required');
    }
    if (_idCardController.text.trim().isEmpty) {
      errors[2] = t('partner_idcard_required');
    }
    if (_areaController.text.trim().isEmpty) {
      errors[3] = t('partner_area_required');
    }

    setState(() {
      _fieldErrors.clear();
      _fieldErrors.addAll(errors);
    });

    final isValid = errors.isEmpty;
    debugPrint(
        'PartnerRegistration: Validate = $isValid, loi: $errors');
    return isValid;
  }

  /// Xu ly submit form.
  void _onSubmit() {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'role': _selectedRole.name,
      'fullname': _fullnameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'idCard': _idCardController.text.trim(),
      'area': _areaController.text.trim(),
    };

    debugPrint(
        'PartnerRegistration: Gui yeu cau - $data');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LanguageService.translate('partner_submit_success')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, data);
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
            debugPrint('PartnerRegistration: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          LanguageService.translate('partner_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PHAN 1: Landing Page - Gioi thieu quyen loi.
            _buildBannerSection(),
            const             SizedBox(height: 24),

            // PHAN 2: Form dang ky.
            _buildFormSection(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildStickyBottomBar(),
      ),
    );
  }

  /// PHAN 1: Banner Landing Page.
  Widget _buildBannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner hinh anh.
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
          ),
          child: Stack(
            children: [
              // Hinh anh tu Internet.
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=800&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withAlpha(20),
                      child: const Center(
                        child: Icon(
                          Icons.delivery_dining,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.primary.withAlpha(15),
                      child: const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Lop phu de de doc text tot hon.
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(60),
                        Colors.black.withAlpha(120),
                      ],
                    ),
                  ),
                ),
              ),
              // Tieu de tren anh.
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Text(
                  LanguageService.translate('partner_banner_title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Danh sach quyen loi.
        _buildBenefitsSection(),
      ],
    );
  }

  /// Danh sach quyen loi (icon + text).
  Widget _buildBenefitsSection() {
    final benefits = [
      LanguageService.translate('partner_benefit_1'),
      LanguageService.translate('partner_benefit_2'),
      LanguageService.translate('partner_benefit_3'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: benefits.asMap().entries.map((entry) {
              return _buildBenefitItem(entry.value, entry.key);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String text, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getBenefitIcon(index),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBenefitIcon(int index) {
    switch (index) {
      case 0:
        return Icons.people_outline;
      case 1:
        return Icons.attach_money;
      case 2:
        return Icons.support_agent_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  /// PHAN 2: Form dang ky.
  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de form.
          Text(
            LanguageService.translate('partner_form_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Lua chon loai doi tac.
          _buildRoleSelector(),
          const SizedBox(height: 16),

          // Ho va ten.
          _buildFullnameField(),
          const SizedBox(height: 14),

          // So dien thoai.
          _buildPhoneField(),
          const SizedBox(height: 14),

          // CCCD.
          _buildIdCardField(),
          const SizedBox(height: 14),

          // Khu vuc hoat dong.
          _buildAreaField(),
        ],
      ),
    );
  }

  /// Lua chon loai doi tac (Nguoi ban / Tai xe).
  Widget _buildRoleSelector() {
    final roles = [
      (
        label: LanguageService.translate('partner_role_seller'),
        value: PartnerRole.seller,
        icon: Icons.restaurant_outlined,
      ),
      (
        label: LanguageService.translate('partner_role_driver'),
        value: PartnerRole.driver,
        icon: Icons.delivery_dining_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...roles.map((role) {
          final isSelected = _selectedRole == role.value;
          return GestureDetector(
            onTap: () {
              debugPrint(
                  'PartnerRegistration: Chon loai doi tac ${role.value.name}');
              setState(() => _selectedRole = role.value);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(12)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      role.icon,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      role.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFullnameField() {
    return TextField(
      controller: _fullnameController,
      focusNode: _fullnameFocus,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      onSubmitted: (_) => _phoneFocus.requestFocus(),
      decoration: _buildDecoration(
        labelKey: 'partner_form_fullname',
        hintKey: 'partner_form_fullname_hint',
        errorFieldIndex: 0,
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      focusNode: _phoneFocus,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onSubmitted: (_) => _idCardFocus.requestFocus(),
      decoration: _buildDecoration(
        labelKey: 'partner_form_phone',
        hintKey: 'partner_form_phone_hint',
        errorFieldIndex: 1,
      ),
    );
  }

  Widget _buildIdCardField() {
    return TextField(
      controller: _idCardController,
      focusNode: _idCardFocus,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
      onSubmitted: (_) => _areaFocus.requestFocus(),
      decoration: _buildDecoration(
        labelKey: 'partner_form_idcard',
        hintKey: 'partner_form_idcard_hint',
        errorFieldIndex: 2,
      ),
    );
  }

  Widget _buildAreaField() {
    return TextField(
      controller: _areaController,
      focusNode: _areaFocus,
      textInputAction: TextInputAction.done,
      readOnly: true,
      onTap: () {
        debugPrint('PartnerRegistration: Nguoi dung bam o nhap khu vuc hoat dong');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPickerView(
              onLocationConfirmed: (lat, lng, address) {
                debugPrint(
                    'PartnerRegistration: Da chon vi tri - [$lat, $lng] - $address');
                _areaController.text = address;
              },
            ),
          ),
        );
      },
      decoration: _buildDecoration(
        labelKey: 'partner_form_area',
        hintKey: 'partner_form_area_hint',
        errorFieldIndex: 3,
      ).copyWith(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            Icons.location_on,
            size: 22,
            color: AppColors.primary,
          ),
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
    );
  }

  /// Sticky Bottom Bar.
  Widget _buildStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
        onTap: _isSubmitting ? null : _onSubmit,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _isSubmitting
                ? AppColors.primary.withAlpha(150)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isSubmitting
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
                  LanguageService.translate('partner_submit_btn'),
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
