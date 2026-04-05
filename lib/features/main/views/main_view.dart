import 'package:flutter/material.dart';
import '../../../core/localization/language_service.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  // Danh sach cac tab.
  static const List<Widget> _pages = [
    HomeView(),
    // Tab Hoat dong - tam thoi la container rong.
    _PlaceholderTab(label: 'Hoạt động'),
    // Tab Uu dai - tam thoi la container rong.
    _PlaceholderTab(label: 'Ưu đãi'),
    // Tab Thong bao - tam thoi la container rong.
    _PlaceholderTab(label: 'Thông báo'),
    // Tab Tai khoan - su dung ProfileView thuc te.
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: LanguageService.translate('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: LanguageService.translate('nav_activity'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_offer_outlined),
            activeIcon: const Icon(Icons.local_offer),
            label: LanguageService.translate('nav_offers'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications),
            label: LanguageService.translate('nav_notifications'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: LanguageService.translate('nav_profile'),
          ),
        ],
      ),
    );
  }
}

/// Widget placeholder tam thoi cho cac tab chua co giao dien.
class _PlaceholderTab extends StatelessWidget {
  final String label;

  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(label),
      ),
      body: Center(
        child: Text('Man hinh $label (dang phat trien)'),
      ),
    );
  }
}
