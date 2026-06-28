import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_shell.dart';
import '../widgets/coming_soon_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import 'app_routes.dart';

/// Root navigator key — exposed so non-widget code (e.g. notification
/// taps, deep links) can navigate without a BuildContext.
final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // ── Tab 0: Dashboard ─────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // ── Tab 1: Accounts ──────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.accounts,
                builder: (context, state) => const ComingSoonPage(
                  title: 'Money Accounts',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ComingSoonPage(
                      title: 'Add Account',
                      icon: Icons.add_circle_outline,
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ComingSoonPage(
                      title: 'Account ${state.pathParameters['id']}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 2: Transactions ──────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const ComingSoonPage(
                  title: 'Transactions',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),

          // ── Tab 3: Reports ───────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const ComingSoonPage(
                  title: 'Reports',
                  icon: Icons.bar_chart_outlined,
                ),
              ),
            ],
          ),

          // ── Tab 4: Settings ──────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const ComingSoonPage(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Top-level routes outside the shell (full screen, no bottom nav) ──
      GoRoute(
        path: AppRoutes.transactionAdd,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ComingSoonPage(
          title: 'Add Transaction',
          icon: Icons.add_circle_outline,
        ),
      ),
      GoRoute(
        path: AppRoutes.budget,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ComingSoonPage(
          title: 'Budget',
          icon: Icons.pie_chart_outline,
        ),
      ),
      GoRoute(
        path: AppRoutes.debt,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ComingSoonPage(
          title: 'Debt Manager',
          icon: Icons.credit_card_outlined,
        ),
      ),
      GoRoute(
        path: AppRoutes.assets,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ComingSoonPage(
          title: 'Asset Manager',
          icon: Icons.home_work_outlined,
        ),
      ),
      GoRoute(
        path: AppRoutes.goals,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ComingSoonPage(
          title: 'Goals',
          icon: Icons.flag_outlined,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiInsights,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ComingSoonPage(
          title: 'AI Insights',
          icon: Icons.auto_awesome_outlined,
        ),
      ),
    ],
  );
});
