import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/performance/day_bucket_index.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_banner_frame.dart';
import '../../../../l10n/l10n.dart';
import '../../../ads/application/ad_content_eligibility.dart';
import '../../../onboarding/domain/entities/local_profile.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../domain/work_models.dart';
import '../controllers/work_controller.dart';

class WorkCalendarScreen extends ConsumerStatefulWidget {
  const WorkCalendarScreen({super.key, required this.initialFlow});
  final WorkFlow initialFlow;

  @override
  ConsumerState<WorkCalendarScreen> createState() => _WorkCalendarScreenState();
}

class _WorkCalendarScreenState extends ConsumerState<WorkCalendarScreen> {
  late DateTime _month;
  late DateTime _selectedDate;
  late WorkFlow _flow;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _flow = widget.initialFlow;
  }

  @override
  Widget build(BuildContext context) {
    final profileMode = ref.watch(
      currentProfileProvider.select((profile) => profile?.workMode),
    );
    final items = ref.watch(
      calendarItemsProvider(CalendarQuery(month: _month, flow: _flow)),
    );
    return AppBannerFrame(
      placement: AdPlacement.calendar,
      enabled: hasPublisherContent(items),
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.calendarTitle)),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab_calendar',
          onPressed: () => context.push(
            _flow == WorkFlow.worker ? AppRoutes.newShift : AppRoutes.newJob,
          ),
          icon: const Icon(Icons.add),
          label: Text(
            _flow == WorkFlow.worker
                ? context.l10n.newShift
                : context.l10n.newJob,
          ),
        ),
        body: Column(
          children: [
            if (profileMode == WorkMode.both)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<WorkFlow>(
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
                    selected: {_flow},
                    onSelectionChanged: (value) =>
                        setState(() => _flow = value.first),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _moveMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat.yMMMM(
                        Localizations.localeOf(context).languageCode,
                      ).format(_month),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _moveMonth(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            items.when(
              data: (values) => _MonthGrid(
                month: _month,
                selectedDate: _selectedDate,
                items: values,
                onSelected: (date) => setState(() => _selectedDate = date),
              ),
              loading: () => const _CalendarLoadingGrid(),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(context.l10n.calendarLoadFailed),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: items.when(
                data: (values) => _Agenda(
                  selectedDate: _selectedDate,
                  items: values
                      .where((item) => item.touchesLocalDate(_selectedDate))
                      .toList(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _moveMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selectedDate = DateTime(_month.year, _month.month, 1);
    });
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDate,
    required this.items,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime selectedDate;
  final List<CalendarWorkItem> items;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final gridStart = DateTime(
      first.year,
      first.month,
      first.day - (first.weekday - DateTime.monday),
    );
    final counts = DayBucketIndex.countOverlaps(
      rangeStart: gridStart,
      dayCount: 42,
      intervals: items.map(
        (item) => (start: item.startLocal, end: item.endLocal),
      ),
    );
    final weekdays = MaterialLocalizations.of(context).narrowWeekdays;
    final orderedWeekdays = [...weekdays.sublist(1), weekdays.first];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              for (final day in orderedWeekdays)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final date = DateTime(
                gridStart.year,
                gridStart.month,
                gridStart.day + index,
              );
              final selected = _sameDate(date, selectedDate);
              final inMonth = date.month == month.month;
              final count = counts[DayBucketIndex.dateKey(date)] ?? 0;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : inMonth
                              ? null
                              : Theme.of(context).disabledColor,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (count > 0)
                        Container(
                          width: count > 2 ? 14 : 6,
                          height: 4,
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarLoadingGrid extends StatelessWidget {
  const _CalendarLoadingGrid();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cell = (constraints.maxWidth - 24) / 7 / 1.05;
      return SizedBox(
        height: 48 + (cell * 6),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(),
          ),
        ),
      );
    },
  );
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.selectedDate, required this.items});
  final DateTime selectedDate;
  final List<CalendarWorkItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(context.l10n.noWorkOnDate));
    }
    return ListView.separated(
      key: PageStorageKey(
        'agenda-${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      itemCount: items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              AppFormatters.date(selectedDate),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          );
        }
        final item = items[index - 1];
        return Card(
          child: ListTile(
            leading: Icon(
              item.flow == WorkFlow.worker
                  ? Icons.badge_outlined
                  : Icons.handyman_outlined,
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${AppFormatters.dateShort(item.startLocal)} ${AppFormatters.time(item.startLocal)} → '
              '${AppFormatters.dateShort(item.endLocal)} ${AppFormatters.time(item.endLocal)} · ${item.ianaTimeZone}',
            ),
            onTap: () => context.push(
              item.flow == WorkFlow.worker
                  ? AppRoutes.shift(item.id)
                  : AppRoutes.job(item.id),
            ),
          ),
        );
      },
    );
  }
}

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
