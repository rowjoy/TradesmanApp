import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/entities/local_profile.dart';
import '../../time_tracking/time_tracking_provider.dart';
import '../data/showcase_repository.dart';
import 'app_showcase.dart';

/// Shows a localized one-step guide the first time a routed screen is opened.
///
/// Screens with multi-step task guides use their own targets instead.
class FirstVisitScreenShowcase extends ConsumerStatefulWidget {
  const FirstVisitScreenShowcase({
    super.key,
    required this.screenId,
    required this.title,
    required this.description,
    required this.child,
  });

  final String screenId;
  final String title;
  final String description;
  final Widget child;

  @override
  ConsumerState<FirstVisitScreenShowcase> createState() =>
      _FirstVisitScreenShowcaseState();
}

class _FirstVisitScreenShowcaseState
    extends ConsumerState<FirstVisitScreenShowcase> {
  final _targetKey = GlobalKey();
  bool _checked = false;
  bool _showTarget = false;
  bool _startQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didUpdateWidget(covariant FirstVisitScreenShowcase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenId != widget.screenId) {
      _checked = false;
      _showTarget = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  Future<void> _check() async {
    if (!mounted || _checked) return;
    _checked = true;
    final completed = await ref
        .read(showcaseRepositoryProvider)
        .isScreenGuideCompleted(widget.screenId);
    if (!mounted || completed) return;
    setState(() => _showTarget = true);
    _queueStart();
  }

  void _queueStart() {
    if (!mounted || !_showTarget || _startQueued) return;
    _startQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQueued = false;
      if (!mounted || !_showTarget) return;
      final started = AppShowcaseCoordinator.instance.start(
        keys: [_targetKey],
        onComplete: _complete,
      );
      if (!started) {
        Future<void>.delayed(const Duration(milliseconds: 350), _queueStart);
      }
    });
  }

  Future<void> _complete() async {
    await ref
        .read(showcaseRepositoryProvider)
        .completeScreenGuide(widget.screenId);
    if (mounted) setState(() => _showTarget = false);
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      widget.child,
      if (_showTarget)
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 8,
          end: 12,
          child: AppShowcase(
            showcaseKey: _targetKey,
            title: widget.title,
            description: widget.description,
            isFirst: true,
            isLast: true,
            targetPadding: const EdgeInsets.all(3),
            targetBorderRadius: BorderRadius.circular(24),
            child: Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _queueStart,
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.tips_and_updates_outlined, size: 20),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

/// Starts the seven-target Home and primary-navigation tour after rendering.
///
/// An active timer blocks automatic and replay flows, so the guide never
/// covers a time-critical Clock In/Out action.
class Module03ShowcaseGate extends ConsumerStatefulWidget {
  const Module03ShowcaseGate({
    super.key,
    required this.mode,
    required this.child,
  });

  final WorkMode mode;
  final Widget child;

  @override
  ConsumerState<Module03ShowcaseGate> createState() =>
      _Module03ShowcaseGateState();
}

class _Module03ShowcaseGateState extends ConsumerState<Module03ShowcaseGate> {
  bool _startQueued = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(module03ShowcaseReplayRequestProvider, (_, __) {
      _queueStart(force: true);
    });

    final completed = ref.watch(module03ShowcaseCompletedProvider);
    final active = ref.watch(activeTimeEntryProvider);
    if (completed.asData?.value == false && active.asData?.value == null) {
      _queueStart();
    }
    return widget.child;
  }

  void _queueStart({bool force = false}) {
    if (_startQueued) return;
    _startQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _startQueued = false;
      if (!mounted) return;
      final active = await ref.read(activeTimeEntryProvider.future);
      if (!mounted || active != null) return;
      if (!force) {
        final completed = await ref
            .read(showcaseRepositoryProvider)
            .isModule03Completed();
        if (!mounted || completed) return;
      }
      AppShowcaseCoordinator.instance.start(
        keys: AppShowcaseKeys.timeTracking,
        onComplete: () async {
          await ref.read(showcaseRepositoryProvider).completeModule03();
          ref.invalidate(module03ShowcaseCompletedProvider);
        },
      );
    });
  }
}
