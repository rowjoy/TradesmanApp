import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/live_second_builder.dart';
import '../../l10n/l10n.dart';
import '../jobs/job_model.dart';
import '../onboarding/domain/entities/local_profile.dart';
import '../onboarding/presentation/controllers/onboarding_controller.dart';
import '../showcase/presentation/guided_showcase.dart';
import '../showcase/presentation/app_showcase.dart';
import '../time_tracking/time_entry_model.dart';
import '../time_tracking/time_tracking_provider.dart';
import '../work/domain/work_models.dart';
import '../work/presentation/controllers/work_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileMode =
        ref.watch(
          currentProfileProvider.select((profile) => profile?.workMode),
        ) ??
        WorkMode.tradesman;
    final flow = ref.watch(selectedWorkFlowProvider);
    final worker = flow == WorkFlow.worker;
    final data = worker
        ? ref.watch(dashboardShiftsProvider)
        : ref.watch(dashboardJobsProvider);
    return Module03ShowcaseGate(
      mode: profileMode,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.dashboardTitle),
          actions: [
            IconButton(
              tooltip: context.l10n.settings,
              onPressed: () => context.go(AppRoutes.more),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (worker) {
              ref.invalidate(dashboardShiftsProvider);
              await ref.read(dashboardShiftsProvider.future);
            } else {
              ref.invalidate(dashboardJobsProvider);
              await ref.read(dashboardJobsProvider.future);
            }
          },
          child: ListView(
            key: PageStorageKey('dashboard-${flow.name}'),
            cacheExtent: 1600,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (profileMode == WorkMode.both)
                SegmentedButton<WorkFlow>(
                  segments: [
                    ButtonSegment(
                      value: WorkFlow.worker,
                      label: Text(context.l10n.workerFlow),
                    ),
                    ButtonSegment(
                      value: WorkFlow.tradesman,
                      label: Text(context.l10n.tradesmanFlow),
                    ),
                  ],
                  selected: {flow},
                  onSelectionChanged: (value) =>
                      ref.read(selectedWorkFlowProvider.notifier).state =
                          value.first,
                ),
              const SizedBox(height: 12),
              const _ActiveTimerCard(),
              const SizedBox(height: 16),
              AppShowcase(
                showcaseKey: AppShowcaseKeys.workPlan,
                title: context.l10n.showcasePlanTitle,
                description: profileMode == WorkMode.worker
                    ? context.l10n.showcaseWorkerPlanBody
                    : profileMode == WorkMode.tradesman
                    ? context.l10n.showcaseTradesmanPlanBody
                    : context.l10n.showcaseBothPlanBody,
                isFirst: true,
                child: data.when(
                  data: (items) => _TodaySummary(
                    count: items.length,
                    label: worker
                        ? context.l10n.shiftsLabel
                        : context.l10n.jobsLabel,
                  ),
                  loading: () => const _LoadingCard(),
                  error: (_, __) => const _LoadingCard(),
                ),
              ),
              const SizedBox(height: 16),
              AppShowcase(
                showcaseKey: AppShowcaseKeys.createWork,
                title: worker ? context.l10n.newShift : context.l10n.newJob,
                description: worker
                    ? '${context.l10n.employers} · ${context.l10n.scheduleTitle} · '
                          '${context.l10n.saveShift}'
                    : '${context.l10n.customers} · ${context.l10n.scheduleTitle} · '
                          '${context.l10n.saveJob}',
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.add_task,
                        label: worker
                            ? context.l10n.newShift
                            : context.l10n.newJob,
                        onTap: () => context.push(
                          worker ? AppRoutes.newShift : AppRoutes.newJob,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.person_add_alt,
                        label: worker
                            ? context.l10n.newEmployer
                            : context.l10n.newCustomer,
                        onTap: () => context.push(
                          worker
                              ? AppRoutes.newEmployer
                              : AppRoutes.newCustomer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.calendar_month_outlined,
                        label: context.l10n.calendarTitle,
                        onTap: () => context.push(AppRoutes.calendarFor(flow)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.todayWork,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.work),
                    child: Text(context.l10n.seeAll),
                  ),
                ],
              ),
              AppShowcase(
                showcaseKey: AppShowcaseKeys.workFlow,
                title: context.l10n.todayWork,
                description:
                    '${context.l10n.trackTime} · ${context.l10n.clockIn} · '
                    '${context.l10n.clockOut} · ${context.l10n.proofTitle}',
                child: data.when(
                  data: (items) => items.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              worker
                                  ? context.l10n.noShifts
                                  : context.l10n.noJobs,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (final item in items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: worker
                                    ? _ShiftRow(shift: item as WorkerShift)
                                    : _JobRow(job: item as Job),
                              ),
                          ],
                        ),
                  loading: () => const Column(
                    children: [
                      AppCardSkeleton(),
                      SizedBox(height: 8),
                      AppCardSkeleton(),
                      SizedBox(height: 8),
                      AppCardSkeleton(),
                    ],
                  ),
                  error: (_, __) => Text(context.l10n.workLoadFailed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveTimerCard extends ConsumerWidget {
  const _ActiveTimerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(activeTimeEntryProvider).valueOrNull;
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: entry == null
          ? const SizedBox(width: double.infinity)
          : _LiveActiveTimerCard(key: ValueKey(entry.id), entry: entry),
    );
  }
}

class _LiveActiveTimerCard extends StatelessWidget {
  const _LiveActiveTimerCard({super.key, required this.entry});

  final TimeEntry entry;

  @override
  Widget build(BuildContext context) => LiveSecondBuilder(
    builder: (context, now) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: ListTile(
          onTap: () => context.push(_routeFor(entry.workItem)),
          leading: const Icon(Icons.timer_outlined),
          title: Text(context.l10n.activeTimer),
          subtitle: Text(
            '${entry.isOnBreak ? context.l10n.onBreak : context.l10n.timerRunning} · ${_timerText(entry.workedDurationAt(now))}',
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    ),
  );

  String _routeFor(WorkItemReference work) => work.type == TrackedWorkType.job
      ? AppRoutes.job(work.id)
      : AppRoutes.shift(work.id);

  String _timerText(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            child: Icon(Icons.today_outlined),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ShiftRow extends StatelessWidget {
  const _ShiftRow({required this.shift});
  final WorkerShift shift;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: () => context.push(AppRoutes.shift(shift.id)),
      leading: const Icon(Icons.badge_outlined),
      title: Text(shift.title),
      subtitle: Text(
        '${AppFormatters.time(shift.schedule.startLocal)}–${AppFormatters.time(shift.schedule.endLocal)} · ${shift.schedule.ianaTimeZone}',
      ),
    ),
  );
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: () => context.push(AppRoutes.job(job.id)),
      leading: const Icon(Icons.handyman_outlined),
      title: Text(job.title),
      subtitle: Text(
        job.schedule == null
            ? context.l10n.notScheduled
            : '${AppFormatters.time(job.schedule!.startLocal)}–${AppFormatters.time(job.schedule!.endLocal)} · ${job.schedule!.ianaTimeZone}',
      ),
    ),
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    ),
  );
}
