import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../search/views/search_view.dart';
import '../../search/views/search_result_view.dart';
import '../../product/views/product_detail_bottom_sheet.dart';
import '../../checkout/views/checkout_view.dart';
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
                child: HomeSearchBar(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchView(),
                      ),
                    );
                  },
                ),
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
                      // Chuyen sang man hinh ket qua tim kiem voi ten danh muc.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchResultView(query: category.name),
                        ),
                      );
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
              // 6. Mon noi bat - Danh sach mon an theo chieu doc.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LanguageService.translate('home_featured_foods'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                debugPrint(
                                    'HomeView: Nguoi dung bam xem tat ca mon noi bat');
                              },
                              child: Text(
                                LanguageService.translate('common_see_all'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      HomeVerticalFeed(
                        productsStream: HomeService.getFeaturedProductsStream(),
                        onProductTap: (product) {
                          showProductDetailSheet(context, product);
                        },
                      ),
                    ],
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
                  productsStream: HomeService.getProductsStream(),
                  onProductTap: (product) {
                    showProductDetailSheet(context, product);
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CheckoutView(),
          ),
        );
      },
      backgroundColor: AppColors.primary,
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
