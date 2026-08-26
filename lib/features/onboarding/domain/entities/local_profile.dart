enum WorkMode { worker, tradesman, both }

enum PayMethod { hourly, daily, fixed, mixed }

enum AppThemePreference { system, light, dark }

class LocalProfile {
  const LocalProfile({
    required this.id,
    required this.workspaceId,
    required this.languageCode,
    required this.workMode,
    required this.countryCode,
    required this.currencyCode,
    required this.profession,
    required this.payMethod,
    required this.defaultRateMinor,
    required this.themePreference,
    required this.demoDataLoaded,
    required this.onboardingCompleted,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String workspaceId;
  final String languageCode;
  final WorkMode workMode;
  final String countryCode;
  final String currencyCode;
  final String profession;
  final PayMethod payMethod;
  final int? defaultRateMinor;
  final AppThemePreference themePreference;
  final bool demoDataLoaded;
  final bool onboardingCompleted;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

class LocalProfileDraft {
  const LocalProfileDraft({
    required this.languageCode,
    required this.workMode,
    required this.countryCode,
    required this.currencyCode,
    required this.profession,
    required this.payMethod,
    required this.defaultRateMinor,
    required this.themePreference,
    required this.loadDemoData,
  });

  final String languageCode;
  final WorkMode workMode;
  final String countryCode;
  final String currencyCode;
  final String profession;
  final PayMethod payMethod;
  final int? defaultRateMinor;
  final AppThemePreference themePreference;
  final bool loadDemoData;
}

WorkMode workModeFromStorage(String value) => WorkMode.values.firstWhere(
  (mode) => mode.name == value,
  orElse: () => WorkMode.tradesman,
);

PayMethod payMethodFromStorage(String value) => PayMethod.values.firstWhere(
  (method) => method.name == value,
  orElse: () => PayMethod.hourly,
);

AppThemePreference themePreferenceFromStorage(String value) =>
    AppThemePreference.values.firstWhere(
      (theme) => theme.name == value,
      orElse: () => AppThemePreference.system,
    );
