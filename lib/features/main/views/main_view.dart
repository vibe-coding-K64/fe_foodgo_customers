import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../home/views/home_view.dart';
import '../../activity/views/activity_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../rewards/views/rewards_view.dart';
import '../../profile/views/profile_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  int _homeRefreshKey = 0;
  int _activityRefreshKey = 0;
  int _rewardsRefreshKey = 0;
  int _notificationsRefreshKey = 0;
  int _profileRefreshKey = 0;

  // Danh sach cac tab.
  static const List<Widget> _pages = [
    HomeView(),
    // Tab Hoat dong - su dung ActivityView thuc te.
    ActivityView(),
    // Tab Uu dai - su dung RewardsView thuc te.
    RewardsView(),
    // Tab Thong bao - su dung NotificationsView thuc te.
    NotificationsView(),
    // Tab Tai khoan - su dung ProfileView thuc te.
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(key: ValueKey(_homeRefreshKey)),
          ActivityView(key: ValueKey(_activityRefreshKey)),
          RewardsView(key: ValueKey(_rewardsRefreshKey)),
          NotificationsView(key: ValueKey(_notificationsRefreshKey)),
          ProfileView(key: ValueKey(_profileRefreshKey)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              _currentIndex = index;
              _homeRefreshKey++;
            });
          } else if (index == 1) {
            setState(() {
              _currentIndex = index;
              _activityRefreshKey++;
            });
          } else if (index == 2) {
            setState(() {
              _currentIndex = index;
              _rewardsRefreshKey++;
            });
          } else if (index == 3) {
            setState(() {
              _currentIndex = index;
              _notificationsRefreshKey++;
            });
          } else if (index == 4) {
            setState(() {
              _currentIndex = index;
              _profileRefreshKey++;
            });
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: context.t('main_nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: context.t('main_nav_activity'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_offer_outlined),
            activeIcon: const Icon(Icons.local_offer),
            label: context.t('main_nav_offers'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications),
            label: context.t('main_nav_notifications'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.t('main_nav_profile'),
          ),
        ],
      ),
    );
  }
}
