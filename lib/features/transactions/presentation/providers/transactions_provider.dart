import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../accounts/domain/entities/account.dart';

final transactionLocalDataSourceProvider =
    Provider<TransactionLocalDataSource>((ref) {
  return TransactionLocalDataSource();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dataSource = ref.watch(transactionLocalDataSourceProvider);
  return TransactionRepositoryImpl(dataSource);
});

/// State notifier yang mengelola daftar transaksi DAN menyesuaikan saldo
/// akun terkait setiap kali transaksi ditambah/dihapus.
///
/// Catatan desain penting: notifier ini bergantung pada [AccountsNotifier]
/// (lewat `ref.read(accountsProvider.notifier)`) untuk memperbarui saldo,
/// bukan menghitung ulang saldo dari nol setiap kali. Ini menjaga kedua
/// modul tetap loosely coupled — Transactions tahu tentang Accounts,
/// tapi Accounts tidak perlu tahu apapun tentang Transactions.
class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionsNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    _loadTransactions();
  }

  final TransactionRepository _repository;
  final Ref _ref;
  final _uuid = const Uuid();

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _repository.getAllTransactions();
      // Urutkan dari yang terbaru ke terlama supaya daftar transaksi
      // menampilkan aktivitas paling baru di atas.
      transactions.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Menambah transaksi baru dan menyesuaikan saldo akun terkait.
  ///
  /// - Income: saldo akun bertambah sebesar [amount]
  /// - Expense: saldo akun berkurang sebesar [amount]
  /// - Transfer: saldo akun sumber berkurang, saldo akun tujuan bertambah
  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String accountId,
    String? toAccountId,
    String? category,
    String? notes,
    DateTime? date,
  }) async {
    final newTransaction = Transaction(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      accountId: accountId,
      toAccountId: toAccountId,
      date: date ?? DateTime.now(),
      category: category,
      notes: notes,
    );

    await _repository.addTransaction(newTransaction);
    await _applyBalanceChange(newTransaction, reverse: false);
    await _loadTransactions();
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _repository.deleteTransaction(transaction.id);
    // Saat transaksi dihapus, efek saldonya harus dibatalkan (reverse)
    // supaya saldo akun kembali ke kondisi sebelum transaksi itu ada.
    await _applyBalanceChange(transaction, reverse: true);
    await _loadTransactions();
  }

  Future<void> _applyBalanceChange(
    Transaction transaction, {
    required bool reverse,
  }) async {
    final accountsNotifier = _ref.read(accountsProvider.notifier);
    final accountsState = _ref.read(accountsProvider);

    final accounts = accountsState.value;
    if (accounts == null) return;

    Account? findAccount(String id) {
      try {
        return accounts.firstWhere((a) => a.id == id);
      } catch (_) {
        return null;
      }
    }

    // sign = -1 kalau reverse (membatalkan efek), 1 kalau normal
    final sign = reverse ? -1 : 1;

    switch (transaction.type) {
      case TransactionType.income:
        final account = findAccount(transaction.accountId);
        if (account != null) {
          await accountsNotifier.updateAccount(
            account.copyWith(
              balance: account.balance + (transaction.amount * sign),
            ),
          );
        }
        break;

      case TransactionType.expense:
        final account = findAccount(transaction.accountId);
        if (account != null) {
          await accountsNotifier.updateAccount(
            account.copyWith(
              balance: account.balance - (transaction.amount * sign),
            ),
          );
        }
        break;

      case TransactionType.transfer:
        final fromAccount = findAccount(transaction.accountId);
        final toAccount = transaction.toAccountId != null
            ? findAccount(transaction.toAccountId!)
            : null;
        if (fromAccount != null) {
          await accountsNotifier.updateAccount(
            fromAccount.copyWith(
              balance: fromAccount.balance - (transaction.amount * sign),
            ),
          );
        }
        if (toAccount != null) {
          await accountsNotifier.updateAccount(
            toAccount.copyWith(
              balance: toAccount.balance + (transaction.amount * sign),
            ),
          );
        }
        break;
    }
  }

  Future<void> refresh() => _loadTransactions();
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>(
        (ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionsNotifier(repository, ref);
});

/// Total pemasukan & pengeluaran bulan berjalan — dipakai dashboard
/// untuk mengganti data mock Monthly Income/Expense dengan data asli.
final monthlyIncomeProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  final now = DateTime.now();
  return transactionsState.when(
    data: (transactions) => transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold<double>(0, (sum, t) => sum + t.amount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final monthlyExpenseProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  final now = DateTime.now();
  return transactionsState.when(
    data: (transactions) => transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold<double>(0, (sum, t) => sum + t.amount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
