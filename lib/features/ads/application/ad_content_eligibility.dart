import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether a surface is showing publisher content that may host ads.
///
/// Riverpod can retain a previous value on [AsyncError], so [AsyncValue.hasValue]
/// alone is not sufficient to distinguish content from an error-only state.
bool hasPublisherContent<T>(AsyncValue<T> value) =>
    value.hasValue && !value.hasError;
