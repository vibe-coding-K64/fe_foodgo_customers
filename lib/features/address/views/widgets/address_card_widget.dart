import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../../profile/models/address_model.dart';

/// Widget hien thi mot dia chi trong danh sach quan ly dia chi.
/// Hien thi: Radio chon mac dinh, ten, SDT, dia chi chi tiet, nhan,
/// nut Edit va Delete o goc phai.
class AddressCardWidget extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCardWidget({
    super.key,
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  /// Tra ve nhan dia chi (nha / cong ty / khac).
  String _getLabel() {
    if (address.name.contains('Công ty') || address.name.contains('Office')) {
      return LanguageService.translate('address_name_office');
    }
    if (address.name.contains('Nhà') || address.name.contains('Home')) {
      return LanguageService.translate('address_name_home');
    }
    return LanguageService.translate('address_name_other');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: address.isDefault
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dong 1: Radio mac dinh + nut Edit/Delete.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio chon lam dia chi mac dinh.
                GestureDetector(
                  onTap: () {
                    debugPrint(
                        'AddressManagement: Chon dia chi mac dinh [${address.id}]');
                    onSetDefault();
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: address.isDefault
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: address.isDefault
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '0${address.userId.substring(0, 9)}'.replaceAllMapped(
                              RegExp(r'(\d{4})(\d{3})(\d{3})'),
                              (match) =>
                                  '${match[1]} ${match[2]} ${match[3]}',
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Nut chinh sua.
                GestureDetector(
                  onTap: () {
                    debugPrint(
                        'AddressManagement: Nguoi dung bam sua dia chi [${address.id}]');
                    onEdit();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Nut xoa.
                GestureDetector(
                  onTap: () {
                    debugPrint(
                        'AddressManagement: Nguoi dung bam xoa dia chi [${address.id}]');
                    onDelete();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Dong 2: Nhan (nha / cong ty / khac).
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: address.isDefault
                    ? AppColors.primary.withAlpha(25)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getLabel(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: address.isDefault
                      ? AppColors.primary
                      : AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Dong 3: Dia chi chi tiet.
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textHint,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address.address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Dong 4: Chi hien thi neu la dia chi mac dinh.
            if (address.isDefault) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    LanguageService.translate('address_set_default'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
