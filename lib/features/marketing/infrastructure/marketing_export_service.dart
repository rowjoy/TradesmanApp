import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/ids/id_generator.dart';
import '../../../core/time/app_clock.dart';

enum MarketingExportFormat { image, pdf }

class MarketingExport {
  const MarketingExport({
    required this.path,
    required this.filename,
    required this.format,
  });

  final String path;
  final String filename;
  final MarketingExportFormat format;
}

class MarketingExportService {
  const MarketingExportService({
    required IdGenerator ids,
    required AppClock clock,
  }) : _ids = ids,
       _clock = clock;

  final IdGenerator _ids;
  final AppClock _clock;

  Future<MarketingExport> createImage(Uint8List pngBytes) async {
    final output = await _output('png');
    final printableBytes = await Isolate.run(
      () => _encodePrintReadyPng(pngBytes),
    );
    await File(output.$1).writeAsBytes(printableBytes, flush: true);
    return MarketingExport(
      path: output.$1,
      filename: output.$2,
      format: MarketingExportFormat.image,
    );
  }

  Future<MarketingExport> createPdf(Uint8List pngBytes) async {
    final output = await _output('pdf');
    final document = pw.Document();
    final image = pw.MemoryImage(pngBytes);
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Image(
          image,
          width: PdfPageFormat.a4.width,
          height: PdfPageFormat.a4.height,
          fit: pw.BoxFit.fill,
        ),
      ),
    );
    await File(output.$1).writeAsBytes(await document.save(), flush: true);
    return MarketingExport(
      path: output.$1,
      filename: output.$2,
      format: MarketingExportFormat.pdf,
    );
  }

  Future<(String, String)> _output(String extension) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'workproof', 'marketing'));
    await directory.create(recursive: true);
    final local = _clock.nowUtc().toLocal();
    final stamp =
        '${local.year.toString().padLeft(4, '0')}'
        '${local.month.toString().padLeft(2, '0')}'
        '${local.day.toString().padLeft(2, '0')}-'
        '${local.hour.toString().padLeft(2, '0')}'
        '${local.minute.toString().padLeft(2, '0')}';
    final id = _ids.next().replaceAll('-', '').substring(0, 8);
    final filename = 'workproof-promotion-$stamp-$id.$extension';
    return (p.join(directory.path, filename), filename);
  }
}

Uint8List _encodePrintReadyPng(Uint8List pngBytes) {
  final image = image_lib.decodePng(pngBytes);
  if (image == null) throw const FormatException('Invalid marketing PNG.');
  return image_lib.PngEncoder(
    pixelDimensions: image_lib.PngPhysicalPixelDimensions.dpi(300),
  ).encode(image);
}

final marketingExportServiceProvider = Provider(
  (ref) => MarketingExportService(
    ids: ref.watch(idGeneratorProvider),
    clock: ref.watch(appClockProvider),
  ),
);
