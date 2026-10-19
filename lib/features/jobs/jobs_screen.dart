import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/status_chip.dart';
import '../../l10n/l10n.dart';
import 'job_provider.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(allJobsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.jobsLabel)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_jobs',
        onPressed: () => context.push(AppRoutes.newJob),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newJob),
      ),
      body: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(child: Text(context.l10n.noJobs));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.build_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      job.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      job.scheduledDate != null
                          ? '${job.scheduledDate!.day}/${job.scheduledDate!.month}  ${job.startTime ?? ''}'
                          : context.l10n.notScheduled,
                    ),
                    trailing: StatusChip(status: job.status),
                    onTap: () => context.push(AppRoutes.job(job.id)),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(context.l10n.workLoadFailed)),
      ),
    );
  }
}
