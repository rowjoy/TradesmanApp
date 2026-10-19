import 'dart:async';

import 'package:flutter/material.dart';

typedef LiveSecondWidgetBuilder =
    Widget Function(BuildContext context, DateTime nowUtc);

/// A lifecycle- and TickerMode-aware one-second clock.
///
/// It stops while the app or an indexed tab is inactive, and contains repaint
/// work to its own subtree.
class LiveSecondBuilder extends StatefulWidget {
  const LiveSecondBuilder({super.key, required this.builder});

  final LiveSecondWidgetBuilder builder;

  @override
  State<LiveSecondBuilder> createState() => _LiveSecondBuilderState();
}

class _LiveSecondBuilderState extends State<LiveSecondBuilder>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _tickerModeEnabled = true;
  DateTime _nowUtc = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerModeEnabled = TickerMode.valuesOf(context).enabled;
    _syncTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _syncTimer();

  bool get _shouldRun {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return _tickerModeEnabled &&
        (lifecycle == null || lifecycle == AppLifecycleState.resumed);
  }

  void _syncTimer() {
    if (!_shouldRun) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _nowUtc = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(child: widget.builder(context, _nowUtc));
}
