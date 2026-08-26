import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../data/audit_repository.dart';
import '../../domain/entities/audit_event.dart';

final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) => AuditRepository(DatabaseHelper.instance),
);

final auditEventsProvider = FutureProvider<List<AuditEvent>>(
  (ref) => ref.watch(auditRepositoryProvider).latest(),
);
