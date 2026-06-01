import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../auth/views/login_view.dart';
import '../../address/views/address_management_view.dart';
import '../../payment/views/payment_methods_view.dart';
import '../../settings/views/settings_view.dart';
import '../../support/views/support_view.dart';
import '../../terms/views/terms_view.dart';
import '../models/profile_stats.dart';
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

  /// Thong ke nguoi dung (orders / vouchers / points).
  Future<ProfileStats>? _statsFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('ProfileView.initState: creating menu items and fetching stats');
    _menuItems = _buildMenuItems();
    _statsFuture = _profileService.getUserStats();
  }

  /// Xay dung danh sach cac muc menu.
  List<ProfileMenuItem> _buildMenuItems() {
    return [
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
      body: FutureBuilder<ProfileStats>(
        future: _statsFuture,
        builder: (context, statsSnapshot) {
          debugPrint('ProfileView: statsSnapshot state=${statsSnapshot.connectionState}, data=${statsSnapshot.data}');
          // Hien thi loading header neu stats dang load.
          if (statsSnapshot.connectionState != ConnectionState.done) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildLoadingHeader()),
                SliverToBoxAdapter(child: ProfileMenuList(items: _menuItems)),
              ],
            );
          }

          // Stats da load (co the la gia tri mac dinh neu co loi).
          final stats = statsSnapshot.data ?? const ProfileStats();

          return StreamBuilder<UserModel?>(
            stream: _profileService.getCurrentUserStream(),
            builder: (context, userSnapshot) {
              debugPrint('ProfileView: userSnapshot state=${userSnapshot.connectionState}, data=${userSnapshot.data}, error=${userSnapshot.error}');
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildLoadingHeader()),
                    SliverToBoxAdapter(child: ProfileMenuList(items: _menuItems)),
                  ],
                );
              }
              if (userSnapshot.hasError || userSnapshot.data == null) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildDefaultHeader(stats: stats)),
                    SliverToBoxAdapter(child: ProfileMenuList(items: _menuItems)),
                  ],
                );
              }
              final user = userSnapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      userName: user.fullName.isNotEmpty
                          ? user.fullName
                          : context.t('profile_no_name'),
                      phoneNumber: user.phoneNumber.isNotEmpty
                          ? user.phoneNumber
                          : '',
                      avatarUrl: user.photoUrl ?? '',
                      onEditProfile: () => _onEditProfile(user),
                      totalOrders: stats.totalOrders,
                      availableVouchers: stats.availableVouchers,
                      rewardPoints: stats.rewardPoints,
                    ),
                  ),
                  SliverToBoxAdapter(child: ProfileMenuList(items: _menuItems)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Header khi dang loading.
  Widget _buildLoadingHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF43A047),
            Color(0xFF66BB6A),
            Color(0xFF2E7D32),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Avatar skeleton.
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 160,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 16),
              // Stats skeleton.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.divider.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 30,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.divider.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 50,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.divider.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              // Button skeleton.
              Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Header mac dinh khi khong co du lieu.
  Widget _buildDefaultHeader({ProfileStats? stats}) {
    return ProfileHeader(
      userName: context.t('profile_no_name'),
      phoneNumber: '',
      avatarUrl: '',
      onEditProfile: () {
        debugPrint('ProfileView: Nguoi dung bam nut chinh sua ho so (default)');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditProfileView(),
          ),
        );
      },
      totalOrders: stats?.totalOrders ?? 0,
      availableVouchers: stats?.availableVouchers ?? 0,
      rewardPoints: stats?.rewardPoints ?? 0,
    );
  }
}
