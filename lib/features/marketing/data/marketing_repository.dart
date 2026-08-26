import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/performance/background_task_runner.dart';
import '../domain/marketing_profile.dart';

class MarketingLogoException implements Exception {
  const MarketingLogoException();
}

class MarketingRepository {
  const MarketingRepository(this._databaseHelper);

  static const _profileKey = 'marketing_profile_v1';
  static const _maxLogoBytes = 12 * 1024 * 1024;

  final DatabaseHelper _databaseHelper;

  Future<MarketingProfile> load() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_profileKey],
      limit: 1,
    );
    if (rows.isEmpty) return const MarketingProfile.empty();
    try {
      final decoded = jsonDecode(rows.first['value']! as String);
      if (decoded is! Map) {
        return const MarketingProfile.empty();
      }
      return MarketingProfile.fromJson(decoded.cast<String, Object?>());
    } catch (_) {
      return const MarketingProfile.empty();
    }
  }

  Future<void> save(MarketingProfile profile) async {
    final db = await _databaseHelper.database;
    await db.insert('app_settings', {
      'key': _profileKey,
      'value': jsonEncode(profile.toJson()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Uint8List?> pickLogo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;
    if (picked.size > _maxLogoBytes) throw const MarketingLogoException();
    final bytes = picked.bytes ??
        (picked.path == null ? null : await File(picked.path!).readAsBytes());
    if (bytes == null || bytes.isEmpty || bytes.length > _maxLogoBytes) {
      throw const MarketingLogoException();
    }
    return BackgroundTaskRunner.run(
      () => _prepareMarketingLogo(bytes),
      debugName: 'workproof-marketing-logo',
    );
  }
}

final marketingRepositoryProvider = Provider(
  (ref) => MarketingRepository(DatabaseHelper.instance),
);

Future<Uint8List> _prepareMarketingLogo(Uint8List source) async {
  var decoded = img.decodeImage(source);
  if (decoded == null) throw const MarketingLogoException();
  decoded = img.bakeOrientation(decoded);
  if (decoded.width > 512 || decoded.height > 512) {
    decoded = decoded.width >= decoded.height
        ? img.copyResize(decoded, width: 512)
        : img.copyResize(decoded, height: 512);
  }
  return Uint8List.fromList(img.encodePng(decoded, level: 6));
}
