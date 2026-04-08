import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/payment_method_model.dart';
import '../services/payment_service.dart';
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
  /// Service quan ly phuong thuc thanh toan.
  final PaymentService _paymentService = const PaymentService();

  /// Dat mot phuong thuc lam mac dinh thong qua Firebase.
  void _onSelectDefault(String methodId) async {
    try {
      await _paymentService.setDefaultPayment(methodId);
      debugPrint('PaymentMethods: Dat [$methodId] lam mac dinh');
    } catch (e) {
      debugPrint('PaymentMethods: Loi dat phuong thuc mac dinh - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService.translate('payment_error_set_default')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Xoa mot phuong thuc thanh toan khoi Firebase.
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
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await _paymentService.deletePayment(method.id);
                debugPrint(
                    'PaymentMethods: Da xoa phuong thuc [${method.id}]');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ctx.t('payment_deleted')),
                      backgroundColor: AppColors.textSecondary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('PaymentMethods: Loi xoa phuong thuc - $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ctx.t('payment_error_delete')),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
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
            // StreamBuilder se tu dong cap nhat khi Firestore thay doi.
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
            child: StreamBuilder<List<PaymentMethodModel>>(
              stream: _paymentService.getPaymentMethodsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  debugPrint('PaymentMethods: Loi StreamBuilder - ${snapshot.error}');
                  return _buildEmptyState();
                }
                final methods = snapshot.data ?? [];
                if (methods.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildMethodsList(methods);
              },
            ),
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
  Widget _buildMethodsList(List<PaymentMethodModel> methods) {
    // Phan loai thanh 3 nhom: cash, card, wallet.
    final cashMethods = methods.where((m) => m.type == PaymentMethodType.cash).toList();
    final cardMethods = methods.where((m) => m.type == PaymentMethodType.card).toList();
    final walletMethods = methods.where((m) => m.type == PaymentMethodType.wallet).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Nhom Tien mat.
        if (cashMethods.isNotEmpty) ...[
          _buildSection(
            context,
            PaymentMethodType.cash,
            cashMethods,
          ),
          const SizedBox(height: 16),
        ],
        // Nhom The.
        if (cardMethods.isNotEmpty) ...[
          _buildSection(
            context,
            PaymentMethodType.card,
            cardMethods,
          ),
          const SizedBox(height: 16),
        ],
        // Nhom Vi dien tu.
        if (walletMethods.isNotEmpty) ...[
          _buildSection(
            context,
            PaymentMethodType.wallet,
            walletMethods,
          ),
        ],
      ],
    );
  }

  /// Xay dung mot nhom phuong thuc.
  Widget _buildSection(
    BuildContext ctx,
    PaymentMethodType type,
    List<PaymentMethodModel> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tieu de nhom.
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            _getGroupTitle(ctx, type),
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
                  : () => _onDelete(ctx, method),
            ),
          );
        }),
      ],
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
