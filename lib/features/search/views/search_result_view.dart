import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../cart/views/cart_view.dart';
import '../models/search_result_item.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/search_result_card.dart';

/// Man hinh Ket qua tim kiem / Danh muc.
///
/// Hien thi ket qua tim kiem voi header co thanh tim kiem,
/// thanh loc FilterChip ngang, va danh sach san pham doc xuong.
class SearchResultView extends StatefulWidget {
  /// Tu khoa tim kiem hien thi trong thanh tim kiem (VD: "Tra sua").
  final String query;

  const SearchResultView({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> {
  /// Kieu sap xep / loc hien tai.
  SearchSortType _selectedSort = SearchSortType.none;

  /// Danh sach ket qua tim kiem (mock data).
  late final List<SearchResultItem> _allResults;

  @override
  void initState() {
    super.initState();
    _allResults = _buildMockResults();
  }

  /// Tao danh sach ket qua mock (5-6 san pham mau).
  ///
  /// Cac truong hop:
  ///   - Tra sua: co san pham con hang va het hang.
  ///   - Gia va danh gia khac nhau de test loc/sap xep.
  List<SearchResultItem> _buildMockResults() {
    return [
      SearchResultItem(
        id: 'sr1',
        productId: 'p1',
        storeId: 's1',
        productName: 'Tra Sua Tran Chau Duong Den',
        productImageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=200&q=80',
        price: 35000,
        storeName: 'Tralines - Tra Sua',
        rating: 4.8,
        reviewCount: 1240,
        isOutOfStock: false,
      ),
      SearchResultItem(
        id: 'sr2',
        productId: 'p2',
        storeId: 's1',
        productName: 'Tra Sua Khoai Mon',
        productImageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=200&q=80',
        price: 40000,
        storeName: 'Tralines - Tra Sua',
        rating: 4.6,
        reviewCount: 856,
        isOutOfStock: false,
      ),
      SearchResultItem(
        id: 'sr3',
        productId: 'p3',
        storeId: 's2',
        productName: 'Tra Sua Thai Do',
        productImageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=200&q=80',
        price: 45000,
        storeName: 'Che Ngon - Tra & Cafe',
        rating: 4.9,
        reviewCount: 2100,
        isOutOfStock: false,
      ),
      SearchResultItem(
        id: 'sr4',
        productId: 'p4',
        storeId: 's2',
        productName: 'Tra Sen Vang Mac Dat',
        productImageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=200&q=80',
        price: 28000,
        storeName: 'Che Ngon - Tra & Cafe',
        rating: 4.3,
        reviewCount: 430,
        isOutOfStock: true,
      ),
      SearchResultItem(
        id: 'sr5',
        productId: 'p5',
        storeId: 's3',
        productName: 'Tra Sua Bo Tan',
        productImageUrl: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=200&q=80',
        price: 55000,
        storeName: 'Gong Cha Vietnam',
        rating: 4.7,
        reviewCount: 3200,
        isOutOfStock: false,
      ),
      SearchResultItem(
        id: 'sr6',
        productId: 'p6',
        storeId: 's3',
        productName: 'Tra Hai Rang',
        productImageUrl: 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=200&q=80',
        price: 38000,
        storeName: 'Gong Cha Vietnam',
        rating: 4.5,
        reviewCount: 980,
        isOutOfStock: false,
      ),
    ];
  }

  /// Tra ve danh sach da duoc loc/sap xep.
  List<SearchResultItem> get _sortedResults {
    final results = List<SearchResultItem>.from(_allResults);

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

  /// Xu ly khi nguoi dung thay doi kieu sap xep.
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
          // Danh sach ket qua.
          Expanded(
            child: _sortedResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _sortedResults.length,
                    itemBuilder: (context, index) {
                      final item = _sortedResults[index];
                      return SearchResultCard(
                        item: item,
                        onTap: () {
                          debugPrint('Xem chi tiet san pham: ${item.productId}');
                        },
                        onAddToCart: () {
                          debugPrint('Them vao gio: ${item.productId}');
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
                  ),
          ),
        ],
      ),
    );
  }

  /// Header: nut Back + thanh tim kiem voi tu khoa.
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
                    Icon(
                      Icons.search,
                      color: AppColors.textHint,
                      size: 20,
                    ),
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
                MaterialPageRoute(
                  builder: (context) => const CartView(),
                ),
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

  /// Widget hien thi khi khong co ket qua.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            context.t('search_no_results'),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('search_try_different'),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
