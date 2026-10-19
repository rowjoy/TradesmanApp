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

typedef MarketingImagePicker = Future<FilePickerResult?> Function();

class MarketingRepository {
  MarketingRepository(this._databaseHelper, {MarketingImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? _pickMarketingImage;

  static const _profileKey = 'marketing_profile_v1';
  static const _maxLogoBytes = 12 * 1024 * 1024;

  final DatabaseHelper _databaseHelper;
  final MarketingImagePicker _imagePicker;

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

  Future<Uint8List?> pickLogo() => _pickAndPrepareImage(
    maxDimension: 512,
    debugName: 'workproof-marketing-logo',
  );

  Future<Uint8List?> pickCoverPhoto() => _pickAndPrepareImage(
    maxDimension: 1600,
    debugName: 'workproof-marketing-cover-photo',
  );

  Future<Uint8List?> _pickAndPrepareImage({
    required int maxDimension,
    required String debugName,
  }) async {
    final result = await _imagePicker();
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;
    if (picked.size > _maxLogoBytes) throw const MarketingLogoException();
    final bytes =
        picked.bytes ??
        (picked.path == null ? null : await File(picked.path!).readAsBytes());
    if (bytes == null || bytes.isEmpty || bytes.length > _maxLogoBytes) {
      throw const MarketingLogoException();
    }
    return BackgroundTaskRunner.run(
      () => _prepareMarketingImage(bytes, maxDimension),
      debugName: debugName,
    );
  }
}

final marketingRepositoryProvider = Provider(
  (ref) => MarketingRepository(DatabaseHelper.instance),
);

Future<FilePickerResult?> _pickMarketingImage() => FilePicker.pickFiles(
  type: FileType.custom,
  allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
  allowMultiple: false,
  withData: true,
);

Future<Uint8List> _prepareMarketingImage(
  Uint8List source,
  int maxDimension,
) async {
  try {
    final decoder = img.findDecoderForData(source);
    if (decoder == null ||
        !const {
          img.ImageFormat.jpg,
          img.ImageFormat.png,
          img.ImageFormat.webp,
        }.contains(decoder.format)) {
      throw const MarketingLogoException();
    }
    final info = decoder.startDecode(source);
    if (info == null ||
        !marketingImageDimensionsAreSafe(info.width, info.height)) {
      throw const MarketingLogoException();
    }
    var decoded = decoder.decodeFrame(0);
    if (decoded == null) throw const MarketingLogoException();
    decoded = img.bakeOrientation(decoded);
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      decoded = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: maxDimension)
          : img.copyResize(decoded, height: maxDimension);
    }
    return Uint8List.fromList(img.encodePng(decoded, level: 6));
  } on MarketingLogoException {
    rethrow;
  } catch (_) {
    throw const MarketingLogoException();
  }
}

const _maxDecodedMarketingImagePixels = 16 * 1000 * 1000;

bool marketingImageDimensionsAreSafe(int width, int height) =>
    width > 0 &&
    height > 0 &&
    width <= _maxDecodedMarketingImagePixels ~/ height;
