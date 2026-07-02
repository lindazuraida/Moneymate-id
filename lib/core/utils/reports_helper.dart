import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';

class CategoryExpenseData {
  const CategoryExpenseData({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.icon,
    required this.amount,
  });
  final String categoryId;
  final String name;
  final Color color;
  final IconData icon;
  final double amount;
}

class MonthlyFinanceData {
  const MonthlyFinanceData({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });
  final int year;
  final int month;
  final double income;
  final double expense;
  double get net => income - expense;
}

class BalancePoint {
  const BalancePoint({required this.date, required this.balance});
  final DateTime date;
  final double balance;
}

class ReportsFilter {
  const ReportsFilter({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  static ReportsFilter currentMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    return ReportsFilter(start: start, end: end);
  }

  ReportsFilter copyWith({DateTime? start, DateTime? end}) {
    return ReportsFilter(start: start ?? this.start, end: end ?? this.end);
  }
}

List<CategoryExpenseData> computeExpenseByCategory({
  required List<Transaction> transactions,
  required Map<String, CategoryExpenseData> categoryMeta,
}) {
  final Map<String, double> amounts = {};
  for (final tx in transactions) {
    if (tx.type != TransactionType.expense) continue;
    final key = tx.categoryId ?? '__uncategorized__';
    amounts[key] = (amounts[key] ?? 0) + tx.amount;
  }

  final result = amounts.entries.map((e) {
    if (e.key == '__uncategorized__') {
      return CategoryExpenseData(
        categoryId: '__uncategorized__',
        name: 'Lainnya',
        color: Colors.grey,
        icon: Icons.category_outlined,
        amount: e.value,
      );
    }
    final meta = categoryMeta[e.key];
    return CategoryExpenseData(
      categoryId: e.key,
      name: meta?.name ?? 'Kategori Dihapus',
      color: meta?.color ?? Colors.grey,
      icon: meta?.icon ?? Icons.category_outlined,
      amount: e.value,
    );
  }).toList();

  result.sort((a, b) => b.amount.compareTo(a.amount));
  return result;
}

List<MonthlyFinanceData> computeMonthlyData({
  required List<Transaction> allTransactions,
  required DateTime rangeStart,
  required DateTime rangeEnd,
}) {
  final Map<String, double> income = {};
  final Map<String, double> expense = {};

  var cur = DateTime(rangeStart.year, rangeStart.month);
  final endMonth = DateTime(rangeEnd.year, rangeEnd.month);
  while (!cur.isAfter(endMonth)) {
    final key = '${cur.year}-${cur.month.toString().padLeft(2, '0')}';
    income[key] = 0;
    expense[key] = 0;
    cur = DateTime(cur.year, cur.month + 1);
  }

  for (final tx in allTransactions) {
    if (tx.date.isBefore(rangeStart) || tx.date.isAfter(rangeEnd)) continue;
    final key = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
    if (!income.containsKey(key)) continue;
    if (tx.type == TransactionType.income) {
      income[key] = (income[key] ?? 0) + tx.amount;
    } else if (tx.type == TransactionType.expense) {
      expense[key] = (expense[key] ?? 0) + tx.amount;
    }
  }

  final keys = income.keys.toList()..sort();
  return keys.map((k) {
    final parts = k.split('-');
    return MonthlyFinanceData(
      year: int.parse(parts[0]),
      month: int.parse(parts[1]),
      income: income[k] ?? 0,
      expense: expense[k] ?? 0,
    );
  }).toList();
}

List<BalancePoint> computeBalanceTrend({
  required double currentTotalBalance,
  required List<Transaction> allTransactions,
  required DateTime rangeStart,
  required DateTime rangeEnd,
}) {
  final rsDay = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
  final reDay = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);

  double netFromStartToNow = 0;
  for (final tx in allTransactions) {
    final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
    if (!d.isBefore(rsDay)) {
      if (tx.type == TransactionType.income) netFromStartToNow += tx.amount;
      if (tx.type == TransactionType.expense) netFromStartToNow -= tx.amount;
    }
  }
  final balanceAtStart = currentTotalBalance - netFromStartToNow;

  final Map<String, double> dailyNet = {};
  for (final tx in allTransactions) {
    final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
    if (d.isBefore(rsDay) || d.isAfter(reDay)) continue;
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    double delta = 0;
    if (tx.type == TransactionType.income) delta = tx.amount;
    if (tx.type == TransactionType.expense) delta = -tx.amount;
    dailyNet[key] = (dailyNet[key] ?? 0) + delta;
  }

  final sortedKeys = dailyNet.keys.toList()..sort();
  final points = <BalancePoint>[BalancePoint(date: rsDay, balance: balanceAtStart)];
  double running = balanceAtStart;

  for (final key in sortedKeys) {
    running += dailyNet[key]!;
    final parts = key.split('-');
    final day = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    if (day != rsDay) points.add(BalancePoint(date: day, balance: running));
  }

  if (points.last.date != reDay) {
    points.add(BalancePoint(date: reDay, balance: running));
  }

  return points;
}
