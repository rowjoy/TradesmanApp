// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/app_feedback.dart';
import '../../l10n/app_language.dart';
import '../../l10n/l10n.dart';
import '../onboarding/domain/entities/local_profile.dart';
import '../onboarding/presentation/controllers/onboarding_controller.dart';
import '../showcase/data/showcase_repository.dart';
import '../time_tracking/time_tracking_provider.dart';
import '../ads/application/ads_consent_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(currentProfileProvider);
    final adsConsent = ref.watch(adsConsentControllerProvider);

    Future<void> openPreferences() async {
      final saved = await context.push<bool>(AppRoutes.preferences);
      if (context.mounted && saved == true) {
        AppFeedback.success(context, context.l10n.preferencesSaved);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        key: const PageStorageKey('settings-root'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.l10n.appearanceTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(context.l10n.themeLight),
                    secondary: const Icon(Icons.light_mode_outlined),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (m) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(m!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(context.l10n.themeDark),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (m) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(m!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(context.l10n.themeSystem),
                    secondary: const Icon(Icons.brightness_auto_outlined),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (m) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(m!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.workProfileTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(profile?.profession ?? context.l10n.localProfile),
                  subtitle: Text(_modeLabel(context, profile?.workMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: openPreferences,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.public_outlined),
                  title: Text(context.l10n.countryCurrencyTitle),
                  subtitle: Text(
                    '${profile?.countryCode ?? 'GB'} · ${profile?.currencyCode ?? 'GBP'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: openPreferences,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(context.l10n.languageLabel),
                  subtitle: Text(
                    AppLanguage.fromCode(profile?.languageCode ?? 'en').nativeName,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: openPreferences,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.campaign_outlined),
              ),
              title: Text(context.l10n.marketingStudioTitle),
              subtitle: Text(context.l10n.marketingStudioSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.marketingStudio),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.qr_code_scanner_rounded),
              ),
              title: Text(
                Localizations.localeOf(context).languageCode == 'bn'
                    ? 'QR ও বারকোড স্টুডিও'
                    : 'QR & Barcode Studio',
              ),
              subtitle: Text(
                Localizations.localeOf(context).languageCode == 'bn'
                    ? 'QR ও বারকোড স্ক্যান, তৈরি ও শেয়ার করুন'
                    : 'Scan, create, and share QR codes and barcodes',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.codeStudio),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.notificationsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(context.l10n.offlineNotificationsTitle),
              subtitle: Text(context.l10n.offlineNotificationsDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.notifications),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.dataTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_android_outlined),
                  title: Text(context.l10n.savedOnDevice),
                  subtitle: Text(context.l10n.localDataDescription),
                  trailing: const Icon(Icons.offline_pin_outlined),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore_rounded),
                  title: Text(context.l10n.backupRestoreTitle),
                  subtitle: Text(context.l10n.backupRestoreSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.backupRestore),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.assessment_outlined),
                  title: Text(context.l10n.reportsTitle),
                  subtitle: Text(context.l10n.reportsOfflineDescription),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.reports),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.securityPrivacyTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: Text(context.l10n.appLockTitle),
                  subtitle: Text(context.l10n.appLockSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.security),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(context.l10n.privacyChoicesTitle),
                  subtitle: Text(
                    adsConsent.privacyOptionsRequired
                        ? context.l10n.privacyChoicesAvailable
                        : context.l10n.privacyChoicesDescription,
                  ),
                  trailing: adsConsent.status == AdsConsentStatus.gathering
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: adsConsent.status == AdsConsentStatus.gathering
                      ? null
                      : () async {
                          final result = await ref
                              .read(adsConsentControllerProvider.notifier)
                              .showPrivacyChoices();
                          if (!context.mounted) return;
                          switch (result) {
                            case PrivacyChoiceResult.shown:
                              AppFeedback.success(
                                context,
                                context.l10n.privacyChoicesUpdated,
                              );
                              break;
                            case PrivacyChoiceResult.notRequired:
                              AppFeedback.info(
                                context,
                                context.l10n.privacyChoicesNotRequired,
                              );
                              break;
                            case PrivacyChoiceResult.failed:
                              AppFeedback.error(
                                context,
                                context.l10n.privacyChoicesFailed,
                              );
                              break;
                          }
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.helpAndGuidance,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tour_outlined),
                  title: Text(context.l10n.replayShowcase),
                  subtitle: Text(context.l10n.helpAndGuidance),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final active = await ref.read(
                      activeTimeEntryProvider.future,
                    );
                    if (!context.mounted) return;
                    if (active != null) {
                      AppFeedback.info(
                        context,
                        context.l10n.showcaseBlockedByTimer,
                      );
                      return;
                    }
                    final repository = ref.read(showcaseRepositoryProvider);
                    await repository.resetModule03();
                    await repository.resetScreenGuides();
                    await repository.resetModule05();
                    ref.invalidate(module03ShowcaseCompletedProvider);
                    ref.invalidate(module05ShowcaseCompletedProvider);
                    if (!context.mounted) return;
                    context.go(AppRoutes.home);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref
                          .read(
                            module03ShowcaseReplayRequestProvider.notifier,
                          )
                          .state++;
                    });
                  },
                ),
                if (profile?.workMode != WorkMode.tradesman) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: Text(context.l10n.payProtectionGuide),
                    subtitle: Text(
                      context.l10n.payProtectionGuideDescription,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await ref
                          .read(showcaseRepositoryProvider)
                          .resetModule05();
                      ref.invalidate(module05ShowcaseCompletedProvider);
                      if (!context.mounted) return;
                      context.go(AppRoutes.money);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(
                              module05ShowcaseReplayRequestProvider.notifier,
                            )
                            .state++;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(BuildContext context, WorkMode? mode) => switch (mode) {
    WorkMode.worker => context.l10n.profileModeWorker,
    WorkMode.tradesman => context.l10n.profileModeTradesman,
    WorkMode.both => context.l10n.profileModeBoth,
    null => context.l10n.localOnlyStatus,
  };
}
