import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/budget.dart';
import 'budget_provider.dart';
import '../../transactions/domain/entities/transaction.dart';

class AddBudgetPage extends ConsumerStatefulWidget {
  const AddBudgetPage({super.key, this.existing});
  final Budget? existing;

  @override
  ConsumerState<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends ConsumerState<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;

  BudgetPeriod _period = BudgetPeriod.monthly;
  String? _selectedCategory;
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

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _limitController = TextEditingController(
      text: e != null ? e.limitAmount.toStringAsFixed(0) : '',
    );
    if (e != null) {
      _period = e.period;
      _selectedCategory = e.category;
      _selectedColor = e.color;
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final limit = double.tryParse(
          _limitController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;

    if (limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limit harus lebih dari 0')),
      );
      return;
    }

    final notifier = ref.read(budgetsProvider.notifier);
    if (_isEditing) {
      await notifier.updateBudget(widget.existing!.copyWith(
        category: _selectedCategory,
        limitAmount: limit,
        period: _period,
        colorValue: _selectedColor.value,
      ));
    } else {
      await notifier.addBudget(
        category: _selectedCategory!,
        limitAmount: limit,
        period: _period,
        colorValue: _selectedColor.value,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Budget' : 'Buat Budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Kategori ──────────────────────────────────────
            Text('Kategori Pengeluaran', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TransactionCategory.expenseCategories.map((cat) {
                final selected = cat.name == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat.name),
                  avatar: Icon(cat.icon, size: 16),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Periode ───────────────────────────────────────
            Text('Periode', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: BudgetPeriod.values.map((p) {
                final selected = p == _period;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _period = p),
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
                              p.icon,
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.label,
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

            // ── Limit ─────────────────────────────────────────
            Text('Batas Pengeluaran', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.headlineSmall,
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),

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
                              color: theme.colorScheme.onSurface, width: 2.5)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Buat Budget'),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(budgetsProvider.notifier)
                      .deleteBudget(widget.existing!.id);
                  if (mounted) Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Hapus Budget'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
