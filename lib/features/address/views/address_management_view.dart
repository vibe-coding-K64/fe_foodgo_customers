import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../profile/models/address_model.dart';
import 'widgets/address_card_widget.dart';

/// Man hinh Quan ly Dia chi (Address Management).
///
/// Hien thi danh sach dia chi da luu voi cac chuc nang:
/// - Radio chon lam dia chi mac dinh
/// - Nut Edit / Delete tren tung dia chi
/// - Sticky Bottom Bar: nut "Them dia chi moi"
///
/// Duoc goi tu:
///   - Tab Tai khoan (ProfileView)
///   - Trang Thanh toan (CheckoutView) khi bam "Doi dia chi"
class AddressManagementView extends StatefulWidget {
  /// Neu la tu Checkout goi, tra dia chi da chon ve cho Checkout.
  final bool isFromCheckout;

  const AddressManagementView({
    super.key,
    this.isFromCheckout = false,
  });

  @override
  State<AddressManagementView> createState() => _AddressManagementViewState();
}

class _AddressManagementViewState extends State<AddressManagementView> {
  /// Danh sach dia chi.
  late List<AddressModel> _addresses;

  /// Khoi tao du lieu gia.
  @override
  void initState() {
    super.initState();
    _addresses = [
      AddressModel(
        id: 'addr_001',
        userId: '0901234567',
        name: 'Nguyen Van A',
        address: '123 Nguyen Hue, Quan 1, TP.HCM',
        lat: 10.7769,
        lng: 106.7009,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AddressModel(
        id: 'addr_002',
        userId: '0901234567',
        name: 'Cong ty TNHH ABC',
        address: '456 Le Duan, Quan 1, TP.HCM',
        lat: 10.7870,
        lng: 106.6950,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AddressModel(
        id: 'addr_003',
        userId: '0901234567',
        name: 'Van phong Co tien',
        address: '789 Dien Bien Phu, Quan 3, TP.HCM',
        lat: 10.7890,
        lng: 106.6850,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Dat mot dia chi lam mac dinh.
  void _onSetDefault(String addressId) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == addressId,
        );
      }
    });
    debugPrint('AddressManagement: Dat dia chi [$addressId] lam mac dinh');
  }

  /// Xoa mot dia chi.
  void _onDelete(int index) {
    final removed = _addresses[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          LanguageService.translate('address_delete'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: Text(
          LanguageService.translate('address_delete_confirm'),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              LanguageService.translate('common_cancel'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _addresses.removeAt(index);
              });
              debugPrint(
                  'AddressManagement: Da xoa dia chi [${removed.id}]');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LanguageService.translate('address_deleted')),
                  backgroundColor: AppColors.textSecondary,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              LanguageService.translate('common_delete'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Mo trang sua dia chi.
  void _onEdit(AddressModel address) {
    debugPrint(
        'AddressManagement: Mo trang sua dia chi [${address.id}]');
    // TODO: Chuyen huong sang trang sua dia chi.
  }

  /// Mo trang them dia chi moi.
  void _onAddNew() {
    debugPrint('AddressManagement: Mo trang them dia chi moi');
    // TODO: Chuyen huong sang trang them dia chi / ban do.
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isFromCheckout
        ? LanguageService.translate('address_my_addresses')
        : LanguageService.translate('address_my_addresses');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('AddressManagement: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Danh sach dia chi.
          Expanded(
            child: _addresses.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return AddressCardWidget(
                        address: address,
                        onSetDefault: () => _onSetDefault(address.id),
                        onEdit: () => _onEdit(address),
                        onDelete: () => _onDelete(index),
                      );
                    },
                  ),
          ),
          // Sticky Bottom Bar.
          _buildStickyBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 40,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LanguageService.translate('address_title'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LanguageService.translate('address_add_new'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    final isCheckout = widget.isFromCheckout;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nut xac nhan (chi hien khi tu Checkout goi).
          if (isCheckout) ...[
            GestureDetector(
              onTap: () {
                final selected = _addresses.where((a) => a.isDefault).firstOrNull;
                if (selected != null) {
                  debugPrint(
                      'AddressManagement: Xac nhan dia chi [${selected.id}] - ${selected.address}');
                  Navigator.pop(context, selected);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  LanguageService.translate('common_confirm'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Nut them dia chi moi.
          GestureDetector(
            onTap: _onAddNew,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isCheckout ? AppColors.surfaceVariant : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                border: isCheckout
                    ? Border.all(color: AppColors.border, width: 1.5)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: isCheckout ? AppColors.textPrimary : Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LanguageService.translate('address_add_new'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isCheckout ? AppColors.textPrimary : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
