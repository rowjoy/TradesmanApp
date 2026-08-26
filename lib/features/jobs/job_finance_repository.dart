import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../../core/ids/id_generator.dart';
import '../../core/time/app_clock.dart';

class JobExpenseRecord {
  const JobExpenseRecord({
    required this.id,
    required this.description,
    required this.amountMinor,
    required this.occurredAtUtc,
  });

  final String id;
  final String description;
  final int amountMinor;
  final DateTime occurredAtUtc;
}

class JobPaymentRecord {
  const JobPaymentRecord({
    required this.id,
    required this.amountMinor,
    required this.method,
    required this.paidAtUtc,
    this.reference,
  });

  final String id;
  final int amountMinor;
  final String method;
  final DateTime paidAtUtc;
  final String? reference;
}

class JobInvoiceRecord {
  const JobInvoiceRecord({
    required this.id,
    required this.number,
    required this.subtotalMinor,
    required this.taxMinor,
    required this.totalMinor,
    required this.paidMinor,
  });

  final String id;
  final String number;
  final int subtotalMinor;
  final int taxMinor;
  final int totalMinor;
  final int paidMinor;
}

class JobFinanceLedger {
  const JobFinanceLedger({
    required this.vatBasisPoints,
    required this.expenses,
    required this.payments,
    this.invoice,
    this.signatureBytes,
  });

  const JobFinanceLedger.empty()
    : vatBasisPoints = 0,
      expenses = const [],
      payments = const [],
      invoice = null,
      signatureBytes = null;

  final int vatBasisPoints;
  final List<JobExpenseRecord> expenses;
  final List<JobPaymentRecord> payments;
  final JobInvoiceRecord? invoice;
  final Uint8List? signatureBytes;
}

class JobFinanceRepository {
  JobFinanceRepository({
    required DatabaseHelper databaseHelper,
    required AppClock clock,
    required IdGenerator ids,
  }) : _databaseHelper = databaseHelper,
       _clock = clock,
       _ids = ids;

  static const _workspaceId = 'local-workspace';
  final DatabaseHelper _databaseHelper;
  final AppClock _clock;
  final IdGenerator _ids;

  Future<JobFinanceLedger> load(String jobId) async {
    final db = await _databaseHelper.database;
    final vatRows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_vatKey(jobId)],
      limit: 1,
    );
    final vat = vatRows.isEmpty
        ? 0
        : int.tryParse(vatRows.first['value'] as String? ?? '') ?? 0;
    final expenseRows = await db.query(
      'expenses',
      where: 'job_id = ? AND deleted_at IS NULL',
      whereArgs: [jobId],
      orderBy: 'expense_date DESC',
    );
    final expenses = expenseRows
        .map(
          (row) => JobExpenseRecord(
            id: row['id']! as String,
            description:
                row['description'] as String? ??
                row['category'] as String? ??
                'Expense',
            amountMinor:
                (row['amount_minor'] as num?)?.round() ??
                (((row['amount'] as num?) ?? 0) * 100).round(),
            occurredAtUtc: DateTime.parse(
              row['expense_date']! as String,
            ).toUtc(),
          ),
        )
        .toList(growable: false);

    final invoiceRows = await db.query(
      'invoices',
      where: 'job_id = ? AND deleted_at IS NULL',
      whereArgs: [jobId],
      orderBy: 'COALESCE(issued_at, created_at) DESC',
      limit: 1,
    );
    JobInvoiceRecord? invoice;
    var payments = const <JobPaymentRecord>[];
    if (invoiceRows.isNotEmpty) {
      final row = invoiceRows.first;
      invoice = JobInvoiceRecord(
        id: row['id']! as String,
        number: row['invoice_number']! as String,
        subtotalMinor: (row['subtotal_minor'] as num).round(),
        taxMinor: (row['tax_minor'] as num).round(),
        totalMinor: (row['total_minor'] as num).round(),
        paidMinor: (row['paid_minor'] as num?)?.round() ?? 0,
      );
      final paymentRows = await db.query(
        'payments',
        where:
            'invoice_id = ? AND deleted_at IS NULL AND reversal_of_payment_id IS NULL',
        whereArgs: [invoice.id],
        orderBy: 'paid_at_utc DESC',
      );
      payments = paymentRows
          .map(
            (payment) => JobPaymentRecord(
              id: payment['id']! as String,
              amountMinor: (payment['amount_minor'] as num).round(),
              method: payment['method']! as String,
              paidAtUtc: DateTime.parse(
                payment['paid_at_utc']! as String,
              ).toUtc(),
              reference: payment['reference'] as String?,
            ),
          )
          .toList(growable: false);
    }

    Uint8List? signatureBytes;
    final signatureRows = await db.rawQuery(
      '''
      SELECT a.local_path
      FROM signatures s
      JOIN attachments a ON a.id = s.attachment_id AND a.deleted_at IS NULL
      WHERE s.linked_entity_type = 'job' AND s.linked_entity_id = ?
      ORDER BY s.signed_at_utc DESC
      LIMIT 1
      ''',
      [jobId],
    );
    if (signatureRows.isNotEmpty) {
      final path = signatureRows.first['local_path'] as String?;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) signatureBytes = await file.readAsBytes();
      }
    }
    return JobFinanceLedger(
      vatBasisPoints: vat.clamp(0, 10000).toInt(),
      expenses: expenses,
      payments: payments,
      invoice: invoice,
      signatureBytes: signatureBytes,
    );
  }

  Future<void> saveVatBasisPoints(String jobId, int value) async {
    final db = await _databaseHelper.database;
    await db.insert('app_settings', {
      'key': _vatKey(jobId),
      'value': value.clamp(0, 10000).toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> addExpense({
    required String jobId,
    required String description,
    required int amountMinor,
  }) async {
    if (amountMinor <= 0) throw const FormatException('Invalid expense.');
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    await db.insert('expenses', {
      'id': _ids.next(),
      'job_id': jobId,
      'amount': amountMinor / 100,
      'amount_minor': amountMinor,
      'category': 'job_cost',
      'description': description.trim(),
      'expense_date': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'sync_status': 'localOnly',
      'version': 1,
    });
  }

  Future<void> deleteExpense(String id) async {
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc().toIso8601String();
    await db.update(
      'expenses',
      {'deleted_at': now, 'updated_at': now, 'sync_status': 'pendingDelete'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> issueQuote({
    required String jobId,
    required String customerId,
    required String description,
    required int subtotalMinor,
    required int taxMinor,
    required int totalMinor,
    required Map<String, Object?> snapshot,
  }) async {
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    return db.transaction((txn) async {
      final rows = await txn.query(
        'quotes',
        where: 'job_id = ? AND deleted_at IS NULL',
        whereArgs: [jobId],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      final id = rows.isEmpty ? _ids.next() : rows.first['id']! as String;
      final number = rows.isEmpty
          ? _number('QUO', now, id)
          : rows.first['quote_number']! as String;
      final values = <String, Object?>{
        'workspace_id': _workspaceId,
        'customer_id': customerId,
        'job_id': jobId,
        'quote_number': number,
        'status': 'issued',
        'subtotal_minor': subtotalMinor,
        'tax_minor': taxMinor,
        'total_minor': totalMinor,
        'issued_snapshot_json': jsonEncode(snapshot),
        'updated_at': now.toIso8601String(),
        'issued_at': now.toIso8601String(),
      };
      if (rows.isEmpty) {
        await txn.insert('quotes', {
          'id': id,
          ...values,
          'created_at': now.toIso8601String(),
        });
      } else {
        await txn.update('quotes', values, where: 'id = ?', whereArgs: [id]);
        await txn.delete('quote_items', where: 'quote_id = ?', whereArgs: [id]);
      }
      await txn.insert('quote_items', {
        'id': _ids.next(),
        'quote_id': id,
        'description': description,
        'quantity_millis': 1000,
        'unit_price_minor': subtotalMinor,
        'line_total_minor': subtotalMinor,
        'sort_order': 0,
      });
      return number;
    });
  }

  Future<JobInvoiceRecord> issueInvoice({
    required String jobId,
    required String customerId,
    required String description,
    required int subtotalMinor,
    required int taxMinor,
    required int totalMinor,
    required Map<String, Object?> snapshot,
  }) async {
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    return db.transaction((txn) async {
      final rows = await txn.query(
        'invoices',
        where: 'job_id = ? AND deleted_at IS NULL',
        whereArgs: [jobId],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      final id = rows.isEmpty ? _ids.next() : rows.first['id']! as String;
      final number = rows.isEmpty
          ? _number('INV', now, id)
          : rows.first['invoice_number']! as String;
      final paid = rows.isEmpty
          ? 0
          : (Sqflite.firstIntValue(
                  await txn.rawQuery(
                    '''SELECT COALESCE(SUM(amount_minor), 0) FROM payments
                       WHERE invoice_id = ? AND deleted_at IS NULL
                       AND reversal_of_payment_id IS NULL''',
                    [id],
                  ),
                ) ??
                0);
      final status = paid >= totalMinor && totalMinor > 0
          ? 'paid'
          : paid > 0
          ? 'partiallyPaid'
          : 'issued';
      final values = <String, Object?>{
        'workspace_id': _workspaceId,
        'customer_id': customerId,
        'job_id': jobId,
        'invoice_number': number,
        'status': status,
        'subtotal_minor': subtotalMinor,
        'tax_minor': taxMinor,
        'total_minor': totalMinor,
        'paid_minor': paid,
        'issued_snapshot_json': jsonEncode(snapshot),
        'due_at_utc': now.add(const Duration(days: 14)).toIso8601String(),
        'updated_at': now.toIso8601String(),
        'issued_at': now.toIso8601String(),
      };
      if (rows.isEmpty) {
        await txn.insert('invoices', {
          'id': id,
          ...values,
          'created_at': now.toIso8601String(),
        });
      } else {
        await txn.update('invoices', values, where: 'id = ?', whereArgs: [id]);
        await txn.delete(
          'invoice_items',
          where: 'invoice_id = ?',
          whereArgs: [id],
        );
      }
      await txn.insert('invoice_items', {
        'id': _ids.next(),
        'invoice_id': id,
        'description': description,
        'quantity_millis': 1000,
        'unit_price_minor': subtotalMinor,
        'line_total_minor': subtotalMinor,
        'sort_order': 0,
      });
      return JobInvoiceRecord(
        id: id,
        number: number,
        subtotalMinor: subtotalMinor,
        taxMinor: taxMinor,
        totalMinor: totalMinor,
        paidMinor: paid,
      );
    });
  }

  Future<JobPaymentRecord> addPayment({
    required String invoiceId,
    required int amountMinor,
    required String method,
    String? reference,
  }) async {
    if (amountMinor <= 0) throw const FormatException('Invalid payment.');
    final db = await _databaseHelper.database;
    final now = _clock.nowUtc();
    final payment = JobPaymentRecord(
      id: _ids.next(),
      amountMinor: amountMinor,
      method: method,
      paidAtUtc: now,
      reference: reference?.trim(),
    );
    await db.transaction((txn) async {
      await txn.insert('payments', {
        'id': payment.id,
        'workspace_id': _workspaceId,
        'invoice_id': invoiceId,
        'amount_minor': amountMinor,
        'method': method,
        'paid_at_utc': now.toIso8601String(),
        'reference': payment.reference,
        'created_at': now.toIso8601String(),
      });
      final rows = await txn.query(
        'invoices',
        columns: ['total_minor'],
        where: 'id = ?',
        whereArgs: [invoiceId],
        limit: 1,
      );
      final total = rows.isEmpty
          ? 0
          : (rows.first['total_minor'] as num).round();
      final paid = Sqflite.firstIntValue(
            await txn.rawQuery(
              '''SELECT COALESCE(SUM(amount_minor), 0) FROM payments
                 WHERE invoice_id = ? AND deleted_at IS NULL
                 AND reversal_of_payment_id IS NULL''',
              [invoiceId],
            ),
          ) ??
          0;
      await txn.update(
        'invoices',
        {
          'paid_minor': paid,
          'status': paid >= total && total > 0 ? 'paid' : 'partiallyPaid',
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
    });
    return payment;
  }

  Future<String> issueReceipt(
    JobPaymentRecord payment,
    Map<String, Object?> snapshot,
  ) async {
    final db = await _databaseHelper.database;
    final existing = await db.query(
      'receipts',
      columns: ['receipt_number'],
      where: 'payment_id = ? AND cancelled_at_utc IS NULL',
      whereArgs: [payment.id],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['receipt_number']! as String;
    }
    final now = _clock.nowUtc();
    final id = _ids.next();
    final number = _number('RCT', now, id);
    await db.insert('receipts', {
      'id': id,
      'workspace_id': _workspaceId,
      'payment_id': payment.id,
      'receipt_number': number,
      'issued_snapshot_json': jsonEncode(snapshot),
      'issued_at_utc': now.toIso8601String(),
    });
    return number;
  }

  Future<void> saveSignature(String jobId, Uint8List bytes) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(
      p.join(root.path, 'workproof', 'evidence', 'signatures'),
    );
    await directory.create(recursive: true);
    final now = _clock.nowUtc();
    final attachmentId = _ids.next();
    final filename = 'job_${_token(jobId)}_${_token(attachmentId)}.png';
    final path = p.join(directory.path, filename);
    await File(path).writeAsBytes(bytes, flush: true);
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.insert('attachments', {
        'id': attachmentId,
        'workspace_id': _workspaceId,
        'original_filename': filename,
        'mime_type': 'image/png',
        'size_bytes': bytes.length,
        'sha256': sha256.convert(bytes).toString(),
        'local_path': path,
        'sync_state': 'localOnly',
        'captured_at_utc': now.toIso8601String(),
      });
      await txn.insert('signatures', {
        'id': _ids.next(),
        'workspace_id': _workspaceId,
        'linked_entity_type': 'job',
        'linked_entity_id': jobId,
        'attachment_id': attachmentId,
        'signer_label': 'Customer / authorised signer',
        'signed_at_utc': now.toIso8601String(),
        'created_at': now.toIso8601String(),
      });
    });
  }

  String _vatKey(String jobId) => 'job_vat_basis_points_v1:$jobId';

  String _number(String prefix, DateTime value, String id) {
    final local = value.toLocal();
    final date = '${local.year.toString().padLeft(4, '0')}'
        '${local.month.toString().padLeft(2, '0')}'
        '${local.day.toString().padLeft(2, '0')}';
    return '$prefix-$date-${_token(id).toUpperCase()}';
  }

  String _token(String value) {
    final safe = value.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    return safe.length <= 8 ? safe : safe.substring(0, 8);
  }
}

final jobFinanceRepositoryProvider = Provider(
  (ref) => JobFinanceRepository(
    databaseHelper: DatabaseHelper.instance,
    clock: ref.watch(appClockProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);
