import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.accountId,
    required super.date,
    super.toAccountId,
    super.category,
    super.notes,
  });

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      accountId: transaction.accountId,
      toAccountId: transaction.toAccountId,
      date: transaction.date,
      category: transaction.category,
      notes: transaction.notes,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      accountId: json['accountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'date': date.toIso8601String(),
      'category': category,
      'notes': notes,
    };
  }
}
