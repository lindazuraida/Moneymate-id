import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/reports_helper.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import 'accounts_provider.dart';
import 'categories_provider.dart';
import 'transactions_provider.dart';

class ReportsFilterNotifier extends StateNotifier<ReportsFilter> {
  ReportsFilterNotifier() : super(ReportsFilter.currentMonth());

  void setRange(DateTime start, DateTime end) {
    state = state.copyWith(start: start, end: end);
  }
}

final reportsFilterProvider =
    StateNotifierProvider<ReportsFilterNotifier, ReportsFilter>((ref) {
  return ReportsFilterNotifier();
});

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final filter = ref.watch(reportsFilterProvider);
  final txs = ref.watch(transactionsProvider).value ?? <Transaction>[];
  return txs
      .where((tx) =>
          !tx.date.isBefore(filter.start) && !tx.date.isAfter(filter.end))
      .toList();
});

final reportsSummaryProvider = Provider<({double income, double expense})>((ref) {
  final txs = ref.watch(filteredTransactionsProvider);
  double income = 0;
  double expense = 0;
  for (final tx in txs) {
    if (tx.type == TransactionType.income) income += tx.amount;
    if (tx.type == TransactionType.expense) expense += tx.amount;
  }
  return (income: income, expense: expense);
});

final categoryExpenseDataProvider = Provider<List<CategoryExpenseData>>((ref) {
  final txs = ref.watch(filteredTransactionsProvider);
  final categories = ref.watch(categoriesProvider).value ?? <Category>[];

  final meta = <String, CategoryExpenseData>{};
  for (final c in categories) {
    meta[c.id] = CategoryExpenseData(
      categoryId: c.id,
      name: c.name,
      color: c.color,
      icon: c.icon,
      amount: 0,
    );
  }

  return computeExpenseByCategory(transactions: txs, categoryMeta: meta);
});

final monthlyFinanceDataProvider = Provider<List<MonthlyFinanceData>>((ref) {
  final filter = ref.watch(reportsFilterProvider);
  final allTxs = ref.watch(transactionsProvider).value ?? <Transaction>[];
  return computeMonthlyData(
    allTransactions: allTxs,
    rangeStart: filter.start,
    rangeEnd: filter.end,
  );
});

final balanceTrendProvider = Provider<List<BalancePoint>>((ref) {
  final filter = ref.watch(reportsFilterProvider);
  final allTxs = ref.watch(transactionsProvider).value ?? <Transaction>[];
  final currentBalance = ref.watch(totalBalanceProvider);
  return computeBalanceTrend(
    currentTotalBalance: currentBalance,
    allTransactions: allTxs,
    rangeStart: filter.start,
    rangeEnd: filter.end,
  );
});
