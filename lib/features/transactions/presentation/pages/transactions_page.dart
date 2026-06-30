import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transactions_provider.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_page.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsProvider);
    final accountsState = ref.watch(accountsProvider);
    final theme = Theme.of(context);

    final accounts = accountsState.value ?? <Account>[];
    Account? findAccount(String id) {
      try {
        return accounts.firstWhere((a) => a.id == id);
      } catch (_) {
        return null;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: transactionsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat transaksi.\n$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return _EmptyState(
              onAddPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionPage(),
                  ),
                );
              },
            );
          }

          // Kelompokkan transaksi per tanggal supaya daftar lebih mudah
          // dipindai — header tanggal muncul setiap kali tanggalnya
          // berganti dari item sebelumnya.
          return RefreshIndicator(
            onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final showDateHeader = index == 0 ||
                    !_isSameDay(
                      transactions[index - 1].date,
                      transaction.date,
                    );

                final account = findAccount(transaction.accountId);
                final toAccount = transaction.toAccountId != null
                    ? findAccount(transaction.toAccountId!)
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDateHeader) ...[
                      if (index != 0) const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, top: 4),
                        child: Text(
                          _formatDateHeader(transaction.date),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    TransactionCard(
                      transaction: transaction,
                      account: account,
                      toAccount: toAccount,
                      onTap: () => _showDeleteConfirmation(
                        context,
                        ref,
                        transaction,
                      ),
                    ),
                    if (index < transactions.length - 1)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Hari Ini';
    if (target == yesterday) return 'Kemarin';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text(
          'Transaksi akan dihapus dan saldo akun akan disesuaikan kembali. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(transactionsProvider.notifier)
                  .deleteTransaction(transaction);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Belum ada transaksi', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Catat pemasukan, pengeluaran, atau\ntransfer untuk mulai melacak keuangan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
