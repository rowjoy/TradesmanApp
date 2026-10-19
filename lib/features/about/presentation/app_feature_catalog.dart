import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/app_feature.dart';

extension AppFeaturePresentation on AppFeature {
  String title(AppLocalizations strings) =>
      _resolveFeatureCopy(strings, titleLocalizationKey);

  String shortDescription(AppLocalizations strings) =>
      _resolveFeatureCopy(strings, shortDescriptionLocalizationKey);

  String description(AppLocalizations strings) =>
      _resolveFeatureCopy(strings, descriptionLocalizationKey);

  IconData get materialIcon => switch (icon) {
    AppFeatureIcon.work => Icons.work_outline_rounded,
    AppFeatureIcon.timer => Icons.timer_outlined,
    AppFeatureIcon.contacts => Icons.people_outline_rounded,
    AppFeatureIcon.calendar => Icons.calendar_month_outlined,
    AppFeatureIcon.money => Icons.payments_outlined,
    AppFeatureIcon.records => Icons.fact_check_outlined,
    AppFeatureIcon.reports => Icons.assessment_outlined,
    AppFeatureIcon.reminders => Icons.notifications_active_outlined,
    AppFeatureIcon.backup => Icons.settings_backup_restore_rounded,
    AppFeatureIcon.security => Icons.security_outlined,
    AppFeatureIcon.promotions => Icons.campaign_outlined,
    AppFeatureIcon.codes => Icons.qr_code_scanner_rounded,
  };
}

String _resolveFeatureCopy(
  AppLocalizations strings,
  String key,
) => switch (key) {
  'workTitle' => strings.workTitle,
  'featureTimeTrackingTitle' => strings.featureTimeTrackingTitle,
  'peopleTitle' => strings.peopleTitle,
  'calendarTitle' => strings.calendarTitle,
  'moneyTitle' => strings.moneyTitle,
  'proofTitle' => strings.proofTitle,
  'reportsTitle' => strings.reportsTitle,
  'offlineNotificationsTitle' => strings.offlineNotificationsTitle,
  'backupRestoreTitle' => strings.backupRestoreTitle,
  'securityPrivacyTitle' => strings.securityPrivacyTitle,
  'marketingStudioTitle' => strings.marketingStudioTitle,
  'codeToolsTitle' => strings.codeToolsTitle,
  'featureWorkShortDescription' => strings.featureWorkShortDescription,
  'featureTimeTrackingShortDescription' =>
    strings.featureTimeTrackingShortDescription,
  'featureContactsShortDescription' => strings.featureContactsShortDescription,
  'featureCalendarShortDescription' => strings.featureCalendarShortDescription,
  'featurePayShortDescription' => strings.featurePayShortDescription,
  'featureRecordsShortDescription' => strings.featureRecordsShortDescription,
  'featureReportsShortDescription' => strings.featureReportsShortDescription,
  'featureRemindersShortDescription' =>
    strings.featureRemindersShortDescription,
  'featureBackupShortDescription' => strings.featureBackupShortDescription,
  'featureSecurityShortDescription' => strings.featureSecurityShortDescription,
  'featurePromotionsShortDescription' =>
    strings.featurePromotionsShortDescription,
  'codeToolsShortDescription' => strings.codeToolsShortDescription,
  'featureWorkDescription' => strings.featureWorkDescription,
  'featureTimeTrackingDescription' => strings.featureTimeTrackingDescription,
  'featureContactsDescription' => strings.featureContactsDescription,
  'featureCalendarDescription' => strings.featureCalendarDescription,
  'featurePayDescription' => strings.featurePayDescription,
  'featureRecordsDescription' => strings.featureRecordsDescription,
  'featureReportsDescription' => strings.featureReportsDescription,
  'featureRemindersDescription' => strings.featureRemindersDescription,
  'featureBackupDescription' => strings.featureBackupDescription,
  'featureSecurityDescription' => strings.featureSecurityDescription,
  'featurePromotionsDescription' => strings.featurePromotionsDescription,
  'codeToolsDescription' => strings.codeToolsDescription,
  _ => throw ArgumentError.value(
    key,
    'key',
    'Unknown feature localization key',
  ),
};
