import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionLocalDataSource {
  static const _storageKey = 'transactions_data_v1';

  Future<List<TransactionModel>> getAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAllTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final current = await getAllTransactions();
    current.add(transaction);
    await saveAllTransactions(current);
  }

  Future<void> deleteTransaction(String id) async {
    final current = await getAllTransactions();
    current.removeWhere((t) => t.id == id);
    await saveAllTransactions(current);
  }
}
