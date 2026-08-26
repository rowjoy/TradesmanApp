import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/audit_event.dart';
import '../controllers/audit_controller.dart';

class ProofOverviewScreen extends ConsumerWidget {
  const ProofOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(auditEventsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.proofTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(auditEventsProvider);
          await ref.read(auditEventsProvider.future);
        },
        child: events.when(
          loading: () => const AppListSkeleton(),
          error: (_, __) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 100),
              Center(child: Text(context.l10n.startupFailed)),
            ],
          ),
          data: (items) => ListView(
            key: const PageStorageKey('proof-audit-list'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                context.l10n.proofSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone_android_outlined, size: 17),
                  const SizedBox(width: 7),
                  Text(context.l10n.localOnlyStatus),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.folder_zip_outlined),
                  ),
                  title: Text(context.l10n.payEvidencePacksTitle),
                  subtitle: Text(context.l10n.payEvidencePacksDescription),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(AppRoutes.money),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.assessment_outlined),
                  ),
                  title: Text(context.l10n.reportsTitle),
                  subtitle: Text(context.l10n.reportsOfflineDescription),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.reports),
                ),
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Text(
                    context.l10n.proofEmpty,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...items.map((event) => _AuditTile(event: event)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.event});

  final AuditEvent event;

  String _label(BuildContext context) => switch (event.summaryKey) {
    'auditOnboardingCompleted' => context.l10n.auditOnboardingCompleted,
    'auditCustomerCreated' => context.l10n.auditCustomerCreated,
    'auditJobCreated' => context.l10n.auditJobCreated,
    'auditClockedIn' => context.l10n.auditClockedIn,
    'auditBreakStarted' => context.l10n.auditBreakStarted,
    'auditPaidBreakStarted' => context.l10n.auditPaidBreakStarted,
    'auditUnpaidBreakStarted' => context.l10n.auditUnpaidBreakStarted,
    'auditBreakEnded' => context.l10n.auditBreakEnded,
    'auditClockedOut' => context.l10n.auditClockedOut,
    'auditTimeCorrected' => context.l10n.auditTimeCorrected,
    'auditPreferencesUpdated' => context.l10n.auditPreferencesUpdated,
    'auditPayPeriodCreated' => context.l10n.auditPayPeriodCreated,
    'auditPayslipRecorded' => context.l10n.auditPayslipRecorded,
    'auditPayAdjustmentAdded' => context.l10n.auditPayAdjustmentAdded,
    'auditEvidenceAdded' => context.l10n.auditEvidenceAdded,
    'auditWorkProofExported' => context.l10n.auditWorkProofExported,
    'auditReportExported' => context.l10n.auditReportExported,
    _ => context.l10n.unknownActivity,
  };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final localTime = event.occurredAtUtc.toLocal();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.verified_outlined, size: 20),
        ),
        title: Text(
          _label(context),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(DateFormat.yMMMd(locale).add_jm().format(localTime)),
      ),
    );
  }
}
