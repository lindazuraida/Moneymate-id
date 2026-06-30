import '../../domain/entities/account.dart';

/// Representasi data dari [Account] yang tahu cara mengubah dirinya
/// menjadi/dari JSON, supaya bisa disimpan sebagai teks lewat
/// shared_preferences. Domain entity ([Account]) sendiri sengaja tidak
/// tahu apapun soal serialisasi — itu murni tanggung jawab layer ini.
class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.name,
    required super.category,
    required super.balance,
    required super.colorValue,
    super.institution,
    super.notes,
    super.currency,
  });

  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      id: account.id,
      name: account.name,
      category: account.category,
      balance: account.balance,
      colorValue: account.colorValue,
      institution: account.institution,
      notes: account.notes,
      currency: account.currency,
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: AccountCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => AccountCategory.cash,
      ),
      balance: (json['balance'] as num).toDouble(),
      colorValue: json['colorValue'] as int,
      institution: json['institution'] as String?,
      notes: json['notes'] as String?,
      currency: json['currency'] as String? ?? 'IDR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'balance': balance,
      'colorValue': colorValue,
      'institution': institution,
      'notes': notes,
      'currency': currency,
    };
  }
}
