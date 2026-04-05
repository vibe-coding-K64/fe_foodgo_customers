import 'package:flutter/material.dart';
import '../../../core/localization/language_service.dart';
import '../../address/views/address_management_view.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_list.dart';

/// Man hinh tai khoan nguoi dung.
///
/// Hien thi thong tin ca nhan, avatar va danh sach cac tuy chon quan ly tai khoan.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Du lieu gia cho header (mock data).
    const mockUserName = 'Nguyen Van A';
    const mockPhone = '0909123456';
    const mockAvatar =
        'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=200&q=80';

    // Danh sach cac muc menu.
    final menuItems = [
      // Quan ly chi tieu.
      ProfileMenuItem(
        titleKey: 'profile_spending',
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => _navigateTo(context, '/profile/spending'),
      ),
      // Dia chi mac dinh.
      ProfileMenuItem(
        titleKey: 'profile_default_address',
        icon: Icons.location_on_outlined,
        onTap: () {
          debugPrint('ProfileView: Mo man hinh quan ly dia chi');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddressManagementView(),
            ),
          );
        },
      ),
      // Thanh toan.
      ProfileMenuItem(
        titleKey: 'profile_payment',
        icon: Icons.payment_outlined,
        onTap: () => _navigateTo(context, '/profile/payment'),
      ),
      // Tro thanh nguoi ban.
      ProfileMenuItem(
        titleKey: 'profile_become_seller',
        icon: Icons.storefront_outlined,
        onTap: () => _navigateTo(context, '/profile/become-seller'),
      ),
      // Tro thanh tai xe.
      ProfileMenuItem(
        titleKey: 'profile_become_driver',
        icon: Icons.delivery_dining_outlined,
        onTap: () => _navigateTo(context, '/profile/become-driver'),
      ),
      // Ho tro.
      ProfileMenuItem(
        titleKey: 'profile_support',
        icon: Icons.support_agent_outlined,
        onTap: () => _navigateTo(context, '/profile/support'),
      ),
      // Cai dat.
      ProfileMenuItem(
        titleKey: 'profile_settings',
        icon: Icons.settings_outlined,
        onTap: () => _navigateTo(context, '/profile/settings'),
      ),
      // Dieu khoan va chinh sach.
      ProfileMenuItem(
        titleKey: 'profile_terms_policy',
        icon: Icons.description_outlined,
        onTap: () => _navigateTo(context, '/profile/terms'),
      ),
      // Dang xuat (mau do, o cuoi).
      ProfileMenuItem(
        titleKey: 'profile_logout',
        icon: Icons.logout,
        isDestructive: true,
        onTap: () => _showLogoutDialog(context),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header gradient xanh chua avatar va thong tin nguoi dung.
          SliverToBoxAdapter(
            child: ProfileHeader(
              userName: mockUserName,
              phoneNumber: mockPhone,
              avatarUrl: mockAvatar,
            ),
          ),
          // Danh sach menu tai khoan.
          SliverToBoxAdapter(
            child: ProfileMenuList(items: menuItems),
          ),
        ],
      ),
    );
  }

  /// Di chuyen den man hinh khi chon menu item.
  void _navigateTo(BuildContext context, String route) {
    debugPrint('Dang di chuyen den: $route');
    // TODO: Tich hop voi router khi da cau hinh AppRoutes.
  }

  /// Hien thi hop thoai xac nhan dang xuat.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageService.translate('profile_logout')),
        content: Text(LanguageService.translate('profile_logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageService.translate('common_cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              debugPrint('Nguoi dung xac nhan dang xuat');
              // TODO: goi AuthService.logout()
            },
            child: Text(
              LanguageService.translate('profile_logout'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
