import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BannerOverlayController extends ChangeNotifier {
  final Map<Route<dynamic>, int> _blockingRouteRefCounts =
      <Route<dynamic>, int>{};

  bool get hasBlockingOverlay => _blockingRouteRefCounts.isNotEmpty;

  NavigatorObserver createObserver() => _BannerOverlayObserver(this);

  void _update(void Function() mutation) {
    final wasBlocking = hasBlockingOverlay;
    mutation();
    if (wasBlocking != hasBlockingOverlay) notifyListeners();
  }

  void _add(Route<dynamic> route) {
    if (route is! PopupRoute<dynamic>) return;
    _blockingRouteRefCounts.update(
      route,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  void _remove(Route<dynamic>? route) {
    if (route is! PopupRoute<dynamic>) return;
    final count = _blockingRouteRefCounts[route];
    if (count == null) return;
    if (count <= 1) {
      _blockingRouteRefCounts.remove(route);
    } else {
      _blockingRouteRefCounts[route] = count - 1;
    }
  }

  @override
  void dispose() {
    _blockingRouteRefCounts.clear();
    super.dispose();
  }
}

class _BannerOverlayObserver extends NavigatorObserver {
  _BannerOverlayObserver(this._controller);

  final BannerOverlayController _controller;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _controller._update(() => _controller._add(route));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _controller._update(() => _controller._remove(route));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _controller._update(() => _controller._remove(route));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _controller._update(() {
      _controller._remove(oldRoute);
      if (newRoute != null) _controller._add(newRoute);
    });
  }
}

final bannerOverlayControllerProvider =
    ChangeNotifierProvider<BannerOverlayController>((ref) {
      return BannerOverlayController();
    });
