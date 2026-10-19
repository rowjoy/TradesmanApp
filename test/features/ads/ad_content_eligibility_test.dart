import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/features/ads/application/ad_content_eligibility.dart';

void main() {
  test('publisher content excludes initial and retained-data errors', () {
    const data = AsyncData<List<int>>(<int>[1]);
    const loading = AsyncLoading<List<int>>();
    final error = AsyncError<List<int>>(
      StateError('load failed'),
      StackTrace.empty,
    );
    final retainedDataError = error.copyWithPrevious(data);

    expect(hasPublisherContent(data), isTrue);
    expect(hasPublisherContent(loading), isFalse);
    expect(hasPublisherContent(error), isFalse);
    expect(retainedDataError.hasValue, isTrue);
    expect(retainedDataError.hasError, isTrue);
    expect(hasPublisherContent(retainedDataError), isFalse);
  });

  test('refreshing previous publisher content remains eligible', () {
    const data = AsyncData<List<int>>(<int>[1]);
    final refreshing = const AsyncLoading<List<int>>().copyWithPrevious(data);

    expect(refreshing.hasValue, isTrue);
    expect(refreshing.hasError, isFalse);
    expect(hasPublisherContent(refreshing), isTrue);
  });
}
