import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../budget/presentation/budget_provider.dart';
import '../../../budget/domain/budget.dart';

/// Aggregate financial snapshot shown on the dashboard.
///
/// This is a *view model*, assembled by aggregating data from the
/// Accounts, Transactions, Debt, and Goals repositories. `totalMoney`
/// now comes from the real Accounts module; the rest stays as
/// representative mock data until Transactions/Debt/Goals are built.
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.totalMoney,
    required this.totalAssets,
    required this.totalDebt,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlyBudget,
    required this.savingGoalProgress,
    required this.userName,
  });

  final double totalMoney;
  final double totalAssets;
  final double totalDebt;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyBudget;
  final double savingGoalProgress; // 0.0–1.0
  final String userName;

  double get netWorth => totalMoney + totalAssets - totalDebt;
  double get remainingBudget => monthlyBudget - monthlyExpense;
}

/// Provides the current dashboard snapshot.
///
/// `totalMoney` is computed live from [totalBalanceProvider] (Accounts
/// module). The remaining fields stay as placeholder values until
/// Transactions, Debt, and Goals modules are built — at which point each
/// will be swapped for its own live provider the same way totalMoney was.
final dashboardSnapshotProvider = Provider<DashboardSnapshot>((ref) {
  final totalMoney = ref.watch(totalBalanceProvider);
  final monthlyIncome = ref.watch(monthlyIncomeProvider);
  final monthlyExpense = ref.watch(monthlyExpenseProvider);

  // Total limit semua budget bulanan
  final allBudgets = ref.watch(budgetsProvider).value ?? <Budget>[];
  final monthlyBudget = allBudgets
      .where((b) => b.period == BudgetPeriod.monthly)
      .fold<double>(0, (s, b) => s + b.limitAmount);

  return DashboardSnapshot(
    totalMoney: totalMoney,
    totalAssets: 185000000, // TODO: ganti dengan data Asset Manager
    totalDebt: 23750000,    // TODO: ganti dengan data Debt Manager
    monthlyIncome: monthlyIncome,
    monthlyExpense: monthlyExpense,
    monthlyBudget: monthlyBudget > 0 ? monthlyBudget : 10000000,
    savingGoalProgress: 0.64, // TODO: ganti dengan data Goals
    userName: 'Bayu',         // TODO: ganti dengan data profil pengguna
  );
});

/// Whether monetary values are masked (privacy toggle) on the dashboard.
final balanceVisibilityProvider = StateProvider<bool>((ref) => true);
