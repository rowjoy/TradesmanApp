import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/providers/app_metadata_provider.dart';
import 'package:tradesman_manager/core/theme/app_theme.dart';
import 'package:tradesman_manager/features/about/presentation/about_app_screen.dart';
import 'package:tradesman_manager/features/app_review/application/app_review_providers.dart';
import 'package:tradesman_manager/features/app_review/application/app_review_service.dart';
import 'package:tradesman_manager/features/work/domain/work_models.dart';
import 'package:tradesman_manager/features/work/presentation/controllers/work_controller.dart';
import 'package:tradesman_manager/l10n/generated/app_localizations.dart';

void main() {
  const metadata = AppMetadata(appName: 'Native WorkProof', packageName: 'com.workproof.workhelper', version: '2.5.0', buildNumber: '42');

  Widget buildApp({required Locale locale, required ThemeMode themeMode, AppReviewGateway? reviewGateway}) {
    final gateway = reviewGateway ?? _FakeReviewGateway(canOpenListing: false);
    return ProviderScope(
      overrides: [
        appMetadataProvider.overrideWith((ref) async => metadata),
        selectedWorkFlowProvider.overrideWith((ref) => WorkFlow.worker),
        appReviewGatewayProvider.overrideWithValue(gateway),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AboutAppScreen(),
      ),
    );
  }

  testWidgets('shows native app metadata, logo, and localized features', (tester) async {
    const locale = Locale('en');
    final strings = lookupAppLocalizations(locale);

    await tester.pumpWidget(buildApp(locale: locale, themeMode: ThemeMode.light));
    await tester.pumpAndSettle();

    expect(find.text('Native WorkProof'), findsOneWidget);
    expect(find.text(strings.versionLabel('2.5.0+42')), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text(strings.appFeaturesTitle), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text(strings.featureTimeTrackingTitle), 220);
    await tester.tap(find.byTooltip(strings.featureDetails).first);
    await tester.pumpAndSettle();

    expect(find.text(strings.openFeature), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('remains scrollable in dark mode on a narrow scaled display', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    const locale = Locale('bn');
    final strings = lookupAppLocalizations(locale);
    await tester.pumpWidget(buildApp(locale: locale, themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(find.byType(AboutAppScreen))).brightness, Brightness.dark);
    expect(find.text(strings.aboutWorkProof), findsOneWidget);
    expect(find.text(strings.versionLabel('2.5.0+42')), findsOneWidget);

    await tester.scrollUntilVisible(find.text(strings.codeToolsTitle), 300);
    await tester.pump();
    expect(find.text(strings.codeToolsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rate action opens the store listing instead of native review', (tester) async {
    final strings = lookupAppLocalizations(const Locale('en'));
    final gateway = _FakeReviewGateway(canOpenListing: true);
    await tester.pumpWidget(buildApp(locale: const Locale('en'), themeMode: ThemeMode.light, reviewGateway: gateway));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text(strings.rateWorkProof), 200);
    await tester.tap(find.text(strings.rateWorkProof));
    await tester.pumpAndSettle();

    expect(gateway.openListingCount, 1);
    expect(gateway.requestReviewCount, 0);
  });

  testWidgets('rate action is hidden when the store listing is unsupported', (tester) async {
    final strings = lookupAppLocalizations(const Locale('en'));
    await tester.pumpWidget(buildApp(locale: const Locale('en'), themeMode: ThemeMode.light, reviewGateway: _FakeReviewGateway(canOpenListing: false)));
    await tester.pumpAndSettle();

    expect(find.text(strings.rateWorkProof), findsNothing);
  });

  testWidgets('store listing failure shows feedback without escaping', (tester) async {
    final strings = lookupAppLocalizations(const Locale('en'));
    final gateway = _FakeReviewGateway(canOpenListing: true, openError: StateError('store failed'));
    await tester.pumpWidget(buildApp(locale: const Locale('en'), themeMode: ThemeMode.light, reviewGateway: gateway));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text(strings.rateWorkProof), 200);
    await tester.tap(find.text(strings.rateWorkProof));
    await tester.pump();
    await tester.pump();

    expect(find.text(strings.storeListingFailed), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeReviewGateway implements AppReviewGateway {
  _FakeReviewGateway({required this.canOpenListing, this.openError});

  final bool canOpenListing;
  final Object? openError;
  int openListingCount = 0;
  int requestReviewCount = 0;

  @override
  bool get canOpenStoreListing => canOpenListing;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> openStoreListing() async {
    openListingCount++;
    if (openError case final error?) throw error;
  }

  @override
  Future<void> requestReview() async {
    requestReviewCount++;
  }
}
