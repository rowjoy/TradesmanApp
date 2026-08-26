import 'dart:convert';

import '../../../core/database/database_helper.dart';
import '../../../core/money/work_earnings_calculator.dart';
import '../domain/entities/money_summary.dart';

class MoneySummaryRepository {
  MoneySummaryRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;
  Future<MoneySummary> load({required String currencyCode}) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery('''
      SELECT t.id, t.work_item_type, t.job_id, t.shift_id,
             t.clock_in, t.clock_out, t.billable_duration_seconds,
             t.calculation_snapshot_json,
             j.pricing_type AS job_pricing_type,
             j.hourly_rate_minor AS job_hourly_rate_minor,
             j.fixed_price_minor AS job_fixed_price_minor,
             s.hourly_rate_minor AS shift_hourly_rate_minor
      FROM time_entries t
      LEFT JOIN jobs j ON j.id = t.job_id AND j.deleted_at IS NULL
      LEFT JOIN shifts s ON s.id = t.shift_id AND s.deleted_at IS NULL
      WHERE t.deleted_at IS NULL
        AND t.clock_out IS NOT NULL
        AND t.status = 'completed'
      ORDER BY t.clock_in ASC
    ''');

    var expectedMinor = 0;
    var trackedSeconds = 0;
    final fixedWorkItemsAdded = <String>{};
    final dailyWorkDaysAdded = <String>{};

    for (final row in rows) {
      final rawSnapshot = row['calculation_snapshot_json'] as String?;
      final snapshot = _decodeSnapshot(rawSnapshot);
      final start = DateTime.parse(row['clock_in']! as String);
      final pricingType = workPricingTypeFromStorage(
        row['job_pricing_type'] as String? ?? 'hourly',
      );
      var regularMinor = 0;
      var overtimeMinor = 0;
      var premiumMinor = 0;
      var extraMinor = 0;
      var fixedMinor = 0;
      if (snapshot != null) {
        trackedSeconds +=
            _snapshotInt(snapshot, 'billableSeconds') ??
            row['billable_duration_seconds'] as int? ??
            0;
        regularMinor = _snapshotInt(snapshot, 'regularPayMinor') ?? 0;
        overtimeMinor = _snapshotInt(snapshot, 'overtimePayMinor') ?? 0;
        premiumMinor = _snapshotInt(snapshot, 'premiumPayMinor') ?? 0;
        extraMinor = _snapshotInt(snapshot, 'extraPayMinor') ?? 0;
        fixedMinor = _snapshotInt(snapshot, 'fixedPayMinor') ?? 0;
      } else {
        final end = DateTime.parse(row['clock_out']! as String);
        final rawSeconds = end
            .difference(start)
            .inSeconds
            .clamp(0, 1 << 31)
            .toInt();
        final breaks = await db.rawQuery(
          '''
          SELECT break_start, break_end
          FROM break_entries
          WHERE time_entry_id = ? AND deleted_at IS NULL
            AND is_paid = 0 AND break_end IS NOT NULL
          ''',
          [row['id']],
        );
        final unpaidSeconds = breaks.fold<int>(0, (total, item) {
          final breakStart = DateTime.parse(item['break_start']! as String);
          final breakEnd = DateTime.parse(item['break_end']! as String);
          final overlapStart = breakStart.isAfter(start) ? breakStart : start;
          final overlapEnd = breakEnd.isBefore(end) ? breakEnd : end;
          return total +
              overlapEnd
                  .difference(overlapStart)
                  .inSeconds
                  .clamp(0, 1 << 31)
                  .toInt();
        });
        final result = const WorkEarningsCalculator().calculate(
          rawSeconds: rawSeconds,
          unpaidBreakSeconds: unpaidSeconds,
          currencyCode: currencyCode,
          pricingType: pricingType,
          baseRateMinor:
              row['job_hourly_rate_minor'] as int? ??
              row['shift_hourly_rate_minor'] as int?,
          fixedPriceMinor: row['job_fixed_price_minor'] as int?,
        );
        trackedSeconds += result.billableSeconds;
        regularMinor = result.regularPay.minorUnits;
        overtimeMinor = result.overtimePay.minorUnits;
        premiumMinor = result.premiumPay.minorUnits;
        extraMinor = result.extraPay.minorUnits;
        fixedMinor = result.fixedPay.minorUnits;
      }

      final workId = row['work_item_type'] == 'shift'
          ? row['shift_id'] as String?
          : row['job_id'] as String?;
      final workKey = '${row['work_item_type']}:${workId ?? row['id']}';
      if (pricingType != WorkPricingType.daily ||
          dailyWorkDaysAdded.add('$workKey:${_localDay(start)}')) {
        expectedMinor += regularMinor + overtimeMinor + premiumMinor;
      }
      expectedMinor += extraMinor;
      if (fixedMinor > 0 &&
          fixedWorkItemsAdded.add(workKey)) {
        expectedMinor += fixedMinor;
      }
    }

    final invoiceRows = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(i.total_minor), 0) AS invoiced_minor,
             COALESCE(SUM(COALESCE((
               SELECT SUM(CASE WHEN p.reversal_of_payment_id IS NULL
                               THEN p.amount_minor ELSE -p.amount_minor END)
               FROM payments p
               WHERE p.invoice_id = i.id AND p.deleted_at IS NULL
             ), i.paid_minor, 0)), 0) AS paid_minor,
             COALESCE(SUM(CASE WHEN i.total_minor > COALESCE((
                               SELECT SUM(CASE WHEN p.reversal_of_payment_id IS NULL
                                               THEN p.amount_minor ELSE -p.amount_minor END)
                               FROM payments p
                               WHERE p.invoice_id = i.id AND p.deleted_at IS NULL
                             ), i.paid_minor, 0)
                               THEN i.total_minor - COALESCE((
                                 SELECT SUM(CASE WHEN p.reversal_of_payment_id IS NULL
                                                 THEN p.amount_minor ELSE -p.amount_minor END)
                                 FROM payments p
                                 WHERE p.invoice_id = i.id AND p.deleted_at IS NULL
                               ), i.paid_minor, 0)
                               ELSE 0 END), 0)
               AS outstanding_minor
      FROM invoices i
      JOIN customers c ON c.id = i.customer_id AND c.deleted_at IS NULL
      WHERE i.deleted_at IS NULL
        AND COALESCE(c.billing_currency_code, ?) = ?
      ''',
      [currencyCode, currencyCode],
    );
    final expenseRows = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(COALESCE(x.amount_minor,
                    CAST(ROUND(x.amount * 100) AS INTEGER))), 0) AS expenses_minor
      FROM expenses x
      LEFT JOIN jobs j ON j.id = x.job_id AND j.deleted_at IS NULL
      LEFT JOIN customers c ON c.id = j.customer_id AND c.deleted_at IS NULL
      WHERE x.deleted_at IS NULL
        AND COALESCE(c.billing_currency_code, ?) = ?
      ''',
      [currencyCode, currencyCode],
    );
    final invoice = invoiceRows.first;
    final expense = expenseRows.first;
    return MoneySummary(
      expectedEarningsMinor: expectedMinor,
      trackedSeconds: trackedSeconds,
      completedEntries: rows.length,
      currencyCode: currencyCode,
      invoicedMinor: (invoice['invoiced_minor'] as num?)?.round() ?? 0,
      paidMinor: (invoice['paid_minor'] as num?)?.round() ?? 0,
      outstandingMinor: (invoice['outstanding_minor'] as num?)?.round() ?? 0,
      expensesMinor: (expense['expenses_minor'] as num?)?.round() ?? 0,
    );
  }
}

Map<String, dynamic>? _decodeSnapshot(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

int? _snapshotInt(Map<String, dynamic> snapshot, String key) {
  final value = snapshot[key];
  return value is num ? value.round() : null;
}

String _localDay(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
