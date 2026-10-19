import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/about/domain/app_feature.dart';
import 'package:tradesman_manager/features/about/presentation/app_feature_catalog.dart';
import 'package:tradesman_manager/features/about/presentation/app_feature_navigation.dart';
import 'package:tradesman_manager/features/work/domain/work_models.dart';
import 'package:tradesman_manager/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog covers each major feature exactly once', () {
    const features = AppFeatureCatalog.all;

    expect(features, hasLength(AppFeatureId.values.length));
    expect(
      features.map((feature) => feature.id).toSet(),
      AppFeatureId.values.toSet(),
    );
    expect(
      features.map((feature) => feature.titleLocalizationKey).toSet(),
      hasLength(features.length),
    );
    expect(features.every((feature) => feature.isAvailable), isTrue);

    for (final id in AppFeatureId.values) {
      expect(AppFeatureCatalog.forId(id).id, id);
    }
  });

  test('feature copy resolves for every supported locale', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final strings = lookupAppLocalizations(locale);
      for (final feature in AppFeatureCatalog.all) {
        expect(feature.title(strings).trim(), isNotEmpty);
        expect(feature.shortDescription(strings).trim(), isNotEmpty);
        expect(feature.description(strings).trim(), isNotEmpty);
      }
    }
  });

  test('workflow-aware destinations resolve to usable routes', () {
    final contacts = AppFeatureCatalog.forId(AppFeatureId.contacts);
    final calendar = AppFeatureCatalog.forId(AppFeatureId.calendar);

    expect(contacts.routeFor(WorkFlow.worker), contains('flow=worker'));
    expect(contacts.routeFor(WorkFlow.tradesman), contains('flow=tradesman'));
    expect(calendar.routeFor(WorkFlow.worker), contains('flow=worker'));
    expect(calendar.routeFor(WorkFlow.tradesman), contains('flow=tradesman'));
    for (final feature in AppFeatureCatalog.all) {
      expect(feature.routeFor(WorkFlow.worker), startsWith('/'));
    }
  });
}
