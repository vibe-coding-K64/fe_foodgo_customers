import 'package:flutter/material.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';
import 'package:fe_foodgo_customers/features/order/services/order_service.dart';
import 'package:fe_foodgo_customers/features/checkout/views/checkout_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/order_detail_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/widgets/activity_order_card.dart';
import 'package:fe_foodgo_customers/features/activity/views/widgets/cancel_order_dialog.dart';
import 'package:fe_foodgo_customers/core/utils/vietnamese_normalizer.dart';

/// Man hinh Hoat dong (Quan ly don hang).
///
/// Hien thi danh sach don hang phan theo 4 trang thai: Tat ca, Da dat, Da nhan, Da huy.
/// Su dung du lieu tu Firebase Firestore.
class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> with SingleTickerProviderStateMixin {
  int _reloadKey = 0;
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _triggerReload() {
    setState(() {
      _reloadKey++;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.greenGradientStart,
                AppColors.greenGradientEnd,
              ],
            ),
          ),
        ),
        title: Text(
          context.t('nav_activity'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(text: context.t('activity_tab_all')),
                  Tab(text: context.t('activity_tab_ordered')),
                  Tab(text: context.t('activity_tab_received')),
                  Tab(text: context.t('activity_tab_cancelled')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: context.t('activity_search_hint'),
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllOrdersList(reloadKey: _reloadKey, onReload: _triggerReload, searchQuery: _searchQuery),
          _ActiveOrdersList(reloadKey: _reloadKey, onReload: _triggerReload, searchQuery: _searchQuery),
          _CompletedOrdersList(reloadKey: _reloadKey, onReload: _triggerReload, searchQuery: _searchQuery),
          _CancelledOrdersList(reloadKey: _reloadKey, onReload: _triggerReload, searchQuery: _searchQuery),
        ],
      ),
    );
  }
}

/// Widget hien thi danh sach tat ca don hang (khong loc status).
class _AllOrdersList extends StatelessWidget {
  final int reloadKey;
  final VoidCallback onReload;
  final String searchQuery;

  const _AllOrdersList({required this.reloadKey, required this.onReload, required this.searchQuery});

  @override
  Widget build(BuildContext context) => _OrdersListView(
        reloadKey: reloadKey,
        onReload: onReload,
        filter: (orders) => orders,
        searchQuery: searchQuery,
        emptyKey: 'activity_empty_all',
        emptySearchKey: 'activity_search_no_result',
      );
}

/// Widget hien thi danh sach don hang dang xu ly (status 0, 1, 2).
class _ActiveOrdersList extends StatelessWidget {
  final int reloadKey;
  final VoidCallback onReload;
  final String searchQuery;

  const _ActiveOrdersList({required this.reloadKey, required this.onReload, required this.searchQuery});

  @override
  Widget build(BuildContext context) => _OrdersListView(
        reloadKey: reloadKey,
        onReload: onReload,
        filter: (orders) => orders.where((o) => o.isActive).toList(),
        searchQuery: searchQuery,
        emptyKey: 'activity_empty_ordered',
        emptySearchKey: 'activity_search_no_result',
      );
}

/// Widget hien thi danh sach don hang da nhan (status 3).
class _CompletedOrdersList extends StatelessWidget {
  final int reloadKey;
  final VoidCallback onReload;
  final String searchQuery;

  const _CompletedOrdersList({required this.reloadKey, required this.onReload, required this.searchQuery});

  @override
  Widget build(BuildContext context) => _OrdersListView(
        reloadKey: reloadKey,
        onReload: onReload,
        filter: (orders) => orders.where((o) => o.isCompleted).toList(),
        searchQuery: searchQuery,
        emptyKey: 'activity_empty_received',
        emptySearchKey: 'activity_search_no_result',
      );
}

/// Widget hien thi danh sach don hang da huy (status 4).
class _CancelledOrdersList extends StatelessWidget {
  final int reloadKey;
  final VoidCallback onReload;
  final String searchQuery;

  const _CancelledOrdersList({required this.reloadKey, required this.onReload, required this.searchQuery});

  @override
  Widget build(BuildContext context) => _OrdersListView(
        reloadKey: reloadKey,
        onReload: onReload,
        filter: (orders) => orders.where((o) => o.isCancelled).toList(),
        searchQuery: searchQuery,
        emptyKey: 'activity_empty_cancelled',
        emptySearchKey: 'activity_search_no_result',
      );
}

/// Widget chung hien thi danh sach don hang voi filter tu outside.
class _OrdersListView extends StatelessWidget {
  final List<OrderModel> Function(List<OrderModel>) filter;
  final String emptyKey;
  final String emptySearchKey;
  final int reloadKey;
  final VoidCallback onReload;
  final String searchQuery;

  const _OrdersListView({
    required this.filter,
    required this.emptyKey,
    required this.emptySearchKey,
    required this.reloadKey,
    required this.onReload,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      key: ValueKey('orders-list-$reloadKey'),
      stream: OrderService.getMyOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('ActivityView: Loi khi lay don hang: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Loi khi tai du lieu: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snapshot.data ?? [];
        final statusFiltered = filter(allOrders);

        // Apply search filter (khong phan biet dau tieng Viet)
        List<OrderModel> orders;
        if (searchQuery.isNotEmpty) {
          orders = statusFiltered.where((o) {
            final orderCode = o.orderCode ?? '';
            final storeName = o.storeName;
            final itemNames = o.items.map((item) => item.name).join(' ');
            return VietnameseNormalizer.matchesDiacritic(searchQuery, orderCode) ||
                VietnameseNormalizer.matchesDiacritic(searchQuery, storeName) ||
                VietnameseNormalizer.matchesDiacritic(searchQuery, itemNames);
          }).toList();
        } else {
          orders = statusFiltered;
        }

        if (orders.isEmpty) {
          return _buildEmptyState(context, isSearching: searchQuery.isNotEmpty);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ActivityOrderCard(
              order: order,
              onViewDetail: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailView(orderId: order.id),
                  ),
                );
              },
              onReorder: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutView(initialOrder: order),
                  ),
                );
              },
              onCancel: () async {
                final response = await CancelOrderDialog.show(context, order);
                if (response != null && response.success) {
                  onReload();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext ctx, {bool isSearching = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching ? ctx.t(emptySearchKey) : ctx.t(emptyKey),
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
