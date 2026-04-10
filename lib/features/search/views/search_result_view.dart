import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../cart/views/cart_view.dart';
import '../../store/services/store_service.dart';
import '../../home/models/store_model.dart';
import 'widgets/search_filter_bar.dart';

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
  final StoreService _storeService = const StoreService();
  SearchSortType _selectedSort = SearchSortType.none;

  late final Future<List<StoreModel>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = _storeService.searchStores(widget.query);
  }

  /// Tra ve danh sach da duoc loc/sap xep.
  List<StoreModel> _sortResults(List<StoreModel> stores) {
    switch (_selectedSort) {
      case SearchSortType.priceAsc:
        return List.from(stores)
          ..sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
      case SearchSortType.priceDesc:
        return List.from(stores)
          ..sort((a, b) => b.deliveryFee.compareTo(a.deliveryFee));
      case SearchSortType.ratingDesc:
        return List.from(stores)..sort((a, b) => b.rating.compareTo(a.rating));
      case SearchSortType.none:
        return stores;
    }
  }

  void _onSortChanged(SearchSortType sort) {
    setState(() {
      _selectedSort = _selectedSort == sort ? SearchSortType.none : sort;
    });
    debugPrint('Sap xep thay doi: $_selectedSort');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header: nut Back + thanh tim kiem.
          _buildHeader(),
          // Divider ngan cach header va filter bar.
          Container(height: 1, color: AppColors.divider),
          // Thanh loc FilterChip.
          SearchFilterBar(
            selectedSort: _selectedSort,
            onSortChanged: _onSortChanged,
          ),
          // Divider ngan cach filter va danh sach.
          Container(height: 1, color: AppColors.divider),
          // Danh sach ket qua - FutureBuilder.
          Expanded(
            child: _buildResultsBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBody() {
    return FutureBuilder<List<StoreModel>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        // Dang tai.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // Co loi.
        if (snapshot.hasError) {
          debugPrint('SearchResultView: loi API - ${snapshot.error}');
          return _buildErrorState(snapshot.error.toString());
        }

        final allResults = snapshot.data ?? [];
        final results = _sortResults(allResults);

        // Rong.
        if (results.isEmpty) {
          return _buildEmptyState();
        }

        // Co du lieu -> hien thi danh sach.
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final store = results[index];
            return _StoreResultCard(
              store: store,
              onTap: () {
                debugPrint(
                    'SearchResultView: Nguoi dung bam quan [${store.name}]');
              },
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
      itemBuilder: (_, __) => const _StoreResultCardSkeleton(),
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
              onPressed: () {
                setState(() {
                  _searchFuture = _storeService.searchStores(widget.query);
                });
              },
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
          // Nut gio hang.
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
        ],
      ),
    );
  }
}

/// Card hien thi ket qua quan trong danh sach tim kiem.
class _StoreResultCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback? onTap;

  const _StoreResultCard({required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hinh anh cua hang.
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  store.avtUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.store,
                      color: AppColors.textHint,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Thong tin cua hang.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.address,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Danh gia + thoi gian giao.
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          store.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${store.reviewCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.deliveryTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${store.distance.toStringAsFixed(1)} ${context.t('unit_km')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Trang thai mo cua + phi giao hang.
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: store.isOpen
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            store.isOpen
                                ? context.t('home_open')
                                : context.t('home_closed'),
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  store.isOpen ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${store.deliveryFee.toStringAsFixed(0)} ${context.t('unit_currency')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Nut them vao gio hang.
              GestureDetector(
                onTap: () {
                  debugPrint(
                      'SearchResultView: Them vao gio [${store.name}]');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${store.name} da duoc them'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
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
        ),
      ),
    );
  }
}

/// Skeleton card khi loading ket qua.
class _StoreResultCardSkeleton extends StatelessWidget {
  const _StoreResultCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Container(
                  width: 120,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
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
          ),
        ],
      ),
    );
  }
}
