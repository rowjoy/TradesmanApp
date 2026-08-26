import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Authoritative offline SQLite database for WorkProof.
///
/// Version 9 preserves earlier rows and adds local report-export audit rows.
/// No user record or legacy evidence file is rewritten by this migration.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static const int schemaVersion = 9;

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = await databaseFilePath;
    return openDatabase(
      path,
      version: schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.rawQuery('PRAGMA journal_mode = WAL');
        // await db.execute('PRAGMA busy_timeout = 5000');
      },
      onCreate: (db, version) async {
        await _createPrototypeSchema(db);
        await _migrateV1ToV2(db);
        await _migrateV2ToV3(db);
        await _migrateV3ToV4(db);
        await _migrateV4ToV5(db);
        await _migrateV5ToV6(db);
        await _migrateV6ToV7(db);
        await _migrateV7ToV8(db);
        await _migrateV8ToV9(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _migrateV1ToV2(db);
        if (oldVersion < 3) await _migrateV2ToV3(db);
        if (oldVersion < 4) await _migrateV3ToV4(db);
        if (oldVersion < 5) await _migrateV4ToV5(db);
        if (oldVersion < 6) await _migrateV5ToV6(db);
        if (oldVersion < 7) await _migrateV6ToV7(db);
        if (oldVersion < 8) await _migrateV7ToV8(db);
        if (oldVersion < 9) await _migrateV8ToV9(db);
      },
    );
  }

  Future<String> get databaseFilePath async {
    final dbPath = await getDatabasesPath();
    // Keep the prototype filename so an in-place upgrade preserves user data.
    return join(dbPath, 'tradesman_manager.db');
  }

  Future<void> close() async {
    final current = _db;
    _db = null;
    await current?.close();
  }

  Future<void> reopenAndValidate() async {
    await close();
    final reopened = await database;
    final integrity = await reopened.rawQuery('PRAGMA integrity_check');
    if (integrity.isEmpty || integrity.first.values.first != 'ok') {
      throw StateError('Database integrity check failed.');
    }
  }

  Future<File> createConsistentSnapshot(File destination) async {
    await destination.parent.create(recursive: true);
    if (await destination.exists()) await destination.delete();
    final current = await database;
    final escaped = destination.path.replaceAll("'", "''");
    try {
      // SQLite creates a transactionally consistent compact snapshot.
      await current.execute("VACUUM INTO '$escaped'");
    } on DatabaseException {
      // Older Android SQLite builds do not support VACUUM INTO. A full WAL
      // checkpoint followed by a short close/copy/reopen window is the safe
      // compatibility path.
      await current.rawQuery('PRAGMA wal_checkpoint(FULL)');
      await close();
      try {
        await File(await databaseFilePath).copy(destination.path);
      } finally {
        await database;
      }
    }
    return destination;
  }

  Future<void> _createPrototypeSchema(Database db) async {
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('CREATE INDEX idx_customers_name ON customers(name)');

    await db.execute('''
      CREATE TABLE services (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        default_rate REAL,
        default_duration_minutes INTEGER,
        tax_rate REAL DEFAULT 0,
        is_custom INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE jobs (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        service_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        address TEXT,
        scheduled_date TEXT,
        start_time TEXT,
        estimated_duration_minutes INTEGER,
        priority TEXT DEFAULT 'normal',
        pricing_type TEXT NOT NULL DEFAULT 'hourly',
        hourly_rate REAL,
        fixed_price REAL,
        status TEXT NOT NULL DEFAULT 'scheduled',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (customer_id) REFERENCES customers(id),
        FOREIGN KEY (service_id) REFERENCES services(id)
      )
    ''');
    await db.execute('CREATE INDEX idx_jobs_customer ON jobs(customer_id)');
    await db.execute('CREATE INDEX idx_jobs_status ON jobs(status)');
    await db.execute('CREATE INDEX idx_jobs_date ON jobs(scheduled_date)');

    await db.execute('''
      CREATE TABLE time_entries (
        id TEXT PRIMARY KEY,
        job_id TEXT NOT NULL,
        clock_in TEXT NOT NULL,
        clock_out TEXT,
        status TEXT NOT NULL DEFAULT 'running',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (job_id) REFERENCES jobs(id)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_time_entries_job ON time_entries(job_id)',
    );

    await db.execute('''
      CREATE TABLE break_entries (
        id TEXT PRIMARY KEY,
        time_entry_id TEXT NOT NULL,
        break_start TEXT NOT NULL,
        break_end TEXT,
        is_paid INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (time_entry_id) REFERENCES time_entries(id)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_break_entries_time_entry ON break_entries(time_entry_id)',
    );

    await db.execute('''
      CREATE TABLE materials (
        id TEXT PRIMARY KEY,
        job_id TEXT NOT NULL,
        item TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        unit_price REAL NOT NULL DEFAULT 0,
        supplier TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (job_id) REFERENCES jobs(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        job_id TEXT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        receipt_photo_path TEXT,
        expense_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await _seedDefaultServices(db);
  }

  Future<void> _migrateV1ToV2(Database db) async {
    await _addColumnIfMissing(db, 'customers', 'workspace_id', 'TEXT');
    await _addColumnIfMissing(
      db,
      'customers',
      'local_version',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(db, 'customers', 'server_version', 'INTEGER');
    await _addColumnIfMissing(db, 'customers', 'last_synced_at', 'TEXT');

    await _addColumnIfMissing(db, 'services', 'workspace_id', 'TEXT');
    await _addColumnIfMissing(db, 'services', 'default_rate_minor', 'INTEGER');
    await _addColumnIfMissing(
      db,
      'services',
      'tax_basis_points',
      'INTEGER NOT NULL DEFAULT 0',
    );

    await _addColumnIfMissing(db, 'jobs', 'workspace_id', 'TEXT');
    await _addColumnIfMissing(db, 'jobs', 'start_at_utc', 'TEXT');
    await _addColumnIfMissing(db, 'jobs', 'end_at_utc', 'TEXT');
    await _addColumnIfMissing(
      db,
      'jobs',
      'iana_time_zone',
      "TEXT NOT NULL DEFAULT 'Etc/UTC'",
    );
    await _addColumnIfMissing(db, 'jobs', 'hourly_rate_minor', 'INTEGER');
    await _addColumnIfMissing(db, 'jobs', 'fixed_price_minor', 'INTEGER');
    await _addColumnIfMissing(
      db,
      'jobs',
      'local_version',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(db, 'jobs', 'server_version', 'INTEGER');
    await _addColumnIfMissing(db, 'jobs', 'last_synced_at', 'TEXT');

    await _addColumnIfMissing(db, 'materials', 'unit_price_minor', 'INTEGER');
    await _addColumnIfMissing(db, 'expenses', 'amount_minor', 'INTEGER');

    await db.execute('''
      UPDATE jobs
      SET hourly_rate_minor = CAST(ROUND(hourly_rate * 100) AS INTEGER)
      WHERE hourly_rate_minor IS NULL AND hourly_rate IS NOT NULL
    ''');
    await db.execute('''
      UPDATE jobs
      SET fixed_price_minor = CAST(ROUND(fixed_price * 100) AS INTEGER)
      WHERE fixed_price_minor IS NULL AND fixed_price IS NOT NULL
    ''');
    await db.execute('''
      UPDATE services
      SET default_rate_minor = CAST(ROUND(default_rate * 100) AS INTEGER)
      WHERE default_rate_minor IS NULL AND default_rate IS NOT NULL
    ''');
    await db.execute('''
      UPDATE materials
      SET unit_price_minor = CAST(ROUND(unit_price * 100) AS INTEGER)
      WHERE unit_price_minor IS NULL
    ''');
    await db.execute('''
      UPDATE expenses
      SET amount_minor = CAST(ROUND(amount * 100) AS INTEGER)
      WHERE amount_minor IS NULL
    ''');

    await _createFoundationTables(db);
    await _createFoundationIndexes(db);

    await db.execute('''
      INSERT OR IGNORE INTO sync_outbox (
        id, workspace_id, entity_type, entity_id, operation_id, operation,
        payload_json, created_at_utc, attempt_count, next_attempt_at_utc, last_error
      )
      SELECT id, 'local-workspace', entity_type, entity_id, id, operation,
             payload, created_at, retry_count, created_at, last_error
      FROM sync_queue
    ''');
  }

  Future<void> _createFoundationTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS profiles (
        id TEXT PRIMARY KEY,
        language_code TEXT NOT NULL,
        work_mode TEXT NOT NULL,
        country_code TEXT NOT NULL,
        currency_code TEXT NOT NULL,
        profession TEXT NOT NULL,
        pay_method TEXT NOT NULL,
        default_rate_minor INTEGER,
        theme_mode TEXT NOT NULL,
        demo_data_loaded INTEGER NOT NULL DEFAULT 0,
        onboarding_completed INTEGER NOT NULL DEFAULT 0,
        created_at_utc TEXT NOT NULL,
        updated_at_utc TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS workspaces (
        id TEXT PRIMARY KEY,
        owner_profile_id TEXT NOT NULL,
        name TEXT NOT NULL,
        mode TEXT NOT NULL,
        country_code TEXT NOT NULL,
        currency_code TEXT NOT NULL,
        created_at_utc TEXT NOT NULL,
        updated_at_utc TEXT NOT NULL,
        deleted_at TEXT,
        local_version INTEGER NOT NULL DEFAULT 1,
        server_version INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'localOnly',
        last_synced_at TEXT,
        FOREIGN KEY (owner_profile_id) REFERENCES profiles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS workspace_members (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        profile_id TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at_utc TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id),
        FOREIGN KEY (profile_id) REFERENCES profiles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS employers (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        name TEXT NOT NULL,
        contact_name TEXT,
        phone TEXT,
        email TEXT,
        pay_schedule TEXT,
        contract_notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        local_version INTEGER NOT NULL DEFAULT 1,
        server_version INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        last_synced_at TEXT,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS workplaces (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        employer_id TEXT NOT NULL,
        name TEXT NOT NULL,
        address TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        local_version INTEGER NOT NULL DEFAULT 1,
        server_version INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        last_synced_at TEXT,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id),
        FOREIGN KEY (employer_id) REFERENCES employers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS shifts (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        employer_id TEXT,
        workplace_id TEXT,
        title TEXT NOT NULL,
        start_at_utc TEXT NOT NULL,
        end_at_utc TEXT NOT NULL,
        iana_time_zone TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        local_version INTEGER NOT NULL DEFAULT 1,
        server_version INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        last_synced_at TEXT,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id),
        FOREIGN KEY (employer_id) REFERENCES employers(id),
        FOREIGN KEY (workplace_id) REFERENCES workplaces(id),
        CHECK (end_at_utc > start_at_utc)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS rate_rules (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        linked_entity_type TEXT NOT NULL,
        linked_entity_id TEXT,
        name TEXT NOT NULL,
        rate_minor INTEGER NOT NULL,
        multiplier_numerator INTEGER NOT NULL DEFAULT 1,
        multiplier_denominator INTEGER NOT NULL DEFAULT 1,
        threshold_seconds INTEGER,
        effective_from_utc TEXT,
        effective_to_utc TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pay_periods (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        employer_id TEXT,
        period_type TEXT NOT NULL,
        start_at_utc TEXT NOT NULL,
        end_at_utc TEXT NOT NULL,
        expected_gross_minor INTEGER NOT NULL DEFAULT 0,
        received_gross_minor INTEGER,
        deductions_minor INTEGER,
        net_payment_minor INTEGER,
        calculation_engine_version INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id),
        FOREIGN KEY (employer_id) REFERENCES employers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS payslips (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        pay_period_id TEXT NOT NULL,
        gross_minor INTEGER,
        deductions_minor INTEGER,
        net_minor INTEGER,
        attachment_id TEXT,
        user_confirmed INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id),
        FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pay_adjustments (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        pay_period_id TEXT NOT NULL,
        adjustment_type TEXT NOT NULL,
        label TEXT NOT NULL,
        amount_minor INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id),
        FOREIGN KEY (pay_period_id) REFERENCES pay_periods(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS quotes (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        customer_id TEXT NOT NULL,
        job_id TEXT,
        quote_number TEXT NOT NULL,
        status TEXT NOT NULL,
        subtotal_minor INTEGER NOT NULL,
        tax_minor INTEGER NOT NULL,
        total_minor INTEGER NOT NULL,
        issued_snapshot_json TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        issued_at TEXT,
        deleted_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers(id),
        FOREIGN KEY (job_id) REFERENCES jobs(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS quote_items (
        id TEXT PRIMARY KEY,
        quote_id TEXT NOT NULL,
        description TEXT NOT NULL,
        quantity_millis INTEGER NOT NULL,
        unit_price_minor INTEGER NOT NULL,
        line_total_minor INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        FOREIGN KEY (quote_id) REFERENCES quotes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoices (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        customer_id TEXT NOT NULL,
        job_id TEXT,
        invoice_number TEXT NOT NULL,
        status TEXT NOT NULL,
        subtotal_minor INTEGER NOT NULL,
        tax_minor INTEGER NOT NULL,
        total_minor INTEGER NOT NULL,
        paid_minor INTEGER NOT NULL DEFAULT 0,
        issued_snapshot_json TEXT,
        due_at_utc TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        issued_at TEXT,
        deleted_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers(id),
        FOREIGN KEY (job_id) REFERENCES jobs(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoice_items (
        id TEXT PRIMARY KEY,
        invoice_id TEXT NOT NULL,
        description TEXT NOT NULL,
        quantity_millis INTEGER NOT NULL,
        unit_price_minor INTEGER NOT NULL,
        line_total_minor INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        invoice_id TEXT,
        amount_minor INTEGER NOT NULL CHECK (amount_minor > 0),
        method TEXT NOT NULL,
        paid_at_utc TEXT NOT NULL,
        reference TEXT,
        reversal_of_payment_id TEXT,
        created_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id),
        FOREIGN KEY (reversal_of_payment_id) REFERENCES payments(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS receipts (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        payment_id TEXT NOT NULL,
        receipt_number TEXT NOT NULL,
        issued_snapshot_json TEXT NOT NULL,
        issued_at_utc TEXT NOT NULL,
        cancelled_at_utc TEXT,
        FOREIGN KEY (payment_id) REFERENCES payments(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS attachments (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        original_filename TEXT NOT NULL,
        mime_type TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        sha256 TEXT NOT NULL,
        local_path TEXT NOT NULL,
        cloud_object_path TEXT,
        sync_state TEXT NOT NULL DEFAULT 'localOnly',
        captured_at_utc TEXT NOT NULL,
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS evidence_items (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        linked_entity_type TEXT NOT NULL,
        linked_entity_id TEXT NOT NULL,
        evidence_type TEXT NOT NULL,
        attachment_id TEXT,
        user_description TEXT,
        captured_at_utc TEXT NOT NULL,
        created_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (attachment_id) REFERENCES attachments(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS signatures (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        linked_entity_type TEXT NOT NULL,
        linked_entity_id TEXT NOT NULL,
        attachment_id TEXT NOT NULL,
        signer_label TEXT,
        signed_at_utc TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (attachment_id) REFERENCES attachments(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        notification_type TEXT NOT NULL,
        source_start_at_utc TEXT,
        source_end_at_utc TEXT,
        iana_time_zone TEXT NOT NULL,
        requested_local_time TEXT,
        offset_seconds INTEGER,
        os_notification_id INTEGER,
        payload_version INTEGER NOT NULL,
        scheduler_version INTEGER NOT NULL,
        status TEXT NOT NULL,
        last_scheduled_at TEXT,
        last_error_code TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE (os_notification_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notification_deliveries (
        id TEXT PRIMARY KEY,
        notification_id TEXT NOT NULL,
        occurrence_id TEXT NOT NULL UNIQUE,
        scheduled_for_utc TEXT NOT NULL,
        delivered_at_utc TEXT,
        opened_at_utc TEXT,
        status TEXT NOT NULL,
        FOREIGN KEY (notification_id) REFERENCES notifications(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS job_alert_preferences (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        category TEXT NOT NULL,
        enabled INTEGER NOT NULL,
        offset_seconds INTEGER,
        quiet_start_minutes INTEGER NOT NULL DEFAULT 1320,
        quiet_end_minutes INTEGER NOT NULL DEFAULT 420,
        private_lock_screen_text INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL,
        UNIQUE (workspace_id, category)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS motivation_settings (
        workspace_id TEXT PRIMARY KEY,
        enabled INTEGER NOT NULL DEFAULT 0,
        delivery_time_minutes INTEGER NOT NULL DEFAULT 420,
        tone TEXT NOT NULL DEFAULT 'calm',
        allowed_days_mask INTEGER NOT NULL DEFAULT 127,
        paused_until_utc TEXT,
        private_lock_screen_text INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS motivation_messages (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        tone TEXT NOT NULL,
        message TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS country_packs (
        id TEXT PRIMARY KEY,
        country_code TEXT NOT NULL,
        content_version INTEGER NOT NULL,
        effective_date TEXT NOT NULL,
        last_reviewed_date TEXT NOT NULL,
        source_url TEXT NOT NULL,
        content_json TEXT NOT NULL,
        installed_at_utc TEXT NOT NULL,
        UNIQUE (country_code, content_version)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS drafts (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        draft_type TEXT NOT NULL,
        linked_entity_id TEXT,
        payload_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        expires_at_utc TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_outbox (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation_id TEXT NOT NULL UNIQUE,
        operation TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        created_at_utc TEXT NOT NULL,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        next_attempt_at_utc TEXT NOT NULL,
        last_error TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_cursors (
        workspace_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        cursor TEXT,
        updated_at_utc TEXT NOT NULL,
        PRIMARY KEY (workspace_id, entity_type)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_conflicts (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        local_payload_json TEXT NOT NULL,
        server_payload_json TEXT NOT NULL,
        detected_at_utc TEXT NOT NULL,
        resolved_at_utc TEXT,
        resolution TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tombstones (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        deleted_at_utc TEXT NOT NULL,
        operation_id TEXT NOT NULL UNIQUE,
        synced_at_utc TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS backup_history (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        backup_type TEXT NOT NULL,
        status TEXT NOT NULL,
        destination_label TEXT,
        schema_version INTEGER NOT NULL,
        record_counts_json TEXT,
        sha256 TEXT,
        started_at_utc TEXT NOT NULL,
        completed_at_utc TEXT,
        error_code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action TEXT NOT NULL,
        summary_key TEXT NOT NULL,
        metadata_json TEXT,
        occurred_at_utc TEXT NOT NULL,
        actor_type TEXT NOT NULL DEFAULT 'localUser'
      )
    ''');
  }

  /// Module 02 migration: people directories and schedules remain editable
  /// offline while retaining the exact wall-clock values and offsets entered.
  /// Separate start/end offsets allow a DST transition to be represented
  /// without changing the original local dates or the elapsed UTC duration.
  Future<void> _migrateV2ToV3(Database db) async {
    await _addColumnIfMissing(db, 'employers', 'default_rate_minor', 'INTEGER');
    await _addColumnIfMissing(db, 'employers', 'official_reference', 'TEXT');
    await _addColumnIfMissing(
      db,
      'workplaces',
      'iana_time_zone',
      "TEXT NOT NULL DEFAULT 'Europe/London'",
    );

    for (final table in ['jobs', 'shifts']) {
      await _addColumnIfMissing(db, table, 'start_local', 'TEXT');
      await _addColumnIfMissing(db, table, 'end_local', 'TEXT');
      await _addColumnIfMissing(db, table, 'start_offset_minutes', 'INTEGER');
      await _addColumnIfMissing(db, table, 'end_offset_minutes', 'INTEGER');
      await _addColumnIfMissing(
        db,
        table,
        'reminders_enabled',
        'INTEGER NOT NULL DEFAULT 1',
      );
    }
    await _addColumnIfMissing(db, 'shifts', 'hourly_rate_minor', 'INTEGER');
    await _addColumnIfMissing(
      db,
      'shifts',
      'break_minutes',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      'shifts',
      'break_is_paid',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      'services',
      'pricing_type',
      "TEXT NOT NULL DEFAULT 'hourly'",
    );
    await _addColumnIfMissing(
      db,
      'services',
      'local_version',
      'INTEGER NOT NULL DEFAULT 1',
    );

    await db.execute('''
      UPDATE jobs
      SET start_local = COALESCE(start_local, start_at_utc, scheduled_date),
          end_local = COALESCE(end_local, end_at_utc),
          start_offset_minutes = COALESCE(start_offset_minutes, 0),
          end_offset_minutes = COALESCE(end_offset_minutes, 0)
      WHERE start_local IS NULL OR start_offset_minutes IS NULL
    ''');
    await db.execute('''
      UPDATE shifts
      SET start_local = COALESCE(start_local, start_at_utc),
          end_local = COALESCE(end_local, end_at_utc),
          start_offset_minutes = COALESCE(start_offset_minutes, 0),
          end_offset_minutes = COALESCE(end_offset_minutes, 0)
      WHERE start_local IS NULL OR start_offset_minutes IS NULL
    ''');

    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_workplaces_workspace_name ON workplaces(workspace_id, name)',
      'CREATE INDEX IF NOT EXISTS idx_services_workspace_name ON services(workspace_id, name)',
      'CREATE INDEX IF NOT EXISTS idx_jobs_workspace_end ON jobs(workspace_id, end_at_utc)',
      'CREATE INDEX IF NOT EXISTS idx_shifts_workspace_end ON shifts(workspace_id, end_at_utc)',
      'CREATE INDEX IF NOT EXISTS idx_drafts_type ON drafts(workspace_id, draft_type, linked_entity_id)',
    ];
    for (final statement in indexes) {
      await db.execute(statement);
    }
  }

  /// Rebuild the two prototype timer tables without losing existing rows.
  /// The original `job_id NOT NULL` shape could not represent worker shifts.
  Future<void> _migrateV3ToV4(Database db) async {
    await db.execute('''
      CREATE TABLE time_entries_v4 (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL DEFAULT 'local-workspace',
        work_item_type TEXT NOT NULL CHECK (work_item_type IN ('job', 'shift')),
        job_id TEXT,
        shift_id TEXT,
        clock_in TEXT NOT NULL,
        clock_out TEXT,
        status TEXT NOT NULL DEFAULT 'running',
        scheduled_start_at_utc TEXT,
        scheduled_end_at_utc TEXT,
        raw_duration_seconds INTEGER,
        unpaid_break_seconds INTEGER,
        billable_duration_seconds INTEGER,
        currency_code TEXT,
        pricing_type TEXT NOT NULL DEFAULT 'hourly',
        base_rate_minor INTEGER,
        fixed_price_minor INTEGER,
        extra_pay_minor INTEGER NOT NULL DEFAULT 0,
        overtime_after_seconds INTEGER,
        overtime_multiplier_numerator INTEGER NOT NULL DEFAULT 3,
        overtime_multiplier_denominator INTEGER NOT NULL DEFAULT 2,
        premium_multiplier_numerator INTEGER NOT NULL DEFAULT 1,
        premium_multiplier_denominator INTEGER NOT NULL DEFAULT 1,
        rounding_increment_seconds INTEGER NOT NULL DEFAULT 60,
        rounding_direction TEXT NOT NULL DEFAULT 'nearest',
        calculation_engine_version INTEGER NOT NULL DEFAULT 2,
        calculation_snapshot_json TEXT,
        correction_reason TEXT,
        manually_edited_at_utc TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1,
        local_version INTEGER NOT NULL DEFAULT 1,
        server_version INTEGER,
        last_synced_at TEXT,
        FOREIGN KEY (job_id) REFERENCES jobs(id),
        FOREIGN KEY (shift_id) REFERENCES shifts(id),
        CHECK (
          (work_item_type = 'job' AND job_id IS NOT NULL AND shift_id IS NULL) OR
          (work_item_type = 'shift' AND shift_id IS NOT NULL AND job_id IS NULL)
        ),
        CHECK (clock_out IS NULL OR clock_out >= clock_in)
      )
    ''');

    await db.execute('''
      INSERT INTO time_entries_v4 (
        id, workspace_id, work_item_type, job_id, shift_id,
        clock_in, clock_out, status, created_at, updated_at, deleted_at,
        sync_status, server_updated_at, version, local_version
      )
      SELECT id, 'local-workspace', 'job', job_id, NULL,
             clock_in, clock_out, status, created_at, updated_at, deleted_at,
             sync_status, server_updated_at, version, 1
      FROM time_entries
    ''');

    await db.execute('''
      CREATE TABLE break_entries_v4 (
        id TEXT PRIMARY KEY,
        time_entry_id TEXT NOT NULL,
        break_start TEXT NOT NULL,
        break_end TEXT,
        is_paid INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pendingCreate',
        server_updated_at TEXT,
        version INTEGER NOT NULL DEFAULT 1,
        local_version INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (time_entry_id) REFERENCES time_entries_v4(id),
        CHECK (break_end IS NULL OR break_end >= break_start)
      )
    ''');

    await db.execute('''
      INSERT INTO break_entries_v4 (
        id, time_entry_id, break_start, break_end, is_paid,
        created_at, updated_at, deleted_at, sync_status,
        server_updated_at, version, local_version
      )
      SELECT id, time_entry_id, break_start, break_end, is_paid,
             created_at, updated_at, deleted_at, sync_status,
             server_updated_at, version, 1
      FROM break_entries
    ''');

    await db.execute('DROP TABLE break_entries');
    await db.execute('DROP TABLE time_entries');
    await db.execute('ALTER TABLE time_entries_v4 RENAME TO time_entries');
    await db.execute('ALTER TABLE break_entries_v4 RENAME TO break_entries');

    // Module 02 allowed one active timer per job. If an older installation has
    // overlapping active jobs, preserve every row but close all except the
    // newest before enforcing Module 03's app-wide single-session invariant.
    await db.execute('''
      UPDATE break_entries
      SET break_end = MAX(
            break_start,
            (SELECT clock_in FROM time_entries
             WHERE clock_out IS NULL AND deleted_at IS NULL
               AND status IN ('running', 'paused')
             ORDER BY clock_in DESC, id DESC LIMIT 1)
          ),
          updated_at = (SELECT clock_in FROM time_entries
                        WHERE clock_out IS NULL AND deleted_at IS NULL
                          AND status IN ('running', 'paused')
                        ORDER BY clock_in DESC, id DESC LIMIT 1)
      WHERE break_end IS NULL
        AND time_entry_id IN (
          SELECT id FROM time_entries
          WHERE clock_out IS NULL AND deleted_at IS NULL
            AND status IN ('running', 'paused')
            AND id <> (
              SELECT id FROM time_entries
              WHERE clock_out IS NULL AND deleted_at IS NULL
                AND status IN ('running', 'paused')
              ORDER BY clock_in DESC, id DESC LIMIT 1
            )
        )
    ''');
    await db.execute('''
      UPDATE time_entries
      SET clock_out = (
            SELECT clock_in FROM time_entries AS keeper
            WHERE keeper.clock_out IS NULL AND keeper.deleted_at IS NULL
              AND keeper.status IN ('running', 'paused')
            ORDER BY keeper.clock_in DESC, keeper.id DESC LIMIT 1
          ),
          status = 'completed',
          correction_reason = 'module03_single_timer_migration',
          manually_edited_at_utc = updated_at,
          sync_status = 'pendingUpdate'
      WHERE clock_out IS NULL AND deleted_at IS NULL
        AND status IN ('running', 'paused')
        AND id <> (
          SELECT id FROM time_entries AS keeper
          WHERE keeper.clock_out IS NULL AND keeper.deleted_at IS NULL
            AND keeper.status IN ('running', 'paused')
          ORDER BY keeper.clock_in DESC, keeper.id DESC LIMIT 1
        )
    ''');

    const statements = [
      'CREATE INDEX idx_time_entries_job ON time_entries(job_id)',
      'CREATE INDEX idx_time_entries_shift ON time_entries(shift_id)',
      'CREATE INDEX idx_time_entries_workspace_clock ON time_entries(workspace_id, clock_in DESC)',
      'CREATE INDEX idx_break_entries_time_entry ON break_entries(time_entry_id)',
    ];
    for (final statement in statements) {
      await db.execute(statement);
    }

    await db.execute('''
      CREATE TRIGGER prevent_multiple_active_time_entries_insert
      BEFORE INSERT ON time_entries
      WHEN NEW.clock_out IS NULL
       AND NEW.deleted_at IS NULL
       AND NEW.status IN ('running', 'paused')
       AND EXISTS (
         SELECT 1 FROM time_entries
         WHERE workspace_id = NEW.workspace_id
           AND clock_out IS NULL
           AND deleted_at IS NULL
           AND status IN ('running', 'paused')
       )
      BEGIN
        SELECT RAISE(ABORT, 'active_work_session_exists');
      END
    ''');

    await db.execute('''
      CREATE TRIGGER prevent_multiple_active_time_entries_update
      BEFORE UPDATE OF clock_out, status, deleted_at ON time_entries
      WHEN NEW.clock_out IS NULL
       AND NEW.deleted_at IS NULL
       AND NEW.status IN ('running', 'paused')
       AND EXISTS (
         SELECT 1 FROM time_entries
         WHERE workspace_id = NEW.workspace_id
           AND id <> NEW.id
           AND clock_out IS NULL
           AND deleted_at IS NULL
           AND status IN ('running', 'paused')
       )
      BEGIN
        SELECT RAISE(ABORT, 'active_work_session_exists');
      END
    ''');

    await db.execute('''
      CREATE TRIGGER prevent_multiple_open_breaks
      BEFORE INSERT ON break_entries
      WHEN NEW.break_end IS NULL
       AND NEW.deleted_at IS NULL
       AND EXISTS (
         SELECT 1 FROM break_entries
         WHERE time_entry_id = NEW.time_entry_id
           AND break_end IS NULL
           AND deleted_at IS NULL
       )
      BEGIN
        SELECT RAISE(ABORT, 'open_break_exists');
      END
    ''');
  }

  /// Module 04 migration: occurrence identity and rendered private copy are
  /// stored beside each OS request so reconciliation can repair missing or
  /// stale notifications without relying on an in-memory background isolate.
  Future<void> _migrateV4ToV5(Database db) async {
    for (final table in ['jobs', 'shifts']) {
      await _addColumnIfMissing(
        db,
        table,
        'reminder_uses_global_defaults',
        'INTEGER NOT NULL DEFAULT 1',
      );
      await _addColumnIfMissing(
        db,
        table,
        'reminder_preview_offset_seconds',
        'INTEGER NOT NULL DEFAULT 86400',
      );
      await _addColumnIfMissing(
        db,
        table,
        'reminder_prepare_offset_seconds',
        'INTEGER NOT NULL DEFAULT 7200',
      );
      await _addColumnIfMissing(
        db,
        table,
        'reminder_start_offset_seconds',
        'INTEGER NOT NULL DEFAULT 1800',
      );
      await _addColumnIfMissing(
        db,
        table,
        'reminder_morning_enabled',
        'INTEGER NOT NULL DEFAULT 1',
      );
      await _addColumnIfMissing(
        db,
        table,
        'reminder_end_enabled',
        'INTEGER NOT NULL DEFAULT 1',
      );
    }

    await _addColumnIfMissing(db, 'notifications', 'scheduled_for_utc', 'TEXT');
    await _addColumnIfMissing(db, 'notifications', 'occurrence_id', 'TEXT');
    await _addColumnIfMissing(db, 'notifications', 'route_intent', 'TEXT');
    await _addColumnIfMissing(db, 'notifications', 'payload_json', 'TEXT');
    await _addColumnIfMissing(db, 'notifications', 'title_text', 'TEXT');
    await _addColumnIfMissing(db, 'notifications', 'body_text', 'TEXT');
    await _addColumnIfMissing(
      db,
      'notifications',
      'content_fingerprint',
      'TEXT',
    );
    await _addColumnIfMissing(db, 'notifications', 'content_locale', 'TEXT');

    await _addColumnIfMissing(
      db,
      'job_alert_preferences',
      'cooldown_seconds',
      'INTEGER NOT NULL DEFAULT 3600',
    );
    await _addColumnIfMissing(
      db,
      'job_alert_preferences',
      'sound_enabled',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(
      db,
      'job_alert_preferences',
      'vibration_enabled',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(
      db,
      'job_alert_preferences',
      'delivery_time_minutes',
      'INTEGER',
    );

    await _addColumnIfMissing(
      db,
      'motivation_settings',
      'custom_message',
      'TEXT',
    );
    await _addColumnIfMissing(
      db,
      'motivation_settings',
      'quiet_start_minutes',
      'INTEGER NOT NULL DEFAULT 1320',
    );
    await _addColumnIfMissing(
      db,
      'motivation_settings',
      'quiet_end_minutes',
      'INTEGER NOT NULL DEFAULT 420',
    );

    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_notifications_occurrence
      ON notifications(occurrence_id)
      WHERE occurrence_id IS NOT NULL
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_notifications_scheduled_for
      ON notifications(status, scheduled_for_utc)
    ''');
  }

  /// Module 05 migration: all financial values remain integer minor units.
  /// Original evidence and privacy-safe share copies are tracked separately so
  /// exports never silently replace the user's source file.
  Future<void> _migrateV5ToV6(Database db) async {
    await _addColumnIfMissing(db, 'customers', 'billing_currency_code', 'TEXT');

    await _addColumnIfMissing(
      db,
      'pay_periods',
      'currency_code',
      "TEXT NOT NULL DEFAULT 'GBP'",
    );
    await _addColumnIfMissing(
      db,
      'pay_periods',
      'status',
      "TEXT NOT NULL DEFAULT 'open'",
    );
    await _addColumnIfMissing(
      db,
      'pay_periods',
      'confidence_state',
      "TEXT NOT NULL DEFAULT 'complete'",
    );
    await _addColumnIfMissing(
      db,
      'pay_periods',
      'calculation_snapshot_json',
      'TEXT',
    );
    await _addColumnIfMissing(db, 'pay_periods', 'data_gap_json', 'TEXT');
    await _addColumnIfMissing(db, 'pay_periods', 'notes', 'TEXT');
    await _addColumnIfMissing(
      db,
      'pay_periods',
      'local_version',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(
      db,
      'pay_periods',
      'sync_status',
      "TEXT NOT NULL DEFAULT 'localOnly'",
    );

    await _addColumnIfMissing(db, 'payslips', 'pay_date_utc', 'TEXT');
    await _addColumnIfMissing(db, 'payslips', 'reference', 'TEXT');
    await _addColumnIfMissing(db, 'payslips', 'currency_code', 'TEXT');
    await _addColumnIfMissing(
      db,
      'payslips',
      'sync_status',
      "TEXT NOT NULL DEFAULT 'localOnly'",
    );
    await _addColumnIfMissing(db, 'pay_adjustments', 'updated_at', 'TEXT');

    await _addColumnIfMissing(db, 'attachments', 'shared_copy_path', 'TEXT');
    await _addColumnIfMissing(db, 'attachments', 'shared_copy_sha256', 'TEXT');
    await _addColumnIfMissing(
      db,
      'attachments',
      'metadata_stripped',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      'attachments',
      'original_retained',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(
      db,
      'evidence_items',
      'selected_for_export',
      'INTEGER NOT NULL DEFAULT 1',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS evidence_exports (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        linked_entity_type TEXT NOT NULL,
        linked_entity_id TEXT NOT NULL,
        pdf_path TEXT NOT NULL,
        zip_path TEXT NOT NULL,
        pdf_sha256 TEXT NOT NULL,
        zip_sha256 TEXT NOT NULL,
        manifest_json TEXT NOT NULL,
        status TEXT NOT NULL,
        generated_at_utc TEXT NOT NULL,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id)
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_pay_periods_employer_range
      ON pay_periods(employer_id, start_at_utc, end_at_utc)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_evidence_exports_link
      ON evidence_exports(linked_entity_type, linked_entity_id, generated_at_utc)
    ''');
  }

  Future<void> _createFoundationIndexes(Database db) async {
    final statements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_customers_workspace ON customers(workspace_id)',
      'CREATE INDEX IF NOT EXISTS idx_services_workspace ON services(workspace_id)',
      'CREATE INDEX IF NOT EXISTS idx_jobs_workspace_date ON jobs(workspace_id, start_at_utc)',
      'CREATE INDEX IF NOT EXISTS idx_jobs_service ON jobs(service_id)',
      'CREATE INDEX IF NOT EXISTS idx_workspace_members_workspace ON workspace_members(workspace_id)',
      'CREATE INDEX IF NOT EXISTS idx_employers_workspace_name ON employers(workspace_id, name)',
      'CREATE INDEX IF NOT EXISTS idx_workplaces_employer ON workplaces(employer_id)',
      'CREATE INDEX IF NOT EXISTS idx_shifts_workspace_start ON shifts(workspace_id, start_at_utc)',
      'CREATE INDEX IF NOT EXISTS idx_shifts_employer ON shifts(employer_id)',
      'CREATE INDEX IF NOT EXISTS idx_shifts_workplace ON shifts(workplace_id)',
      'CREATE INDEX IF NOT EXISTS idx_rate_rules_link ON rate_rules(linked_entity_type, linked_entity_id)',
      'CREATE INDEX IF NOT EXISTS idx_pay_periods_workspace_start ON pay_periods(workspace_id, start_at_utc)',
      'CREATE INDEX IF NOT EXISTS idx_payslips_period ON payslips(pay_period_id)',
      'CREATE INDEX IF NOT EXISTS idx_pay_adjustments_period ON pay_adjustments(pay_period_id)',
      'CREATE INDEX IF NOT EXISTS idx_materials_job ON materials(job_id)',
      'CREATE INDEX IF NOT EXISTS idx_expenses_job ON expenses(job_id)',
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_quotes_number ON quotes(workspace_id, quote_number)',
      'CREATE INDEX IF NOT EXISTS idx_quotes_customer ON quotes(customer_id)',
      'CREATE INDEX IF NOT EXISTS idx_quote_items_quote ON quote_items(quote_id)',
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_invoices_number ON invoices(workspace_id, invoice_number)',
      'CREATE INDEX IF NOT EXISTS idx_invoices_customer ON invoices(customer_id)',
      'CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice ON invoice_items(invoice_id)',
      'CREATE INDEX IF NOT EXISTS idx_payments_invoice ON payments(invoice_id, paid_at_utc)',
      'CREATE INDEX IF NOT EXISTS idx_receipts_payment ON receipts(payment_id)',
      'CREATE INDEX IF NOT EXISTS idx_attachments_workspace ON attachments(workspace_id)',
      'CREATE INDEX IF NOT EXISTS idx_evidence_link ON evidence_items(linked_entity_type, linked_entity_id)',
      'CREATE INDEX IF NOT EXISTS idx_signatures_link ON signatures(linked_entity_type, linked_entity_id)',
      'CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications(status, source_start_at_utc)',
      'CREATE INDEX IF NOT EXISTS idx_notification_deliveries_notification ON notification_deliveries(notification_id)',
      'CREATE INDEX IF NOT EXISTS idx_motivation_messages_workspace ON motivation_messages(workspace_id)',
      'CREATE INDEX IF NOT EXISTS idx_drafts_updated ON drafts(workspace_id, updated_at)',
      'CREATE INDEX IF NOT EXISTS idx_outbox_retry ON sync_outbox(next_attempt_at_utc, attempt_count)',
      'CREATE INDEX IF NOT EXISTS idx_outbox_entity ON sync_outbox(entity_type, entity_id)',
      'CREATE INDEX IF NOT EXISTS idx_conflicts_entity ON sync_conflicts(entity_type, entity_id)',
      'CREATE INDEX IF NOT EXISTS idx_backup_workspace_time ON backup_history(workspace_id, started_at_utc DESC)',
      'CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_logs(entity_type, entity_id, occurred_at_utc)',
      'CREATE INDEX IF NOT EXISTS idx_audit_workspace_time ON audit_logs(workspace_id, occurred_at_utc DESC)',
    ];
    for (final statement in statements) {
      await db.execute(statement);
    }
  }

  Future<void> _migrateV6ToV7(Database db) async {
    const statements = [
      '''CREATE INDEX IF NOT EXISTS idx_jobs_active_schedule
         ON jobs(workspace_id, deleted_at, start_at_utc, end_at_utc)''',
      '''CREATE INDEX IF NOT EXISTS idx_jobs_active_status
         ON jobs(workspace_id, deleted_at, status, start_at_utc)''',
      '''CREATE INDEX IF NOT EXISTS idx_shifts_active_schedule
         ON shifts(workspace_id, deleted_at, start_at_utc, end_at_utc)''',
      '''CREATE INDEX IF NOT EXISTS idx_shifts_active_status
         ON shifts(workspace_id, deleted_at, status, start_at_utc)''',
      '''CREATE INDEX IF NOT EXISTS idx_time_entries_active
         ON time_entries(workspace_id, clock_out, deleted_at, status, clock_in DESC)''',
      '''CREATE INDEX IF NOT EXISTS idx_break_entries_open
         ON break_entries(time_entry_id, break_end, deleted_at)''',
      '''CREATE INDEX IF NOT EXISTS idx_evidence_period_export
         ON evidence_items(linked_entity_type, linked_entity_id, deleted_at,
                           selected_for_export, captured_at_utc DESC)''',
    ];
    for (final statement in statements) {
      await db.execute(statement);
    }
    await db.execute('PRAGMA optimize');
  }

  Future<void> _migrateV7ToV8(Database db) async {
    await _addColumnIfMissing(
      db,
      'attachments',
      'encryption_version',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      'backup_history',
      'manifest_version',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(db, 'backup_history', 'file_size_bytes', 'INTEGER');
    await _addColumnIfMissing(db, 'backup_history', 'restore_mode', 'TEXT');
  }

  /// Module 10 migration: generated reports stay local and retain a checksum
  /// audit trail without copying report contents into SQLite.
  Future<void> _migrateV8ToV9(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS report_exports (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        report_kind TEXT NOT NULL,
        export_format TEXT NOT NULL,
        range_start_utc TEXT NOT NULL,
        range_end_utc TEXT NOT NULL,
        party_type TEXT,
        party_id TEXT,
        currency_code TEXT NOT NULL,
        local_path TEXT NOT NULL,
        sha256 TEXT NOT NULL,
        created_at_utc TEXT NOT NULL,
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id)
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_report_exports_workspace_time
      ON report_exports(workspace_id, created_at_utc DESC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_report_exports_party
      ON report_exports(party_type, party_id, created_at_utc DESC)
    ''');
    await db.execute('PRAGMA optimize');
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String declaration,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $declaration');
    }
  }

  Future<void> _seedDefaultServices(Database db) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final starterServices = <Map<String, Object>>[
      {'name': 'Leak Repair', 'category': 'Plumbing', 'default_rate': 40.0},
      {'name': 'Tap Repair', 'category': 'Plumbing', 'default_rate': 35.0},
      {'name': 'Boiler Service', 'category': 'Plumbing', 'default_rate': 60.0},
      {
        'name': 'Socket Installation',
        'category': 'Electrical',
        'default_rate': 35.0,
      },
      {'name': 'Fuse Box', 'category': 'Electrical', 'default_rate': 55.0},
      {'name': 'House Cleaning', 'category': 'Cleaning', 'default_rate': 20.0},
      {
        'name': 'Furniture Assembly',
        'category': 'Handyman',
        'default_rate': 25.0,
      },
      {
        'name': 'Interior Painting',
        'category': 'Painting',
        'default_rate': 30.0,
      },
    ];
    for (final service in starterServices) {
      final name = service['name']! as String;
      await db.insert('services', {
        'id': 'seed-${name.toLowerCase().replaceAll(' ', '-')}',
        'name': name,
        'category': service['category'],
        'description': null,
        'default_rate': service['default_rate'],
        'default_duration_minutes': 60,
        'tax_rate': 0,
        'is_custom': 0,
        'created_at': now,
        'updated_at': now,
        'sync_status': 'synced',
        'version': 1,
      });
    }
  }

  Future<bool> integrityCheck() async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA integrity_check');
    return result.isNotEmpty && result.first.values.first == 'ok';
  }

  Future<void> closeForTest() async {
    final db = _db;
    _db = null;
    await db?.close();
  }
}
