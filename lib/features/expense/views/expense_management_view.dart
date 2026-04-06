import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/language_service.dart';
import '../models/expense_model.dart';
import 'widgets/expense_chart_widget.dart';
import 'widgets/expense_filter_bar.dart';
import 'widgets/expense_summary_card.dart';
import 'widgets/expense_transaction_item.dart';

/// Man hinh Quan ly chi tieu.
///
/// Hien thi:
///   - Thanh loc thoi gian (ChoiceChip).
///   - Card tong quan chi tieu thang.
///   - Bieu do phan bo chi tieu (PieChart).
///   - Danh sach giao dich.
///
/// Duoc goi tu:
///   - ProfileView: bam "Quan ly chi tieu"
class ExpenseManagementView extends StatefulWidget {
  const ExpenseManagementView({super.key});

  @override
  State<ExpenseManagementView> createState() => _ExpenseManagementViewState();
}

class _ExpenseManagementViewState extends State<ExpenseManagementView> {
  /// Thang duoc chon (mac dinh la thang hien tai).
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    debugPrint('ExpenseManagement: Man hinh da mo, thang $_selectedMonth');
  }

  /// Lay danh sach giao dich theo thang duoc chon.
  List<ExpenseTransaction> _getFilteredTransactions() {
    return kMockTransactions
        .where((t) => t.date.month == _selectedMonth)
        .toList();
  }

  /// Tinh tong chi tieu theo thang.
  double _getTotalExpense() {
    return _getFilteredTransactions()
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Tao danh sach phan bo cho PieChart dua tren du lieu.
  List<ExpenseChartItem> _buildChartItems() {
    final transactions = _getFilteredTransactions();
    if (transactions.isEmpty) return [];

    // Tinh tong theo category.
    final Map<String, double> categoryTotals = {};
    for (final t in transactions) {
      categoryTotals[t.categoryKey] =
          (categoryTotals[t.categoryKey] ?? 0) + t.amount;
    }

    // Sap xep theo gia tri giam dan.
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Danh sach mau.
    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      Colors.orange,
      Colors.brown,
      Colors.purple,
    ];

    return sortedEntries.asMap().entries.map((entry) {
      return ExpenseChartItem(
        categoryKey: entry.value.key,
        amount: entry.value.value,
        color: colors[entry.key % colors.length],
      );
    }).toList();
  }

  /// Xu ly khi nguoi dung chon thang khac.
  void _onMonthChanged(int month) {
    debugPrint('ExpenseManagement: Chon thang $month');
    setState(() => _selectedMonth = month);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _getFilteredTransactions();
    final totalExpense = _getTotalExpense();
    final chartItems = _buildChartItems();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('ExpenseManagement: Nguoi dung bam nut back');
            Navigator.pop(context);
          },
        ),
        title: Text(
          LanguageService.translate('expense_title'),
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
          const SizedBox(height: 12),
          // Thanh loc thang.
          ExpenseFilterBar(
            selectedMonth: _selectedMonth,
            onMonthChanged: _onMonthChanged,
          ),
          const SizedBox(height: 12),
          // Noi dung cuon.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card tong quan chi tieu.
                  ExpenseSummaryCard(
                    totalAmount: totalExpense,
                    month: _selectedMonth,
                  ),
                  const SizedBox(height: 16),
                  // Bieu do phan bo.
                  if (chartItems.isNotEmpty) ...[
                    ExpenseChartWidget(items: chartItems),
                    const SizedBox(height: 20),
                  ],
                  // Tieu de lich su giao dich.
                  Text(
                    LanguageService.translate('expense_history_title'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Danh sach giao dich.
                  if (transactions.isEmpty)
                    _buildEmptyState()
                  else
                    _buildTransactionList(transactions),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget trang thai rong (khong co giao dich).
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textHint.withAlpha(100),
          ),
          const SizedBox(height: 12),
          Text(
            LanguageService.translate('expense_no_history'),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget danh sach giao dich (khong cuon rieng).
  Widget _buildTransactionList(List<ExpenseTransaction> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return ExpenseTransactionItem(
          transaction: transactions[index],
        );
      },
    );
  }
}
