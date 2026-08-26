import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';

class ShowcaseRepository {
  const ShowcaseRepository();

  static const _module03Key = 'full_app_showcase_completed_v5';
  static const _module05Key = 'module05_showcase_completed';
  static const _screenGuidePrefix = 'screen_showcase_v2_';

  Future<bool> isScreenGuideCompleted(String screenId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['$_screenGuidePrefix$screenId'],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == 'true';
  }

  Future<void> completeScreenGuide(String screenId) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('app_settings', {
      'key': '$_screenGuidePrefix$screenId',
      'value': 'true',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> resetScreenGuides() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'app_settings',
      where: 'key LIKE ?',
      whereArgs: ['$_screenGuidePrefix%'],
    );
  }

  Future<bool> isModule03Completed() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_module03Key],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == 'true';
  }

  Future<void> completeModule03() async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('app_settings', {
      'key': _module03Key,
      'value': 'true',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> resetModule03() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_module03Key],
    );
  }

  Future<bool> isModule05Completed() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_module05Key],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == 'true';
  }

  Future<void> completeModule05() async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('app_settings', {
      'key': _module05Key,
      'value': 'true',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> resetModule05() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_module05Key],
    );
  }
}

final showcaseRepositoryProvider = Provider(
  (ref) => const ShowcaseRepository(),
);

final module03ShowcaseCompletedProvider = FutureProvider<bool>((ref) {
  return ref.watch(showcaseRepositoryProvider).isModule03Completed();
});

final module05ShowcaseCompletedProvider = FutureProvider<bool>((ref) {
  return ref.watch(showcaseRepositoryProvider).isModule05Completed();
});

final module05ShowcaseReplayRequestProvider = StateProvider<int>((ref) => 0);

final module03ShowcaseReplayRequestProvider = StateProvider<int>((ref) => 0);
