import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/utils/reports_helper.dart';
import '../../core/utils/transaction_formatters.dart';

class ExpenseDonutChart extends StatelessWidget {
  const ExpenseDonutChart({super.key, required this.data});

  final List<CategoryExpenseData> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('Tidak ada pengeluaran di periode ini.')),
      );
    }

    final total = data.fold<double>(0, (sum, d) => sum + d.amount);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: data.map((d) {
                final pct = total > 0 ? d.amount / total * 100 : 0.0;
                return PieChartSectionData(
                  value: d.amount,
                  color: d.color,
                  title: pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 45,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: data.take(8).map((d) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 6, backgroundColor: d.color),
                  const SizedBox(width: 4),
                  Text(
                    '${d.name}  ${TransactionFormatters.currency(d.amount)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
