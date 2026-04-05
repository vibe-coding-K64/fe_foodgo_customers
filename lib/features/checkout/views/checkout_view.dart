import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../../../features/profile/models/address_model.dart';
import 'widgets/checkout_delivery_info.dart';
import 'widgets/checkout_cart_item.dart';
import 'widgets/checkout_cart_items.dart';
import 'widgets/checkout_promotions.dart';
import 'widgets/checkout_summary.dart';
import '../../address/views/address_management_view.dart';

/// Trang checkout (Thanh toan) - buoc cuoi cung cua luong mua hang.
/// Giao dien gom: thong tin giao hang, danh sach mon, uu dai,
/// chi tiet hoa don, va sticky bottom bar.
class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  // Dia chi giao hang mac dinh (du lieu gia).
  late AddressModel _deliveryAddress;

  // Danh sach mon trong gio hang (du lieu gia).
  late List<CheckoutCartItem> _cartItems;

  // Cac truong thai tuy chon.
  bool _isPointsEnabled = false;
  String _selectedVoucher = '';
  String _selectedPaymentMethod = 'cash';

  // Thong tin tinh toan.
  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get _deliveryFee {
    return 15000;
  }

  double get _discount {
    double voucherDiscount = 0;
    if (_selectedVoucher.isNotEmpty) {
      voucherDiscount = 5000;
    }
    double pointsDiscount = 0;
    if (_isPointsEnabled) {
      pointsDiscount = 10000;
    }
    return voucherDiscount + pointsDiscount;
  }

  double get _totalPayment {
    return _subtotal + _deliveryFee - _discount;
  }

  /// Khoi tao du lieu gia.
  @override
  void initState() {
    super.initState();
    _deliveryAddress = AddressModel(
      id: 'addr_001',
      userId: '0901234567',
      name: 'Nguyen Van A',
      address: '123 Nguyen Hue, Quan 1, TP.HCM',
      lat: 10.7769,
      lng: 106.7009,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _cartItems = [
      CheckoutCartItem(
        id: 'item_001',
        name: 'Tra Sua Tran Chau Duong',
        imageUrl: 'https://picsum.photos/seed/milktea1/200',
        unitPrice: 35000,
        quantity: 2,
        toppings: [
          CheckoutTopping(name: 'Tran chau', price: 5000),
          CheckoutTopping(name: 'Thach ca phe', price: 8000),
        ],
      ),
      CheckoutCartItem(
        id: 'item_002',
        name: 'Ca phe sua da',
        imageUrl: 'https://picsum.photos/seed/coffee2/200',
        unitPrice: 29000,
        quantity: 1,
        toppings: [
          CheckoutTopping(name: 'Da', price: 0),
        ],
      ),
      CheckoutCartItem(
        id: 'item_003',
        name: 'Tra vai Thach Vuive',
        imageUrl: 'https://picsum.photos/seed/greentea3/200',
        unitPrice: 42000,
        quantity: 1,
        toppings: [
          CheckoutTopping(name: 'Trai cay', price: 12000),
          CheckoutTopping(name: 'Pudding', price: 6000),
        ],
      ),
    ];
  }

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return str;
  }

  void _onQuantityChanged(int index, int newQuantity) {
    setState(() {
      _cartItems[index] = CheckoutCartItem(
        id: _cartItems[index].id,
        name: _cartItems[index].name,
        imageUrl: _cartItems[index].imageUrl,
        unitPrice: _cartItems[index].unitPrice,
        quantity: newQuantity,
        toppings: _cartItems[index].toppings,
      );
    });
    debugPrint('Checkout: Cap nhat so luong mon [${_cartItems[index].name}] = $newQuantity');
  }

  void _onItemRemoved(int index) {
    final removedItem = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
    });
    debugPrint('Checkout: Da xoa mon [${removedItem.name}] khoi gio hang');
  }

  void _onPlaceOrder() {
    debugPrint('========== CHECKOUT: DAT HANG ==========');
    debugPrint('Dia chi giao hang: ${_deliveryAddress.address}');
    debugPrint('So mon: ${_cartItems.length}');
    for (final item in _cartItems) {
      debugPrint('  - ${item.name} x${item.quantity} = ${_formatPrice(item.totalPrice)} VND');
    }
    debugPrint('Tam tinh: ${_formatPrice(_subtotal)} VND');
    debugPrint('Phi giao hang: ${_formatPrice(_deliveryFee)} VND');
    debugPrint('Giam gia: -${_formatPrice(_discount)} VND');
    debugPrint('Tong thanh toan: ${_formatPrice(_totalPayment)} VND');
    debugPrint('Phuong thuc thanh toan: $_selectedPaymentMethod');
    debugPrint('Diem tich luy: ${_isPointsEnabled ? "co" : "khong"}');
    debugPrint('Voucher: ${_selectedVoucher.isEmpty ? "khong" : _selectedVoucher}');
    debugPrint('==========================================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(LanguageService.translate('checkout_title')),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('Checkout: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Noi dung cuon chinh.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PHAN 1: Thong tin giao hang.
                  CheckoutDeliveryInfo(
                    address: _deliveryAddress,
                    estimatedTime: '15-20 ${LanguageService.translate('unit_min')}',
                    onChangeAddressTap: () async {
                      debugPrint('Checkout: Mo man hinh doi dia chi');
                      final selected = await Navigator.push<AddressModel>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AddressManagementView(isFromCheckout: true),
                        ),
                      );
                      if (selected != null) {
                        setState(() {
                          _deliveryAddress = selected;
                        });
                        debugPrint(
                            'Checkout: Da cap nhat dia chi thanh [${selected.name}] - ${selected.address}');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // PHAN 2: Danh sach mon da chon.
                  CheckoutCartItems(
                    items: _cartItems,
                    onQuantityChanged: _onQuantityChanged,
                    onItemRemoved: _onItemRemoved,
                    onAddMoreTap: () {
                      debugPrint('Checkout: Quay lai chon them mon');
                    },
                  ),
                  const SizedBox(height: 20),
                  // PHAN 3: Uu dai va phuong thuc thanh toan.
                  CheckoutPromotions(
                    onVoucherTap: () {
                      debugPrint('Checkout: Mo man hinh chon voucher');
                    },
                    onPaymentMethodTap: () {
                      debugPrint('Checkout: Mo man hinh chon phuong thuc thanh toan');
                    },
                    isPointsEnabled: _isPointsEnabled,
                    selectedVoucher:
                        _selectedVoucher.isEmpty ? null : _selectedVoucher,
                    selectedPaymentMethod: _selectedPaymentMethod,
                  ),
                  const SizedBox(height: 20),
                  // PHAN 4: Chi tiet hoa don.
                  CheckoutSummary(
                    subtotal: _subtotal,
                    deliveryFee: _deliveryFee,
                    discount: _discount,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // STICKY BOTTOM BAR.
          _buildStickyBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tong tien.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LanguageService.translate('checkout_total_payment'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatPrice(_totalPayment)} ${LanguageService.translate('unit_currency')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Nut dat hang.
          GestureDetector(
            onTap: _onPlaceOrder,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                LanguageService.translate('checkout_order_btn'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
