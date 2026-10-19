import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/money/money.dart';
import '../../core/money/work_earnings_calculator.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/inline_animated_picker.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/live_second_builder.dart';
import '../../l10n/l10n.dart';
import '../jobs/job_model.dart';
import '../jobs/job_provider.dart';
import '../app_review/application/app_review_providers.dart';
import '../customers/customer_provider.dart';
import '../money/presentation/controllers/money_summary_controller.dart';
import '../notifications/application/notification_controller.dart';
import '../onboarding/presentation/controllers/onboarding_controller.dart';
import '../proof/presentation/controllers/audit_controller.dart';
import '../reports/application/report_controller.dart';
import '../reports/infrastructure/report_export_service.dart';
import '../security/application/app_lock_controller.dart';
import '../showcase/data/showcase_repository.dart';
import '../showcase/presentation/app_showcase.dart';
import '../work/data/work_repository.dart';
import '../work/domain/work_models.dart';
import '../work/presentation/controllers/work_controller.dart';
import 'time_entry_model.dart';
import 'time_tracking_provider.dart';

class ClockScreen extends ConsumerStatefulWidget {
  const ClockScreen({super.key, required this.workItem});

  final WorkItemReference workItem;

  @override
  ConsumerState<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends ConsumerState<ClockScreen> {
  final _workGuideKey = GlobalKey();
  final _timerGuideKey = GlobalKey();
  final _pdfGuideKey = GlobalKey();
  late Future<_WorkDescriptor?> _workFuture;
  bool _busy = false;
  bool _sharingWork = false;
  bool _startedHere = false;
  int _overtimeHours = 8;
  double _overtimeMultiplier = 1.5;
  double _premiumMultiplier = 1;
  int _roundingMinutes = 1;
  int _extraPayMinor = 0;
  bool _guideQueued = false;

  @override
  void initState() {
    super.initState();
    _workFuture = _loadWork();
  }

  Future<_WorkDescriptor?> _loadWork() async {
    if (widget.workItem.type == TrackedWorkType.job) {
      final job = await ref
          .read(jobRepositoryProvider)
          .getById(widget.workItem.id);
      return job == null ? null : _WorkDescriptor.fromJob(job);
    }
    final shift = await ref
        .read(workRepositoryProvider)
        .shift(widget.workItem.id);
    return shift == null ? null : _WorkDescriptor.fromShift(shift);
  }

  void _queueGuide() {
    if (_guideQueued) return;
    _guideQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _guideQueued = false;
      if (!mounted) return;
      final screenId = widget.workItem.type == TrackedWorkType.job
          ? 'job_workflow'
          : 'shift_workflow';
      final repository = ref.read(showcaseRepositoryProvider);
      if (await repository.isScreenGuideCompleted(screenId)) return;
      if (!mounted) return;
      final keys = <GlobalKey>[_workGuideKey, _timerGuideKey];
      if (widget.workItem.type == TrackedWorkType.job) keys.add(_pdfGuideKey);
      final started = AppShowcaseCoordinator.instance.start(
        keys: keys,
        onComplete: () => repository.completeScreenGuide(screenId),
      );
      if (!started) {
        Future<void>.delayed(const Duration(milliseconds: 350), _queueGuide);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeTimeEntryProvider);
    final latestAsync = ref.watch(
      latestCompletedTimeEntryProvider(widget.workItem),
    );
    final historyAsync = ref.watch(timeEntryHistoryProvider(widget.workItem));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workItem.type == TrackedWorkType.job
              ? context.l10n.jobTimerTitle
              : context.l10n.shiftTimerTitle,
        ),
        actions: [
          if (widget.workItem.type == TrackedWorkType.job)
            IconButton(
              tooltip: context.l10n.manageJobTitle,
              onPressed: () =>
                  context.push(AppRoutes.jobWorkspace(widget.workItem.id)),
              icon: const Icon(Icons.business_center_outlined),
            ),
          if (widget.workItem.type == TrackedWorkType.job)
            AppShowcase(
              showcaseKey: _pdfGuideKey,
              title: context.l10n.exportPdf,
              description:
                  '${context.l10n.exportPdf} · ${context.l10n.emailLabel} / '
                  'WhatsApp · ${context.l10n.savedOnDevice}',
              isLast: true,
              targetBorderRadius: BorderRadius.circular(24),
              child: IconButton(
                tooltip: context.l10n.exportPdf,
                onPressed: _sharingWork ? null : _shareWorkPdf,
                icon: _sharingWork
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
              ),
            ),
        ],
      ),
      body: FutureBuilder<_WorkDescriptor?>(
        future: _workFuture,
        builder: (context, workSnapshot) {
          if (workSnapshot.connectionState != ConnectionState.done ||
              activeAsync.isLoading) {
            return const AppListSkeleton(itemCount: 4);
          }
          final work = workSnapshot.data;
          if (work == null) {
            return Center(child: Text(context.l10n.workRecordNotFound));
          }
          if (activeAsync.hasError) {
            return _ErrorState(onRetry: _refresh);
          }
          _queueGuide();
          final globalActive = activeAsync.valueOrNull;
          final entry = globalActive?.workItem == widget.workItem
              ? globalActive
              : null;
          return _body(
            work,
            entry,
            globalActive,
            latestAsync.valueOrNull,
            historyAsync.valueOrNull ?? const [],
          );
        },
      ),
    );
  }

  Widget _body(
    _WorkDescriptor work,
    TimeEntry? entry,
    TimeEntry? globalActive,
    TimeEntry? latest,
    List<TimeEntry> history,
  ) {
    final fixedNow = DateTime.now().toUtc();
    final currency =
        ref.watch(
          currentProfileProvider.select((profile) => profile?.currencyCode),
        ) ??
        'GBP';

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
        key: PageStorageKey(
          'clock-${widget.workItem.type.name}-${widget.workItem.id}',
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AppShowcase(
            showcaseKey: _workGuideKey,
            title: work.title,
            description:
                '${context.l10n.scheduleTitle} · ${context.l10n.pricingLabel} · '
                '${context.l10n.proofTitle}',
            isFirst: true,
            child: _WorkHeader(work: work),
          ),
          if (entry != null && !_startedHere) ...[
            const SizedBox(height: 12),
            _InfoBanner(icon: Icons.restore, text: context.l10n.timerRecovered),
          ],
          if (globalActive != null && entry == null) ...[
            const SizedBox(height: 12),
            _OtherActiveCard(onOpen: () => _openWork(globalActive.workItem)),
          ],
          const SizedBox(height: 16),
          AppShowcase(
            showcaseKey: _timerGuideKey,
            title: widget.workItem.type == TrackedWorkType.job
                ? context.l10n.jobTimerTitle
                : context.l10n.shiftTimerTitle,
            description:
                '${context.l10n.clockIn} · ${context.l10n.startBreak} · '
                '${context.l10n.clockOut}',
            isLast: widget.workItem.type != TrackedWorkType.job,
            child: _LiveClockSection(
              work: work,
              entry: entry,
              latest: latest,
              currencyCode: currency,
              busy: _busy,
              onClockIn: globalActive == null ? () => _clockIn(work) : null,
              onBreak: entry == null ? null : () => _chooseBreak(entry),
              onResume: entry == null ? null : () => _resume(entry),
              onClockOut: entry == null ? null : () => _clockOut(entry),
            ),
          ),
          if (entry == null) ...[
            const SizedBox(height: 12),
            _PayRulesCard(
              overtimeHours: _overtimeHours,
              overtimeMultiplier: _overtimeMultiplier,
              premiumMultiplier: _premiumMultiplier,
              roundingMinutes: _roundingMinutes,
              currencyCode: currency,
              onOvertimeHours: (value) =>
                  setState(() => _overtimeHours = value),
              onOvertimeMultiplier: (value) =>
                  setState(() => _overtimeMultiplier = value),
              onPremiumMultiplier: (value) =>
                  setState(() => _premiumMultiplier = value),
              onRoundingMinutes: (value) =>
                  setState(() => _roundingMinutes = value),
              onExtraPay: (value) => setState(() {
                _extraPayMinor =
                    Money.tryParse(value, currencyCode: currency)?.minorUnits ??
                    0;
              }),
            ),
          ],
          if (history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              context.l10n.recentSessions,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final item in history.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HistoryTile(
                  entry: item,
                  now: fixedNow,
                  onCorrect: item.clockOut == null
                      ? null
                      : () => _correctTime(item),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _clockIn(_WorkDescriptor work) async {
    final profile = ref.read(currentProfileProvider);
    final overtimeRatio = _ratio(_overtimeMultiplier);
    final premiumRatio = _ratio(_premiumMultiplier);
    await _run(() async {
      try {
        await ref
            .read(timeTrackingRepositoryProvider)
            .clockIn(
              ClockInRequest(
                workItem: widget.workItem,
                currencyCode: profile?.currencyCode ?? 'GBP',
                pricingType: work.pricingType,
                scheduledStartAtUtc: work.startUtc,
                scheduledEndAtUtc: work.endUtc,
                baseRateMinor: work.baseRateMinor ?? profile?.defaultRateMinor,
                fixedPriceMinor: work.fixedPriceMinor,
                extraPayMinor: _extraPayMinor,
                overtimeAfterSeconds: _overtimeHours * 60 * 60,
                overtimeMultiplierNumerator: overtimeRatio.$1,
                overtimeMultiplierDenominator: overtimeRatio.$2,
                premiumMultiplierNumerator: premiumRatio.$1,
                premiumMultiplierDenominator: premiumRatio.$2,
                roundingIncrementSeconds: _roundingMinutes * 60,
              ),
            );
        _startedHere = true;
      } on ActiveWorkSessionException catch (error) {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(context.l10n.activeSessionExists),
            content: Text(context.l10n.activeSessionExistsDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.cancelLabel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _openWork(error.activeEntry.workItem);
                },
                child: Text(context.l10n.openActiveWork),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> _shareWorkPdf() async {
    if (_sharingWork || widget.workItem.type != TrackedWorkType.job) return;
    setState(() => _sharingWork = true);
    try {
      final job = await ref
          .read(jobRepositoryProvider)
          .getById(widget.workItem.id);
      if (job == null) throw const FormatException('Job not found.');
      final customer = await ref
          .read(customerRepositoryProvider)
          .getById(job.customerId);
      final service = job.serviceId == null
          ? null
          : await ref.read(workRepositoryProvider).service(job.serviceId!);
      final currency =
          customer?.billingCurrencyCode ??
          ref.read(currentProfileProvider)?.currencyCode ??
          'GBP';
      final schedule = job.schedule;
      final export = await ref
          .read(reportExportServiceProvider)
          .createWorkOrder(
            WorkOrderDocument(
              reference: job.id,
              title: job.title,
              status: job.status.name,
              priority: job.priority,
              pricingType: job.pricingType.name,
              currencyCode: currency,
              createdAtUtc: job.createdAt,
              description: job.description,
              workAddress: job.address,
              customerName: customer?.name,
              customerPhone: customer?.phone,
              customerEmail: customer?.email,
              customerAddress: customer?.address,
              serviceName: service?.name,
              startLocal: schedule?.startLocal,
              endLocal: schedule?.endLocal,
              ianaTimeZone: schedule?.ianaTimeZone,
              hourlyRateMinor: job.hourlyRateMinor,
              fixedPriceMinor: job.fixedPriceMinor,
              notes: job.notes,
            ),
          );
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(export.path)],
          subject: 'Work confirmation: ${job.title}',
          text: 'WorkProof PDF · SHA-256: ${export.sha256}',
          sharePositionOrigin: Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 1,
            height: 1,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.l10n.reportExportFailed);
      }
    } finally {
      if (mounted) setState(() => _sharingWork = false);
    }
  }

  Future<void> _chooseBreak(TimeEntry entry) async {
    final paid = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.chooseBreakType,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(context.l10n.paidBreak),
                subtitle: Text(context.l10n.paidBreakDescription),
                onTap: () => Navigator.pop(context, true),
              ),
              ListTile(
                leading: const Icon(Icons.money_off_outlined),
                title: Text(context.l10n.unpaidBreak),
                subtitle: Text(context.l10n.unpaidBreakDescription),
                onTap: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ),
      ),
    );
    if (paid == null) return;
    await _run(
      () => ref
          .read(timeTrackingRepositoryProvider)
          .startBreak(entry.id, isPaid: paid),
    );
  }

  Future<void> _resume(TimeEntry entry) =>
      _run(() => ref.read(timeTrackingRepositoryProvider).endBreak(entry.id));

  Future<void> _clockOut(TimeEntry entry) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.clockOutConfirmTitle),
            content: Text(context.l10n.clockOutConfirmDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancelLabel),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.stop),
                label: Text(context.l10n.clockOut),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    final succeeded = await _run(
      () => ref.read(timeTrackingRepositoryProvider).clockOut(entry.id),
    );
    if (!succeeded || !mounted) return;

    final route = ModalRoute.of(context);
    unawaited(
      ref
          .read(appReviewServiceProvider)
          .maybeRequestReview(
            canPresent: () {
              if (!mounted || route?.isCurrent != true) return false;
              final lifecycleState = WidgetsBinding.instance.lifecycleState;
              if (lifecycleState != null &&
                  lifecycleState != AppLifecycleState.resumed) {
                return false;
              }
              final appLock = ref.read(appLockControllerProvider);
              return !appLock.initializing &&
                  !appLock.locked &&
                  !AppShowcaseCoordinator.instance.isActive;
            },
          ),
    );
  }

  Future<void> _correctTime(TimeEntry entry) async {
    final correction = await showDialog<TimeCorrection>(
      context: context,
      builder: (context) => _CorrectionDialog(entry: entry),
    );
    if (correction == null) return;
    await _run(
      () => ref
          .read(timeTrackingRepositoryProvider)
          .correctTime(entry.id, correction),
    );
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_busy) return false;
    setState(() => _busy = true);
    try {
      await action();
      _refresh();
      return true;
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.l10n.timerActionFailed);
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _refresh() {
    ref.invalidate(activeTimeEntryProvider);
    ref.invalidate(workTimeEntryProvider(widget.workItem));
    ref.invalidate(latestCompletedTimeEntryProvider(widget.workItem));
    ref.invalidate(timeEntryHistoryProvider(widget.workItem));
    ref.invalidate(moneySummaryProvider);
    ref.invalidate(auditEventsProvider);
    invalidateWorkData(
      ref,
      flow: widget.workItem.type == TrackedWorkType.shift
          ? WorkFlow.worker
          : WorkFlow.tradesman,
    );
    unawaited(ref.read(notificationControllerProvider.notifier).reconcile());
  }

  void _openWork(WorkItemReference workItem) {
    final route = workItem.type == TrackedWorkType.job
        ? AppRoutes.job(workItem.id)
        : AppRoutes.shift(workItem.id);
    context.pushReplacement(route);
  }
}

/// Owns the one-second ticker so only live numbers rebuild. The surrounding
/// screen, async builders, pay-rule form and history remain stable.
class _LiveClockSection extends StatelessWidget {
  const _LiveClockSection({
    required this.work,
    required this.entry,
    required this.latest,
    required this.currencyCode,
    required this.busy,
    required this.onClockIn,
    required this.onBreak,
    required this.onResume,
    required this.onClockOut,
  });

  final _WorkDescriptor work;
  final TimeEntry? entry;
  final TimeEntry? latest;
  final String currencyCode;
  final bool busy;
  final VoidCallback? onClockIn;
  final VoidCallback? onBreak;
  final VoidCallback? onResume;
  final VoidCallback? onClockOut;

  @override
  Widget build(BuildContext context) {
    Widget content(DateTime now) {
      final displayEntry = entry ?? latest;
      final earnings = displayEntry?.earningsAt(now);
      return Column(
        children: [
          _TimerCard(
            entry: entry,
            latest: latest,
            now: now,
            busy: busy,
            onClockIn: onClockIn,
            onBreak: onBreak,
            onResume: onResume,
            onClockOut: onClockOut,
          ),
          const SizedBox(height: 16),
          _ActualVsPlanCard(work: work, entry: displayEntry, now: now),
          if (displayEntry != null && earnings != null) ...[
            const SizedBox(height: 16),
            _EarningsCard(
              entry: displayEntry,
              earnings: earnings,
              currencyCode: currencyCode,
            ),
          ],
        ],
      );
    }

    return entry == null
        ? content(DateTime.now().toUtc())
        : LiveSecondBuilder(builder: (_, now) => content(now));
  }
}

class _WorkDescriptor {
  const _WorkDescriptor({
    required this.title,
    required this.status,
    required this.pricingType,
    this.subtitle,
    this.startUtc,
    this.endUtc,
    this.startLocal,
    this.endLocal,
    this.timeZone,
    this.baseRateMinor,
    this.fixedPriceMinor,
  });

  factory _WorkDescriptor.fromJob(Job job) => _WorkDescriptor(
    title: job.title,
    subtitle: job.address,
    status: job.status.name,
    startUtc: job.schedule?.startUtc,
    endUtc: job.schedule?.endUtc,
    startLocal: job.schedule?.startLocal,
    endLocal: job.schedule?.endLocal,
    timeZone: job.schedule?.ianaTimeZone,
    pricingType: switch (job.pricingType) {
      PricingType.hourly => WorkPricingType.hourly,
      PricingType.daily => WorkPricingType.daily,
      PricingType.fixed => WorkPricingType.fixed,
      PricingType.mixed => WorkPricingType.mixed,
    },
    baseRateMinor: job.hourlyRateMinor,
    fixedPriceMinor: job.fixedPriceMinor,
  );

  factory _WorkDescriptor.fromShift(WorkerShift shift) => _WorkDescriptor(
    title: shift.title,
    subtitle: shift.notes,
    status: shift.status.name,
    startUtc: shift.schedule.startUtc,
    endUtc: shift.schedule.endUtc,
    startLocal: shift.schedule.startLocal,
    endLocal: shift.schedule.endLocal,
    timeZone: shift.schedule.ianaTimeZone,
    pricingType: WorkPricingType.hourly,
    baseRateMinor: shift.hourlyRateMinor,
  );

  final String title;
  final String? subtitle;
  final String status;
  final DateTime? startUtc;
  final DateTime? endUtc;
  final DateTime? startLocal;
  final DateTime? endLocal;
  final String? timeZone;
  final WorkPricingType pricingType;
  final int? baseRateMinor;
  final int? fixedPriceMinor;
}

class _WorkHeader extends StatelessWidget {
  const _WorkHeader({required this.work});

  final _WorkDescriptor work;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.work_outline)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (work.subtitle?.trim().isNotEmpty ?? false)
                  Text(
                    work.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Chip(label: Text(work.status)),
        ],
      ),
    ),
  );
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.entry,
    required this.latest,
    required this.now,
    required this.busy,
    required this.onClockIn,
    required this.onBreak,
    required this.onResume,
    required this.onClockOut,
  });

  final TimeEntry? entry;
  final TimeEntry? latest;
  final DateTime now;
  final bool busy;
  final VoidCallback? onClockIn;
  final VoidCallback? onBreak;
  final VoidCallback? onResume;
  final VoidCallback? onClockOut;

  @override
  Widget build(BuildContext context) {
    final active = entry != null;
    final shown = entry ?? latest;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              shown == null
                  ? '00:00:00'
                  : _clockDuration(
                      active
                          ? entry!.workedDurationAt(now)
                          : shown.billableDurationAt(now),
                    ),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              !active
                  ? (latest == null
                        ? context.l10n.notStarted
                        : context.l10n.lastBillableTime)
                  : entry!.isOnBreak
                  ? context.l10n.onBreak
                  : context.l10n.timerRunning,
              style: TextStyle(
                color: active ? AppColors.success : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            if (!active)
              ElevatedButton.icon(
                onPressed: busy ? null : onClockIn,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  onClockIn == null
                      ? context.l10n.anotherTimerRunning
                      : context.l10n.clockIn,
                ),
              )
            else if (entry!.isOnBreak)
              ElevatedButton.icon(
                onPressed: busy ? null : onResume,
                icon: const Icon(Icons.play_arrow),
                label: Text(context.l10n.resumeWork),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : onBreak,
                      icon: const Icon(Icons.free_breakfast_outlined),
                      label: Text(context.l10n.startBreak),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                      ),
                      onPressed: busy ? null : onClockOut,
                      icon: const Icon(Icons.stop),
                      label: Text(context.l10n.clockOut),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PayRulesCard extends StatelessWidget {
  const _PayRulesCard({
    required this.overtimeHours,
    required this.overtimeMultiplier,
    required this.premiumMultiplier,
    required this.roundingMinutes,
    required this.currencyCode,
    required this.onOvertimeHours,
    required this.onOvertimeMultiplier,
    required this.onPremiumMultiplier,
    required this.onRoundingMinutes,
    required this.onExtraPay,
  });

  final int overtimeHours;
  final double overtimeMultiplier;
  final double premiumMultiplier;
  final int roundingMinutes;
  final String currencyCode;
  final ValueChanged<int> onOvertimeHours;
  final ValueChanged<double> onOvertimeMultiplier;
  final ValueChanged<double> onPremiumMultiplier;
  final ValueChanged<int> onRoundingMinutes;
  final ValueChanged<String> onExtraPay;

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      key: const PageStorageKey<String>('clock-pay-rules-expansion'),
      leading: const Icon(Icons.tune),
      title: Text(context.l10n.payRules),
      subtitle: Text(context.l10n.payRulesDescription),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        InlineAnimatedPicker<int>(
          key: const PageStorageKey<String>('clock-overtime-hours'),
          label: context.l10n.overtimeAfter,
          value: overtimeHours,
          options: const [8, 10, 12],
          optionLabel: (value) => '$value ${context.l10n.hoursShort}',
          leading: const Icon(Icons.more_time_outlined),
          onChanged: onOvertimeHours,
        ),
        const SizedBox(height: 12),
        InlineAnimatedPicker<double>(
          key: const PageStorageKey<String>('clock-overtime-multiplier'),
          label: context.l10n.overtimeMultiplier,
          value: overtimeMultiplier,
          options: const [1.25, 1.5, 2.0],
          optionLabel: (value) => '$value×',
          leading: const Icon(Icons.calculate_outlined),
          onChanged: onOvertimeMultiplier,
        ),
        const SizedBox(height: 12),
        InlineAnimatedPicker<double>(
          key: const PageStorageKey<String>('clock-premium-multiplier'),
          label: context.l10n.ratePremium,
          value: premiumMultiplier,
          options: const [1.0, 1.25, 1.5],
          optionLabel: (value) => '$value×',
          leading: const Icon(Icons.trending_up_outlined),
          onChanged: onPremiumMultiplier,
        ),
        const SizedBox(height: 12),
        InlineAnimatedPicker<int>(
          key: const PageStorageKey<String>('clock-rounding-minutes'),
          label: context.l10n.timeRounding,
          value: roundingMinutes,
          options: const [1, 5, 15],
          optionLabel: (value) => '$value ${context.l10n.minutesShort}',
          leading: const Icon(Icons.timer_outlined),
          onChanged: onRoundingMinutes,
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const PageStorageKey<String>('clock-extra-pay'),
          initialValue: '',
          decoration: InputDecoration(
            labelText: context.l10n.extraPay,
            prefixText: '$currencyCode ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onExtraPay,
        ),
      ],
    ),
  );
}

class _ActualVsPlanCard extends StatelessWidget {
  const _ActualVsPlanCard({
    required this.work,
    required this.entry,
    required this.now,
  });

  final _WorkDescriptor work;
  final TimeEntry? entry;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.plannedVsActual,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _valueRow(
            context.l10n.plannedTime,
            work.startLocal == null || work.endLocal == null
                ? context.l10n.notScheduled
                : '${_dateTime(work.startLocal!)} – ${_dateTime(work.endLocal!)}${work.timeZone == null ? '' : ' · ${work.timeZone}'}',
          ),
          _valueRow(
            context.l10n.actualTime,
            entry == null
                ? context.l10n.notStarted
                : '${_dateTime(entry!.clockIn.toLocal())} – ${entry!.clockOut == null ? context.l10n.nowLabel : _dateTime(entry!.clockOut!.toLocal())}',
          ),
          if (entry != null) ...[
            _valueRow(
              context.l10n.rawDuration,
              AppFormatters.duration(entry!.totalElapsedAt(now)),
            ),
            _valueRow(
              context.l10n.paidBreak,
              AppFormatters.duration(entry!.paidBreakDurationAt(now)),
            ),
            _valueRow(
              context.l10n.unpaidBreak,
              AppFormatters.duration(entry!.unpaidBreakDurationAt(now)),
            ),
            _valueRow(
              context.l10n.billableDuration,
              AppFormatters.duration(entry!.billableDurationAt(now)),
              bold: true,
            ),
          ],
        ],
      ),
    ),
  );
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({
    required this.entry,
    required this.earnings,
    required this.currencyCode,
  });

  final TimeEntry entry;
  final WorkEarningsResult earnings;
  final String currencyCode;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.earningsBreakdown,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (entry.baseRateMinor != null)
            _valueRow(
              context.l10n.baseRate,
              '${_money(entry.baseRateMinor!, currencyCode)} / ${entry.pricingType == WorkPricingType.daily ? context.l10n.daysShort : context.l10n.hoursShort}',
            ),
          _valueRow(
            context.l10n.regularPay,
            _money(earnings.regularPay.minorUnits, currencyCode),
          ),
          if (earnings.overtimePay.minorUnits > 0)
            _valueRow(
              context.l10n.overtimePay,
              _money(earnings.overtimePay.minorUnits, currencyCode),
            ),
          if (earnings.premiumPay.minorUnits > 0)
            _valueRow(
              context.l10n.premiumPay,
              _money(earnings.premiumPay.minorUnits, currencyCode),
            ),
          if (earnings.fixedPay.minorUnits > 0)
            _valueRow(
              context.l10n.fixedPay,
              _money(earnings.fixedPay.minorUnits, currencyCode),
            ),
          if (earnings.extraPay.minorUnits > 0)
            _valueRow(
              context.l10n.extraPay,
              _money(earnings.extraPay.minorUnits, currencyCode),
            ),
          const Divider(height: 24),
          _valueRow(
            context.l10n.expectedTotal,
            _money(earnings.total.minorUnits, currencyCode),
            bold: true,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.calculationSnapshotNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.now,
    required this.onCorrect,
  });

  final TimeEntry entry;
  final DateTime now;
  final VoidCallback? onCorrect;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(entry.isActive ? Icons.timer : Icons.check_circle_outline),
      title: Text(
        '${_dateTime(entry.clockIn.toLocal())} · ${AppFormatters.duration(entry.billableDurationAt(now))}',
      ),
      subtitle: Text(
        entry.wasCorrected
            ? '${context.l10n.corrected}: ${entry.correctionReason}'
            : entry.isActive
            ? context.l10n.timerRunning
            : context.l10n.completedSession,
      ),
      trailing: onCorrect == null
          ? null
          : IconButton(
              tooltip: context.l10n.correctTime,
              onPressed: onCorrect,
              icon: const Icon(Icons.edit_calendar_outlined),
            ),
    ),
  );
}

class _OtherActiveCard extends StatelessWidget {
  const _OtherActiveCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: Text(context.l10n.activeSessionExists),
      subtitle: Text(context.l10n.activeSessionExistsDescription),
      trailing: TextButton(
        onPressed: onOpen,
        child: Text(context.l10n.openLabel),
      ),
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
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
        Text(context.l10n.timerLoadFailed),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onRetry, child: Text(context.l10n.retry)),
      ],
    ),
  );
}

class _CorrectionDialog extends StatefulWidget {
  const _CorrectionDialog({required this.entry});

  final TimeEntry entry;

  @override
  State<_CorrectionDialog> createState() => _CorrectionDialogState();
}

class _CorrectionDialogState extends State<_CorrectionDialog> {
  late DateTime _start;
  late DateTime _end;
  final _reason = TextEditingController();
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _start = widget.entry.clockIn.toLocal();
    _end = widget.entry.clockOut!.toLocal();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.correctTime),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.actualStart),
            subtitle: Text(_dateTime(_start)),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () => _pick(start: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.actualEnd),
            subtitle: Text(_dateTime(_end)),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () => _pick(start: false),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reason,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.correctionReason,
              errorText: _invalid
                  ? context.l10n.correctionReasonRequired
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.correctionAuditNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancelLabel),
      ),
      FilledButton(onPressed: _save, child: Text(context.l10n.saveLabel)),
    ],
  );

  Future<void> _pick({required bool start}) async {
    final current = start ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (start) {
        _start = value;
      } else {
        _end = value;
      }
    });
  }

  void _save() {
    final invalid = !_end.isAfter(_start) || _reason.text.trim().length < 3;
    if (invalid) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.pop(
      context,
      TimeCorrection(
        clockInUtc: _start.toUtc(),
        clockOutUtc: _end.toUtc(),
        reason: _reason.text.trim(),
      ),
    );
  }
}

Widget _valueRow(String label, String value, {bool bold = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(label)),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
);

(int, int) _ratio(double value) => switch (value) {
  1.25 => (5, 4),
  1.5 => (3, 2),
  2.0 => (2, 1),
  _ => (1, 1),
};

String _clockDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String _dateTime(DateTime value) =>
    '${AppFormatters.date(value)} ${AppFormatters.time(value)}';

String _money(int minor, String currency) =>
    AppFormatters.currencyMinor(minor, currencyCode: currency);
