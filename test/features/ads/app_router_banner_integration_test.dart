import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tradesman_manager/core/router/app_router.dart';
import 'package:tradesman_manager/features/ads/application/banner_overlay_controller.dart';
import 'package:tradesman_manager/features/onboarding/domain/entities/local_profile.dart';
import 'package:tradesman_manager/features/onboarding/domain/repositories/local_profile_repository.dart';
import 'package:tradesman_manager/features/onboarding/presentation/controllers/onboarding_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('popup visibility does not reconstruct the production router', () async {
    final container = ProviderContainer(
      overrides: [
        localProfileRepositoryProvider.overrideWithValue(
          _EmptyProfileRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await Future<void>.delayed(Duration.zero);

    final router = container.read(appRouterProvider);
    final controller = container.read(bannerOverlayControllerProvider);
    final observer = controller.createObserver();
    final popup = _TestPopupRoute();

    observer.didPush(popup, null);
    expect(container.read(appRouterProvider), same(router));

    observer.didPop(popup, null);
    expect(container.read(appRouterProvider), same(router));
  });

  test('every stateful shell branch observes popup routes', () {
    final container = ProviderContainer(
      overrides: [
        localProfileRepositoryProvider.overrideWithValue(
          _EmptyProfileRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);
    final shell = router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;

    expect(shell.branches, isNotEmpty);
    for (final branch in shell.branches) {
      expect(branch.observers, isNotNull);
      expect(branch.observers, isNotEmpty);
    }
  });
}

class _EmptyProfileRepository implements LocalProfileRepository {
  @override
  Future<LocalProfile?> load() async => null;

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

class _TestPopupRoute extends PopupRoute<void> {
  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'test';

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => const SizedBox();
}
