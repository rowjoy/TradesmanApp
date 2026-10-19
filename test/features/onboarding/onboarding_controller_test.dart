import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/onboarding/domain/entities/local_profile.dart';
import 'package:tradesman_manager/features/onboarding/domain/repositories/local_profile_repository.dart';
import 'package:tradesman_manager/features/onboarding/presentation/controllers/onboarding_controller.dart';

void main() {
  test(
    'restore reload keeps the current profile visible while reading',
    () async {
      final repository = _Repository();
      final controller = OnboardingController(repository);
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.asData?.value?.languageCode, 'en');

      final reload = controller.reloadAfterRestore();
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.asData?.value?.languageCode, 'en');

      repository.restored.complete(_profile(languageCode: 'bn'));
      await reload;

      expect(controller.state.asData?.value?.languageCode, 'bn');
      controller.dispose();
    },
  );
}

class _Repository implements LocalProfileRepository {
  final restored = Completer<LocalProfile?>();
  var _loads = 0;

  @override
  Future<LocalProfile?> load() async {
    _loads++;
    if (_loads == 1) return _profile(languageCode: 'en');
    return restored.future;
  }

  @override
  Future<LocalProfile> completeSetup(LocalProfileDraft draft) =>
      throw UnimplementedError();

  @override
  Future<LocalProfile> updatePreferences({
    required String languageCode,
    required WorkMode workMode,
    required String countryCode,
    required String currencyCode,
  }) => throw UnimplementedError();
}

LocalProfile _profile({required String languageCode}) => LocalProfile(
  id: 'profile',
  workspaceId: 'workspace',
  languageCode: languageCode,
  workMode: WorkMode.both,
  countryCode: 'BD',
  currencyCode: 'BDT',
  profession: 'Electrician',
  payMethod: PayMethod.hourly,
  defaultRateMinor: 10000,
  themePreference: AppThemePreference.system,
  demoDataLoaded: false,
  onboardingCompleted: true,
  createdAtUtc: DateTime.utc(2026, 1, 1),
  updatedAtUtc: DateTime.utc(2026, 1, 1),
);
