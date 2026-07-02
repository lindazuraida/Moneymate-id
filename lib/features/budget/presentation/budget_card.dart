import 'package:flutter/material.dart';
import '../domain/budget.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.progress,
    required this.onTap,
    required this.onLongPress,
  });

  final BudgetProgress progress;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String _fmt(double value) {
    final formatted = value.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  Color _barColor(BuildContext context) {
    if (progress.isOverBudget) return const Color(0xFFEF4444);
    if (progress.isWarning) return const Color(0xFFF59E0B);
    return progress.budget.color;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = _barColor(context);
    final pct = (progress.ratio * 100).toStringAsFixed(0);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: progress.isOverBudget
                  ? const Color(0xFFEF4444).withOpacity(0.5)
                  : theme.colorScheme.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: kategori + persentase
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: progress.budget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      color: progress.budget.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.budget.category,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          progress.budget.period.label,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Badge peringatan
                  if (progress.isOverBudget)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Melebihi!',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (progress.isWarning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$pct%',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      '$pct%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress.ratio,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),

              const SizedBox(height: 12),

              // Angka: terpakai / limit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Terpakai', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 2),
                      Text(
                        _fmt(progress.spent),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: progress.isOverBudget
                              ? const Color(0xFFEF4444)
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Sisa', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 2),
                      Text(
                        progress.isOverBudget
                            ? '-${_fmt(progress.spent - progress.budget.limitAmount)}'
                            : _fmt(progress.remaining),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: progress.isOverBudget
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF22C55E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Limit: ${_fmt(progress.budget.limitAmount)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
