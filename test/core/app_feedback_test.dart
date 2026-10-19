import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/widgets/app_feedback.dart';

void main() {
  testWidgets('defers feedback while a registered Scaffold is deactivated', (
    tester,
  ) async {
    late BuildContext feedbackContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            feedbackContext = context;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );

    final scaffoldElement = tester.element(find.byType(Scaffold));
    // Reproduce the framework's transient state before dispose unregisters it.
    // ignore: invalid_use_of_visible_for_overriding_member
    scaffoldElement.deactivate();
    try {
      AppFeedback.info(feedbackContext, 'Saved safely');
    } finally {
      tester.binding.buildOwner!.buildScope(
        tester.binding.rootElement!,
        // ignore: invalid_use_of_visible_for_overriding_member
        scaffoldElement.activate,
      );
    }

    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Saved safely'), findsOneWidget);
  });

  testWidgets('does not throw if no Scaffold remains after deferring', (
    tester,
  ) async {
    final showScaffold = ValueNotifier(true);
    addTearDown(showScaffold.dispose);
    late BuildContext feedbackContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            feedbackContext = context;
            return ValueListenableBuilder<bool>(
              valueListenable: showScaffold,
              builder: (context, show, child) =>
                  show ? const Scaffold(body: SizedBox()) : const SizedBox(),
            );
          },
        ),
      ),
    );

    AppFeedback.info(feedbackContext, 'No target');
    showScaffold.value = false;
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('No target'), findsNothing);
  });
}
