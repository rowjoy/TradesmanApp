import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../features/ads/application/ads_consent_controller.dart';
import '../../features/ads/infrastructure/ad_diagnostics.dart';
import '../../features/ads/infrastructure/ad_unit_config.dart';
import '../../l10n/l10n.dart';

export '../../features/ads/infrastructure/ad_unit_config.dart' show AdPlacement;

/// A consent-aware, route-owned top banner.
///
/// The widget is only placed on browse/report surfaces. It collapses on no-fill,
/// missing production configuration, unsupported platforms, or denied consent.
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key, this.placement = AdPlacement.appShell});

  final AdPlacement placement;

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  static const _loadTimeoutDuration = Duration(seconds: 30);

  BannerAd? _ad;
  BannerAd? _loadingAd;
  Timer? _loadTimeout;
  int? _requestedWidth;
  int? _availableWidth;
  int? _reservedHeight;
  String? _unitId;
  String? _availableUnitId;
  bool _loading = false;
  bool _failed = false;
  bool _clearScheduled = false;
  bool _loadScheduled = false;
  int _generation = 0;

  @override
  void didUpdateWidget(covariant BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placement != widget.placement) _reset();
  }

  @override
  void dispose() {
    _reset();
    super.dispose();
  }

  void _reset() {
    _generation++;
    _loadTimeout?.cancel();
    _loadTimeout = null;
    final ad = _ad;
    final loadingAd = _loadingAd;
    _ad = null;
    _loadingAd = null;
    _requestedWidth = null;
    _reservedHeight = null;
    _unitId = null;
    _loading = false;
    _failed = false;
    _loadScheduled = false;
    unawaited(_disposeSafely(ad));
    if (!identical(ad, loadingAd)) unawaited(_disposeSafely(loadingAd));
  }

  Future<void> _disposeSafely(BannerAd? ad) async {
    if (ad == null) return;
    try {
      await ad.dispose();
    } catch (_) {
      // Ads are optional. A platform disposal failure must not affect the UI.
    }
  }

  bool _isEligibleNow(String unitId) {
    if (!mounted || !TickerMode.valuesOf(context).enabled) return false;
    if (MediaQuery.viewInsetsOf(context).bottom > 0) return false;
    if (!ref.read(adsConsentControllerProvider).adsReady) return false;
    return AdUnitConfig.bannerId(widget.placement) == unitId;
  }

  void _scheduleResetIfIneligible() {
    if (_clearScheduled) return;
    _clearScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearScheduled = false;
      if (!mounted) return;
      final unitId = AdUnitConfig.bannerId(widget.placement);
      if (unitId != null && _isEligibleNow(unitId)) return;
      setState(_reset);
    });
  }

  void _scheduleLoad() {
    if (_loadScheduled) return;
    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      final width = _availableWidth;
      final unitId = _availableUnitId;
      if (mounted && width != null && unitId != null) {
        unawaited(_load(width, unitId));
      }
    });
  }

  Future<void> _load(int width, String unitId) async {
    final sameRequest = _requestedWidth == width && _unitId == unitId;
    if (width <= 0 ||
        sameRequest ||
        _availableWidth != width ||
        _availableUnitId != unitId) {
      return;
    }
    if (!_isEligibleNow(unitId)) return;
    if (_loading || _failed) _reset();

    final generation = ++_generation;
    final old = _ad;
    setState(() {
      _loading = true;
      _requestedWidth = width;
      _reservedHeight = null;
      _unitId = unitId;
      _ad = null;
      _loadingAd = null;
    });
    await _disposeSafely(old);

    AdSize? adaptive;
    try {
      adaptive = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        width,
      ).timeout(_loadTimeoutDuration);
    } catch (_) {
      _markFailed(generation);
      return;
    }
    if (!mounted || generation != _generation) {
      return;
    }
    if (_availableWidth != width || _availableUnitId != unitId) {
      setState(_reset);
      return;
    }
    if (!_isEligibleNow(unitId)) {
      setState(_reset);
      return;
    }

    final size = adaptive ?? AdSize.banner;
    late final BannerAd banner;
    banner = BannerAd(
      adUnitId: unitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted || generation != _generation) {
            unawaited(_disposeSafely(banner));
            return;
          }
          if (_availableWidth != width || _availableUnitId != unitId) {
            unawaited(_disposeSafely(banner));
            setState(_reset);
            return;
          }
          if (!_isEligibleNow(unitId)) {
            setState(_reset);
            return;
          }
          _loadTimeout?.cancel();
          _loadTimeout = null;
          setState(() {
            _ad = banner;
            _loadingAd = null;
            _loading = false;
            _failed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          AdDiagnostics.logBannerLoadFailure(
            placement: widget.placement,
            adUnitId: unitId,
            error: error,
          );
          _markFailed(generation, ad is BannerAd ? ad : banner);
        },
      ),
    );
    setState(() {
      _loadingAd = banner;
      _reservedHeight = size.height;
    });
    _loadTimeout?.cancel();
    _loadTimeout = Timer(
      _loadTimeoutDuration,
      () => _markFailed(generation, banner),
    );
    try {
      await banner.load().timeout(_loadTimeoutDuration);
    } catch (_) {
      _markFailed(generation, banner);
    }
  }

  void _markFailed(int generation, [BannerAd? failedAd]) {
    if (!mounted || generation != _generation) {
      unawaited(_disposeSafely(failedAd));
      return;
    }
    _generation++;
    _loadTimeout?.cancel();
    _loadTimeout = null;
    final ad = _ad;
    final loadingAd = _loadingAd;
    setState(() {
      _ad = null;
      _loadingAd = null;
      _reservedHeight = null;
      _loading = false;
      _failed = true;
    });
    unawaited(_disposeSafely(failedAd));
    if (!identical(failedAd, ad)) unawaited(_disposeSafely(ad));
    if (!identical(failedAd, loadingAd) && !identical(ad, loadingAd)) {
      unawaited(_disposeSafely(loadingAd));
    }
  }

  Widget _slot(BuildContext context, {required double height, BannerAd? ad}) {
    final colors = Theme.of(context).colorScheme;
    final content = Center(
      child: SizedBox(
        width: ad?.size.width.toDouble(),
        height: height,
        child: ad == null
            ? null
            : Semantics(
                label: context.l10n.advertisementLabel,
                container: true,
                child: AdWidget(ad: ad),
              ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.symmetric(
          horizontal: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consent = ref.watch(adsConsentControllerProvider);
    final tickerActive = TickerMode.valuesOf(context).enabled;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final unitId = AdUnitConfig.bannerId(widget.placement);
    final eligible =
        consent.adsReady && tickerActive && !keyboardVisible && unitId != null;
    if (!eligible) {
      if (_ad != null ||
          _loadingAd != null ||
          _loading ||
          _failed ||
          _unitId != null) {
        _scheduleResetIfIneligible();
      }
      return const SizedBox.shrink();
    }
    final configuredUnitId = unitId;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
          return const SizedBox.shrink();
        }
        final safePadding = MediaQuery.paddingOf(context);
        final width =
            (constraints.maxWidth - safePadding.left - safePadding.right)
                .floor();
        if (width <= 0) return const SizedBox.shrink();
        _availableWidth = width;
        _availableUnitId = configuredUnitId;
        if (_requestedWidth != width || _unitId != configuredUnitId) {
          _scheduleLoad();
        }
        final ad = _ad;
        if (ad != null) {
          return _slot(context, height: ad.size.height.toDouble(), ad: ad);
        }
        if (_failed) return const SizedBox.shrink();
        return _slot(
          context,
          height: (_reservedHeight ?? (width >= 728 ? 90 : 60)).toDouble(),
        );
      },
    );
  }
}
