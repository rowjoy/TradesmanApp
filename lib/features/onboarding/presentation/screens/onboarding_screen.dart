import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/money/currency_catalog.dart';
import '../../../../core/money/money.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/inline_animated_picker.dart';
import '../../../../l10n/app_language.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/local_profile.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _introPageCount = 3;
  static const _pageCount = 7;

  final _pageController = PageController();
  final _professionController = TextEditingController();
  final _rateController = TextEditingController();

  int _page = 0;
  String _languageCode = 'en';
  WorkMode _workMode = WorkMode.tradesman;
  String _countryCode = 'GB';
  String _currencyCode = 'GBP';
  PayMethod _payMethod = PayMethod.hourly;
  AppThemePreference _theme = AppThemePreference.system;
  bool _loadDemoData = true;
  bool _saving = false;
  bool _languageInitialized = false;
  String? _professionError;
  String? _rateError;
  String? _saveError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_languageInitialized) {
      _languageInitialized = true;
      final deviceLanguage = Localizations.localeOf(context).languageCode;
      if (AppLanguage.languages.any((item) => item.code == deviceLanguage)) {
        _languageCode = deviceLanguage;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _professionController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_page == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _continue(BuildContext localizedContext) {
    if (_page == _introPageCount + 1 &&
        _professionController.text.trim().isEmpty) {
      setState(
        () => _professionError = localizedContext.l10n.professionRequired,
      );
      return;
    }
    if (_page == _introPageCount + 2 &&
        !_validateRate(localizedContext)) {
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  bool _validateRate(BuildContext localizedContext) {
    final input = _rateController.text.trim();
    if (input.isEmpty) {
      setState(() => _rateError = null);
      return true;
    }
    final parsed = Money.tryParse(input, currencyCode: _currencyCode);
    setState(
      () => _rateError = parsed == null
          ? localizedContext.l10n.invalidRate
          : null,
    );
    return parsed != null;
  }

  Future<void> _finish(BuildContext localizedContext) async {
    if (!_validateRate(localizedContext)) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final parsedRate = _rateController.text.trim().isEmpty
        ? null
        : Money.tryParse(
            _rateController.text,
            currencyCode: _currencyCode,
          )?.minorUnits;
    final themeMode = switch (_theme) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };

    try {
      await ref.read(themeModeProvider.notifier).setThemeMode(themeMode);
      await ref
          .read(onboardingControllerProvider.notifier)
          .complete(
            LocalProfileDraft(
              languageCode: _languageCode,
              workMode: _workMode,
              countryCode: _countryCode,
              currencyCode: _currencyCode,
              profession: _professionController.text.trim(),
              payMethod: _payMethod,
              defaultRateMinor: parsedRate,
              themePreference: _theme,
              loadDemoData: _loadDemoData,
            ),
          );
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = localizedContext.l10n.setupSaveFailed;
        });
      }
    }
  }

  Future<void> _skip(BuildContext localizedContext) async {
    _professionController.text = localizedContext.l10n.generalWork;
    _rateController.clear();
    setState(() {
      _workMode = WorkMode.tradesman;
      _countryCode = 'GB';
      _currencyCode = 'GBP';
      _payMethod = PayMethod.hourly;
      _theme = AppThemePreference.system;
      _loadDemoData = false;
    });
    await _finish(localizedContext);
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: Locale(_languageCode),
      child: Builder(
        builder: (localizedContext) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(localizedContext.l10n.onboardingTitle),
            actions: [
              TextButton(
                onPressed: _saving ? null : () => _skip(localizedContext),
                child: Text(localizedContext.l10n.skipSetup),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _LanguageMenu(
                          value: _languageCode,
                          onChanged: (value) =>
                              setState(() => _languageCode = value),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: (_page + 1) / _pageCount,
                          backgroundColor: Theme.of(
                            localizedContext,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (value) => setState(() => _page = value),
                    children: [
                      _IntroStep(
                        asset: 'assets/onboarding/plan_work.svg',
                        title: localizedContext.l10n.workTitle,
                        description:
                            localizedContext.l10n.tradesmanModeDescription,
                        benefits: [
                          localizedContext.l10n.customers,
                          localizedContext.l10n.scheduleTitle,
                          localizedContext.l10n.pricingLabel,
                        ],
                      ),
                      _IntroStep(
                        asset: 'assets/onboarding/track_offline.svg',
                        title: localizedContext.l10n.tagline,
                        description:
                            localizedContext.l10n.showcaseClockInBody,
                        benefits: [
                          localizedContext.l10n.clockIn,
                          localizedContext.l10n.startBreak,
                          localizedContext.l10n.clockOut,
                          localizedContext.l10n.offlineNotificationsTitle,
                        ],
                      ),
                      _IntroStep(
                        asset: 'assets/onboarding/share_proof.svg',
                        title: localizedContext.l10n.showcaseProofTitle,
                        description:
                            localizedContext.l10n.reportsOfflineDescription,
                        benefits: [
                          localizedContext.l10n.exportPdf,
                          '${localizedContext.l10n.emailLabel} / WhatsApp',
                          localizedContext.l10n.localDataDescription,
                        ],
                      ),
                      _LanguageAndModeStep(
                        workMode: _workMode,
                        onModeChanged: (value) =>
                            setState(() => _workMode = value),
                      ),
                      _MarketStep(
                        countryCode: _countryCode,
                        currencyCode: _currencyCode,
                        professionController: _professionController,
                        professionError: _professionError,
                        onCountryChanged: (value) => setState(() {
                          _countryCode = value;
                          _currencyCode = CurrencyCatalog.market(
                            value,
                          ).defaultCurrencyCode;
                        }),
                        onCurrencyChanged: (value) =>
                            setState(() => _currencyCode = value),
                        onProfessionChanged: (_) {
                          if (_professionError != null) {
                            setState(() => _professionError = null);
                          }
                        },
                      ),
                      _PayMethodStep(
                        payMethod: _payMethod,
                        currencyCode: _currencyCode,
                        rateController: _rateController,
                        rateError: _rateError,
                        onMethodChanged: (value) =>
                            setState(() => _payMethod = value),
                        onRateChanged: (_) {
                          if (_rateError != null) {
                            setState(() => _rateError = null);
                          }
                        },
                      ),
                      _PreferencesStep(
                        theme: _theme,
                        loadDemoData: _loadDemoData,
                        onThemeChanged: (value) =>
                            setState(() => _theme = value),
                        onDemoChanged: (value) =>
                            setState(() => _loadDemoData = value),
                      ),
                    ],
                  ),
                ),
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _saveError!,
                      style: const TextStyle(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                  child: Row(
                    children: [
                      if (_page > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : _goBack,
                            child: Text(localizedContext.l10n.backLabel),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: _page > 0 ? 1 : 2,
                        child: ElevatedButton(
                          onPressed: _saving
                              ? null
                              : _page == _pageCount - 1
                              ? () => _finish(localizedContext)
                              : () => _continue(localizedContext),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _page == _pageCount - 1
                                      ? localizedContext.l10n.finishSetup
                                      : localizedContext.l10n.continueLabel,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageAndModeStep extends StatelessWidget {
  const _LanguageAndModeStep({
    required this.workMode,
    required this.onModeChanged,
  });

  final WorkMode workMode;
  final ValueChanged<WorkMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        _StepTitle(context.l10n.workModeTitle),
        const SizedBox(height: 12),
        _ModeCard(
          selected: workMode == WorkMode.worker,
          icon: Icons.badge_outlined,
          title: context.l10n.workerMode,
          subtitle: context.l10n.workerModeDescription,
          onTap: () => onModeChanged(WorkMode.worker),
        ),
        const SizedBox(height: 10),
        _ModeCard(
          selected: workMode == WorkMode.tradesman,
          icon: Icons.handyman_outlined,
          title: context.l10n.tradesmanMode,
          subtitle: context.l10n.tradesmanModeDescription,
          onTap: () => onModeChanged(WorkMode.tradesman),
        ),
        const SizedBox(height: 10),
        _ModeCard(
          selected: workMode == WorkMode.both,
          icon: Icons.call_split_outlined,
          title: context.l10n.bothMode,
          subtitle: context.l10n.bothModeDescription,
          onTap: () => onModeChanged(WorkMode.both),
        ),
      ],
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = AppLanguage.fromCode(value);
    return PopupMenuButton<String>(
      initialValue: value,
      tooltip: context.l10n.languageTitle,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final language in AppLanguage.languages)
          PopupMenuItem(
            value: language.code,
            child: Row(
              children: [
                Text(language.flag),
                const SizedBox(width: 10),
                Expanded(child: Text(language.nativeName)),
                if (language.code == value)
                  Icon(
                    Icons.check_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
      ],
      child: Semantics(
        button: true,
        label: context.l10n.languageTitle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(selected.flag),
              const SizedBox(width: 8),
              Text(
                selected.nativeName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroStep extends StatefulWidget {
  const _IntroStep({
    required this.asset,
    required this.title,
    required this.description,
    required this.benefits,
  });

  final String asset;
  final String title;
  final String description;
  final List<String> benefits;

  @override
  State<_IntroStep> createState() => _IntroStepState();
}

class _IntroStepState extends State<_IntroStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      children: [
        SizedBox(
          height: 230,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final wave = math.sin(_animation.value * math.pi * 2);
              return Transform.translate(
                offset: Offset(0, wave * 7),
                child: Transform.scale(
                  scale: 0.985 + ((wave + 1) * 0.008),
                  child: child,
                ),
              );
            },
            child: SvgPicture.asset(widget.asset, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final benefit in widget.benefits)
              Chip(
                avatar: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: colors.primary,
                ),
                label: Text(benefit),
              ),
          ],
        ),
      ],
    );
  }
}

class _MarketStep extends StatelessWidget {
  const _MarketStep({
    required this.countryCode,
    required this.currencyCode,
    required this.professionController,
    required this.professionError,
    required this.onCountryChanged,
    required this.onCurrencyChanged,
    required this.onProfessionChanged,
  });

  final String countryCode;
  final String currencyCode;
  final TextEditingController professionController;
  final String? professionError;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onProfessionChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        _StepTitle(context.l10n.marketTitle),
        const SizedBox(height: 18),
        InlineAnimatedPicker<String>(
          label: context.l10n.countryLabel,
          value: countryCode,
          options: CurrencyCatalog.markets
              .map((item) => item.code)
              .toList(growable: false),
          optionLabel: (value) => CurrencyCatalog.market(value).label(
            languageCode: Localizations.localeOf(context).languageCode,
          ),
          optionLeading: (value) => Text(CurrencyCatalog.market(value).flag),
          leading: const Icon(Icons.public_rounded),
          onChanged: onCountryChanged,
        ),
        const SizedBox(height: 16),
        InlineAnimatedPicker<String>(
          label: context.l10n.currencyLabel,
          value: currencyCode,
          options: CurrencyCatalog.currencies
              .map((item) => item.code)
              .toList(growable: false),
          optionLabel: (value) => CurrencyCatalog.currency(value).label(
            languageCode: Localizations.localeOf(context).languageCode,
          ),
          optionLeading: (value) => Text(
            CurrencyCatalog.currency(value).symbol,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          leading: const Icon(Icons.currency_exchange_rounded),
          onChanged: onCurrencyChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: professionController,
          onChanged: onProfessionChanged,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: context.l10n.professionLabel,
            hintText: context.l10n.professionHint,
            errorText: professionError,
          ),
        ),
      ],
    );
  }
}

class _PayMethodStep extends StatelessWidget {
  const _PayMethodStep({
    required this.payMethod,
    required this.currencyCode,
    required this.rateController,
    required this.rateError,
    required this.onMethodChanged,
    required this.onRateChanged,
  });

  final PayMethod payMethod;
  final String currencyCode;
  final TextEditingController rateController;
  final String? rateError;
  final ValueChanged<PayMethod> onMethodChanged;
  final ValueChanged<String> onRateChanged;

  @override
  Widget build(BuildContext context) {
    final currencySymbol = CurrencyCatalog.currency(currencyCode).symbol;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        _StepTitle(context.l10n.payMethodTitle),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MethodChip(
              label: context.l10n.methodHourly,
              value: PayMethod.hourly,
              selected: payMethod,
              onChanged: onMethodChanged,
            ),
            _MethodChip(
              label: context.l10n.methodDaily,
              value: PayMethod.daily,
              selected: payMethod,
              onChanged: onMethodChanged,
            ),
            _MethodChip(
              label: context.l10n.methodFixed,
              value: PayMethod.fixed,
              selected: payMethod,
              onChanged: onMethodChanged,
            ),
            _MethodChip(
              label: context.l10n.methodMixed,
              value: PayMethod.mixed,
              selected: payMethod,
              onChanged: onMethodChanged,
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: rateController,
          onChanged: onRateChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.l10n.defaultRateLabel,
            prefixText: '$currencySymbol ',
            errorText: rateError,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.skipOptional,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PreferencesStep extends StatelessWidget {
  const _PreferencesStep({
    required this.theme,
    required this.loadDemoData,
    required this.onThemeChanged,
    required this.onDemoChanged,
  });

  final AppThemePreference theme;
  final bool loadDemoData;
  final ValueChanged<AppThemePreference> onThemeChanged;
  final ValueChanged<bool> onDemoChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        _StepTitle(context.l10n.preferencesTitle),
        const SizedBox(height: 18),
        Text(
          context.l10n.themeLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        SegmentedButton<AppThemePreference>(
          segments: [
            ButtonSegment(
              value: AppThemePreference.system,
              icon: const Icon(Icons.brightness_auto_outlined),
              label: Text(context.l10n.themeSystem),
            ),
            ButtonSegment(
              value: AppThemePreference.light,
              icon: const Icon(Icons.light_mode_outlined),
              label: Text(context.l10n.themeLight),
            ),
            ButtonSegment(
              value: AppThemePreference.dark,
              icon: const Icon(Icons.dark_mode_outlined),
              label: Text(context.l10n.themeDark),
            ),
          ],
          selected: {theme},
          showSelectedIcon: false,
          onSelectionChanged: (value) => onThemeChanged(value.first),
        ),
        const SizedBox(height: 24),
        Card(
          child: SwitchListTile(
            value: loadDemoData,
            onChanged: onDemoChanged,
            secondary: const Icon(Icons.science_outlined),
            title: Text(context.l10n.demoDataTitle),
            subtitle: Text(context.l10n.demoDataDescription),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(context.l10n.privacySetupNote)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer.withValues(alpha: 0.5)
                : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final PayMethod value;
  final PayMethod selected;
  final ValueChanged<PayMethod> onChanged;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected == value,
    onSelected: (_) => onChanged(value),
  );
}
