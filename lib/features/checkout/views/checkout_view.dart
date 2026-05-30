import 'package:flutter/material.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';
import 'package:fe_foodgo_customers/features/address/models/address_model.dart';
import 'package:fe_foodgo_customers/features/cart/models/cart_item_model.dart';
import 'package:fe_foodgo_customers/features/home/models/product_model.dart';
import 'package:fe_foodgo_customers/features/address/services/address_service.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_delivery_info.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_cart_item.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_cart_items.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_promotions.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_summary.dart';
import 'package:fe_foodgo_customers/features/address/views/address_management_view.dart';
import 'package:fe_foodgo_customers/features/checkout/services/checkout_service.dart';
import 'package:fe_foodgo_customers/features/checkout/models/checkout_models.dart';

/// Trang checkout (Thanh toan) - buoc cuoi cung cua luong mua hang.
/// Giao dien gom: thong tin giao hang, danh sach mon, uu dai,
/// chi tiet hoa don, va sticky bottom bar.
///
/// Thuoc tinh [initialOrder] cho phep dat lai don hang cu:
///   - Neu la [OrderModel]: hien thi san danh sach mon cu trong gio hang.
///   - Neu la null: su dung gio hang mac dinh (mock data).
///
/// Thuoc tinh [selectedCartItems] truyen tu CartView khi nguoi dung
/// bam "Dat hang" tu trang gio hang. Cac mon da chon se duoc hien thi
/// cung topping va gia da bao gom topping.
class CheckoutView extends StatefulWidget {
  /// Don hang cu de dat lai. Neu null, su dung gio hang mac dinh.
  final OrderModel? initialOrder;

  /// Cac mon da chon tu trang gio hang (CartView).
  /// Neu duoc truyen, cac mon nay se duoc hien thi thay vi mock data.
  final List<CartItemModel>? selectedCartItems;

  const CheckoutView({
    super.key,
    this.initialOrder,
    this.selectedCartItems,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  // Dia chi giao hang (load tu Firestore).
  AddressModel? _deliveryAddress;
  final AddressService _addressService = const AddressService();

  // Danh sach mon trong gio hang (du lieu gia).
  late List<CheckoutCartItem> _cartItems;

  // Phuong thuc thanh toan.
  String _selectedVoucher = '';
  String _selectedPaymentMethod = 'cash';
  String _orderNote = '';

  // Model mock voucher.
  static final List<_VoucherModel> _freeshipVouchers = [
    _VoucherModel(
      id: 'sys_voucher_001',
      name: 'Mien phi giao hang - Thai Hoa',
      discount: 0,
      type: _VoucherType.freeship,
      minOrder: 50000,
      expireDate: DateTime.now().add(const Duration(days: 7)),
    ),
    _VoucherModel(
      id: 'sys_voucher_002',
      name: 'Freeship cho don tu 30K',
      discount: 0,
      type: _VoucherType.freeship,
      minOrder: 30000,
      expireDate: DateTime.now().add(const Duration(days: 14)),
    ),
    _VoucherModel(
      id: 'sys_voucher_003',
      name: 'Mien phi giao hang cho quy khach than thiet',
      discount: 0,
      type: _VoucherType.freeship,
      minOrder: 100000,
      expireDate: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  static final List<_VoucherModel> _discountVouchers = [
    _VoucherModel(
      id: 'sys_voucher_010',
      name: 'Giam 10K cho don tu 80K',
      discount: 10000,
      type: _VoucherType.discount,
      minOrder: 80000,
      expireDate: DateTime.now().add(const Duration(days: 5)),
    ),
    _VoucherModel(
      id: 'sys_voucher_011',
      name: 'Giam 20% (toi da 30K)',
      discount: 30,
      type: _VoucherType.percent,
      minOrder: 100000,
      expireDate: DateTime.now().add(const Duration(days: 10)),
    ),
    _VoucherModel(
      id: 'sys_voucher_012',
      name: 'Giam 15K - Khach hang moi',
      discount: 15000,
      type: _VoucherType.discount,
      minOrder: 50000,
      expireDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ];

  // Phuong thuc thanh toan.
  static final List<_PaymentMethodModel> _paymentMethods = [
    _PaymentMethodModel(
      id: 'cash',
      name: 'checkout_payment_cash',
      icon: Icons.money_outlined,
    ),
    _PaymentMethodModel(
      id: 'momo',
      name: 'checkout_payment_momo',
      icon: Icons.wallet_outlined,
    ),
    _PaymentMethodModel(
      id: 'zalo',
      name: 'checkout_payment_zalo',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _PaymentMethodModel(
      id: 'card',
      name: 'checkout_payment_card',
      icon: Icons.credit_card_outlined,
    ),
  ];

  List<_ToppingOption> _getToppingOptions(String foodId) {
    switch (foodId) {
      case 'prod_001':
        return [
          _ToppingOption(name: 'Tran chau', price: 5000),
          _ToppingOption(name: 'Thach ca phe', price: 8000),
          _ToppingOption(name: 'Them bo', price: 12000),
          _ToppingOption(name: 'Them sua', price: 5000),
        ];
      case 'prod_002':
        return [
          _ToppingOption(name: 'Da', price: 0),
          _ToppingOption(name: 'Them duong', price: 3000),
          _ToppingOption(name: 'Them ca phe', price: 5000),
        ];
      case 'prod_003':
        return [
          _ToppingOption(name: 'Trai cay', price: 12000),
          _ToppingOption(name: 'Pudding', price: 6000),
          _ToppingOption(name: 'Thach', price: 4000),
          _ToppingOption(name: 'Them rau mach', price: 5000),
        ];
      default:
        return [
          _ToppingOption(name: 'Topping 1', price: 5000),
          _ToppingOption(name: 'Topping 2', price: 5000),
        ];
    }
  }

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
    return voucherDiscount;
  }

  double get _totalPayment {
    return _subtotal + _deliveryFee - _discount;
  }

  /// Khoi tao du lieu.
  @override
  void initState() {
    super.initState();

    // Neu co don hang cu thi chuyen doi sang gio hang, nguoc lai su dung mock.
    if (widget.selectedCartItems != null &&
        widget.selectedCartItems!.isNotEmpty) {
      debugPrint(
        'Checkout: Su dung ${widget.selectedCartItems!.length} mon tu CartView',
      );
      _cartItems = _convertCartItemsToCheckoutItems(widget.selectedCartItems!);
    } else if (widget.initialOrder != null) {
      debugPrint(
        'Checkout: Dat lai don hang [${widget.initialOrder!.id}], ten quan [${widget.initialOrder!.storeName}]',
      );
      _cartItems = _convertOrderToCartItems(widget.initialOrder!);
    } else {
      debugPrint('Checkout: Khoi tao gio hang mac dinh');
      _cartItems = [
        CheckoutCartItem(
          id: 'item_001',
          foodId: 'prod_001',
          storeId: 'store_001',
          name: 'Tra Sua Tran Chau Duong',
          imageUrl: 'https://picsum.photos/seed/milktea1/200',
          basePrice: 35000,
          unitPrice: 48000,
          quantity: 2,
          toppings: [
            CheckoutTopping(name: 'Tran chau', price: 5000),
            CheckoutTopping(name: 'Thach ca phe', price: 8000),
          ],
        ),
        CheckoutCartItem(
          id: 'item_002',
          foodId: 'prod_002',
          storeId: 'store_001',
          name: 'Ca phe sua da',
          imageUrl: 'https://picsum.photos/seed/coffee2/200',
          basePrice: 29000,
          unitPrice: 29000,
          quantity: 1,
          toppings: [CheckoutTopping(name: 'Da', price: 0)],
        ),
        CheckoutCartItem(
          id: 'item_003',
          foodId: 'prod_003',
          storeId: 'store_001',
          name: 'Tra vai Thach Vuive',
          imageUrl: 'https://picsum.photos/seed/greentea3/200',
          basePrice: 24000,
          unitPrice: 42000,
          quantity: 1,
          toppings: [
            CheckoutTopping(name: 'Trai cay', price: 12000),
            CheckoutTopping(name: 'Pudding', price: 6000),
          ],
        ),
      ];
    }
    _selectedPaymentMethod = 'cash';
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final address = await _addressService.getDefaultAddressFromFirestore();
    if (mounted && address != null) {
      setState(() {
        _deliveryAddress = address;
      });
    }
  }

  /// Chuyen doi danh sach mon cua don hang cu sang dinh dang gio hang checkout.
  List<CheckoutCartItem> _convertOrderToCartItems(OrderModel order) {
    return order.items.map((item) {
      final toppingsTotal = (item.options ?? []).fold<double>(
        0, (sum, o) => sum + o.price,
      );
      final basePrice = (item.price - toppingsTotal).clamp(0.0, double.infinity);
      return CheckoutCartItem(
        id: 'reorder_${order.id}_${item.name.hashCode}',
        foodId: item.foodId,
        storeId: order.storeId,
        name: item.name,
        imageUrl: item.imageUrl ?? '',
        basePrice: basePrice,
        unitPrice: item.price,
        quantity: item.quantity,
        toppings: (item.options ?? [])
            .map((o) => CheckoutTopping(
                  name: o.name,
                  price: o.price,
                ))
            .toList(),
      );
    }).toList();
  }

  /// Chuyen doi danh sach CartItemModel tu CartView sang dinh dang checkout.
  /// Bao gom topping, gia (da bao gom topping), size, ghi chu.
  List<CheckoutCartItem> _convertCartItemsToCheckoutItems(
      List<CartItemModel> cartItems) {
    return cartItems.map((cart) {
      final unitPrice = cart.unitPriceOf(cart.product);
      final basePrice = cart.product?.basePrice ?? 0.0;

      return CheckoutCartItem(
        id: cart.id,
        foodId: cart.foodId,
        storeId: cart.storeId,
        name: cart.name,
        imageUrl: cart.imageUrlOrDefault,
        basePrice: basePrice,
        unitPrice: unitPrice,
        quantity: cart.quantity,
        toppings: cart.selectedToppings
            .map((t) {
              final opt = _findToppingOption(cart.product, t.name);
              return CheckoutTopping(name: t.name, price: opt?.price ?? 0.0);
            })
            .toList(),
        note: cart.note ?? '',
      );
    }).toList();
  }

  OptionModel? _findToppingOption(dynamic product, String toppingName) {
    if (product == null) return null;
    for (final group in (product.optionGroups as List)) {
      if (group.name.toLowerCase().contains('topping')) {
        for (final opt in (group.options as List)) {
          if (opt.name == toppingName) return opt as OptionModel;
        }
      }
    }
    return null;
  }

  String _formatPrice(double price) {
    final str = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return str;
  }

  void _onQuantityChanged(int index, int newQuantity) {
    setState(() {
      final current = _cartItems[index];
      _cartItems[index] = current.copyWith(quantity: newQuantity);
    });
    debugPrint(
      'Checkout: Cap nhat so luong mon [${_cartItems[index].name}] = $newQuantity',
    );
  }

  void _onItemRemoved(int index) {
    final removedItem = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
    });
    debugPrint('Checkout: Da xoa mon [${removedItem.name}] khoi gio hang');
  }

  /// Xu ly bam nut Sửa mot mon an.
  void _onEditItemTap(int index) {
    final item = _cartItems[index];
    debugPrint('Checkout: Nguoi dung bam Sửa mon [$index] - ${item.name}');
    _showEditItemBottomSheet(index);
  }

  /// Xu ly bam nut Voucher.
  void _onVoucherTap() {
    debugPrint('Checkout: Nguoi dung bam Chọn Voucher/Khuyến mãi');
    _showVoucherBottomSheet();
  }

  /// Xu ly bam nut Phuong thuc thanh toan.
  void _onPaymentMethodTap() {
    debugPrint('Checkout: Nguoi dung bam Phương thức thanh toán');
    _showPaymentMethodBottomSheet();
  }

  void _onPlaceOrder() async {
    if (_cartItems.isEmpty) {
      _showSnackBar(context, 'Gio hang cua ban dang rong');
      return;
    }

    debugPrint('========== CHECKOUT: DAT HANG ==========');
    debugPrint('Dia chi giao hang: ${_deliveryAddress?.address ?? "Chua co dia chi"}');
    debugPrint('So mon: ${_cartItems.length}');
    for (final item in _cartItems) {
      debugPrint(
        '  - ${item.name} x${item.quantity} = ${_formatPrice(item.totalPrice)} VND',
      );
    }
    debugPrint('Tam tinh: ${_formatPrice(_subtotal)} VND');
    debugPrint('Phi giao hang: ${_formatPrice(_deliveryFee)} VND');
    debugPrint('Giam gia: -${_formatPrice(_discount)} VND');
    debugPrint('Tong thanh toan: ${_formatPrice(_totalPayment)} VND');
    debugPrint('Phuong thuc thanh toan: $_selectedPaymentMethod');
    debugPrint(
      'Voucher: ${_selectedVoucher.isEmpty ? "khong" : _selectedVoucher}',
    );
    debugPrint('Ghi chu: $_orderNote');
    debugPrint('==========================================');

    // Hien thi loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final request = CheckoutRequest(
        userId: 'user_001',
        addressId: _deliveryAddress!.id,
        paymentMethod: _selectedPaymentMethod,
        voucherId: _selectedVoucher.isEmpty ? null : _selectedVoucher,
        note: _orderNote.isEmpty ? null : _orderNote,
      );

      final response = await CheckoutService.checkout(request);

      if (!mounted) return;
      Navigator.pop(context);

      debugPrint(
        '[Checkout] Dat hang thanh cong: orderId=${response.orderId}, '
        'orderCode=${response.orderCode}, finalAmount=${response.finalAmount}',
      );

      _showOrderSuccessDialog(context, response);
    } on CheckoutException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar(context, e.error.message);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar(context, 'Da xay ra loi. Vui long thu lai.');
    }
  }

  void _showOrderSuccessDialog(BuildContext context, CheckoutResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Text('Dat hang thanh cong!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ma don hang: ${response.orderCode}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Ten cua hang: ${response.storeName}'),
            Text('Dia chi giao: ${response.deliveryAddress}'),
            const SizedBox(height: 8),
            Text(
              'Tong thanh toan: ${_formatPrice(response.finalAmount)} VND',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui long cho cua hang xac nhan don hang.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, response);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.t('checkout_title')),
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
                    address: _deliveryAddress ?? AddressModel(
                      id: '',
                      userId: '',
                      name: '',
                      address: 'Chua co dia chi',
                      receiverName: '',
                      receiverPhone: '',
                      isDefault: false,
                    ),
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
                          'Checkout: Da cap nhat dia chi thanh [${selected.name}] - ${selected.address}',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // PHAN 2: Danh sach mon da chon.
                  CheckoutCartItems(
                    items: _cartItems,
                    onQuantityChanged: _onQuantityChanged,
                    onItemRemoved: _onItemRemoved,
                    onEditTap: _onEditItemTap,
                  ),
                  const SizedBox(height: 20),
                  // PHAN 3: Uu dai va phuong thuc thanh toan.
                  CheckoutPromotions(
                    onVoucherTap: _onVoucherTap,
                    onPaymentMethodTap: _onPaymentMethodTap,
                    selectedVoucher: _selectedVoucher.isEmpty
                        ? null
                        : _selectedVoucher,
                    selectedPaymentMethod: _selectedPaymentMethod,
                    onNoteChanged: (note) {
                      setState(() {
                        _orderNote = note;
                      });
                    },
                    orderNote: _orderNote,
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
                  context.t('checkout_total_payment'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatPrice(_totalPayment)} ${context.t('unit_currency')}',
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
                context.t('checkout_order_btn'),
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

  ///=============================================================================
  /// BOTTOM SHEET: PHUONG THUC THANH TOAN
  ///=============================================================================

  /// Hien thi BottomSheet chon phuong thuc thanh toan.
  void _showPaymentMethodBottomSheet() {
    debugPrint('Checkout: Mo BottomSheet chon phuong thuc thanh toan');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vach ngan dau va nut dong.
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t('checkout_select_payment_method'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      debugPrint(
                        'Checkout: Dong BottomSheet phuong thuc thanh toan',
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            // Danh sach phuong thuc.
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: _paymentMethods.length,
              itemBuilder: (ctx, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedPaymentMethod == method.id;
                return ListTile(
                  leading: Icon(
                    method.icon,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                  title: Text(
                    context.t(method.name),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 22,
                        )
                      : Icon(
                          Icons.radio_button_off,
                          color: AppColors.textHint,
                          size: 22,
                        ),
                  onTap: () {
                    debugPrint(
                      'Checkout: Chon phuong thuc thanh toan [${method.id}] - ${context.t(method.name)}',
                    );
                    setState(() {
                      _selectedPaymentMethod = method.id;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  ///=============================================================================
  /// BOTTOM SHEET: VOUCHER
  ///=============================================================================

  /// Hien thi BottomSheet chon voucher voi 2 tab.
  void _showVoucherBottomSheet() {
    debugPrint('Checkout: Mo BottomSheet chon voucher');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.70,
        minChildSize: 0.50,
        maxChildSize: 0.90,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Vach ngan dau va tieu de.
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.t('checkout_select_voucher'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        debugPrint('Checkout: Dong BottomSheet voucher');
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Tab Bar.
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      tabs: [
                        Tab(text: context.t('checkout_voucher_freeship')),
                        Tab(text: context.t('checkout_voucher_discount')),
                      ],
                    ),
                  ],
                ),
              ),
              // Tab View.
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: TabBarView(
                    children: [
                      // Tab 1: Mien phi giao hang.
                      _buildVoucherList(
                        vouchers: _freeshipVouchers,
                        scrollController: scrollController,
                        emptyLabel: context.t('checkout_voucher_empty'),
                      ),
                      // Tab 2: Ma giam gia.
                      _buildVoucherList(
                        vouchers: _discountVouchers,
                        scrollController: scrollController,
                        emptyLabel: context.t('checkout_voucher_empty'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build danh sach voucher cho mot tab.
  Widget _buildVoucherList({
    required List<_VoucherModel> vouchers,
    required ScrollController scrollController,
    required String emptyLabel,
  }) {
    if (vouchers.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: const TextStyle(fontSize: 14, color: AppColors.textHint),
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: vouchers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final voucher = vouchers[index];
        return _VoucherCard(
          voucher: voucher,
          isSelected: _selectedVoucher == voucher.id,
          onApply: () {
            debugPrint(
              'Checkout: Ap dung voucher [${voucher.id}] - ${voucher.name}',
            );
            setState(() {
              _selectedVoucher = voucher.id;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  ///=============================================================================
  /// BOTTOM SHEET: SUA MON AN
  ///=============================================================================

  /// Hien thi BottomSheet sua chi tiet mot mon (topping + ghi chu).
  void _showEditItemBottomSheet(int itemIndex) {
    final originalItem = _cartItems[itemIndex];
    debugPrint(
      'Checkout: Mo BottomSheet sua mon [$itemIndex] - ${originalItem.name}',
    );

    // Tao danh sach topping tuy chon cho mon nay.
    final availableToppings = _getToppingOptions(originalItem.id);

    // Tao danh sach topping dang chon (bat dau tu topping cua mon).
    final selectedToppings = List<CheckoutTopping>.from(originalItem.toppings);

    // Tao bien cuc bo cho ghi chu.
    final noteController = TextEditingController(text: originalItem.note);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.80,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tieu de va nut dong.
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.t('checkout_edit_item'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          debugPrint('Checkout: Dong BottomSheet sua mon');
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                // Noi dung cuon.
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hinh anh va ten mon.
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                originalItem.imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.fastfood,
                                    color: AppColors.textHint,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    originalItem.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatPrice(originalItem.unitPrice)} ${context.t('unit_currency')}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Phan topping.
                        Text(
                          context.t('checkout_topping_options'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Danh sach topping checkbox.
                        ...availableToppings.map((option) {
                          final isSelected = selectedToppings.any(
                            (t) => t.name == option.name,
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withAlpha(15)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    selectedToppings.add(
                                      CheckoutTopping(
                                        name: option.name,
                                        price: option.price,
                                      ),
                                    );
                                  } else {
                                    selectedToppings.removeWhere(
                                      (t) => t.name == option.name,
                                    );
                                  }
                                });
                                debugPrint(
                                  'Checkout: Topping [${option.name}] ${checked == true ? "chon" : "bo chon"}',
                                );
                              },
                              title: Text(
                                option.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: option.price > 0
                                  ? Text(
                                      '+ ${_formatPrice(option.price)} ${context.t('unit_currency')}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  : null,
                              activeColor: AppColors.primary,
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        // Phan ghi chu.
                        Text(
                          context.t('checkout_item_note'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: noteController,
                          maxLines: 2,
                          maxLength: 100,
                          decoration: InputDecoration(
                            hintText: context.t('checkout_note_hint'),
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textHint,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Hien thi gia tri tam tinh.
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.t('checkout_temp_total'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${_formatPrice(_calcEditItemTotal(originalItem.unitPrice, originalItem.quantity, selectedToppings))} ${context.t('unit_currency')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16 + MediaQuery.of(context).padding.bottom,
                        ),
                      ],
                    ),
                  ),
                ),
                // Nut Cap nhat.
                Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    12 + MediaQuery.of(ctx).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint(
                          'Checkout: Cap nhat mon [$itemIndex] - ${originalItem.name}',
                        );
                        debugPrint(
                          '  Topping moi: ${selectedToppings.map((t) => t.name).join(", ")}',
                        );
                        debugPrint('  Ghi chu: ${noteController.text}');
                        setState(() {
                          _cartItems[itemIndex] = originalItem.copyWith(
                            toppings: List.from(selectedToppings),
                            note: noteController.text.trim(),
                          );
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.t('common_update'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Tinh tong gia tam thoi cho BottomSheet sua mon.
  double _calcEditItemTotal(
    double unitPrice,
    int quantity,
    List<CheckoutTopping> selectedToppings,
  ) {
    final toppingTotal = selectedToppings.fold<double>(
      0,
      (sum, t) => sum + (t.price * quantity),
    );
    return unitPrice * quantity + toppingTotal;
  }
}

///=============================================================================
/// MODEL: VOUCHER
///=============================================================================

/// Loai voucher.
enum _VoucherType { freeship, discount, percent }

/// Model mock voucher.
class _VoucherModel {
  final String id;
  final String name;
  final double discount;
  final _VoucherType type;
  final double minOrder;
  final DateTime expireDate;

  const _VoucherModel({
    required this.id,
    required this.name,
    required this.discount,
    required this.type,
    required this.minOrder,
    required this.expireDate,
  });
}

/// Card hien thi mot voucher trong danh sach.
class _VoucherCard extends StatelessWidget {
  final _VoucherModel voucher;
  final bool isSelected;
  final VoidCallback onApply;

  const _VoucherCard({
    required this.voucher,
    required this.isSelected,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withAlpha(15)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon dau.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  voucher.type == _VoucherType.freeship
                      ? Icons.local_shipping_outlined
                      : Icons.discount_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Thong tin voucher.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toi thieu ${_formatPrice(voucher.minOrder)} ${context.t('unit_currency')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Hang duoi: han su dung + nut ap dung.
          Row(
            children: [
              Icon(Icons.schedule, size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                'Het han: ${voucher.expireDate.day}/${voucher.expireDate.month}/${voucher.expireDate.year}',
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onApply,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.textSecondary
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isSelected
                        ? context.t('common_applied')
                        : context.t('common_apply'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final str = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return str;
  }
}

///=============================================================================
/// MODEL: PHUONG THUC THANH TOAN
///=============================================================================

/// Model phuong thuc thanh toan.
class _PaymentMethodModel {
  final String id;
  final String name;
  final IconData icon;

  const _PaymentMethodModel({
    required this.id,
    required this.name,
    required this.icon,
  });
}

/// Model tuy chon topping.
class _ToppingOption {
  final String name;
  final double price;

  const _ToppingOption({required this.name, required this.price});
}
