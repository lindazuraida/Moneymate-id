import '../domain/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.category,
    required super.limitAmount,
    required super.period,
    required super.colorValue,
  });

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      category: budget.category,
      limitAmount: budget.limitAmount,
      period: budget.period,
      colorValue: budget.colorValue,
    );
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      category: json['category'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (p) => p.name == json['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      colorValue: json['colorValue'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'limitAmount': limitAmount,
      'period': period.name,
      'colorValue': colorValue,
    };
  }
}
