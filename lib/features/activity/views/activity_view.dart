import 'package:flutter/material.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';
import 'package:fe_foodgo_customers/features/order/services/order_service.dart';
import 'package:fe_foodgo_customers/features/checkout/views/checkout_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/order_detail_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/widgets/activity_order_card.dart';
import 'package:fe_foodgo_customers/features/activity/views/widgets/cancel_order_dialog.dart';

/// Man hinh Hoat dong (Quan ly don hang).
///
/// Hien thi danh sach don hang phan theo 3 trang thai: Da dat, Da nhan, Da huy.
/// Su dung du lieu tu Firebase Firestore.
class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  int _reloadKey = 0;

  void _triggerReload() {
    setState(() {
      _reloadKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                // TabBar phan loai don hang.
                TabBar(
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
                    Tab(text: context.t('activity_tab_ordered')),
                    Tab(text: context.t('activity_tab_received')),
                    Tab(text: context.t('activity_tab_cancelled')),
                  ],
                ),
                // Thanh tim kiem va loc.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      // O tim kiem.
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
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
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nut loc.
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {
                            debugPrint('Mo bang loc');
                          },
                          icon: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
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
          children: [
            // Tab Da dat (active: status 0, 1, 2).
            _ActiveOrdersList(reloadKey: _reloadKey, onReload: _triggerReload),
            // Tab Da nhan (status 3).
            _CompletedOrdersList(reloadKey: _reloadKey, onReload: _triggerReload),
            // Tab Da huy (status 4).
            _CancelledOrdersList(reloadKey: _reloadKey, onReload: _triggerReload),
          ],
        ),
      ),
    );
  }
}

/// Widget hien thi danh sach don hang dang xu ly (status 0, 1, 2).
class _ActiveOrdersList extends StatelessWidget {
  final int reloadKey;
  final VoidCallback onReload;

  const _ActiveOrdersList({required this.reloadKey, required this.onReload});

  @override
  Widget build(BuildContext context) => _OrdersListView(
        reloadKey: reloadKey,
        onReload: onReload,
        filter: (orders) => orders.where((o) => o.isActive).toList(),
        emptyKey: 'activity_empty_ordered',
      );
}

/// Widget hien thi danh sach don hang da nhan (status 3).
class _CompletedOrdersList extends StatelessWidget {
  final int reloadKey;
  final VoidCallback onReload;

  const _CompletedOrdersList({required this.reloadKey, required this.onReload});

  @override
  Widget build(BuildContext context) => _OrdersListView(
        reloadKey: reloadKey,
        onReload: onReload,
        filter: (orders) => orders.where((o) => o.isCompleted).toList(),
        emptyKey: 'activity_empty_received',
      );
}

/// Widget hien thi danh sach don hang da huy (status 4).
class _CancelledOrdersList extends StatelessWidget {
  final int reloadKey;
  final VoidCallback onReload;

  const _CancelledOrdersList({required this.reloadKey, required this.onReload});

  @override
  Widget build(BuildContext context) => _OrdersListView(
        reloadKey: reloadKey,
        onReload: onReload,
        filter: (orders) => orders.where((o) => o.isCancelled).toList(),
        emptyKey: 'activity_empty_cancelled',
      );
}

/// Widget chung hien thi danh sach don hang voi filter tu outside.
class _OrdersListView extends StatelessWidget {
  final List<OrderModel> Function(List<OrderModel>) filter;
  final String emptyKey;
  final int reloadKey;
  final VoidCallback onReload;

  const _OrdersListView({
    required this.filter,
    required this.emptyKey,
    required this.reloadKey,
    required this.onReload,
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
        final orders = filter(allOrders);

        if (orders.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ActivityOrderCard(
              order: order,
              onViewDetail: () {
                debugPrint('Xem chi tiet don hang: ${order.id}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailView(orderId: order.id),
                  ),
                );
              },
              onReorder: () {
                debugPrint(
                  'ActivityView: Nguoi dung bam Dat lai don hang [${order.id}]',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutView(initialOrder: order),
                  ),
                );
              },
              onCancel: () async {
                debugPrint('Huy don hang: ${order.id}');
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

  Widget _buildEmptyState(BuildContext ctx) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            ctx.t(emptyKey),
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
