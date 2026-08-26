import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../../onboarding/domain/entities/local_profile.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../../pay_protection/domain/pay_protection_models.dart';
import '../../../pay_protection/presentation/controllers/pay_protection_controller.dart';
import '../../../showcase/data/showcase_repository.dart';
import '../../../showcase/presentation/app_showcase.dart';
import '../controllers/money_summary_controller.dart';

class MoneyOverviewScreen extends ConsumerStatefulWidget {
  const MoneyOverviewScreen({super.key});

  @override
  ConsumerState<MoneyOverviewScreen> createState() =>
      _MoneyOverviewScreenState();
}

class _MoneyOverviewScreenState extends ConsumerState<MoneyOverviewScreen> {
  bool _showPayProtection = true;

  @override
  Widget build(BuildContext context) {
    final mode =
        ref.watch(
          currentProfileProvider.select((profile) => profile?.workMode),
        ) ??
        WorkMode.tradesman;
    final showSwitch = mode == WorkMode.both;
    final workerSurface =
        mode == WorkMode.worker || (showSwitch && _showPayProtection);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          workerSurface
              ? context.l10n.m05PayProtection
              : context.l10n.moneyTitle,
        ),
      ),
      body: Column(
        children: [
          if (showSwitch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.shield_outlined),
                      label: Text(context.l10n.m05WorkerPay),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.business_center_outlined),
                      label: Text(
                        context.l10n.m05BusinessMoney,
                      ),
                    ),
                  ],
                  selected: {_showPayProtection},
                  onSelectionChanged: (selection) =>
                      setState(() => _showPayProtection = selection.first),
                ),
              ),
            ),
          Expanded(
            child: workerSurface
                ? const _PayProtectionHome()
                : const _BusinessMoneyContent(),
          ),
        ],
      ),
    );
  }
}

class _PayProtectionHome extends ConsumerStatefulWidget {
  const _PayProtectionHome();

  @override
  ConsumerState<_PayProtectionHome> createState() => _PayProtectionHomeState();
}

class _PayProtectionHomeState extends ConsumerState<_PayProtectionHome> {
  final _summaryKey = GlobalKey();
  final _createKey = GlobalKey();
  final _periodsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  Future<void> _startIfNeeded() async {
    final completed = await ref
        .read(showcaseRepositoryProvider)
        .isModule05Completed();
    if (!mounted || completed) return;
    _startGuide();
  }

  void _startGuide() {
    if (!mounted) return;
    AppShowcaseCoordinator.instance.start(
      keys: [_summaryKey, _createKey, _periodsKey],
      onComplete: _completeGuide,
    );
  }

  Future<void> _completeGuide() async {
    await ref.read(showcaseRepositoryProvider).completeModule05();
    ref.invalidate(module05ShowcaseCompletedProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(module05ShowcaseReplayRequestProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startGuide());
    });
    final periods = ref.watch(payPeriodsProvider);
    final all = periods.asData?.value ?? const <PayPeriod>[];
    final possibleTotal = all.fold<int>(
      0,
      (total, item) => total + mathPositive(item.possibleDifferenceMinor),
    );
    final currency =
        ref.watch(
          currentProfileProvider.select((profile) => profile?.currencyCode),
        ) ??
        'GBP';
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(payPeriodsProvider);
        await ref.read(payPeriodsProvider.future);
      },
      child: ListView(
        key: const PageStorageKey('money-worker-pay-protection'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          AppShowcase(
            showcaseKey: _summaryKey,
            title: context.l10n.m05PayAtAGlance,
            description: context.l10n.m05ExpectedAndReceivedPayStaySeparateA,
            isFirst: true,
            targetBorderRadius: BorderRadius.circular(24),
            child: _PayHero(
              openPeriods: all
                  .where((item) => item.status != PayPeriodStatus.exported)
                  .length,
              possibleDifferenceMinor: possibleTotal,
              currencyCode: currency,
              onTour: _startGuide,
            ),
          ),
          const SizedBox(height: 16),
          AppShowcase(
            showcaseKey: _createKey,
            title: context.l10n.m05StartAPayPeriod,
            description: context.l10n.m05ChooseEmployerScheduleAndCurrencyInsideThis,
            targetBorderRadius: BorderRadius.circular(16),
            child: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.newPayPeriod),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                context.l10n.m05CreatePayProtectionPeriod,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.m05PayPeriods,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const Icon(Icons.lock_outline_rounded, size: 18),
              const SizedBox(width: 6),
              Text(context.l10n.m05OnDevice),
            ],
          ),
          const SizedBox(height: 10),
          AppShowcase(
            showcaseKey: _periodsKey,
            title: context.l10n.m05ReviewEvidenceExport,
            description: context.l10n.m05OpenAPeriodToAddAPayslip,
            isLast: true,
            targetBorderRadius: BorderRadius.circular(18),
            child: periods.when(
              loading: () => const Column(
                children: [
                  AppCardSkeleton(),
                  SizedBox(height: 10),
                  AppCardSkeleton(),
                  SizedBox(height: 10),
                  AppCardSkeleton(),
                ],
              ),
              error: (_, __) => _InlineError(
                onRetry: () => ref.invalidate(payPeriodsProvider),
              ),
              data: (items) => items.isEmpty
                  ? _EmptyPayPeriods(
                      onCreate: () => context.push(AppRoutes.newPayPeriod),
                    )
                  : Column(
                      children: [
                        for (final period in items) ...[
                          _PayPeriodCard(
                            period: period,
                            onTap: () =>
                                context.push(AppRoutes.payPeriod(period.id)),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayHero extends StatelessWidget {
  const _PayHero({
    required this.openPeriods,
    required this.possibleDifferenceMinor,
    required this.currencyCode,
    required this.onTour,
  });

  final int openPeriods;
  final int possibleDifferenceMinor;
  final String currencyCode;
  final VoidCallback onTour;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0D5453), Color(0xFF123C3B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: .18),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton.filledTonal(
              tooltip: context.l10n.m05ShowGuide,
              onPressed: onTour,
              icon: const Icon(Icons.tour_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .14),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.m05PossibleDifferenceToReview,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 5),
        Text(
          AppFormatters.currencyMinor(
            possibleDifferenceMinor,
            currencyCode: currencyCode,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(
              Icons.pending_actions_outlined,
              color: Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 7),
            Text(
              context.l10n.m05OpenPeriodsCount(openPeriods),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PayPeriodCard extends StatelessWidget {
  const _PayPeriodCard({required this.period, required this.onTap});

  final PayPeriod period;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final difference = period.possibleDifferenceMinor;
    final warning = difference != null && difference != 0;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      period.employerName ??
                          context.l10n.m05AllEmployers,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _StatusPill(period: period),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${AppFormatters.dateShort(period.startAtUtc.toLocal())} – '
                '${AppFormatters.dateShort(period.endAtUtc.toLocal().subtract(const Duration(days: 1)))} · '
                '${period.currencyCode}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MiniMoney(
                      label: context.l10n.m05Expected,
                      value: AppFormatters.currencyMinor(
                        period.expectedGrossMinor,
                        currencyCode: period.currencyCode,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _MiniMoney(
                      label: context.l10n.m05Received,
                      value: period.receivedGrossMinor == null
                          ? '—'
                          : AppFormatters.currencyMinor(
                              period.receivedGrossMinor!,
                              currencyCode: period.currencyCode,
                            ),
                    ),
                  ),
                ],
              ),
              if (warning) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          difference > 0
                              ? context.l10n.m05PossibleDifferenceReview(
                                  AppFormatters.currencyMinor(
                                    difference,
                                    currencyCode: period.currencyCode,
                                  ),
                                )
                              : context.l10n.m05ReceivedAboveExpectedReview(
                                  AppFormatters.currencyMinor(
                                    difference.abs(),
                                    currencyCode: period.currencyCode,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.period});
  final PayPeriod period;

  @override
  Widget build(BuildContext context) {
    final label = switch (period.status) {
      PayPeriodStatus.open => context.l10n.openLabel,
      PayPeriodStatus.reviewed => context.l10n.m05Reviewed,
      PayPeriodStatus.exported => context.l10n.m05Exported,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MiniMoney extends StatelessWidget {
  const _MiniMoney({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}

class _EmptyPayPeriods extends StatelessWidget {
  const _EmptyPayPeriods({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.shield_moon_outlined, size: 46),
          const SizedBox(height: 12),
          Text(
            context.l10n.m05NoPayPeriodYet,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            context.l10n.m05CreateOneAfterRecordingShiftsExpectedPay,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onCreate,
            child: Text(context.l10n.m05CreateNow),
          ),
        ],
      ),
    ),
  );
}

class _BusinessMoneyContent extends ConsumerWidget {
  const _BusinessMoneyContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(moneySummaryProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(moneySummaryProvider);
        await ref.read(moneySummaryProvider.future);
      },
      child: ListView(
        key: const PageStorageKey('money-business-summary'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          summary.when(
            loading: () => const Column(
              children: [
                AppCardSkeleton(height: 132),
                SizedBox(height: 12),
                AppCardSkeleton(),
                SizedBox(height: 12),
                AppCardSkeleton(),
              ],
            ),
            error: (_, __) => _InlineError(
              onRetry: () => ref.invalidate(moneySummaryProvider),
            ),
            data: (value) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.moneyExpected,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppFormatters.currencyMinor(
                            value.expectedEarningsMinor,
                            currencyCode: value.currencyCode,
                          ),
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone_android_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(context.l10n.savedOnDevice),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      _BusinessAmountTile(
                        icon: Icons.description_outlined,
                        label: Localizations.localeOf(context).languageCode ==
                                'bn'
                            ? 'ইনভয়েস মোট'
                            : 'Invoiced',
                        amountMinor: value.invoicedMinor,
                        currencyCode: value.currencyCode,
                      ),
                      const Divider(height: 1),
                      _BusinessAmountTile(
                        icon: Icons.payments_outlined,
                        label: Localizations.localeOf(context).languageCode ==
                                'bn'
                            ? 'পরিশোধিত'
                            : 'Paid',
                        amountMinor: value.paidMinor,
                        currencyCode: value.currencyCode,
                      ),
                      const Divider(height: 1),
                      _BusinessAmountTile(
                        icon: Icons.pending_actions_outlined,
                        label: Localizations.localeOf(context).languageCode ==
                                'bn'
                            ? 'বকেয়া ব্যালেন্স'
                            : 'Outstanding balance',
                        amountMinor: value.outstandingMinor,
                        currencyCode: value.currencyCode,
                      ),
                      const Divider(height: 1),
                      _BusinessAmountTile(
                        icon: Icons.receipt_long_outlined,
                        label: Localizations.localeOf(context).languageCode ==
                                'bn'
                            ? 'খরচ'
                            : 'Expenses',
                        amountMinor: value.expensesMinor,
                        currencyCode: value.currencyCode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.timer_outlined),
                        title: Text(context.l10n.moneyTrackedTime),
                        trailing: Text(
                          AppFormatters.duration(
                            Duration(seconds: value.trackedSeconds),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.task_alt_outlined),
                        title: Text(context.l10n.moneyCompletedEntries),
                        trailing: Text(
                          '${value.completedEntries}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessAmountTile extends StatelessWidget {
  const _BusinessAmountTile({
    required this.icon,
    required this.label,
    required this.amountMinor,
    required this.currencyCode,
  });

  final IconData icon;
  final String label;
  final int amountMinor;
  final String currencyCode;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    trailing: Text(
      AppFormatters.currencyMinor(
        amountMinor,
        currencyCode: currencyCode,
      ),
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      children: [
        Text(context.l10n.startupFailed),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: onRetry, child: Text(context.l10n.retry)),
      ],
    ),
  );
}

int mathPositive(int? value) => value == null || value <= 0 ? 0 : value;
