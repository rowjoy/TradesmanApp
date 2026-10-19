import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/database/database_helper.dart';
import 'package:tradesman_manager/core/ids/id_generator.dart';
import 'package:tradesman_manager/core/time/app_clock.dart';
import 'package:tradesman_manager/core/time/schedule_window.dart';
import 'package:tradesman_manager/features/customers/customer_model.dart';
import 'package:tradesman_manager/features/customers/customer_provider.dart';
import 'package:tradesman_manager/features/jobs/job_finance_repository.dart';
import 'package:tradesman_manager/features/jobs/job_model.dart';
import 'package:tradesman_manager/features/jobs/job_provider.dart';
import 'package:tradesman_manager/features/jobs/job_workspace_screen.dart';
import 'package:tradesman_manager/features/marketing/data/marketing_repository.dart';
import 'package:tradesman_manager/features/marketing/domain/marketing_profile.dart';
import 'package:tradesman_manager/features/notifications/application/notification_controller.dart';
import 'package:tradesman_manager/features/notifications/data/notification_repository.dart';
import 'package:tradesman_manager/features/notifications/domain/notification_models.dart';
import 'package:tradesman_manager/features/notifications/infrastructure/local_notification_gateway.dart';
import 'package:tradesman_manager/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:tradesman_manager/features/time_tracking/time_entry_model.dart';
import 'package:tradesman_manager/features/time_tracking/time_tracking_provider.dart';
import 'package:tradesman_manager/l10n/generated/app_localizations.dart';

const _clock = _FixedClock();
const _ids = _SequentialIds();

void main() {
  for (final target in const [
    (status: JobStatus.completed, label: 'Completed'),
    (status: JobStatus.cancelled, label: 'Cancelled'),
  ]) {
    testWidgets(
      '${target.status.name} cancels obsolete OS reminders immediately',
      (tester) async {
        final harness = await _pumpWorkspace(tester);

        await tester.tap(find.byType(DropdownButtonFormField<JobStatus>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(target.label).last);
        await tester.pumpAndSettle();

        expect(harness.jobs.current.status, target.status);
        expect(await harness.gateway.pendingIds(), isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('a payment that marks a job paid cancels its OS reminder', (
    tester,
  ) async {
    final finance = _MemoryFinanceRepository();
    final harness = await _pumpWorkspace(
      tester,
      job: _job(pricingType: PricingType.fixed, fixedPriceMinor: 10000),
      finance: finance,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(harness.jobs.current.status, JobStatus.paid);
    expect(await harness.gateway.pendingIds(), isEmpty);
    expect(tester.takeException(), isNull);
  });
}

Job _job({
  PricingType pricingType = PricingType.hourly,
  int? fixedPriceMinor,
}) => Job(
  id: 'job-1',
  customerId: 'customer-1',
  title: 'Boiler service',
  schedule: ScheduleWindow.fromLocal(
    startLocal: DateTime(2030, 1, 2, 9),
    endLocal: DateTime(2030, 1, 2, 10),
    ianaTimeZone: 'Etc/UTC',
    startOffsetMinutes: 0,
    endOffsetMinutes: 0,
  ),
  pricingType: pricingType,
  fixedPriceMinor: fixedPriceMinor,
  createdAt: _clock.nowUtc(),
  updatedAt: _clock.nowUtc(),
);

Future<_WorkspaceHarness> _pumpWorkspace(
  WidgetTester tester, {
  Job? job,
  _MemoryFinanceRepository? finance,
}) async {
  final jobs = _MemoryJobRepository(job ?? _job());
  final gateway = _MemoryNotificationGateway({42});
  final notifications = _RecordingNotificationController(
    sourceRepository: _CancellationNotificationRepository(),
    gateway: gateway,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentProfileProvider.overrideWithValue(null),
        jobRepositoryProvider.overrideWithValue(jobs),
        customerRepositoryProvider.overrideWithValue(
          _MemoryCustomerRepository(),
        ),
        marketingRepositoryProvider.overrideWithValue(
          _MemoryMarketingRepository(),
        ),
        jobFinanceRepositoryProvider.overrideWithValue(
          finance ?? _MemoryFinanceRepository(),
        ),
        timeTrackingRepositoryProvider.overrideWithValue(
          _MemoryTimeTrackingRepository(),
        ),
        notificationControllerProvider.overrideWith((ref) => notifications),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: JobWorkspaceScreen(jobId: 'job-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _WorkspaceHarness(jobs: jobs, gateway: gateway);
}

class _WorkspaceHarness {
  const _WorkspaceHarness({required this.jobs, required this.gateway});

  final _MemoryJobRepository jobs;
  final _MemoryNotificationGateway gateway;
}

class _FixedClock implements AppClock {
  const _FixedClock();

  @override
  DateTime nowUtc() => DateTime.utc(2029, 12, 1, 12);
}

class _SequentialIds implements IdGenerator {
  const _SequentialIds();

  @override
  String next() => 'test-id';
}

class _MemoryJobRepository extends JobRepository {
  _MemoryJobRepository(this.current) : super(clock: _clock, idGenerator: _ids);

  Job current;

  @override
  Future<Job?> getById(String id) async => current.id == id ? current : null;

  @override
  Future<void> updateStatus(String jobId, JobStatus status) async {
    if (current.id == jobId) current = current.copyWith(status: status);
  }
}

class _MemoryCustomerRepository extends CustomerRepository {
  _MemoryCustomerRepository() : super(clock: _clock, idGenerator: _ids);

  @override
  Future<Customer?> getById(String id) async => null;
}

class _MemoryMarketingRepository extends MarketingRepository {
  _MemoryMarketingRepository() : super(DatabaseHelper.instance);

  @override
  Future<MarketingProfile> load() async => const MarketingProfile.empty();
}

class _MemoryFinanceRepository extends JobFinanceRepository {
  _MemoryFinanceRepository()
    : super(databaseHelper: DatabaseHelper.instance, clock: _clock, ids: _ids);

  JobFinanceLedger ledger = const JobFinanceLedger.empty();

  @override
  Future<JobFinanceLedger> load(String jobId) async => ledger;

  @override
  Future<void> saveVatBasisPoints(String jobId, int value) async {}

  @override
  Future<JobInvoiceRecord> issueInvoice({
    required String jobId,
    required String customerId,
    required String description,
    required int subtotalMinor,
    required int taxMinor,
    required int totalMinor,
    required Map<String, Object?> snapshot,
  }) async => JobInvoiceRecord(
    id: 'invoice-1',
    number: 'INV-1',
    subtotalMinor: subtotalMinor,
    taxMinor: taxMinor,
    totalMinor: totalMinor,
    paidMinor: 0,
  );

  @override
  Future<JobPaymentRecord> addPayment({
    required String invoiceId,
    required int amountMinor,
    required String method,
    String? reference,
  }) async {
    final payment = JobPaymentRecord(
      id: 'payment-1',
      amountMinor: amountMinor,
      method: method,
      paidAtUtc: _clock.nowUtc(),
      reference: reference,
    );
    ledger = JobFinanceLedger(
      vatBasisPoints: ledger.vatBasisPoints,
      expenses: ledger.expenses,
      payments: [payment],
      invoice: ledger.invoice,
      signatureBytes: ledger.signatureBytes,
    );
    return payment;
  }
}

class _MemoryTimeTrackingRepository extends TimeTrackingRepository {
  _MemoryTimeTrackingRepository() : super(clock: _clock, idGenerator: _ids);

  @override
  Future<TimeEntry?> latestCompletedForWork(WorkItemReference workItem) async =>
      null;
}

class _CancellationNotificationRepository extends NotificationRepository {
  _CancellationNotificationRepository() : super(clock: _clock, ids: _ids);

  @override
  Future<List<WorkAlertSource>> loadWorkSources() async => const [];

  @override
  Future<Map<AlertCategory, AlertPreference>> loadPreferences() async => {
    for (final category in AlertCategory.values)
      category: AlertPreference.defaults(category),
  };

  @override
  Future<MotivationSettings> loadMotivation() async =>
      const MotivationSettings();

  @override
  Future<ReconcileBatch> prepareReconcile({
    required List<PlannedNotification> desired,
    required Set<int> pendingOsIds,
    required bool canSchedule,
  }) async => const ReconcileBatch(cancelIds: [42], schedule: []);

  @override
  Future<void> markCancelled(int osNotificationId) async {}

  @override
  Future<({int pending, int attention})> statusCounts() async =>
      (pending: 0, attention: 0);

  @override
  Future<void> saveLastReconcile(DateTime value) async {}
}

class _RecordingNotificationController extends NotificationController {
  _RecordingNotificationController({
    required NotificationRepository sourceRepository,
    required _MemoryNotificationGateway gateway,
  }) : _gateway = gateway,
       super(
         repository: sourceRepository,
         gateway: gateway,
         clock: _clock,
         languageCode: () => 'en',
       );

  final _MemoryNotificationGateway _gateway;

  @override
  Future<void> reconcile() => _gateway.cancel(42);
}

class _MemoryNotificationGateway implements NotificationGateway {
  _MemoryNotificationGateway(Set<int> pending) : _pending = {...pending};

  final Set<int> _pending;

  @override
  Stream<String> get taps => const Stream.empty();

  @override
  String get localTimeZone => 'Etc/UTC';

  @override
  Future<String?> initialize() async => null;

  @override
  Future<bool?> permissionEnabled() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> refreshTimeZone() async {}

  @override
  Future<void> openSettings() async {}

  @override
  Future<Set<int>> pendingIds() async => {..._pending};

  @override
  Future<void> cancelAllPending() async => _pending.clear();

  @override
  Future<void> cancel(int id) async {
    _pending.remove(id);
  }

  @override
  Future<void> schedule(StoredNotification notification) async =>
      _pending.add(notification.osNotificationId);

  @override
  Future<void> showTest({
    required String title,
    required String body,
    required String payload,
  }) async {}

  @override
  void dispose() {}
}
