import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Widget thanh loc thoi gian cho trang quan ly chi tieu.
///
/// Hien thi thanh lua chon ngang (ChoiceChip) de loc theo thang:
///   - Tháng này.
///   - Tháng trước.
///   - Tháng X/Y (tuy chon).
class ExpenseFilterBar extends StatelessWidget {
  /// Chi so thang duoc chon (1 = Thang 1, ...).
  final int selectedMonth;

  /// Ham goi khi nguoi dung chon thang.
  final ValueChanged<int> onMonthChanged;

  const ExpenseFilterBar({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Tinh thang hien tai va thang truoc.
    final now = DateTime.now();
    final thisMonth = now.month;
    final thisYear = now.year;
    final lastMonth = thisMonth == 1 ? 12 : thisMonth - 1;
    final lastMonthYear = thisMonth == 1 ? thisYear - 1 : thisYear;

    // Tao danh sach lua chon.
    final options = [
      _FilterOption(
        month: thisMonth,
        year: thisYear,
        labelKey: 'expense_filter_this_month',
      ),
      _FilterOption(
        month: lastMonth,
        year: lastMonthYear,
        labelKey: 'expense_filter_last_month',
      ),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selectedMonth == option.month;

          return ChoiceChip(
            label: Text(context.t(option.labelKey)),
            selected: isSelected,
            onSelected: (_) {
              debugPrint('ExpenseFilter: Chon loc [$option]');
              onMonthChanged(option.month);
            },
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            elevation: 0,
          );
        },
      ),
    );
  }
}

/// Lua chon loc theo thang.
class _FilterOption {
  final int month;
  final int year;
  final String labelKey;

  const _FilterOption({
    required this.month,
    required this.year,
    required this.labelKey,
  });

  @override
  String toString() => '$month/$year';
}
