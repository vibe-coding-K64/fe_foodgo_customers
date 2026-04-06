import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../features/home/models/store_model.dart';
import '../../../features/home/models/product_model.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_category_model.dart';
import 'restaurant_reviews_view.dart';

/// Trang chi tiet quan an.
///
/// Su dung CustomScrollView ket hop SliverPersistentHeader de co
/// thanh danh muc mon an sticky khi cuon.
///
/// Tum xuong duoi se thay:
///   1. SliverAppBar: Anh bi thu nho + Tieu de xuat hien tren AppBar.
///   2. Thong tin co ban: Avatar, Ten, Khoang cach, Danh gia (clickable).
///   3. Danh muc sticky: StickyHeader nam ngay duoi AppBar.
///   4. Danh sach mon: SliverList cac mon an theo danh muc.
class RestaurantDetailView extends StatefulWidget {
  final String storeId;

  const RestaurantDetailView({
    super.key,
    required this.storeId,
  });

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  // Store mock data.
  late StoreModel _store;
  late List<RestaurantCategoryModel> _categories;
  late String _selectedCategoryId;

  // Vi tri tab danh muc dang duoc chon.
  int _selectedCategoryIndex = 0;

  // Scroll controller de di chuyen thanh danh muc khi bam tab.
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store = RestaurantService.getMockStore(widget.storeId);
    _categories = RestaurantService.getCategories();
    _selectedCategoryId = _categories.first.id;
    debugPrint(
        'RestaurantDetailView: Khoi tao trang chi tiet quan [${_store.name}]');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Xu ly khi nguoi dung bam vao tab danh muc.
  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedCategoryId = _categories[index].id;
    });
    debugPrint(
        'RestaurantDetailView: Nguoi dung bam danh muc [${_categories[index].name}]');
  }

  // Xu ly khi nguoi dung bam vao block danh gia.
  void _onRatingTap() {
    debugPrint('Chuyen sang trang Danh gia');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantReviewsView(storeId: widget.storeId),
      ),
    );
  }

  // Xu ly khi nguoi dung bam nut (+) them mon vao gio hang.
  void _onAddToCart(ProductModel product) {
    debugPrint(
        'RestaurantDetailView: Nguoi dung them mon [${product.name}] vao gio hang');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${LanguageService.translate('success_add_to_cart')} ${product.name}',
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Lay key localization cua danh muc theo id.
  String _getCategoryDisplayName(RestaurantCategoryModel category) {
    final keyMap = <String, String>{
      'all': 'category_all',
      'drinks': 'category_drinks',
      'fast_food': 'category_fast_food',
      'vietnamese': 'category_vietnamese',
      'snacks': 'category_snacks',
      'dessert': 'category_dessert',
      'breakfast': 'category_breakfast',
      'seafood': 'category_seafood',
    };
    final key = keyMap[category.id] ?? category.name;
    return LanguageService.translate(key);
  }

  @override
  Widget build(BuildContext context) {
    final distance = RestaurantService.getMockDistance();

    return Scaffold(
      // Body la CustomScrollView chua cac Sliver.
      body: CustomScrollView(
        controller: _scrollController,

        // ========== 1. SLIVER APP BAR (ANH BIA + TIEU DE) ==========
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            // Anhnen gradient phia sau tieu de.
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _store.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Anh bia.
                  Image.network(
                    _store.backUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryLight,
                        child: const Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                  // Gradient de tieu de de doc hon.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon:
                      const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    debugPrint(
                        'RestaurantDetailView: Nguoi dung bam yeu thich');
                  },
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    debugPrint('RestaurantDetailView: Nguoi dung bam chia se');
                  },
                ),
              ),
            ],
          ),

          // ========== 2. THONG TIN CO BAN (AVATAR, TEN, KHOANG CACH, DANH GIA) ==========
          SliverToBoxAdapter(
            child: _StoreInfoSection(
              store: _store,
              distance: distance,
              onRatingTap: _onRatingTap,
            ),
          ),

          // ========== 3. STICKY HEADER - DANH MUC MON AN ==========
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryTabsDelegate(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategoryTap: _onCategoryTap,
              getDisplayName: _getCategoryDisplayName,
            ),
          ),

          // ========== 4. DANH SACH MON AN ==========
          // Su dung StreamBuilder de lay san pham theo danh muc da chon.
          StreamBuilder<List<ProductModel>>(
            stream: RestaurantService.getProductsByCategoryStream(
              widget.storeId,
              _selectedCategoryId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child:
                        Text(LanguageService.translate('error_load_products')),
                  ),
                );
              }
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      LanguageService.translate('empty_products'),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return _FoodItemTile(
                      product: product,
                      onAddToCart: () => _onAddToCart(product),
                    );
                  },
                  childCount: products.length,
                ),
              );
            },
          ),

          // Khoang trong cuoi cung.
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: PHAN THONG TIN CO BAN CUA QUAN
// (Avatar, Ten, Khoang cach, Danh gia clickable)
// ================================================================

class _StoreInfoSection extends StatelessWidget {
  final StoreModel store;
  final double distance;
  final VoidCallback onRatingTap;

  const _StoreInfoSection({
    required this.store,
    required this.distance,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar — placed below cover image with white border and shadow.
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: store.avtUrl.isNotEmpty
                  ? NetworkImage(store.avtUrl)
                  : null,
              child: store.avtUrl.isEmpty
                  ? Icon(
                      Icons.restaurant,
                      size: 36,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ),

          // Gap between avatar and name.
          const SizedBox(height: 12),

          // Store name.
          Text(
            store.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // Distance and delivery time.
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${LanguageService.translate('restaurant_distance')} $distance ${LanguageService.translate('unit_km')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${LanguageService.translate('restaurant_delivery_time')} ${store.deliveryTime}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Delivery fee.
          Row(
            children: [
              Icon(
                Icons.delivery_dining_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${LanguageService.translate('restaurant_delivery_fee')}: ${_formatPrice(store.deliveryFee)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Rating block (clickable).
          InkWell(
            onTap: onRatingTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Yellow star icon.
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  // Star count.
                  Text(
                    store.rating.toStringAsFixed(1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Review count.
                  Text(
                    '${_formatReviewCount(store.reviewCount)} ${LanguageService.translate('restaurant_reviews_count')}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Chevron.
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Divider(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == 0) {
      return LanguageService.translate('home_free_delivery');
    }
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formatted VND';
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K+';
    }
    return count.toString();
  }
}

// ================================================================
// WIDGET: TIEN DAO STICKY - DANH MUC TAB
// Su dung SliverPersistentHeaderDelegate de tao sticky header.
// ================================================================

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final List<RestaurantCategoryModel> categories;
  final int selectedIndex;
  final Function(int) onCategoryTap;
  final String Function(RestaurantCategoryModel) getDisplayName;

  _CategoryTabsDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
    required this.getDisplayName,
  });

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  bool shouldRebuild(covariant _CategoryTabsDelegate oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.categories != categories;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onCategoryTap(index),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            getDisplayName(category),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Duong ke phan cach duoi cung.
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.divider,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: ITEM MON AN
// (Anh, Ten, Mo ta, Gia, Nut +)
// ================================================================

class _FoodItemTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const _FoodItemTile({
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== ANH MON AN ==========
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Image.network(
                  product.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.fastfood,
                        size: 32,
                        color: AppColors.textHint,
                      ),
                    );
                  },
                ),
                // Neu het hang thi hien thi overlay.
                if (product.isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        LanguageService.translate('product_out_of_stock'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ========== THONG TIN MON AN ==========
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ten mon.
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Mo ta ngan.
                Text(
                  product.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Gia tien (mau xanh la) + Nut them.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gia.
                    Text(
                      _formatPrice(product.basePrice),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Nut (+) them vao gio.
                    if (!product.isOutOfStock)
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formatted VND';
  }
}
