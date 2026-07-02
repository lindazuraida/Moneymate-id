import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/utils/reports_helper.dart';

class BalanceLineChart extends StatelessWidget {
  const BalanceLineChart({super.key, required this.points});

  final List<BalancePoint> points;

  String _shortAmount(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Butuh minimal 2 poin data untuk menampilkan tren.\nCoba tambah lebih banyak transaksi atau perluas range tanggal.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final startDate = points.first.date;
    final totalDays = points.last.date.difference(startDate).inDays.toDouble();
    final spots = points
        .map((p) => FlSpot(p.date.difference(startDate).inDays.toDouble(), p.balance))
        .toList();

    final minY = points.fold<double>(points.first.balance, (m, p) => p.balance < m ? p.balance : m);
    final maxY = points.fold<double>(points.first.balance, (m, p) => p.balance > m ? p.balance : m);
    final yPad = ((maxY - minY) * 0.15).clamp(10000.0, double.infinity);
    final xInterval = (totalDays / 4).clamp(1.0, double.infinity).ceilToDouble();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY - yPad,
          maxY: maxY + yPad,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF1565C0),
              barWidth: 2.5,
              dotData: FlDotData(show: points.length <= 10),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF1565C0).withOpacity(0.08),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, meta) => Text(
                  _shortAmount(value),
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: xInterval,
                getTitlesWidget: (value, meta) {
                  final date = startDate.add(Duration(days: value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 9)),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false),
        ),
      ),
    );
  }
}
