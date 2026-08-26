import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pay_protection_repository.dart';
import '../../domain/pay_protection_models.dart';
import '../../../work/domain/work_models.dart';
import '../../../work/presentation/controllers/work_controller.dart';

final payPeriodsProvider = FutureProvider<List<PayPeriod>>((ref) {
  return ref.watch(payProtectionRepositoryProvider).periods();
});

final payProtectionEmployersProvider = FutureProvider<List<Employer>>((ref) {
  return ref.watch(employersProvider.future);
});

final payPeriodDetailProvider = FutureProvider.family<PayPeriodDetail?, String>(
  (ref, id) {
    return ref.watch(payProtectionRepositoryProvider).detail(id);
  },
);

void invalidatePayProtection(WidgetRef ref, {String? periodId}) {
  ref.invalidate(payPeriodsProvider);
  if (periodId != null) ref.invalidate(payPeriodDetailProvider(periodId));
}
