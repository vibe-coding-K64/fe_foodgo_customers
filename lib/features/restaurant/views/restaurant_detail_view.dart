import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/state/cart_state.dart';
import '../../../core/utils/auth_storage.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../home/models/store_model.dart';
import '../../home/models/product_model.dart';
import '../../cart/views/cart_view.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_category_model.dart';
import '../models/restaurant_detail_response.dart';
import 'restaurant_reviews_view.dart';
import '../../product/views/product_detail_bottom_sheet.dart';

/// Trang chi tiet quan an.
///
/// Su dung CustomScrollView ket hop SliverPersistentHeader de co
/// thanh danh muc mon an sticky khi cuon.
///
/// Tum xuong duoi se thay:
///   1. SliverAppBar: Anh bia + Tieu de xuat hien tren AppBar.
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
  // Du lieu tu API.
  RestaurantDetailResponse? _detail;
  StoreModel? _store;
  List<RestaurantCategoryModel> _categories = [];
  List<ProductModel> _allProducts = [];
  String _selectedCategoryId = 'all';

  // Trang thai loading.
  bool _isLoading = true;
  String? _errorMessage;
  /// Tap productId dang duoc add de hien thi loading icon tren tile.
  final Set<String> _addingProductIds = {};
  /// ProductId dang mo bottom sheet de configure.
  String? _productIdBeingConfigured;

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetail();
  }

  Future<void> _loadRestaurantDetail() async {
    try {
      final detail = await RestaurantService.getRestaurantDetail(widget.storeId);
      if (mounted) {
        setState(() {
          _detail = detail;
          _store = detail.store;
          _categories = detail.categories;
          _allProducts = detail.products;
          _isLoading = false;

          // Chon danh muc dau tien neu co.
          if (detail.categories.isNotEmpty) {
            _selectedCategoryId = detail.categories.first.id;
          }

          if (_store == null) {
            _errorMessage = 'Khong tim thay cua hang';
          }
        });
        debugPrint(
            'RestaurantDetailView: Da lay chi tiet - store: ${_store?.name}, '
            'categories: ${_categories.length}, products: ${_allProducts.length}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Khong the tai thong tin cua hang';
        });
        debugPrint('RestaurantDetailView: Loi loadRestaurantDetail - $e');
      }
    }
  }

  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategoryId = _categories[index].id;
    });
    debugPrint(
        'RestaurantDetailView: Nguoi dung bam danh muc [${_categories[index].name}]');
  }

  void _onRatingTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantReviewsView(storeId: widget.storeId),
      ),
    );
  }

  void _onAddToCart(ProductModel product) {
    if (_addingProductIds.contains(product.id)) return;

    // Co option -> mo bottom sheet de configure.
    if (product.optionGroups.isNotEmpty) {
      setState(() => _addingProductIds.add(product.id));
      showProductDetailSheet(context, product).then((_) {
        if (mounted) {
          setState(() => _addingProductIds.remove(product.id));
        }
      });
      return;
    }

    // Khong co option -> add truc tiep.
    _addDirectlyToCart(product);
  }

  Future<void> _addDirectlyToCart(ProductModel product) async {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      showTopSnackBar(
        context,
        message: context.t('auth_login'),
        backgroundColor: AppColors.error,
      );
      return;
    }

    if (product.isOutOfStock) return;

    setState(() => _addingProductIds.add(product.id));

    final cartState = CartState.of(context);
    CartAddResult result;
    try {
      result = await cartState.addItem(
        userId,
        product,
        quantity: 1,
      );
    } finally {
      if (mounted) {
        setState(() => _addingProductIds.remove(product.id));
      }
    }

    if (!mounted) return;

    switch (result) {
      case CartAddResult.success:
        showTopSnackBar(
          context,
          message: '${product.name} ${context.t('success_add_to_cart')}',
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        );
        break;
      case CartAddResult.differentStore:
        _showDifferentStoreDialog(cartState, product);
        break;
      case CartAddResult.outOfStock:
        showTopSnackBar(
          context,
          message: cartState.errorMessage ?? 'Mon an dang het hang.',
          backgroundColor: AppColors.error,
        );
        break;
      case CartAddResult.notFound:
        showTopSnackBar(
          context,
          message: cartState.errorMessage ?? 'San pham khong ton tai.',
          backgroundColor: AppColors.error,
        );
        break;
      case CartAddResult.otherError:
        showTopSnackBar(
          context,
          message: cartState.errorMessage ?? 'Loi them vao gio hang.',
          backgroundColor: AppColors.error,
        );
        break;
    }
  }

  void _showDifferentStoreDialog(CartState cartState, ProductModel product) {
    final message = cartState.differentStoreErrorMessage ??
        'Gio hang hien co mon tu cua hang khac. Ban co muon xoa gio hang hien tai de them mon nay?';

    bool dialogIsAdding = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cua hang khac'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: dialogIsAdding ? null : () => Navigator.pop(ctx),
              child: Text(
                'Huy',
                style: TextStyle(
                  color: dialogIsAdding
                      ? AppColors.textHint
                      : AppColors.textSecondary,
                ),
              ),
            ),
            FilledButton(
              onPressed: dialogIsAdding
                  ? null
                  : () async {
                      setDialogState(() => dialogIsAdding = true);
                      Navigator.pop(ctx);
                      final userId = AuthStorage.getUserId();
                      if (userId == null) return;

                      final result = await cartState.replaceCartAndAddItem(
                        userId,
                        product,
                        quantity: 1,
                      );

                      if (!mounted) return;

                      if (result == CartAddResult.success) {
                        Navigator.pop(context);
                        showTopSnackBar(
                          context,
                          message:
                              '${product.name} ${context.t('success_add_to_cart')}',
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 1),
                        );
                      } else {
                        showTopSnackBar(
                          context,
                          message:
                              cartState.errorMessage ?? 'Loi them vao gio hang.',
                          backgroundColor: AppColors.error,
                        );
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              ),
              child: dialogIsAdding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Xoa va them moi'),
            ),
          ],
        ),
      ),
    );
  }

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
    return context.t(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ========== 1. SLIVER APP BAR ==========
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _store?.name ?? '...',
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
                  if (_store != null)
                    Image.network(
                      _store!.backUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryLight,
                        child: const Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  else
                    Container(color: AppColors.primaryLight),
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
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartView(),
                      ),
                    );
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

          // ========== 2. THONG TIN CO BAN ==========
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_store == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    _errorMessage ?? 'Khong the tai thong tin cua hang',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: _StoreInfoSection(
                store: _store!,
                onRatingTap: _onRatingTap,
              ),
            ),

          // ========== 3. STICKY HEADER - DANH MUC ==========
          if (_isLoading)
            const SliverToBoxAdapter(
              child: SizedBox(height: 52),
            )
          else if (_categories.isNotEmpty)
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryTabsDelegate(
                categories: _categories,
                selectedId: _selectedCategoryId,
                onCategoryTap: _onCategoryTap,
                getDisplayName: _getCategoryDisplayName,
              ),
            ),

          // ========== 4. DANH SACH MON AN ==========
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_store == null)
            const SliverFillRemaining(
              child: SizedBox(height: 200),
            )
          else if (_allProducts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  context.t('empty_products'),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final products = _selectedCategoryId == 'all'
                      ? _allProducts
                      : _allProducts
                          .where((p) => p.categoryId == _selectedCategoryId)
                          .toList();
                  if (index >= products.length) return null;
                  final product = products[index];
                  return _FoodItemTile(
                    product: product,
                    isAddingToCart: _addingProductIds.contains(product.id),
                    onAddToCart: () => _onAddToCart(product),
                  );
                },
                childCount: (_selectedCategoryId == 'all'
                        ? _allProducts
                        : _allProducts
                            .where(
                                (p) => p.categoryId == _selectedCategoryId)
                            .toList())
                    .length,
              ),
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
// ================================================================

class _StoreInfoSection extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onRatingTap;

  const _StoreInfoSection({
    required this.store,
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
          // Avatar.
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
            child: store.avtUrl.trim().isNotEmpty
                ? CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: NetworkImage(
                      store.avtUrl.trim(),
                      headers: {'Accept': 'image/*'},
                    ),
                    onBackgroundImageError: (_, __) {},
                  )
                : CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.restaurant,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          // Ten cua hang.
          Text(
            store.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // Thoi gian giao.
          Row(
            children: [
              Icon(
                Icons.delivery_dining_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${context.t('restaurant_delivery_fee')}: ${_formatPrice(store.deliveryFee)}',
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
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    store.rating.toStringAsFixed(1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatReviewCount(store.reviewCount)} ${context.t('restaurant_reviews_count')}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
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
    return '$formatted ${LanguageService.translate('unit_currency')}';
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
// ================================================================

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final List<RestaurantCategoryModel> categories;
  final String selectedId;
  final Function(int) onCategoryTap;
  final String Function(RestaurantCategoryModel) getDisplayName;

  _CategoryTabsDelegate({
    required this.categories,
    required this.selectedId,
    required this.onCategoryTap,
    required this.getDisplayName,
  });

  int get _selectedIndex {
    final idx = categories.indexWhere((c) => c.id == selectedId);
    return idx >= 0 ? idx : 0;
  }

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  bool shouldRebuild(covariant _CategoryTabsDelegate oldDelegate) {
    return oldDelegate.selectedId != selectedId ||
        oldDelegate.categories != categories;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final selectedIdx = _selectedIndex;
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
                final isSelected = index == selectedIdx;
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
// ================================================================

class _FoodItemTile extends StatelessWidget {
  final ProductModel product;
  final bool isAddingToCart;
  final VoidCallback onAddToCart;

  const _FoodItemTile({
    required this.product,
    required this.isAddingToCart,
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
          // Anh mon an.
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
                if (product.isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.t('product_out_of_stock'),
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

          // Thong tin mon an.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  product.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formatPrice(product.basePrice),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isAddingToCart)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else if (!product.isOutOfStock)
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
    return '$formatted ${LanguageService.translate('unit_currency')}';
  }
}
