import 'package:flutter/material.dart';
import '../../../core/localization/language_service.dart';
import '../../address/views/address_management_view.dart';
import '../../expense/views/expense_management_view.dart';
import '../../payment/views/payment_methods_view.dart';
import '../../partner/views/partner_registration_view.dart';
import '../../settings/views/settings_view.dart';
import '../../support/views/support_view.dart';
import '../../terms/views/terms_view.dart';
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
        onTap: () {
          debugPrint('ProfileView: Mo trang quan ly chi tieu');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExpenseManagementView(),
            ),
          );
        },
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
        onTap: () {
          debugPrint('ProfileView: Mo man hinh quan ly thanh toan');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentMethodsView(),
            ),
          );
        },
      ),
      // Tro thanh nguoi ban.
      ProfileMenuItem(
        titleKey: 'profile_become_seller_or_driver',
        icon: Icons.content_paste_rounded,
        onTap: () {
          debugPrint('ProfileView: Mo trang dang ky doi tac (Nguoi ban)');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PartnerRegistrationView(
                initialRole: PartnerRole.seller,
              ),
            ),
          );
        },
      ),
      // Ho tro.
      ProfileMenuItem(
        titleKey: 'profile_support',
        icon: Icons.support_agent_outlined,
        onTap: () {
          debugPrint('ProfileView: Mo trang tro giup');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SupportView(),
            ),
          );
        },
      ),
      // Cai dat.
      ProfileMenuItem(
        titleKey: 'profile_settings',
        icon: Icons.settings_outlined,
        onTap: () {
          debugPrint('ProfileView: Mo trang cai dat');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsView(),
            ),
          );
        },
      ),
      // Dieu khoan va chinh sach.
      ProfileMenuItem(
        titleKey: 'profile_terms_policy',
        icon: Icons.description_outlined,
        onTap: () {
          debugPrint('ProfileView: Mo trang dieu khoan va chinh sach');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TermsView(),
            ),
          );
        },
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
