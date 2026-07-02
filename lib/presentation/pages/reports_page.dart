import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/transaction_formatters.dart';
import '../providers/reports_provider.dart';
import '../widgets/balance_line_chart.dart';
import '../widgets/expense_donut_chart.dart';
import '../widgets/income_expense_bar_chart.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final filter = ref.read(reportsFilterProvider);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: filter.start, end: filter.end),
      helpText: 'Pilih rentang laporan',
      saveText: 'Terapkan',
    );
    if (range != null) {
      ref.read(reportsFilterProvider.notifier).setRange(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportsFilterProvider);
    final summary = ref.watch(reportsSummaryProvider);
    final expenseData = ref.watch(categoryExpenseDataProvider);
    final monthlyData = ref.watch(monthlyFinanceDataProvider);
    final balancePoints = ref.watch(balanceTrendProvider);

    final net = summary.income - summary.expense;
    final netColor = net >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.date_range_outlined),
            label: Text(
              '${_fmtDate(filter.start)} - ${_fmtDate(filter.end)}',
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: () => _pickRange(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _SummaryCard(
                  label: 'Pemasukan',
                  amount: summary.income,
                  color: const Color(0xFF2E7D32),
                  icon: Icons.arrow_downward_outlined,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Pengeluaran',
                  amount: summary.expense,
                  color: const Color(0xFFC62828),
                  icon: Icons.arrow_upward_outlined,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Selisih',
                  amount: net,
                  color: netColor,
                  icon: net >= 0 ? Icons.trending_up_outlined : Icons.trending_down_outlined,
                ),
              ],
            ),
          ),
          _SectionCard(
            title: 'Pengeluaran per Kategori',
            child: ExpenseDonutChart(data: expenseData),
          ),
          _SectionCard(
            title: 'Income vs Pengeluaran Bulanan',
            child: IncomeExpenseBarChart(data: monthlyData),
          ),
          _SectionCard(
            title: 'Tren Saldo Total',
            child: BalanceLineChart(points: balancePoints),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              FittedBox(
                child: Text(
                  TransactionFormatters.currency(amount.abs()),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
