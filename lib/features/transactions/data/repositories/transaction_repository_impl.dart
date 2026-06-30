import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._localDataSource);

  final TransactionLocalDataSource _localDataSource;

  @override
  Future<List<Transaction>> getAllTransactions() {
    return _localDataSource.getAllTransactions();
  }

  @override
  Future<void> addTransaction(Transaction transaction) {
    return _localDataSource
        .addTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _localDataSource.deleteTransaction(id);
  }
}
