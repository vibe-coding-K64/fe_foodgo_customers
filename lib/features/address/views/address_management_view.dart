import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import 'address_form_view.dart';
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
  /// Service quan ly dia chi, tuong tac voi Firebase.
  final AddressService _addressService = AddressService();

  /// Dat mot dia chi lam mac dinh thong qua Firebase.
  void _onSetDefault(String addressId) async {
    try {
      await _addressService.setDefaultAddress(addressId);
      debugPrint('AddressManagement: Dat dia chi [$addressId] lam mac dinh');
    } catch (e) {
      debugPrint('AddressManagement: Loi dat dia chi mac dinh - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService.translate('address_error_set_default')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Xoa mot dia chi khoi Firebase.
  void _onDelete(AddressModel address) {
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
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _addressService.deleteAddress(address.id);
                debugPrint(
                    'AddressManagement: Da xoa dia chi [${address.id}]');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(LanguageService.translate('address_deleted')),
                      backgroundColor: AppColors.textSecondary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('AddressManagement: Loi xoa dia chi - $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(LanguageService.translate('address_error_delete')),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
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
  Future<void> _onEdit(AddressModel address) async {
    debugPrint('AddressManagement: Mo trang sua dia chi [${address.id}]');
    final updated = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormView(address: address),
      ),
    );
    // StreamBuilder se tu dong cap nhat khi Firestore thay doi,
    // nen khong can setState o day.
    if (updated != null) {
      debugPrint('AddressManagement: Da cap nhat dia chi [${updated.id}]');
    }
  }

  /// Mo trang them dia chi moi.
  Future<void> _onAddNew() async {
    debugPrint('AddressManagement: Mo trang them dia chi moi');
    final created = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressFormView(),
      ),
    );
    // StreamBuilder se tu dong cap nhat khi Firestore thay doi.
    if (created != null) {
      debugPrint('AddressManagement: Da them dia chi [${created.id}]');
    }
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
            child: StreamBuilder<List<AddressModel>>(
              stream: _addressService.getAddressesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  debugPrint('AddressManagement: Loi StreamBuilder - ${snapshot.error}');
                  return _buildEmptyState();
                }
                final addresses = snapshot.data ?? [];
                if (addresses.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return AddressCardWidget(
                      address: address,
                      onSetDefault: () => _onSetDefault(address.id),
                      onEdit: () => _onEdit(address),
                      onDelete: () => _onDelete(address),
                    );
                  },
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
            StreamBuilder<List<AddressModel>>(
              stream: _addressService.getAddressesStream(),
              builder: (context, snapshot) {
                final addresses = snapshot.data ?? [];
                final selected = addresses.where((a) => a.isDefault).firstOrNull;
                return GestureDetector(
                  onTap: selected != null
                      ? () {
                          debugPrint(
                              'AddressManagement: Xac nhan dia chi [${selected.id}] - ${selected.addressText}');
                          Navigator.pop(context, selected);
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected != null
                          ? AppColors.primary
                          : AppColors.primary.withAlpha(100),
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
                );
              },
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
