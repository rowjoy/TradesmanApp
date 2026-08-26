import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/application/notification_controller.dart';
import '../../features/ads/application/ads_consent_controller.dart';
import '../../features/backup/application/backup_recovery_coordinator.dart';
import '../../features/onboarding/domain/entities/local_profile.dart';
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../features/showcase/presentation/app_showcase.dart';
import '../../l10n/l10n.dart';
import '../security/evidence_encryption_migration.dart';

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
    unawaited(
      Future.microtask(
        () => ref.read(adsConsentControllerProvider.notifier).initialize(),
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
    final destinations = [
      _Destination(Icons.home_outlined, Icons.home, context.l10n.navHome),
      _Destination(
        Icons.work_outline,
        Icons.work,
        context.l10n.navWork,
        showcaseKey: AppShowcaseKeys.work,
        showcaseTitle: context.l10n.navWork,
        showcaseDescription:
            '${context.l10n.jobsLabel} · ${context.l10n.shiftsLabel} · '
            '${context.l10n.peopleTitle} · ${context.l10n.calendarTitle}',
      ),
      _Destination(
        Icons.payments_outlined,
        Icons.payments,
        context.l10n.navMoney,
        showcaseKey: AppShowcaseKeys.money,
        showcaseTitle: context.l10n.moneyTitle,
        showcaseDescription:
            '${context.l10n.moneyExpected} · ${context.l10n.m05Received} · '
            '${context.l10n.reportsTitle}',
      ),
      _Destination(
        Icons.verified_outlined,
        Icons.verified,
        context.l10n.navProof,
        showcaseKey: AppShowcaseKeys.proof,
        showcaseTitle: context.l10n.showcaseProofTitle,
        showcaseDescription: context.l10n.showcaseProofBody,
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
                  Expanded(child: widget.navigationShell),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: widget.navigationShell,
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
