import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tradesman_manager/core/database/database_helper.dart';
import 'package:tradesman_manager/features/marketing/data/marketing_repository.dart';
import 'package:tradesman_manager/features/marketing/domain/marketing_profile.dart';

void main() {
  group('MarketingProfile cover photo persistence', () {
    test('round-trips cover photo bytes through JSON', () {
      final profile = _profile(
        coverPhotoBytes: Uint8List.fromList(const [0, 1, 2, 255]),
      );

      final json = profile.toJson();
      final restored = MarketingProfile.fromJson(json);

      expect(json['coverPhotoBase64'], 'AAEC/w==');
      expect(restored.coverPhotoBytes, orderedEquals(const [0, 1, 2, 255]));
    });

    test('loads legacy JSON without a cover photo', () {
      final restored = MarketingProfile.fromJson(const {
        'displayName': 'Bright Spark Electrical',
        'headline': 'Reliable electrical work',
        'offer': 'Free quote',
        'services': ['Rewiring'],
        'phone': '+8801783109748',
        'email': 'hello@example.com',
        'website': 'example.com',
        'address': 'Dhaka',
        'template': 'professional',
        'logoBase64': null,
      });

      expect(restored.coverPhotoBytes, isNull);
      expect(restored.displayName, 'Bright Spark Electrical');
      expect(restored.template, MarketingTemplate.professional);
    });

    test('ignores malformed persisted cover photo data', () {
      final restored = MarketingProfile.fromJson({
        ..._profile().toJson(),
        'coverPhotoBase64': 'not valid base64!',
      });

      expect(restored.coverPhotoBytes, isNull);
    });
  });

  group('MarketingRepository image preparation', () {
    test('rejects decoded dimensions above the safe pixel budget', () {
      expect(marketingImageDimensionsAreSafe(4000, 4000), isTrue);
      expect(marketingImageDimensionsAreSafe(4001, 4000), isFalse);
      expect(marketingImageDimensionsAreSafe(0, 4000), isFalse);
      expect(marketingImageDimensionsAreSafe(4000, -1), isFalse);
    });

    test('rejects unsafe header dimensions before allocating pixels', () async {
      final source = Uint8List.fromList(
        img.encodePng(img.Image(width: 1, height: 1)),
      );
      _writeUint32(source, 16, 4001);
      _writeUint32(source, 20, 4000);
      final repository = _repositoryWithFile(source, name: 'huge.png');

      await expectLater(
        repository.pickCoverPhoto(),
        throwsA(isA<MarketingLogoException>()),
      );
    });

    test('prepares a landscape cover photo at a 1600px maximum edge', () async {
      final source = Uint8List.fromList(
        img.encodeJpg(img.Image(width: 2400, height: 1200)),
      );
      final repository = _repositoryWithFile(source, name: 'work.jpg');

      final prepared = await repository.pickCoverPhoto();
      final decoded = img.decodeImage(prepared!);

      expect(
        prepared.take(8),
        orderedEquals(const [137, 80, 78, 71, 13, 10, 26, 10]),
      );
      expect(decoded, isNotNull);
      expect(decoded!.width, 1600);
      expect(decoded.height, 800);
    });

    test('rejects an oversized cover photo before decoding it', () async {
      final repository = MarketingRepository(
        DatabaseHelper.instance,
        imagePicker: () async => FilePickerResult([
          PlatformFile(
            name: 'too-large.jpg',
            size: 12 * 1024 * 1024 + 1,
            bytes: Uint8List.fromList(const [1, 2, 3]),
          ),
        ]),
      );

      await expectLater(
        repository.pickCoverPhoto(),
        throwsA(isA<MarketingLogoException>()),
      );
    });

    test('keeps logo preparation capped at 512px', () async {
      final source = Uint8List.fromList(
        img.encodeJpg(img.Image(width: 1024, height: 512)),
      );
      final repository = _repositoryWithFile(source, name: 'logo.jpg');

      final prepared = await repository.pickLogo();
      final decoded = img.decodeImage(prepared!);

      expect(decoded, isNotNull);
      expect(decoded!.width, 512);
      expect(decoded.height, 256);
    });
  });
}

MarketingProfile _profile({Uint8List? coverPhotoBytes}) => MarketingProfile(
  displayName: 'Bright Spark Electrical',
  headline: 'Reliable electrical work',
  offer: 'Free quote',
  services: const ['Rewiring'],
  phone: '+8801783109748',
  email: 'hello@example.com',
  website: 'example.com',
  address: 'Dhaka',
  template: MarketingTemplate.professional,
  coverPhotoBytes: coverPhotoBytes,
);

MarketingRepository _repositoryWithFile(
  Uint8List bytes, {
  required String name,
}) => MarketingRepository(
  DatabaseHelper.instance,
  imagePicker: () async => FilePickerResult([
    PlatformFile(name: name, size: bytes.length, bytes: bytes),
  ]),
);

void _writeUint32(Uint8List bytes, int offset, int value) {
  bytes[offset] = (value >> 24) & 0xff;
  bytes[offset + 1] = (value >> 16) & 0xff;
  bytes[offset + 2] = (value >> 8) & 0xff;
  bytes[offset + 3] = value & 0xff;
}
