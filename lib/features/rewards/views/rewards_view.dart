import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import 'widgets/rewards_point_card.dart';
import 'widgets/rewards_exchange_section.dart';
import 'widgets/rewards_my_vouchers.dart';

/// Man hinh Uu dai (Rewards).
///
/// Hien thi diem thanh vien, danh sach voucher doi duoc, va voucher cua nguoi dung.
class RewardsView extends StatelessWidget {
  const RewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data diem thanh vien.
    const mockPoints = 1500;
    const mockTier = 'Hang Vang';
    const mockNextTierPoints = 2000;

    // Mock data voucher doi diem.
    final exchangeVouchers = [
      const ExchangeVoucher(
        id: 'ev1',
        title: 'Giam 10K',
        subtitle: 'Cho don hang bat ky',
        pointsRequired: 100,
        imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200&q=80',
        remaining: 50,
      ),
      const ExchangeVoucher(
        id: 'ev2',
        title: 'Giam 20%',
        subtitle: 'Giao hang mien phi',
        pointsRequired: 200,
        imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=200&q=80',
        remaining: 20,
      ),
      const ExchangeVoucher(
        id: 'ev3',
        title: 'Giam 30K',
        subtitle: 'Cho don tu 100K',
        pointsRequired: 150,
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&q=80',
        remaining: 10,
      ),
      const ExchangeVoucher(
        id: 'ev4',
        title: 'Giam 50%',
        subtitle: 'Giam toi da 25K',
        pointsRequired: 300,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&q=80',
        remaining: 5,
      ),
    ];

    // Mock data voucher cua nguoi dung.
    final myVouchers = [
      MyVoucher(
        id: 'mv1',
        name: 'Giam 15% cho mon an',
        code: 'EAT15',
        description: 'Giam 15% cho tat ca mon an',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        discountValue: 15,
        isPercentage: true,
        minOrderValue: 100000,
      ),
      MyVoucher(
        id: 'mv2',
        name: 'Mien phi giao hang',
        code: 'FREESHIP',
        description: 'Mien phi giao hang cho don tu 50K',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        discountValue: 0,
        isPercentage: false,
        minOrderValue: 50000,
      ),
      MyVoucher(
        id: 'mv3',
        name: 'Giam 20K cho cua hang',
        code: 'SAVE20K',
        description: 'Giam 20K cho cua hang ho tro',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        discountValue: 20,
        isPercentage: false,
        minOrderValue: 150000,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar tieu de.
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.greenGradientStart,
                    AppColors.greenGradientEnd,
                  ],
                ),
              ),
            ),
            title: Text(
              LanguageService.translate('nav_offers'),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          // Card diem thanh vien.
          SliverToBoxAdapter(
            child: RewardsPointCard(
              currentPoints: mockPoints,
              memberTier: mockTier,
              nextTierPoints: mockNextTierPoints,
            ),
          ),
          // Section doi diem.
          SliverToBoxAdapter(
            child: RewardsExchangeSection(vouchers: exchangeVouchers),
          ),
          // Khoang cach.
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          // Section voucher cua toi.
          SliverToBoxAdapter(
            child: RewardsMyVouchers(vouchers: myVouchers),
          ),
          // Khoang cach cuoi.
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}
