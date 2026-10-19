import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradesman_manager/features/app_update/presentation/store_update_gate.dart';
import 'package:upgrader/upgrader.dart';

void main() {
  test('configures startup and resume checks without a reminder delay', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final upgrader = container.read(appStoreUpgraderProvider);

    expect(upgrader.state.checkOnResume, isTrue);
    expect(upgrader.state.durationUntilAlertAgain, Duration.zero);
  });

  testWidgets('force alert exposes no dismissal path', (tester) async {
    final alert = ForcedUpgradeAlert(
      upgrader: _FakeUpgrader(),
      child: const SizedBox.shrink(),
    );

    expect(alert.showIgnore, isFalse);
    expect(alert.showLater, isFalse);
    expect(alert.barrierDismissible, isFalse);
    expect(alert.shouldPopScope?.call(), isFalse);
  });

  testWidgets('update opens the store without popping the current route', (
    tester,
  ) async {
    final upgrader = _FakeUpgrader();
    BuildContext? pushedRouteContext;

    await tester.pumpWidget(
      MaterialApp(
        home: ForcedUpgradeAlert(
          upgrader: upgrader,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) {
                        pushedRouteContext = context;
                        return const Scaffold(body: Text('pushed route'));
                      },
                    ),
                  );
                },
                child: const Text('push'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('pushed route'), findsOneWidget);

    final alertFinder = find.byType(ForcedUpgradeAlert, skipOffstage: false);
    expect(alertFinder, findsOneWidget);
    final state = tester.state<ForcedUpgradeAlertState>(alertFinder);
    state.onUserUpdated(pushedRouteContext!, true);
    await tester.pumpAndSettle();

    expect(upgrader.storeLaunches, 1);
    expect(find.text('pushed route'), findsOneWidget);
  });

  testWidgets('restores a forced dialog after its owning page is replaced', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final router = _ReplacingRouterDelegate();
    final upgrader = _FakeUpgrader();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: router,
        routeInformationParser: const _IntegerRouteParser(),
        builder: (context, child) => ForcedUpgradeAlert(
          upgrader: upgrader,
          navigatorKey: router.navigatorKey,
          child: child,
        ),
      ),
    );

    final state = tester.state<ForcedUpgradeAlertState>(
      find.byType(ForcedUpgradeAlert),
    );
    state.showTheDialog(
      key: const Key('upgrader_alert_dialog'),
      context: router.navigatorKey.currentContext!,
      title: 'Update required',
      message: 'A newer version is available.',
      releaseNotes: null,
      barrierDismissible: false,
      messages: UpgraderMessages(code: 'en'),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('upgrader_alert_dialog')), findsOneWidget);

    router.replaceWith(1);
    await tester.pumpAndSettle();

    expect(find.text('page 1'), findsOneWidget);
    expect(upgrader.displayChecks, greaterThan(0));
    expect(state.displayed, isTrue);
    expect(find.byKey(const Key('upgrader_alert_dialog')), findsOneWidget);
  });
}

class _IntegerRouteParser extends RouteInformationParser<int> {
  const _IntegerRouteParser();

  @override
  Future<int> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture(0);

  @override
  RouteInformation? restoreRouteInformation(int configuration) {
    return RouteInformation(uri: Uri(path: '/$configuration'));
  }
}

class _ReplacingRouterDelegate extends RouterDelegate<int>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<int> {
  int _pageIndex = 0;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void replaceWith(int pageIndex) {
    _pageIndex = pageIndex;
    notifyListeners();
  }

  @override
  int get currentConfiguration => _pageIndex;

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    pages: [
      MaterialPage<void>(
        key: ValueKey(_pageIndex),
        child: Scaffold(body: Text('page $_pageIndex')),
      ),
    ],
    onDidRemovePage: (_) {},
  );

  @override
  Future<bool> popRoute() => SynchronousFuture(false);

  @override
  Future<void> setNewRoutePath(int configuration) {
    _pageIndex = configuration;
    return SynchronousFuture(null);
  }
}

class _FakeUpgrader extends Upgrader {
  int storeLaunches = 0;
  int displayChecks = 0;

  @override
  Future<bool> initialize() async => true;

  @override
  String body(UpgraderMessages messages) => 'A newer version is available.';

  @override
  bool shouldDisplayUpgrade() {
    displayChecks++;
    return true;
  }

  @override
  Future<void> sendUserToAppStore() async {
    storeLaunches++;
  }
}
