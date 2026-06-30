#!/bin/bash
set -e

mkdir -p lib/domain/entities lib/domain/repositories
mkdir -p lib/data/models lib/data/datasources lib/data/repositories
mkdir -p lib/presentation/providers lib/presentation/pages lib/presentation/widgets
mkdir -p lib/core/utils

# ============================================================
# CORE: formatter (currency + date label) khusus modul ini
# ============================================================
cat > lib/core/utils/transaction_formatters.dart << 'DARTEOF'
class TransactionFormatters {
  TransactionFormatters._();

  static String currency(double value) {
    final isNegative = value < 0;
    final intValue = value.abs().round();
    final str = intValue.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${isNegative ? '-' : ''}Rp $buffer';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static String time(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
DARTEOF

# ============================================================
# DOMAIN: Category entity
# ============================================================
cat > lib/domain/entities/category.dart << 'DARTEOF'
import 'package:flutter/material.dart';

enum CategoryType {
  income,
  expense;

  String get label => this == CategoryType.income ? 'Pemasukan' : 'Pengeluaran';
}

enum CategoryIconKey {
  salary,
  bonus,
  gift,
  food,
  transport,
  shopping,
  bill,
  entertainment,
  health,
  education,
  savings,
  other;

  IconData get icon {
    switch (this) {
      case CategoryIconKey.salary:
        return Icons.work_outline;
      case CategoryIconKey.bonus:
        return Icons.card_giftcard_outlined;
      case CategoryIconKey.gift:
        return Icons.redeem_outlined;
      case CategoryIconKey.food:
        return Icons.restaurant_outlined;
      case CategoryIconKey.transport:
        return Icons.directions_car_outlined;
      case CategoryIconKey.shopping:
        return Icons.shopping_bag_outlined;
      case CategoryIconKey.bill:
        return Icons.receipt_long_outlined;
      case CategoryIconKey.entertainment:
        return Icons.movie_outlined;
      case CategoryIconKey.health:
        return Icons.favorite_outline;
      case CategoryIconKey.education:
        return Icons.school_outlined;
      case CategoryIconKey.savings:
        return Icons.savings_outlined;
      case CategoryIconKey.other:
        return Icons.category_outlined;
    }
  }
}

@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorValue,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final CategoryType type;
  final CategoryIconKey iconKey;
  final int colorValue;
  final bool isDefault;

  Color get color => Color(colorValue);
  IconData get icon => iconKey.icon;

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    CategoryIconKey? iconKey,
    int? colorValue,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
DARTEOF

# ============================================================
# DOMAIN: Transaction entity
# ============================================================
cat > lib/domain/entities/transaction.dart << 'DARTEOF'
import 'package:flutter/foundation.dart';

enum TransactionType {
  income,
  expense,
  transfer;

  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}

@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.date,
    required this.createdAt,
    this.toAccountId,
    this.categoryId,
    this.note,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String accountId;
  final String? toAccountId;
  final String? categoryId;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    bool clearToAccountId = false,
    bool clearCategoryId = false,
    bool clearNote = false,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      toAccountId: clearToAccountId ? null : (toAccountId ?? this.toAccountId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      note: clearNote ? null : (note ?? this.note),
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
DARTEOF

# ============================================================
# DOMAIN: Repository interfaces
# ============================================================
cat > lib/domain/repositories/category_repository.dart << 'DARTEOF'
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
DARTEOF

cat > lib/domain/repositories/transaction_repository.dart << 'DARTEOF'
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}
DARTEOF

# ============================================================
# DATA: Models
# ============================================================
cat > lib/data/models/category_model.dart << 'DARTEOF'
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.iconKey,
    required super.colorValue,
    super.isDefault,
  });

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      type: category.type,
      iconKey: category.iconKey,
      colorValue: category.colorValue,
      isDefault: category.isDefault,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CategoryType.expense,
      ),
      iconKey: CategoryIconKey.values.firstWhere(
        (k) => k.name == json['iconKey'],
        orElse: () => CategoryIconKey.other,
      ),
      colorValue: json['colorValue'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'iconKey': iconKey.name,
      'colorValue': colorValue,
      'isDefault': isDefault,
    };
  }
}
DARTEOF

cat > lib/data/models/transaction_model.dart << 'DARTEOF'
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.accountId,
    required super.date,
    required super.createdAt,
    super.toAccountId,
    super.categoryId,
    super.note,
  });

  factory TransactionModel.fromEntity(Transaction tx) {
    return TransactionModel(
      id: tx.id,
      type: tx.type,
      amount: tx.amount,
      accountId: tx.accountId,
      toAccountId: tx.toAccountId,
      categoryId: tx.categoryId,
      note: tx.note,
      date: tx.date,
      createdAt: tx.createdAt,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      accountId: json['accountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      categoryId: json['categoryId'] as String?,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'categoryId': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
DARTEOF

# ============================================================
# DATA: Datasources (shared_preferences, pola sama dengan Accounts)
# ============================================================
cat > lib/data/datasources/category_local_datasource.dart << 'DARTEOF'
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  static const _key = 'moneymate_categories';

  static const _defaultColor = 0xFF6750A4;

  List<CategoryModel> _defaultCategories() {
    return [
      CategoryModel(id: 'cat_def_salary', name: 'Gaji', type: CategoryType.income, iconKey: CategoryIconKey.salary, colorValue: 0xFF2E7D32, isDefault: true),
      CategoryModel(id: 'cat_def_bonus', name: 'Bonus', type: CategoryType.income, iconKey: CategoryIconKey.bonus, colorValue: 0xFF43A047, isDefault: true),
      CategoryModel(id: 'cat_def_gift_in', name: 'Hadiah', type: CategoryType.income, iconKey: CategoryIconKey.gift, colorValue: 0xFF66BB6A, isDefault: true),
      CategoryModel(id: 'cat_def_other_in', name: 'Lainnya', type: CategoryType.income, iconKey: CategoryIconKey.other, colorValue: 0xFF81C784, isDefault: true),
      CategoryModel(id: 'cat_def_food', name: 'Makan', type: CategoryType.expense, iconKey: CategoryIconKey.food, colorValue: 0xFFE65100, isDefault: true),
      CategoryModel(id: 'cat_def_transport', name: 'Transport', type: CategoryType.expense, iconKey: CategoryIconKey.transport, colorValue: 0xFF6D4C41, isDefault: true),
      CategoryModel(id: 'cat_def_shopping', name: 'Belanja', type: CategoryType.expense, iconKey: CategoryIconKey.shopping, colorValue: 0xFFAD1457, isDefault: true),
      CategoryModel(id: 'cat_def_bill', name: 'Tagihan', type: CategoryType.expense, iconKey: CategoryIconKey.bill, colorValue: 0xFF455A64, isDefault: true),
      CategoryModel(id: 'cat_def_entertainment', name: 'Hiburan', type: CategoryType.expense, iconKey: CategoryIconKey.entertainment, colorValue: 0xFF6A1B9A, isDefault: true),
      CategoryModel(id: 'cat_def_health', name: 'Kesehatan', type: CategoryType.expense, iconKey: CategoryIconKey.health, colorValue: 0xFFC62828, isDefault: true),
      CategoryModel(id: 'cat_def_education', name: 'Pendidikan', type: CategoryType.expense, iconKey: CategoryIconKey.education, colorValue: 0xFF1565C0, isDefault: true),
      CategoryModel(id: 'cat_def_other_ex', name: 'Lainnya', type: CategoryType.expense, iconKey: CategoryIconKey.other, colorValue: _defaultColor, isDefault: true),
    ];
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      final defaults = _defaultCategories();
      await _saveAll(defaults);
      return defaults;
    }
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveAll(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<void> addCategory(Category category) async {
    final all = await getAllCategories();
    all.add(CategoryModel.fromEntity(category));
    await _saveAll(all);
  }

  Future<void> updateCategory(Category category) async {
    final all = await getAllCategories();
    final idx = all.indexWhere((c) => c.id == category.id);
    if (idx != -1) all[idx] = CategoryModel.fromEntity(category);
    await _saveAll(all);
  }

  Future<void> deleteCategory(String id) async {
    final all = await getAllCategories();
    all.removeWhere((c) => c.id == id);
    await _saveAll(all);
  }
}
DARTEOF

cat > lib/data/datasources/transaction_local_datasource.dart << 'DARTEOF'
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/transaction.dart';
import '../models/transaction_model.dart';

class TransactionLocalDataSource {
  static const _key = 'moneymate_transactions';

  Future<List<TransactionModel>> getAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveAll(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<void> addTransaction(Transaction transaction) async {
    final all = await getAllTransactions();
    all.add(TransactionModel.fromEntity(transaction));
    await _saveAll(all);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final all = await getAllTransactions();
    final idx = all.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) all[idx] = TransactionModel.fromEntity(transaction);
    await _saveAll(all);
  }

  Future<void> deleteTransaction(String id) async {
    final all = await getAllTransactions();
    all.removeWhere((t) => t.id == id);
    await _saveAll(all);
  }
}
DARTEOF

# ============================================================
# DATA: Repository implementations
# ============================================================
cat > lib/data/repositories/category_repository_impl.dart << 'DARTEOF'
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource);

  final CategoryLocalDataSource _dataSource;

  @override
  Future<List<Category>> getAllCategories() => _dataSource.getAllCategories();

  @override
  Future<void> addCategory(Category category) => _dataSource.addCategory(category);

  @override
  Future<void> updateCategory(Category category) => _dataSource.updateCategory(category);

  @override
  Future<void> deleteCategory(String id) => _dataSource.deleteCategory(id);
}
DARTEOF

cat > lib/data/repositories/transaction_repository_impl.dart << 'DARTEOF'
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dataSource);

  final TransactionLocalDataSource _dataSource;

  @override
  Future<List<Transaction>> getAllTransactions() => _dataSource.getAllTransactions();

  @override
  Future<void> addTransaction(Transaction transaction) => _dataSource.addTransaction(transaction);

  @override
  Future<void> updateTransaction(Transaction transaction) => _dataSource.updateTransaction(transaction);

  @override
  Future<void> deleteTransaction(String id) => _dataSource.deleteTransaction(id);
}
DARTEOF

# ============================================================
# PRESENTATION: Providers
# ============================================================
cat > lib/presentation/providers/categories_provider.dart << 'DARTEOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  return CategoryLocalDataSource();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  CategoriesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  final CategoryRepository _repository;
  final _uuid = const Uuid();

  Future<void> _loadCategories() async {
    try {
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addCategory({
    required String name,
    required CategoryType type,
    required CategoryIconKey iconKey,
    required int colorValue,
  }) async {
    final newCategory = Category(
      id: _uuid.v4(),
      name: name,
      type: type,
      iconKey: iconKey,
      colorValue: colorValue,
    );
    await _repository.addCategory(newCategory);
    await _loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    await _loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await _loadCategories();
  }

  Future<void> refresh() => _loadCategories();
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoriesNotifier(repository);
});

final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoriesProvider);
  return state.when(
    data: (categories) => categories.where((c) => c.type == CategoryType.income).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoriesProvider);
  return state.when(
    data: (categories) => categories.where((c) => c.type == CategoryType.expense).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
DARTEOF

cat > lib/presentation/providers/transactions_provider.dart << 'DARTEOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'accounts_provider.dart';

final transactionLocalDataSourceProvider = Provider<TransactionLocalDataSource>((ref) {
  return TransactionLocalDataSource();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dataSource = ref.watch(transactionLocalDataSourceProvider);
  return TransactionRepositoryImpl(dataSource);
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionsNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    _loadTransactions();
  }

  final TransactionRepository _repository;
  final Ref _ref;
  final _uuid = const Uuid();

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _repository.getAllTransactions();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Account? _findAccount(List<Account> accounts, String id) {
    for (final acc in accounts) {
      if (acc.id == id) return acc;
    }
    return null;
  }

  Future<void> _applyTransactionEffect(Transaction tx, {bool reverse = false}) async {
    final sign = reverse ? -1 : 1;
    final accountsNotifier = _ref.read(accountsProvider.notifier);
    final accounts = _ref.read(accountsProvider).value ?? <Account>[];

    switch (tx.type) {
      case TransactionType.income:
        final acc = _findAccount(accounts, tx.accountId);
        if (acc != null) {
          await accountsNotifier.updateAccount(
            acc.copyWith(balance: acc.balance + (tx.amount * sign)),
          );
        }
        break;
      case TransactionType.expense:
        final acc = _findAccount(accounts, tx.accountId);
        if (acc != null) {
          await accountsNotifier.updateAccount(
            acc.copyWith(balance: acc.balance - (tx.amount * sign)),
          );
        }
        break;
      case TransactionType.transfer:
        final fromAcc = _findAccount(accounts, tx.accountId);
        if (fromAcc != null) {
          await accountsNotifier.updateAccount(
            fromAcc.copyWith(balance: fromAcc.balance - (tx.amount * sign)),
          );
        }
        if (tx.toAccountId != null) {
          final toAcc = _findAccount(accounts, tx.toAccountId!);
          if (toAcc != null) {
            await accountsNotifier.updateAccount(
              toAcc.copyWith(balance: toAcc.balance + (tx.amount * sign)),
            );
          }
        }
        break;
    }
  }

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String accountId,
    required DateTime date,
    String? toAccountId,
    String? categoryId,
    String? note,
  }) async {
    final newTx = Transaction(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      accountId: accountId,
      toAccountId: toAccountId,
      categoryId: categoryId,
      note: note,
      date: date,
      createdAt: DateTime.now(),
    );
    await _applyTransactionEffect(newTx);
    await _repository.addTransaction(newTx);
    await _loadTransactions();
  }

  Future<void> updateTransaction(Transaction oldTx, Transaction newTx) async {
    await _applyTransactionEffect(oldTx, reverse: true);
    await _applyTransactionEffect(newTx);
    await _repository.updateTransaction(newTx);
    await _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    final current = state.value ?? <Transaction>[];
    Transaction? target;
    for (final t in current) {
      if (t.id == id) {
        target = t;
        break;
      }
    }
    if (target != null) {
      await _applyTransactionEffect(target, reverse: true);
    }
    await _repository.deleteTransaction(id);
    await _loadTransactions();
  }

  Future<void> refresh() => _loadTransactions();
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionsNotifier(repository, ref);
});
DARTEOF

echo "✅ Semua file domain/data/provider berhasil dibuat."

mkdir -p lib/presentation/pages lib/presentation/widgets

# ============================================================
# WIDGET: transaction_tile.dart
# ============================================================
cat > lib/presentation/widgets/transaction_tile.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import '../../core/utils/transaction_formatters.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.fromAccount,
    required this.toAccount,
    required this.category,
    required this.onTap,
  });

  final Transaction transaction;
  final Account? fromAccount;
  final Account? toAccount;
  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;

    final Color amountColor = isIncome
        ? const Color(0xFF2E7D32)
        : isExpense
            ? const Color(0xFFC62828)
            : const Color(0xFF1565C0);

    final IconData icon = isTransfer
        ? Icons.swap_horiz_outlined
        : (category?.icon ?? Icons.category_outlined);

    final Color iconBg = isTransfer
        ? const Color(0xFF1565C0)
        : (category?.color ?? Colors.grey);

    String title;
    String subtitle;
    if (isTransfer) {
      title = 'Transfer';
      subtitle = '${fromAccount?.name ?? '-'} → ${toAccount?.name ?? '-'}';
    } else {
      title = category?.name ?? 'Tanpa Kategori';
      subtitle = fromAccount?.name ?? '-';
    }

    final amountPrefix = isIncome ? '+' : (isExpense ? '-' : '');

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: iconBg.withOpacity(0.15),
        child: Icon(icon, color: iconBg, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$amountPrefix${TransactionFormatters.currency(transaction.amount)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            TransactionFormatters.time(transaction.date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
DARTEOF

# ============================================================
# PAGE: transactions_page.dart
# ============================================================
cat > lib/presentation/pages/transactions_page.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/transaction_formatters.dart';
import '../../domain/entities/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/transactions_provider.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_page.dart';
import 'categories_page.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsProvider);
    final accountsState = ref.watch(accountsProvider);
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Kelola Kategori',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: transactionsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat transaksi: $error')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada transaksi.\nTekan tombol + untuk menambah transaksi pertama.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final accounts = accountsState.value ?? [];
          final categories = categoriesState.value ?? [];

          final Map<String, List<Transaction>> grouped = {};
          for (final tx in transactions) {
            final label = TransactionFormatters.dateGroupLabel(tx.date);
            grouped.putIfAbsent(label, () => []).add(tx);
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...entry.value.map((tx) {
                    final fromAcc = accounts.where((a) => a.id == tx.accountId).isNotEmpty
                        ? accounts.firstWhere((a) => a.id == tx.accountId)
                        : null;
                    final toAcc = tx.toAccountId != null && accounts.where((a) => a.id == tx.toAccountId).isNotEmpty
                        ? accounts.firstWhere((a) => a.id == tx.toAccountId)
                        : null;
                    final cat = tx.categoryId != null && categories.where((c) => c.id == tx.categoryId).isNotEmpty
                        ? categories.firstWhere((c) => c.id == tx.categoryId)
                        : null;

                    return TransactionTile(
                      transaction: tx,
                      fromAccount: fromAcc,
                      toAccount: toAcc,
                      category: cat,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionPage(editingTransaction: tx),
                          ),
                        );
                      },
                    );
                  }),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
DARTEOF

echo "✅ transaction_tile.dart dan transactions_page.dart berhasil dibuat."

cat > lib/presentation/pages/add_transaction_page.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/transaction_formatters.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/transactions_provider.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key, this.editingTransaction});

  final Transaction? editingTransaction;

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _accountId;
  String? _toAccountId;
  String? _categoryId;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.editingTransaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.editingTransaction;
    if (tx != null) {
      _type = tx.type;
      _accountId = tx.accountId;
      _toAccountId = tx.toAccountId;
      _categoryId = tx.categoryId;
      _date = tx.date;
      _amountController.text = tx.amount.round().toString();
      _noteController.text = tx.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final raw = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah harus diisi dan lebih dari 0')),
      );
      return;
    }
    if (_accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih akun terlebih dahulu')),
      );
      return;
    }
    if (_type == TransactionType.transfer) {
      if (_toAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih akun tujuan transfer')),
        );
        return;
      }
      if (_toAccountId == _accountId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun asal dan tujuan tidak boleh sama')),
        );
        return;
      }
    } else {
      if (_categoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
        );
        return;
      }
    }

    final notifier = ref.read(transactionsProvider.notifier);
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    if (_isEditing) {
      final oldTx = widget.editingTransaction!;
      final newTx = oldTx.copyWith(
        type: _type,
        amount: amount,
        accountId: _accountId,
        toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
        categoryId: _type == TransactionType.transfer ? null : _categoryId,
        note: note,
        clearToAccountId: _type != TransactionType.transfer,
        clearCategoryId: _type == TransactionType.transfer,
        clearNote: note == null,
        date: _date,
      );
      await notifier.updateTransaction(oldTx, newTx);
    } else {
      await notifier.addTransaction(
        type: _type,
        amount: amount,
        accountId: _accountId!,
        toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
        categoryId: _type == TransactionType.transfer ? null : _categoryId,
        note: note,
        date: _date,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini? Saldo akun akan disesuaikan kembali.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true && widget.editingTransaction != null) {
      await ref.read(transactionsProvider.notifier).deleteTransaction(widget.editingTransaction!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(accountsProvider);
    final accounts = accountsState.value ?? <Account>[];
    final categories = _type == TransactionType.income
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    if (_accountId != null && !accounts.any((a) => a.id == _accountId)) {
      _accountId = null;
    }
    if (_toAccountId != null && !accounts.any((a) => a.id == _toAccountId)) {
      _toAccountId = null;
    }
    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaksi' : 'Tambah Transaksi'),
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
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.income, label: Text('Masuk')),
                ButtonSegment(value: TransactionType.expense, label: Text('Keluar')),
                ButtonSegment(value: TransactionType.transfer, label: Text('Transfer')),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() {
                  _type = selection.first;
                  _categoryId = null;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _accountId,
              decoration: InputDecoration(
                labelText: _type == TransactionType.transfer ? 'Dari Akun' : 'Akun',
                border: const OutlineInputBorder(),
              ),
              items: accounts
                  .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                  .toList(),
              onChanged: (value) => setState(() => _accountId = value),
            ),
            if (_type == TransactionType.transfer) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _toAccountId,
                decoration: const InputDecoration(
                  labelText: 'Ke Akun',
                  border: OutlineInputBorder(),
                ),
                items: accounts
                    .where((a) => a.id != _accountId)
                    .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (value) => setState(() => _toAccountId = value),
              ),
            ],
            if (_type != TransactionType.transfer) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: categories
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal'),
              subtitle: Text(TransactionFormatters.dateGroupLabel(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Transaksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
DARTEOF

echo "✅ add_transaction_page.dart berhasil dibuat."

cat > lib/presentation/pages/categories_page.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/categories_provider.dart';
import 'add_category_page.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus kategori "${category.name}"? Transaksi lama dengan kategori ini akan tetap ada tapi tidak terhubung ke kategori manapun.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
    }
  }

  Widget _buildList(List<Category> categories, CategoryType type) {
    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Belum ada kategori ${type.label.toLowerCase()}.'),
        ),
      );
    }
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: category.color.withOpacity(0.15),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          title: Text(category.name),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddCategoryPage(editingCategory: category)),
                );
              } else if (value == 'delete') {
                _confirmDelete(category);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomeCategories = ref.watch(incomeCategoriesProvider);
    final expenseCategories = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type = _tabController.index == 0 ? CategoryType.income : CategoryType.expense;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddCategoryPage(initialType: type)),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(incomeCategories, CategoryType.income),
          _buildList(expenseCategories, CategoryType.expense),
        ],
      ),
    );
  }
}
DARTEOF

echo "✅ categories_page.dart berhasil dibuat."

cat > lib/presentation/pages/add_category_page.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/categories_provider.dart';

const List<int> _kCategoryColors = [
  0xFF2E7D32, 0xFF43A047, 0xFF66BB6A,
  0xFFE65100, 0xFFEF6C00, 0xFFFB8C00,
  0xFFC62828, 0xFFD32F2F, 0xFFE53935,
  0xFF1565C0, 0xFF1976D2, 0xFF1E88E5,
  0xFF6A1B9A, 0xFF8E24AA, 0xFFAB47BC,
  0xFF455A64, 0xFF546E7A, 0xFF6D4C41,
];

class AddCategoryPage extends ConsumerStatefulWidget {
  const AddCategoryPage({super.key, this.editingCategory, this.initialType});

  final Category? editingCategory;
  final CategoryType? initialType;

  @override
  ConsumerState<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late CategoryType _type;
  CategoryIconKey _iconKey = CategoryIconKey.other;
  int _colorValue = _kCategoryColors.first;

  bool get _isEditing => widget.editingCategory != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.editingCategory;
    if (cat != null) {
      _nameController.text = cat.name;
      _type = cat.type;
      _iconKey = cat.iconKey;
      _colorValue = cat.colorValue;
    } else {
      _type = widget.initialType ?? CategoryType.expense;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(categoriesProvider.notifier);
    if (_isEditing) {
      final updated = widget.editingCategory!.copyWith(
        name: _nameController.text.trim(),
        type: _type,
        iconKey: _iconKey,
        colorValue: _colorValue,
      );
      await notifier.updateCategory(updated);
    } else {
      await notifier.addCategory(
        name: _nameController.text.trim(),
        type: _type,
        iconKey: _iconKey,
        colorValue: _colorValue,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment(value: CategoryType.income, label: Text('Pemasukan')),
                ButtonSegment(value: CategoryType.expense, label: Text('Pengeluaran')),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama kategori tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('Pilih Ikon', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: CategoryIconKey.values.map((key) {
                final selected = key == _iconKey;
                return GestureDetector(
                  onTap: () => setState(() => _iconKey = key),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: selected ? Color(_colorValue) : Colors.grey.shade200,
                    child: Icon(
                      key.icon,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Pilih Warna', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _kCategoryColors.map((colorInt) {
                final selected = colorInt == _colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = colorInt),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(colorInt),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Kategori'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
DARTEOF

echo "✅ add_category_page.dart berhasil dibuat."
