import 'package:flutter/material.dart';
import '../../../core/localization/language_service.dart';
import '../services/home_service.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_categories.dart';
import 'widgets/home_banner_carousel.dart';
import 'widgets/home_suggestion_section.dart';
import 'widgets/home_vertical_feed.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Noi dung cuon chinh.
          CustomScrollView(
            slivers: [
              // 1. Header banner dia chi.
              SliverToBoxAdapter(
                child: HomeHeader(onEditAddress: () {}),
              ),
              // 2. Thanh tim kiem.
              SliverToBoxAdapter(
                child: HomeSearchBar(onTap: () {}),
              ),
              // 3. Danh muc mon an.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: HomeCategories(
                    categoriesStream: HomeService.getCategoriesStream(),
                    onCategoryTap: (category) {
                      debugPrint(
                          'HomeView: Nguoi dung bam danh muc [${category.name}]');
                    },
                  ),
                ),
              ),
              // 4. Banner quang cao carousel.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: HomeBannerCarousel(
                    bannersStream: HomeService.getBannersStream(),
                  ),
                ),
              ),
              // 5. Nhom goi y - Quan gan day.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: HomeSuggestionSection(
                    title: LanguageService.translate('home_near_you'),
                    storesStream: HomeService.getNearbyStoresStream(),
                    onSeeAllTap: () {
                      debugPrint('HomeView: Nguoi dung bam xem tat ca quan');
                    },
                    onStoreTap: (store) {
                      debugPrint(
                          'HomeView: Nguoi dung bam quan [${store.name}]');
                    },
                  ),
                ),
              ),
              // 6. Nhom goi y - Mon ngon noi bat.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: HomeSuggestionSection(
                    title: LanguageService.translate('home_recommended'),
                    productsStream: HomeService.getFeaturedProductsStream(),
                    onSeeAllTap: () {
                      debugPrint(
                          'HomeView: Nguoi dung bam xem tat ca san pham');
                    },
                    onProductTap: (product) {
                      debugPrint(
                          'HomeView: Nguoi dung bam san pham [${product.name}]');
                    },
                  ),
                ),
              ),
              // 7. Feed cuon doc - Danh sach tong hop.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    LanguageService.translate('home_popular_stores'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HomeVerticalFeed(
                  storesStream: HomeService.getStoresStream(),
                  onStoreTap: (store) {
                    debugPrint(
                        'HomeView: Nguoi dung bam quan [${store.name}]');
                  },
                ),
              ),
              // Khoang trong cuoi cung cho FAB.
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
          // 8. Nut FAB Gio hang.
          Positioned(
            right: 16,
            bottom: 16,
            child: _CartFab(),
          ),
        ],
      ),
    );
  }
}

/// Nut FAB gio hang o goc phai duoi.
class _CartFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        debugPrint('HomeView: Nguoi dung bam vao gio hang');
      },
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.shopping_cart,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
