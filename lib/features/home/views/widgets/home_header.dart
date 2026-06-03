import 'package:flutter/material.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../features/address/services/address_service.dart';
import '../../../../features/address/models/address_model.dart';

/// Widget hien thi banner dia chi o dau trang.
class HomeHeader extends StatelessWidget {
  final VoidCallback? onEditAddress;

  const HomeHeader({super.key, this.onEditAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FutureBuilder<AddressModel?>(
              future: const AddressService().getDefaultAddressFromFirestore(),
              builder: (context, snapshot) {
                String diaChiHienThi;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  diaChiHienThi = 'Dang tai dia chi...';
                } else if (snapshot.hasData && snapshot.data != null) {
                  diaChiHienThi = snapshot.data!.address;
                } else {
                  diaChiHienThi = 'Chua thiet lap dia chi';
                }
                return GestureDetector(
                  onTap: onEditAddress,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('home_deliver_to'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        diaChiHienThi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: onEditAddress,
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
