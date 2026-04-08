import 'package:flutter/material.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';
import 'package:fe_foodgo_customers/features/order/services/order_service.dart';
import 'package:fe_foodgo_customers/features/checkout/views/checkout_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/order_detail_view.dart';
import 'package:fe_foodgo_customers/features/activity/views/widgets/activity_order_card.dart';

/// Man hinh Hoat dong (Quan ly don hang).
///
/// Hien thi danh sach don hang phan theo 3 trang thai: Da dat, Da nhan, Da huy.
/// Su dung du lieu tu Firebase Firestore.
class ActivityView extends StatelessWidget {
  const ActivityView({super.key});

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
            // Tab Da dat (status 0, 1, 2).
            _OrderList(status: 0),
            // Tab Da nhan (status 3).
            _OrderList(status: 1),
            // Tab Da huy (status 4).
            _OrderList(status: 2),
          ],
        ),
      ),
    );
  }
}

/// Widget hien thi danh sach don hang theo trang thai.
class _OrderList extends StatelessWidget {
  final int status;

  const _OrderList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.getMyOrdersStream(),
      builder: (context, snapshot) {
        // Neu co loi thi hien thi loi.
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

        // Neu dang loading thi hien thi vong xoay.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Lay danh sach don hang.
        final allOrders = snapshot.data ?? [];

        // Phan loai don hang theo trang thai.
        final activeOrders = allOrders.where((o) => o.isActive).toList();
        final completedOrders = allOrders.where((o) => o.isCompleted).toList();
        final cancelledOrders = allOrders.where((o) => o.isCancelled).toList();

        // Chon danh sach phu hop voi tab.
        List<OrderModel> orders;
        switch (status) {
          case 0:
            orders = activeOrders;
            break;
          case 1:
            orders = completedOrders;
            break;
          case 2:
            orders = cancelledOrders;
            break;
          default:
            orders = [];
        }

        // Neu khong co don hang thi hien thi trang thai rong.
        if (orders.isEmpty) {
          return _buildEmptyState(context);
        }

        // Hien thi danh sach don hang.
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
                    builder: (context) => OrderDetailView(order: order),
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
              onCancel: () {
                debugPrint('Huy don hang: ${order.id}');
                _showCancelDialog(context, order);
              },
            );
          },
        );
      },
    );
  }

  /// Hien thi dialog xac nhan huy don hang.
  Future<void> _showCancelDialog(BuildContext context, OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan huy don'),
        content: Text('Ban co chac chan muon huy don hang ${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Khong'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Co, huy don'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!context.mounted) return;

    // Hien thi loading.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Goi service huy don.
    final success = await OrderService.cancelOrder(order.id);

    // Dong loading.
    if (context.mounted) {
      Navigator.pop(context);

      // Hien thi snackbar thong bao.
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Huy don hang thanh cong'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Huy don hang that bai, vui long thu lai'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext ctx) {
    String emptyText;
    switch (status) {
      case 0:
        emptyText = ctx.t('activity_empty_ordered');
        break;
      case 1:
        emptyText = ctx.t('activity_empty_received');
        break;
      case 2:
        emptyText = ctx.t('activity_empty_cancelled');
        break;
      default:
        emptyText = 'Khong co don hang';
    }

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
            emptyText,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
