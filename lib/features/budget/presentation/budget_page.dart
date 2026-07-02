import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/budget.dart';
import 'budget_provider.dart';
import 'budget_card.dart';
import 'add_budget_page.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default tab = Bulanan (index 2) karena paling umum dipakai
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        bottom: TabBar(
          controller: _tabController,
          tabs: BudgetPeriod.values
              .map((p) => Tab(icon: Icon(p.icon), text: p.label))
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddBudgetPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: BudgetPeriod.values
            .map((period) => _BudgetTabView(period: period))
            .toList(),
      ),
    );
  }
}

class _BudgetTabView extends ConsumerWidget {
  const _BudgetTabView({required this.period});

  final BudgetPeriod period;

  String _fmt(double value) {
    final formatted = value.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList = ref.watch(budgetProgressByPeriodProvider(period));
    final theme = Theme.of(context);

    if (progressList.isEmpty) {
      return _EmptyState(
        period: period,
        onAddPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddBudgetPage()),
        ),
      );
    }

    // Ringkasan total untuk periode ini
    final totalLimit = progressList.fold<double>(
        0, (s, p) => s + p.budget.limitAmount);
    final totalSpent = progressList.fold<double>(0, (s, p) => s + p.spent);
    final totalRatio =
        totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final overCount = progressList.where((p) => p.isOverBudget).length;
    final warnCount =
        progressList.where((p) => p.isWarning && !p.isOverBudget).length;

    return RefreshIndicator(
      onRefresh: () => ref.read(budgetsProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // ── Ringkasan periode ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan ${period.label}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fmt(totalSpent),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'dari ${_fmt(totalLimit)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: totalRatio,
                    minHeight: 10,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      overCount > 0
                          ? const Color(0xFFEF4444)
                          : warnCount > 0
                              ? const Color(0xFFF59E0B)
                              : theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (overCount > 0 || warnCount > 0) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (overCount > 0)
                        _StatusChip(
                          label: '$overCount kategori melebihi limit',
                          color: const Color(0xFFEF4444),
                        ),
                      if (warnCount > 0)
                        _StatusChip(
                          label: '$warnCount kategori mendekati limit',
                          color: const Color(0xFFF59E0B),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Daftar budget kartu ───────────────────────────
          ...progressList.map((progress) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BudgetCard(
                  progress: progress,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddBudgetPage(existing: progress.budget),
                    ),
                  ),
                  onLongPress: () => _confirmDelete(
                      context, ref, progress.budget),
                ),
              )),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Budget budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Budget?'),
        content: Text(
            'Budget "${budget.category}" (${budget.period.label}) akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ref.read(budgetsProvider.notifier).deleteBudget(budget.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Hapus',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.period, required this.onAddPressed});
  final BudgetPeriod period;
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
              child: Icon(period.icon,
                  size: 40, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text('Belum ada budget ${period.label.toLowerCase()}',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Buat budget per kategori untuk\nmulai memantau pengeluaranmu.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Buat Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
