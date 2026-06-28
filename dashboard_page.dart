import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/net_worth_hero_card.dart';
import '../widgets/summary_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _formatCurrency(double value) {
    final formatted = value.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp ${value < 0 ? '-' : ''}$formatted';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);
    final isVisible = ref.watch(balanceVisibilityProvider);
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Greeting header ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${snapshot.userName} 👋',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            today,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.12),
                          child: Icon(
                            Icons.person_outline,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Hero net worth card ──────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: NetWorthHeroCard(
                  netWorth: snapshot.netWorth,
                  totalAssets: snapshot.totalAssets,
                  totalDebt: snapshot.totalDebt,
                  isBalanceVisible: isVisible,
                  onToggleVisibility: () => ref
                      .read(balanceVisibilityProvider.notifier)
                      .update((v) => !v),
                ),
              ),
            ),

            // ── Summary grid ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
                AppSpacing.screenHorizontal,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Text('Overview', style: theme.textTheme.titleMedium),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxl,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.45,
                ),
                delegate: SliverChildListDelegate([
                  SummaryCard(
                    label: 'Total Money',
                    value: isVisible
                        ? _formatCurrency(snapshot.totalMoney)
                        : 'Rp •••••',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFF5B5FEF),
                  ),
                  SummaryCard(
                    label: 'Monthly Income',
                    value: isVisible
                        ? _formatCurrency(snapshot.monthlyIncome)
                        : 'Rp •••••',
                    icon: Icons.arrow_downward_rounded,
                    iconColor: const Color(0xFF22C55E),
                    trend: '+12.4%',
                    isPositiveTrend: true,
                  ),
                  SummaryCard(
                    label: 'Monthly Expense',
                    value: isVisible
                        ? _formatCurrency(snapshot.monthlyExpense)
                        : 'Rp •••••',
                    icon: Icons.arrow_upward_rounded,
                    iconColor: const Color(0xFFEF4444),
                    trend: '-4.1%',
                    isPositiveTrend: false,
                  ),
                  SummaryCard(
                    label: 'Remaining Budget',
                    value: isVisible
                        ? _formatCurrency(snapshot.remainingBudget)
                        : 'Rp •••••',
                    icon: Icons.savings_outlined,
                    iconColor: const Color(0xFFF59E0B),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
