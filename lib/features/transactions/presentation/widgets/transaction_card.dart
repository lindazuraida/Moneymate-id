import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';
import '../../../accounts/domain/entities/account.dart';

/// Kartu yang menampilkan satu transaksi di daftar.
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.account,
    this.toAccount,
    required this.onTap,
  });

  final Transaction transaction;
  final Account? account;
  final Account? toAccount;
  final VoidCallback onTap;

  String _formatCurrency(double value) {
    final formatted = value.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  String _subtitle() {
    switch (transaction.type) {
      case TransactionType.transfer:
        final fromName = account?.name ?? 'Akun?';
        final toName = toAccount?.name ?? 'Akun?';
        return '$fromName → $toName';
      case TransactionType.income:
      case TransactionType.expense:
        final parts = <String>[];
        if (transaction.category != null) parts.add(transaction.category!);
        if (account != null) parts.add(account!.name);
        return parts.isEmpty ? '-' : parts.join(' • ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final sign = transaction.type == TransactionType.income
        ? '+'
        : isExpense
            ? '-'
            : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: transaction.type.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(transaction.type.icon, color: transaction.type.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category ?? transaction.type.label,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(),
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${_formatCurrency(transaction.amount)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: transaction.type == TransactionType.income
                        ? const Color(0xFF22C55E)
                        : isExpense
                            ? const Color(0xFFEF4444)
                            : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM, HH:mm').format(transaction.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
