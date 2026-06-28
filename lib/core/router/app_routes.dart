/// Centralized route path constants.
///
/// Keeping these as static strings (rather than scattering literal paths
/// across `context.go('/whatever')` calls) means renaming a route is a
/// one-file change and typos become compile-time errors at call sites
/// that reference `AppRoutes.xxx`.
class AppRoutes {
  AppRoutes._();

  // Shell tabs
  static const dashboard = '/dashboard';
  static const accounts = '/accounts';
  static const transactions = '/transactions';
  static const reports = '/reports';
  static const settings = '/settings';

  // Accounts
  static const accountDetail = '/accounts/:id';
  static const accountAdd = '/accounts/add';
  static const accountEdit = '/accounts/:id/edit';

  // Transactions
  static const transactionAdd = '/transactions/add';
  static const transactionDetail = '/transactions/:id';

  // Budget
  static const budget = '/budget';
  static const budgetAdd = '/budget/add';

  // Debt
  static const debt = '/debt';
  static const debtDetail = '/debt/:id';
  static const debtAdd = '/debt/add';

  // Assets
  static const assets = '/assets';
  static const assetAdd = '/assets/add';

  // Goals
  static const goals = '/goals';
  static const goalDetail = '/goals/:id';
  static const goalAdd = '/goals/add';

  // AI Insights
  static const aiInsights = '/ai-insights';

  // Auth
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';

  // Misc
  static const profile = '/profile';
  static const pinLock = '/pin-lock';

  static String accountDetailPath(String id) => '/accounts/$id';
  static String accountEditPath(String id) => '/accounts/$id/edit';
  static String transactionDetailPath(String id) => '/transactions/$id';
  static String debtDetailPath(String id) => '/debt/$id';
  static String goalDetailPath(String id) => '/goals/$id';
}
