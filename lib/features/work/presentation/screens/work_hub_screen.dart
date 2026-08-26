import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../../jobs/job_model.dart';
import '../../../jobs/job_provider.dart';
import '../../../notifications/application/notification_controller.dart';
import '../../../onboarding/domain/entities/local_profile.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../../proof/presentation/controllers/audit_controller.dart';
import '../../data/work_repository.dart';
import '../../domain/work_models.dart';
import '../controllers/work_controller.dart';

class WorkHubScreen extends ConsumerStatefulWidget {
  const WorkHubScreen({super.key});

  @override
  ConsumerState<WorkHubScreen> createState() => _WorkHubScreenState();
}

class _WorkHubScreenState extends ConsumerState<WorkHubScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(workListSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _queueSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      ref.read(workListSearchQueryProvider.notifier).state = value.trim();
      ref.read(workPageLimitProvider.notifier).state = 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode =
        ref.watch(
          currentProfileProvider.select((profile) => profile?.workMode),
        ) ??
        WorkMode.tradesman;
    final flow = ref.watch(selectedWorkFlowProvider);
    final isWorker = flow == WorkFlow.worker;
    final data = isWorker
        ? ref.watch(shiftsProvider)
        : ref.watch(workJobsProvider);
    final pageLimit = ref.watch(workPageLimitProvider);
    final shiftFilter = ref.watch(shiftStatusFilterProvider);
    final jobFilter = ref.watch(jobStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.workTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.peopleTitle,
            onPressed: () => context.push(AppRoutes.peopleFor(flow)),
            icon: const Icon(Icons.groups_outlined),
          ),
          IconButton(
            tooltip: context.l10n.calendarTitle,
            onPressed: () => context.push(AppRoutes.calendarFor(flow)),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_work_hub',
        onPressed: () =>
            context.push(isWorker ? AppRoutes.newShift : AppRoutes.newJob),
        icon: const Icon(Icons.add),
        label: Text(isWorker ? context.l10n.newShift : context.l10n.newJob),
      ),
      body: Column(
        children: [
          const BannerAdWidget(placement: AdPlacement.work),
          if (mode == WorkMode.both)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<WorkFlow>(
                  segments: [
                    ButtonSegment(
                      value: WorkFlow.worker,
                      icon: const Icon(Icons.badge_outlined),
                      label: Text(context.l10n.workerFlow),
                    ),
                    ButtonSegment(
                      value: WorkFlow.tradesman,
                      icon: const Icon(Icons.handyman_outlined),
                      label: Text(context.l10n.tradesmanFlow),
                    ),
                  ],
                  selected: {flow},
                  onSelectionChanged: (value) {
                    _searchDebounce?.cancel();
                    _searchController.clear();
                    ref.read(selectedWorkFlowProvider.notifier).state =
                        value.first;
                    ref.read(workListSearchQueryProvider.notifier).state = '';
                    ref.read(workPageLimitProvider.notifier).state = 50;
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: isWorker
                    ? context.l10n.searchShifts
                    : context.l10n.searchJobs,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _queueSearch,
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: context.l10n.filterAll,
                  selected: isWorker
                      ? shiftFilter == null
                      : jobFilter == null,
                  onSelected: () {
                    if (isWorker) {
                      ref.read(shiftStatusFilterProvider.notifier).state = null;
                    } else {
                      ref.read(jobStatusFilterProvider.notifier).state = null;
                    }
                  },
                ),
                _FilterChip(
                  label: context.l10n.statusScheduled,
                  selected: isWorker
                      ? shiftFilter == WorkItemStatus.scheduled
                      : jobFilter == JobStatus.scheduled,
                  onSelected: () {
                    if (isWorker) {
                      ref.read(shiftStatusFilterProvider.notifier).state =
                          WorkItemStatus.scheduled;
                    } else {
                      ref.read(jobStatusFilterProvider.notifier).state =
                          JobStatus.scheduled;
                    }
                  },
                ),
                _FilterChip(
                  label: context.l10n.statusCompleted,
                  selected: isWorker
                      ? shiftFilter == WorkItemStatus.completed
                      : jobFilter == JobStatus.completed,
                  onSelected: () {
                    if (isWorker) {
                      ref.read(shiftStatusFilterProvider.notifier).state =
                          WorkItemStatus.completed;
                    } else {
                      ref.read(jobStatusFilterProvider.notifier).state =
                          JobStatus.completed;
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: data.when(
              data: (items) => items.isEmpty
                  ? _EmptyWork(flow: flow)
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (isWorker) {
                          ref.invalidate(shiftsProvider);
                          await ref.read(shiftsProvider.future);
                        } else {
                          ref.invalidate(workJobsProvider);
                          await ref.read(workJobsProvider.future);
                        }
                      },
                      child: ListView.separated(
                        key: PageStorageKey('work-hub-${flow.name}'),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                        itemCount:
                            items.length + (items.length >= pageLimit ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == items.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    ref
                                            .read(
                                              workPageLimitProvider.notifier,
                                            )
                                            .state +=
                                        50,
                                icon: const Icon(Icons.expand_more),
                                label: Text(context.l10n.loadMore),
                              ),
                            );
                          }
                          return isWorker
                              ? _ShiftCard(shift: items[index] as WorkerShift)
                              : _JobCard(job: items[index] as Job);
                        },
                      ),
                    ),
              loading: () => const AppListSkeleton(),
              error: (_, __) => _ErrorState(
                onRetry: () => isWorker
                    ? ref.invalidate(shiftsProvider)
                    : ref.invalidate(workJobsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftCard extends ConsumerWidget {
  const _ShiftCard({required this.shift});
  final WorkerShift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      leading: const CircleAvatar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: Icon(Icons.badge_outlined),
      ),
      title: Text(
        shift.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        _scheduleLabel(
          shift.schedule.startLocal,
          shift.schedule.endLocal,
          shift.schedule.ianaTimeZone,
        ),
      ),
      onTap: () => context.push(AppRoutes.shift(shift.id)),
      trailing: Wrap(
        spacing: 2,
        children: [
          IconButton(
            tooltip: context.l10n.editLabel,
            onPressed: () => context.push(AppRoutes.editShift(shift.id)),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: context.l10n.deleteLabel,
            onPressed: () async {
              if (!await _confirmDelete(context)) return;
              await ref.read(workRepositoryProvider).softDelete(
                table: 'shifts',
                entityType: 'shift',
                id: shift.id,
              );
              invalidateWorkData(ref, flow: WorkFlow.worker);
              ref.invalidate(auditEventsProvider);
              unawaited(
                ref.read(notificationControllerProvider.notifier).reconcile(),
              );
              if (context.mounted) {
                AppFeedback.success(context, context.l10n.recordDeleted);
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    ),
  );
}

class _JobCard extends ConsumerWidget {
  const _JobCard({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = job.schedule;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: const CircleAvatar(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          child: Icon(Icons.handyman_outlined),
        ),
        title: Text(
          job.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          schedule == null
              ? context.l10n.notScheduled
              : _scheduleLabel(
                  schedule.startLocal,
                  schedule.endLocal,
                  schedule.ianaTimeZone,
                ),
        ),
        onTap: () => context.push(AppRoutes.job(job.id)),
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              tooltip: context.l10n.editLabel,
              onPressed: () => context.push(AppRoutes.editJob(job.id)),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: context.l10n.deleteLabel,
              onPressed: () async {
                if (!await _confirmDelete(context)) return;
                await ref.read(jobRepositoryProvider).softDelete(job.id);
                invalidateWorkData(ref, flow: WorkFlow.tradesman);
                ref.invalidate(auditEventsProvider);
                unawaited(
                  ref
                      .read(notificationControllerProvider.notifier)
                      .reconcile(),
                );
                if (context.mounted) {
                  AppFeedback.success(context, context.l10n.recordDeleted);
                }
              },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    ),
  );
}

class _EmptyWork extends StatelessWidget {
  const _EmptyWork({required this.flow});
  final WorkFlow flow;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            flow == WorkFlow.worker
                ? Icons.event_available
                : Icons.home_repair_service,
            size: 54,
          ),
          const SizedBox(height: 12),
          Text(
            flow == WorkFlow.worker
                ? context.l10n.noShifts
                : context.l10n.noJobs,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.workLoadFailed),
        TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
      ],
    ),
  );
}

String _scheduleLabel(DateTime start, DateTime end, String zone) {
  final sameDay =
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  if (sameDay) {
    return '${AppFormatters.date(start)} · ${AppFormatters.time(start)}–${AppFormatters.time(end)} · $zone';
  }
  return '${AppFormatters.date(start)} ${AppFormatters.time(start)} → '
      '${AppFormatters.date(end)} ${AppFormatters.time(end)} · $zone';
}

Future<bool> _confirmDelete(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteWorkTitle),
        content: Text(context.l10n.deleteWorkDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.deleteLabel),
          ),
        ],
      ),
    ) ??
    false;
