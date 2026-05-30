import 'package:flutter/material.dart';
import 'package:fe_foodgo_customers/core/constants/app_colors.dart';
import 'package:fe_foodgo_customers/core/localization/language_service.dart';
import 'package:fe_foodgo_customers/features/order/models/order_model.dart';
import 'package:fe_foodgo_customers/features/address/models/address_model.dart';
import 'package:fe_foodgo_customers/features/cart/models/cart_item_model.dart';
import 'package:fe_foodgo_customers/features/home/models/product_model.dart';
import 'package:fe_foodgo_customers/features/address/services/address_service.dart';
import 'package:fe_foodgo_customers/features/payment/models/payment_method_model.dart';
import 'package:fe_foodgo_customers/features/payment/services/payment_method_firestore_service.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_delivery_info.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_cart_item.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_cart_items.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_promotions.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/checkout_summary.dart';
import 'package:fe_foodgo_customers/features/checkout/views/widgets/voucher_selection_sheet.dart';
import 'package:fe_foodgo_customers/features/address/views/address_management_view.dart';
import 'package:fe_foodgo_customers/features/checkout/services/checkout_service.dart';
import 'package:fe_foodgo_customers/features/checkout/services/my_voucher_firestore_service.dart';
import 'package:fe_foodgo_customers/features/checkout/models/checkout_models.dart';
import 'package:fe_foodgo_customers/features/checkout/models/voucher_model.dart';

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

  // Voucher: moi tab chon 1 voucher, 3 tab doc lap.
  String _selectedDiscountVoucher = '';
  String _selectedShopVoucher = '';
  String _selectedFreeshipVoucher = '';
  String _selectedPaymentMethod = 'cash';
  String _orderNote = '';

  // Voucher tu API backend.
  List<VoucherModel>? _freeshipVouchers;
  List<VoucherModel>? _discountVouchers;
  List<VoucherModel>? _shopVouchers;

  // Phuong thuc thanh toan tu Firestore.
  List<PaymentMethodModel> _paymentMethods = [];
  final PaymentMethodFirestoreService _paymentFirestoreService =
      const PaymentMethodFirestoreService();

  Future<void> _loadPaymentMethods() async {
    debugPrint('Checkout: Dang tai phuong thuc thanh toan tu Firestore');
    final methods = await _paymentFirestoreService.getPaymentMethods();
    if (mounted) {
      setState(() {
        _paymentMethods = methods;
        if (_paymentMethods.isNotEmpty) {
          final defaultMethod = _paymentMethods.first;
          _selectedPaymentMethod = defaultMethod.id;
          debugPrint(
              'Checkout: Da load ${_paymentMethods.length} phuong thuc, mac dinh: ${defaultMethod.name}');
        }
      });
    }
  }

  // Thong tin tinh toan.
  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get _deliveryFee {
    return 15000;
  }

  double get _shopDiscount {
    final voucher = _findSelectedShopVoucher();
    return _getVoucherDiscount(voucher);
  }

  double get _discount {
    final voucher = _findSelectedDiscountVoucher();
    return _getVoucherDiscount(voucher);
  }

  double get _freeshipDiscount {
    final voucher = _findSelectedFreeshipVoucher();
    if (voucher == null) return 0;
    return _deliveryFee.clamp(0, voucher.value);
  }

  VoucherModel? _findSelectedDiscountVoucher() {
    if (_selectedDiscountVoucher.isEmpty) return null;
    for (final v in (_discountVouchers ?? [])) {
      if (v.id == _selectedDiscountVoucher) return v;
    }
    for (final v in (_shopVouchers ?? [])) {
      if (v.id == _selectedDiscountVoucher) return v;
    }
    return null;
  }

  VoucherModel? _findSelectedShopVoucher() {
    if (_selectedShopVoucher.isEmpty) return null;
    for (final v in (_shopVouchers ?? [])) {
      if (v.id == _selectedShopVoucher) return v;
    }
    return null;
  }

  VoucherModel? _findSelectedFreeshipVoucher() {
    if (_selectedFreeshipVoucher.isEmpty) return null;
    for (final v in (_freeshipVouchers ?? [])) {
      if (v.id == _selectedFreeshipVoucher) return v;
    }
    return null;
  }

  double get _totalPayment {
    return _subtotal + _deliveryFee - _discount - _shopDiscount - _freeshipDiscount;
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
            CheckoutTopping(name: 'Tran Chau', price: 5000),
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
          name: 'Tra Vai Thach Vuive',
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
    _loadVouchers();
    _loadPaymentMethods();
  }

  Future<void> _loadDefaultAddress() async {
    final address = await _addressService.getDefaultAddressFromFirestore();
    if (mounted && address != null) {
      setState(() {
        _deliveryAddress = address;
      });
    }
  }

  Future<void> _loadVouchers() async {
    if (_cartItems.isEmpty) return;

    try {
      final storeId = _cartItems.isNotEmpty ? _cartItems.first.storeId : null;
      final voucherData = await MyVoucherFirestoreService.getVouchersForCheckout(
        userId: 'user_001',
        storeId: storeId,
      );

      if (!mounted) return;
      setState(() {
        _freeshipVouchers = voucherData.freeshipVouchers;
        _discountVouchers = voucherData.myVouchers;
        _shopVouchers = voucherData.vouchers;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      debugPrint('[Checkout] Loi load voucher: $e');
      setState(() {
        _freeshipVouchers = [];
        _discountVouchers = [];
        _shopVouchers = [];
      });
    }
  }

  /// Tra ve chuoi gia tri giam cua voucher da chon (hien thi tren UI).
  /// Format: "-15k" | "-15%" | "-15k FREESHIPABC"
  /// - Voucher type 2 (fixed): hien "-{value/1000}k"
  /// - Voucher type 1 (percent): hien "-{value}%"
  /// - Voucher freeship: chi hien ten ma, khong gia tri tien.
  String _getSelectedVouchersSummary() {
    final parts = <String>[];

    // Voucher giam gia discount.
    if (_selectedDiscountVoucher.isNotEmpty) {
      final v = _findSelectedDiscountVoucher();
      if (v != null) {
        parts.add(v.type == 1
            ? '-${v.value.toInt()}%'
            : '-${_formatK(v.value)}k');
      }
    }

    // Voucher giam gia shop.
    if (_selectedShopVoucher.isNotEmpty) {
      final v = _findSelectedShopVoucher();
      if (v != null) {
        parts.add(v.type == 1
            ? '-${v.value.toInt()}%'
            : '-${_formatK(v.value)}k');
      }
    }

    // Voucher freeship: chi hien ten ma.
    if (_selectedFreeshipVoucher.isNotEmpty) {
      final fv = _findSelectedFreeshipVoucher();
      if (fv != null) parts.add(fv.code);
    }

    return parts.isEmpty ? '' : parts.join(', ');
  }

  /// Format gia tri tien thanh chuoi "k" (VD: 15000 -> "15.k").
  String _formatK(double value) {
    final k = (value / 1000).round();
    return '$k';
  }

  /// Lay giam gia tu voucher duoc chon.
  double _getVoucherDiscount(VoucherModel? voucher) {
    if (voucher == null) return 0;
    if (voucher.isFreeship) {
      return _deliveryFee.clamp(0, voucher.value);
    }
    if (voucher.type == 1) {
      return (_subtotal * voucher.value / 100).clamp(0, double.infinity);
    }
    return voucher.value.clamp(0, double.infinity);
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
    _loadVouchers().then((_) => _validateSelectedVouchers());
  }

  void _onItemRemoved(int index) {
    final removedItem = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
    });
    debugPrint('Checkout: Da xoa mon [${removedItem.name}] khoi gio hang');
    _validateSelectedVouchers();
  }

  void _validateSelectedVouchers() {
    if (!mounted) return;
    final newSubtotal = _subtotal;

    final removedDiscount = _selectedDiscountVoucher.isNotEmpty &&
        (_findSelectedDiscountVoucher()?.minOrderValue ?? 0) > newSubtotal;
    final removedShop = _selectedShopVoucher.isNotEmpty &&
        (_findSelectedShopVoucher()?.minOrderValue ?? 0) > newSubtotal;
    final removedFreeship = _selectedFreeshipVoucher.isNotEmpty &&
        (_findSelectedFreeshipVoucher()?.minOrderValue ?? 0) > newSubtotal;

    if (removedDiscount || removedShop || removedFreeship) {
      setState(() {
        if (removedDiscount) _selectedDiscountVoucher = '';
        if (removedShop) _selectedShopVoucher = '';
        if (removedFreeship) _selectedFreeshipVoucher = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Voucher khong con ap dung do gia tri don hang giam',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Xu ly bam nut Voucher.
  void _onVoucherTap() {
    debugPrint('Checkout: Nguoi dung bam Chon Voucher/Khuyen mai');
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => VoucherSelectionSheet(
              discountVouchers: _discountVouchers,
              shopVouchers: _shopVouchers,
              freeshipVouchers: _freeshipVouchers,
              subtotal: _subtotal,
              selectedDiscount: _selectedDiscountVoucher,
              selectedShop: _selectedShopVoucher,
              selectedFreeship: _selectedFreeshipVoucher,
              onChanged: (discount, shop, freeship) {
                setState(() {
                  _selectedDiscountVoucher = discount;
                  _selectedShopVoucher = shop;
                  _selectedFreeshipVoucher = freeship;
                });
              },
            ),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        )
        .then((_) {
      // Force rebuild sau khi sheet dong.
      setState(() {});
      _validateSelectedVouchers();
    });
  }

  /// Xu ly bam nut Phuong thuc thanh toan.
  void _onPaymentMethodTap() {
    debugPrint('Checkout: Nguoi dung bam Phuong thuc thanh toan');
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
    debugPrint('Giam gia voucher: -${_formatPrice(_discount)} VND');
    debugPrint('Giam gia shop: -${_formatPrice(_shopDiscount)} VND');
    debugPrint('Giam gia freeship: -${_formatPrice(_freeshipDiscount)} VND');
    debugPrint('Tong thanh toan: ${_formatPrice(_totalPayment)} VND');
    debugPrint('Phuong thuc thanh toan: $_selectedPaymentMethod');
    debugPrint('Voucher discount: ${_selectedDiscountVoucher.isEmpty ? "khong" : _selectedDiscountVoucher}');
    debugPrint('Voucher shop: ${_selectedShopVoucher.isEmpty ? "khong" : _selectedShopVoucher}');
    debugPrint('Voucher freeship: ${_selectedFreeshipVoucher.isEmpty ? "khong" : _selectedFreeshipVoucher}');
    debugPrint('Ghi chu: $_orderNote');
    debugPrint('==========================================');

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
        discountVoucherId: _selectedDiscountVoucher.isEmpty ? null : _selectedDiscountVoucher,
        shopVoucherId: _selectedShopVoucher.isEmpty ? null : _selectedShopVoucher,
        freeshipVoucherId: _selectedFreeshipVoucher.isEmpty ? null : _selectedFreeshipVoucher,
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
                  ),
                  const SizedBox(height: 20),
                  // PHAN 3: Uu dai va phuong thuc thanh toan.
                  CheckoutPromotions(
                    onVoucherTap: _onVoucherTap,
                    onPaymentMethodTap: _onPaymentMethodTap,
                    selectedVouchersSummary: _getSelectedVouchersSummary(),
                    selectedPaymentMethod: _selectedPaymentMethod,
                    selectedPaymentMethodInfo: _paymentMethods.isEmpty
                        ? null
                        : _paymentMethods.firstWhere(
                            (m) => m.id == _selectedPaymentMethod,
                            orElse: () => _paymentMethods.first,
                          ),
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
                    shopDiscount: _shopDiscount,
                    freeshipDiscount: _freeshipDiscount,
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
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: tieu de + nut dong.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      sheetContext.t('checkout_select_payment_method'),
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
                      Navigator.pop(sheetContext);
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
                final icon = _getPaymentIcon(method);
                return ListTile(
                  leading: Icon(
                    icon,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                  title: Text(
                    method.name,
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
                  subtitle: method.details.isNotEmpty
                      ? Text(
                          method.details,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 22,
                        )
                      : const Icon(
                          Icons.radio_button_off,
                          color: AppColors.textHint,
                          size: 22,
                        ),
                  onTap: () {
                    debugPrint(
                      'Checkout: Chon phuong thuc thanh toan [${method.id}] - ${method.name}',
                    );
                    setState(() {
                      _selectedPaymentMethod = method.id;
                    });
                    Navigator.pop(sheetContext);
                  },
                );
              },
            ),
            SizedBox(height: MediaQuery.of(sheetContext).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// Tra ve IconData tu PaymentMethodModel.
  IconData _getPaymentIcon(PaymentMethodModel method) {
    switch (method.type) {
      case PaymentMethodType.cash:
        return Icons.money_outlined;
      case PaymentMethodType.wallet:
        final brand = method.walletBrand?.toLowerCase();
        if (brand == 'momo') return Icons.wallet_outlined;
        if (brand == 'zalopay' || brand == 'zalo') {
          return Icons.account_balance_wallet_outlined;
        }
        return Icons.account_balance_wallet_outlined;
      case PaymentMethodType.card:
        return Icons.credit_card_outlined;
    }
  }
}
