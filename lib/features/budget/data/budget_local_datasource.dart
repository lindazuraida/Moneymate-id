import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'budget_model.dart';

class BudgetLocalDataSource {
  static const _storageKey = 'budgets_data_v1';

  Future<List<BudgetModel>> getAllBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => BudgetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<BudgetModel> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(budgets.map((b) => b.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addBudget(BudgetModel budget) async {
    final current = await getAllBudgets();
    current.add(budget);
    await _saveAll(current);
  }

  Future<void> updateBudget(BudgetModel updated) async {
    final current = await getAllBudgets();
    final index = current.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      current[index] = updated;
      await _saveAll(current);
    }
  }

  Future<void> deleteBudget(String id) async {
    final current = await getAllBudgets();
    current.removeWhere((b) => b.id == id);
    await _saveAll(current);
  }
}
