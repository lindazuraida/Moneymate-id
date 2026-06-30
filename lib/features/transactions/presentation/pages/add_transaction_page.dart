import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../accounts/domain/entities/account.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  TransactionCategory? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih akun terlebih dahulu')),
      );
      return;
    }

    if (_selectedType == TransactionType.transfer &&
        _selectedToAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih akun tujuan transfer')),
      );
      return;
    }

    if (_selectedType == TransactionType.transfer &&
        _selectedAccountId == _selectedToAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun asal dan tujuan tidak boleh sama')),
      );
      return;
    }

    final amount = double.tryParse(
          _amountController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah harus lebih dari 0')),
      );
      return;
    }

    await ref.read(transactionsProvider.notifier).addTransaction(
          type: _selectedType,
          amount: amount,
          accountId: _selectedAccountId!,
          toAccountId: _selectedType == TransactionType.transfer
              ? _selectedToAccountId
              : null,
          category: _selectedType == TransactionType.transfer
              ? null
              : _selectedCategory?.name,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsState = ref.watch(accountsProvider);
    final accounts = accountsState.value ?? <Account>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Jenis transaksi ───────────────────────────────
            Row(
              children: TransactionType.values.map((type) {
                final selected = type == _selectedType;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() {
                        _selectedType = type;
                        _selectedCategory = null;
                      }),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? type.color.withOpacity(0.12)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? type.color : theme.colorScheme.outline,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              type.icon,
                              color: selected
                                  ? type.color
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              type.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: selected
                                    ? type.color
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight:
                                    selected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Jumlah ────────────────────────────────────────
            Text('Jumlah', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.headlineSmall,
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Akun ──────────────────────────────────────────
            if (accounts.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Belum ada akun. Tambahkan akun terlebih dahulu di tab Akun sebelum mencatat transaksi.',
                  style: theme.textTheme.bodySmall,
                ),
              )
            else ...[
              Text(
                _selectedType == TransactionType.transfer
                    ? 'Dari Akun'
                    : 'Akun',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _AccountDropdown(
                accounts: accounts,
                value: _selectedAccountId,
                onChanged: (id) => setState(() => _selectedAccountId = id),
              ),

              if (_selectedType == TransactionType.transfer) ...[
                const SizedBox(height: 20),
                Text('Ke Akun', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _AccountDropdown(
                  accounts: accounts,
                  value: _selectedToAccountId,
                  onChanged: (id) => setState(() => _selectedToAccountId = id),
                ),
              ],
            ],
            const SizedBox(height: 20),

            // ── Kategori (hanya income/expense) ────────────────
            if (_selectedType != TransactionType.transfer) ...[
              Text('Kategori', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_selectedType == TransactionType.income
                        ? TransactionCategory.incomeCategories
                        : TransactionCategory.expenseCategories)
                    .map((cat) {
                  final selected = cat.name == _selectedCategory?.name;
                  return ChoiceChip(
                    label: Text(cat.name),
                    avatar: Icon(cat.icon, size: 16),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // ── Catatan ───────────────────────────────────────
            Text('Catatan (opsional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Tambahkan catatan...',
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: accounts.isEmpty ? null : _handleSave,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Simpan Transaksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDropdown extends StatelessWidget {
  const _AccountDropdown({
    required this.accounts,
    required this.value,
    required this.onChanged,
  });

  final List<Account> accounts;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(hintText: 'Pilih akun'),
      items: accounts.map((account) {
        return DropdownMenuItem(
          value: account.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(account.category.icon, size: 18, color: account.color),
              const SizedBox(width: 8),
              Text(account.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Wajib dipilih' : null,
    );
  }
}
