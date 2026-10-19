import 'dart:io';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart' as code_widget;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/l10n.dart';

class CodeStudioScreen extends StatelessWidget {
  const CodeStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bn = Localizations.localeOf(context).languageCode == 'bn';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.codeToolsTitle),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.qr_code_scanner_rounded),
                text: bn ? 'স্ক্যান' : 'Scan',
              ),
              Tab(
                icon: const Icon(Icons.qr_code_2_rounded),
                text: bn ? 'তৈরি করুন' : 'Create',
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_ScannerPanel(), _GeneratorPanel()]),
      ),
    );
  }
}

class _ScannerPanel extends StatefulWidget {
  const _ScannerPanel();

  @override
  State<_ScannerPanel> createState() => _ScannerPanelState();
}

class _ScannerPanelState extends State<_ScannerPanel> {
  String? _value;
  String? _format;
  bool _handled = false;

  bool get _bn => Localizations.localeOf(context).languageCode == 'bn';
  String t(String en, String bn) => _bn ? bn : en;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value == null || value.isEmpty) continue;
      _handled = true;
      if (!mounted) return;
      setState(() {
        _value = value;
        _format = barcode.format.name;
      });
      return;
    }
  }

  void _scanAgain() {
    setState(() {
      _value = null;
      _format = null;
      _handled = false;
    });
  }

  Future<void> _copy() async {
    final value = _value;
    if (value == null) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) _message(t('Copied to clipboard.', 'ক্লিপবোর্ডে কপি হয়েছে।'));
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          t(
            'Point the camera at a QR code or common barcode.',
            'ক্যামেরাটি QR কোড বা সাধারণ বারকোডের দিকে ধরুন।',
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        if (_value == null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 340,
              child: MobileScanner(
                key: const ValueKey('code-studio-scanner'),
                tapToFocus: true,
                onDetect: _onDetect,
                errorBuilder: (context, error) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.no_photography_outlined, size: 42),
                          const SizedBox(height: 12),
                          Text(
                            t(
                              'Camera access is unavailable. Allow camera permission in system settings and try again.',
                              'ক্যামেরা ব্যবহার করা যাচ্ছে না। সিস্টেম সেটিংসে ক্যামেরার অনুমতি দিয়ে আবার চেষ্টা করুন।',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                overlayBuilder: (context, constraints) => Center(
                  child: Container(
                    width: 240,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t('Code detected', 'কোড পাওয়া গেছে'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Chip(label: Text((_format ?? 'unknown').toUpperCase())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(_value!),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: _copy,
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(t('Copy', 'কপি')),
                      ),
                      OutlinedButton.icon(
                        onPressed: _scanAgain,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(t('Scan again', 'আবার স্ক্যান')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(t('Private by design', 'গোপনীয়তা সুরক্ষিত')),
            subtitle: Text(
              t(
                'Scanning happens on this device. WorkProof does not upload the camera image.',
                'স্ক্যান এই ডিভাইসেই হয়। WorkProof ক্যামেরার ছবি আপলোড করে না।',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _CodeKind { qr, barcode }

class _GeneratorPanel extends StatefulWidget {
  const _GeneratorPanel();

  @override
  State<_GeneratorPanel> createState() => _GeneratorPanelState();
}

class _GeneratorPanelState extends State<_GeneratorPanel> {
  final _content = TextEditingController(text: 'WorkProof');
  final _codeKey = GlobalKey();
  _CodeKind _kind = _CodeKind.qr;
  bool _sharing = false;

  bool get _bn => Localizations.localeOf(context).languageCode == 'bn';
  String t(String en, String bn) => _bn ? bn : en;
  String get _data => _content.text.trim();
  bool get _valid =>
      _data.isNotEmpty &&
      (_kind == _CodeKind.qr ||
          _data.codeUnits.every((value) => value >= 32 && value <= 126));

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    if (_data.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _data));
    if (mounted) _message(t('Copied to clipboard.', 'ক্লিপবোর্ডে কপি হয়েছে।'));
  }

  Future<void> _share() async {
    if (!_valid || _sharing) return;
    FocusScope.of(context).unfocus();
    setState(() => _sharing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final object = _codeKey.currentContext?.findRenderObject();
      if (object is! RenderRepaintBoundary || !object.hasSize) {
        throw StateError('Code preview is not ready.');
      }
      final image = await object.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Code image could not be created.');
      final directory = await getTemporaryDirectory();
      final type = _kind == _CodeKind.qr ? 'qr' : 'barcode';
      final file = File(
        '${directory.path}/workproof_${type}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: _data,
          sharePositionOrigin: Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 1,
            height: 1,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        _message(t('The code could not be shared.', 'কোডটি শেয়ার করা যায়নি।'));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final isQr = _kind == _CodeKind.qr;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        SegmentedButton<_CodeKind>(
          segments: [
            ButtonSegment(
              value: _CodeKind.qr,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: Text(t('QR code', 'QR কোড')),
            ),
            ButtonSegment(
              value: _CodeKind.barcode,
              icon: const Icon(Icons.view_week_outlined),
              label: Text(t('Barcode', 'বারকোড')),
            ),
          ],
          selected: {_kind},
          onSelectionChanged: (selection) {
            setState(() => _kind = selection.first);
          },
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _content,
          minLines: 1,
          maxLines: isQr ? 4 : 1,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: t('Code content', 'কোডের তথ্য'),
            helperText: isQr
                ? t(
                    'Use text, a website, phone number, or reference.',
                    'টেক্সট, ওয়েবসাইট, ফোন নম্বর বা রেফারেন্স লিখুন।',
                  )
                : t(
                    'Code 128 supports standard English letters, numbers, and symbols.',
                    'Code 128 সাধারণ ইংরেজি অক্ষর, সংখ্যা ও চিহ্ন সমর্থন করে।',
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RepaintBoundary(
                  key: _codeKey,
                  child: ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _valid
                          ? code_widget.BarcodeWidget(
                              barcode: isQr
                                  ? code_widget.Barcode.qrCode()
                                  : code_widget.Barcode.code128(),
                              data: _data,
                              width: isQr ? 220 : 330,
                              height: isQr ? 220 : 130,
                              drawText: !isQr,
                              backgroundColor: Colors.white,
                              color: Colors.black,
                              errorBuilder: (context, error) => SizedBox(
                                width: 260,
                                height: 130,
                                child: Center(
                                  child: Text(
                                    t(
                                      'This content cannot be encoded.',
                                      'এই তথ্যটি কোডে রূপান্তর করা যাচ্ছে না।',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 260,
                              height: isQr ? 220 : 130,
                              child: Center(
                                child: Text(
                                  _data.isEmpty
                                      ? t(
                                          'Enter content to create a code.',
                                          'কোড তৈরি করতে তথ্য লিখুন।',
                                        )
                                      : t(
                                          'Barcode content must use standard English characters.',
                                          'বারকোডে সাধারণ ইংরেজি অক্ষর ব্যবহার করুন।',
                                        ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _data.isEmpty ? null : _copy,
                icon: const Icon(Icons.copy_rounded),
                label: Text(t('Copy text', 'টেক্সট কপি')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: !_valid || _sharing ? null : _share,
                icon: _sharing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share_outlined),
                label: Text(t('Share PNG', 'PNG শেয়ার')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
