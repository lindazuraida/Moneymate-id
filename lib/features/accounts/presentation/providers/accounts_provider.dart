import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/account_local_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

/// Instance datasource — satu untuk seluruh app (singleton via Riverpod).
final accountLocalDataSourceProvider = Provider<AccountLocalDataSource>((ref) {
  return AccountLocalDataSource();
});

/// Instance repository, dibangun dari datasource di atas.
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dataSource = ref.watch(accountLocalDataSourceProvider);
  return AccountRepositoryImpl(dataSource);
});

/// State notifier yang mengelola daftar akun dan mengekspos operasi
/// CRUD ke UI. Memuat data dari penyimpanan lokal saat pertama dibuat.
class AccountsNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  AccountsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadAccounts();
  }

  final AccountRepository _repository;
  final _uuid = const Uuid();

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _repository.getAllAccounts();
      state = AsyncValue.data(accounts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addAccount({
    required String name,
    required AccountCategory category,
    required double balance,
    required int colorValue,
    String? institution,
    String? notes,
    String currency = 'IDR',
  }) async {
    final newAccount = Account(
      id: _uuid.v4(),
      name: name,
      category: category,
      balance: balance,
      colorValue: colorValue,
      institution: institution,
      notes: notes,
      currency: currency,
    );

    await _repository.addAccount(newAccount);
    await _loadAccounts();
  }

  Future<void> updateAccount(Account account) async {
    await _repository.updateAccount(account);
    await _loadAccounts();
  }

  Future<void> deleteAccount(String id) async {
    await _repository.deleteAccount(id);
    await _loadAccounts();
  }

  Future<void> refresh() => _loadAccounts();
}

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, AsyncValue<List<Account>>>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return AccountsNotifier(repository);
});

/// Total saldo gabungan dari seluruh akun — dipakai dashboard nantinya
/// untuk mengganti data mock dengan data asli.
final totalBalanceProvider = Provider<double>((ref) {
  final accountsState = ref.watch(accountsProvider);
  return accountsState.when(
    data: (accounts) =>
        accounts.fold<double>(0, (sum, account) => sum + account.balance),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
