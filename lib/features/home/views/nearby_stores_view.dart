import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/state/cart_state.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/utils/vietnamese_normalizer.dart';
import '../../../core/utils/format_currency.dart';
import '../../home/models/store_model.dart';
import '../../restaurant/views/restaurant_detail_view.dart';
import '../../store/services/store_service.dart';
import '../../cart/views/cart_view.dart';
import 'widgets/app_search_bar.dart';

/// Trang hien thi tat ca quan gan day.
///
/// Su dung FutureBuilder ket hop ListView de lazy-load du lieu.
class NearbyStoresView extends StatefulWidget {
  final double lat;
  final double lng;

  const NearbyStoresView({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<NearbyStoresView> createState() => _NearbyStoresViewState();
}

class _NearbyStoresViewState extends State<NearbyStoresView> {
  final StoreService _storeService = StoreService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<StoreModel>> _storesFuture;
  List<StoreModel> _allStores = [];
  List<StoreModel> _filteredStores = [];
  bool _showMap = false;

  /// Vi tri hien tai cua nguoi dung (ban dau = vi tri truyen vao).
  LatLng? _userLocation;
  LatLng? _mapCenter;
  double _mapZoom = 14;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStores() {
    _storesFuture = _storeService.getNearbyStores(
      lat: widget.lat,
      lng: widget.lng,
      limit: 50,
    ).then((stores) {
      _allStores = stores;
      _applyFilter(_searchController.text);
      return stores;
    });
  }

  void _applyFilter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredStores = List.from(_allStores);
      } else {
        _filteredStores = _allStores.where((s) {
          return VietnameseNormalizer.matchesDiacritic(query, s.name) ||
              VietnameseNormalizer.matchesDiacritic(query, s.address);
        }).toList();
      }
    });
  }

  void _onSearchChanged(String value) {
    _applyFilter(value);
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

  /// Lay vi tri GPS hien tai.
  Future<void> _fetchUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) _showSnackBar(context.t('location_service_disabled'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) _showSnackBar(context.t('location_permission_denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) _showSnackBar(context.t('location_permission_permanently_denied'));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_userLocation!, _mapZoom);
      }
    } catch (e) {
      debugPrint('NearbyStoresView: Loi lay vi tri GPS - $e');
    }
  }

  void _showSnackBar(String message) {
    showAppToast(
      context,
      message: message,
      type: AppToastType.info,
    );
  }

  /// Mo Google Maps de chi duong.
  Future<void> _openDirections(LatLng dest, String storeName) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}&travelmode=driving',
    );

    try {
      final launched = await launchUrl(url, mode: LaunchMode.platformDefault);
      if (!launched && mounted) _showSnackBar(context.t('cannot_open_map'));
    } catch (e) {
      debugPrint('NearbyStoresView: Loi mo Google Maps - $e');
      if (mounted) _showSnackBar(context.t('cannot_open_map'));
    }
  }

  /// Mo bottom sheet chi tiet quan + nut chi duong.
  void _showStoreOnMapSheet(StoreModel store) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _StoreMapSheet(
        store: store,
        onNavigate: () {
          Navigator.pop(context);
          if (store.lat != null && store.lng != null) {
            _openDirections(LatLng(store.lat!, store.lng!), store.name);
          }
        },
        onViewDetail: () {
          Navigator.pop(context);
          _onStoreTap(store);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('home_near_you')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        actions: [
          ListenableBuilder(
            listenable: CartState.of(context),
            builder: (context, _) {
              final count = CartState.of(context).itemCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartView(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
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
          ),
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
            onPressed: () {
              setState(() => _showMap = !_showMap);
              if (_showMap) {
                _fetchUserLocation();
              }
            },
            tooltip: _showMap
                ? context.t('common_view_list')
                : context.t('common_view_map'),
          ),
        ],
      ),
      body: _showMap ? _buildMapView() : _buildListView(),
      floatingActionButton: _showMap
          ? FloatingActionButton.small(
              onPressed: _fetchUserLocation,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: context.t('my_location'),
              child: const Icon(Icons.my_location, size: 20),
            )
          : null,
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Thanh tim kiem.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AppSearchBar(
            controller: _searchController,
            hintText: context.t('search_stores'),
            onChanged: _onSearchChanged,
            onClear: () => _applyFilter(''),
          ),
        ),
        const SizedBox(height: 8),

        // Danh sach quan.
        Expanded(
          child: FutureBuilder<List<StoreModel>>(
            future: _storesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, __) => const _StoreItemSkeleton(),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(onRetry: _onRetry);
              }

              final stores = _filteredStores;
              if (stores.isEmpty) {
                if (_searchController.text.isNotEmpty) {
                  return _EmptyState(
                    icon: Icons.search_off,
                    message: context.t('search_no_results'),
                  );
                }
                return _EmptyState(
                  icon: Icons.store_outlined,
                  message: context.t('empty_stores'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: stores.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return _StoreItem(
                    store: store,
                    onTap: () => _onStoreTap(store),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return FutureBuilder<List<StoreModel>>(
      future: _storesFuture,
      builder: (context, snapshot) {
        final stores = _filteredStores;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        // Lay tam map: uu tien vi tri GPS, roi den vi tri truyen vao.
        final center = _userLocation ?? LatLng(widget.lat, widget.lng);

        // Marker quán.
        final storeMarkers = stores
            .where((s) => s.lat != null && s.lng != null)
            .map((store) => Marker(
                  point: LatLng(store.lat!, store.lng!),
                  width: 120,
                  height: 56,
                  child: GestureDetector(
                    onTap: () => _showStoreOnMapSheet(store),
                    child: _StoreMapMarker(store: store),
                  ),
                ))
            .toList();

        // Marker vi tri nguoi dung.
        final userMarker = _userLocation != null
            ? Marker(
                point: _userLocation!,
                width: 28,
                height: 28,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              )
            : null;

        final allMarkers = [
          if (userMarker != null) userMarker,
          ...storeMarkers,
        ];

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: _mapZoom,
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture) {
                    _mapCenter = pos.center;
                    _mapZoom = pos.zoom;
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.foodgo',
                ),
                MarkerLayer(markers: allMarkers),
              ],
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            if (snapshot.hasError)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade300),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.t('error_load_stores'),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: _onRetry,
                        child: Text(context.t('common_retry')),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ================================================================
// WIDGET: MARKER QUAN TREN BAN DO
// ================================================================

class _StoreMapMarker extends StatelessWidget {
  final StoreModel store;

  const _StoreMapMarker({required this.store});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: store.isOpen ? AppColors.primary : Colors.grey,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            store.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        CustomPaint(
          size: const Size(14, 8),
          painter: _MarkerTailPainter(
            color: store.isOpen ? AppColors.primary : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _MarkerTailPainter extends CustomPainter {
  final Color color;
  _MarkerTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================================================================
// WIDGET: BOTTOM SHEET CHI TIET QUAN TREN MAP
// ================================================================

class _StoreMapSheet extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onNavigate;
  final VoidCallback onViewDetail;

  const _StoreMapSheet({
    required this.store,
    required this.onNavigate,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh keo.
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Anh + Ten + Dia chi.
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  store.avtUrl.trim().isNotEmpty
                      ? store.avtUrl.trim()
                      : store.backUrl.trim().isNotEmpty
                          ? store.backUrl.trim()
                          : '',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey[200],
                    child: const Icon(Icons.store, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.address,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${store.rating.toStringAsFixed(1)} (${store.reviewCount})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hai nut hanh dong.
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewDetail,
                  icon: const Icon(Icons.store_outlined, size: 18),
                  label: Text(context.t('view_store_detail')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions, size: 18),
                  label: Text(context.t('navigate_to_store')),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: ITEM QUAN - DOC
// ================================================================

class _StoreItem extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const _StoreItem({required this.store, required this.onTap});

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
                          color: store.isOpen
                              ? Colors.green[50]
                              : Colors.red[50],
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
                        style:
                            TextStyle(fontSize: 12, color: AppColors.primary),
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
