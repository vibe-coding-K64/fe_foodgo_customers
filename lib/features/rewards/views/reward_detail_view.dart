import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/rewards_model.dart';
import '../services/offer_service.dart';

/// Man hinh Chi tiet uu dai (doi diem).
///
/// Nhan vao mot [ExchangeVoucherModel] va hien thi day du noi dung.
///
/// Hien thi:
///   - Hinh anh cover tran vien.
///   - Tieu de, mo ta, dieu khoan.
///   - Sticky bottom bar: Diem can doi + nut "Doi diem ngay".
///
/// Duoc goi tu:
///   - RewardsView: bam vao item trong section "Doi diem".
class RewardDetailView extends StatefulWidget {
  /// Voucher can hien thi chi tiet.
  final ExchangeVoucherModel voucher;

  /// Callback khi doi voucher thanh cong (tra ve so diem con lai).
  final void Function(int diemConLai)? onExchangeSuccess;

  const RewardDetailView({
    super.key,
    required this.voucher,
    this.onExchangeSuccess,
  });

  @override
  State<RewardDetailView> createState() => _RewardDetailViewState();
}

class _RewardDetailViewState extends State<RewardDetailView> {
  bool _isExchanging = false;

  String _formatPoints(int points) {
    final formatted = points.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},');
    return formatted;
  }

  void _onExchangeTap() {
    final bodyTemplate = context.t('reward_exchange_confirm_body');
    final bodyText = bodyTemplate.replaceAll(
        '\$1', _formatPoints(widget.voucher.pointsRequired));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            context.t('reward_exchange_confirm_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            bodyText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('RewardDetail: Nguoi dung huy dong diem');
                Navigator.pop(dialogContext);
              },
              child: Text(
                context.t('common_cancel'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _performExchange();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                context.t('common_confirm'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  Future<void> _performExchange() async {
    setState(() => _isExchanging = true);

    final (result, errorMessage) = await OfferService.exchangeVoucher(
      voucherId: widget.voucher.id,
    );

    if (!mounted) return;
    setState(() => _isExchanging = false);

    if (result != null) {
      _showExchangeSuccess(result);
    } else {
      _showExchangeError(errorMessage ?? 'Doi voucher that bai.');
    }
  }

  void _showExchangeSuccess(ExchangedVoucherData data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.greenGradientEnd, size: 24),
              const SizedBox(width: 8),
              Text(
                context.t('reward_exchange_success'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSuccessRow('Voucher', data.name),
                      const SizedBox(height: 6),
                      _buildSuccessRow('Ma', data.code),
                      const SizedBox(height: 6),
                      _buildSuccessRow('Giam gia', data.discountText),
                      const SizedBox(height: 6),
                      _buildSuccessRow(
                          'Diem da dung', _formatPoints(data.diemDaDung)),
                      const SizedBox(height: 6),
                      _buildSuccessRow(
                          'Diem con lai', _formatPoints(data.diemConLai)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  widget.onExchangeSuccess?.call(data.diemConLai);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.t('common_done'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.all(16),
        );
      },
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showExchangeError(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 24),
              SizedBox(width: 8),
              Text(
                'Doi voucher that bai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Dong',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.all(16),
        );
      },
    );
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
            debugPrint('RewardDetail: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          context.t('reward_detail_title'),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverImage(),
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  _buildTerms(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: widget.voucher.imageUrl.isNotEmpty
          ? Image.network(
              widget.voucher.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.local_offer_outlined,
          size: 64,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.voucher.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.voucher.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 1,
        decoration: BoxDecoration(
          color: AppColors.divider.withAlpha(80),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildTerms(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                context.t('reward_terms'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withAlpha(120),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withAlpha(80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTermItem(
                  icon: Icons.calendar_today_outlined,
                  text: widget.voucher.terms.isNotEmpty
                      ? widget.voucher.terms
                      : context.t('reward_default_terms'),
                ),
                if (widget.voucher.minOrderValue > 0) ...[
                  const SizedBox(height: 10),
                  _buildTermItem(
                    icon: Icons.shopping_cart_outlined,
                    text: '${context.t('reward_min_order')}: '
                        '${widget.voucher.minOrderValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} '
                        '${context.t('unit_currency')}',
                  ),
                ],
                const SizedBox(height: 10),
                _buildTermItem(
                  icon: Icons.inventory_2_outlined,
                  text: '${context.t('reward_remaining')}: ${widget.voucher.remaining} ${context.t('reward_voucher_unit')}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '${_formatPoints(widget.voucher.pointsRequired)} ${context.t('reward_points_required')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isExchanging ? null : _onExchangeTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isExchanging
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.t('reward_action_exchange_now'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
