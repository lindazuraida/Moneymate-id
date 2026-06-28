import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aggregate financial snapshot shown on the dashboard.
///
/// This is intentionally a plain data class with no Isar/Firestore
/// annotations — it's a *view model*, assembled by aggregating data from
/// the Accounts, Transactions, Debt, and Goals repositories once those
/// modules exist. For now it's seeded with representative mock data so
/// the dashboard UI can be built and reviewed independently.
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

  static const mock = DashboardSnapshot(
    totalMoney: 42500000,
    totalAssets: 185000000,
    totalDebt: 23750000,
    monthlyIncome: 14500000,
    monthlyExpense: 8230000,
    monthlyBudget: 10000000,
    savingGoalProgress: 0.64,
    userName: 'Bayu',
  );
}

/// Provides the current dashboard snapshot.
///
/// Once the Accounts/Transactions/Debt/Goals repositories are built, this
/// becomes a computed provider (`Provider`/`FutureProvider`) that watches
/// those repositories and aggregates live data instead of returning mock.
final dashboardSnapshotProvider = Provider<DashboardSnapshot>((ref) {
  return DashboardSnapshot.mock;
});

/// Whether monetary values are masked (privacy toggle) on the dashboard.
final balanceVisibilityProvider = StateProvider<bool>((ref) => true);
