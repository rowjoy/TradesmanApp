import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/router/app_shell.dart';
import 'package:tradesman_manager/core/widgets/app_banner_frame.dart';
import 'package:tradesman_manager/features/ads/application/ads_consent_controller.dart';
import 'package:tradesman_manager/features/ads/application/banner_overlay_controller.dart';

void main() {
  testWidgets('eligible tabs retain one shared banner owner', (tester) async {
    final tracker = _BannerTracker();
    final consent = _FakeAdsConsentController();
    final overlay = BannerOverlayController();
    final navigatorKey = GlobalKey<NavigatorState>();
    final shell = ValueNotifier<_ShellState>(
      const _ShellState(index: 0, proofHasContent: false),
    );
    addTearDown(shell.dispose);

    await tester.pumpWidget(
      _placementApp(
        tracker: tracker,
        consent: consent,
        overlay: overlay,
        shell: shell,
        navigatorKey: navigatorKey,
      ),
    );
    await tester.pumpAndSettle();

    expect(tracker.active, 1);
    expect(tracker.created, 1);

    for (final index in <int>[1, 2]) {
      shell.value = _ShellState(index: index, proofHasContent: false);
      await tester.pump();
      expect(tracker.active, 1);
      expect(tracker.created, 1);
    }

    shell.value = const _ShellState(index: 3, proofHasContent: true);
    await tester.pump();
    expect(tracker.active, 1);
    expect(tracker.created, 1);

    shell.value = const _ShellState(index: 3, proofHasContent: false);
    await tester.pump();
    expect(tracker.active, 0);
    expect(tracker.disposed, 1);

    shell.value = const _ShellState(index: 3, proofHasContent: true);
    await tester.pump();
    expect(tracker.active, 1);
    expect(tracker.created, 2);

    shell.value = const _ShellState(index: 4, proofHasContent: true);
    await tester.pump();
    expect(tracker.active, 0);

    shell.value = const _ShellState(index: 0, proofHasContent: false);
    await tester.pump();
    expect(tracker.active, 1);
    expect(tracker.created, 3);

    unawaited(
      navigatorKey.currentState!.push<void>(
        MaterialPageRoute<void>(builder: (_) => const Scaffold()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tracker.active, 0);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(tracker.active, 1);
    expect(tracker.created, 4);
  });

  testWidgets('work readiness and the outer shell keyboard suppress banners', (
    tester,
  ) async {
    final tracker = _BannerTracker();
    final consent = _FakeAdsConsentController();
    final overlay = BannerOverlayController();
    final shell = ValueNotifier<_ShellState>(
      const _ShellState(
        index: 1,
        proofHasContent: false,
        workHasContent: false,
      ),
    );
    addTearDown(shell.dispose);

    await tester.pumpWidget(
      _placementApp(
        tracker: tracker,
        consent: consent,
        overlay: overlay,
        shell: shell,
      ),
    );
    await tester.pump();
    expect(tracker.active, 0);

    shell.value = const _ShellState(
      index: 1,
      proofHasContent: false,
      workHasContent: true,
    );
    await tester.pump();
    expect(tracker.active, 1);

    shell.value = const _ShellState(
      index: 1,
      proofHasContent: false,
      workHasContent: true,
      keyboardHeight: 260,
    );
    await tester.pump();
    expect(tracker.active, 0);

    shell.value = const _ShellState(
      index: 1,
      proofHasContent: false,
      workHasContent: true,
    );
    await tester.pump();
    expect(tracker.active, 1);
  });

  testWidgets('mobile and rail layouts keep navigation outside the banner', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[390, 1000]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      final tracker = _BannerTracker();
      final consent = _FakeAdsConsentController();
      final overlay = BannerOverlayController();
      final shell = ValueNotifier<_ShellState>(
        const _ShellState(index: 0, proofHasContent: false),
      );

      await tester.pumpWidget(
        _placementApp(
          tracker: tracker,
          consent: consent,
          overlay: overlay,
          shell: shell,
        ),
      );
      await tester.pump();

      final bannerRect = tester.getRect(find.byKey(_BannerTracker.bannerKey));
      if (width >= 840) {
        final railRect = tester.getRect(find.byKey(const Key('test-rail')));
        expect(railRect.right, lessThanOrEqualTo(bannerRect.left));
        expect(find.byKey(const Key('test-bottom-nav')), findsNothing);
      } else {
        final bottomRect = tester.getRect(
          find.byKey(const Key('test-bottom-nav')),
        );
        expect(bannerRect.bottom, lessThan(bottomRect.top));
        expect(find.byKey(const Key('test-rail')), findsNothing);
      }
      expect(find.text('branch 0'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      shell.dispose();
    }
  });
}

Widget _placementApp({
  required _BannerTracker tracker,
  required _FakeAdsConsentController consent,
  required BannerOverlayController overlay,
  required ValueNotifier<_ShellState> shell,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return ProviderScope(
    overrides: [
      appBannerBuilderProvider.overrideWithValue(tracker.build),
      bannerOverlayControllerProvider.overrideWith((_) => overlay),
      adsConsentControllerProvider.overrideWith((_) => consent),
    ],
    child: MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [overlay.createObserver()],
      home: ValueListenableBuilder<_ShellState>(
        valueListenable: shell,
        builder: (context, value, _) {
          final media = MediaQuery.of(
            context,
          ).copyWith(viewInsets: EdgeInsets.only(bottom: value.keyboardHeight));
          return MediaQuery(
            data: media,
            child: Builder(
              builder: (context) => LayoutBuilder(
                builder: (context, constraints) {
                  final region = MainShellBannerRegion(
                    currentIndex: value.index,
                    proofHasContent: value.proofHasContent,
                    workHasContent: value.workHasContent,
                    keyboardVisible:
                        MediaQuery.viewInsetsOf(context).bottom > 0,
                    child: ColoredBox(
                      color: Colors.white,
                      child: Center(child: Text('branch ${value.index}')),
                    ),
                  );
                  if (constraints.maxWidth >= 840) {
                    return Scaffold(
                      body: Row(
                        children: [
                          const SizedBox(key: Key('test-rail'), width: 88),
                          Expanded(child: region),
                        ],
                      ),
                    );
                  }
                  return Scaffold(
                    body: region,
                    bottomNavigationBar: const SizedBox(
                      key: Key('test-bottom-nav'),
                      height: 72,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _ShellState {
  const _ShellState({
    required this.index,
    required this.proofHasContent,
    this.workHasContent = true,
    this.keyboardHeight = 0,
  });

  final int index;
  final bool proofHasContent;
  final bool workHasContent;
  final double keyboardHeight;
}

class _BannerTracker {
  static const bannerKey = Key('placement-banner');

  int created = 0;
  int disposed = 0;

  int get active => created - disposed;

  Widget build(BuildContext context, AdPlacement placement) {
    expect(placement, AdPlacement.appShell);
    return _TrackedBanner(key: bannerKey, tracker: this);
  }
}

class _TrackedBanner extends StatefulWidget {
  const _TrackedBanner({required this.tracker, super.key});

  final _BannerTracker tracker;

  @override
  State<_TrackedBanner> createState() => _TrackedBannerState();
}

class _TrackedBannerState extends State<_TrackedBanner> {
  @override
  void initState() {
    super.initState();
    widget.tracker.created++;
  }

  @override
  void dispose() {
    widget.tracker.disposed++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 50);
}

class _FakeAdsConsentController extends AdsConsentController {
  _FakeAdsConsentController() {
    state = const AdsConsentState(
      status: AdsConsentStatus.ready,
      canRequestAds: true,
      sdkInitialized: true,
    );
  }

  @override
  Future<void> initialize() async {}
}
