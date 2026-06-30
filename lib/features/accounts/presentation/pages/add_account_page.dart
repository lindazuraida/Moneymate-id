import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../providers/accounts_provider.dart';

/// Halaman tambah akun baru, atau edit akun yang sudah ada kalau
/// [existingAccount] diisi.
class AddAccountPage extends ConsumerStatefulWidget {
  const AddAccountPage({super.key, this.existingAccount});

  final Account? existingAccount;

  @override
  ConsumerState<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends ConsumerState<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _institutionController;
  late final TextEditingController _notesController;

  AccountCategory _selectedCategory = AccountCategory.bank;
  Color _selectedColor = const Color(0xFF5B5FEF);

  static const _colorOptions = [
    Color(0xFF5B5FEF),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
    Color(0xFF22C55E),
  ];

  bool get _isEditing => widget.existingAccount != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAccount;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _balanceController = TextEditingController(
      text: existing != null ? existing.balance.toStringAsFixed(0) : '',
    );
    _institutionController =
        TextEditingController(text: existing?.institution ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    if (existing != null) {
      _selectedCategory = existing.category;
      _selectedColor = existing.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _institutionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final balance = double.tryParse(
          _balanceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;

    final notifier = ref.read(accountsProvider.notifier);

    if (_isEditing) {
      final updated = widget.existingAccount!.copyWith(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        balance: balance,
        colorValue: _selectedColor.value,
        institution: _institutionController.text.trim().isEmpty
            ? null
            : _institutionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await notifier.updateAccount(updated);
    } else {
      await notifier.addAccount(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        balance: balance,
        colorValue: _selectedColor.value,
        institution: _institutionController.text.trim().isEmpty
            ? null
            : _institutionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Akun' : 'Tambah Akun'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Pilihan kategori ──────────────────────────────
            Text('Kategori', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: AccountCategory.values.map((category) {
                final selected = category == _selectedCategory;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCategory = category),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.colorScheme.primary.withOpacity(0.12)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              category.icon,
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
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

            // ── Nama akun ─────────────────────────────────────
            Text('Nama Akun', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Contoh: BCA Tabungan, Dompet Harian',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama akun wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Saldo ─────────────────────────────────────────
            Text('Saldo Awal', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Saldo wajib diisi (boleh 0)';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Institusi ─────────────────────────────────────
            Text(
              'Institusi (opsional)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _institutionController,
              decoration: InputDecoration(
                hintText: _selectedCategory == AccountCategory.bank
                    ? 'Contoh: BCA, Mandiri, BRI'
                    : _selectedCategory == AccountCategory.eWallet
                        ? 'Contoh: GoPay, OVO, DANA'
                        : 'Opsional',
              ),
            ),
            const SizedBox(height: 20),

            // ── Warna ─────────────────────────────────────────
            Text('Warna', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions.map((color) {
                final selected = color.value == _selectedColor.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 2,
                            )
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Catatan ───────────────────────────────────────
            Text('Catatan (opsional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tambahkan catatan tentang akun ini...',
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _handleSave,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Akun'),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(accountsProvider.notifier)
                      .deleteAccount(widget.existingAccount!.id);
                  if (mounted) Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Hapus Akun'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
