import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../../address/models/address_model.dart';

/// Widget hien thi thong tin giao hang o phan checkout.
/// Hien thi card chua: ten nguoi nhan, SDT, dia chi, thoi gian du kien.
class CheckoutDeliveryInfo extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onChangeAddressTap;

  const CheckoutDeliveryInfo({
    super.key,
    required this.address,
    this.onChangeAddressTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de + nut doi dia chi.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.t('checkout_delivery_info'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  debugPrint('Checkout: Nguoi dung bam doi dia chi');
                  onChangeAddressTap?.call();
                },
                child: Row(
                  children: [
                    Text(
                      context.t('checkout_change_address'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ten + SDT.
          Row(
            children: [
              Text(
                address.receiverName.isNotEmpty
                    ? address.receiverName
                    : 'Khách hàng',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 14,
                color: AppColors.border,
              ),
              const SizedBox(width: 8),
              Text(
                address.receiverPhone.isNotEmpty
                    ? address.receiverPhone.replaceAllMapped(
                        RegExp(r'(\d{4})(\d{3})(\d{3})'),
                        (match) => '${match[1]} ${match[2]} ${match[3]}',
                      )
                    : '',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Dia chi chi tiet.
          Text(
            address.address,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
