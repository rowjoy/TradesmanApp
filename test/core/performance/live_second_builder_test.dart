import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/widgets/live_second_builder.dart';

void main() {
  testWidgets('does not tick when its indexed subtree is disabled', (
    tester,
  ) async {
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: TickerMode(
          enabled: false,
          child: LiveSecondBuilder(
            builder: (_, __) {
              builds++;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    final initialBuilds = builds;
    await tester.pump(const Duration(seconds: 3));
    expect(builds, initialBuilds);
  });

  testWidgets('updates its small subtree while active', (tester) async {
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LiveSecondBuilder(
          builder: (_, __) {
            builds++;
            return const SizedBox();
          },
        ),
      ),
    );

    final initialBuilds = builds;
    await tester.pump(const Duration(seconds: 1));
    expect(builds, greaterThan(initialBuilds));
  });
}
