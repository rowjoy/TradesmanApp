import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../../core/ids/id_generator.dart';
import '../../core/time/app_clock.dart';
import 'customer_model.dart';

class CustomerRepository {
  CustomerRepository({
    required AppClock clock,
    required IdGenerator idGenerator,
  }) : _clock = clock,
       _idGenerator = idGenerator;

  static const _workspaceId = 'local-workspace';
  final AppClock _clock;
  final IdGenerator _idGenerator;

  Future<List<Customer>> getAll({String? query}) async {
    final db = await DatabaseHelper.instance.database;
    final where = query != null && query.isNotEmpty
        ? "deleted_at IS NULL AND (name LIKE ? OR phone LIKE ? OR email LIKE ?)"
        : "deleted_at IS NULL";
    final args = query != null && query.isNotEmpty
        ? ['%$query%', '%$query%', '%$query%']
        : null;
    final rows = await db.query(
      'customers',
      where: where,
      whereArgs: args,
      orderBy: 'name ASC',
    );
    return rows.map((r) => Customer.fromMap(r)).toList();
  }

  Future<Customer> create({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    String? billingCurrencyCode,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    final customer = Customer(
      id: _idGenerator.next(),
      name: name,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
      billingCurrencyCode: billingCurrencyCode,
      createdAt: now,
      updatedAt: now,
    );
    final map = {
      ...customer.toMap(),
      'workspace_id': _workspaceId,
      'local_version': 1,
    };
    await db.transaction((txn) async {
      await txn.insert('customers', map);
      await _writeOutbox(
        txn,
        entityId: customer.id,
        operation: 'create',
        payload: map,
        now: now,
      );
      await txn.insert('audit_logs', {
        'id': _idGenerator.next(),
        'workspace_id': _workspaceId,
        'entity_type': 'customer',
        'entity_id': customer.id,
        'action': 'created',
        'summary_key': 'auditCustomerCreated',
        'occurred_at_utc': now.toIso8601String(),
      });
    });
    return customer;
  }

  Future<Customer?> getById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'customers',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Customer.fromMap(rows.first);
  }

  Future<void> update(Customer customer) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    final map = {
      ...customer.toMap(),
      'workspace_id': _workspaceId,
      'sync_status': 'pendingUpdate',
    };
    await db.transaction((txn) async {
      await txn.update(
        'customers',
        map,
        where: 'id = ?',
        whereArgs: [customer.id],
      );
      await _writeOutbox(
        txn,
        entityId: customer.id,
        operation: 'update',
        payload: map,
        now: now,
      );
      await txn.insert('audit_logs', {
        'id': _idGenerator.next(),
        'workspace_id': _workspaceId,
        'entity_type': 'customer',
        'entity_id': customer.id,
        'action': 'updated',
        'summary_key': 'auditCustomerUpdated',
        'occurred_at_utc': now.toIso8601String(),
      });
    });
  }

  Future<void> softDelete(String id) async {
    final db = await DatabaseHelper.instance.database;
    final now = _clock.nowUtc();
    await db.transaction((txn) async {
      await txn.update(
        'customers',
        {
          'deleted_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'sync_status': 'pendingDelete',
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await _writeOutbox(
        txn,
        entityId: id,
        operation: 'delete',
        payload: const {},
        now: now,
      );
      final operationId = _idGenerator.next();
      await txn.insert('tombstones', {
        'id': _idGenerator.next(),
        'workspace_id': _workspaceId,
        'entity_type': 'customer',
        'entity_id': id,
        'deleted_at_utc': now.toIso8601String(),
        'operation_id': operationId,
      });
      await txn.insert('audit_logs', {
        'id': _idGenerator.next(),
        'workspace_id': _workspaceId,
        'entity_type': 'customer',
        'entity_id': id,
        'action': 'deleted',
        'summary_key': 'auditCustomerDeleted',
        'occurred_at_utc': now.toIso8601String(),
      });
    });
  }

  Future<void> _writeOutbox(
    Transaction txn, {
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    required DateTime now,
  }) async {
    final operationId = _idGenerator.next();
    await txn.insert('sync_outbox', {
      'id': _idGenerator.next(),
      'workspace_id': _workspaceId,
      'entity_type': 'customer',
      'entity_id': entityId,
      'operation_id': operationId,
      'operation': operation,
      'payload_json': jsonEncode(payload),
      'created_at_utc': now.toIso8601String(),
      'attempt_count': 0,
      'next_attempt_at_utc': now.toIso8601String(),
    });
  }

  /// Customer summary: total jobs, revenue, paid, outstanding.
  /// Wired to jobs/invoices once those tables are populated in Phase 2.
  Future<Map<String, dynamic>> getSummary(String customerId) async {
    final db = await DatabaseHelper.instance.database;
    final jobCountResult = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM jobs WHERE customer_id = ? AND deleted_at IS NULL',
      [customerId],
    );
    final jobCount = (jobCountResult.first['cnt'] as int?) ?? 0;
    return {
      'totalJobs': jobCount,
      'revenue': 0.0,
      'paid': 0.0,
      'outstanding': 0.0,
    };
  }
}

final customerRepositoryProvider = Provider(
  (ref) => CustomerRepository(
    clock: ref.watch(appClockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

final customerSearchQueryProvider = StateProvider<String>((ref) => '');

final customersListProvider = FutureProvider<List<Customer>>((ref) async {
  final query = ref.watch(customerSearchQueryProvider);
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getAll(query: query);
});

final allCustomersProvider = FutureProvider<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).getAll();
});
