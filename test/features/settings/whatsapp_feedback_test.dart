import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradesman_manager/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:tradesman_manager/features/settings/settings_screen.dart';
import 'package:tradesman_manager/features/settings/whatsapp_feedback.dart';
import 'package:tradesman_manager/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildSettings({
  WhatsAppFeedbackLauncher? launcher,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      currentProfileProvider.overrideWithValue(null),
      if (launcher != null)
        whatsAppFeedbackLauncherProvider.overrideWithValue(launcher),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SettingsScreen(),
    ),
  );
}

Future<void> revealFeedback(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.drag(find.byType(ListView), const Offset(0, -3000));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'Help and guidance offers WhatsApp feedback with the contact number',
    (tester) async {
      await tester.pumpWidget(buildSettings());
      await revealFeedback(tester);

      expect(find.text('Send feedback on WhatsApp'), findsOneWidget);
      expect(find.textContaining('+8801783109748'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'opens only on tap with an external HTTPS draft and no user records',
    (tester) async {
      Uri? openedUri;
      LaunchMode? openedMode;
      var calls = 0;
      await tester.pumpWidget(
        buildSettings(
          launcher: (uri, {required mode}) async {
            calls++;
            openedUri = uri;
            openedMode = mode;
            return true;
          },
        ),
      );
      await revealFeedback(tester);
      expect(calls, 0);
      await tester.tap(find.text('Send feedback on WhatsApp'));
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(openedMode, LaunchMode.externalApplication);
      expect(openedUri!.scheme, 'https');
      expect(openedUri!.host, 'wa.me');
      expect(openedUri!.path, '/8801783109748');
      expect(openedUri!.queryParameters.keys, ['text']);
      expect(
        openedUri!.queryParameters['text'],
        'Hi WorkProof team, I would like to share feedback:',
      );
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  for (final throws in [false, true]) {
    testWidgets(
      '${throws ? 'thrown' : 'false'} launch failure shows safe AppFeedback',
      (tester) async {
        await tester.pumpWidget(
          buildSettings(
            launcher: (uri, {required mode}) async {
              if (throws) throw StateError('private platform diagnostics');
              return false;
            },
          ),
        );
        await revealFeedback(tester);
        await tester.tap(find.text('Send feedback on WhatsApp'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('Could not open WhatsApp. Please try again.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
        expect(
          find.textContaining('private platform diagnostics'),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('pending launch failure is safe after Settings is removed', (
    tester,
  ) async {
    final result = Completer<bool>();
    await tester.pumpWidget(
      buildSettings(launcher: (uri, {required mode}) => result.future),
    );
    await revealFeedback(tester);
    await tester.tap(find.text('Send feedback on WhatsApp'));
    await tester.pumpWidget(const SizedBox());
    result.completeError(StateError('launch failed after navigation'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Bengali feedback labels and draft are localized', (
    tester,
  ) async {
    Uri? openedUri;
    await tester.pumpWidget(
      buildSettings(
        locale: const Locale('bn'),
        launcher: (uri, {required mode}) async {
          openedUri = uri;
          return true;
        },
      ),
    );
    await revealFeedback(tester);
    await tester.tap(find.text('WhatsApp-এ মতামত পাঠান'));
    await tester.pumpAndSettle();

    expect(
      openedUri!.queryParameters['text'],
      'হ্যালো WorkProof টিম, আমি কিছু মতামত জানাতে চাই:',
    );
    expect(openedUri!.toString(), isNot(contains('হ্যালো')));
    expect(tester.takeException(), isNull);
  });
}
