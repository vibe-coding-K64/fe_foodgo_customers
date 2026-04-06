import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../models/expense_model.dart';

/// Widget hien thi mot item giao dich trong danh sach.
///
/// Hien thi:
///   - Ben trai: Icon mon an / quan an.
///   - Giua: Ten quan (dam) + Ngay thang (xam).
///   - Ben phai: So tien am (mau do).
class ExpenseTransactionItem extends StatelessWidget {
  final ExpenseTransaction transaction;

  const ExpenseTransactionItem({
    super.key,
    required this.transaction,
  });

  /// Tra ve IconData dua tren ten icon.
  IconData _getIcon() {
    switch (transaction.iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'cookie':
        return Icons.cookie;
      case 'coffee':
        return Icons.coffee;
      case 'fastfood':
        return Icons.fastfood;
      default:
        return Icons.receipt_long;
    }
  }

  /// Tra ve mau nen icon dua tren category.
  Color _getIconBackground() {
    switch (transaction.categoryKey) {
      case 'expense_category_com':
        return AppColors.primary.withAlpha(25);
      case 'expense_category_tea':
        return AppColors.primaryLight.withAlpha(25);
      case 'expense_category_snack':
        return Colors.orange.withAlpha(25);
      case 'expense_category_coffee':
        return Colors.brown.withAlpha(25);
      case 'expense_category_fastfood':
        return Colors.red.withAlpha(25);
      default:
        return AppColors.surfaceVariant;
    }
  }

  /// Format so tien voi dau phay.
  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},');
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(100)),
      ),
      child: Row(
        children: [
          // Icon ben trai.
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getIconBackground(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Thong tin giao dich o giua.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.storeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // So tien ben phai (mau do, co dau tru).
          Text(
            '- ${_formatCurrency(transaction.amount)}${LanguageService.translate('expense_prefix')}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// Format ngay thanh chuoi dd/MM/yyyy.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}
