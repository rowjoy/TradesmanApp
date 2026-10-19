enum AppFeatureId {
  workPlanning,
  timeTracking,
  contacts,
  calendar,
  payAndIncome,
  workRecords,
  reports,
  reminders,
  backup,
  security,
  promotions,
  codeTools,
}

enum AppFeatureDestination {
  work,
  people,
  calendar,
  money,
  proof,
  reports,
  reminders,
  backup,
  security,
  promotions,
  codeTools,
}

enum AppFeatureIcon {
  work,
  timer,
  contacts,
  calendar,
  money,
  records,
  reports,
  reminders,
  backup,
  security,
  promotions,
  codes,
}

enum AppFeatureAvailability { available, unavailable }

/// Stable, UI-agnostic metadata for a feature shown to users.
///
/// Visible copy and Material icons are resolved in the presentation layer so
/// this model stays independent from Flutter and the localization generator.
class AppFeature {
  const AppFeature({
    required this.id,
    required this.titleLocalizationKey,
    required this.shortDescriptionLocalizationKey,
    required this.descriptionLocalizationKey,
    required this.icon,
    required this.destination,
    this.availability = AppFeatureAvailability.available,
  });

  final AppFeatureId id;
  final String titleLocalizationKey;
  final String shortDescriptionLocalizationKey;
  final String descriptionLocalizationKey;
  final AppFeatureIcon icon;
  final AppFeatureDestination destination;
  final AppFeatureAvailability availability;

  bool get isAvailable => availability == AppFeatureAvailability.available;
}

abstract final class AppFeatureCatalog {
  static const all = <AppFeature>[
    AppFeature(
      id: AppFeatureId.workPlanning,
      titleLocalizationKey: 'workTitle',
      shortDescriptionLocalizationKey: 'featureWorkShortDescription',
      descriptionLocalizationKey: 'featureWorkDescription',
      icon: AppFeatureIcon.work,
      destination: AppFeatureDestination.work,
    ),
    AppFeature(
      id: AppFeatureId.timeTracking,
      titleLocalizationKey: 'featureTimeTrackingTitle',
      shortDescriptionLocalizationKey: 'featureTimeTrackingShortDescription',
      descriptionLocalizationKey: 'featureTimeTrackingDescription',
      icon: AppFeatureIcon.timer,
      destination: AppFeatureDestination.work,
    ),
    AppFeature(
      id: AppFeatureId.contacts,
      titleLocalizationKey: 'peopleTitle',
      shortDescriptionLocalizationKey: 'featureContactsShortDescription',
      descriptionLocalizationKey: 'featureContactsDescription',
      icon: AppFeatureIcon.contacts,
      destination: AppFeatureDestination.people,
    ),
    AppFeature(
      id: AppFeatureId.calendar,
      titleLocalizationKey: 'calendarTitle',
      shortDescriptionLocalizationKey: 'featureCalendarShortDescription',
      descriptionLocalizationKey: 'featureCalendarDescription',
      icon: AppFeatureIcon.calendar,
      destination: AppFeatureDestination.calendar,
    ),
    AppFeature(
      id: AppFeatureId.payAndIncome,
      titleLocalizationKey: 'moneyTitle',
      shortDescriptionLocalizationKey: 'featurePayShortDescription',
      descriptionLocalizationKey: 'featurePayDescription',
      icon: AppFeatureIcon.money,
      destination: AppFeatureDestination.money,
    ),
    AppFeature(
      id: AppFeatureId.workRecords,
      titleLocalizationKey: 'proofTitle',
      shortDescriptionLocalizationKey: 'featureRecordsShortDescription',
      descriptionLocalizationKey: 'featureRecordsDescription',
      icon: AppFeatureIcon.records,
      destination: AppFeatureDestination.proof,
    ),
    AppFeature(
      id: AppFeatureId.reports,
      titleLocalizationKey: 'reportsTitle',
      shortDescriptionLocalizationKey: 'featureReportsShortDescription',
      descriptionLocalizationKey: 'featureReportsDescription',
      icon: AppFeatureIcon.reports,
      destination: AppFeatureDestination.reports,
    ),
    AppFeature(
      id: AppFeatureId.reminders,
      titleLocalizationKey: 'offlineNotificationsTitle',
      shortDescriptionLocalizationKey: 'featureRemindersShortDescription',
      descriptionLocalizationKey: 'featureRemindersDescription',
      icon: AppFeatureIcon.reminders,
      destination: AppFeatureDestination.reminders,
    ),
    AppFeature(
      id: AppFeatureId.backup,
      titleLocalizationKey: 'backupRestoreTitle',
      shortDescriptionLocalizationKey: 'featureBackupShortDescription',
      descriptionLocalizationKey: 'featureBackupDescription',
      icon: AppFeatureIcon.backup,
      destination: AppFeatureDestination.backup,
    ),
    AppFeature(
      id: AppFeatureId.security,
      titleLocalizationKey: 'securityPrivacyTitle',
      shortDescriptionLocalizationKey: 'featureSecurityShortDescription',
      descriptionLocalizationKey: 'featureSecurityDescription',
      icon: AppFeatureIcon.security,
      destination: AppFeatureDestination.security,
    ),
    AppFeature(
      id: AppFeatureId.promotions,
      titleLocalizationKey: 'marketingStudioTitle',
      shortDescriptionLocalizationKey: 'featurePromotionsShortDescription',
      descriptionLocalizationKey: 'featurePromotionsDescription',
      icon: AppFeatureIcon.promotions,
      destination: AppFeatureDestination.promotions,
    ),
    AppFeature(
      id: AppFeatureId.codeTools,
      titleLocalizationKey: 'codeToolsTitle',
      shortDescriptionLocalizationKey: 'codeToolsShortDescription',
      descriptionLocalizationKey: 'codeToolsDescription',
      icon: AppFeatureIcon.codes,
      destination: AppFeatureDestination.codeTools,
    ),
  ];

  static AppFeature forId(AppFeatureId id) =>
      all.singleWhere((feature) => feature.id == id);
}
