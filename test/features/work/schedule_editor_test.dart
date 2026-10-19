import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/time/time_zone_options.dart';
import 'package:tradesman_manager/core/widgets/inline_animated_picker.dart';
import 'package:tradesman_manager/features/work/presentation/widgets/schedule_editor.dart';
import 'package:tradesman_manager/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows the device time zone without a user picker', (
    tester,
  ) async {
    final controller = ScheduleEditorController()
      ..useDeviceTimeZone('Asia/Dhaka');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ScheduleEditor(controller: controller)),
      ),
    );

    expect(find.textContaining('Asia/Dhaka'), findsOneWidget);
    expect(find.byType(InlineAnimatedPicker<String>), findsNothing);
  });

  test('recalculates schedule offsets from the device after date changes', () {
    final controller = ScheduleEditorController()
      ..useDeviceTimeZone('Device/Zone');
    final nextStart = controller.startLocal.add(const Duration(days: 180));

    controller.setStart(nextStart);

    expect(controller.ianaTimeZone, 'Device/Zone');
    expect(controller.startOffsetMinutes, deviceOffsetMinutes(nextStart));
  });
}
