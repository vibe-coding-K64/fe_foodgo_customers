import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../features/profile/models/address_model.dart';

/// Man hinh form Them moi / Cap nhat dia chi.
///
/// Thu tu nhan du lieu (khi isEdit = true):
///   1. [address] - dia chi cu (neu la edit, hien thi san)
///   2. [onSave] - callback khi nguoi dung bam "Luu dia chi"
///
/// Thu tu tra du lieu (sau khi luu):
///   - Tra ve AddressModel da duoc tao / cap nhat thong qua callback [onSave].
///   - Hoac tra ve [null] neu nguoi dung bam Back.
///
/// Duoc goi tu:
///   - AddressManagementView: bam nut "Them dia chi" (khong truyen address)
///   - AddressManagementView: bam nut "Sua" tren card (truyen address)
class AddressFormView extends StatefulWidget {
  /// Dia chi can sua (null neu la tao moi).
  final AddressModel? address;

  /// Callback khi nguoi dung luu thanh cong.
  final void Function(AddressModel address)? onSave;

  const AddressFormView({
    super.key,
    this.address,
    this.onSave,
  });

  /// Kiem tra xem day la che do sua hay tao moi.
  bool get isEditMode => address != null;

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  /// Controller cac o nhap lieu.
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _wardController;
  late final TextEditingController _districtController;
  late final TextEditingController _cityController;

  /// FocusNode de quyen khong focus giua cac o.
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  /// Loai dia chi dang chon (0 = Nha, 1 = Van phong, 2 = Khac).
  int _selectedLabel = 0;

  /// Co dat lam mac dinh hay khong.
  bool _isDefault = false;

  /// Trang thai loading khi dang submit form.
  bool _isSaving = false;

  /// Các loi validate hien tai (key = index cua field).
  final Map<int, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    final addr = widget.address;

    // Khoi tao controller voi du lieu cu (neu la sua).
    _nameController = TextEditingController(text: addr?.name ?? '');
    _phoneController = TextEditingController(text: addr?.userId ?? '');
    _streetController = TextEditingController(text: addr?.address ?? '');
    _wardController = TextEditingController();
    _districtController = TextEditingController();
    _cityController = TextEditingController();

    if (addr != null) {
      _isDefault = addr.isDefault;
      // Phan tich dia chi day du de tach cac thanh phan.
      _parseAddress(addr.address);
    }

    debugPrint(
        'AddressFormView: Che do ${widget.isEditMode ? 'sua' : 'them moi'}.');
  }

  /// Phan tich dia chi day du thanh tung thanh phan.
  void _parseAddress(String fullAddress) {
    // Mac dinh: "123 Nguyen Hue, Quan 1, TP.HCM"
    final parts = fullAddress.split(',').map((p) => p.trim()).toList();
    if (parts.length >= 1) _streetController.text = parts[0];
    if (parts.length >= 2) _districtController.text = parts[1];
    if (parts.length >= 3) _cityController.text = parts[2];
  }

  /// Goop tat ca thanh phan dia chi thanh mot chuoi day du.
  String _buildFullAddress() {
    final street = _streetController.text.trim();
    final district = _districtController.text.trim();
    final city = _cityController.text.trim();

    final buffer = StringBuffer();
    if (street.isNotEmpty) buffer.write(street);
    if (district.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write(district);
    }
    if (city.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write(city);
    }
    return buffer.isEmpty ? street : buffer.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Validate tat ca cac truong bat buoc.
  /// Tra ve true neu tat ca deu hop le.
  bool _validate(BuildContext context) {
    final t = context.t;
    final errors = <int, String>{};

    if (_nameController.text.trim().isEmpty) {
      errors[0] = t('address_form_name_required');
    }
    if (_phoneController.text.trim().isEmpty) {
      errors[1] = t('address_form_phone_required');
    }
    if (_streetController.text.trim().isEmpty) {
      errors[2] = t('address_form_street_required');
    }
    if (_districtController.text.trim().isEmpty) {
      errors[3] = t('address_form_district_required');
    }
    if (_cityController.text.trim().isEmpty) {
      errors[4] = t('address_form_city_required');
    }

    setState(() {
      _fieldErrors.clear();
      _fieldErrors.addAll(errors);
    });

    final isValid = errors.isEmpty;
    debugPrint('AddressFormView: Validate form = $isValid, loi: $errors');
    return isValid;
  }

  /// Xu ly khi nguoi dung bam nut "Luu dia chi".
  void _onSave() {
    if (!_validate(context)) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final addr = AddressModel(
      id: widget.address?.id ?? 'addr_${now.millisecondsSinceEpoch}',
      userId: _phoneController.text.trim(),
      name: _nameController.text.trim(),
      address: _buildFullAddress(),
      lat: widget.address?.lat ?? 0,
      lng: widget.address?.lng ?? 0,
      isDefault: _isDefault,
      createdAt: widget.address?.createdAt ?? now,
      updatedAt: now,
    );

    debugPrint(
        'AddressFormView: Luu dia chi [${addr.id}] - ${addr.name}, ${addr.address}, mac dinh=${addr.isDefault}');

    // Thong bao thanh cong.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('address_form_saved')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Goi callback.
    widget.onSave?.call(addr);

    // Quay lai.
    Navigator.pop(context, addr);
  }

  /// Khoi tao style cho TextField.
  InputDecoration _buildInputDecoration({
    required BuildContext ctx,
    required String labelKey,
    required String hintKey,
    int? errorFieldIndex,
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
    );
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
            debugPrint('AddressFormView: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.isEditMode
              ? context.t('address_form_title_edit')
              : context.t('address_form_title_add'),
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
            // MUC 1: Thong tin lien he.
            _buildSectionHeader(context, 'address_form_contact_info'),
            const SizedBox(height: 12),
            _buildNameField(context),
            const SizedBox(height: 14),
            _buildPhoneField(context),
            const SizedBox(height: 24),

            // MUC 2: Vi tri.
            _buildSectionHeader(context, 'address_form_location'),
            const SizedBox(height: 12),
            _buildMapPicker(context),
            const SizedBox(height: 14),
            _buildStreetField(context),
            const SizedBox(height: 14),
            _buildWardField(context),
            const SizedBox(height: 14),
            _buildDistrictField(context),
            const SizedBox(height: 14),
            _buildCityField(context),
            const SizedBox(height: 24),

            // MUC 3: Cai dat bo sung.
            _buildSectionHeader(context, 'address_form_label'),
            const SizedBox(height: 12),
            _buildLabelChips(context),
            const SizedBox(height: 20),
            _buildDefaultSwitch(context),
            const SizedBox(height: 24),

            // Khoang trong duoi cung de sticky bar.
            SizedBox(height: 80 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
      bottomSheet: _buildStickyBottomBar(context),
    );
  }

  /// Tieu de cua tung muc (section header).
  Widget _buildSectionHeader(BuildContext ctx, String labelKey) {
    return Text(
      ctx.t(labelKey),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Nut chon vi tri tren ban do.
  Widget _buildMapPicker(BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        debugPrint('AddressFormView: Nguoi dung bam chon ban do (chua ho tro)');
        // TODO: Mo trang ban do / tra ve toa do.
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.map_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ctx.t('address_form_select_map'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  /// O nhap Ten nguoi nhan.
  Widget _buildNameField(BuildContext ctx) {
    return TextField(
      controller: _nameController,
      focusNode: _focusNodes[0],
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      onSubmitted: (_) => _focusNodes[1].requestFocus(),
      decoration: _buildInputDecoration(
        ctx: ctx,
        labelKey: 'address_form_receiver_name',
        hintKey: 'address_form_receiver_name_hint',
        errorFieldIndex: 0,
      ),
    );
  }

  /// O nhap So dien thoai.
  Widget _buildPhoneField(BuildContext ctx) {
    return TextField(
      controller: _phoneController,
      focusNode: _focusNodes[1],
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onSubmitted: (_) => _focusNodes[2].requestFocus(),
      decoration: _buildInputDecoration(
        ctx: ctx,
        labelKey: 'address_form_phone',
        hintKey: 'address_form_phone_hint',
        errorFieldIndex: 1,
      ),
    );
  }

  /// O nhap So nha / Ten duong.
  Widget _buildStreetField(BuildContext ctx) {
    return TextField(
      controller: _streetController,
      focusNode: _focusNodes[2],
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      onSubmitted: (_) => _focusNodes[3].requestFocus(),
      decoration: _buildInputDecoration(
        ctx: ctx,
        labelKey: 'address_form_street',
        hintKey: 'address_form_street_hint',
        errorFieldIndex: 2,
      ),
    );
  }

  /// O nhap Phuong / Xa.
  Widget _buildWardField(BuildContext ctx) {
    return TextField(
      controller: _wardController,
      focusNode: _focusNodes[3],
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      onSubmitted: (_) => _focusNodes[4].requestFocus(),
      decoration: _buildInputDecoration(
        ctx: ctx,
        labelKey: 'address_form_ward',
        hintKey: 'address_form_ward_hint',
      ),
    );
  }

  /// O nhap Quan / Huyen.
  Widget _buildDistrictField(BuildContext ctx) {
    return TextField(
      controller: _districtController,
      focusNode: _focusNodes[4],
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      onSubmitted: (_) => _focusNodes[0].requestFocus(),
      decoration: _buildInputDecoration(
        ctx: ctx,
        labelKey: 'address_form_district',
        hintKey: 'address_form_district_hint',
        errorFieldIndex: 3,
      ),
    );
  }

  /// O nhap Tinh / Thanh pho.
  Widget _buildCityField(BuildContext ctx) {
    return TextField(
      controller: _cityController,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: _buildInputDecoration(
        ctx: ctx,
        labelKey: 'address_form_city',
        hintKey: 'address_form_city_hint',
        errorFieldIndex: 4,
      ),
    );
  }

  /// Nhom ChoiceChip: Nha / Van phong / Khac.
  Widget _buildLabelChips(BuildContext ctx) {
    final labels = [
      ctx.t('address_name_home'),
      ctx.t('address_name_office'),
      ctx.t('address_name_other'),
    ];

    return Wrap(
      spacing: 10,
      children: List.generate(labels.length, (index) {
        final isSelected = _selectedLabel == index;
        return GestureDetector(
          onTap: () {
            debugPrint('AddressFormView: Chon label [$index] = ${labels[index]}');
            setState(() => _selectedLabel = index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border,
                width: 1,
              ),
            ),
            child: Text(
              labels[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Dong Switch "Dat lam dia chi mac dinh".
  Widget _buildDefaultSwitch(BuildContext ctx) {
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
              ctx.t('address_form_default_switch'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _isDefault,
              onChanged: (value) {
                debugPrint(
                    'AddressFormView: Switch mac dinh = $value');
                setState(() => _isDefault = value);
              },
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Bar: Nut "Luu dia chi".
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
        onTap: _isSaving ? null : _onSave,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _isSaving
                ? AppColors.primary.withAlpha(150)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isSaving
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Text(
                  ctx.t('address_form_save_btn'),
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
