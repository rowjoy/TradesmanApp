/// Supported application languages with metadata.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  final String code;
  final String name;
  final String nativeName;
  final String flag;

  static const List<AppLanguage> languages = [
    AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    AppLanguage(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇧🇩',
    ),
    AppLanguage(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
    ),
    AppLanguage(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flag: '🇯🇵',
    ),
    AppLanguage(
      code: 'pl',
      name: 'Polish',
      nativeName: 'Polski',
      flag: '🇵🇱',
    ),
    AppLanguage(
      code: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      flag: '🇵🇰',
    ),
    AppLanguage(
      code: 'ro',
      name: 'Romanian',
      nativeName: 'Română',
      flag: '🇷🇴',
    ),
    AppLanguage(
      code: 'ga',
      name: 'Irish',
      nativeName: 'Gaeilge',
      flag: '🇮🇪',
    ),
    AppLanguage(
      code: 'yo',
      name: 'Yoruba',
      nativeName: 'Yorùbá',
      flag: '🇳🇬',
    ),
    AppLanguage(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文 (简体)',
      flag: '🇨🇳',
    ),
  ];

  static AppLanguage fromCode(String code) {
    return languages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => languages.first,
    );
  }
}
