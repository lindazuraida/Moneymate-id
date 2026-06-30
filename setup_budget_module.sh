#!/bin/bash
set -e

mkdir -p lib/domain/entities lib/domain/repositories
mkdir -p lib/data/models lib/data/datasources lib/data/repositories
mkdir -p lib/presentation/providers lib/presentation/pages lib/presentation/widgets
mkdir -p lib/core/utils

# ============================================================
# CORE: budget_calculator.dart
# ============================================================
cat > lib/core/utils/budget_calculator.dart << 'DARTEOF'
import 'package:flutter/material.dart';

class BudgetCalculator {
  BudgetCalculator._();

  static double progressRatio(double spent, double limit) {
    if (limit <= 0) return 0;
    final ratio = spent / limit;
    return ratio.isNaN ? 0 : ratio;
  }

  static Color progressColor(double ratio) {
    if (ratio >= 1.0) return const Color(0xFFC62828);
    if (ratio >= 0.7) return const Color(0xFFF9A825);
    return const Color(0xFF2E7D32);
  }

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) {
    final firstOfNextMonth = DateTime(date.year, date.month + 1, 1);
    return firstOfNextMonth.subtract(const Duration(days: 1));
  }

  static DateTime endOfWeek(DateTime start) => start.add(const Duration(days: 6));
}
DARTEOF

# ============================================================
# DOMAIN: Budget entity
# ============================================================
cat > lib/domain/entities/budget.dart << 'DARTEOF'
import 'package:flutter/foundation.dart';

enum BudgetPeriodType {
  weekly,
  monthly,
  custom;

  String get label {
    switch (this) {
      case BudgetPeriodType.weekly:
        return 'Mingguan';
      case BudgetPeriodType.monthly:
        return 'Bulanan';
      case BudgetPeriodType.custom:
        return 'Custom';
    }
  }
}

@immutable
class Budget {
  const Budget({
    required this.id,
    required this.limitAmount,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    this.categoryId,
  });

  final String id;
  final String? categoryId; // null = budget total/overall (semua kategori expense)
  final double limitAmount;
  final BudgetPeriodType periodType;
  final DateTime startDate;
  final DateTime endDate;

  bool get isOverall => categoryId == null;

  Budget copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    BudgetPeriodType? periodType,
    DateTime? startDate,
    DateTime? endDate,
    bool clearCategoryId = false,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      limitAmount: limitAmount ?? this.limitAmount,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
DARTEOF

# ============================================================
# DOMAIN: Repository interface
# ============================================================
cat > lib/domain/repositories/budget_repository.dart << 'DARTEOF'
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<void> addBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
}
DARTEOF

# ============================================================
# DATA: Model
# ============================================================
cat > lib/data/models/budget_model.dart << 'DARTEOF'
import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.limitAmount,
    required super.periodType,
    required super.startDate,
    required super.endDate,
    super.categoryId,
  });

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      categoryId: budget.categoryId,
      limitAmount: budget.limitAmount,
      periodType: budget.periodType,
      startDate: budget.startDate,
      endDate: budget.endDate,
    );
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String?,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      periodType: BudgetPeriodType.values.firstWhere(
        (p) => p.name == json['periodType'],
        orElse: () => BudgetPeriodType.monthly,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limitAmount': limitAmount,
      'periodType': periodType.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
DARTEOF

# ============================================================
# DATA: Datasource
# ============================================================
cat > lib/data/datasources/budget_local_datasource.dart << 'DARTEOF'
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/budget.dart';
import '../models/budget_model.dart';

class BudgetLocalDataSource {
  static const _key = 'moneymate_budgets';

  Future<List<BudgetModel>> getAllBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveAll(List<BudgetModel> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<void> addBudget(Budget budget) async {
    final all = await getAllBudgets();
    all.add(BudgetModel.fromEntity(budget));
    await _saveAll(all);
  }

  Future<void> updateBudget(Budget budget) async {
    final all = await getAllBudgets();
    final idx = all.indexWhere((b) => b.id == budget.id);
    if (idx != -1) all[idx] = BudgetModel.fromEntity(budget);
    await _saveAll(all);
  }

  Future<void> deleteBudget(String id) async {
    final all = await getAllBudgets();
    all.removeWhere((b) => b.id == id);
    await _saveAll(all);
  }
}
DARTEOF

# ============================================================
# DATA: Repository implementation
# ============================================================
cat > lib/data/repositories/budget_repository_impl.dart << 'DARTEOF'
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._dataSource);

  final BudgetLocalDataSource _dataSource;

  @override
  Future<List<Budget>> getAllBudgets() => _dataSource.getAllBudgets();

  @override
  Future<void> addBudget(Budget budget) => _dataSource.addBudget(budget);

  @override
  Future<void> updateBudget(Budget budget) => _dataSource.updateBudget(budget);

  @override
  Future<void> deleteBudget(String id) => _dataSource.deleteBudget(id);
}
DARTEOF

# ============================================================
# PRESENTATION: Provider
# ============================================================
cat > lib/presentation/providers/budgets_provider.dart << 'DARTEOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/budget_local_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/budget_repository.dart';
import 'transactions_provider.dart';

final budgetLocalDataSourceProvider = Provider<BudgetLocalDataSource>((ref) {
  return BudgetLocalDataSource();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final dataSource = ref.watch(budgetLocalDataSourceProvider);
  return BudgetRepositoryImpl(dataSource);
});

class BudgetsNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  BudgetsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadBudgets();
  }

  final BudgetRepository _repository;
  final _uuid = const Uuid();

  Future<void> _loadBudgets() async {
    try {
      final budgets = await _repository.getAllBudgets();
      state = AsyncValue.data(budgets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addBudget({
    String? categoryId,
    required double limitAmount,
    required BudgetPeriodType periodType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final newBudget = Budget(
      id: _uuid.v4(),
      categoryId: categoryId,
      limitAmount: limitAmount,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
    );
    await _repository.addBudget(newBudget);
    await _loadBudgets();
  }

  Future<void> updateBudget(Budget budget) async {
    await _repository.updateBudget(budget);
    await _loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.deleteBudget(id);
    await _loadBudgets();
  }

  Future<void> refresh() => _loadBudgets();
}

final budgetsProvider = StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetsNotifier(repository);
});

/// Menghitung total pengeluaran yang relevan untuk satu budget, berdasarkan
/// transaksi expense yang ada di dalam rentang tanggal budget dan
/// (kalau budget per kategori) cocok kategorinya.
double spentForBudget(Budget budget, List<Transaction> allTransactions) {
  double total = 0;
  for (final tx in allTransactions) {
    if (tx.type != TransactionType.expense) continue;
    final inRange = !tx.date.isBefore(budget.startDate) &&
        !tx.date.isAfter(budget.endDate.add(const Duration(days: 1)));
    if (!inRange) continue;
    if (!budget.isOverall && tx.categoryId != budget.categoryId) continue;
    total += tx.amount;
  }
  return total;
}

/// Provider keluarga yang mengembalikan total terpakai untuk satu budget
/// tertentu, otomatis ter-update setiap kali transactionsProvider berubah.
final budgetSpentProvider = Provider.family<double, Budget>((ref, budget) {
  final transactionsState = ref.watch(transactionsProvider);
  final transactions = transactionsState.value ?? <Transaction>[];
  return spentForBudget(budget, transactions);
});
DARTEOF

echo "✅ Modul Budget (domain/data/provider) berhasil dibuat."

mkdir -p lib/presentation/pages lib/presentation/widgets

# ============================================================
# WIDGET: budget_card.dart
# ============================================================
cat > lib/presentation/widgets/budget_card.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import '../../core/utils/budget_calculator.dart';
import '../../core/utils/transaction_formatters.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.category,
    required this.onTap,
  });

  final Budget budget;
  final double spent;
  final Category? category;
  final VoidCallback onTap;

  String _periodLabel() {
    final s = budget.startDate;
    final e = budget.endDate;
    String fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
    if (budget.periodType == BudgetPeriodType.monthly) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${months[s.month - 1]} ${s.year}';
    }
    return '${fmt(s)} - ${fmt(e)}';
  }

  @override
  Widget build(BuildContext context) {
    final ratio = BudgetCalculator.progressRatio(spent, budget.limitAmount);
    final color = BudgetCalculator.progressColor(ratio);
    final remaining = budget.limitAmount - spent;
    final title = budget.isOverall ? 'Total Bulanan' : (category?.name ?? 'Kategori Dihapus');
    final icon = budget.isOverall ? Icons.account_balance_wallet_outlined : (category?.icon ?? Icons.category_outlined);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (category?.color ?? color).withOpacity(0.15),
                    child: Icon(icon, color: category?.color ?? color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          '${budget.periodType.label} • ${_periodLabel()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(ratio * 100).clamp(0, 999).toStringAsFixed(0)}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${TransactionFormatters.currency(spent)} / ${TransactionFormatters.currency(budget.limitAmount)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    remaining >= 0
                        ? 'Sisa ${TransactionFormatters.currency(remaining)}'
                        : 'Lebih ${TransactionFormatters.currency(remaining.abs())}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: remaining >= 0 ? null : const Color(0xFFC62828),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
DARTEOF

# ============================================================
# PAGE: budgets_page.dart
# ============================================================
cat > lib/presentation/pages/budgets_page.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import '../providers/categories_provider.dart';
import '../widgets/budget_card.dart';
import 'add_budget_page.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsState = ref.watch(budgetsProvider);
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBudgetPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: budgetsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat budget: $error')),
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada budget.\nTekan tombol + untuk membuat budget pertama.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final categories = categoriesState.value ?? [];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final spent = ref.watch(budgetSpentProvider(budget));
              final category = budget.categoryId != null && categories.where((c) => c.id == budget.categoryId).isNotEmpty
                  ? categories.firstWhere((c) => c.id == budget.categoryId)
                  : null;

              return BudgetCard(
                budget: budget,
                spent: spent,
                category: category,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddBudgetPage(editingBudget: budget)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
DARTEOF

echo "✅ budget_card.dart dan budgets_page.dart berhasil dibuat."

cat > lib/presentation/pages/add_budget_page.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/budget_calculator.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../providers/budgets_provider.dart';
import '../providers/categories_provider.dart';

enum _BudgetScope { overall, category }

class AddBudgetPage extends ConsumerStatefulWidget {
  const AddBudgetPage({super.key, this.editingBudget});

  final Budget? editingBudget;

  @override
  ConsumerState<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends ConsumerState<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  _BudgetScope _scope = _BudgetScope.overall;
  String? _categoryId;
  BudgetPeriodType _periodType = BudgetPeriodType.monthly;
  DateTime _monthAnchor = DateTime.now();
  DateTime _weekStart = DateTime.now();
  DateTime _customStart = DateTime.now();
  DateTime _customEnd = DateTime.now().add(const Duration(days: 6));

  bool get _isEditing => widget.editingBudget != null;

  @override
  void initState() {
    super.initState();
    final b = widget.editingBudget;
    if (b != null) {
      _scope = b.isOverall ? _BudgetScope.overall : _BudgetScope.category;
      _categoryId = b.categoryId;
      _periodType = b.periodType;
      _amountController.text = b.limitAmount.round().toString();
      _monthAnchor = b.startDate;
      _weekStart = b.startDate;
      _customStart = b.startDate;
      _customEnd = b.endDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final raw = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _monthAnchor,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih bulan (tanggal bebas)',
    );
    if (picked != null) setState(() => _monthAnchor = picked);
  }

  Future<void> _pickWeekStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal mulai minggu',
    );
    if (picked != null) setState(() => _weekStart = picked);
  }

  Future<void> _pickCustomStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Tanggal mulai',
    );
    if (picked != null) {
      setState(() {
        _customStart = picked;
        if (_customEnd.isBefore(_customStart)) {
          _customEnd = _customStart;
        }
      });
    }
  }

  Future<void> _pickCustomEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customEnd.isBefore(_customStart) ? _customStart : _customEnd,
      firstDate: _customStart,
      lastDate: DateTime(2100),
      helpText: 'Tanggal selesai',
    );
    if (picked != null) setState(() => _customEnd = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah limit harus diisi dan lebih dari 0')),
      );
      return;
    }
    if (_scope == _BudgetScope.category && _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    late DateTime startDate;
    late DateTime endDate;
    switch (_periodType) {
      case BudgetPeriodType.monthly:
        startDate = BudgetCalculator.startOfMonth(_monthAnchor);
        endDate = BudgetCalculator.endOfMonth(_monthAnchor);
        break;
      case BudgetPeriodType.weekly:
        startDate = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
        endDate = BudgetCalculator.endOfWeek(startDate);
        break;
      case BudgetPeriodType.custom:
        startDate = DateTime(_customStart.year, _customStart.month, _customStart.day);
        endDate = DateTime(_customEnd.year, _customEnd.month, _customEnd.day);
        break;
    }

    final notifier = ref.read(budgetsProvider.notifier);
    final categoryId = _scope == _BudgetScope.overall ? null : _categoryId;

    if (_isEditing) {
      final updated = widget.editingBudget!.copyWith(
        categoryId: categoryId,
        clearCategoryId: _scope == _BudgetScope.overall,
        limitAmount: amount,
        periodType: _periodType,
        startDate: startDate,
        endDate: endDate,
      );
      await notifier.updateBudget(updated);
    } else {
      await notifier.addBudget(
        categoryId: categoryId,
        limitAmount: amount,
        periodType: _periodType,
        startDate: startDate,
        endDate: endDate,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Budget'),
        content: const Text('Yakin ingin menghapus budget ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true && widget.editingBudget != null) {
      await ref.read(budgetsProvider.notifier).deleteBudget(widget.editingBudget!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final expenseCategories = ref.watch(expenseCategoriesProvider);

    if (_categoryId != null && !expenseCategories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'Tambah Budget'),
        actions: [
          if (_isEditing)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<_BudgetScope>(
              segments: const [
                ButtonSegment(value: _BudgetScope.overall, label: Text('Total Bulanan')),
                ButtonSegment(value: _BudgetScope.category, label: Text('Per Kategori')),
              ],
              selected: {_scope},
              onSelectionChanged: (selection) => setState(() => _scope = selection.first),
            ),
            if (_scope == _BudgetScope.category) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: expenseCategories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(c.icon, size: 18, color: c.color),
                              const SizedBox(width: 8),
                              Text(c.name),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Limit Budget (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text('Periode', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<BudgetPeriodType>(
              segments: const [
                ButtonSegment(value: BudgetPeriodType.weekly, label: Text('Mingguan')),
                ButtonSegment(value: BudgetPeriodType.monthly, label: Text('Bulanan')),
                ButtonSegment(value: BudgetPeriodType.custom, label: Text('Custom')),
              ],
              selected: {_periodType},
              onSelectionChanged: (selection) => setState(() => _periodType = selection.first),
            ),
            const SizedBox(height: 16),
            if (_periodType == BudgetPeriodType.monthly)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bulan'),
                subtitle: Text(
                  '${BudgetCalculator.startOfMonth(_monthAnchor).day}-${BudgetCalculator.endOfMonth(_monthAnchor).day} '
                  '${_monthAnchor.month}/${_monthAnchor.year}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickMonth,
              ),
            if (_periodType == BudgetPeriodType.weekly)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mulai Minggu'),
                subtitle: Text(
                  '${_fmtDate(_weekStart)} - ${_fmtDate(BudgetCalculator.endOfWeek(_weekStart))}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickWeekStart,
              ),
            if (_periodType == BudgetPeriodType.custom) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Mulai'),
                subtitle: Text(_fmtDate(_customStart)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickCustomStart,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Selesai'),
                subtitle: Text(_fmtDate(_customEnd)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickCustomEnd,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
DARTEOF

echo "✅ add_budget_page.dart berhasil dibuat."
