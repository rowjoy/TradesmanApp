import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/ids/id_generator.dart';
import '../../../../core/time/app_clock.dart';
import '../../data/repository_impl/sqlite_local_profile_repository.dart';
import '../../domain/entities/local_profile.dart';
import '../../domain/repositories/local_profile_repository.dart';

final localProfileRepositoryProvider = Provider<LocalProfileRepository>((ref) {
  return SqliteLocalProfileRepository(
    databaseHelper: DatabaseHelper.instance,
    clock: ref.watch(appClockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
});

class OnboardingController extends StateNotifier<AsyncValue<LocalProfile?>> {
  OnboardingController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final LocalProfileRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.load);
  }

  Future<LocalProfile> complete(LocalProfileDraft draft) async {
    final saved = await _repository.completeSetup(draft);
    state = AsyncData(saved);
    return saved;
  }

  Future<LocalProfile> updatePreferences({
    required String languageCode,
    required WorkMode workMode,
    required String countryCode,
    required String currencyCode,
  }) async {
    final previous = state;
    try {
      final saved = await _repository.updatePreferences(
        languageCode: languageCode,
        workMode: workMode,
        countryCode: countryCode,
        currencyCode: currencyCode,
      );
      state = AsyncData(saved);
      return saved;
    } catch (error, stackTrace) {
      state = previous;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, AsyncValue<LocalProfile?>>((
      ref,
    ) {
      return OnboardingController(ref.watch(localProfileRepositoryProvider));
    });

final currentProfileProvider = Provider<LocalProfile?>((ref) {
  return ref.watch(onboardingControllerProvider).asData?.value;
});
