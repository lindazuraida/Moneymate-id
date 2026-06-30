import 'package:flutter/material.dart';

/// Jenis kategori akun keuangan yang didukung.
///
/// Hanya Bank, Cash, dan E-Wallet di rilis pertama ini — Investment,
/// Crypto, dan Gold akan ditambahkan setelah modul ini stabil.
enum AccountCategory {
  bank,
  cash,
  eWallet;

  String get label {
    switch (this) {
      case AccountCategory.bank:
        return 'Bank';
      case AccountCategory.cash:
        return 'Tunai';
      case AccountCategory.eWallet:
        return 'E-Wallet';
    }
  }

  IconData get icon {
    switch (this) {
      case AccountCategory.bank:
        return Icons.account_balance_outlined;
      case AccountCategory.cash:
        return Icons.payments_outlined;
      case AccountCategory.eWallet:
        return Icons.smartphone_outlined;
    }
  }
}

/// Entity inti yang merepresentasikan satu akun/rekening keuangan milik
/// pengguna — entri murni domain, tidak tahu apapun soal bagaimana ia
/// disimpan (itu tanggung jawab layer data).
@immutable
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.category,
    required this.balance,
    required this.colorValue,
    this.institution,
    this.notes,
    this.currency = 'IDR',
  });

  final String id;
  final String name;
  final AccountCategory category;
  final double balance;
  final int colorValue; // disimpan sebagai int (Color.value) untuk persistensi
  final String? institution; // contoh: "BCA", "GoPay"
  final String? notes;
  final String currency;

  Color get color => Color(colorValue);

  Account copyWith({
    String? id,
    String? name,
    AccountCategory? category,
    double? balance,
    int? colorValue,
    String? institution,
    String? notes,
    String? currency,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      balance: balance ?? this.balance,
      colorValue: colorValue ?? this.colorValue,
      institution: institution ?? this.institution,
      notes: notes ?? this.notes,
      currency: currency ?? this.currency,
    );
  }
}
