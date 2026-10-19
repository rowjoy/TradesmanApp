import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/domain/app_feature.dart';
import '../../features/about/presentation/app_feature_catalog.dart';
import '../../features/ads/application/ad_content_eligibility.dart';
import '../../features/notifications/application/notification_controller.dart';
import '../../features/backup/application/backup_recovery_coordinator.dart';
import '../../features/onboarding/domain/entities/local_profile.dart';
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../features/proof/presentation/controllers/audit_controller.dart';
import '../../features/showcase/presentation/app_showcase.dart';
import '../../features/work/domain/work_models.dart';
import '../../features/work/presentation/controllers/work_controller.dart';
import '../../l10n/l10n.dart';
import '../security/evidence_encryption_migration.dart';
import '../widgets/app_banner_frame.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(
      Future.microtask(
        () => ref.read(notificationControllerProvider.notifier).initialize(),
      ),
    );
    unawaited(
      Future.microtask(
        () => ref.read(backupRecoveryCoordinatorProvider).runIfDue(),
      ),
    );
    unawaited(
      Future.microtask(
        () => ref.read(evidenceEncryptionMigrationProvider).run(),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref
            .read(notificationControllerProvider.notifier)
            .refreshPermissionAndRepair(),
      );
      unawaited(ref.read(backupRecoveryCoordinatorProvider).runIfDue());
      unawaited(ref.read(evidenceEncryptionMigrationProvider).run());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      notificationControllerProvider.select((value) => value.pendingRoute),
      (_, route) {
        if (route == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.go(route);
          ref.read(notificationControllerProvider.notifier).consumeRoute();
        });
      },
    );
    final workFeature = AppFeatureCatalog.forId(AppFeatureId.workPlanning);
    final payFeature = AppFeatureCatalog.forId(AppFeatureId.payAndIncome);
    final recordsFeature = AppFeatureCatalog.forId(AppFeatureId.workRecords);
    final destinations = [
      _Destination(Icons.home_outlined, Icons.home, context.l10n.navHome),
      _Destination(
        Icons.work_outline,
        Icons.work,
        context.l10n.navWork,
        showcaseKey: AppShowcaseKeys.work,
        showcaseTitle: context.l10n.navWork,
        showcaseDescription: workFeature.shortDescription(context.l10n),
      ),
      _Destination(
        Icons.payments_outlined,
        Icons.payments,
        context.l10n.navMoney,
        showcaseKey: AppShowcaseKeys.money,
        showcaseTitle: context.l10n.moneyTitle,
        showcaseDescription: payFeature.shortDescription(context.l10n),
      ),
      _Destination(
        Icons.verified_outlined,
        Icons.verified,
        context.l10n.navProof,
        showcaseKey: AppShowcaseKeys.proof,
        showcaseTitle: context.l10n.showcaseProofTitle,
        showcaseDescription: recordsFeature.shortDescription(context.l10n),
      ),
      _Destination(
        Icons.more_horiz,
        Icons.more,
        context.l10n.navMore,
        showcaseKey: AppShowcaseKeys.more,
        showcaseTitle: context.l10n.settings,
        showcaseDescription:
            '${context.l10n.notificationsTitle} · '
            '${context.l10n.backupRestoreTitle} · '
            '${context.l10n.securityPrivacyTitle}',
        isLastShowcase: true,
      ),
    ];
    final mode = ref.watch(
      currentProfileProvider.select((value) => value?.workMode),
    );
    final proofHasContent = hasPublisherContent(ref.watch(auditEventsProvider));
    final currentIndex = widget.navigationShell.currentIndex;
    final workHasContent = currentIndex != 1
        ? true
        : switch (ref.watch(selectedWorkFlowProvider)) {
            WorkFlow.worker => hasPublisherContent(ref.watch(shiftsProvider)),
            WorkFlow.tradesman => hasPublisherContent(
              ref.watch(workJobsProvider),
            ),
          };
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 840;
        if (useRail) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    extended: constraints.maxWidth >= 1120,
                    selectedIndex: widget.navigationShell.currentIndex,
                    onDestinationSelected: _onTap,
                    leading: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _BrandMark(extended: constraints.maxWidth >= 1120),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: _ModeLabel(mode: mode),
                    ),
                    destinations: [
                      for (final destination in destinations)
                        NavigationRailDestination(
                          icon: _DestinationIcon(destination: destination),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: MainShellBannerRegion(
                      currentIndex: widget.navigationShell.currentIndex,
                      proofHasContent: proofHasContent,
                      workHasContent: workHasContent,
                      keyboardVisible: keyboardVisible,
                      child: widget.navigationShell,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: MainShellBannerRegion(
            currentIndex: widget.navigationShell.currentIndex,
            proofHasContent: proofHasContent,
            workHasContent: workHasContent,
            keyboardVisible: keyboardVisible,
            child: widget.navigationShell,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            destinations: [
              for (final destination in destinations)
                NavigationDestination(
                  icon: _DestinationIcon(destination: destination),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class MainShellBannerRegion extends StatelessWidget {
  const MainShellBannerRegion({
    required this.currentIndex,
    required this.proofHasContent,
    required this.workHasContent,
    required this.keyboardVisible,
    required this.child,
    super.key,
  });

  final int currentIndex;
  final bool proofHasContent;
  final bool workHasContent;
  final bool keyboardVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enabled =
        !keyboardVisible &&
        (currentIndex == 0 ||
            (currentIndex == 1 && workHasContent) ||
            currentIndex == 2 ||
            (currentIndex == 3 && proofHasContent));
    return AppBannerFrame(
      placement: AdPlacement.appShell,
      enabled: enabled,
      child: child,
    );
  }
}

class _Destination {
  const _Destination(
    this.icon,
    this.selectedIcon,
    this.label, {
    this.showcaseKey,
    this.showcaseTitle,
    this.showcaseDescription,
    this.isLastShowcase = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final GlobalKey? showcaseKey;
  final String? showcaseTitle;
  final String? showcaseDescription;
  final bool isLastShowcase;
}

class _DestinationIcon extends StatelessWidget {
  const _DestinationIcon({required this.destination});

  final _Destination destination;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(destination.icon);
    final key = destination.showcaseKey;
    if (key == null) return icon;
    return AppShowcase(
      showcaseKey: key,
      title: destination.showcaseTitle!,
      description: destination.showcaseDescription!,
      isLast: destination.isLastShowcase,
      targetBorderRadius: BorderRadius.circular(24),
      child: icon,
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.verified_user_outlined),
      if (extended) ...[
        const SizedBox(width: 10),
        Text(
          context.l10n.appTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    ],
  );
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({required this.mode});

  final WorkMode? mode;

  @override
  Widget build(BuildContext context) {
    final label = switch (mode) {
      WorkMode.worker => context.l10n.profileModeWorker,
      WorkMode.tradesman => context.l10n.profileModeTradesman,
      WorkMode.both => context.l10n.profileModeBoth,
      null => context.l10n.localOnlyStatus,
    };
    return Tooltip(
      message: label,
      child: const Icon(Icons.offline_pin_outlined),
    );
  }
}
