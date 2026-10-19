import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/app_update/domain/app_update_models.dart';
import 'package:tradesman_manager/features/app_update/presentation/app_update_dialog.dart';
import 'package:tradesman_manager/l10n/generated/app_localizations.dart';

void main() {
  const optionalOffer = AppUpdateOffer(
    platform: AppUpdatePlatform.ios,
    flow: AppUpdateFlow.storeRedirect,
    installedVersion: '1.0.0',
    availableVersion: '1.1.0',
    isMandatory: false,
  );
  const mandatoryOffer = AppUpdateOffer(
    platform: AppUpdatePlatform.android,
    flow: AppUpdateFlow.immediate,
    installedVersion: '1.0.0',
    availableBuildNumber: 11,
    isMandatory: true,
  );

  Widget buildApp(AppUpdateOffer offer) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            key: const Key('show-update'),
            onPressed: () => AppUpdateDialog.show(context, offer: offer),
            child: const Text('Show'),
          ),
        ),
      ),
    ),
  );

  testWidgets('optional update offers Update Now and Later', (tester) async {
    final strings = lookupAppLocalizations(const Locale('en'));
    await tester.pumpWidget(buildApp(optionalOffer));

    await tester.tap(find.byKey(const Key('show-update')));
    await tester.pumpAndSettle();

    expect(find.text(strings.updateAvailableTitle), findsOneWidget);
    expect(find.text(strings.updateNow), findsOneWidget);
    expect(find.text(strings.later), findsOneWidget);
    expect(find.text(strings.versionLabel('1.1.0')), findsOneWidget);

    await tester.tap(find.text(strings.later));
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsNothing);
  });

  testWidgets('mandatory update hides Later and blocks the back action', (
    tester,
  ) async {
    final strings = lookupAppLocalizations(const Locale('en'));
    await tester.pumpWidget(buildApp(mandatoryOffer));

    await tester.tap(find.byKey(const Key('show-update')));
    await tester.pumpAndSettle();

    expect(find.text(strings.updateNow), findsOneWidget);
    expect(find.text(strings.later), findsNothing);
    expect(find.text(strings.updateRequiredMessage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsOneWidget);

    await tester.tap(find.text(strings.updateNow));
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsNothing);
  });
}
