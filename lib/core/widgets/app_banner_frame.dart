import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ads/application/ads_consent_controller.dart';
import '../../features/ads/application/banner_overlay_controller.dart';
import '../../features/showcase/presentation/app_showcase.dart';
import 'banner_ad_widget.dart';

export '../../features/ads/infrastructure/ad_unit_config.dart' show AdPlacement;

typedef AppBannerBuilder =
    Widget Function(BuildContext context, AdPlacement placement);

final appBannerBuilderProvider = Provider<AppBannerBuilder>((ref) {
  return (context, placement) => BannerAdWidget(placement: placement);
});

class AppBannerFrame extends ConsumerStatefulWidget {
  const AppBannerFrame({
    required this.child,
    required this.placement,
    this.enabled = true,
    this.showcaseActivity,
    super.key,
  });

  final Widget child;
  final AdPlacement placement;
  final bool enabled;
  final ValueListenable<bool>? showcaseActivity;

  @override
  ConsumerState<AppBannerFrame> createState() => _AppBannerFrameState();
}

class _AppBannerFrameState extends ConsumerState<AppBannerFrame>
    with WidgetsBindingObserver {
  late AppLifecycleState _lifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    unawaited(
      Future<void>.microtask(() async {
        if (!mounted) return;
        await ref.read(adsConsentControllerProvider.notifier).initialize();
      }),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lifecycleState == state) return;
    setState(() => _lifecycleState = state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasBlockingOverlay = ref
        .watch(bannerOverlayControllerProvider)
        .hasBlockingOverlay;
    final bannerBuilder = ref.watch(appBannerBuilderProvider);
    final showcaseActivity =
        widget.showcaseActivity ?? AppShowcaseCoordinator.instance.activity;

    return ValueListenableBuilder<bool>(
      valueListenable: showcaseActivity,
      builder: (context, showcaseActive, _) {
        final routeIsCurrent = ModalRoute.isCurrentOf(context) == true;
        final bannerEnabled =
            widget.enabled &&
            _lifecycleState == AppLifecycleState.resumed &&
            routeIsCurrent &&
            !hasBlockingOverlay &&
            TickerMode.valuesOf(context).enabled &&
            !showcaseActive &&
            MediaQuery.viewInsetsOf(context).bottom == 0;

        return SafeArea(
          bottom: false,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Column(
              children: [
                KeyedSubtree(
                  key: const ValueKey<String>('app-banner-slot'),
                  child: bannerEnabled
                      ? bannerBuilder(context, widget.placement)
                      : const SizedBox.shrink(),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      },
    );
  }
}
