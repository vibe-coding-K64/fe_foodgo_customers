import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../models/voucher_model.dart';
import 'voucher_card.dart';

/// Man hinh chon voucher (tach ra file rieng de tranh loi setState trong bottom sheet).
class VoucherSelectionSheet extends StatefulWidget {
  final List<VoucherModel>? discountVouchers;
  final List<VoucherModel>? shopVouchers;
  final List<VoucherModel>? freeshipVouchers;
  final double subtotal;
  final String selectedDiscount;
  final String selectedShop;
  final String selectedFreeship;
  final void Function(String discount, String shop, String freeship) onChanged;

  const VoucherSelectionSheet({
    super.key,
    required this.discountVouchers,
    required this.shopVouchers,
    required this.freeshipVouchers,
    required this.subtotal,
    required this.selectedDiscount,
    required this.selectedShop,
    required this.selectedFreeship,
    required this.onChanged,
  });

  @override
  State<VoucherSelectionSheet> createState() => _VoucherSelectionSheetState();
}

class _VoucherSelectionSheetState extends State<VoucherSelectionSheet> {
  late String _discount;
  late String _shop;
  late String _freeship;

  @override
  void initState() {
    super.initState();
    _discount = widget.selectedDiscount;
    _shop = widget.selectedShop;
    _freeship = widget.selectedFreeship;
  }

  void _toggle(String id, String field) {
    setState(() {
      if (field == 'discount') {
        _discount = _discount == id ? '' : id;
      } else if (field == 'shop') {
        _shop = _shop == id ? '' : id;
      } else {
        _freeship = _freeship == id ? '' : id;
      }
    });
    widget.onChanged(_discount, _shop, _freeship);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultTabController(
        length: 3,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header.
              Padding(
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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Tab bar.
              TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                tabs: [
                  Tab(text: context.t('checkout_voucher_discount')),
                  Tab(text: context.t('checkout_voucher_shop')),
                  Tab(text: context.t('checkout_voucher_freeship')),
                ],
              ),
              // Tab view.
              Expanded(
                child: TabBarView(
                  children: [
                    _buildVoucherList(widget.discountVouchers, 'discount'),
                    _buildVoucherList(widget.shopVouchers, 'shop'),
                    _buildVoucherList(widget.freeshipVouchers, 'freeship'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherList(List<VoucherModel>? list, String field) {
    if (list == null || list.isEmpty) {
      return Center(
        child: Text(
          context.t('checkout_voucher_empty'),
          style: const TextStyle(fontSize: 14, color: AppColors.textHint),
        ),
      );
    }

    final now = DateTime.now();
    final validList = list.where((v) => v.expiryDate.isAfter(now)).toList();
    if (validList.isEmpty) {
      return Center(
        child: Text(
          context.t('checkout_voucher_empty'),
          style: const TextStyle(fontSize: 14, color: AppColors.textHint),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: validList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final v = validList[index];
        final isSelected = (field == 'discount' && _discount == v.id) ||
            (field == 'shop' && _shop == v.id) ||
            (field == 'freeship' && _freeship == v.id);
        return VoucherCard(
          voucher: v,
          isSelected: isSelected,
          isDisabled: v.minOrderValue > widget.subtotal,
          onApply: () => _toggle(v.id, field),
        );
      },
    );
  }
}
