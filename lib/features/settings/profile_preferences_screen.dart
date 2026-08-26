import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/currency_catalog.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/inline_animated_picker.dart';
import '../../l10n/app_language.dart';
import '../../l10n/l10n.dart';
import '../money/presentation/controllers/money_summary_controller.dart';
import '../onboarding/domain/entities/local_profile.dart';
import '../onboarding/presentation/controllers/onboarding_controller.dart';
import '../pay_protection/presentation/controllers/pay_protection_controller.dart';

class ProfilePreferencesScreen extends ConsumerStatefulWidget {
  const ProfilePreferencesScreen({super.key});

  @override
  ConsumerState<ProfilePreferencesScreen> createState() =>
      _ProfilePreferencesScreenState();
}

class _ProfilePreferencesScreenState
    extends ConsumerState<ProfilePreferencesScreen> {
  late String _languageCode;
  late WorkMode _workMode;
  late String _countryCode;
  late String _currencyCode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentProfileProvider);
    _languageCode = profile?.languageCode ?? 'en';
    _workMode = profile?.workMode ?? WorkMode.tradesman;
    _countryCode = profile?.countryCode ?? 'GB';
    _currencyCode = profile?.currencyCode ?? 'GBP';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .updatePreferences(
            languageCode: _languageCode,
            workMode: _workMode,
            countryCode: _countryCode,
            currencyCode: _currencyCode,
          );
      ref.invalidate(moneySummaryProvider);
      ref.invalidate(payPeriodsProvider);
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.l10n.preferencesSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.regionLanguageTitle),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D5453), Color(0xFF123C3B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const Icon(Icons.public_rounded, color: Colors.white, size: 34),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.localWorkspaceTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      context.l10n.localWorkspaceDescription,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InlineAnimatedPicker<WorkMode>(
          label: context.l10n.workModeTitle,
          value: _workMode,
          options: WorkMode.values,
          optionLabel: (mode) => switch (mode) {
            WorkMode.worker => context.l10n.workerMode,
            WorkMode.tradesman => context.l10n.tradesmanMode,
            WorkMode.both => context.l10n.bothMode,
          },
          leading: const Icon(Icons.badge_outlined),
          onChanged: (value) => setState(() => _workMode = value),
        ),
        const SizedBox(height: 14),
        InlineAnimatedPicker<String>(
          label: context.l10n.appLanguageLabel,
          value: _languageCode,
          options: AppLanguage.languages.map((l) => l.code).toList(),
          optionLabel: (code) {
            final lang = AppLanguage.fromCode(code);
            return '${lang.nativeName} (${lang.name})';
          },
          optionLeading: (code) => Text(AppLanguage.fromCode(code).flag),
          leading: const Icon(Icons.language_rounded),
          onChanged: (value) => setState(() => _languageCode = value),
        ),
        const SizedBox(height: 14),
        InlineAnimatedPicker<String>(
          label: context.l10n.countryMarketLabel,
          value: _countryCode,
          options: CurrencyCatalog.markets
              .map((item) => item.code)
              .toList(growable: false),
          optionLabel: (value) => CurrencyCatalog.market(value).label(
            languageCode: Localizations.localeOf(context).languageCode,
          ),
          optionLeading: (value) => Text(CurrencyCatalog.market(value).flag),
          leading: const Icon(Icons.travel_explore_rounded),
          onChanged: (value) => setState(() {
            _countryCode = value;
            _currencyCode = CurrencyCatalog.market(value).defaultCurrencyCode;
          }),
        ),
        const SizedBox(height: 14),
        InlineAnimatedPicker<String>(
          label: context.l10n.defaultCurrencyLabel,
          value: _currencyCode,
          options: CurrencyCatalog.currencies
              .map((item) => item.code)
              .toList(growable: false),
          optionLabel: (value) => CurrencyCatalog.currency(value).label(
            languageCode: Localizations.localeOf(context).languageCode,
          ),
          optionLeading: (value) => Text(
            CurrencyCatalog.currency(value).symbol,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          leading: const Icon(Icons.currency_exchange_rounded),
          onChanged: (value) => setState(() => _currencyCode = value),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.currencyHistoryNote,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(context.l10n.savePreferences),
        ),
      ],
    ),
  );
}
