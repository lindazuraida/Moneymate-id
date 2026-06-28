import 'package:flutter/material.dart';

/// Centralized color palette for MoneyMate ID.
///
/// The palette is built around a deep "wealth" indigo/violet as the brand
/// seed color, with a fintech-standard semantic set for income (green),
/// expense (red/coral), and warning/neutral tones used across budgets,
/// debts, and goal progress indicators.
class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────
  static const Color primary = Color(0xFF5B5FEF); // indigo-violet
  static const Color primaryDark = Color(0xFF8A8DF7);
  static const Color secondary = Color(0xFF14B8A6); // teal accent
  static const Color tertiary = Color(0xFFF59E0B); // amber accent

  // ── Semantic (financial) ───────────────────────────
  static const Color income = Color(0xFF22C55E); // green
  static const Color expense = Color(0xFFEF4444); // red/coral
  static const Color transfer = Color(0xFF3B82F6); // blue
  static const Color investment = Color(0xFF8B5CF6); // purple
  static const Color debt = Color(0xFFF97316); // orange
  static const Color warning = Color(0xFFFBBF24);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  // ── Light surfaces ──────────────────────────────────
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF0FA);
  static const Color lightOutline = Color(0xFFE2E4ED);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // ── Dark surfaces ───────────────────────────────────
  static const Color darkBackground = Color(0xFF0B0D17);
  static const Color darkSurface = Color(0xFF151823);
  static const Color darkSurfaceVariant = Color(0xFF1E2230);
  static const Color darkOutline = Color(0xFF2A2F40);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // ── Gradients (used on hero/balance cards) ──────────
  static const List<Color> heroGradientLight = [
    Color(0xFF5B5FEF),
    Color(0xFF8A5CF6),
  ];

  static const List<Color> heroGradientDark = [
    Color(0xFF4338CA),
    Color(0xFF6D28D9),
  ];

  // ── Category accent palette (for charts / icons) ────
  static const List<Color> categoryPalette = [
    Color(0xFF5B5FEF),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
    Color(0xFF22C55E),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];
}
