import 'package:flutter/material.dart';

/// Jenis transaksi yang didukung.
enum TransactionType {
  income,
  expense,
  transfer;

  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.income:
        return const Color(0xFF22C55E); // hijau
      case TransactionType.expense:
        return const Color(0xFFEF4444); // merah
      case TransactionType.transfer:
        return const Color(0xFF3B82F6); // biru
    }
  }
}

/// Kategori transaksi siap pakai. Income dan Expense punya daftar kategori
/// berbeda karena sifatnya berbeda — kategori expense jauh lebih banyak
/// karena variasi pengeluaran sehari-hari lebih luas.
class TransactionCategory {
  const TransactionCategory(this.name, this.icon);

  final String name;
  final IconData icon;

  static const List<TransactionCategory> incomeCategories = [
    TransactionCategory('Gaji', Icons.work_outline),
    TransactionCategory('Bonus', Icons.card_giftcard_outlined),
    TransactionCategory('Hadiah', Icons.redeem_outlined),
    TransactionCategory('Investasi', Icons.trending_up),
    TransactionCategory('Penjualan', Icons.sell_outlined),
    TransactionCategory('Lainnya', Icons.more_horiz),
  ];

  static const List<TransactionCategory> expenseCategories = [
    TransactionCategory('Makanan', Icons.restaurant_outlined),
    TransactionCategory('Transport', Icons.directions_car_outlined),
    TransactionCategory('Belanja', Icons.shopping_bag_outlined),
    TransactionCategory('Tagihan', Icons.receipt_long_outlined),
    TransactionCategory('Hiburan', Icons.movie_outlined),
    TransactionCategory('Kesehatan', Icons.local_hospital_outlined),
    TransactionCategory('Pendidikan', Icons.school_outlined),
    TransactionCategory('Rumah Tangga', Icons.home_outlined),
    TransactionCategory('Lainnya', Icons.more_horiz),
  ];

  static TransactionCategory? findByName(String? name, TransactionType type) {
    if (name == null) return null;
    final list = type == TransactionType.income
        ? incomeCategories
        : expenseCategories;
    try {
      return list.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }
}

/// Entity inti yang merepresentasikan satu transaksi keuangan.
///
/// Untuk transfer: [accountId] adalah akun sumber, [toAccountId] adalah
/// akun tujuan. Untuk income/expense, [toAccountId] selalu null.
@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.date,
    this.toAccountId,
    this.category,
    this.notes,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String accountId;
  final String? toAccountId;
  final DateTime date;
  final String? category;
  final String? notes;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? accountId,
    String? toAccountId,
    DateTime? date,
    String? category,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}
