import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../home/models/store_model.dart';
import '../../restaurant/views/restaurant_detail_view.dart';
import '../../store/services/store_service.dart';

/// Trang hien thi tat ca quan pho bien.
class PopularStoresView extends StatefulWidget {
  final double lat;
  final double lng;

  const PopularStoresView({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<PopularStoresView> createState() => _PopularStoresViewState();
}

class _PopularStoresViewState extends State<PopularStoresView> {
  final StoreService _storeService = StoreService();

  late Future<List<StoreModel>> _storesFuture;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  void _loadStores() {
    _storesFuture = _storeService.getPopularStores(
      lat: widget.lat,
      lng: widget.lng,
      limit: 50,
    );
  }

  void _onRetry() {
    setState(() => _loadStores());
  }

  void _onStoreTap(StoreModel store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailView(storeId: store.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('home_popular_stores')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<List<StoreModel>>(
        future: _storesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => const _StoreItemSkeleton(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _onRetry);
          }

          final stores = snapshot.data ?? [];
          if (stores.isEmpty) {
            return _EmptyState(
              icon: Icons.trending_up_outlined,
              message: context.t('empty_stores'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: stores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final store = stores[index];
              return _StoreItem(
                store: store,
                index: index + 1,
                onTap: () => _onStoreTap(store),
              );
            },
          );
        },
      ),
    );
  }
}

// ================================================================
// WIDGET: ITEM QUAN - DOC
// ================================================================

class _StoreItem extends StatelessWidget {
  final StoreModel store;
  final int? index;
  final VoidCallback onTap;

  const _StoreItem({
    required this.store,
    this.index,
    required this.onTap,
  });

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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (index != null)
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index! <= 3
                      ? _getRankColor(index!)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: index! <= 3 ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            if (index != null) const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                store.avtUrl.trim().isNotEmpty
                    ? store.avtUrl.trim()
                    : store.backUrl.trim().isNotEmpty
                        ? store.backUrl.trim()
                        : '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
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
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                          color:
                              store.isOpen ? Colors.green[50] : Colors.red[50],
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
                      Icon(Icons.location_on,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text(
                        '${store.distance.toStringAsFixed(1)} ${context.t('unit_km')}',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        store.deliveryTime,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.blueGrey.shade600;
      case 3:
        return Colors.brown.shade600;
      default:
        return Colors.grey;
    }
  }
}

// ================================================================
// WIDGET: SKELETON
// ================================================================

class _StoreItemSkeleton extends StatelessWidget {
  const _StoreItemSkeleton();

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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
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
              context.t('error_load_stores'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
