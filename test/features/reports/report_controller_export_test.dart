import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/database/database_helper.dart';
import 'package:tradesman_manager/core/ids/id_generator.dart';
import 'package:tradesman_manager/core/time/app_clock.dart';
import 'package:tradesman_manager/features/reports/application/report_controller.dart';
import 'package:tradesman_manager/features/reports/data/report_repository.dart';
import 'package:tradesman_manager/features/reports/domain/report_models.dart';
import 'package:tradesman_manager/features/reports/infrastructure/report_export_service.dart';

void main() {
  test(
    'exporting remains true through generation and native sharing',
    () async {
      final report = _report();
      final repository = _FakeReportRepository(report);
      final createCompleter = Completer<PreparedReportExport>();
      final shareCompleter = Completer<void>();
      var createCalls = 0;
      var shareCalls = 0;
      PreparedReportExport? sharedExport;
      Rect? sharedOrigin;
      final service = _FakeReportExportService(
        repository: repository,
        create: (_, __) {
          createCalls++;
          return createCompleter.future;
        },
      );
      final controller = ReportController(
        repository: repository,
        exportService: service,
        share: (export, {origin}) {
          shareCalls++;
          sharedExport = export;
          sharedOrigin = origin;
          return shareCompleter.future;
        },
        initialFilter: report.filter,
      );
      addTearDown(controller.dispose);
      await controller.refresh();

      const origin = Rect.fromLTWH(10, 20, 30, 40);
      final pending = controller.exportAndShare(
        ReportExportFormat.pdf,
        origin: origin,
      );

      expect(controller.state.exporting, isTrue);
      expect(createCalls, 1);
      expect(await controller.exportAndShare(ReportExportFormat.csv), isFalse);
      expect(createCalls, 1);

      final prepared = _preparedExport();
      createCompleter.complete(prepared);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.exporting, isTrue);
      expect(controller.state.lastExport, same(prepared));
      expect(shareCalls, 1);
      expect(sharedExport, same(prepared));
      expect(sharedOrigin, origin);

      shareCompleter.complete();
      expect(await pending, isTrue);
      expect(controller.state.exporting, isFalse);
      expect(controller.state.errorCode, isNull);
      expect(controller.state.lastExport, same(prepared));
    },
  );

  test('generation failure clears exporting and records the error', () async {
    final report = _report();
    final repository = _FakeReportRepository(report);
    var shareCalls = 0;
    final controller = ReportController(
      repository: repository,
      exportService: _FakeReportExportService(
        repository: repository,
        create: (_, __) =>
            Future<PreparedReportExport>.error(StateError('generation failed')),
      ),
      share: (_, {origin}) async => shareCalls++,
      initialFilter: report.filter,
    );
    addTearDown(controller.dispose);
    await controller.refresh();

    expect(await controller.exportAndShare(ReportExportFormat.csv), isFalse);
    expect(controller.state.exporting, isFalse);
    expect(controller.state.errorCode, 'report_export_failed');
    expect(controller.state.lastExport, isNull);
    expect(shareCalls, 0);
  });

  test(
    'sharing failure retains the prepared export and records the error',
    () async {
      final report = _report();
      final prepared = _preparedExport();
      final repository = _FakeReportRepository(report);
      final controller = ReportController(
        repository: repository,
        exportService: _FakeReportExportService(
          repository: repository,
          create: (_, __) async => prepared,
        ),
        share: (_, {origin}) => Future<void>.error(StateError('share failed')),
        initialFilter: report.filter,
      );
      addTearDown(controller.dispose);
      await controller.refresh();

      expect(await controller.exportAndShare(ReportExportFormat.pdf), isFalse);
      expect(controller.state.exporting, isFalse);
      expect(controller.state.errorCode, 'report_export_failed');
      expect(controller.state.lastExport, same(prepared));
    },
  );
}

OfflineReport _report() {
  final filter = ReportFilter(
    startUtc: DateTime.utc(2026, 10, 12),
    endUtc: DateTime.utc(2026, 10, 19),
    preset: ReportRangePreset.weekly,
    scope: ReportScope.both,
    currencyCode: 'GBP',
  );
  return OfflineReport(
    filter: filter,
    generatedAtUtc: DateTime.utc(2026, 10, 19),
    worker: WorkerReportSummary.empty,
    business: BusinessReportSummary.empty,
    lines: const [],
    parties: const [],
  );
}

PreparedReportExport _preparedExport() => PreparedReportExport(
  id: 'export-1',
  path: '/tmp/workproof-report.pdf',
  filename: 'workproof-report.pdf',
  sha256: 'abc123',
  format: ReportExportFormat.pdf,
  createdAtUtc: DateTime.utc(2026, 10, 19),
);

class _FakeReportRepository extends ReportRepository {
  _FakeReportRepository(this.report)
    : super(databaseHelper: DatabaseHelper.instance);

  final OfflineReport report;

  @override
  Future<OfflineReport> build(ReportFilter filter) async => report;
}

typedef _CreateExport =
    Future<PreparedReportExport> Function(
      OfflineReport report,
      ReportExportFormat format,
    );

class _FakeReportExportService extends ReportExportService {
  _FakeReportExportService({
    required super.repository,
    required _CreateExport create,
  }) : _create = create,
       super(idGenerator: _FakeIdGenerator(), clock: _FakeClock());

  final _CreateExport _create;

  @override
  Future<PreparedReportExport> create(
    OfflineReport report,
    ReportExportFormat format,
  ) {
    return _create(report, format);
  }
}

class _FakeIdGenerator implements IdGenerator {
  @override
  String next() => 'id';
}

class _FakeClock implements AppClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 19);
}
