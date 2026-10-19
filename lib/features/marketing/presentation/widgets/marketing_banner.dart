import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../domain/marketing_profile.dart';

const _canvasWidth = 420.0;
const _canvasHeight = 594.0;

/// A print-shaped, code-native flyer preview.
///
/// The canvas deliberately ignores the device's accessibility text scale. The
/// editor around it still honours that preference, while this fixed-size print
/// artifact keeps the same typography and geometry in previews and exports.
class MarketingBanner extends StatelessWidget {
  const MarketingBanner({required this.profile, super.key});

  final MarketingProfile profile;

  @override
  Widget build(BuildContext context) {
    final banner = switch (profile.template) {
      MarketingTemplate.professional => _ProfessionalBanner(profile: profile),
      MarketingTemplate.bold => _BoldBanner(profile: profile),
      MarketingTemplate.elegant => _ElegantBanner(profile: profile),
    };

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          key: ValueKey<String>('marketing-banner-${profile.template.name}'),
          width: _canvasWidth,
          height: _canvasHeight,
          child: banner,
        ),
      ),
    );
  }
}

class _ProfessionalBanner extends StatelessWidget {
  const _ProfessionalBanner({required this.profile});

  final MarketingProfile profile;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF092D3A);
    const teal = Color(0xFF087F7A);
    const gold = Color(0xFFE7B84B);
    const paper = Color(0xFFF3F7F5);
    final services = profile.services.take(8).toList(growable: false);

    return DecoratedBox(
      decoration: const BoxDecoration(color: paper),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              key: const ValueKey<String>('professional-hero-stage'),
              child: Stack(
                children: [
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 292,
                    child: ClipPath(
                      clipper: _ProfessionalCurveClipper(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [navy, Color(0xFF07525B), teal],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: -52,
                    end: -46,
                    child: Container(
                      width: 176,
                      height: 176,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.09),
                          width: 28,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 28,
                    start: 25,
                    end: 24,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: SizedBox(
                            height: 196,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _BrandMark(
                                  bytes: profile.logoBytes,
                                  foreground: Colors.white,
                                  background: Colors.white.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderColor: Colors.white.withValues(
                                    alpha: 0.18,
                                  ),
                                  size: 48,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  _displayName(context, profile),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1.02,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.45,
                                  ),
                                ),
                                if (profile.headline.isNotEmpty) ...[
                                  const SizedBox(height: 7),
                                  Text(
                                    profile.headline,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFD5ECE8),
                                      fontSize: 10.5,
                                      height: 1.24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 5,
                          child: _HeroPhoto(
                            bytes: profile.coverPhotoBytes,
                            height: 184,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(70),
                              topRight: Radius.circular(70),
                              bottomLeft: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                            fallbackColors: const [
                              Color(0xFF0C6E70),
                              Color(0xFF13A19B),
                            ],
                            borderColor: gold,
                            iconColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (profile.offer.isNotEmpty)
              PositionedDirectional(
                top: 244,
                start: 25,
                end: 25,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 43),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_outlined,
                        color: navy,
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          profile.offer,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 13,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            PositionedDirectional(
              top: 309,
              start: 25,
              end: 25,
              height: 188,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 27, height: 3, color: teal),
                      const SizedBox(width: 9),
                      Text(
                        context.l10n.marketingServicesTitle.toUpperCase(),
                        style: const TextStyle(
                          color: navy,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.35,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Expanded(
                    child: _ServiceGrid(
                      services: services,
                      background: Colors.white,
                      foreground: navy,
                      accent: teal,
                      emptyText: context.l10n.marketingServicesHint,
                      borderColor: const Color(0xFFDCE8E5),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 86,
              child: _BannerContact(
                profile: profile,
                background: navy,
                foreground: Colors.white,
                accent: gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoldBanner extends StatelessWidget {
  const _BoldBanner({required this.profile});

  final MarketingProfile profile;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF24103A);
    const plum = Color(0xFF5D155F);
    const magenta = Color(0xFFC52267);
    const orange = Color(0xFFFF6F3D);
    const yellow = Color(0xFFFFD052);
    final services = profile.services.take(8).toList(growable: false);

    return ClipRect(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ink, plum, magenta],
          ),
        ),
        child: Stack(
          key: const ValueKey<String>('bold-diagonal-stage'),
          children: [
            PositionedDirectional(
              top: -28,
              end: -34,
              width: 206,
              height: 270,
              child: Transform.rotate(
                angle: 0.11,
                child: _HeroPhoto(
                  bytes: profile.coverPhotoBytes,
                  height: 270,
                  borderRadius: BorderRadius.circular(0),
                  fallbackColors: const [magenta, orange],
                  borderColor: yellow,
                  borderWidth: 5,
                  iconColor: Colors.white,
                ),
              ),
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              width: 282,
              height: 276,
              child: ClipPath(
                clipper: const _BoldHeaderClipper(),
                child: ColoredBox(
                  color: ink.withValues(alpha: 0.94),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24,
                      25,
                      43,
                      22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BrandMark(
                          bytes: profile.logoBytes,
                          foreground: ink,
                          background: Colors.white,
                          borderColor: Colors.white,
                          size: 43,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _displayName(context, profile),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            height: 0.98,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                          ),
                        ),
                        if (profile.headline.isNotEmpty) ...[
                          const SizedBox(height: 9),
                          Text(
                            profile.headline,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFF8DDE9),
                              fontSize: 10,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 244,
              left: -18,
              right: -18,
              height: 300,
              child: Transform.rotate(
                angle: -0.035,
                child: const ColoredBox(color: Colors.white),
              ),
            ),
            if (profile.offer.isNotEmpty)
              PositionedDirectional(
                top: 217,
                start: 24,
                end: 25,
                child: Transform.rotate(
                  angle: -0.018,
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [orange, yellow]),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      profile.offer,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 21,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.35,
                      ),
                    ),
                  ),
                ),
              ),
            PositionedDirectional(
              top: 307,
              start: 25,
              end: 25,
              height: 193,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        services.length.toString().padLeft(2, '0'),
                        key: const ValueKey<String>('bold-service-count'),
                        style: const TextStyle(
                          color: magenta,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          context.l10n.marketingServicesTitle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _BoldServices(
                      services: services,
                      emptyText: context.l10n.marketingServicesHint,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 76,
              child: _BannerContact(
                profile: profile,
                background: ink,
                foreground: Colors.white,
                accent: yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElegantBanner extends StatelessWidget {
  const _ElegantBanner({required this.profile});

  final MarketingProfile profile;

  @override
  Widget build(BuildContext context) {
    const ivory = Color(0xFFFAF6EA);
    const charcoal = Color(0xFF22241F);
    const olive = Color(0xFF596252);
    const gold = Color(0xFFB28A47);
    final services = profile.services.take(8).toList(growable: false);

    return DecoratedBox(
      decoration: const BoxDecoration(color: ivory),
      child: ClipRect(
        child: Stack(
          key: const ValueKey<String>('elegant-editorial-stage'),
          children: [
            const PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: 34,
              child: ColoredBox(color: charcoal),
            ),
            const PositionedDirectional(
              start: 34,
              top: 0,
              bottom: 0,
              width: 5,
              child: ColoredBox(color: gold),
            ),
            PositionedDirectional(
              top: 27,
              start: 60,
              end: 25,
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BrandMark(
                            bytes: profile.logoBytes,
                            foreground: charcoal,
                            background: Colors.white.withValues(alpha: 0.6),
                            borderColor: gold,
                            size: 46,
                          ),
                          const SizedBox(height: 18),
                          Container(width: 40, height: 2, color: gold),
                          const SizedBox(height: 10),
                          Text(
                            _displayName(context, profile),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: charcoal,
                              fontSize: 24,
                              height: 1.02,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (profile.headline.isNotEmpty) ...[
                            const SizedBox(height: 9),
                            Text(
                              profile.headline,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: olive,
                                fontSize: 10,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _HeroPhoto(
                      bytes: profile.coverPhotoBytes,
                      height: 218,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(78),
                        topRight: Radius.circular(78),
                      ),
                      fallbackColors: const [olive, charcoal],
                      borderColor: gold,
                      borderWidth: 2,
                      iconColor: const Color(0xFFEBD8AE),
                    ),
                  ),
                ],
              ),
            ),
            if (profile.offer.isNotEmpty)
              PositionedDirectional(
                top: 264,
                start: 60,
                end: 25,
                child: Row(
                  children: [
                    Container(width: 4, height: 48, color: gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        profile.offer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: charcoal,
                          fontSize: 17,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            PositionedDirectional(
              top: 332,
              start: 60,
              end: 25,
              height: 164,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.marketingServicesTitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Expanded(
                    child: _EditorialServices(
                      services: services,
                      emptyText: context.l10n.marketingServicesHint,
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              start: 39,
              end: 0,
              bottom: 0,
              height: 79,
              child: _BannerContact(
                profile: profile,
                background: charcoal,
                foreground: Colors.white,
                accent: gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({
    required this.bytes,
    required this.foreground,
    required this.background,
    required this.borderColor,
    required this.size,
  });

  final Uint8List? bytes;
  final Color foreground;
  final Color background;
  final Color borderColor;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey<String>('banner-logo'),
    width: size,
    height: size,
    padding: EdgeInsets.all(bytes == null ? 8 : 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(size * 0.22),
      border: Border.all(color: borderColor),
    ),
    child: bytes == null
        ? Icon(Icons.handyman_rounded, color: foreground, size: size * 0.55)
        : Image.memory(
            bytes!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => Icon(
              Icons.handyman_rounded,
              color: foreground,
              size: size * 0.55,
            ),
          ),
  );
}

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({
    required this.bytes,
    required this.height,
    required this.borderRadius,
    required this.fallbackColors,
    required this.borderColor,
    required this.iconColor,
    this.borderWidth = 3,
  });

  final Uint8List? bytes;
  final double height;
  final BorderRadius borderRadius;
  final List<Color> fallbackColors;
  final Color borderColor;
  final Color iconColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: fallbackColors,
        ),
      ),
      child: Center(
        child: Icon(Icons.business_center_rounded, color: iconColor, size: 50),
      ),
    );

    return Container(
      key: bytes == null ? null : const ValueKey<String>('banner-cover-photo'),
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: bytes == null
          ? fallback
          : Image.memory(
              bytes!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.services,
    required this.background,
    required this.foreground,
    required this.accent,
    required this.emptyText,
    required this.borderColor,
  });

  final List<String> services;
  final Color background;
  final Color foreground;
  final Color accent;
  final String emptyText;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        emptyText,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: foreground, fontSize: 10),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 7,
        crossAxisSpacing: 9,
        childAspectRatio: 5.2,
      ),
      itemBuilder: (context, index) => DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.13),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.check_rounded, color: accent, size: 11),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  services[index],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 8.8,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoldServices extends StatelessWidget {
  const _BoldServices({required this.services, required this.emptyText});

  final List<String> services;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        emptyText,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF5D155F), fontSize: 10),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 13,
        childAspectRatio: 5.1,
      ),
      itemBuilder: (context, index) => Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFC52267), Color(0xFFFF6F3D)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              services[index],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF24103A),
                fontSize: 8.8,
                height: 1.08,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialServices extends StatelessWidget {
  const _EditorialServices({required this.services, required this.emptyText});

  final List<String> services;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        emptyText,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF596252), fontSize: 10),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 18,
        childAspectRatio: 5,
      ),
      itemBuilder: (context, index) => DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x33B28A47))),
        ),
        child: Row(
          children: [
            Text(
              '${index + 1}'.padLeft(2, '0'),
              style: const TextStyle(
                color: Color(0xFFB28A47),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                services[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF22241F),
                  fontSize: 8.6,
                  height: 1.08,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerContact extends StatelessWidget {
  const _BannerContact({
    required this.profile,
    required this.background,
    required this.foreground,
    required this.accent,
  });

  final MarketingProfile profile;
  final Color background;
  final Color foreground;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final contacts = <(IconData, String)>[
      if (profile.phone.isNotEmpty) (Icons.phone_rounded, profile.phone),
      if (profile.email.isNotEmpty) (Icons.email_rounded, profile.email),
      if (profile.website.isNotEmpty) (Icons.language_rounded, profile.website),
      if (profile.address.isNotEmpty)
        (Icons.location_on_rounded, profile.address),
    ];

    return ColoredBox(
      key: const ValueKey<String>('banner-contact'),
      color: background,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 11, 24, 10),
        child: contacts.isEmpty
            ? Center(
                child: Text(
                  context.l10n.marketingContactRequired,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.76),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final itemWidth = contacts.length == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - spacing) / 2;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: 7,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: [
                      for (final contact in contacts)
                        SizedBox(
                          width: itemWidth,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  contact.$1,
                                  size: 11,
                                  color: background,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  contact.$2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: foreground,
                                    fontSize: 8.8,
                                    height: 1.1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _ProfessionalCurveClipper extends CustomClipper<Path> {
  const _ProfessionalCurveClipper();

  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height * 0.78)
    ..cubicTo(
      size.width * 0.72,
      size.height * 1.02,
      size.width * 0.33,
      size.height * 0.76,
      0,
      size.height * 0.94,
    )
    ..close();

  @override
  bool shouldReclip(_ProfessionalCurveClipper oldClipper) => false;
}

class _BoldHeaderClipper extends CustomClipper<Path> {
  const _BoldHeaderClipper();

  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width * 0.78, size.height)
    ..lineTo(0, size.height * 0.9)
    ..close();

  @override
  bool shouldReclip(_BoldHeaderClipper oldClipper) => false;
}

String _displayName(BuildContext context, MarketingProfile profile) =>
    profile.displayName.isEmpty
    ? context.l10n.marketingNameLabel
    : profile.displayName;
