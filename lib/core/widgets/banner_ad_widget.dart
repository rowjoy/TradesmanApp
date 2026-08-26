import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../features/ads/application/ads_consent_controller.dart';
import '../../features/ads/infrastructure/ad_unit_config.dart';
import '../../l10n/l10n.dart';

export '../../features/ads/infrastructure/ad_unit_config.dart' show AdPlacement;

/// A consent-aware, route-owned top banner.
///
/// The widget is only placed on browse/report surfaces. It collapses on no-fill,
/// missing production configuration, unsupported platforms, or denied consent.
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key, this.placement = AdPlacement.dashboard});

  final AdPlacement placement;

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _ad;
  int? _requestedWidth;
  bool _loading = false;
  bool _failed = false;

  @override
  void dispose() {
    unawaited(_ad?.dispose());
    super.dispose();
  }

  void _clear() {
    final ad = _ad;
    _ad = null;
    _requestedWidth = null;
    _loading = false;
    if (ad != null) unawaited(ad.dispose());
  }

  Future<void> _load(int width) async {
    if (_loading || _failed || width <= 0 || _requestedWidth == width) return;
    final unitId = AdUnitConfig.bannerId(widget.placement);
    if (unitId == null) return;
    final old = _ad;
    setState(() {
      _loading = true;
      _requestedWidth = width;
      _ad = null;
    });
    if (old != null) await old.dispose();
    final adaptive =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted) return;
    final size = adaptive ?? AdSize.banner;
    late final BannerAd banner;
    banner = BannerAd(
      adUnitId: unitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) {
            unawaited(banner.dispose());
            return;
          }
          setState(() {
            _ad = banner;
            _loading = false;
          });
        },
        onAdFailedToLoad: (ad, _) {
          unawaited(ad.dispose());
          if (!mounted) return;
          setState(() {
            _ad = null;
            _loading = false;
            _failed = true;
          });
        },
      ),
    );
    banner.load();
  }

  @override
  Widget build(BuildContext context) {
    final consent = ref.watch(adsConsentControllerProvider);
    if (!consent.adsReady) {
      if (_ad != null || _loading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(_clear);
        });
      }
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floor();
        final configured = AdUnitConfig.bannerId(widget.placement) != null;
        if (!_loading && !_failed && _requestedWidth != width) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(_load(width));
          });
        }
        final ad = _ad;
        if (ad == null) {
          return configured && !_failed
              ? SizedBox(height: width >= 728 ? 90 : 60)
              : const SizedBox.shrink();
        }
        return Semantics(
          label: context.l10n.advertisementLabel,
          container: true,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: SizedBox(
                width: ad.size.width.toDouble(),
                height: ad.size.height.toDouble(),
                child: AdWidget(ad: ad),
              ),
            ),
          ),
        );
      },
    );
  }
}
