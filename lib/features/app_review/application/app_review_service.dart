import '../../time_tracking/time_entry_model.dart';

abstract interface class AppReviewGateway {
  bool get canOpenStoreListing;

  Future<bool> isAvailable();

  Future<void> requestReview();

  Future<void> openStoreListing();
}

abstract interface class ReviewAttemptStore {
  Future<bool> hasAttempted();

  Future<void> markAttempted();

  Future<void> clearAttempted();
}

class AppReviewService {
  AppReviewService({
    required Future<CompletedClockOutStats> Function() loadStats,
    required AppReviewGateway gateway,
    required ReviewAttemptStore attemptStore,
  }) : _loadStats = loadStats,
       _gateway = gateway,
       _attemptStore = attemptStore;

  static const minimumCompletedClockOuts = 3;
  static const minimumClockOutSpan = Duration(days: 7);

  final Future<CompletedClockOutStats> Function() _loadStats;
  final AppReviewGateway _gateway;
  final ReviewAttemptStore _attemptStore;
  Future<void>? _inFlight;

  Future<void> maybeRequestReview({required bool Function() canPresent}) {
    final running = _inFlight;
    if (running != null) return running;

    final next = _maybeRequestReview(canPresent);
    _inFlight = next;
    next.whenComplete(() {
      if (identical(_inFlight, next)) _inFlight = null;
    });
    return next;
  }

  Future<void> _maybeRequestReview(bool Function() canPresent) async {
    try {
      if (!canPresent() || await _attemptStore.hasAttempted()) return;

      final stats = await _loadStats();
      final first = stats.firstClockOutUtc;
      final latest = stats.latestClockOutUtc;
      if (stats.count < minimumCompletedClockOuts ||
          first == null ||
          latest == null ||
          latest.difference(first) < minimumClockOutSpan) {
        return;
      }

      if (!await _gateway.isAvailable() || !canPresent()) return;

      await _attemptStore.markAttempted();
      if (!canPresent()) {
        await _attemptStore.clearAttempted();
        return;
      }
      await _gateway.requestReview();
    } catch (_) {
      // Review prompts are optional and must never interrupt clock-out.
    }
  }
}
