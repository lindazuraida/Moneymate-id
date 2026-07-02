import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/budget_local_datasource.dart';
import '../data/budget_model.dart';
import '../domain/budget.dart';
import '../../transactions/presentation/providers/transactions_provider.dart';
import '../../transactions/domain/entities/transaction.dart';

final budgetLocalDataSourceProvider = Provider<BudgetLocalDataSource>((ref) {
  return BudgetLocalDataSource();
});

/// Mengelola daftar budget dan mengekspos operasi CRUD.
class BudgetsNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  BudgetsNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _load();
  }

  final BudgetLocalDataSource _dataSource;
  final _uuid = const Uuid();

  Future<void> _load() async {
    try {
      final budgets = await _dataSource.getAllBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBudget({
    required String category,
    required double limitAmount,
    required BudgetPeriod period,
    required int colorValue,
  }) async {
    final budget = BudgetModel(
      id: _uuid.v4(),
      category: category,
      limitAmount: limitAmount,
      period: period,
      colorValue: colorValue,
    );
    await _dataSource.addBudget(budget);
    await _load();
  }

  Future<void> updateBudget(Budget budget) async {
    await _dataSource.updateBudget(BudgetModel.fromEntity(budget));
    await _load();
  }

  Future<void> deleteBudget(String id) async {
    await _dataSource.deleteBudget(id);
    await _load();
  }

  Future<void> refresh() => _load();
}

final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>>((ref) {
  final ds = ref.watch(budgetLocalDataSourceProvider);
  return BudgetsNotifier(ds);
});

/// Menghitung pengeluaran aktual per kategori untuk setiap budget,
/// menghasilkan daftar [BudgetProgress] yang siap ditampilkan UI.
///
/// Provider ini me-watch BOTH [budgetsProvider] dan [transactionsProvider]
/// — setiap kali ada transaksi baru, progres semua budget otomatis
/// ter-update tanpa perlu manual refresh.
final budgetProgressProvider = Provider<List<BudgetProgress>>((ref) {
  final budgetsState = ref.watch(budgetsProvider);
  final transactionsState = ref.watch(transactionsProvider);

  final budgets = budgetsState.value ?? <Budget>[];
  final transactions = transactionsState.value ?? <Transaction>[];
  final now = DateTime.now();

  return budgets.map((budget) {
    final range = budget.period.activeRange(now);

    // Jumlahkan semua pengeluaran dalam rentang aktif periode budget
    // yang kategorinya cocok dengan budget ini.
    final spent = transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.category == budget.category &&
            !t.date.isBefore(range.start) &&
            t.date.isBefore(range.end))
        .fold<double>(0, (sum, t) => sum + t.amount);

    return BudgetProgress(budget: budget, spent: spent);
  }).toList();
});

/// Filter progres per periode — dipakai tab di halaman Budget.
final budgetProgressByPeriodProvider =
    Provider.family<List<BudgetProgress>, BudgetPeriod>((ref, period) {
  final allProgress = ref.watch(budgetProgressProvider);
  return allProgress
      .where((p) => p.budget.period == period)
      .toList()
    ..sort((a, b) => b.ratio.compareTo(a.ratio)); // yang paling mepet dulu
});
