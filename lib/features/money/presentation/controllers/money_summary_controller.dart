import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../data/money_summary_repository.dart';
import '../../domain/entities/money_summary.dart';

final moneySummaryRepositoryProvider = Provider<MoneySummaryRepository>(
  (ref) => MoneySummaryRepository(DatabaseHelper.instance),
);

final moneySummaryProvider = FutureProvider<MoneySummary>((ref) async {
  final currencyCode = ref.watch(
    currentProfileProvider.select((profile) => profile?.currencyCode),
  );
  return ref
      .watch(moneySummaryRepositoryProvider)
      .load(currencyCode: currencyCode ?? 'GBP');
});
