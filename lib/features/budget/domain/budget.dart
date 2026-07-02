import 'package:flutter/material.dart';

/// Periode budget yang didukung.
enum BudgetPeriod {
  daily,
  weekly,
  monthly;

  String get label {
    switch (this) {
      case BudgetPeriod.daily:
        return 'Harian';
      case BudgetPeriod.weekly:
        return 'Mingguan';
      case BudgetPeriod.monthly:
        return 'Bulanan';
    }
  }

  IconData get icon {
    switch (this) {
      case BudgetPeriod.daily:
        return Icons.today_outlined;
      case BudgetPeriod.weekly:
        return Icons.date_range_outlined;
      case BudgetPeriod.monthly:
        return Icons.calendar_month_outlined;
    }
  }

  /// Rentang tanggal aktif untuk periode ini, dihitung dari [now].
  DateTimeRange activeRange(DateTime now) {
    switch (this) {
      case BudgetPeriod.daily:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 1)),
        );
      case BudgetPeriod.weekly:
        // Minggu dimulai Senin (weekday == 1)
        final daysFromMonday = (now.weekday - 1) % 7;
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: daysFromMonday));
        return DateTimeRange(
          start: monday,
          end: monday.add(const Duration(days: 7)),
        );
      case BudgetPeriod.monthly:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);
    }
  }
}

/// Satu item budget — batas pengeluaran untuk satu kategori dalam
/// satu periode tertentu.
@immutable
class Budget {
  const Budget({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.period,
    required this.colorValue,
  });

  final String id;
  final String category;   // nama kategori, misal "Makanan"
  final double limitAmount;
  final BudgetPeriod period;
  final int colorValue;

  Color get color => Color(colorValue);

  Budget copyWith({
    String? id,
    String? category,
    double? limitAmount,
    BudgetPeriod? period,
    int? colorValue,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

/// View model gabungan antara [Budget] dan progres pengeluaran aktual —
/// dipakai langsung oleh UI, tidak perlu logika tambahan di widget.
@immutable
class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.spent,
  });

  final Budget budget;
  final double spent;

  double get remaining => (budget.limitAmount - spent).clamp(0, double.infinity);
  double get ratio => budget.limitAmount > 0
      ? (spent / budget.limitAmount).clamp(0.0, 1.0)
      : 0.0;

  bool get isOverBudget => spent > budget.limitAmount;
  bool get isWarning => ratio >= 0.8 && !isOverBudget;
}
