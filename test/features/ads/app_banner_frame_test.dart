import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/widgets/app_banner_frame.dart';
import 'package:tradesman_manager/features/ads/application/ads_consent_controller.dart';
import 'package:tradesman_manager/features/ads/application/banner_overlay_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('overlay observers share popup state without getting stuck', () {
    final controller = BannerOverlayController();
    final first = controller.createObserver();
    final second = controller.createObserver();
    final changes = <bool>[];
    controller.addListener(() => changes.add(controller.hasBlockingOverlay));

    final popup = _TestPopupRoute();
    first.didPush(popup, null);
    second.didPush(popup, null);

    expect(controller.hasBlockingOverlay, isTrue);
    expect(changes, <bool>[true]);

    first.didPop(popup, null);
    expect(controller.hasBlockingOverlay, isTrue);
    expect(changes, <bool>[true]);

    second.didRemove(popup, null);
    expect(controller.hasBlockingOverlay, isFalse);
    expect(changes, <bool>[true, false]);

    final replacement = _TestPopupRoute();
    first.didPush(popup, null);
    first.didReplace(newRoute: replacement, oldRoute: popup);
    expect(controller.hasBlockingOverlay, isTrue);
    expect(changes, <bool>[true, false, true]);

    first.didReplace(
      newRoute: MaterialPageRoute<void>(builder: (_) => const SizedBox()),
      oldRoute: replacement,
    );
    expect(controller.hasBlockingOverlay, isFalse);
    expect(changes, <bool>[true, false, true, false]);

    controller.dispose();
  });

  testWidgets('every contextual gate removes and restores one banner', (
    tester,
  ) async {
    final tracker = _BannerTracker();
    final overlay = BannerOverlayController();
    final overlayObserver = overlay.createObserver();
    final consent = _FakeAdsConsentController();
    final showcase = ValueNotifier<bool>(false);
    final settings = ValueNotifier<_FrameSettings>(const _FrameSettings());
    addTearDown(showcase.dispose);
    addTearDown(settings.dispose);
    addTearDown(() {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });

    await tester.pumpWidget(
      _frameApp(
        tracker: tracker,
        overlay: overlay,
        observer: overlayObserver,
        consent: consent,
        showcase: showcase,
        settings: settings,
        child: const ColoredBox(color: Colors.white),
      ),
    );
    await tester.pump();

    expect(tracker.active, 1);
    expect(consent.initializeCalls, 1);

    Future<void> expectSuppressed(_FrameSettings next) async {
      settings.value = next;
      await tester.pump();
      expect(tracker.active, 0);
    }

    Future<void> expectRestored() async {
      settings.value = const _FrameSettings();
      await tester.pump();
      expect(tracker.active, 1);
      expect(tracker.created, tracker.disposed + 1);
    }

    await expectSuppressed(const _FrameSettings(enabled: false));
    await expectRestored();
    await expectSuppressed(const _FrameSettings(tickerEnabled: false));
    await expectRestored();
    await expectSuppressed(const _FrameSettings(keyboardHeight: 240));
    await expectRestored();

    showcase.value = true;
    await tester.pump();
    expect(tracker.active, 0);
    showcase.value = false;
    await tester.pump();
    expect(tracker.active, 1);

    final popup = _TestPopupRoute();
    overlayObserver.didPush(popup, null);
    await tester.pump();
    expect(tracker.active, 0);
    overlayObserver.didRemove(popup, null);
    await tester.pump();
    expect(tracker.active, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(tracker.active, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tracker.active, 1);

    for (final state in <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump();
      expect(tracker.active, 0, reason: '$state');
    }
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tracker.active, 1);
  });

  testWidgets('child text, focus, and scroll state survive suppression', (
    tester,
  ) async {
    final tracker = _BannerTracker();
    final overlay = BannerOverlayController();
    final consent = _FakeAdsConsentController();
    final showcase = ValueNotifier<bool>(false);
    final settings = ValueNotifier<_FrameSettings>(const _FrameSettings());
    final childKey = GlobalKey<_PersistentChildState>();
    addTearDown(showcase.dispose);
    addTearDown(settings.dispose);

    await tester.pumpWidget(
      _frameApp(
        tracker: tracker,
        overlay: overlay,
        observer: overlay.createObserver(),
        consent: consent,
        showcase: showcase,
        settings: settings,
        child: _PersistentChild(key: childKey),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('persistent-field')), 'saved');
    childKey.currentState!.focusNode.requestFocus();
    await tester.drag(
      find.byKey(const Key('persistent-list')),
      const Offset(0, -250),
    );
    await tester.pump();
    final offset = childKey.currentState!.scrollController.offset;
    expect(offset, greaterThan(0));
    expect(childKey.currentState!.focusNode.hasFocus, isTrue);

    showcase.value = true;
    await tester.pump();
    expect(tracker.active, 0);
    showcase.value = false;
    await tester.pump();

    expect(tracker.active, 1);
    expect(childKey.currentState!.textController.text, 'saved');
    expect(childKey.currentState!.focusNode.hasFocus, isTrue);
    expect(childKey.currentState!.scrollController.offset, offset);
  });

  testWidgets('page and popup coverage dispose then restore the banner', (
    tester,
  ) async {
    final tracker = _BannerTracker();
    final overlay = BannerOverlayController();
    final consent = _FakeAdsConsentController();
    final showcase = ValueNotifier<bool>(false);
    final settings = ValueNotifier<_FrameSettings>(const _FrameSettings());
    final navigatorKey = GlobalKey<NavigatorState>();
    addTearDown(showcase.dispose);
    addTearDown(settings.dispose);

    await tester.pumpWidget(
      _frameApp(
        tracker: tracker,
        overlay: overlay,
        observer: overlay.createObserver(),
        consent: consent,
        showcase: showcase,
        settings: settings,
        navigatorKey: navigatorKey,
        child: const ColoredBox(color: Colors.white),
      ),
    );
    await tester.pumpAndSettle();
    expect(tracker.active, 1);

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

    unawaited(
      showDialog<void>(
        context: navigatorKey.currentContext!,
        builder: (_) => const AlertDialog(content: Text('blocking popup')),
      ),
    );
    await tester.pumpAndSettle();
    expect(overlay.hasBlockingOverlay, isTrue);
    expect(tracker.active, 0);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(overlay.hasBlockingOverlay, isFalse);
    expect(tracker.active, 1);
  });

  testWidgets('top safe area is applied once at phone and rail widths', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in <double>[390, 1000]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      final tracker = _BannerTracker();
      final overlay = BannerOverlayController();
      final consent = _FakeAdsConsentController();
      final showcase = ValueNotifier<bool>(false);
      final settings = ValueNotifier<_FrameSettings>(const _FrameSettings());

      await tester.pumpWidget(
        _frameApp(
          tracker: tracker,
          overlay: overlay,
          observer: overlay.createObserver(),
          consent: consent,
          showcase: showcase,
          settings: settings,
          mediaPadding: const EdgeInsets.only(top: 24),
          child: const ColoredBox(
            key: Key('safe-content'),
            color: Colors.white,
          ),
        ),
      );
      await tester.pump();

      expect(tester.getTopLeft(find.byKey(_BannerTracker.bannerKey)).dy, 24);
      expect(tester.getTopLeft(find.byKey(const Key('safe-content'))).dy, 74);
      expect(tester.takeException(), isNull);

      settings.value = const _FrameSettings(enabled: false);
      await tester.pump();
      expect(tester.getTopLeft(find.byKey(const Key('safe-content'))).dy, 24);
      expect(tester.takeException(), isNull);

      showcase.dispose();
      settings.dispose();
    }
  });
}

Widget _frameApp({
  required _BannerTracker tracker,
  required BannerOverlayController overlay,
  required NavigatorObserver observer,
  required _FakeAdsConsentController consent,
  required ValueNotifier<bool> showcase,
  required ValueNotifier<_FrameSettings> settings,
  required Widget child,
  GlobalKey<NavigatorState>? navigatorKey,
  EdgeInsets mediaPadding = EdgeInsets.zero,
}) {
  return ProviderScope(
    overrides: [
      appBannerBuilderProvider.overrideWithValue(tracker.build),
      bannerOverlayControllerProvider.overrideWith((_) => overlay),
      adsConsentControllerProvider.overrideWith((_) => consent),
    ],
    child: MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [observer],
      builder: (context, routedChild) {
        final media = MediaQuery.of(context).copyWith(padding: mediaPadding);
        return MediaQuery(data: media, child: routedChild!);
      },
      home: ValueListenableBuilder<_FrameSettings>(
        valueListenable: settings,
        builder: (context, value, _) {
          final media = MediaQuery.of(
            context,
          ).copyWith(viewInsets: EdgeInsets.only(bottom: value.keyboardHeight));
          return MediaQuery(
            data: media,
            child: TickerMode(
              enabled: value.tickerEnabled,
              child: AppBannerFrame(
                enabled: value.enabled,
                placement: AdPlacement.appShell,
                showcaseActivity: showcase,
                child: child,
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _FrameSettings {
  const _FrameSettings({
    this.enabled = true,
    this.tickerEnabled = true,
    this.keyboardHeight = 0,
  });

  final bool enabled;
  final bool tickerEnabled;
  final double keyboardHeight;
}

class _BannerTracker {
  static const bannerKey = Key('tracked-banner');

  int created = 0;
  int disposed = 0;

  int get active => created - disposed;

  Widget build(BuildContext context, AdPlacement placement) {
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

  int initializeCalls = 0;

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }
}

class _PersistentChild extends StatefulWidget {
  const _PersistentChild({super.key});

  @override
  State<_PersistentChild> createState() => _PersistentChildState();
}

class _PersistentChildState extends State<_PersistentChild> {
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final scrollController = ScrollController();

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            key: const Key('persistent-field'),
            controller: textController,
            focusNode: focusNode,
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('persistent-list'),
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (_, index) =>
                  SizedBox(height: 48, child: Text('row $index')),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestPopupRoute extends PopupRoute<void> {
  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'test';

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const SizedBox();
  }
}
