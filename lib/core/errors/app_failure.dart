/// A user-safe failure. Raw exceptions stay in logs and are never rendered.
sealed class AppFailure implements Exception {
  const AppFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AppFailure($code)';
}

final class LocalStorageFailure extends AppFailure {
  const LocalStorageFailure({String code = 'local_storage_failed'})
    : super(code, 'The local data operation could not be completed.');
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(String message) : super('validation_failed', message);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure()
    : super('not_found', 'The requested local record no longer exists.');
}
