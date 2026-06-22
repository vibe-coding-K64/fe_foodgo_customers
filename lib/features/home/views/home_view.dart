import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/utils/format_currency.dart';
import '../../search/views/search_view.dart';
import '../../search/views/search_result_view.dart';
import '../../product/views/product_detail_bottom_sheet.dart';
import '../../cart/views/cart_view.dart';
import '../../restaurant/views/restaurant_detail_view.dart';
import '../../address/views/address_management_view.dart';
import '../../address/services/address_service.dart';
import '../../address/models/address_model.dart';
import '../../store/services/store_service.dart';
import '../../store/services/product_service.dart';
import '../../home/models/store_model.dart';
import '../../home/models/product_model.dart';
import '../../home/models/category_model.dart';
import 'nearby_stores_view.dart';
import 'featured_products_view.dart';
import 'popular_stores_view.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_categories.dart';
import '../widgets/green_chat_overlay.dart';
import '../services/home_service.dart';

/// Trang chu - HomeView.
///
/// Hien thi cac khoi noi dung:
///   1. Header dia chi giao hang.
///   2. Thanh tim kiem.
///   3. Danh muc mon an (tu Firestore Stream).
///   4. Quan ngon gan day (tu API /api/stores/nearby).
///   6. Mon an noi bat (tu API /api/products/featured).
///   7. Quan pho bien (tu API /api/stores/popular).
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const _defaultLat = 10.8500;
  static const _defaultLng = 106.7900;

  final StoreService _storeService = StoreService();
  final ProductService _productService = const ProductService();
  final AddressService _addressService = const AddressService();

  double _lat = _defaultLat;
  double _lng = _defaultLng;

  /// Stable Future references — set once in initState and updated only on retry.
  /// FutureBuilder only re-executes when the reference changes.
  Future<AddressModel?> _defaultAddressFuture = Future.value(null);
  Future<List<StoreModel>> _nearbyStoresFuture = Future.value([]);
  Future<List<ProductModel>> _featuredProductsFuture = Future.value([]);
  late Future<List<StoreModel>> _popularStoresFuture;

  /// Stream — created at construction time (not in build).
  final Stream<List<CategoryModel>> _categoriesStream =
      HomeService.getCategoriesStream();

  @override
  void initState() {
    super.initState();
    _popularStoresFuture = _storeService.getPopularStores(lat: _lat, lng: _lng);
    _resolveLocationAndFetch();
  }

  Future<void> _resolveLocationAndFetch() async {
    double lat = _defaultLat;
    double lng = _defaultLng;

    // Start fetching default address and store the future.
    final defaultAddressFuture = _addressService.getDefaultAddressFromFirestore();
    if (mounted) {
      setState(() {
        _defaultAddressFuture = defaultAddressFuture;
      });
    }

    final defaultAddress = await defaultAddressFuture;
    if (defaultAddress != null && defaultAddress.lat != null && defaultAddress.lng != null) {
      lat = defaultAddress.lat!;
      lng = defaultAddress.lng!;
      debugPrint('HomeView: Su dung dia chi mac dinh - lat=$lat, lng=$lng');
    } else {
      debugPrint('HomeView: Bat dau lay GPS...');
      final gpsPos = await AddressService.getGpsPosition();
      if (gpsPos != null) {
        lat = gpsPos.latitude;
        lng = gpsPos.longitude;
        debugPrint('HomeView: [GPS OK] lat=${gpsPos.latitude}, lng=${gpsPos.longitude}');
      } else {
        debugPrint('HomeView: [GPS NULL] Khong lay duoc GPS, su dung toa do mac dinh');
        debugPrint('HomeView: Khong co dia chi, su dung toa do mac dinh - lat=$lat, lng=$lng');
      }
    }

    if (!mounted) return;

    setState(() {
      _lat = lat;
      _lng = lng;
      _nearbyStoresFuture = _storeService.getNearbyStores(lat: lat, lng: lng);
      _featuredProductsFuture = _productService.getFeaturedProducts();
      _popularStoresFuture = _storeService.getPopularStores(lat: lat, lng: lng);
    });
  }

  void _retryNearbyStores() {
    if (!mounted) return;
    setState(() {
      _nearbyStoresFuture = _storeService.getNearbyStores(lat: _lat, lng: _lng);
    });
  }

  void _retryFeaturedProducts() {
    if (!mounted) return;
    setState(() {
      _featuredProductsFuture = _productService.getFeaturedProducts();
    });
  }

  void _retryPopularStores() {
    if (!mounted) return;
    setState(() {
      _popularStoresFuture = _storeService.getPopularStores(lat: _lat, lng: _lng);
    });
  }

  /// Mo GreenBot chat overlay (hien thi tren trang chu).
  ///
  /// Dung `showGeneralDialog` de:
  ///   - Van giu trang chu ben duoi (khong push route moi).
  ///   - Tap ra ngoai vung chat se dong overlay (`barrierDismissible: true`).
  Future<void> _openGreenChat() async {
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Đóng GreenBot',
      barrierDismissible: true,
      barrierColor: const Color(0x66000000),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) => const GreenChatOverlay(),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  addressFuture: _defaultAddressFuture,
                  onEditAddress: () {
                    debugPrint(
                      'HomeView: Nguoi dung bam nut chinh sua dia chi',
                    );
                    Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressManagementView(),
                      ),
                    ).then((changed) {
                      if (changed == true) {
                        debugPrint('HomeView: Dia chi da thay doi, fetch lai du lieu');
                        _resolveLocationAndFetch();
                      }
                    });
                  },
                ),
              ),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: HomeCategories(
                    categoriesStream: _categoriesStream,
                    onCategoryTap: (category) {
                      debugPrint(
                        'HomeView: Nguoi dung bam danh muc [${category.name}]',
                      );
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _NearbyStoresSection(
                    future: _nearbyStoresFuture,
                    onSeeAllTap: () {
                      debugPrint('HomeView: Nguoi dung bam xem tat ca quan gan day');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NearbyStoresView(
                            lat: _lat,
                            lng: _lng,
                          ),
                        ),
                      );
                    },
                    onStoreTap: (store) {
                      debugPrint('HomeView: Nguoi dung bam quan [${store.name}]');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RestaurantDetailView(storeId: store.id),
                        ),
                      );
                    },
                    onRetry: _retryNearbyStores,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _FeaturedProductsSection(
                    future: _featuredProductsFuture,
                    onSeeAllTap: () {
                      debugPrint(
                        'HomeView: Nguoi dung bam xem tat ca mon noi bat',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeaturedProductsView(),
                        ),
                      );
                    },
                    onProductTap: (product) {
                      showProductDetailSheet(context, product);
                    },
                    onRetry: _retryFeaturedProducts,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _PopularStoresSection(
                    future: _popularStoresFuture,
                    onSeeAllTap: () {
                      debugPrint('HomeView: Nguoi dung bam xem tat ca quan pho bien');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PopularStoresView(
                            lat: _lat,
                            lng: _lng,
                          ),
                        ),
                      );
                    },
                    onStoreTap: (store) {
                      debugPrint('HomeView: Nguoi dung bam quan [${store.name}]');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RestaurantDetailView(storeId: store.id),
                        ),
                      );
                    },
                    onRetry: _retryPopularStores,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _GreenBotFab(onTap: _openGreenChat),
                const SizedBox(height: 12),
                _CartFab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Nut FAB GreenBot dat phia tren nut gio hang, nen trong suot.
///
/// Bam vao se mo bong bóng chat GreenChatOverlay.
class _GreenBotFab extends StatelessWidget {
  const _GreenBotFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'asset/img/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
        ),
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
          MaterialPageRoute(builder: (context) => const CartView()),
        );
      },
      backgroundColor: AppColors.primary,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.shopping_cart, color: Colors.white, size: 26),
    );
  }
}

/// Khoi noi dung "Quan ngon gan day" su dung FutureBuilder.
class _NearbyStoresSection extends StatelessWidget {
  final Future<List<StoreModel>> future;
  final VoidCallback? onSeeAllTap;
  final void Function(StoreModel store)? onStoreTap;
  final VoidCallback? onRetry;

  const _NearbyStoresSection({
    required this.future,
    this.onSeeAllTap,
    this.onStoreTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('home_near_you'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAllTap != null)
                GestureDetector(
                  onTap: onSeeAllTap,
                  child: Text(
                    context.t('common_see_all'),
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
        SizedBox(
          height: 200,
          child: FutureBuilder<List<StoreModel>>(
            future: future,
            builder: (context, snapshot) {
              // Dang tai.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const _StoreCardSkeleton(),
                );
              }

              // Co loi.
              if (snapshot.hasError) {
                debugPrint(
                    'HomeView: Loi tai quan gan day - ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade300),
                      const SizedBox(height: 8),
                      Text(
                        context.t('error_load_stores'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: onRetry,
                        child: Text(context.t('common_retry')),
                      ),
                    ],
                  ),
                );
              }

              final stores = snapshot.data ?? [];

              // Rong.
              if (stores.isEmpty) {
                return Center(
                  child: Text(
                    context.t('empty_stores'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: stores.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return _StoreCard(
                    store: store,
                    onTap: () => onStoreTap?.call(store),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Khoi noi dung "Mon an noi bat" su dung FutureBuilder.
class _FeaturedProductsSection extends StatelessWidget {
  final Future<List<ProductModel>> future;
  final VoidCallback? onSeeAllTap;
  final void Function(ProductModel product)? onProductTap;
  final VoidCallback? onRetry;

  const _FeaturedProductsSection({
    required this.future,
    this.onSeeAllTap,
    this.onProductTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('home_featured_foods'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAllTap != null)
                GestureDetector(
                  onTap: onSeeAllTap,
                  child: Text(
                    context.t('common_see_all'),
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
        SizedBox(
          height: 240,
          child: FutureBuilder<List<ProductModel>>(
            future: future,
            builder: (context, snapshot) {
              // Dang tai.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const _ProductCardSkeleton(),
                );
              }

              // Co loi.
              if (snapshot.hasError) {
                debugPrint(
                    'HomeView: Loi tai mon an noi bat - ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade300),
                      const SizedBox(height: 8),
                      Text(
                        context.t('error_load_products'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: onRetry,
                        child: Text(context.t('common_retry')),
                      ),
                    ],
                  ),
                );
              }

              final products = snapshot.data ?? [];

              // Rong.
              if (products.isEmpty) {
                return Center(
                  child: Text(
                    context.t('empty_products'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductCard(
                    product: product,
                    onTap: () => onProductTap?.call(product),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Khoi noi dung "Quan pho bien" - lay nearby_stores dao nguoc danh sach.
class _PopularStoresSection extends StatelessWidget {
  final Future<List<StoreModel>> future;
  final VoidCallback? onSeeAllTap;
  final void Function(StoreModel store)? onStoreTap;
  final VoidCallback? onRetry;

  const _PopularStoresSection({
    required this.future,
    this.onSeeAllTap,
    this.onStoreTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.t('home_popular_stores'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 660,
          child: FutureBuilder<List<StoreModel>>(
            future: future,
          builder: (context, snapshot) {
            // Dang tai.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const _VerticalStoreItemSkeleton(),
              );
            }

            // Co loi.
            if (snapshot.hasError) {
              debugPrint(
                  'HomeView: Loi tai quan pho bien - ${snapshot.error}');
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade300),
                      const SizedBox(height: 8),
                      Text(
                        context.t('error_load_stores'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: onRetry,
                        child: Text(context.t('common_retry')),
                      ),
                    ],
                  ),
                ),
              );
            }

            final allStores = snapshot.data ?? [];
            if (allStores.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    context.t('empty_stores'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }

            final popularStores = allStores.take(5).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: popularStores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final store = popularStores[index];
                return _VerticalStoreItem(
                  store: store,
                  onTap: () => onStoreTap?.call(store),
                );
              },
            );
          },
          ),
        ),
      ],
    );
  }
}

/// Card hien thi thong tin quan (Horizontal).
class _StoreCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback? onTap;

  const _StoreCard({required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                store.backUrl.trim().isNotEmpty ? store.backUrl.trim() : store.avtUrl.trim(),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.store, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        store.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${store.reviewCount})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text(
                        '${store.distance.toStringAsFixed(1)} ${context.t('unit_km')}',
                        style: TextStyle(fontSize: 11, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 2),
                      Text(
                        store.deliveryTime,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.address,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card hien thi thong tin mon an (Horizontal).
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const _ProductCard({required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                  if (product.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            context.t('home_out_of_stock'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formatCurrency(product.basePrice, context),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (product.sales != null && product.sales! > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${context.t('home_sold_count')} ${product.sales ?? 0}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.rating != null) ...[
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (product.distance != null) ...[
                        Icon(Icons.location_on, size: 12, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${product.distance?.toStringAsFixed(1) ?? '0'} ${context.t('unit_km')}',
                          style: TextStyle(fontSize: 11, color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                  if (product.address != null && product.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.store, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            product.storeName ?? product.address!,
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (product.deliveryTime != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          product.deliveryTime!,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item hien thi quan theo chieu doc (Vertical).
class _VerticalStoreItem extends StatelessWidget {
  final StoreModel store;
  final VoidCallback? onTap;

  const _VerticalStoreItem({required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                store.avtUrl.trim().isNotEmpty
                    ? store.avtUrl.trim()
                    : store.backUrl.trim().isNotEmpty
                        ? store.backUrl.trim()
                        : '',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Icon(Icons.store, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.address,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        store.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${store.reviewCount} ${context.t('unit_rating')})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: store.isOpen ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          store.isOpen
                              ? context.t('home_open')
                              : context.t('home_closed'),
                          style: TextStyle(
                            fontSize: 11,
                            color: store.isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, size: 14, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text(
                        '${store.distance.toStringAsFixed(1)} ${context.t('unit_km')}',
                        style: TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        store.deliveryTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton card hien thi khi loading (Horizontal Store).
class _StoreCardSkeleton extends StatelessWidget {
  const _StoreCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton card hien thi khi loading (Horizontal Product).
class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton item hien thi khi loading (Vertical Store).
class _VerticalStoreItemSkeleton extends StatelessWidget {
  const _VerticalStoreItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
