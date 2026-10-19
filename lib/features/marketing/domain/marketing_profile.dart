import 'dart:convert';
import 'dart:typed_data';

enum MarketingTemplate { professional, bold, elegant }

class MarketingProfile {
  const MarketingProfile({
    required this.displayName,
    required this.headline,
    required this.offer,
    required this.services,
    required this.phone,
    required this.email,
    required this.website,
    required this.address,
    required this.template,
    this.logoBytes,
    this.coverPhotoBytes,
  });

  const MarketingProfile.empty()
    : displayName = '',
      headline = '',
      offer = '',
      services = const [],
      phone = '',
      email = '',
      website = '',
      address = '',
      template = MarketingTemplate.professional,
      logoBytes = null,
      coverPhotoBytes = null;

  final String displayName;
  final String headline;
  final String offer;
  final List<String> services;
  final String phone;
  final String email;
  final String website;
  final String address;
  final MarketingTemplate template;
  final Uint8List? logoBytes;
  final Uint8List? coverPhotoBytes;

  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'headline': headline,
    'offer': offer,
    'services': services,
    'phone': phone,
    'email': email,
    'website': website,
    'address': address,
    'template': template.name,
    'logoBase64': logoBytes == null ? null : base64Encode(logoBytes!),
    'coverPhotoBase64': coverPhotoBytes == null
        ? null
        : base64Encode(coverPhotoBytes!),
  };

  factory MarketingProfile.fromJson(Map<String, Object?> json) {
    return MarketingProfile(
      displayName: json['displayName'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      offer: json['offer'] as String? ?? '',
      services:
          (json['services'] as List<Object?>?)
              ?.whereType<String>()
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(growable: false) ??
          const [],
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      address: json['address'] as String? ?? '',
      template: MarketingTemplate.values.firstWhere(
        (item) => item.name == json['template'],
        orElse: () => MarketingTemplate.professional,
      ),
      logoBytes: _decodeImageBytes(json['logoBase64']),
      coverPhotoBytes: _decodeImageBytes(json['coverPhotoBase64']),
    );
  }
}

Uint8List? _decodeImageBytes(Object? encoded) {
  if (encoded is! String || encoded.isEmpty) return null;
  try {
    return base64Decode(encoded);
  } on FormatException {
    return null;
  }
}
