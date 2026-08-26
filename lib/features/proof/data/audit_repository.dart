import '../../../core/database/database_helper.dart';
import '../domain/entities/audit_event.dart';

class AuditRepository {
  AuditRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<AuditEvent>> latest({int limit = 100}) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'audit_logs',
      orderBy: 'occurred_at_utc DESC',
      limit: limit,
    );
    return rows
        .map(
          (row) => AuditEvent(
            id: row['id']! as String,
            entityType: row['entity_type']! as String,
            entityId: row['entity_id']! as String,
            action: row['action']! as String,
            summaryKey: row['summary_key']! as String,
            occurredAtUtc: DateTime.parse(
              row['occurred_at_utc']! as String,
            ).toUtc(),
          ),
        )
        .toList(growable: false);
  }
}
