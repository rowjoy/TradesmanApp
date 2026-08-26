import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AppClock {
  DateTime nowUtc();
}

final class SystemAppClock implements AppClock {
  const SystemAppClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

final appClockProvider = Provider<AppClock>((ref) => const SystemAppClock());
