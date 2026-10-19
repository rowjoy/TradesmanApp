import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../l10n/l10n.dart';

abstract final class AppShowcaseIds {
  static const timeTracking = 'full_app_v5';
  static const payProtection = 'pay_protection_v2';
}

abstract final class AppShowcaseKeys {
  static final workPlan = GlobalKey(debugLabel: 'showcase-work-plan');
  static final createWork = GlobalKey(debugLabel: 'showcase-create-work');
  static final workFlow = GlobalKey(debugLabel: 'showcase-work-flow');
  static final work = GlobalKey(debugLabel: 'showcase-work');
  static final money = GlobalKey(debugLabel: 'showcase-money');
  static final proof = GlobalKey(debugLabel: 'showcase-proof');
  static final more = GlobalKey(debugLabel: 'showcase-more');

  static List<GlobalKey> get timeTracking => [
    workPlan,
    createWork,
    workFlow,
    work,
    money,
    proof,
    more,
  ];
}

/// Owns the one ShowcaseView 5.x registration used by all indexed tabs.
class AppShowcaseCoordinator {
  AppShowcaseCoordinator._();

  static final instance = AppShowcaseCoordinator._();

  FutureOr<void> Function()? _onComplete;
  bool _completing = false;
  bool _registered = false;
  final ValueNotifier<bool> _activity = ValueNotifier<bool>(false);
  int _startToken = 0;

  bool get isActive => _activity.value;
  ValueListenable<bool> get activity => _activity;

  void _setActive(bool value) {
    if (_activity.value == value) return;
    _activity.value = value;
  }

  void register() {
    if (_registered) return;
    ShowcaseView.register(
      blurValue: 1.2,
      enableAutoScroll: true,
      disableMovingAnimation: true,
      semanticEnable: true,
      onFinish: _complete,
      onDismiss: (_) => _complete(),
    );
    _registered = true;
  }

  bool start({
    required List<GlobalKey> keys,
    required FutureOr<void> Function() onComplete,
  }) {
    if (!_registered || keys.isEmpty || isActive) return false;
    _setActive(true);
    _onComplete = onComplete;
    final token = ++_startToken;
    _startWhenReady(keys, token: token, attempt: 0);
    return true;
  }

  void _startWhenReady(
    List<GlobalKey> keys, {
    required int token,
    required int attempt,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isActive || token != _startToken) return;
      final ready = keys.where(_targetIsReady).toList(growable: false);
      if (ready.length == keys.length || attempt >= 12) {
        if (ready.isEmpty) {
          _setActive(false);
          _onComplete = null;
          return;
        }
        ShowcaseView.get().startShowCase(ready);
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        if (!isActive || token != _startToken) return;
        _startWhenReady(keys, token: token, attempt: attempt + 1);
      });
    });
  }

  bool _targetIsReady(GlobalKey key) {
    return ShowcaseView.get().isTargetRendered(key);
  }

  void finish() {
    if (!_registered) return;
    _startToken++;
    ShowcaseView.get().dismiss();
    unawaited(_complete());
  }

  Future<void> _complete() async {
    if (_completing) return;
    final callback = _onComplete;
    _onComplete = null;
    _setActive(false);
    _startToken++;
    if (callback == null) return;
    _completing = true;
    try {
      await callback();
    } finally {
      _completing = false;
    }
  }
}

/// Localized, reusable ShowcaseView target based on the supplied sample.
class AppShowcase extends StatelessWidget {
  const AppShowcase({
    required this.showcaseKey,
    required this.title,
    required this.description,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
    this.targetPadding = const EdgeInsets.all(5),
    this.targetBorderRadius = const BorderRadius.all(Radius.circular(16)),
    super.key,
  });

  final GlobalKey showcaseKey;
  final String title;
  final String description;
  final Widget child;
  final bool isFirst;
  final bool isLast;
  final EdgeInsets targetPadding;
  final BorderRadius targetBorderRadius;

  @override
  Widget build(BuildContext context) => Showcase(
    key: showcaseKey,
    title: title,
    description: description,
    targetPadding: targetPadding,
    targetBorderRadius: targetBorderRadius,
    tooltipBackgroundColor: const Color(0xFF123C3B),
    textColor: Colors.white,
    tooltipActions: [
      TooltipActionButton(
        type: TooltipDefaultActionType.skip,
        name: context.l10n.skipShowcase,
        textStyle: const TextStyle(color: Colors.white70),
      ),
      if (!isFirst)
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          name: context.l10n.backLabel,
          textStyle: const TextStyle(color: Colors.white),
        ),
      TooltipActionButton(
        type: TooltipDefaultActionType.next,
        name: isLast ? context.l10n.gotIt : context.l10n.nextLabel,
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        onTap: isLast ? AppShowcaseCoordinator.instance.finish : null,
      ),
    ],
    child: child,
  );
}
