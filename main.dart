import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

void main() {
  // Local-only mode: Firebase.initializeApp() intentionally omitted here.
  // When cloud sync is enabled, this becomes:
  //
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //   runApp(const ProviderScope(child: MoneyMateApp()));
  //
  // For now the app runs fully offline against local state/Isar.
  runApp(const ProviderScope(child: MoneyMateApp()));
}

class MoneyMateApp extends ConsumerWidget {
  const MoneyMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'MoneyMate ID',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
