import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist the chosen theme mode.
const _themeModePrefsKey = 'app_theme_mode';

/// Controls the app-wide [ThemeMode] (light / dark / system).
///
/// Persists the choice via `shared_preferences` so it survives app
/// restarts. Falls back silently to in-memory state if prefs are
/// unavailable (e.g. first run before plugins are registered).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_themeModePrefsKey);
      switch (saved) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    } catch (_) {
      // Keep default ThemeMode.system if prefs can't be read.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModePrefsKey, mode.name);
    } catch (_) {
      // Non-fatal: theme just won't persist this session.
    }
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(next);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
