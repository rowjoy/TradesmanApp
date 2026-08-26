import '../entities/local_profile.dart';

abstract interface class LocalProfileRepository {
  Future<LocalProfile?> load();

  Future<LocalProfile> completeSetup(LocalProfileDraft draft);

  Future<LocalProfile> updatePreferences({
    required String languageCode,
    required WorkMode workMode,
    required String countryCode,
    required String currencyCode,
  });
}
