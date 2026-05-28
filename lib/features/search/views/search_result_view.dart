import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/state/cart_state.dart';
import '../../../core/utils/auth_storage.dart';
import '../../cart/views/cart_view.dart';
import '../../home/models/product_model.dart';
import '../../product/views/product_detail_bottom_sheet.dart';
import '../models/search_result_item.dart';
import '../services/services.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/search_result_card.dart';

/// Man hinh Ket qua tim kiem / Danh muc.
///
/// Hien thi ket qua tim kiem voi header co thanh tim kiem,
/// thanh loc FilterChip ngang, va danh sach san pham doc xuong.
///
/// Su dung FutureBuilder goi StoreService.searchStores(keyword).
class SearchResultView extends StatefulWidget {
  /// Tu khoa tim kiem hien thi trong thanh tim kiem (VD: "Tra sua").
  final String query;

  const SearchResultView({super.key, required this.query});

  @override
  State<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> {
  final ApiSearchService _apiSearchService = const ApiSearchService();
  SearchSortType _selectedSort = SearchSortType.none;
  double? _minPrice;
  double? _maxPrice;
  double? _minRating;

  List<SearchResultItem> _allResults = [];
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  Future<void> _fetchSearchResults() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final userLat = AuthStorage.getUserLatitude() ?? 10.8500;
      final userLng = AuthStorage.getUserLongitude() ?? 106.7900;
      final userId = AuthStorage.getUserId();

      final results = await _apiSearchService.fetchSearchResults(
        keyword: widget.query,
        userLat: userLat,
        userLng: userLng,
        sortBy: null,
        userId: userId,
      );

      setState(() {
        _allResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e;
        _isLoading = false;
      });
    }
  }

  List<SearchResultItem> get _filteredResults {
    var results = List<SearchResultItem>.from(_allResults);

    if (_minPrice != null) {
      results = results.where((r) => r.price >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      results = results.where((r) => r.price <= _maxPrice!).toList();
    }
    if (_minRating != null) {
      results = results.where((r) => r.rating >= _minRating!).toList();
    }

    switch (_selectedSort) {
      case SearchSortType.priceAsc:
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SearchSortType.priceDesc:
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SearchSortType.ratingDesc:
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SearchSortType.none:
        break;
    }

    return results;
  }

  void _onSortChanged(SearchSortType sort) {
    setState(() {
      _selectedSort = _selectedSort == sort ? SearchSortType.none : sort;
    });
  }

  void _onPriceFilterChanged(double? min, double? max) {
    setState(() {
      _minPrice = min;
      _maxPrice = max;
    });
  }

  void _onRatingFilterChanged(double? min) {
    setState(() {
      _minRating = _minRating == min ? null : min;
    });
  }

  /// Chuyen SearchResultItem thanh ProductModel de mo bottom sheet.
  ProductModel _toProductModel(SearchResultItem item) {
    return ProductModel(
      id: item.productId,
      storeId: item.storeId,
      categoryId: '',
      categoryName: '',
      name: item.productName,
      description: '',
      basePrice: item.price,
      imageUrl: item.imageUrl,
      isOutOfStock: item.isOutOfStock,
      isFeatured: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      optionGroups: item.optionGroups
          .map((g) => OptionGroupModel.fromJson(g))
          .toList(),
    );
  }

  void _onAddToCart(SearchResultItem item) {
    final userId = AuthStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('auth_login')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (item.isOutOfStock) return;

    final product = _toProductModel(item);

    // Neu co option (size/topping) -> mo bottom sheet.
    if (item.optionGroups.isNotEmpty) {
      showProductDetailSheet(context, product);
      return;
    }

    // Khong co option -> add truc tiep.
    _addDirectlyToCart(item, product);
  }

  Future<void> _addDirectlyToCart(
      SearchResultItem item, ProductModel product) async {
    final userId = AuthStorage.getUserId();
    if (userId == null) return;

    final cartState = CartState.of(context);
    final result = await cartState.addItem(
      userId,
      product,
      quantity: 1,
    );

    if (!mounted) return;

    switch (result) {
      case CartAddResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.productName} ${context.t('success_add_to_cart')}'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
        break;
      case CartAddResult.differentStore:
        _showDifferentStoreDialog(cartState, item, product);
        break;
      case CartAddResult.outOfStock:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartState.errorMessage ?? 'Mon an dang het hang.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case CartAddResult.notFound:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartState.errorMessage ?? 'San pham khong ton tai.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case CartAddResult.otherError:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(cartState.errorMessage ?? 'Loi them vao gio hang.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  void _showDifferentStoreDialog(
      CartState cartState, SearchResultItem item, ProductModel product) {
    final message = cartState.differentStoreErrorMessage ??
        'Gio hang hien co mon tu cua hang khac. Ban co muon xoa gio hang hien tai de them mon nay?';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cua hang khac'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Huy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () async {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${item.productName} ${context.t('success_add_to_cart')}'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        cartState.errorMessage ?? 'Loi them vao gio hang.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xoa va them moi'),
          ),
        ],
      ),
    );
  }

  /// Lay so luong trong gio cua mot san pham.
  int _getCartQuantity(String productId, CartState cartState) {
    try {
      final item = cartState.items.where((i) => i.foodId == productId).toList();
      if (item.isEmpty) return 0;
      return item.fold(0, (sum, i) => sum + i.quantity);
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Container(height: 1, color: AppColors.divider),
          SearchFilterBar(
            selectedSort: _selectedSort,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            minRating: _minRating,
            onSortChanged: _onSortChanged,
            onPriceFilterChanged: _onPriceFilterChanged,
            onRatingFilterChanged: _onRatingFilterChanged,
          ),
          Container(height: 1, color: AppColors.divider),
          Expanded(
            child: _buildResultsBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_loadError != null) {
      debugPrint('SearchResultView: loi API - $_loadError');
      return _buildErrorState(_loadError.toString());
    }

    final allResults = _filteredResults;

    if (allResults.isEmpty) {
      return _buildEmptyState();
    }

    return ListenableBuilder(
      listenable: CartState.of(context),
      builder: (context, _) {
        final cartState = CartState.of(context);
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: allResults.length,
          itemBuilder: (context, index) {
            final item = allResults[index];
            final cartQty = _getCartQuantity(item.productId, cartState);
            return SearchResultCard(
              item: item,
              cartQuantity: cartQty,
              onTap: () {
                debugPrint(
                    'SearchResultView: Nguoi dung bam san pham [${item.productName}]');
                final product = _toProductModel(item);
                showProductDetailSheet(context, product);
              },
              onAddToCart: () => _onAddToCart(item),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _SearchResultCardSkeleton(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              context.t('error_server'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchSearchResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(context.t('common_retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            context.t('search_no_results'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('search_try_different'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 4,
        right: 8,
        bottom: 8,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          // Nut Back.
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            padding: const EdgeInsets.all(8),
          ),
          // Thanh tim kiem hien thi tu khoa (an vao de quay ve SearchView).
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textHint, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.query,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Nut gio hang + badge.
          _buildCartButton(),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return ListenableBuilder(
      listenable: CartState.of(context),
      builder: (context, _) {
        final cartState = CartState.of(context);
        final count = cartState.itemCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                debugPrint('SearchResultView: Nguoi dung bam icon gio hang');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartView()),
                );
              },
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textPrimary,
              ),
              padding: const EdgeInsets.all(8),
            ),
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Skeleton card khi loading ket qua.
class _SearchResultCardSkeleton extends StatelessWidget {
  const _SearchResultCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hinh anh san pham.
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ten san pham.
                Container(
                  width: 140,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                // Ten cua hang.
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                // Gia + danh gia.
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
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
}
