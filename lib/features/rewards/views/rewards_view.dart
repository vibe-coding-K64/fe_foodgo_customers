import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/rewards_model.dart';
import '../services/offer_service.dart';
import 'my_vouchers_view.dart';
import 'reward_detail_view.dart';
import 'widgets/rewards_point_card.dart';
import 'widgets/rewards_voucher_card.dart';
import 'voucher_applicable_products_view.dart';

/// Man hinh Uu dai (Rewards).
///
/// Hien thi diem thanh vien, danh sach voucher doi duoc, va voucher cua nguoi dung.
/// Lay du lieu tu Firebase Firestore.
class RewardsView extends StatefulWidget {
  const RewardsView({super.key});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> {
  /// Future lay thong tin diem thanh vien.
  late final Future<UserRewardInfo?> _rewardInfoFuture;

  /// Future lay danh sach voucher co the doi.
  late final Future<List<SystemVoucherModel>> _systemVouchersFuture;

  /// Future lay danh sach voucher cua nguoi dung.
  late final Future<List<MyVoucherModel>> _myVouchersFuture;

  @override
  void initState() {
    super.initState();
    _rewardInfoFuture = OfferService.getUserRewardInfo();
    _systemVouchersFuture = OfferService.getSystemVouchers();
    _myVouchersFuture = OfferService.getMyVouchers();
  }

  /// Lay ten hien thi cua hang thanh vien tu so tier.
  String _getTierName(int tier) {
    switch (tier) {
      case 0:
        return context.t('tier_0');
      case 1:
        return context.t('tier_1');
      case 2:
        return context.t('tier_2');
      case 3:
        return context.t('tier_3');
      default:
        return context.t('tier_0');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              context.t('nav_offers'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),

          // Card diem thanh vien.
          SliverToBoxAdapter(
            child: _buildRewardInfoCard(),
          ),

          // Section doi diem.
          SliverToBoxAdapter(
            child: _buildExchangeSection(),
          ),

          // Khoang cach.
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          // Section voucher cua toi.
          SliverToBoxAdapter(
            child: _buildMyVouchersSection(),
          ),

          // Khoang cach cuoi.
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  /// Build phan thong tin diem thanh vien.
  Widget _buildRewardInfoCard() {
    return FutureBuilder<UserRewardInfo?>(
      future: _rewardInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildRewardCardSkeleton();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return RewardsPointCard(
            currentPoints: 0,
            memberTier: context.t('tier_0'),
            nextTierPoints: 1000,
          );
        }

        final info = snapshot.data!;
        return RewardsPointCard(
          currentPoints: info.loyaltyPoints,
          memberTier: _getTierName(info.membershipTier),
          nextTierPoints: info.nextTierPoints,
        );
      },
    );
  }

  /// Skeleton loading cho card diem thanh vien.
  Widget _buildRewardCardSkeleton() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.greenGradientStart.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 160,
    );
  }

  /// Build phan voucher co the doi diem.
  Widget _buildExchangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.t('rewards_exchange'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<SystemVoucherModel>>(
            future: _systemVouchersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildExchangeListSkeleton();
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  context.t('common_none'),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                );
              }

              final vouchers = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: vouchers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final voucher = vouchers[index];
                  return _SystemVoucherCard(
                    voucher: voucher,
                    onTap: () {
                      debugPrint('RewardsView: Mo trang chi tiet voucher doi diem [${voucher.id}]');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RewardDetailView(
                            voucher: ExchangeVoucherModel.fromSystemVoucher(voucher),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build phan voucher cua nguoi dung.
  Widget _buildMyVouchersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('rewards_my_vouchers'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              FutureBuilder<List<MyVoucherModel>>(
                future: _myVouchersFuture,
                builder: (context, snapshot) {
                  final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
                  return TextButton(
                    onPressed: hasData
                        ? () {
                            debugPrint('RewardsView: Mo trang tat ca voucher');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyVouchersView(
                                  vouchers: snapshot.data!,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      context.t('common_see_all'),
                      style: TextStyle(
                        color: hasData ? AppColors.primary : AppColors.textHint,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        FutureBuilder<List<MyVoucherModel>>(
          future: _myVouchersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildMyVouchersSkeleton();
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(
                'Chua co uu dai nao',
                padding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }

            final vouchers = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vouchers.length > 3 ? 3 : vouchers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                return RewardsVoucherCard(
                  voucher: voucher,
                  onUse: () {
                    debugPrint('RewardsView: Nguoi dung bam dung ngay [${voucher.code}]');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VoucherApplicableProductsView(
                          voucher: voucher,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Skeleton loading cho danh sach voucher doi diem.
  Widget _buildExchangeListSkeleton() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Skeleton loading cho danh sach voucher cua toi.
  Widget _buildMyVouchersSkeleton() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Widget hien thi trang thai rong.
  Widget _buildEmptyState(String message, {EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Widget card cho voucher doi diem (tu he thong).
///
/// Trich xuat thanh widget rieng de su dung trong FutureBuilder.
class _SystemVoucherCard extends StatelessWidget {
  final SystemVoucherModel voucher;
  final VoidCallback? onTap;

  const _SystemVoucherCard({
    required this.voucher,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('RewardsExchange: Nguoi dung bam vao voucher [${voucher.id}]');
        onTap?.call();
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
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
            // Hinh anh voucher.
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 80,
                width: double.infinity,
                color: AppColors.surfaceVariant,
                child: voucher.imageUrl.isNotEmpty
                    ? Image.network(
                        voucher.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            // Thong tin voucher.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      voucher.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Nut doi diem.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          debugPrint('RewardsExchange: Nguoi dung bam nut doi diem [${voucher.id}]');
                          onTap?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stars, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${voucher.pointsRequired}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.local_offer_outlined,
        size: 32,
        color: AppColors.textSecondary,
      ),
    );
  }
}
