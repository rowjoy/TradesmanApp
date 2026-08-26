import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/app_clock.dart';
import '../domain/pay_protection_models.dart';

class PayProtectionRepository {
  PayProtectionRepository({
    required DatabaseHelper databaseHelper,
    required AppClock clock,
    required IdGenerator idGenerator,
  }) : _databaseHelper = databaseHelper,
       _clock = clock,
       _idGenerator = idGenerator;

  static const workspaceId = 'local-workspace';
  final DatabaseHelper _databaseHelper;
  final AppClock _clock;
  final IdGenerator _idGenerator;

  Future<List<PayPeriod>> periods() async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT p.*, e.name AS employer_name
      FROM pay_periods p
      LEFT JOIN employers e ON e.id = p.employer_id AND e.deleted_at IS NULL
      WHERE p.workspace_id = ? AND p.deleted_at IS NULL
      ORDER BY p.start_at_utc DESC, p.created_at DESC
    ''',
      [workspaceId],
    );
    return rows.map(_periodFromRow).toList(growable: false);
  }

  Future<PayPeriodDetail?> detail(String id) async {
    final db = await _databaseHelper.database;
    final periods = await db.rawQuery(
      '''
      SELECT p.*, e.name AS employer_name
      FROM pay_periods p
      LEFT JOIN employers e ON e.id = p.employer_id AND e.deleted_at IS NULL
      WHERE p.id = ? AND p.workspace_id = ? AND p.deleted_at IS NULL
      LIMIT 1
    ''',
      [id, workspaceId],
    );
    if (periods.isEmpty) return null;

    final payslipRows = await db.query(
      'payslips',
      where: 'pay_period_id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    final adjustmentRows = await db.query(
      'pay_adjustments',
      where: 'pay_period_id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      orderBy: 'created_at ASC',
    );
    final evidenceRows = await db.rawQuery(
      '''
      SELECT ev.*, a.id AS attachment_join_id, a.original_filename,
             a.mime_type, a.size_bytes, a.sha256, a.local_path,
             a.shared_copy_path, a.shared_copy_sha256,
             a.metadata_stripped, a.original_retained
      FROM evidence_items ev
      LEFT JOIN attachments a ON a.id = ev.attachment_id AND a.deleted_at IS NULL
      WHERE ev.linked_entity_type = 'payPeriod'
        AND ev.linked_entity_id = ? AND ev.deleted_at IS NULL
      ORDER BY ev.captured_at_utc DESC
    ''',
      [id],
    );
    final auditRows = await db.rawQuery(
      '''
      SELECT action, summary_key, occurred_at_utc
      FROM audit_logs
      WHERE (entity_type = 'payPeriod' AND entity_id = ?)
         OR (entity_type = 'evidence' AND entity_id IN (
           SELECT id FROM evidence_items
           WHERE linked_entity_type = 'payPeriod' AND linked_entity_id = ?
         ))
      ORDER BY occurred_at_utc ASC
    ''',
      [id, id],
    );

    return PayPeriodDetail(
      period: _periodFromRow(periods.first),
      payslip: payslipRows.isEmpty ? null : _payslipFromRow(payslipRows.first),
      adjustments: adjustmentRows
          .map(_adjustmentFromRow)
          .toList(growable: false),
      evidence: evidenceRows.map(_evidenceFromRow).toList(growable: false),
      auditEvents: auditRows
          .map(
            (row) => PayAuditEvent(
              action: row['action']! as String,
              summaryKey: row['summary_key']! as String,
              occurredAtUtc: DateTime.parse(
                row['occurred_at_utc']! as String,
              ).toUtc(),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<String> createPeriod({
    required PayPeriodType periodType,
    required DateTime startAtUtc,
    required DateTime endAtUtc,
    required String currencyCode,
    String? employerId,
    String? notes,
  }) async {
    if (!endAtUtc.isAfter(startAtUtc)) {
      throw const FormatException('Pay period end must be after start.');
    }
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    final id = _idGenerator.next();
    final calculated = await _calculateExpected(
      db,
      startAtUtc: startAtUtc,
      endAtUtc: endAtUtc,
      employerId: employerId,
      currencyCode: currencyCode,
    );
    final gaps = <String>[
      if (calculated.entryCount == 0) 'noCompletedTimeEntries',
      if (calculated.missingRateCount > 0) 'missingRate',
    ];
    final confidence = gaps.isEmpty
        ? PayConfidence.complete
        : PayConfidence.needsReview;
    final row = <String, Object?>{
      'id': id,
      'workspace_id': workspaceId,
      'employer_id': employerId,
      'period_type': periodType.name,
      'start_at_utc': startAtUtc.toIso8601String(),
      'end_at_utc': endAtUtc.toIso8601String(),
      'expected_gross_minor': calculated.expectedGrossMinor,
      'calculation_engine_version': 3,
      'currency_code': currencyCode,
      'status': PayPeriodStatus.open.name,
      'confidence_state': confidence.name,
      'calculation_snapshot_json': jsonEncode(calculated.toJson()),
      'data_gap_json': jsonEncode(gaps),
      'notes': _blankToNull(notes),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'local_version': 1,
      'sync_status': 'localOnly',
    };
    await db.transaction((txn) async {
      await txn.insert('pay_periods', row);
      await _auditAndOutbox(
        txn,
        entityType: 'payPeriod',
        entityId: id,
        action: 'created',
        summaryKey: 'auditPayPeriodCreated',
        payload: row,
        now: now,
      );
    });
    return id;
  }

  Future<void> savePayslip({
    required String payPeriodId,
    required String currencyCode,
    required int grossMinor,
    required int deductionsMinor,
    required int netMinor,
    DateTime? payDateUtc,
    String? reference,
    PreparedEvidenceFile? file,
  }) async {
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    await db.transaction((txn) async {
      String? attachmentId;
      if (file != null) {
        attachmentId = await _insertAttachment(txn, file, now);
        await _insertEvidence(
          txn,
          payPeriodId: payPeriodId,
          type: EvidenceType.payslip,
          description: 'Payslip attachment',
          attachmentId: attachmentId,
          now: now,
        );
      }
      final existing = await txn.query(
        'payslips',
        columns: ['id', 'attachment_id', 'created_at'],
        where: 'pay_period_id = ? AND deleted_at IS NULL',
        whereArgs: [payPeriodId],
        orderBy: 'updated_at DESC',
        limit: 1,
      );
      final id = existing.isEmpty
          ? _idGenerator.next()
          : existing.first['id']! as String;
      final row = <String, Object?>{
        'workspace_id': workspaceId,
        'pay_period_id': payPeriodId,
        'gross_minor': grossMinor,
        'deductions_minor': deductionsMinor,
        'net_minor': netMinor,
        'pay_date_utc': payDateUtc?.toIso8601String(),
        'reference': _blankToNull(reference),
        'currency_code': currencyCode,
        'attachment_id':
            attachmentId ??
            (existing.isEmpty ? null : existing.first['attachment_id']),
        'user_confirmed': 1,
        'updated_at': now.toIso8601String(),
        'sync_status': 'localOnly',
      };
      if (existing.isEmpty) {
        await txn.insert('payslips', {
          'id': id,
          ...row,
          'created_at': now.toIso8601String(),
        });
      } else {
        await txn.update('payslips', row, where: 'id = ?', whereArgs: [id]);
      }
      await txn.update(
        'pay_periods',
        {
          'received_gross_minor': grossMinor,
          'deductions_minor': deductionsMinor,
          'net_payment_minor': netMinor,
          'updated_at': now.toIso8601String(),
          'sync_status': 'localOnly',
        },
        where: 'id = ?',
        whereArgs: [payPeriodId],
      );
      await _auditAndOutbox(
        txn,
        entityType: 'payPeriod',
        entityId: payPeriodId,
        action: 'payslipRecorded',
        summaryKey: 'auditPayslipRecorded',
        payload: row,
        now: now,
      );
    });
  }

  Future<void> addAdjustment({
    required String payPeriodId,
    required String type,
    required String label,
    required int amountMinor,
  }) async {
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    await db.transaction((txn) async {
      final period = await txn.query(
        'pay_periods',
        columns: ['expected_gross_minor'],
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [payPeriodId],
        limit: 1,
      );
      if (period.isEmpty) throw StateError('Pay period not found.');
      final current = period.first['expected_gross_minor'] as int? ?? 0;
      final id = _idGenerator.next();
      final row = <String, Object?>{
        'id': id,
        'workspace_id': workspaceId,
        'pay_period_id': payPeriodId,
        'adjustment_type': type,
        'label': label.trim(),
        'amount_minor': amountMinor,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      await txn.insert('pay_adjustments', row);
      await txn.update(
        'pay_periods',
        {
          'expected_gross_minor': math.max(0, current + amountMinor),
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [payPeriodId],
      );
      await _auditAndOutbox(
        txn,
        entityType: 'payPeriod',
        entityId: payPeriodId,
        action: 'adjustmentAdded',
        summaryKey: 'auditPayAdjustmentAdded',
        payload: row,
        now: now,
      );
    });
  }

  Future<void> addNoteEvidence({
    required String payPeriodId,
    required String description,
    EvidenceType type = EvidenceType.note,
  }) async {
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    await db.transaction((txn) async {
      final evidenceId = await _insertEvidence(
        txn,
        payPeriodId: payPeriodId,
        type: type,
        description: description,
        now: now,
      );
      await _auditAndOutbox(
        txn,
        entityType: 'evidence',
        entityId: evidenceId,
        action: 'created',
        summaryKey: 'auditEvidenceAdded',
        payload: {'payPeriodId': payPeriodId, 'type': type.name},
        now: now,
      );
    });
  }

  Future<void> addFileEvidence({
    required String payPeriodId,
    required EvidenceType type,
    required PreparedEvidenceFile file,
    String? description,
  }) async {
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    await db.transaction((txn) async {
      final attachmentId = await _insertAttachment(txn, file, now);
      final evidenceId = await _insertEvidence(
        txn,
        payPeriodId: payPeriodId,
        type: type,
        description: description,
        attachmentId: attachmentId,
        now: now,
      );
      await _auditAndOutbox(
        txn,
        entityType: 'evidence',
        entityId: evidenceId,
        action: 'created',
        summaryKey: 'auditEvidenceAdded',
        payload: {
          'payPeriodId': payPeriodId,
          'type': type.name,
          'sha256': file.sha256,
        },
        now: now,
      );
    });
  }

  Future<void> setEvidenceSelected(String id, {required bool selected}) async {
    final db = await _databaseHelper.database;
    await db.update(
      'evidence_items',
      {'selected_for_export': selected ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<WorkProofExport> recordExport({
    required String payPeriodId,
    required String pdfPath,
    required String zipPath,
    required String pdfSha256,
    required String zipSha256,
    required Map<String, Object?> manifest,
  }) async {
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    final id = _idGenerator.next();
    await db.transaction((txn) async {
      await txn.insert('evidence_exports', {
        'id': id,
        'workspace_id': workspaceId,
        'linked_entity_type': 'payPeriod',
        'linked_entity_id': payPeriodId,
        'pdf_path': pdfPath,
        'zip_path': zipPath,
        'pdf_sha256': pdfSha256,
        'zip_sha256': zipSha256,
        'manifest_json': jsonEncode(manifest),
        'status': 'ready',
        'generated_at_utc': now.toIso8601String(),
      });
      await txn.update(
        'pay_periods',
        {
          'status': PayPeriodStatus.exported.name,
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [payPeriodId],
      );
      await _auditAndOutbox(
        txn,
        entityType: 'payPeriod',
        entityId: payPeriodId,
        action: 'exported',
        summaryKey: 'auditWorkProofExported',
        payload: {'pdfSha256': pdfSha256, 'zipSha256': zipSha256},
        now: now,
      );
    });
    return WorkProofExport(
      id: id,
      pdfPath: pdfPath,
      zipPath: zipPath,
      pdfSha256: pdfSha256,
      zipSha256: zipSha256,
      generatedAtUtc: now,
    );
  }

  Future<PayCalculationBreakdown> _calculateExpected(
    Database db, {
    required DateTime startAtUtc,
    required DateTime endAtUtc,
    required String? employerId,
    required String currencyCode,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT t.id, t.clock_in, t.clock_out, t.billable_duration_seconds,
             t.calculation_snapshot_json, t.currency_code,
             t.base_rate_minor, s.hourly_rate_minor, s.employer_id
      FROM time_entries t
      INNER JOIN shifts s ON s.id = t.shift_id AND s.deleted_at IS NULL
      WHERE t.workspace_id = ? AND t.work_item_type = 'shift'
        AND t.status = 'completed' AND t.clock_out IS NOT NULL
        AND t.deleted_at IS NULL AND t.clock_in >= ? AND t.clock_in < ?
        AND (? IS NULL OR s.employer_id = ?)
      ORDER BY t.clock_in ASC
    ''',
      [
        workspaceId,
        startAtUtc.toIso8601String(),
        endAtUtc.toIso8601String(),
        employerId,
        employerId,
      ],
    );

    var seconds = 0;
    var regular = 0;
    var overtime = 0;
    var premium = 0;
    var allowances = 0;
    var missingRates = 0;
    final ids = <String>[];
    for (final row in rows) {
      ids.add(row['id']! as String);
      final entryCurrency = row['currency_code'] as String?;
      if (entryCurrency != null && entryCurrency != currencyCode) {
        missingRates++;
        continue;
      }
      final snapshotSource = row['calculation_snapshot_json'] as String?;
      if (snapshotSource != null && snapshotSource.isNotEmpty) {
        final snapshot = jsonDecode(snapshotSource);
        if (snapshot is Map<String, dynamic>) {
          int value(String key) => (snapshot[key] as num?)?.toInt() ?? 0;
          seconds += value('billableSeconds');
          regular += value('regularPayMinor');
          overtime += value('overtimePayMinor');
          premium += value('premiumPayMinor');
          allowances += value('extraPayMinor') + value('fixedPayMinor');
          continue;
        }
      }
      final start = DateTime.parse(row['clock_in']! as String);
      final end = DateTime.parse(row['clock_out']! as String);
      final billable =
          row['billable_duration_seconds'] as int? ??
          math.max(0, end.difference(start).inSeconds);
      seconds += billable;
      final rate =
          row['base_rate_minor'] as int? ?? row['hourly_rate_minor'] as int?;
      if (rate == null) {
        missingRates++;
      } else {
        regular += (rate * billable + 1800) ~/ 3600;
      }
    }
    return PayCalculationBreakdown(
      recordedSeconds: seconds,
      regularPayMinor: regular,
      overtimePayMinor: overtime,
      premiumPayMinor: premium,
      allowancesMinor: allowances,
      entryCount: rows.length,
      missingRateCount: missingRates,
      sourceTimeEntryIds: ids,
    );
  }

  Future<String> _insertAttachment(
    Transaction txn,
    PreparedEvidenceFile file,
    DateTime now,
  ) async {
    final id = _idGenerator.next();
    await txn.insert('attachments', {
      'id': id,
      'workspace_id': workspaceId,
      'original_filename': file.originalFilename,
      'mime_type': file.mimeType,
      'size_bytes': file.sizeBytes,
      'sha256': file.sha256,
      'local_path': file.localPath,
      'shared_copy_path': file.sharedCopyPath,
      'shared_copy_sha256': file.sharedCopySha256,
      'metadata_stripped': file.metadataStripped ? 1 : 0,
      'original_retained': file.originalRetained ? 1 : 0,
      'encryption_version': 1,
      'sync_state': 'localOnly',
      'captured_at_utc': now.toIso8601String(),
    });
    return id;
  }

  Future<String> _insertEvidence(
    Transaction txn, {
    required String payPeriodId,
    required EvidenceType type,
    required DateTime now,
    String? description,
    String? attachmentId,
  }) async {
    final id = _idGenerator.next();
    await txn.insert('evidence_items', {
      'id': id,
      'workspace_id': workspaceId,
      'linked_entity_type': 'payPeriod',
      'linked_entity_id': payPeriodId,
      'evidence_type': type.name,
      'attachment_id': attachmentId,
      'user_description': _blankToNull(description),
      'captured_at_utc': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'selected_for_export': 1,
    });
    return id;
  }

  Future<void> _auditAndOutbox(
    Transaction txn, {
    required String entityType,
    required String entityId,
    required String action,
    required String summaryKey,
    required Map<String, Object?> payload,
    required DateTime now,
  }) async {
    await txn.insert('audit_logs', {
      'id': _idGenerator.next(),
      'workspace_id': workspaceId,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'summary_key': summaryKey,
      'occurred_at_utc': now.toIso8601String(),
      'actor_type': 'localUser',
    });
    await txn.insert('sync_outbox', {
      'id': _idGenerator.next(),
      'workspace_id': workspaceId,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation_id': _idGenerator.next(),
      'operation': action,
      'payload_json': jsonEncode(payload),
      'created_at_utc': now.toIso8601String(),
      'attempt_count': 0,
      'next_attempt_at_utc': now.toIso8601String(),
    });
  }

  PayPeriod _periodFromRow(Map<String, Object?> row) => PayPeriod(
    id: row['id']! as String,
    employerId: row['employer_id'] as String?,
    employerName: row['employer_name'] as String?,
    periodType: payPeriodTypeFromStorage(row['period_type']! as String),
    startAtUtc: DateTime.parse(row['start_at_utc']! as String).toUtc(),
    endAtUtc: DateTime.parse(row['end_at_utc']! as String).toUtc(),
    expectedGrossMinor: row['expected_gross_minor'] as int? ?? 0,
    receivedGrossMinor: row['received_gross_minor'] as int?,
    deductionsMinor: row['deductions_minor'] as int?,
    netPaymentMinor: row['net_payment_minor'] as int?,
    currencyCode: row['currency_code'] as String? ?? 'GBP',
    status: payPeriodStatusFromStorage(row['status'] as String? ?? 'open'),
    confidence: payConfidenceFromStorage(
      row['confidence_state'] as String? ?? 'needsReview',
    ),
    breakdown: PayCalculationBreakdown.fromJson(
      row['calculation_snapshot_json'] as String?,
    ),
    notes: row['notes'] as String?,
    createdAtUtc: DateTime.parse(row['created_at']! as String).toUtc(),
  );

  PayslipRecord _payslipFromRow(Map<String, Object?> row) => PayslipRecord(
    id: row['id']! as String,
    payPeriodId: row['pay_period_id']! as String,
    grossMinor: row['gross_minor'] as int?,
    deductionsMinor: row['deductions_minor'] as int?,
    netMinor: row['net_minor'] as int?,
    payDateUtc: row['pay_date_utc'] == null
        ? null
        : DateTime.parse(row['pay_date_utc']! as String).toUtc(),
    reference: row['reference'] as String?,
    currencyCode: row['currency_code'] as String? ?? 'GBP',
    attachmentId: row['attachment_id'] as String?,
    createdAtUtc: DateTime.parse(row['created_at']! as String).toUtc(),
  );

  PayAdjustment _adjustmentFromRow(Map<String, Object?> row) => PayAdjustment(
    id: row['id']! as String,
    type: row['adjustment_type']! as String,
    label: row['label']! as String,
    amountMinor: row['amount_minor']! as int,
    createdAtUtc: DateTime.parse(row['created_at']! as String).toUtc(),
  );

  EvidenceItem _evidenceFromRow(Map<String, Object?> row) {
    final attachmentId = row['attachment_join_id'] as String?;
    return EvidenceItem(
      id: row['id']! as String,
      type: evidenceTypeFromStorage(row['evidence_type']! as String),
      description: row['user_description'] as String?,
      capturedAtUtc: DateTime.parse(row['captured_at_utc']! as String).toUtc(),
      selectedForExport: (row['selected_for_export'] as int? ?? 1) == 1,
      attachment: attachmentId == null
          ? null
          : EvidenceAttachment(
              id: attachmentId,
              originalFilename: row['original_filename']! as String,
              mimeType: row['mime_type']! as String,
              sizeBytes: row['size_bytes']! as int,
              sha256: row['sha256']! as String,
              localPath: row['local_path']! as String,
              sharedCopyPath: row['shared_copy_path'] as String?,
              sharedCopySha256: row['shared_copy_sha256'] as String?,
              metadataStripped: (row['metadata_stripped'] as int? ?? 0) == 1,
              originalRetained: (row['original_retained'] as int? ?? 1) == 1,
            ),
    );
  }

  String? _blankToNull(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}

final payProtectionRepositoryProvider = Provider<PayProtectionRepository>(
  (ref) => PayProtectionRepository(
    databaseHelper: DatabaseHelper.instance,
    clock: ref.watch(appClockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);
