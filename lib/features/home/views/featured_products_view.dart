import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/utils/vietnamese_normalizer.dart';
import '../../../core/utils/format_currency.dart';
import '../../home/models/product_model.dart';
import '../../product/views/product_detail_bottom_sheet.dart';
import '../../store/services/product_service.dart';
import 'widgets/app_search_bar.dart';

/// Trang hien thi tat ca mon an noi bat.
///
/// Su dung FutureBuilder ket hop ListView de hien thi san pham dang 1 cot.
class FeaturedProductsView extends StatefulWidget {
  const FeaturedProductsView({super.key});

  @override
  State<FeaturedProductsView> createState() => _FeaturedProductsViewState();
}

class _FeaturedProductsViewState extends State<FeaturedProductsView> {
  final ProductService _productService = const ProductService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<ProductModel>> _productsFuture;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _productsFuture = _productService.getFeaturedProducts(limit: 50).then((products) {
      _allProducts = products;
      _applyFilter('');
      return _filteredProducts;
    });
  }

  void _applyFilter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((p) {
          return VietnameseNormalizer.matchesDiacritic(query, p.name) ||
              (p.storeName != null &&
                  VietnameseNormalizer.matchesDiacritic(query, p.storeName!));
        }).toList();
      }
    });
  }

  void _onSearchChanged(String value) {
    _applyFilter(value);
  }

  void _onRetry() {
    _searchController.clear();
    _applyFilter('');
    setState(() => _loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('home_featured_foods')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Thanh tim kiem.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSearchBar(
              controller: _searchController,
              hintText: context.t('search_products'),
              onChanged: _onSearchChanged,
              onClear: () => _applyFilter(''),
            ),
          ),
          const SizedBox(height: 8),

          // Noi dung.
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => const _ProductCardSkeleton(),
                  );
                }

                if (snapshot.hasError) {
                  return _ErrorState(onRetry: _onRetry);
                }

                final products = _filteredProducts;
                if (products.isEmpty) {
                  if (_searchController.text.isNotEmpty) {
                    return _EmptyState(
                      icon: Icons.search_off,
                      message: context.t('search_no_results'),
                    );
                  }
                  return _EmptyState(
                      icon: Icons.fastfood_outlined,
                      message: context.t('empty_products'),
                    );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      onTap: () => showProductDetailSheet(context, product),
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
}

// ================================================================
// WIDGET: CARD SAN PHAM - NGANG
// ================================================================

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anh san pham.
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110,
                      height: 110,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey, size: 36),
                    ),
                  ),
                  if (product.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            context.t('home_out_of_stock'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (product.isFeatured)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Nổi bật',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Thong tin san pham.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.storeName != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        product.storeName!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(product.basePrice, context),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildRatingRow(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(BuildContext context) {
    final parts = <Widget>[];

    if (product.rating != null) {
      parts.addAll([
        const Icon(Icons.star, size: 12, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          product.rating!.toStringAsFixed(1),
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ]);
    }

    if (product.distance != null) {
      if (parts.isNotEmpty) parts.add(const SizedBox(width: 8));
      parts.addAll([
        Icon(Icons.location_on, size: 12, color: AppColors.primary),
        const SizedBox(width: 2),
        Text(
          '${product.distance!.toStringAsFixed(1)} ${context.t('unit_km')}',
          style: TextStyle(fontSize: 12, color: AppColors.primary),
        ),
      ]);
    }

    return parts.isNotEmpty ? Row(children: parts) : const SizedBox.shrink();
  }
}

// ================================================================
// WIDGET: SKELETON
// ================================================================

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 70,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: TRANG THAI LOI
// ================================================================

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              context.t('error_load_products'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(context.t('common_retry')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// WIDGET: TRANG THAI RONG
// ================================================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
