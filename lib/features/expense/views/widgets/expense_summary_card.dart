import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Widget hien thi card tong quan chi tieu thang.
///
/// Hien thi:
///   - Nền gradient xanh.
///   - Tieude "Tong chi tieu thang X".
///   - Con so tong (font rat to, dam).
class ExpenseSummaryCard extends StatelessWidget {
  final double totalAmount;
  final int month;

  const ExpenseSummaryCard({
    super.key,
    required this.totalAmount,
    required this.month,
  });

  /// Format so tien voi dau phay.
  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},');
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = _getMonthLabel(month);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieude phu.
          Text(
            '${LanguageService.translate('expense_total_label')} $monthLabel',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withAlpha(200),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Con so tong.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(totalAmount),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  LanguageService.translate('expense_prefix'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withAlpha(200),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tra ve nhan thang theo so.
  String _getMonthLabel(int month) {
    switch (month) {
      case 1:
        return '1';
      case 2:
        return '2';
      case 3:
        return '3';
      case 4:
        return '4';
      case 5:
        return '5';
      case 6:
        return '6';
      case 7:
        return '7';
      case 8:
        return '8';
      case 9:
        return '9';
      case 10:
        return '10';
      case 11:
        return '11';
      case 12:
        return '12';
      default:
        return month.toString();
    }
  }
}
