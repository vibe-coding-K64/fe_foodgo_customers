import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/utils/order_converter.dart';
import '../../../../features/checkout/views/checkout_view.dart';
import 'order_detail_view.dart';
import 'widgets/activity_order_card.dart';

/// Man hinh Hoat dong (Quan ly don hang).
///
/// Hien thi danh sach don hang phan theo 3 trang thai: Da dat, Da nhan, Da huy.
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
            LanguageService.translate('nav_activity'),
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
                    Tab(text: LanguageService.translate('activity_tab_ordered')),
                    Tab(text: LanguageService.translate('activity_tab_received')),
                    Tab(text: LanguageService.translate('activity_tab_cancelled')),
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
                              hintText: LanguageService.translate(
                                  'activity_search_hint'),
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
            // Tab Da dat.
            _OrderList(status: OrderStatus.ordered),
            // Tab Da nhan.
            _OrderList(status: OrderStatus.received),
            // Tab Da huy.
            _OrderList(status: OrderStatus.cancelled),
          ],
        ),
      ),
    );
  }
}

/// Widget hien thi danh sach don hang theo trang thai.
class _OrderList extends StatelessWidget {
  final OrderStatus status;

  const _OrderList({required this.status});

  @override
  Widget build(BuildContext context) {
    final orders = _getMockOrders(status);

    if (orders.isEmpty) {
      return _buildEmptyState();
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
                builder: (context) => OrderDetailView(
                  order: orderModelToDetail(order),
                ),
              ),
            );
          },
          onReorder: () {
            debugPrint('ActivityView: Nguoi dung bam Dat lai don hang [${order.id}]');
            final orderDetail = orderModelToDetail(order);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutView(initialOrder: orderDetail),
              ),
            );
          },
          onCancel: () {
            debugPrint('Huy don hang: ${order.id}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Huy don hang ${order.id}'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String emptyText;
    switch (status) {
      case OrderStatus.ordered:
        emptyText = LanguageService.translate('activity_empty_ordered');
        break;
      case OrderStatus.received:
        emptyText = LanguageService.translate('activity_empty_received');
        break;
      case OrderStatus.cancelled:
        emptyText = LanguageService.translate('activity_empty_cancelled');
        break;
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
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<OrderModel> _getMockOrders(OrderStatus targetStatus) {
    final now = DateTime.now();

    final allOrders = [
      OrderModel(
        id: 'ORD001',
        storeName: 'Com Tam Oi Den',
        mainItem: 'Com tam bi cha',
        itemCount: 2,
        totalPrice: 85000,
        orderDate: now.subtract(const Duration(hours: 2)),
        status: OrderStatus.ordered,
        subStatus: SubOrderStatus.preparing,
      ),
      OrderModel(
        id: 'ORD002',
        storeName: 'Bun Bo Hue Ba Trieu',
        mainItem: 'Bun bo hue lon',
        itemCount: 1,
        totalPrice: 55000,
        orderDate: now.subtract(const Duration(days: 1)),
        status: OrderStatus.ordered,
        subStatus: SubOrderStatus.driverComing,
      ),
      OrderModel(
        id: 'ORD003',
        storeName: 'Pho 24 Quan Phu Nhuan',
        mainItem: 'Pho bo tai nam',
        itemCount: 3,
        totalPrice: 150000,
        orderDate: now.subtract(const Duration(days: 2)),
        status: OrderStatus.received,
      ),
      OrderModel(
        id: 'ORD004',
        storeName: 'Mi Quang Ba Giu',
        mainItem: 'Mi quang ga',
        itemCount: 1,
        totalPrice: 45000,
        orderDate: now.subtract(const Duration(days: 3)),
        status: OrderStatus.received,
      ),
      OrderModel(
        id: 'ORD005',
        storeName: 'Banh Mi Cay Tay Dong',
        mainItem: 'Banh mi thit nguoi',
        itemCount: 2,
        totalPrice: 60000,
        orderDate: now.subtract(const Duration(days: 5)),
        status: OrderStatus.received,
      ),
      OrderModel(
        id: 'ORD006',
        storeName: 'Lau De Nha Hang Song Than',
        mainItem: 'Lau de 4 nguoi',
        itemCount: 4,
        totalPrice: 450000,
        orderDate: now.subtract(const Duration(days: 7)),
        status: OrderStatus.cancelled,
      ),
    ];

    return allOrders.where((o) => o.status == targetStatus).toList();
  }
}
