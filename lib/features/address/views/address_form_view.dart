import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import 'map_picker_view.dart';

/// Man hinh form Them moi / Cap nhat dia chi.
///
/// Thu tu nhan du lieu (khi isEdit = true):
///   1. [address] - dia chi cu (neu la edit, hien thi san)
///   2. [onSave] - callback khi nguoi dung bam "Luu dia chi"
///
/// Thu tu tra du lieu (sau khi luu):
///   - Tra ve AddressModel da duoc tao / cap nhat thong qua API.
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

  /// Callback ngay truoc khi pop 2 lan. Dung de reload danh sach dia chi.
  final Future<void> Function(AddressModel address)? onBeforeDoublePop;

  /// Neu true, sau khi luu se pop 2 lan (ve trang checkout).
  final bool autoDoublePop;

  const AddressFormView({
    super.key,
    this.address,
    this.onSave,
    this.onBeforeDoublePop,
    this.autoDoublePop = false,
  });

  /// Kiem tra xem day la che do sua hay tao moi.
  bool get isEditMode => address != null;

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final AddressService _addressService = AddressService();

  /// Controller cac o nhap lieu.
  late final TextEditingController _receiverNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _labelController;

  /// FocusNode de quyen khong focus giua cac o.
  final List<FocusNode> _focusNodes = List.generate(2, (_) => FocusNode());

  /// Loai dia chi dang chon (0 = Nha, 1 = Van phong, 2 = Khac).
  int _selectedLabel = 0;

  /// Co dat lam mac dinh hay khong.
  bool _isDefault = false;

  /// Trang thai loading khi dang submit form.
  bool _isSaving = false;

  /// Toa do duoc chon tu MapPickerPage.
  double? _selectedLat;
  double? _selectedLng;

  /// Dia chi hien thi (lay tu MapPicker, read-only, khong cho nhap tay).
  String _addressDisplay = '';

  /// Cac loi validate hien tai (key = index cua field).
  final Map<int, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    final addr = widget.address;

    _receiverNameController = TextEditingController(text: addr?.receiverName ?? '');
    _phoneController = TextEditingController(text: addr?.receiverPhone ?? '');
    _labelController = TextEditingController(text: addr?.name ?? '');

    if (addr != null) {
      _isDefault = addr.isDefault;
      _addressDisplay = addr.address;
      _selectedLabel = _inferLabelIndex(addr.name);
      _selectedLat = addr.lat;
      _selectedLng = addr.lng;
    }

    debugPrint(
        'AddressFormView: Che do ${widget.isEditMode ? 'sua' : 'them moi'}.');
  }

  /// Xac dinh chi so chip label tu gia tri label hien tai.
  int _inferLabelIndex(String label) {
    if (label.isEmpty) return 0;
    if (label.contains('Công ty') ||
        label.contains('Office') ||
        label.contains('Cong ty')) {
      return 1;
    }
    if (label.contains('Nhà') ||
        label.contains('Home') ||
        label.contains('Nha')) {
      return 0;
    }
    return 2; // Khac
  }

  /// Lay gia tri label tu chi so chip.
  String _getLabelValue(int index, BuildContext ctx) {
    switch (index) {
      case 0:
        return ctx.t('address_name_home');
      case 1:
        return ctx.t('address_name_office');
      case 2:
        return ctx.t('address_name_other');
      default:
        return '';
    }
  }

  /// Mo MapPickerPage de chon vi tri tren ban do.
  void _openMapPicker(BuildContext ctx) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      ctx,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          initialLat: _selectedLat ?? widget.address?.lat,
          initialLng: _selectedLng ?? widget.address?.lng,
          initialAddress: _addressDisplay.isNotEmpty ? _addressDisplay : widget.address?.address,
        ),
      ),
    );

    if (result != null && mounted) {
      final lat = result['lat'] as double;
      final lng = result['lng'] as double;
      final fullAddress = result['address'] as String;

      setState(() {
        _selectedLat = lat;
        _selectedLng = lng;
        _addressDisplay = fullAddress;
      });

      debugPrint(
          'AddressFormView: Chon vi tri tu ban do - lat=$lat, lng=$lng, address=$fullAddress');
    }
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _phoneController.dispose();
    _labelController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Validate tat ca cac truong bat buoc.
  bool _validate(BuildContext context) {
    final t = context.t;
    final errors = <int, String>{};

    if (_receiverNameController.text.trim().isEmpty) {
      errors[0] = t('address_form_name_required');
    }
    if (_phoneController.text.trim().isEmpty) {
      errors[1] = t('address_form_phone_required');
    }
    if (_addressDisplay.trim().isEmpty) {
      errors[2] = t('error_no_address');
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
  void _onSave() async {
    if (!_validate(context)) return;

    setState(() => _isSaving = true);

    try {
      final fullAddress = _addressDisplay.trim();
      final label = _getLabelValue(_selectedLabel, context);

      debugPrint(
          'AddressFormView: Dang luu dia chi - name=$label, address=$fullAddress, '
          'receiverName=${_receiverNameController.text.trim()}, '
          'receiverPhone=${_phoneController.text.trim()}, '
          'lat=${_selectedLat ?? widget.address?.lat}, lng=${_selectedLng ?? widget.address?.lng}, '
          'isDefault=$_isDefault');

      final AddressModel savedAddress;

      if (widget.isEditMode) {
        savedAddress = await _addressService.updateAddress(
          addressId: widget.address!.id,
          name: label,
          address: fullAddress,
          receiverName: _receiverNameController.text.trim(),
          receiverPhone: _phoneController.text.trim(),
          lat: _selectedLat ?? widget.address?.lat,
          lng: _selectedLng ?? widget.address?.lng,
          isDefault: _isDefault,
        );
      } else {
        savedAddress = await _addressService.createAddress(
          name: label,
          address: fullAddress,
          receiverName: _receiverNameController.text.trim(),
          receiverPhone: _phoneController.text.trim(),
          lat: _selectedLat,
          lng: _selectedLng,
          isDefault: _isDefault,
        );
      }

      debugPrint(
          'AddressFormView: Da luu dia chi [${savedAddress.id}] thanh cong');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('address_form_saved')),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );

        widget.onSave?.call(savedAddress);
        if (widget.autoDoublePop) {
          await widget.onBeforeDoublePop?.call(savedAddress);
          if (mounted) {
            Navigator.pop(context); // ve AddressManagement
            Navigator.pop(context, savedAddress); // ve Checkout
          }
        } else {
          Navigator.pop(context, savedAddress);
        }
      }
    } catch (e) {
      debugPrint('AddressFormView: Loi khi luu dia chi - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? context.t('address_error_update')
                  : context.t('address_error_create'),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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

  /// Nut chon vi tri tren ban do / hien thi dia chi da chon.
  Widget _buildMapPicker(BuildContext ctx) {
    final hasAddress = _addressDisplay.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => _openMapPicker(ctx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasAddress
              ? AppColors.surface
              : AppColors.primary.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasAddress
                ? _fieldErrors[2] != null
                    ? AppColors.error
                    : AppColors.border
                : AppColors.primary.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.map_outlined,
              color: hasAddress ? AppColors.textSecondary : AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasAddress
                    ? _addressDisplay
                    : ctx.t('address_form_select_map'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasAddress ? FontWeight.w400 : FontWeight.w500,
                  color: hasAddress
                      ? AppColors.textPrimary
                      : AppColors.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
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
      controller: _receiverNameController,
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
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: _buildInputDecoration(
        ctx: ctx,
        labelKey: 'address_form_phone',
        hintKey: 'address_form_phone_hint',
        errorFieldIndex: 1,
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
