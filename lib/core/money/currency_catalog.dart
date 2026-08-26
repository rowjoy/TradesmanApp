class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.englishName,
    required this.bengaliName,
    required this.fractionDigits,
  });

  final String code;
  final String symbol;
  final String englishName;
  final String bengaliName;
  final int fractionDigits;

  String label({required String languageCode}) {
    final name = switch (languageCode) {
      'bn' => bengaliName,
      'en' => englishName,
      _ => null,
    };
    return name == null ? '$symbol · $code' : '$symbol · $name ($code)';
  }
}

class MarketOption {
  const MarketOption({
    required this.code,
    required this.englishName,
    required this.bengaliName,
    required this.defaultCurrencyCode,
    required this.flag,
  });

  final String code;
  final String englishName;
  final String bengaliName;
  final String defaultCurrencyCode;
  final String flag;

  String label({required String languageCode}) {
    final name = switch (languageCode) {
      'bn' => bengaliName,
      'en' => englishName,
      _ => null,
    };
    return name == null ? '$flag  $code' : '$flag  $name';
  }
}

abstract final class CurrencyCatalog {
  static const currencies = <CurrencyOption>[
    CurrencyOption(
      code: 'GBP',
      symbol: '£',
      englishName: 'British pound',
      bengaliName: 'ব্রিটিশ পাউন্ড',
      fractionDigits: 2,
    ),
    CurrencyOption(
      code: 'EUR',
      symbol: '€',
      englishName: 'Euro',
      bengaliName: 'ইউরো',
      fractionDigits: 2,
    ),
    CurrencyOption(
      code: 'INR',
      symbol: '₹',
      englishName: 'Indian rupee',
      bengaliName: 'ভারতীয় রুপি',
      fractionDigits: 2,
    ),
    CurrencyOption(
      code: 'JPY',
      symbol: '¥',
      englishName: 'Japanese yen',
      bengaliName: 'জাপানি ইয়েন',
      fractionDigits: 0,
    ),
    CurrencyOption(
      code: 'BDT',
      symbol: '৳',
      englishName: 'Bangladeshi taka',
      bengaliName: 'বাংলাদেশি টাকা',
      fractionDigits: 2,
    ),
    CurrencyOption(
      code: 'USD',
      symbol: r'$',
      englishName: 'US dollar',
      bengaliName: 'মার্কিন ডলার',
      fractionDigits: 2,
    ),
  ];

  static const markets = <MarketOption>[
    MarketOption(
      code: 'GB',
      englishName: 'United Kingdom',
      bengaliName: 'যুক্তরাজ্য',
      defaultCurrencyCode: 'GBP',
      flag: '🇬🇧',
    ),
    MarketOption(
      code: 'EU',
      englishName: 'European Union',
      bengaliName: 'ইউরোপীয় ইউনিয়ন',
      defaultCurrencyCode: 'EUR',
      flag: '🇪🇺',
    ),
    MarketOption(
      code: 'IN',
      englishName: 'India',
      bengaliName: 'ভারত',
      defaultCurrencyCode: 'INR',
      flag: '🇮🇳',
    ),
    MarketOption(
      code: 'JP',
      englishName: 'Japan',
      bengaliName: 'জাপান',
      defaultCurrencyCode: 'JPY',
      flag: '🇯🇵',
    ),
    MarketOption(
      code: 'BD',
      englishName: 'Bangladesh',
      bengaliName: 'বাংলাদেশ',
      defaultCurrencyCode: 'BDT',
      flag: '🇧🇩',
    ),
    MarketOption(
      code: 'US',
      englishName: 'United States',
      bengaliName: 'যুক্তরাষ্ট্র',
      defaultCurrencyCode: 'USD',
      flag: '🇺🇸',
    ),
  ];

  static CurrencyOption currency(String code) => currencies.firstWhere(
    (item) => item.code == code,
    orElse: () => currencies.first,
  );

  static MarketOption market(String code) => markets.firstWhere(
    (item) => item.code == code,
    orElse: () => markets.first,
  );

  static int fractionDigits(String currencyCode) =>
      currency(currencyCode).fractionDigits;

  static int scale(String currencyCode) =>
      fractionDigits(currencyCode) == 0 ? 1 : 100;
}
