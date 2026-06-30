import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../models/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._localDataSource);

  final AccountLocalDataSource _localDataSource;

  @override
  Future<List<Account>> getAllAccounts() {
    return _localDataSource.getAllAccounts();
  }

  @override
  Future<void> addAccount(Account account) {
    return _localDataSource.addAccount(AccountModel.fromEntity(account));
  }

  @override
  Future<void> updateAccount(Account account) {
    return _localDataSource.updateAccount(AccountModel.fromEntity(account));
  }

  @override
  Future<void> deleteAccount(String id) {
    return _localDataSource.deleteAccount(id);
  }
}
