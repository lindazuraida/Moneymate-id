import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// A compact metric card used on the dashboard grid (Total Assets,
/// Total Debt, Monthly Income, etc).
///
/// Kept visually quiet (icon + label + value) so the grid of 6-8 cards
/// doesn't compete for attention — the hero balance card above carries
/// the primary visual weight.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.trend,
    this.isPositiveTrend = true,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? trend;
  final bool isPositiveTrend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: theme.textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.moneyMedium(theme.colorScheme.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositiveTrend
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 12,
                  color: isPositiveTrend
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 2),
                Text(
                  trend!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPositiveTrend
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

