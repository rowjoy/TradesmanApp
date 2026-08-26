import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../jobs/job_model.dart';
import '../../../jobs/job_provider.dart';
import '../../../onboarding/domain/entities/local_profile.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../data/work_repository.dart';
import '../../domain/work_models.dart';

final selectedWorkFlowProvider = StateProvider<WorkFlow>((ref) {
  final mode = ref.watch(
    currentProfileProvider.select((profile) => profile?.workMode),
  );
  return mode == WorkMode.worker ? WorkFlow.worker : WorkFlow.tradesman;
});

final workListSearchQueryProvider = StateProvider<String>((ref) => '');
final directorySearchQueryProvider = StateProvider<String>((ref) => '');
final shiftStatusFilterProvider = StateProvider<WorkItemStatus?>((ref) => null);
final workPageLimitProvider = StateProvider<int>((ref) => 50);

final employersProvider = FutureProvider<List<Employer>>((ref) {
  return ref.watch(workRepositoryProvider).employers();
});

final workplacesProvider = FutureProvider<List<Workplace>>((ref) {
  return ref.watch(workRepositoryProvider).workplaces();
});

final servicesProvider = FutureProvider<List<ServiceTemplate>>((ref) {
  return ref.watch(workRepositoryProvider).services();
});

final directoryEmployersProvider = FutureProvider<List<Employer>>((ref) {
  return ref
      .watch(workRepositoryProvider)
      .employers(query: ref.watch(directorySearchQueryProvider));
});

final directoryWorkplacesProvider = FutureProvider<List<Workplace>>((ref) {
  return ref
      .watch(workRepositoryProvider)
      .workplaces(query: ref.watch(directorySearchQueryProvider));
});

final directoryServicesProvider = FutureProvider<List<ServiceTemplate>>((ref) {
  return ref
      .watch(workRepositoryProvider)
      .services(query: ref.watch(directorySearchQueryProvider));
});

final shiftsProvider = FutureProvider<List<WorkerShift>>((ref) {
  return ref
      .watch(workRepositoryProvider)
      .shifts(
        query: ref.watch(workListSearchQueryProvider),
        status: ref.watch(shiftStatusFilterProvider),
        limit: ref.watch(workPageLimitProvider),
      );
});

final workJobsProvider = FutureProvider<List<Job>>((ref) {
  final status = ref.watch(jobStatusFilterProvider);
  return ref
      .watch(jobRepositoryProvider)
      .getAll(
        query: ref.watch(workListSearchQueryProvider),
        status: status,
        limit: ref.watch(workPageLimitProvider),
      );
});

final dashboardShiftsProvider = FutureProvider<List<WorkerShift>>((ref) async {
  final now = DateTime.now();
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = DateTime(now.year, now.month, now.day + 1);
  return ref
      .watch(workRepositoryProvider)
      .shifts(
        rangeStartUtc: dayStart.toUtc(),
        rangeEndUtc: dayEnd.toUtc(),
        limit: 20,
      );
});

final dashboardJobsProvider = FutureProvider<List<Job>>((ref) {
  return ref.watch(jobRepositoryProvider).getTodayJobs(limit: 20);
});

class CalendarQuery {
  const CalendarQuery({required this.month, required this.flow});

  final DateTime month;
  final WorkFlow flow;

  @override
  bool operator ==(Object other) =>
      other is CalendarQuery &&
      other.month.year == month.year &&
      other.month.month == month.month &&
      other.flow == flow;

  @override
  int get hashCode => Object.hash(month.year, month.month, flow);
}

final calendarItemsProvider =
    FutureProvider.family<List<CalendarWorkItem>, CalendarQuery>((ref, query) {
      final monthStart = DateTime.utc(
        query.month.year,
        query.month.month,
      ).subtract(const Duration(days: 1));
      final monthEnd = DateTime.utc(
        query.month.year,
        query.month.month + 1,
      ).add(const Duration(days: 1));
      return ref
          .watch(workRepositoryProvider)
          .calendarItems(
            rangeStartUtc: monthStart,
            rangeEndUtc: monthEnd,
            flow: query.flow,
          );
    });

void invalidateWorkData(WidgetRef ref, {required WorkFlow flow}) {
  if (flow == WorkFlow.worker) {
    ref.invalidate(shiftsProvider);
    ref.invalidate(dashboardShiftsProvider);
  } else {
    ref.invalidate(workJobsProvider);
    ref.invalidate(allJobsProvider);
    ref.invalidate(todayJobsProvider);
    ref.invalidate(dashboardJobsProvider);
  }
  ref.invalidate(calendarItemsProvider);
}

void invalidateWorkDirectories(WidgetRef ref) {
  ref.invalidate(employersProvider);
  ref.invalidate(workplacesProvider);
  ref.invalidate(servicesProvider);
  ref.invalidate(directoryEmployersProvider);
  ref.invalidate(directoryWorkplacesProvider);
  ref.invalidate(directoryServicesProvider);
}
