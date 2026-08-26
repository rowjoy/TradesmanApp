class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.summaryKey,
    required this.occurredAtUtc,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String summaryKey;
  final DateTime occurredAtUtc;
}
