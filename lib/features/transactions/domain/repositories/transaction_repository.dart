import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<void> addTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}
