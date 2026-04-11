import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../cart/views/cart_view.dart';
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

  late final Future<List<SearchResultItem>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = _apiSearchService.fetchSearchResults(widget.query);
  }

  /// Tra ve danh sach da duoc loc/sap xep.
  List<SearchResultItem> _sortResults(List<SearchResultItem> items) {
    switch (_selectedSort) {
      case SearchSortType.priceAsc:
        return List.from(items)..sort((a, b) => a.price.compareTo(b.price));
      case SearchSortType.priceDesc:
        return List.from(items)..sort((a, b) => b.price.compareTo(a.price));
      case SearchSortType.ratingDesc:
        return List.from(items)..sort((a, b) => b.rating.compareTo(a.rating));
      case SearchSortType.none:
        return items;
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
    return FutureBuilder<List<SearchResultItem>>(
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
            final item = results[index];
            return SearchResultCard(
              item: item,
              onTap: () {
                debugPrint(
                    'SearchResultView: Nguoi dung bam san pham [${item.productName}]');
              },
              onAddToCart: () {
                debugPrint(
                    'SearchResultView: Them vao gio [${item.productName}]');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.productName} da duoc them'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                  ),
                );
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
              onPressed: () {
                setState(() {
                  _searchFuture =
                      _apiSearchService.fetchSearchResults(widget.query);
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
