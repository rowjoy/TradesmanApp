import 'dart:convert';

import '../../../core/database/database_helper.dart';
import '../../../core/money/earnings_calculator.dart';
import '../../../core/money/work_earnings_calculator.dart';
import '../domain/report_models.dart';

class ReportRepository {
  ReportRepository({required DatabaseHelper databaseHelper})
    : _databaseHelper = databaseHelper;

  static const workspaceId = 'local-workspace';
  final DatabaseHelper _databaseHelper;

  Future<OfflineReport> build(ReportFilter filter) async {
    if (!filter.endUtc.isAfter(filter.startUtc)) {
      throw const FormatException('Report end must be after start.');
    }
    final db = await _databaseHelper.database;
    final timeLines = await _timeLines(filter);
    final parties = await _parties(filter.scope);

    var workerRecorded = 0;
    var workerBillable = 0;
    var workerExpected = 0;
    var workerMissing = 0;
    var businessRecorded = 0;
    var businessBillable = 0;
    var businessExpected = 0;
    var businessMissing = 0;
    for (final line in timeLines) {
      if (line.type == ReportLineType.workerTime) {
        workerRecorded += line.recordedSeconds;
        workerBillable += line.billableSeconds;
        workerExpected += line.creditMinor;
        if (line.reference == 'calculation_missing') workerMissing++;
      } else {
        businessRecorded += line.recordedSeconds;
        businessBillable += line.billableSeconds;
        businessExpected += line.creditMinor;
        if (line.reference == 'calculation_missing') businessMissing++;
      }
    }

    final lines = <ReportLine>[...timeLines];
    var workerReceived = 0;
    var workerDeductions = 0;
    var workerNet = 0;
    if (filter.scope != ReportScope.tradesman &&
        filter.partyType != ReportPartyType.customer) {
      final payRows = await _workerPayRows(filter);
      for (final row in payRows) {
        workerReceived += _integer(row['received_gross_minor']);
        workerDeductions += _integer(row['deductions_minor']);
        workerNet += _integer(row['net_payment_minor']);
        final received = _integer(row['received_gross_minor']);
        if (received != 0 || row['net_payment_minor'] != null) {
          lines.add(
            ReportLine(
              id: row['id']! as String,
              type: ReportLineType.payslip,
              occurredAtUtc: DateTime.parse(
                row['payment_at_utc']! as String,
              ).toUtc(),
              title: 'Payslip / pay period',
              partyId: row['employer_id'] as String?,
              partyName: row['employer_name'] as String?,
              reference: row['period_type'] as String?,
              creditMinor: received,
              currencyCode: filter.currencyCode,
            ),
          );
        }
      }
    }

    var invoiced = 0;
    var paid = 0;
    var outstanding = 0;
    var expenses = 0;
    if (filter.scope != ReportScope.worker &&
        filter.partyType != ReportPartyType.employer) {
      final invoiceRows = await _invoiceRows(filter);
      for (final row in invoiceRows) {
        final total = _integer(row['total_minor']);
        final paidForInvoice = _integer(row['calculated_paid_minor']);
        invoiced += total;
        outstanding += (total - paidForInvoice).clamp(0, total).toInt();
        lines.add(
          ReportLine(
            id: row['id']! as String,
            type: ReportLineType.invoice,
            occurredAtUtc: DateTime.parse(
              (row['issued_at'] ?? row['created_at'])! as String,
            ).toUtc(),
            title: row['invoice_number']! as String,
            partyId: row['customer_id'] as String?,
            partyName: row['customer_name'] as String?,
            reference: row['status'] as String?,
            debitMinor: total,
            currencyCode: filter.currencyCode,
          ),
        );
      }

      final paymentRows = await _paymentRows(filter);
      for (final row in paymentRows) {
        final amount = _integer(row['signed_amount_minor']);
        paid += amount;
        lines.add(
          ReportLine(
            id: row['id']! as String,
            type: ReportLineType.payment,
            occurredAtUtc: DateTime.parse(
              row['paid_at_utc']! as String,
            ).toUtc(),
            title: row['reversal_of_payment_id'] == null
                ? 'Payment received'
                : 'Payment reversal',
            partyId: row['customer_id'] as String?,
            partyName: row['customer_name'] as String?,
            reference:
                row['reference'] as String? ?? row['invoice_number'] as String?,
            creditMinor: amount,
            currencyCode: filter.currencyCode,
          ),
        );
      }

      final expenseRows = await _expenseRows(filter);
      for (final row in expenseRows) {
        final amount = _integer(row['amount_minor']);
        expenses += amount;
        lines.add(
          ReportLine(
            id: row['id']! as String,
            type: ReportLineType.expense,
            occurredAtUtc: DateTime.parse(
              row['expense_date']! as String,
            ).toUtc(),
            title: row['description'] as String? ?? row['category']! as String,
            partyId: row['customer_id'] as String?,
            partyName: row['customer_name'] as String?,
            reference: row['category'] as String?,
            debitMinor: amount,
            currencyCode: filter.currencyCode,
          ),
        );
      }
    }

    lines.sort((a, b) => b.occurredAtUtc.compareTo(a.occurredAtUtc));
    return OfflineReport(
      filter: filter,
      generatedAtUtc: DateTime.now().toUtc(),
      worker: WorkerReportSummary(
        recordedSeconds: workerRecorded,
        billableSeconds: workerBillable,
        expectedGrossMinor: workerExpected,
        receivedGrossMinor: workerReceived,
        deductionsMinor: workerDeductions,
        netPaymentMinor: workerNet,
        missingCalculationCount: workerMissing,
      ),
      business: BusinessReportSummary(
        recordedSeconds: businessRecorded,
        billableSeconds: businessBillable,
        billableWorkMinor: businessExpected,
        invoicedMinor: invoiced,
        paidMinor: paid,
        outstandingMinor: outstanding,
        expensesMinor: expenses,
        missingCalculationCount: businessMissing,
      ),
      lines: List.unmodifiable(lines),
      parties: parties,
    );
  }

  Future<List<ReportLine>> _timeLines(ReportFilter filter) async {
    final db = await _databaseHelper.database;
    final clauses = <String>[
      'te.workspace_id = ?',
      'te.deleted_at IS NULL',
      'te.clock_out IS NOT NULL',
      'te.clock_in >= ?',
      'te.clock_in < ?',
      'te.currency_code = ?',
    ];
    final args = <Object?>[
      workspaceId,
      filter.startUtc.toIso8601String(),
      filter.endUtc.toIso8601String(),
      filter.currencyCode,
    ];
    if (filter.scope == ReportScope.worker) {
      clauses.add("te.work_item_type = 'shift'");
    } else if (filter.scope == ReportScope.tradesman) {
      clauses.add("te.work_item_type = 'job'");
    }
    if (filter.partyType == ReportPartyType.employer &&
        filter.partyId != null) {
      clauses.add('s.employer_id = ?');
      args.add(filter.partyId);
    } else if (filter.partyType == ReportPartyType.customer &&
        filter.partyId != null) {
      clauses.add('j.customer_id = ?');
      args.add(filter.partyId);
    }
    final rows = await db.rawQuery('''
      SELECT te.*,
             s.title AS shift_title, s.employer_id,
             e.name AS employer_name,
             j.title AS job_title, j.customer_id,
             c.name AS customer_name
      FROM time_entries te
      LEFT JOIN shifts s ON s.id = te.shift_id AND s.deleted_at IS NULL
      LEFT JOIN employers e ON e.id = s.employer_id AND e.deleted_at IS NULL
      LEFT JOIN jobs j ON j.id = te.job_id AND j.deleted_at IS NULL
      LEFT JOIN customers c ON c.id = j.customer_id AND c.deleted_at IS NULL
      WHERE ${clauses.join(' AND ')}
      ORDER BY te.clock_in DESC
    ''', args);
    return rows
        .map((row) {
          final worker = row['work_item_type'] == 'shift';
          final total = _entryTotal(row);
          final missing =
              row['calculation_snapshot_json'] == null &&
              row['base_rate_minor'] == null &&
              row['fixed_price_minor'] == null;
          return ReportLine(
            id: row['id']! as String,
            type: worker
                ? ReportLineType.workerTime
                : ReportLineType.businessTime,
            occurredAtUtc: DateTime.parse(row['clock_in']! as String).toUtc(),
            title:
                (worker ? row['shift_title'] : row['job_title']) as String? ??
                'Recorded work',
            partyId:
                (worker ? row['employer_id'] : row['customer_id']) as String?,
            partyName:
                (worker ? row['employer_name'] : row['customer_name'])
                    as String?,
            reference: missing ? 'calculation_missing' : null,
            recordedSeconds: _rawSeconds(row),
            billableSeconds: _billableSeconds(row),
            creditMinor: total,
            currencyCode: filter.currencyCode,
          );
        })
        .toList(growable: false);
  }

  int _entryTotal(Map<String, Object?> row) {
    final encoded = row['calculation_snapshot_json'] as String?;
    if (encoded != null && encoded.isNotEmpty) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is Map<String, dynamic>) {
          return (decoded['totalMinor'] as num?)?.toInt() ?? 0;
        }
      } on FormatException {
        // Reproduce from immutable time-entry inputs below.
      }
    }
    final result = const WorkEarningsCalculator().calculate(
      rawSeconds: _rawSeconds(row),
      unpaidBreakSeconds: _integer(row['unpaid_break_seconds']),
      currencyCode: row['currency_code'] as String? ?? 'GBP',
      pricingType: workPricingTypeFromStorage(
        row['pricing_type'] as String? ?? 'hourly',
      ),
      baseRateMinor: row['base_rate_minor'] as int?,
      fixedPriceMinor: row['fixed_price_minor'] as int?,
      extraPayMinor: _integer(row['extra_pay_minor']),
      overtimeAfterSeconds:
          (row['overtime_after_seconds'] as int?) ?? 8 * 60 * 60,
      overtimeMultiplierNumerator:
          (row['overtime_multiplier_numerator'] as int?) ?? 3,
      overtimeMultiplierDenominator:
          (row['overtime_multiplier_denominator'] as int?) ?? 2,
      premiumMultiplierNumerator:
          (row['premium_multiplier_numerator'] as int?) ?? 1,
      premiumMultiplierDenominator:
          (row['premium_multiplier_denominator'] as int?) ?? 1,
      rounding: BillingRoundingRule(
        incrementSeconds: (row['rounding_increment_seconds'] as int?) ?? 60,
        direction: _rounding(row['rounding_direction'] as String?),
      ),
    );
    return result.total.minorUnits;
  }

  Future<List<Map<String, Object?>>> _workerPayRows(ReportFilter filter) async {
    final db = await _databaseHelper.database;
    final employerClause =
        filter.partyType == ReportPartyType.employer && filter.partyId != null
        ? 'AND p.employer_id = ?'
        : '';
    return db.rawQuery(
      '''
      SELECT p.id, p.employer_id, p.period_type,
             COALESCE(ps.pay_date_utc, p.start_at_utc) AS payment_at_utc,
             COALESCE(ps.gross_minor, p.received_gross_minor) AS received_gross_minor,
             COALESCE(ps.deductions_minor, p.deductions_minor) AS deductions_minor,
             COALESCE(ps.net_minor, p.net_payment_minor) AS net_payment_minor,
             e.name AS employer_name
      FROM pay_periods p
      LEFT JOIN employers e ON e.id = p.employer_id AND e.deleted_at IS NULL
      LEFT JOIN payslips ps ON ps.id = (
        SELECT latest.id FROM payslips latest
        WHERE latest.pay_period_id = p.id AND latest.deleted_at IS NULL
        ORDER BY latest.updated_at DESC LIMIT 1
      )
      WHERE p.workspace_id = ? AND p.deleted_at IS NULL
        AND datetime(COALESCE(ps.pay_date_utc, p.start_at_utc)) >= datetime(?)
        AND datetime(COALESCE(ps.pay_date_utc, p.start_at_utc)) < datetime(?)
        AND p.currency_code = ? $employerClause
      ORDER BY payment_at_utc DESC
    ''',
      [
        workspaceId,
        filter.startUtc.toIso8601String(),
        filter.endUtc.toIso8601String(),
        filter.currencyCode,
        if (employerClause.isNotEmpty) filter.partyId,
      ],
    );
  }

  Future<List<Map<String, Object?>>> _invoiceRows(ReportFilter filter) async {
    final db = await _databaseHelper.database;
    final partyClause =
        filter.partyType == ReportPartyType.customer && filter.partyId != null
        ? 'AND i.customer_id = ?'
        : '';
    return db.rawQuery(
      '''
      SELECT i.*, c.name AS customer_name,
             COALESCE((
               SELECT SUM(CASE WHEN p.reversal_of_payment_id IS NULL
                               THEN p.amount_minor ELSE -p.amount_minor END)
               FROM payments p
               WHERE p.invoice_id = i.id AND p.deleted_at IS NULL
             ), i.paid_minor, 0) AS calculated_paid_minor
      FROM invoices i
      JOIN customers c ON c.id = i.customer_id AND c.deleted_at IS NULL
      WHERE i.workspace_id = ? AND i.deleted_at IS NULL
        AND datetime(COALESCE(i.issued_at, i.created_at)) >= datetime(?)
        AND datetime(COALESCE(i.issued_at, i.created_at)) < datetime(?)
        AND COALESCE(c.billing_currency_code, ?) = ? $partyClause
      ORDER BY COALESCE(i.issued_at, i.created_at) DESC
    ''',
      [
        workspaceId,
        filter.startUtc.toIso8601String(),
        filter.endUtc.toIso8601String(),
        filter.currencyCode,
        filter.currencyCode,
        if (partyClause.isNotEmpty) filter.partyId,
      ],
    );
  }

  Future<List<Map<String, Object?>>> _paymentRows(ReportFilter filter) async {
    final db = await _databaseHelper.database;
    final partyClause =
        filter.partyType == ReportPartyType.customer && filter.partyId != null
        ? 'AND i.customer_id = ?'
        : '';
    return db.rawQuery(
      '''
      SELECT p.*,
             CASE WHEN p.reversal_of_payment_id IS NULL
                  THEN p.amount_minor ELSE -p.amount_minor END
               AS signed_amount_minor,
             i.customer_id, i.invoice_number, c.name AS customer_name
      FROM payments p
      JOIN invoices i ON i.id = p.invoice_id AND i.deleted_at IS NULL
      JOIN customers c ON c.id = i.customer_id AND c.deleted_at IS NULL
      WHERE p.workspace_id = ? AND p.deleted_at IS NULL
        AND datetime(p.paid_at_utc) >= datetime(?)
        AND datetime(p.paid_at_utc) < datetime(?)
        AND COALESCE(c.billing_currency_code, ?) = ? $partyClause
      ORDER BY p.paid_at_utc DESC
    ''',
      [
        workspaceId,
        filter.startUtc.toIso8601String(),
        filter.endUtc.toIso8601String(),
        filter.currencyCode,
        filter.currencyCode,
        if (partyClause.isNotEmpty) filter.partyId,
      ],
    );
  }

  Future<List<Map<String, Object?>>> _expenseRows(ReportFilter filter) async {
    final db = await _databaseHelper.database;
    final partyClause =
        filter.partyType == ReportPartyType.customer && filter.partyId != null
        ? 'AND j.customer_id = ?'
        : '';
    return db.rawQuery(
      '''
      SELECT x.id, COALESCE(x.amount_minor, CAST(ROUND(x.amount * 100) AS INTEGER))
               AS amount_minor,
             x.category, x.description, x.expense_date,
             j.customer_id, c.name AS customer_name
      FROM expenses x
      LEFT JOIN jobs j ON j.id = x.job_id AND j.deleted_at IS NULL
      LEFT JOIN customers c ON c.id = j.customer_id AND c.deleted_at IS NULL
      WHERE x.deleted_at IS NULL
        AND datetime(x.expense_date) >= datetime(?)
        AND datetime(x.expense_date) < datetime(?) $partyClause
      ORDER BY x.expense_date DESC
    ''',
      [
        filter.startUtc.toIso8601String(),
        filter.endUtc.toIso8601String(),
        if (partyClause.isNotEmpty) filter.partyId,
      ],
    );
  }

  Future<List<ReportParty>> _parties(ReportScope scope) async {
    final db = await _databaseHelper.database;
    final values = <ReportParty>[];
    if (scope != ReportScope.tradesman) {
      final rows = await db.query(
        'employers',
        columns: ['id', 'name'],
        where: 'workspace_id = ? AND deleted_at IS NULL',
        whereArgs: [workspaceId],
        orderBy: 'name COLLATE NOCASE',
      );
      values.addAll(
        rows.map(
          (row) => ReportParty(
            id: row['id']! as String,
            name: row['name']! as String,
            type: ReportPartyType.employer,
          ),
        ),
      );
    }
    if (scope != ReportScope.worker) {
      final rows = await db.query(
        'customers',
        columns: ['id', 'name'],
        where: 'workspace_id = ? AND deleted_at IS NULL',
        whereArgs: [workspaceId],
        orderBy: 'name COLLATE NOCASE',
      );
      values.addAll(
        rows.map(
          (row) => ReportParty(
            id: row['id']! as String,
            name: row['name']! as String,
            type: ReportPartyType.customer,
          ),
        ),
      );
    }
    return List.unmodifiable(values);
  }

  Future<void> recordExport(
    PreparedReportExport export,
    OfflineReport report,
  ) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.insert('report_exports', {
        'id': export.id,
        'workspace_id': workspaceId,
        'report_kind': report.filter.scope.name,
        'export_format': export.format.name,
        'range_start_utc': report.filter.startUtc.toIso8601String(),
        'range_end_utc': report.filter.endUtc.toIso8601String(),
        'party_type': report.filter.partyType?.name,
        'party_id': report.filter.partyId,
        'currency_code': report.filter.currencyCode,
        'local_path': export.path,
        'sha256': export.sha256,
        'created_at_utc': export.createdAtUtc.toIso8601String(),
      });
      await txn.insert('audit_logs', {
        'id': '${export.id}-audit',
        'workspace_id': workspaceId,
        'entity_type': 'reportExport',
        'entity_id': export.id,
        'action': 'exported',
        'summary_key': 'auditReportExported',
        'metadata_json': jsonEncode({
          'format': export.format.name,
          'sha256': export.sha256,
          'scope': report.filter.scope.name,
        }),
        'occurred_at_utc': export.createdAtUtc.toIso8601String(),
      });
    });
  }
}

int _integer(Object? value) => (value as num?)?.toInt() ?? 0;

int _rawSeconds(Map<String, Object?> row) {
  final stored = row['raw_duration_seconds'] as num?;
  if (stored != null) return stored.toInt();
  final start = DateTime.tryParse(row['clock_in'] as String? ?? '');
  final end = DateTime.tryParse(row['clock_out'] as String? ?? '');
  if (start == null || end == null || !end.isAfter(start)) return 0;
  return end.difference(start).inSeconds;
}

int _billableSeconds(Map<String, Object?> row) {
  final stored = row['billable_duration_seconds'] as num?;
  if (stored != null) return stored.toInt();
  return (_rawSeconds(row) - _integer(row['unpaid_break_seconds']))
      .clamp(0, 1 << 40)
      .toInt();
}

BillingRoundingDirection _rounding(String? value) =>
    BillingRoundingDirection.values.firstWhere(
      (item) => item.name == value,
      orElse: () => BillingRoundingDirection.nearest,
    );
