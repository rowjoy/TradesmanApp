import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/jobs/job_model.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final JobStatus status;

  Color _color() {
    switch (status) {
      case JobStatus.completed:
      case JobStatus.paid:
        return AppColors.success;
      case JobStatus.inProgress:
        return AppColors.accent;
      case JobStatus.paused:
      case JobStatus.partiallyPaid:
        return AppColors.warning;
      case JobStatus.cancelled:
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  String _label() {
    switch (status) {
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.partiallyPaid:
        return 'Partially Paid';
      default:
        return status.name[0].toUpperCase() + status.name.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
