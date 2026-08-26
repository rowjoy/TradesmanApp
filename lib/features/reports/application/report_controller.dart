import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/app_clock.dart';
import '../../onboarding/domain/entities/local_profile.dart';
import '../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../data/report_repository.dart';
import '../domain/report_models.dart';
import '../infrastructure/report_export_service.dart';

class ReportState {
  const ReportState({
    required this.filter,
    required this.report,
    this.refreshing = false,
    this.exporting = false,
    this.lastExport,
    this.errorCode,
  });

  final ReportFilter filter;
  final AsyncValue<OfflineReport> report;
  final bool refreshing;
  final bool exporting;
  final PreparedReportExport? lastExport;
  final String? errorCode;

  ReportState copyWith({
    ReportFilter? filter,
    AsyncValue<OfflineReport>? report,
    bool? refreshing,
    bool? exporting,
    PreparedReportExport? lastExport,
    String? errorCode,
    bool clearError = false,
  }) => ReportState(
    filter: filter ?? this.filter,
    report: report ?? this.report,
    refreshing: refreshing ?? this.refreshing,
    exporting: exporting ?? this.exporting,
    lastExport: lastExport ?? this.lastExport,
    errorCode: clearError ? null : errorCode ?? this.errorCode,
  );
}

class ReportController extends StateNotifier<ReportState> {
  ReportController({
    required ReportRepository repository,
    required ReportExportService exportService,
    required ReportFilter initialFilter,
  }) : _repository = repository,
       _exportService = exportService,
       super(ReportState(filter: initialFilter, report: const AsyncLoading())) {
    refresh();
  }

  final ReportRepository _repository;
  final ReportExportService _exportService;

  Future<void> refresh() async {
    final filter = state.filter;
    state = state.copyWith(
      report: state.report.asData == null
          ? const AsyncLoading<OfflineReport>()
          : state.report,
      refreshing: state.report.asData != null,
      clearError: true,
    );
    final result = await AsyncValue.guard(() => _repository.build(filter));
    if (state.filter == filter) {
      state = state.copyWith(report: result, refreshing: false);
    }
  }

  Future<void> setPreset(ReportRangePreset preset) async {
    final range = _rangeFor(preset, DateTime.now());
    state = state.copyWith(
      filter: state.filter.copyWith(
        preset: preset,
        startUtc: range.$1,
        endUtc: range.$2,
      ),
    );
    await refresh();
  }

  Future<void> setCustomRange(DateTime startLocal, DateTime endLocal) async {
    final start = DateTime(
      startLocal.year,
      startLocal.month,
      startLocal.day,
    ).toUtc();
    final end = DateTime(
      endLocal.year,
      endLocal.month,
      endLocal.day + 1,
    ).toUtc();
    state = state.copyWith(
      filter: state.filter.copyWith(
        preset: ReportRangePreset.custom,
        startUtc: start,
        endUtc: end,
      ),
    );
    await refresh();
  }

  Future<void> setScope(ReportScope scope) async {
    state = state.copyWith(
      filter: state.filter.copyWith(scope: scope, clearParty: true),
    );
    await refresh();
  }

  Future<void> setParty(ReportParty? party) async {
    state = state.copyWith(
      filter: party == null
          ? state.filter.copyWith(clearParty: true)
          : state.filter.copyWith(partyType: party.type, partyId: party.id),
    );
    await refresh();
  }

  Future<bool> exportAndShare(ReportExportFormat format, {Rect? origin}) async {
    final report = state.report.asData?.value;
    if (report == null || state.exporting) return false;
    state = state.copyWith(exporting: true, clearError: true);
    try {
      final export = await _exportService.create(report, format);
      state = state.copyWith(exporting: false, lastExport: export);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(export.path)],
          subject: 'WorkProof offline report',
          text: 'SHA-256: ${export.sha256}',
          sharePositionOrigin: origin,
        ),
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        exporting: false,
        errorCode: 'report_export_failed',
      );
      return false;
    }
  }
}

final reportRepositoryProvider = Provider(
  (ref) => ReportRepository(databaseHelper: DatabaseHelper.instance),
);

final reportExportServiceProvider = Provider(
  (ref) => ReportExportService(
    repository: ref.watch(reportRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
    clock: ref.watch(appClockProvider),
  ),
);

final reportControllerProvider =
    StateNotifierProvider.autoDispose<ReportController, ReportState>((ref) {
      final profile = ref.watch(currentProfileProvider);
      final range = _rangeFor(ReportRangePreset.weekly, DateTime.now());
      return ReportController(
        repository: ref.watch(reportRepositoryProvider),
        exportService: ref.watch(reportExportServiceProvider),
        initialFilter: ReportFilter(
          startUtc: range.$1,
          endUtc: range.$2,
          preset: ReportRangePreset.weekly,
          scope: _scopeFor(profile?.workMode),
          currencyCode: profile?.currencyCode ?? 'GBP',
        ),
      );
    });

ReportScope _scopeFor(WorkMode? mode) => switch (mode) {
  WorkMode.worker => ReportScope.worker,
  WorkMode.tradesman => ReportScope.tradesman,
  WorkMode.both || null => ReportScope.both,
};

(DateTime, DateTime) _rangeFor(ReportRangePreset preset, DateTime nowLocal) {
  final day = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
  if (preset == ReportRangePreset.monthly) {
    return (
      DateTime(day.year, day.month).toUtc(),
      DateTime(day.year, day.month + 1).toUtc(),
    );
  }
  final start = day.subtract(Duration(days: day.weekday - DateTime.monday));
  return (start.toUtc(), start.add(const Duration(days: 7)).toUtc());
}
