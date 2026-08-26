import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'features/security/presentation/app_lock_gate.dart';
import 'features/showcase/presentation/app_showcase.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppShowcaseCoordinator.instance.register();
  // Ads/Firebase are intentionally not initialized here. The local workspace
  // renders first; consent-aware optional services are added in their own slice.
  runApp(const ProviderScope(child: TradesmanApp()));
}

class TradesmanApp extends ConsumerWidget {
  const TradesmanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final languageCode = ref.watch(
      currentProfileProvider.select((profile) => profile?.languageCode),
    );

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: languageCode == null ? null : Locale(languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) => AppLockGate(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
