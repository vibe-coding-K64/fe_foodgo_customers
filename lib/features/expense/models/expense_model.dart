/// Model mot giao dich chi tieu.
class ExpenseTransaction {
  final String id;
  final String storeName;
  final String iconName;
  final String categoryKey;
  final DateTime date;
  final double amount;

  const ExpenseTransaction({
    required this.id,
    required this.storeName,
    required this.iconName,
    required this.categoryKey,
    required this.date,
    required this.amount,
  });
}

/// Mock data danh sach giao dich.
final List<ExpenseTransaction> kMockTransactions = [
  ExpenseTransaction(
    id: '1',
    storeName: 'Quán Cơm Sài Gòn',
    iconName: 'restaurant',
    categoryKey: 'expense_category_com',
    date: DateTime(2026, 4, 3),
    amount: 55000,
  ),
  ExpenseTransaction(
    id: '2',
    storeName: 'Tiệm Trà Sữa Gong Cha',
    iconName: 'local_cafe',
    categoryKey: 'expense_category_tea',
    date: DateTime(2026, 4, 2),
    amount: 35000,
  ),
  ExpenseTransaction(
    id: '3',
    storeName: 'Cửa Hàng Ăn Vặt Hồng Hạnh',
    iconName: 'cookie',
    categoryKey: 'expense_category_snack',
    date: DateTime(2026, 4, 1),
    amount: 25000,
  ),
  ExpenseTransaction(
    id: '4',
    storeName: 'Highlands Coffee',
    iconName: 'coffee',
    categoryKey: 'expense_category_coffee',
    date: DateTime(2026, 3, 28),
    amount: 45000,
  ),
  ExpenseTransaction(
    id: '5',
    storeName: 'Burger King',
    iconName: 'fastfood',
    categoryKey: 'expense_category_fastfood',
    date: DateTime(2026, 3, 25),
    amount: 89000,
  ),
];
