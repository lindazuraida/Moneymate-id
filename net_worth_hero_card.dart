import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Hero card at the top of the dashboard — shows Net Worth as the
/// primary figure with Total Assets / Total Debt as a secondary split.
///
/// This is the single most important visual on the home screen, so it
/// gets the gradient treatment while every other card stays flat and
/// quiet to avoid competing with it.
class NetWorthHeroCard extends StatefulWidget {
  const NetWorthHeroCard({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.totalDebt,
    this.isBalanceVisible = true,
    this.onToggleVisibility,
  });

  final double netWorth;
  final double totalAssets;
  final double totalDebt;
  final bool isBalanceVisible;
  final VoidCallback? onToggleVisibility;

  @override
  State<NetWorthHeroCard> createState() => _NetWorthHeroCardState();
}

class _NetWorthHeroCardState extends State<NetWorthHeroCard> {
  String _formatCurrency(double value) {
    final formatted = value.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp ${value < 0 ? '-' : ''}$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors =
        isDark ? AppColors.heroGradientDark : AppColors.heroGradientLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Worth',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              GestureDetector(
                onTap: widget.onToggleVisibility,
                child: Icon(
                  widget.isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.85),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.isBalanceVisible
                ? _formatCurrency(widget.netWorth)
                : 'Rp •••••••',
            style: AppTypography.moneyDisplay(Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Total Assets',
                  value: widget.isBalanceVisible
                      ? _formatCurrency(widget.totalAssets)
                      : 'Rp •••••',
                  icon: Icons.trending_up,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withOpacity(0.15),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Total Debt',
                  value: widget.isBalanceVisible
                      ? _formatCurrency(widget.totalDebt)
                      : 'Rp •••••',
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white.withOpacity(0.85)),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.moneySmall(Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
