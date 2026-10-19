import 'dart:async';
import 'dart:isolate';

/// Runs CPU-heavy, platform-independent work away from Flutter's UI isolate.
///
/// Callers must only capture isolate-safe values. UI state, providers, database
/// handles and method channels stay on the main isolate.
abstract final class BackgroundTaskRunner {
  static Future<T> run<T>(FutureOr<T> Function() task, {String? debugName}) =>
      Isolate.run(task, debugName: debugName);
}
