import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/app_update/presentation/store_update_gate.dart';
import 'features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'features/security/presentation/app_lock_gate.dart';
import 'features/showcase/presentation/app_showcase.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppShowcaseCoordinator.instance.register();
  await Firebase.initializeApp();
  FlutterError.onError = (errorDetails) {
    FlutterError.presentError(errorDetails);

    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Unhandled errors outside Flutter framework callbacks.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

    return true;
  };
  // Ads/Firebase are intentionally not initialized here. The local workspace
  // renders first; consent-aware optional services are added in their own slice.
  runApp(const ProviderScope(child: WorkProofApp()));
}

class WorkProofApp extends ConsumerWidget {
  const WorkProofApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final upgrader = ref.watch(appStoreUpgraderProvider);
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
        child: ForcedUpgradeAlert(
          upgrader: upgrader,
          navigatorKey: router.routerDelegate.navigatorKey,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/*

https://github.com/gitnecmoney/Nec_pay_cyprus_Mobile
https://github.com/gitnecmoney/NecMoneyApp
https://github.com/gitnecmoney/necpay_bd_Mobile
https://github.com/gitnecmoney/Nec_Digital_Bank_Mobile





 */
