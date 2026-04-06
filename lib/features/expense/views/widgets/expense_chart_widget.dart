import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/language_service.dart';

/// Item phan bo trong bieu do.
class ExpenseChartItem {
  final String categoryKey;
  final double amount;
  final Color color;

  const ExpenseChartItem({
    required this.categoryKey,
    required this.amount,
    required this.color,
  });

  double get percentage => amount;
}

/// Widget bieu do phan bo chi tieu (Pie Chart).
///
/// Hien thi:
///   - Bieu do tron (PieChart) voi fl_chart.
///   - Chú thích (Legend) ben canh.
class ExpenseChartWidget extends StatelessWidget {
  final List<ExpenseChartItem> items;

  const ExpenseChartWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalAmount = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tieu de.
          Text(
            LanguageService.translate('expense_chart_title'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Bieu do tron.
              SizedBox(
                width: 130,
                height: 130,
                child: PieChart(
                  PieChartData(
                    sections: _buildSections(totalAmount),
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Chú thích.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < items.length; i++)
                      _buildLegendItem(items[i], totalAmount),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tao cac section cho PieChart.
  List<PieChartSectionData> _buildSections(double total) {
    return items.map((item) {
      final percentage = (item.amount / total) * 100;
      return PieChartSectionData(
        value: item.amount,
        color: item.color,
        radius: 22,
        title: '${percentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  /// Tao mot dong chu thich.
  Widget _buildLegendItem(ExpenseChartItem item, double total) {
    final percentage = (item.amount / total) * 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LanguageService.translate(item.categoryKey),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
