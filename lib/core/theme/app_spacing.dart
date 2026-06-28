/// Spacing, radius, and elevation design tokens.
///
/// Centralizing these means every card, button, and sheet in the app shares
/// the same rhythm — the difference between "looks handmade" and "looks like
/// a design system."
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Screen-level padding
  static const double screenHorizontal = 20;
  static const double screenVertical = 16;
}

class AppRadius {
  AppRadius._();

  static const double sm = 10;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;
}

class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double card = 0; // we use soft shadows, not Material elevation
  static const double raised = 2;
  static const double modal = 8;
}
