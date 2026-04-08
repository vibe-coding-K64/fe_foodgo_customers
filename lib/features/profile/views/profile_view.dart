import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../auth/views/login_view.dart';
import '../../address/views/address_management_view.dart';
import '../../expense/views/expense_management_view.dart';
import '../../payment/views/payment_methods_view.dart';
import '../../partner/views/partner_registration_view.dart';
import '../../settings/views/settings_view.dart';
import '../../support/views/support_view.dart';
import '../../terms/views/terms_view.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import 'edit_profile_view.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_list.dart';

/// Man hinh tai khoan nguoi dung.
///
/// Hien thi thong tin ca nhan, avatar va danh sach cac tuy chon quan ly tai khoan.
/// Du lieu nguoi dung duoc lay tu Firebase Firestore thong qua StreamBuilder.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  /// Service quan ly ho so nguoi dung.
  final ProfileService _profileService = const ProfileService();

  /// Danh sach cac muc menu.
  late final List<ProfileMenuItem> _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = _buildMenuItems();
  }

  /// Xay dung danh sach cac muc menu.
  List<ProfileMenuItem> _buildMenuItems() {
    return [
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
  }

  /// Mo trang chinh sua ho so.
  void _onEditProfile(UserModel user) {
    debugPrint('ProfileView: Nguoi dung bam nut chinh sua ho so');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileView(user: user),
      ),
    );
  }

  /// Hien thi hop thoai xac nhan dang xuat.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('profile_logout')),
        content: Text(context.t('profile_logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('common_cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              debugPrint('ProfileView: Nguoi dung xac nhan dang xuat');
              // Xoa toan bo lich su man hinh va chuyen ve man hinh Dang nhap.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            child: Text(
              context.t('common_yes'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header gradient xanh chua avatar va thong tin nguoi dung.
          SliverToBoxAdapter(
            child: StreamBuilder<UserModel?>(
              stream: _profileService.getCurrentUserStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingHeader();
                }
                if (snapshot.hasError) {
                  debugPrint('ProfileView: loi StreamBuilder - ${snapshot.error}');
                  return _buildDefaultHeader();
                }
                final user = snapshot.data;
                if (user == null) {
                  return _buildDefaultHeader();
                }
                return ProfileHeader(
                  userName: user.fullName.isNotEmpty
                      ? user.fullName
                      : context.t('profile_no_name'),
                  phoneNumber: user.phoneNumber.isNotEmpty
                      ? user.phoneNumber
                      : '',
                  avatarUrl: user.photoUrl ?? '',
                  onEditProfile: () => _onEditProfile(user),
                );
              },
            ),
          ),
          // Danh sach menu tai khoan.
          SliverToBoxAdapter(
            child: ProfileMenuList(items: _menuItems),
          ),
        ],
      ),
    );
  }

  /// Header khi dang loading.
  Widget _buildLoadingHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF4CAF50),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 120,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header mac dinh khi khong co du lieu.
  Widget _buildDefaultHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF4CAF50),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.t('profile_no_name'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  debugPrint('ProfileView: Nguoi dung bam nut chinh sua ho so (default)');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileView(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: Text(
                  context.t('profile_edit'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
