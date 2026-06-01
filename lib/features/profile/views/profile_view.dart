import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../auth/views/login_view.dart';
import '../../address/views/address_management_view.dart';
import '../../expense/views/expense_management_view.dart';
import '../../order/services/order_service.dart';
import '../../payment/views/payment_methods_view.dart';
import '../../partner/views/partner_registration_view.dart';
import '../../rewards/services/offer_service.dart';
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

  /// So don hang da dat.
  int _totalOrders = 0;

  /// So voucher con han su dung.
  int _availableVouchers = 0;

  /// Diem thuong hieu hien co.
  int _rewardPoints = 0;

  /// Flag de chi load stats 1 lan.
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _menuItems = _buildMenuItems();
    _loadStats();
  }

  /// Tai stats: so don, voucher, diem.
  Future<void> _loadStats() async {
    if (_statsLoaded) return;
    _statsLoaded = true;

    try {
      final results = await Future.wait([
        _loadTotalOrders(),
        _loadAvailableVouchers(),
        _loadRewardPoints(),
      ]);

      if (mounted) {
        setState(() {
          _totalOrders = results[0] as int;
          _availableVouchers = results[1] as int;
          _rewardPoints = results[2] as int;
        });
      }
    } catch (e) {
      debugPrint('ProfileView: loi load stats - $e');
    }
  }

  Future<int> _loadTotalOrders() async {
    try {
      final orders = await OrderService.getMyOrders();
      return orders.length;
    } catch (e) {
      debugPrint('ProfileView: loi load total orders - $e');
      return 0;
    }
  }

  Future<int> _loadAvailableVouchers() async {
    try {
      final vouchers = await OfferService.getMyVouchers();
      return vouchers.where((v) => v.isValid).length;
    } catch (e) {
      debugPrint('ProfileView: loi load vouchers - $e');
      return 0;
    }
  }

  Future<int> _loadRewardPoints() async {
    try {
      final info = await OfferService.getUserRewardInfo();
      return info?.loyaltyPoints ?? 0;
    } catch (e) {
      debugPrint('ProfileView: loi load reward points - $e');
      return 0;
    }
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
          // Header moi: gradient xanh, avatar, stats.
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
                      : 'Khách hàng FoodGo',
                  phoneNumber: user.phoneNumber.isNotEmpty
                      ? user.phoneNumber
                      : '',
                  avatarUrl: user.photoUrl ?? '',
                  onEditProfile: () => _onEditProfile(user),
                  isDriver: user.isDriver,
                  isCustomer: user.isCustomer,
                  totalOrders: _totalOrders,
                  availableVouchers: _availableVouchers,
                  rewardPoints: _rewardPoints,
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

  /// Header khi dang loading — thiet ke moi.
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar loading
              Container(
                width: 108,
                height: 108,
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
              // Name skeleton
              Container(
                width: 160,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              // Phone skeleton
              Container(
                width: 110,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 26),
              // Stats skeleton
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 55,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Header mac dinh khi khong co du lieu — thiet ke moi.
  Widget _buildDefaultHeader() {
    return ProfileHeader(
      userName: 'Khách hàng FoodGo',
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
      isDriver: false,
      isCustomer: true,
      totalOrders: _totalOrders,
      availableVouchers: _availableVouchers,
      rewardPoints: _rewardPoints,
    );
  }
}
