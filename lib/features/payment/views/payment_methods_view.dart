import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/payment_method_model.dart';
import 'add_payment_method_view.dart';
import 'widgets/payment_method_card.dart';

/// Man hinh Quan ly Phuong thuc Thanh toan.
///
/// Hien thi 3 nhom: Tien mat (COD), The, Vi dien tu.
/// Co sticky bottom bar de them moi.
///
/// Duoc goi tu:
///   - Tab Tai khoan (ProfileView): bam "Thanh toan"
class PaymentMethodsView extends StatefulWidget {
  const PaymentMethodsView({super.key});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  /// Danh sach phuong thuc thanh toan.
  late List<PaymentMethodModel> _methods;

  @override
  void initState() {
    super.initState();
    _methods = _buildMockData();
  }

  /// Tao danh sach mock gom: 1 the Visa, 1 vi MoMo da lien ket.
  List<PaymentMethodModel> _buildMockData() {
    return [
      // Nhom 1: Tien mat (COD) - mac dinh, khong the xoa.
      PaymentMethodModel(
        id: 'pm_cash_001',
        type: PaymentMethodType.cash,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      // Nhom 2: The Visa.
      PaymentMethodModel(
        id: 'pm_card_visa_001',
        type: PaymentMethodType.card,
        isDefault: false,
        createdAt: DateTime.now(),
        cardBrand: CardBrand.visa,
        last4Digits: '4242',
      ),
      // Nhom 2: The Mastercard.
      PaymentMethodModel(
        id: 'pm_card_mc_001',
        type: PaymentMethodType.card,
        isDefault: false,
        createdAt: DateTime.now(),
        cardBrand: CardBrand.mastercard,
        last4Digits: '8888',
      ),
      // Nhom 3: Vi MoMo da lien ket.
      PaymentMethodModel(
        id: 'pm_wallet_momo_001',
        type: PaymentMethodType.wallet,
        isDefault: false,
        createdAt: DateTime.now(),
        walletBrand: WalletBrand.momo,
        isLinked: true,
      ),
      // Nhom 3: Vi ZaloPay chua lien ket.
      PaymentMethodModel(
        id: 'pm_wallet_zalo_001',
        type: PaymentMethodType.wallet,
        isDefault: false,
        createdAt: DateTime.now(),
        walletBrand: WalletBrand.zalopay,
        isLinked: false,
      ),
    ];
  }

  /// Lay danh sach nhom da duoc phan loai.
  Map<PaymentMethodType, List<PaymentMethodModel>> get _groupedMethods {
    final groups = <PaymentMethodType, List<PaymentMethodModel>>{};
    for (final method in _methods) {
      groups.putIfAbsent(method.type, () => []).add(method);
    }
    return groups;
  }

  /// Dat mot phuong thuc lam mac dinh.
  void _onSelectDefault(String methodId) {
    setState(() {
      for (int i = 0; i < _methods.length; i++) {
        _methods[i] = _methods[i].copyWith(
          isDefault: _methods[i].id == methodId,
        );
      }
    });
    debugPrint('PaymentMethods: Dat [$methodId] lam mac dinh');
  }

  /// Xoa mot phuong thuc thanh toan.
  void _onDelete(BuildContext ctx, PaymentMethodModel method) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          ctx.t('payment_delete'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: Text(
          ctx.t('payment_delete_confirm'),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              ctx.t('common_cancel'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              setState(() {
                _methods.removeWhere((m) => m.id == method.id);
              });
              debugPrint(
                  'PaymentMethods: Da xoa phuong thuc [${method.id}]');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(ctx.t('payment_deleted')),
                  backgroundColor: AppColors.textSecondary,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              ctx.t('common_delete'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Mo trang them moi phuong thuc thanh toan.
  Future<void> _onAddNew() async {
    debugPrint('PaymentMethods: Mo trang them phuong thuc thanh toan');
    final created = await Navigator.push<PaymentMethodModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentMethodView(
          onConfirm: (method) {
            debugPrint(
                'PaymentMethods: Da them phuong thuc [${method.id}]');
            setState(() {
              _methods.add(method);
            });
          },
        ),
      ),
    );
    if (created != null) {
      debugPrint(
          'PaymentMethods: Quay ve sau khi them [${created.id}]');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('PaymentMethods: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('payment_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _methods.isEmpty
                ? _buildEmptyState()
                : _buildMethodsList(),
          ),
          _buildStickyBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payment_outlined,
                size: 40,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.t('payment_title'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t('payment_add_new'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Danh sach phuong thuc, chia theo nhom.
  Widget _buildMethodsList() {
    final groups = _groupedMethods;
    final order = [
      PaymentMethodType.cash,
      PaymentMethodType.card,
      PaymentMethodType.wallet,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: order.length,
      itemBuilder: (context, sectionIndex) {
        final type = order[sectionIndex];
        final items = groups[type];
        if (items == null || items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tieu de nhom.
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _getGroupTitle(context, type),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Cac item trong nhom.
            ...items.map((method) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PaymentMethodCard(
                  method: method,
                  onTap: () {
                    debugPrint(
                        'PaymentMethods: Nguoi dung chon phuong thuc [${method.id}]');
                    _onSelectDefault(method.id);
                  },
                  onDelete: method.type == PaymentMethodType.cash
                      ? null
                      : () => _onDelete(context, method),
                ),
              );
            }),
            if (sectionIndex < order.length - 1)
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Lay tieu de nhom theo loai.
  String _getGroupTitle(BuildContext ctx, PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cash:
        return ctx.t('payment_group_cash').toUpperCase();
      case PaymentMethodType.card:
        return ctx.t('payment_group_card').toUpperCase();
      case PaymentMethodType.wallet:
        return ctx.t('payment_group_wallet').toUpperCase();
    }
  }

  /// Sticky Bottom Bar.
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
      child: GestureDetector(
        onTap: _onAddNew,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                context.t('payment_add_new'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
