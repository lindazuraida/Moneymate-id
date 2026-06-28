import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_routes.dart';

/// Persistent shell wrapping the five primary tabs.
///
/// Used as the `builder` for a [StatefulShellRoute] in GoRouter so each
/// tab keeps its own navigation stack while the bottom nav bar and FAB
/// stay mounted across tab switches (no jarring rebuild/animation reset).
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _NavDestination(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavDestination(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Accounts'),
    _NavDestination(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Transactions'),
    _NavDestination(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reports'),
    _NavDestination(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.transactionAdd),
        child: const Icon(Icons.add, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 64,
        child: Row(
          children: List.generate(destinations.length, (index) {
            // Leave a visual gap for the notched FAB in the middle slot.
            if (index == 2) {
              return const Expanded(child: SizedBox());
            }
            final d = destinations[index];
            final selected = index == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? d.activeIcon : d.icon,
                      size: 24,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
