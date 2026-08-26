import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../data/marketing_repository.dart';
import '../domain/marketing_profile.dart';
import '../infrastructure/marketing_export_service.dart';

const _a4AspectRatio = 210 / 297;
const _a4CanvasWidth = 420.0;
const _a4CanvasHeight = 594.0;
const _a4ExportWidthPixels = 2480.0;

class MarketingStudioScreen extends ConsumerStatefulWidget {
  const MarketingStudioScreen({super.key});

  @override
  ConsumerState<MarketingStudioScreen> createState() =>
      _MarketingStudioScreenState();
}

class _MarketingStudioScreenState
    extends ConsumerState<MarketingStudioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previewKey = GlobalKey();
  final _displayName = TextEditingController();
  final _headline = TextEditingController();
  final _offer = TextEditingController();
  final _services = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();
  final _address = TextEditingController();

  MarketingTemplate _template = MarketingTemplate.professional;
  Uint8List? _logoBytes;
  bool _loading = true;
  bool _saving = false;
  bool _exporting = false;
  bool _hydrating = false;

  List<TextEditingController> get _controllers => [
    _displayName,
    _headline,
    _offer,
    _services,
    _phone,
    _email,
    _website,
    _address,
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_refreshPreview);
    }
    _load();
  }

  Future<void> _load() async {
    final saved = await ref.read(marketingRepositoryProvider).load();
    if (!mounted) return;
    final profession = ref.read(currentProfileProvider)?.profession.trim() ?? '';
    _hydrating = true;
    _displayName.text = saved.displayName;
    _headline.text = saved.headline;
    _offer.text = saved.offer;
    _services.text = saved.services.isEmpty && profession.isNotEmpty
        ? profession
        : saved.services.join('\n');
    _phone.text = saved.phone;
    _email.text = saved.email;
    _website.text = saved.website;
    _address.text = saved.address;
    _template = saved.template;
    _logoBytes = saved.logoBytes;
    _hydrating = false;
    setState(() => _loading = false);
  }

  void _refreshPreview() {
    if (mounted && !_hydrating) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
        ..removeListener(_refreshPreview)
        ..dispose();
    }
    super.dispose();
  }

  List<String> get _serviceList => _services.text
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);

  MarketingProfile get _profile => MarketingProfile(
    displayName: _displayName.text.trim(),
    headline: _headline.text.trim(),
    offer: _offer.text.trim(),
    services: _serviceList,
    phone: _phone.text.trim(),
    email: _email.text.trim(),
    website: _website.text.trim(),
    address: _address.text.trim(),
    template: _template,
    logoBytes: _logoBytes,
  );

  bool _validate() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return false;
    if (_phone.text.trim().isEmpty && _email.text.trim().isEmpty) {
      AppFeedback.error(context, context.l10n.marketingContactRequired);
      return false;
    }
    return true;
  }

  Future<bool> _save({bool showFeedback = true}) async {
    if (!_validate() || _saving) return false;
    setState(() => _saving = true);
    try {
      await ref.read(marketingRepositoryProvider).save(_profile);
      if (mounted && showFeedback) {
        AppFeedback.success(context, context.l10n.marketingProfileSaved);
      }
      return true;
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.l10n.saveFailed);
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickLogo() async {
    try {
      final selected = await ref.read(marketingRepositoryProvider).pickLogo();
      if (!mounted || selected == null) return;
      setState(() => _logoBytes = selected);
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.l10n.marketingLogoFailed);
      }
    }
  }

  Future<void> _export(
    MarketingExportFormat format,
    BuildContext buttonContext,
  ) async {
    if (_exporting || !await _save(showFeedback: false) || !mounted) return;
    FocusScope.of(context).unfocus();
    setState(() => _exporting = true);
    try {
      final pngBytes = await _capturePreview();
      final service = ref.read(marketingExportServiceProvider);
      final export = format == MarketingExportFormat.image
          ? await service.createImage(pngBytes)
          : await service.createPdf(pngBytes);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(export.path)],
          subject: _profile.displayName,
          text: _shareText(_profile),
          sharePositionOrigin: _shareOrigin(buttonContext),
        ),
      );
      if (mounted) {
        AppFeedback.success(context, context.l10n.marketingExportSaved);
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.l10n.marketingExportFailed);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<Uint8List> _capturePreview() async {
    await WidgetsBinding.instance.endOfFrame;
    final renderObject = _previewKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary ||
        !renderObject.hasSize ||
        renderObject.size.width <= 0) {
      throw StateError('Marketing preview is not ready.');
    }
    // A4 at 300 DPI is 2480 x 3508 pixels. The preview keeps the exact A4
    // aspect ratio, so deriving the scale from its width produces a
    // print-ready image without cropping or adding a square canvas.
    final pixelRatio = _a4ExportWidthPixels / renderObject.size.width;
    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) throw StateError('Marketing preview export failed.');
    return data.buffer.asUint8List();
  }

  String _shareText(MarketingProfile profile) => [
    profile.displayName,
    if (profile.headline.isNotEmpty) profile.headline,
    if (profile.offer.isNotEmpty) profile.offer,
    if (profile.phone.isNotEmpty) profile.phone,
    if (profile.email.isNotEmpty) profile.email,
    if (profile.website.isNotEmpty) profile.website,
    if (profile.address.isNotEmpty) profile.address,
  ].join('\n');

  Rect? _shareOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.marketingStudioTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.marketingSaveProfile,
            onPressed: _saving || _loading ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final preview = _previewPanel();
                final editor = _editorPanel();
                if (constraints.maxWidth >= 980) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: preview,
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: editor,
                        ),
                      ),
                    ],
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    children: [
                      preview,
                      const SizedBox(height: 24),
                      editor,
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _previewPanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.marketingPreview,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 10),
      DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: RepaintBoundary(
          key: _previewKey,
          child: AspectRatio(
            aspectRatio: _a4AspectRatio,
            child: _MarketingBanner(profile: _profile),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text(
        context.l10n.marketingStudioSubtitle,
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 14),
      Builder(
        builder: (buttonContext) => Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exporting
                    ? null
                    : () => _export(
                        MarketingExportFormat.image,
                        buttonContext,
                      ),
                icon: const Icon(Icons.image_outlined),
                label: Text(context.l10n.marketingCreateImage),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _exporting
                    ? null
                    : () => _export(
                        MarketingExportFormat.pdf,
                        buttonContext,
                      ),
                icon: _exporting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  _exporting
                      ? context.l10n.marketingCreating
                      : context.l10n.marketingCreatePdf,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _editorPanel() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.marketingProfileTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _LogoPreview(bytes: _logoBytes),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(context.l10n.marketingChooseLogo),
                  ),
                  if (_logoBytes != null)
                    TextButton.icon(
                      onPressed: () => setState(() => _logoBytes = null),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(context.l10n.marketingRemoveLogo),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _displayName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: '${context.l10n.marketingNameLabel} *',
            prefixIcon: const Icon(Icons.business_outlined),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? context.l10n.marketingRequiredInfo
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _headline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: context.l10n.marketingHeadlineLabel,
            prefixIcon: const Icon(Icons.campaign_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _offer,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: context.l10n.marketingOfferLabel,
            prefixIcon: const Icon(Icons.local_offer_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _services,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: '${context.l10n.marketingServicesLabel} *',
            hintText: context.l10n.marketingServicesHint,
            prefixIcon: const Icon(Icons.design_services_outlined),
            alignLabelWithHint: true,
          ),
          validator: (_) => _serviceList.isEmpty
              ? context.l10n.marketingRequiredInfo
              : null,
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.marketingTemplateLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _templateChip(
              MarketingTemplate.professional,
              context.l10n.marketingTemplateProfessional,
            ),
            _templateChip(
              MarketingTemplate.bold,
              context.l10n.marketingTemplateBold,
            ),
            _templateChip(
              MarketingTemplate.elegant,
              context.l10n.marketingTemplateElegant,
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: context.l10n.phoneLabel,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: context.l10n.emailLabel,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _website,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: context.l10n.marketingWebsiteLabel,
            prefixIcon: const Icon(Icons.language_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _address,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: context.l10n.addressLabel,
            prefixIcon: const Icon(Icons.location_on_outlined),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(context.l10n.marketingSaveProfile),
        ),
      ],
    ),
  );

  Widget _templateChip(MarketingTemplate template, String label) => ChoiceChip(
    selected: _template == template,
    label: Text(label),
    avatar: Icon(
      switch (template) {
        MarketingTemplate.professional => Icons.workspace_premium_outlined,
        MarketingTemplate.bold => Icons.bolt_outlined,
        MarketingTemplate.elegant => Icons.auto_awesome_outlined,
      },
      size: 18,
    ),
    onSelected: (_) => setState(() => _template = template),
  );
}

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.bytes});

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) => Container(
    width: 82,
    height: 82,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: bytes == null
        ? const Icon(Icons.add_business_outlined, size: 34)
        : Image.memory(bytes!, fit: BoxFit.cover, gaplessPlayback: true),
  );
}

class _MarketingBanner extends StatelessWidget {
  const _MarketingBanner({required this.profile});

  final MarketingProfile profile;

  @override
  Widget build(BuildContext context) {
    final palette = _BannerPalette.forTemplate(profile.template);
    final services = profile.services.take(8).toList(growable: false);
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: _a4CanvasWidth,
        height: _a4CanvasHeight,
        child: Container(
          decoration: BoxDecoration(
            gradient: palette.gradient,
            border: Border.all(color: palette.border, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
          Positioned(
            right: -48,
            top: -58,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.accent.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            left: -76,
            bottom: -92,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.accent.withValues(alpha: 0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: palette.logoBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: profile.logoBytes == null
                          ? Icon(
                              Icons.handyman_outlined,
                              color: palette.primaryText,
                              size: 36,
                            )
                          : Image.memory(
                              profile.logoBytes!,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName.isEmpty
                                ? context.l10n.marketingNameLabel
                                : profile.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.primaryText,
                              fontSize: 27,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (profile.headline.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              profile.headline,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.secondaryText,
                                fontSize: 13,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (profile.offer.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      profile.offer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.accentText,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                Text(
                  context.l10n.marketingServicesTitle.toUpperCase(),
                  style: TextStyle(
                    color: palette.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                if (services.isEmpty)
                  Text(
                    context.l10n.marketingServicesHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.secondaryText),
                  )
                else
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      for (final service in services)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 176),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: palette.card,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            service,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.primaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profile.phone.isNotEmpty)
                        _BannerContact(
                          icon: Icons.phone_outlined,
                          text: profile.phone,
                          color: palette.primaryText,
                        ),
                      if (profile.email.isNotEmpty)
                        _BannerContact(
                          icon: Icons.email_outlined,
                          text: profile.email,
                          color: palette.primaryText,
                        ),
                      if (profile.website.isNotEmpty)
                        _BannerContact(
                          icon: Icons.language_outlined,
                          text: profile.website,
                          color: palette.primaryText,
                        ),
                      if (profile.address.isNotEmpty)
                        _BannerContact(
                          icon: Icons.location_on_outlined,
                          text: profile.address,
                          color: palette.primaryText,
                          maxLines: 2,
                        ),
                      if (profile.phone.isEmpty &&
                          profile.email.isEmpty &&
                          profile.website.isEmpty &&
                          profile.address.isEmpty)
                        Text(
                          context.l10n.marketingContactRequired,
                          maxLines: 2,
                          style: TextStyle(color: palette.secondaryText),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerContact extends StatelessWidget {
  const _BannerContact({
    required this.icon,
    required this.text,
    required this.color,
    this.maxLines = 1,
  });

  final IconData icon;
  final String text;
  final Color color;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _BannerPalette {
  const _BannerPalette({
    required this.gradient,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
    required this.accentText,
    required this.card,
    required this.cardBorder,
    required this.logoBackground,
    required this.border,
  });

  final LinearGradient gradient;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;
  final Color accentText;
  final Color card;
  final Color cardBorder;
  final Color logoBackground;
  final Color border;

  static _BannerPalette forTemplate(MarketingTemplate template) =>
      switch (template) {
        MarketingTemplate.professional => _BannerPalette(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D3434), Color(0xFF17645F)],
          ),
          primaryText: Colors.white,
          secondaryText: const Color(0xFFD7EBE8),
          accent: const Color(0xFFF4C95D),
          accentText: const Color(0xFF183231),
          card: Colors.white.withValues(alpha: 0.11),
          cardBorder: Colors.white.withValues(alpha: 0.14),
          logoBackground: Colors.white.withValues(alpha: 0.14),
          border: const Color(0xFF5A9A95),
        ),
        MarketingTemplate.bold => _BannerPalette(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF31104C), Color(0xFF8F245B), Color(0xFFF06A3A)],
          ),
          primaryText: Colors.white,
          secondaryText: const Color(0xFFFFE9E2),
          accent: const Color(0xFFFFD166),
          accentText: const Color(0xFF38123E),
          card: Colors.white.withValues(alpha: 0.13),
          cardBorder: Colors.white.withValues(alpha: 0.18),
          logoBackground: Colors.white.withValues(alpha: 0.16),
          border: const Color(0xFFF3A17E),
        ),
        MarketingTemplate.elegant => _BannerPalette(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF9EC), Color(0xFFEDE0BF)],
          ),
          primaryText: const Color(0xFF25231F),
          secondaryText: const Color(0xFF605B4E),
          accent: const Color(0xFF9A722B),
          accentText: Colors.white,
          card: Colors.white.withValues(alpha: 0.58),
          cardBorder: const Color(0x339A722B),
          logoBackground: Colors.white.withValues(alpha: 0.7),
          border: const Color(0xFFB99653),
        ),
      };
}
