import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_yo.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('ga'),
    Locale('hi'),
    Locale('ja'),
    Locale('pl'),
    Locale('ro'),
    Locale('ur'),
    Locale('yo'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WorkProof'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Track your work. Protect your pay. Keep your proof.'**
  String get tagline;

  /// No description provided for @loadingApp.
  ///
  /// In en, this message translates to:
  /// **'Opening your local workspace…'**
  String get loadingApp;

  /// No description provided for @startupFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not open your local workspace.'**
  String get startupFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @skipSetup.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipSetup;

  /// No description provided for @skipOptional.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings.'**
  String get skipOptional;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up WorkProof'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No account or internet is required.'**
  String get onboardingSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @workModeTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you work?'**
  String get workModeTitle;

  /// No description provided for @workerMode.
  ///
  /// In en, this message translates to:
  /// **'I work for an employer'**
  String get workerMode;

  /// No description provided for @workerModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Shifts, hours, expected pay, and payslips'**
  String get workerModeDescription;

  /// No description provided for @tradesmanMode.
  ///
  /// In en, this message translates to:
  /// **'I work for my own customers'**
  String get tradesmanMode;

  /// No description provided for @tradesmanModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Jobs, customers, quotes, and invoices'**
  String get tradesmanModeDescription;

  /// No description provided for @bothMode.
  ///
  /// In en, this message translates to:
  /// **'I do both'**
  String get bothMode;

  /// No description provided for @bothModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep employer work and customer work separate'**
  String get bothModeDescription;

  /// No description provided for @marketTitle.
  ///
  /// In en, this message translates to:
  /// **'Your work setup'**
  String get marketTitle;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @countryUnitedKingdom.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get countryUnitedKingdom;

  /// No description provided for @countryOther.
  ///
  /// In en, this message translates to:
  /// **'Other / not listed yet'**
  String get countryOther;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @professionLabel.
  ///
  /// In en, this message translates to:
  /// **'Profession or sector'**
  String get professionLabel;

  /// No description provided for @professionHint.
  ///
  /// In en, this message translates to:
  /// **'For example: construction, care, cleaning'**
  String get professionHint;

  /// No description provided for @professionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your profession or sector'**
  String get professionRequired;

  /// No description provided for @payMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Usual pay or charging method'**
  String get payMethodTitle;

  /// No description provided for @methodHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get methodHourly;

  /// No description provided for @methodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get methodDaily;

  /// No description provided for @methodFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get methodFixed;

  /// No description provided for @methodMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get methodMixed;

  /// No description provided for @defaultRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Default rate (optional)'**
  String get defaultRateLabel;

  /// No description provided for @invalidRate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount with up to 2 decimal places'**
  String get invalidRate;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get preferencesTitle;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @demoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Load editable demo data'**
  String get demoDataTitle;

  /// No description provided for @demoDataDescription.
  ///
  /// In en, this message translates to:
  /// **'See the workflow with a sample customer and job.'**
  String get demoDataDescription;

  /// No description provided for @privacySetupNote.
  ///
  /// In en, this message translates to:
  /// **'Your setup is saved only on this device. Cloud backup is optional and can be enabled later.'**
  String get privacySetupNote;

  /// No description provided for @setupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup was not saved. Your current data was not changed.'**
  String get setupSaveFailed;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get navWork;

  /// No description provided for @navMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get navMoney;

  /// No description provided for @navProof.
  ///
  /// In en, this message translates to:
  /// **'Proof'**
  String get navProof;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @moneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get moneyTitle;

  /// No description provided for @moneyExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected earnings'**
  String get moneyExpected;

  /// No description provided for @moneyTrackedTime.
  ///
  /// In en, this message translates to:
  /// **'Tracked time'**
  String get moneyTrackedTime;

  /// No description provided for @moneyCompletedEntries.
  ///
  /// In en, this message translates to:
  /// **'Completed work records'**
  String get moneyCompletedEntries;

  /// No description provided for @moneyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete a tracked job to see deterministic earnings here.'**
  String get moneyEmpty;

  /// No description provided for @proofTitle.
  ///
  /// In en, this message translates to:
  /// **'Proof'**
  String get proofTitle;

  /// No description provided for @proofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local activity record'**
  String get proofSubtitle;

  /// No description provided for @proofEmpty.
  ///
  /// In en, this message translates to:
  /// **'Actions recorded from this version will appear here.'**
  String get proofEmpty;

  /// No description provided for @savedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get savedOnDevice;

  /// No description provided for @localOnlyStatus.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get localOnlyStatus;

  /// No description provided for @auditOnboardingCompleted.
  ///
  /// In en, this message translates to:
  /// **'WorkProof setup completed'**
  String get auditOnboardingCompleted;

  /// No description provided for @auditCustomerCreated.
  ///
  /// In en, this message translates to:
  /// **'Customer created'**
  String get auditCustomerCreated;

  /// No description provided for @auditJobCreated.
  ///
  /// In en, this message translates to:
  /// **'Job created'**
  String get auditJobCreated;

  /// No description provided for @auditClockedIn.
  ///
  /// In en, this message translates to:
  /// **'Clocked in'**
  String get auditClockedIn;

  /// No description provided for @auditBreakStarted.
  ///
  /// In en, this message translates to:
  /// **'Break started'**
  String get auditBreakStarted;

  /// No description provided for @auditBreakEnded.
  ///
  /// In en, this message translates to:
  /// **'Break ended'**
  String get auditBreakEnded;

  /// No description provided for @auditClockedOut.
  ///
  /// In en, this message translates to:
  /// **'Clocked out'**
  String get auditClockedOut;

  /// No description provided for @unknownActivity.
  ///
  /// In en, this message translates to:
  /// **'Work activity recorded'**
  String get unknownActivity;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profileModeWorker.
  ///
  /// In en, this message translates to:
  /// **'Worker mode'**
  String get profileModeWorker;

  /// No description provided for @profileModeTradesman.
  ///
  /// In en, this message translates to:
  /// **'Tradesman mode'**
  String get profileModeTradesman;

  /// No description provided for @profileModeBoth.
  ///
  /// In en, this message translates to:
  /// **'Worker + Tradesman mode'**
  String get profileModeBoth;

  /// No description provided for @workTitle.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get workTitle;

  /// No description provided for @workerFlow.
  ///
  /// In en, this message translates to:
  /// **'Employer work'**
  String get workerFlow;

  /// No description provided for @tradesmanFlow.
  ///
  /// In en, this message translates to:
  /// **'Customer work'**
  String get tradesmanFlow;

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'People & services'**
  String get peopleTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @newShift.
  ///
  /// In en, this message translates to:
  /// **'New shift'**
  String get newShift;

  /// No description provided for @newJob.
  ///
  /// In en, this message translates to:
  /// **'New job'**
  String get newJob;

  /// No description provided for @editShift.
  ///
  /// In en, this message translates to:
  /// **'Edit shift'**
  String get editShift;

  /// No description provided for @editJob.
  ///
  /// In en, this message translates to:
  /// **'Edit job'**
  String get editJob;

  /// No description provided for @searchShifts.
  ///
  /// In en, this message translates to:
  /// **'Search shifts…'**
  String get searchShifts;

  /// No description provided for @searchJobs.
  ///
  /// In en, this message translates to:
  /// **'Search jobs…'**
  String get searchJobs;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search this directory…'**
  String get searchPeople;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @noShifts.
  ///
  /// In en, this message translates to:
  /// **'No shifts found. Add a normal or overnight shift.'**
  String get noShifts;

  /// No description provided for @noJobs.
  ///
  /// In en, this message translates to:
  /// **'No jobs found. Add your first customer job.'**
  String get noJobs;

  /// No description provided for @workLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load your work.'**
  String get workLoadFailed;

  /// No description provided for @notScheduled.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled'**
  String get notScheduled;

  /// No description provided for @trackTime.
  ///
  /// In en, this message translates to:
  /// **'Track time'**
  String get trackTime;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @deleteWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this work record?'**
  String get deleteWorkTitle;

  /// No description provided for @deleteWorkDescription.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from active lists and kept in the local audit history.'**
  String get deleteWorkDescription;

  /// No description provided for @employers.
  ///
  /// In en, this message translates to:
  /// **'Employers'**
  String get employers;

  /// No description provided for @workplaces.
  ///
  /// In en, this message translates to:
  /// **'Workplaces'**
  String get workplaces;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @noEmployers.
  ///
  /// In en, this message translates to:
  /// **'No employers yet.'**
  String get noEmployers;

  /// No description provided for @noWorkplaces.
  ///
  /// In en, this message translates to:
  /// **'No workplaces yet.'**
  String get noWorkplaces;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers yet.'**
  String get noCustomers;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No services yet.'**
  String get noServices;

  /// No description provided for @noContactInfo.
  ///
  /// In en, this message translates to:
  /// **'No contact information'**
  String get noContactInfo;

  /// No description provided for @peopleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load this directory.'**
  String get peopleLoadFailed;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordDescription.
  ///
  /// In en, this message translates to:
  /// **'Linked history will not be silently erased.'**
  String get deleteRecordDescription;

  /// No description provided for @newEmployer.
  ///
  /// In en, this message translates to:
  /// **'New employer'**
  String get newEmployer;

  /// No description provided for @editEmployer.
  ///
  /// In en, this message translates to:
  /// **'Edit employer'**
  String get editEmployer;

  /// No description provided for @employerName.
  ///
  /// In en, this message translates to:
  /// **'Employer or agency name'**
  String get employerName;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get contactName;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @paySchedule.
  ///
  /// In en, this message translates to:
  /// **'Pay schedule'**
  String get paySchedule;

  /// No description provided for @contractNotes.
  ///
  /// In en, this message translates to:
  /// **'Contract notes'**
  String get contractNotes;

  /// No description provided for @newWorkplace.
  ///
  /// In en, this message translates to:
  /// **'New workplace'**
  String get newWorkplace;

  /// No description provided for @editWorkplace.
  ///
  /// In en, this message translates to:
  /// **'Edit workplace'**
  String get editWorkplace;

  /// No description provided for @workplaceName.
  ///
  /// In en, this message translates to:
  /// **'Workplace name'**
  String get workplaceName;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @timeZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'IANA time zone'**
  String get timeZoneLabel;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerName;

  /// No description provided for @newService.
  ///
  /// In en, this message translates to:
  /// **'New service'**
  String get newService;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get editService;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service name'**
  String get serviceName;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @pricingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricingLabel;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Default duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'This record was not saved. Try again.'**
  String get saveFailed;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleTitle;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @endLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLabel;

  /// No description provided for @startUtcOffset.
  ///
  /// In en, this message translates to:
  /// **'Start UTC offset'**
  String get startUtcOffset;

  /// No description provided for @endUtcOffset.
  ///
  /// In en, this message translates to:
  /// **'End UTC offset'**
  String get endUtcOffset;

  /// No description provided for @overnightLabel.
  ///
  /// In en, this message translates to:
  /// **'Overnight'**
  String get overnightLabel;

  /// No description provided for @invalidSchedule.
  ///
  /// In en, this message translates to:
  /// **'End must be after start. Use the next date for overnight work.'**
  String get invalidSchedule;

  /// No description provided for @shiftTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Shift title'**
  String get shiftTitleLabel;

  /// No description provided for @employerOptional.
  ///
  /// In en, this message translates to:
  /// **'Employer (optional)'**
  String get employerOptional;

  /// No description provided for @workplaceOptional.
  ///
  /// In en, this message translates to:
  /// **'Workplace (optional)'**
  String get workplaceOptional;

  /// No description provided for @hourlyRateOptional.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate (optional)'**
  String get hourlyRateOptional;

  /// No description provided for @dailyRateOptional.
  ///
  /// In en, this message translates to:
  /// **'Daily rate (optional)'**
  String get dailyRateOptional;

  /// No description provided for @fixedPriceOptional.
  ///
  /// In en, this message translates to:
  /// **'Fixed price (optional)'**
  String get fixedPriceOptional;

  /// No description provided for @breakMinutes.
  ///
  /// In en, this message translates to:
  /// **'Break minutes'**
  String get breakMinutes;

  /// No description provided for @paidBreak.
  ///
  /// In en, this message translates to:
  /// **'Paid break'**
  String get paidBreak;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative number'**
  String get invalidNumber;

  /// No description provided for @remindersEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminders enabled'**
  String get remindersEnabled;

  /// No description provided for @reminderIntentNote.
  ///
  /// In en, this message translates to:
  /// **'Offline alerts will follow this work schedule.'**
  String get reminderIntentNote;

  /// No description provided for @saveShift.
  ///
  /// In en, this message translates to:
  /// **'Save shift'**
  String get saveShift;

  /// No description provided for @saveJob.
  ///
  /// In en, this message translates to:
  /// **'Save job'**
  String get saveJob;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved on this device.'**
  String get draftSaved;

  /// No description provided for @jobTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitleLabel;

  /// No description provided for @serviceOptional.
  ///
  /// In en, this message translates to:
  /// **'Service (optional)'**
  String get serviceOptional;

  /// No description provided for @calendarLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load this month.'**
  String get calendarLoadFailed;

  /// No description provided for @noWorkOnDate.
  ///
  /// In en, this message translates to:
  /// **'No work scheduled for this date.'**
  String get noWorkOnDate;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardTitle;

  /// No description provided for @shiftsLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s shifts'**
  String get shiftsLabel;

  /// No description provided for @jobsLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s jobs'**
  String get jobsLabel;

  /// No description provided for @todayWork.
  ///
  /// In en, this message translates to:
  /// **'Today\'s work'**
  String get todayWork;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @jobTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Job time'**
  String get jobTimerTitle;

  /// No description provided for @shiftTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift time'**
  String get shiftTimerTitle;

  /// No description provided for @workRecordNotFound.
  ///
  /// In en, this message translates to:
  /// **'This work record was not found.'**
  String get workRecordNotFound;

  /// No description provided for @timerRecovered.
  ///
  /// In en, this message translates to:
  /// **'Active timer restored from this device. Its time is reconstructed from saved timestamps.'**
  String get timerRecovered;

  /// No description provided for @activeSessionExists.
  ///
  /// In en, this message translates to:
  /// **'Another timer is active'**
  String get activeSessionExists;

  /// No description provided for @activeSessionExistsDescription.
  ///
  /// In en, this message translates to:
  /// **'WorkProof allows one active Job or Shift at a time.'**
  String get activeSessionExistsDescription;

  /// No description provided for @openActiveWork.
  ///
  /// In en, this message translates to:
  /// **'Open active work'**
  String get openActiveWork;

  /// No description provided for @openLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLabel;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @lastBillableTime.
  ///
  /// In en, this message translates to:
  /// **'Last billable time'**
  String get lastBillableTime;

  /// No description provided for @onBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get onBreak;

  /// No description provided for @timerRunning.
  ///
  /// In en, this message translates to:
  /// **'Timer running'**
  String get timerRunning;

  /// No description provided for @anotherTimerRunning.
  ///
  /// In en, this message translates to:
  /// **'Another timer is running'**
  String get anotherTimerRunning;

  /// No description provided for @clockIn.
  ///
  /// In en, this message translates to:
  /// **'Clock In'**
  String get clockIn;

  /// No description provided for @clockOut.
  ///
  /// In en, this message translates to:
  /// **'Clock Out'**
  String get clockOut;

  /// No description provided for @resumeWork.
  ///
  /// In en, this message translates to:
  /// **'Resume work'**
  String get resumeWork;

  /// No description provided for @startBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get startBreak;

  /// No description provided for @chooseBreakType.
  ///
  /// In en, this message translates to:
  /// **'Choose break type'**
  String get chooseBreakType;

  /// No description provided for @paidBreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Counts as billable work time.'**
  String get paidBreakDescription;

  /// No description provided for @unpaidBreak.
  ///
  /// In en, this message translates to:
  /// **'Unpaid break'**
  String get unpaidBreak;

  /// No description provided for @unpaidBreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Removed from billable work time.'**
  String get unpaidBreakDescription;

  /// No description provided for @clockOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clock out now?'**
  String get clockOutConfirmTitle;

  /// No description provided for @clockOutConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Any open break will end at the same time.'**
  String get clockOutConfirmDescription;

  /// No description provided for @timerActionFailed.
  ///
  /// In en, this message translates to:
  /// **'That timer action was not saved. Try again.'**
  String get timerActionFailed;

  /// No description provided for @timerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This timer could not be loaded.'**
  String get timerLoadFailed;

  /// No description provided for @payRules.
  ///
  /// In en, this message translates to:
  /// **'Pay rules'**
  String get payRules;

  /// No description provided for @payRulesDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional overtime, premium, and rounding settings'**
  String get payRulesDescription;

  /// No description provided for @overtimeAfter.
  ///
  /// In en, this message translates to:
  /// **'Overtime after'**
  String get overtimeAfter;

  /// No description provided for @overtimeMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Overtime multiplier'**
  String get overtimeMultiplier;

  /// No description provided for @ratePremium.
  ///
  /// In en, this message translates to:
  /// **'Rate premium'**
  String get ratePremium;

  /// No description provided for @timeRounding.
  ///
  /// In en, this message translates to:
  /// **'Billable time rounding'**
  String get timeRounding;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'hr'**
  String get hoursShort;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get daysShort;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @extraPay.
  ///
  /// In en, this message translates to:
  /// **'Tips, bonus or allowance'**
  String get extraPay;

  /// No description provided for @plannedVsActual.
  ///
  /// In en, this message translates to:
  /// **'Planned vs actual'**
  String get plannedVsActual;

  /// No description provided for @plannedTime.
  ///
  /// In en, this message translates to:
  /// **'Planned schedule'**
  String get plannedTime;

  /// No description provided for @actualTime.
  ///
  /// In en, this message translates to:
  /// **'Actual clock time'**
  String get actualTime;

  /// No description provided for @nowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowLabel;

  /// No description provided for @rawDuration.
  ///
  /// In en, this message translates to:
  /// **'Raw duration'**
  String get rawDuration;

  /// No description provided for @billableDuration.
  ///
  /// In en, this message translates to:
  /// **'Billable duration'**
  String get billableDuration;

  /// No description provided for @earningsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Earnings breakdown'**
  String get earningsBreakdown;

  /// No description provided for @baseRate.
  ///
  /// In en, this message translates to:
  /// **'Base rate'**
  String get baseRate;

  /// No description provided for @regularPay.
  ///
  /// In en, this message translates to:
  /// **'Regular pay'**
  String get regularPay;

  /// No description provided for @overtimePay.
  ///
  /// In en, this message translates to:
  /// **'Overtime pay'**
  String get overtimePay;

  /// No description provided for @premiumPay.
  ///
  /// In en, this message translates to:
  /// **'Premium pay'**
  String get premiumPay;

  /// No description provided for @fixedPay.
  ///
  /// In en, this message translates to:
  /// **'Fixed pay'**
  String get fixedPay;

  /// No description provided for @expectedTotal.
  ///
  /// In en, this message translates to:
  /// **'Expected total'**
  String get expectedTotal;

  /// No description provided for @calculationSnapshotNote.
  ///
  /// In en, this message translates to:
  /// **'Final values are saved as a deterministic calculation snapshot at Clock Out.'**
  String get calculationSnapshotNote;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get recentSessions;

  /// No description provided for @completedSession.
  ///
  /// In en, this message translates to:
  /// **'Completed session'**
  String get completedSession;

  /// No description provided for @correctTime.
  ///
  /// In en, this message translates to:
  /// **'Correct time'**
  String get correctTime;

  /// No description provided for @corrected.
  ///
  /// In en, this message translates to:
  /// **'Corrected'**
  String get corrected;

  /// No description provided for @actualStart.
  ///
  /// In en, this message translates to:
  /// **'Actual start'**
  String get actualStart;

  /// No description provided for @actualEnd.
  ///
  /// In en, this message translates to:
  /// **'Actual end'**
  String get actualEnd;

  /// No description provided for @correctionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for correction'**
  String get correctionReason;

  /// No description provided for @correctionReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Use a reason of at least 3 characters and check the times.'**
  String get correctionReasonRequired;

  /// No description provided for @correctionAuditNote.
  ///
  /// In en, this message translates to:
  /// **'The reason and corrected timestamps stay in the audit history.'**
  String get correctionAuditNote;

  /// No description provided for @auditPaidBreakStarted.
  ///
  /// In en, this message translates to:
  /// **'Paid break started'**
  String get auditPaidBreakStarted;

  /// No description provided for @auditUnpaidBreakStarted.
  ///
  /// In en, this message translates to:
  /// **'Unpaid break started'**
  String get auditUnpaidBreakStarted;

  /// No description provided for @auditTimeCorrected.
  ///
  /// In en, this message translates to:
  /// **'Tracked time corrected'**
  String get auditTimeCorrected;

  /// No description provided for @activeTimer.
  ///
  /// In en, this message translates to:
  /// **'Active work timer'**
  String get activeTimer;

  /// No description provided for @helpAndGuidance.
  ///
  /// In en, this message translates to:
  /// **'Help & guidance'**
  String get helpAndGuidance;

  /// No description provided for @replayShowcase.
  ///
  /// In en, this message translates to:
  /// **'Replay time tracking guide'**
  String get replayShowcase;

  /// No description provided for @replayShowcaseDescription.
  ///
  /// In en, this message translates to:
  /// **'See the five-step Clock In and Clock Out workflow again.'**
  String get replayShowcaseDescription;

  /// No description provided for @showcaseBlockedByTimer.
  ///
  /// In en, this message translates to:
  /// **'Finish the active timer before opening the guide.'**
  String get showcaseBlockedByTimer;

  /// No description provided for @showcasePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Start from your work plan'**
  String get showcasePlanTitle;

  /// No description provided for @showcaseWorkerPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Open a scheduled Shift from Home, Work, or Calendar.'**
  String get showcaseWorkerPlanBody;

  /// No description provided for @showcaseTradesmanPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Open a customer Job from Home, Work, or Calendar.'**
  String get showcaseTradesmanPlanBody;

  /// No description provided for @showcaseBothPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Worker Shifts and customer Jobs stay separate, but use the same simple timer.'**
  String get showcaseBothPlanBody;

  /// No description provided for @showcaseClockInTitle.
  ///
  /// In en, this message translates to:
  /// **'Clock In when work begins'**
  String get showcaseClockInTitle;

  /// No description provided for @showcaseClockInBody.
  ///
  /// In en, this message translates to:
  /// **'Only one Job or Shift can run at once. The timer survives an app restart.'**
  String get showcaseClockInBody;

  /// No description provided for @showcaseBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the right break'**
  String get showcaseBreakTitle;

  /// No description provided for @showcaseBreakBody.
  ///
  /// In en, this message translates to:
  /// **'Paid breaks remain billable. Unpaid breaks are removed automatically.'**
  String get showcaseBreakBody;

  /// No description provided for @showcaseClockOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Clock Out when finished'**
  String get showcaseClockOutTitle;

  /// No description provided for @showcaseClockOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will see planned versus actual time and a clear pay breakdown.'**
  String get showcaseClockOutBody;

  /// No description provided for @showcaseProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep a trustworthy record'**
  String get showcaseProofTitle;

  /// No description provided for @showcaseProofBody.
  ///
  /// In en, this message translates to:
  /// **'Corrections require a reason. Final time and pay calculations are saved for Proof.'**
  String get showcaseProofBody;

  /// No description provided for @skipShowcase.
  ///
  /// In en, this message translates to:
  /// **'Skip guide'**
  String get skipShowcase;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextLabel;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @workProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Work profile'**
  String get workProfileTitle;

  /// No description provided for @localProfile.
  ///
  /// In en, this message translates to:
  /// **'Local profile'**
  String get localProfile;

  /// No description provided for @countryCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Country and currency'**
  String get countryCurrencyTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @offlineNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline notifications & job alerts'**
  String get offlineNotificationsTitle;

  /// No description provided for @offlineNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Timing, privacy, quiet hours and schedule repair'**
  String get offlineNotificationsDescription;

  /// No description provided for @dataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataTitle;

  /// No description provided for @localDataDescription.
  ///
  /// In en, this message translates to:
  /// **'No account or internet is required.'**
  String get localDataDescription;

  /// No description provided for @payProtectionGuide.
  ///
  /// In en, this message translates to:
  /// **'Pay Protection guide'**
  String get payProtectionGuide;

  /// No description provided for @payProtectionGuideDescription.
  ///
  /// In en, this message translates to:
  /// **'See expected pay, payslip, evidence and export'**
  String get payProtectionGuideDescription;

  /// No description provided for @regionLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Region & language'**
  String get regionLanguageTitle;

  /// No description provided for @localWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your local workspace'**
  String get localWorkspaceTitle;

  /// No description provided for @localWorkspaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Language and money display update without an account or internet.'**
  String get localWorkspaceDescription;

  /// No description provided for @appLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguageLabel;

  /// No description provided for @countryMarketLabel.
  ///
  /// In en, this message translates to:
  /// **'Country / market'**
  String get countryMarketLabel;

  /// No description provided for @defaultCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Default workspace currency'**
  String get defaultCurrencyLabel;

  /// No description provided for @currencyHistoryNote.
  ///
  /// In en, this message translates to:
  /// **'Changing the default does not convert old records. Each customer can keep a separate billing currency.'**
  String get currencyHistoryNote;

  /// No description provided for @savePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save preferences'**
  String get savePreferences;

  /// No description provided for @preferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved.'**
  String get preferencesSaved;

  /// No description provided for @preferencesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Preferences could not be saved.'**
  String get preferencesSaveFailed;

  /// No description provided for @m05PayProtection.
  ///
  /// In en, this message translates to:
  /// **'Pay Protection'**
  String get m05PayProtection;

  /// No description provided for @m05WorkerPay.
  ///
  /// In en, this message translates to:
  /// **'Worker pay'**
  String get m05WorkerPay;

  /// No description provided for @m05BusinessMoney.
  ///
  /// In en, this message translates to:
  /// **'Business money'**
  String get m05BusinessMoney;

  /// No description provided for @m05PayAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'Pay at a glance'**
  String get m05PayAtAGlance;

  /// No description provided for @m05StartAPayPeriod.
  ///
  /// In en, this message translates to:
  /// **'Start a pay period'**
  String get m05StartAPayPeriod;

  /// No description provided for @m05PayPeriods.
  ///
  /// In en, this message translates to:
  /// **'Pay periods'**
  String get m05PayPeriods;

  /// No description provided for @m05OnDevice.
  ///
  /// In en, this message translates to:
  /// **'On device'**
  String get m05OnDevice;

  /// No description provided for @m05ShowGuide.
  ///
  /// In en, this message translates to:
  /// **'Show guide'**
  String get m05ShowGuide;

  /// No description provided for @m05AllEmployers.
  ///
  /// In en, this message translates to:
  /// **'All employers'**
  String get m05AllEmployers;

  /// No description provided for @m05Expected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get m05Expected;

  /// No description provided for @m05Received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get m05Received;

  /// No description provided for @m05Reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get m05Reviewed;

  /// No description provided for @m05Exported.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get m05Exported;

  /// No description provided for @m05NoPayPeriodYet.
  ///
  /// In en, this message translates to:
  /// **'No pay period yet'**
  String get m05NoPayPeriodYet;

  /// No description provided for @m05CreateNow.
  ///
  /// In en, this message translates to:
  /// **'Create now'**
  String get m05CreateNow;

  /// No description provided for @m05PayReview.
  ///
  /// In en, this message translates to:
  /// **'Pay review'**
  String get m05PayReview;

  /// No description provided for @m05SavedCalculation.
  ///
  /// In en, this message translates to:
  /// **'Saved calculation'**
  String get m05SavedCalculation;

  /// No description provided for @m05ExpectedGross.
  ///
  /// In en, this message translates to:
  /// **'Expected gross'**
  String get m05ExpectedGross;

  /// No description provided for @m05ReceivedGross.
  ///
  /// In en, this message translates to:
  /// **'Received gross'**
  String get m05ReceivedGross;

  /// No description provided for @m05AddPayslip.
  ///
  /// In en, this message translates to:
  /// **'Add payslip'**
  String get m05AddPayslip;

  /// No description provided for @m05EditPayslip.
  ///
  /// In en, this message translates to:
  /// **'Edit payslip'**
  String get m05EditPayslip;

  /// No description provided for @m05AddEvidence.
  ///
  /// In en, this message translates to:
  /// **'Add evidence'**
  String get m05AddEvidence;

  /// No description provided for @m05RecordedHours.
  ///
  /// In en, this message translates to:
  /// **'Recorded hours'**
  String get m05RecordedHours;

  /// No description provided for @m05Overtime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get m05Overtime;

  /// No description provided for @m05Premiums.
  ///
  /// In en, this message translates to:
  /// **'Premiums'**
  String get m05Premiums;

  /// No description provided for @m05Deductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get m05Deductions;

  /// No description provided for @m05NetPayment.
  ///
  /// In en, this message translates to:
  /// **'Net payment'**
  String get m05NetPayment;

  /// No description provided for @m05MetadataStripped.
  ///
  /// In en, this message translates to:
  /// **'metadata stripped'**
  String get m05MetadataStripped;

  /// No description provided for @m05ReviewMetadata.
  ///
  /// In en, this message translates to:
  /// **'review metadata'**
  String get m05ReviewMetadata;

  /// No description provided for @m05NoEvidenceAttachedYet.
  ///
  /// In en, this message translates to:
  /// **'No evidence attached yet.'**
  String get m05NoEvidenceAttachedYet;

  /// No description provided for @m05Retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get m05Retry;

  /// No description provided for @m05Employer.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get m05Employer;

  /// No description provided for @m05NewPayPeriod.
  ///
  /// In en, this message translates to:
  /// **'New pay period'**
  String get m05NewPayPeriod;

  /// No description provided for @m05EmployerScope.
  ///
  /// In en, this message translates to:
  /// **'Employer scope'**
  String get m05EmployerScope;

  /// No description provided for @m05PayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Pay currency'**
  String get m05PayCurrency;

  /// No description provided for @m05From.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get m05From;

  /// No description provided for @m05To.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get m05To;

  /// No description provided for @m05CalculateAndSave.
  ///
  /// In en, this message translates to:
  /// **'Calculate and save'**
  String get m05CalculateAndSave;

  /// No description provided for @m05Weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get m05Weekly;

  /// No description provided for @m05Fortnightly.
  ///
  /// In en, this message translates to:
  /// **'Fortnightly'**
  String get m05Fortnightly;

  /// No description provided for @m05FourWeekly.
  ///
  /// In en, this message translates to:
  /// **'Four-weekly'**
  String get m05FourWeekly;

  /// No description provided for @m05Monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get m05Monthly;

  /// No description provided for @m05CustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get m05CustomRange;

  /// No description provided for @m05RecordPayslip.
  ///
  /// In en, this message translates to:
  /// **'Record payslip'**
  String get m05RecordPayslip;

  /// No description provided for @m05PayPeriodNotFound.
  ///
  /// In en, this message translates to:
  /// **'Pay period not found.'**
  String get m05PayPeriodNotFound;

  /// No description provided for @m05PayDate.
  ///
  /// In en, this message translates to:
  /// **'Pay date'**
  String get m05PayDate;

  /// No description provided for @m05NotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get m05NotSet;

  /// No description provided for @m05ChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get m05ChooseFile;

  /// No description provided for @m05ReplaceFile.
  ///
  /// In en, this message translates to:
  /// **'Replace file'**
  String get m05ReplaceFile;

  /// No description provided for @m05SaveAndCompare.
  ///
  /// In en, this message translates to:
  /// **'Save and compare'**
  String get m05SaveAndCompare;

  /// No description provided for @m05WriteANoteFirst.
  ///
  /// In en, this message translates to:
  /// **'Write a note first.'**
  String get m05WriteANoteFirst;

  /// No description provided for @m05ChooseAFileFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a file first.'**
  String get m05ChooseAFileFirst;

  /// No description provided for @m05EvidenceType.
  ///
  /// In en, this message translates to:
  /// **'Evidence type'**
  String get m05EvidenceType;

  /// No description provided for @m05WrittenNote.
  ///
  /// In en, this message translates to:
  /// **'Written note'**
  String get m05WrittenNote;

  /// No description provided for @m05Photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get m05Photo;

  /// No description provided for @m05Payslip.
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get m05Payslip;

  /// No description provided for @m05WhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get m05WhatHappened;

  /// No description provided for @m05DescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get m05DescriptionOptional;

  /// No description provided for @m05NoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get m05NoFileSelected;

  /// No description provided for @m05ChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another'**
  String get m05ChooseAnother;

  /// No description provided for @m05SaveEvidence.
  ///
  /// In en, this message translates to:
  /// **'Save evidence'**
  String get m05SaveEvidence;

  /// No description provided for @m05ExpectedAndReceivedPayStaySeparateA.
  ///
  /// In en, this message translates to:
  /// **'Expected and received pay stay separate. A difference is a review prompt, not a legal conclusion.'**
  String get m05ExpectedAndReceivedPayStaySeparateA;

  /// No description provided for @m05ChooseEmployerScheduleAndCurrencyInsideThis.
  ///
  /// In en, this message translates to:
  /// **'Choose employer, schedule and currency inside this screen. No popup dropdown is used.'**
  String get m05ChooseEmployerScheduleAndCurrencyInsideThis;

  /// No description provided for @m05CreatePayProtectionPeriod.
  ///
  /// In en, this message translates to:
  /// **'Create pay protection period'**
  String get m05CreatePayProtectionPeriod;

  /// No description provided for @m05ReviewEvidenceExport.
  ///
  /// In en, this message translates to:
  /// **'Review, evidence, export'**
  String get m05ReviewEvidenceExport;

  /// No description provided for @m05OpenAPeriodToAddAPayslip.
  ///
  /// In en, this message translates to:
  /// **'Open a period to add a payslip, attach evidence and create an offline PDF + ZIP pack.'**
  String get m05OpenAPeriodToAddAPayslip;

  /// No description provided for @m05PossibleDifferenceToReview.
  ///
  /// In en, this message translates to:
  /// **'Possible difference to review'**
  String get m05PossibleDifferenceToReview;

  /// No description provided for @m05CreateOneAfterRecordingShiftsExpectedPay.
  ///
  /// In en, this message translates to:
  /// **'Create one after recording shifts. Expected pay is calculated from saved time snapshots.'**
  String get m05CreateOneAfterRecordingShiftsExpectedPay;

  /// No description provided for @m05PayslipSavedPayComparisonUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payslip saved. Pay comparison updated.'**
  String get m05PayslipSavedPayComparisonUpdated;

  /// No description provided for @m05EvidenceSavedWithAnIntegrityChecksum.
  ///
  /// In en, this message translates to:
  /// **'Evidence saved with an integrity checksum.'**
  String get m05EvidenceSavedWithAnIntegrityChecksum;

  /// No description provided for @m05PDFZIPPackCreatedOfflineSHA256.
  ///
  /// In en, this message translates to:
  /// **'PDF + ZIP pack created offline. SHA-256 manifest included.'**
  String get m05PDFZIPPackCreatedOfflineSHA256;

  /// No description provided for @m05ExportCouldNotBeCreated.
  ///
  /// In en, this message translates to:
  /// **'Export could not be created.'**
  String get m05ExportCouldNotBeCreated;

  /// No description provided for @m05EvidenceTimeline.
  ///
  /// In en, this message translates to:
  /// **'Evidence timeline'**
  String get m05EvidenceTimeline;

  /// No description provided for @m05ExportsUseSelectedEvidenceAndPrivacyShare.
  ///
  /// In en, this message translates to:
  /// **'Exports use selected evidence and privacy share-copies. Original files stay private on this device. Review documents before sharing.'**
  String get m05ExportsUseSelectedEvidenceAndPrivacyShare;

  /// No description provided for @m05CreatePDFZIPEvidencePack.
  ///
  /// In en, this message translates to:
  /// **'Create PDF + ZIP evidence pack'**
  String get m05CreatePDFZIPEvidencePack;

  /// No description provided for @m05ThisIsAUserCreatedRecordNot.
  ///
  /// In en, this message translates to:
  /// **'This is a user-created record, not legal advice or a finding of underpayment.'**
  String get m05ThisIsAUserCreatedRecordNot;

  /// No description provided for @m05AddAPayslipToComparePayment.
  ///
  /// In en, this message translates to:
  /// **'Add a payslip to compare payment.'**
  String get m05AddAPayslipToComparePayment;

  /// No description provided for @m05ExpectedAndReceivedGrossMatch.
  ///
  /// In en, this message translates to:
  /// **'Expected and received gross match.'**
  String get m05ExpectedAndReceivedGrossMatch;

  /// No description provided for @m05AllowancesAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Allowances & adjustments'**
  String get m05AllowancesAdjustments;

  /// No description provided for @m05NoCompletedShiftsWereFoundInThis.
  ///
  /// In en, this message translates to:
  /// **'No completed shifts were found in this range.'**
  String get m05NoCompletedShiftsWereFoundInThis;

  /// No description provided for @m05EnterALabelAndValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a label and valid amount.'**
  String get m05EnterALabelAndValidAmount;

  /// No description provided for @m05AddExpectedPayAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Add expected-pay adjustment'**
  String get m05AddExpectedPayAdjustment;

  /// No description provided for @m05AdjustmentType.
  ///
  /// In en, this message translates to:
  /// **'Adjustment type'**
  String get m05AdjustmentType;

  /// No description provided for @m05Allowance.
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get m05Allowance;

  /// No description provided for @m05OvertimeCorrection.
  ///
  /// In en, this message translates to:
  /// **'Overtime correction'**
  String get m05OvertimeCorrection;

  /// No description provided for @m05ManualCorrection.
  ///
  /// In en, this message translates to:
  /// **'Manual correction'**
  String get m05ManualCorrection;

  /// No description provided for @m05ReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason / label'**
  String get m05ReasonLabel;

  /// No description provided for @m05UseAMinusSignOnlyForA.
  ///
  /// In en, this message translates to:
  /// **'Use a minus sign only for a correction that reduces expected gross.'**
  String get m05UseAMinusSignOnlyForA;

  /// No description provided for @m05SaveAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Save adjustment'**
  String get m05SaveAdjustment;

  /// No description provided for @m05CouldNotLoadPayPeriod.
  ///
  /// In en, this message translates to:
  /// **'Could not load pay period.'**
  String get m05CouldNotLoadPayPeriod;

  /// No description provided for @m05EndDateMustBeAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start.'**
  String get m05EndDateMustBeAfterStart;

  /// No description provided for @m05PayPeriodCreatedAndExpectedPayCalculated.
  ///
  /// In en, this message translates to:
  /// **'Pay period created and expected pay calculated.'**
  String get m05PayPeriodCreatedAndExpectedPayCalculated;

  /// No description provided for @m05CouldNotCreatePayPeriod.
  ///
  /// In en, this message translates to:
  /// **'Could not create pay period.'**
  String get m05CouldNotCreatePayPeriod;

  /// No description provided for @m05CompletedWorkerShiftsInThisDateRange.
  ///
  /// In en, this message translates to:
  /// **'Completed worker shifts in this date range are used to create a saved expected-pay snapshot.'**
  String get m05CompletedWorkerShiftsInThisDateRange;

  /// No description provided for @m05PrivateNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Private note (optional)'**
  String get m05PrivateNoteOptional;

  /// No description provided for @m05FileCouldNotBePrepared.
  ///
  /// In en, this message translates to:
  /// **'File could not be prepared.'**
  String get m05FileCouldNotBePrepared;

  /// No description provided for @m05EnterValidGrossDeductionsAndNetAmounts.
  ///
  /// In en, this message translates to:
  /// **'Enter valid gross, deductions and net amounts.'**
  String get m05EnterValidGrossDeductionsAndNetAmounts;

  /// No description provided for @m05PayslipCouldNotBeSaved.
  ///
  /// In en, this message translates to:
  /// **'Payslip could not be saved.'**
  String get m05PayslipCouldNotBeSaved;

  /// No description provided for @m05EnterValuesExactlyAsShownOCRIs.
  ///
  /// In en, this message translates to:
  /// **'Enter values exactly as shown. OCR is not used, so nothing is silently accepted.'**
  String get m05EnterValuesExactlyAsShownOCRIs;

  /// No description provided for @m05PayslipReferenceOptional.
  ///
  /// In en, this message translates to:
  /// **'Payslip reference (optional)'**
  String get m05PayslipReferenceOptional;

  /// No description provided for @m05PayslipPhotoOrPDF.
  ///
  /// In en, this message translates to:
  /// **'Payslip photo or PDF'**
  String get m05PayslipPhotoOrPDF;

  /// No description provided for @m05EvidenceCouldNotBeSaved.
  ///
  /// In en, this message translates to:
  /// **'Evidence could not be saved.'**
  String get m05EvidenceCouldNotBeSaved;

  /// No description provided for @m05DocumentPDF.
  ///
  /// In en, this message translates to:
  /// **'Document / PDF'**
  String get m05DocumentPDF;

  /// No description provided for @m05TypedAcknowledgement.
  ///
  /// In en, this message translates to:
  /// **'Typed acknowledgement'**
  String get m05TypedAcknowledgement;

  /// No description provided for @m05SignerNameAndAcknowledgement.
  ///
  /// In en, this message translates to:
  /// **'Signer name and acknowledgement'**
  String get m05SignerNameAndAcknowledgement;

  /// No description provided for @m05CompressedShareCopyCreatedImageMetadataStripped.
  ///
  /// In en, this message translates to:
  /// **'Compressed share-copy created; image metadata stripped.'**
  String get m05CompressedShareCopyCreatedImageMetadataStripped;

  /// No description provided for @m05AShareCopyIsCreatedDocumentMetadata.
  ///
  /// In en, this message translates to:
  /// **'A share-copy is created. Document metadata may remain—review before sharing.'**
  String get m05AShareCopyIsCreatedDocumentMetadata;

  /// No description provided for @m05ChooseFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Choose from device'**
  String get m05ChooseFromDevice;

  /// No description provided for @m05ThisRecordsTypedAcknowledgementAndTimeOnly.
  ///
  /// In en, this message translates to:
  /// **'This records typed acknowledgement and time only; it is not a verified digital signature.'**
  String get m05ThisRecordsTypedAcknowledgementAndTimeOnly;

  /// No description provided for @m05OriginalEvidenceStaysPrivateOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Original evidence stays private on this device. Only selected evidence is added to an export.'**
  String get m05OriginalEvidenceStaysPrivateOnThisDevice;

  /// No description provided for @m05OpenPeriodsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No open periods} =1{1 open period} other{{count} open periods}}'**
  String m05OpenPeriodsCount(int count);

  /// No description provided for @m05PossibleDifferenceReview.
  ///
  /// In en, this message translates to:
  /// **'Possible {amount} difference — review the payslip and saved records.'**
  String m05PossibleDifferenceReview(String amount);

  /// No description provided for @m05ReceivedAboveExpectedReview.
  ///
  /// In en, this message translates to:
  /// **'Received {amount} above expected — review the saved records.'**
  String m05ReceivedAboveExpectedReview(String amount);

  /// No description provided for @m05MissingRateReview.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All rates are ready.} =1{1 entry needs a rate review.} other{{count} entries need a rate review.}}'**
  String m05MissingRateReview(int count);

  /// No description provided for @m05AmountWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'Amount ({currency})'**
  String m05AmountWithCurrency(String currency);

  /// No description provided for @m04NotificationsJobAlerts.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Job Alerts'**
  String get m04NotificationsJobAlerts;

  /// No description provided for @m04WorkAlerts.
  ///
  /// In en, this message translates to:
  /// **'Work alerts'**
  String get m04WorkAlerts;

  /// No description provided for @m04PrivateLockScreenText.
  ///
  /// In en, this message translates to:
  /// **'Private lock-screen text'**
  String get m04PrivateLockScreenText;

  /// No description provided for @m04HidesJobCustomerAndWorkplaceNames.
  ///
  /// In en, this message translates to:
  /// **'Hides Job, customer and workplace names'**
  String get m04HidesJobCustomerAndWorkplaceNames;

  /// No description provided for @m04OptionalMotivation.
  ///
  /// In en, this message translates to:
  /// **'Optional motivation'**
  String get m04OptionalMotivation;

  /// No description provided for @m04CalmDailyMessage.
  ///
  /// In en, this message translates to:
  /// **'Calm daily message'**
  String get m04CalmDailyMessage;

  /// No description provided for @m04OffByDefaultAndSuppressedNearImportant.
  ///
  /// In en, this message translates to:
  /// **'Off by default and suppressed near important alerts'**
  String get m04OffByDefaultAndSuppressedNearImportant;

  /// No description provided for @m04DeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Delivery time'**
  String get m04DeliveryTime;

  /// No description provided for @m04CustomMessageOptional.
  ///
  /// In en, this message translates to:
  /// **'Custom message (optional)'**
  String get m04CustomMessageOptional;

  /// No description provided for @m04QuietHours22000700.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours: 22:00–07:00'**
  String get m04QuietHours22000700;

  /// No description provided for @m04PreviewAndMotivationWaitTimeSensitiveWork.
  ///
  /// In en, this message translates to:
  /// **'Preview and motivation wait; time-sensitive work alerts stay on time.'**
  String get m04PreviewAndMotivationWaitTimeSensitiveWork;

  /// No description provided for @m04OfflineDelivery.
  ///
  /// In en, this message translates to:
  /// **'Offline delivery'**
  String get m04OfflineDelivery;

  /// No description provided for @m04NoInternetIsNeededOSBatteryRules.
  ///
  /// In en, this message translates to:
  /// **'No internet is needed. OS battery rules may shift an inexact reminder; Repair schedule reconciles it again.'**
  String get m04NoInternetIsNeededOSBatteryRules;

  /// No description provided for @m04OnlyWhileWorkIsActive.
  ///
  /// In en, this message translates to:
  /// **'Only while work is active'**
  String get m04OnlyWhileWorkIsActive;

  /// No description provided for @m04DigestTime.
  ///
  /// In en, this message translates to:
  /// **'Digest time'**
  String get m04DigestTime;

  /// No description provided for @m04HowEarly.
  ///
  /// In en, this message translates to:
  /// **'How early'**
  String get m04HowEarly;

  /// No description provided for @m04NotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get m04NotificationsEnabled;

  /// No description provided for @m04NotificationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Notification permission needed'**
  String get m04NotificationPermissionNeeded;

  /// No description provided for @m04Enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get m04Enable;

  /// No description provided for @m04RepairSchedule.
  ///
  /// In en, this message translates to:
  /// **'Repair schedule'**
  String get m04RepairSchedule;

  /// No description provided for @m04SystemSettings.
  ///
  /// In en, this message translates to:
  /// **'System settings'**
  String get m04SystemSettings;

  /// No description provided for @m04PreviousDayPreview.
  ///
  /// In en, this message translates to:
  /// **'Previous-day preview'**
  String get m04PreviousDayPreview;

  /// No description provided for @m04700MorningDigest.
  ///
  /// In en, this message translates to:
  /// **'7:00 morning digest'**
  String get m04700MorningDigest;

  /// No description provided for @m04PreparationAlert.
  ///
  /// In en, this message translates to:
  /// **'Preparation alert'**
  String get m04PreparationAlert;

  /// No description provided for @m04StartsSoon.
  ///
  /// In en, this message translates to:
  /// **'Starts soon'**
  String get m04StartsSoon;

  /// No description provided for @m04ActiveWorkBreak.
  ///
  /// In en, this message translates to:
  /// **'Active-work break'**
  String get m04ActiveWorkBreak;

  /// No description provided for @m04ScheduledFinish.
  ///
  /// In en, this message translates to:
  /// **'Scheduled finish'**
  String get m04ScheduledFinish;

  /// No description provided for @m04Motivation.
  ///
  /// In en, this message translates to:
  /// **'Motivation'**
  String get m04Motivation;

  /// No description provided for @m04RemindYouAboutWork.
  ///
  /// In en, this message translates to:
  /// **'Remind you about work?'**
  String get m04RemindYouAboutWork;

  /// No description provided for @m04WorkProofCanScheduleJobAndShiftAlerts.
  ///
  /// In en, this message translates to:
  /// **'WorkProof can schedule Job and Shift alerts on this device without internet.'**
  String get m04WorkProofCanScheduleJobAndShiftAlerts;

  /// No description provided for @m04WorkAndCustomerNamesStayPrivateOn.
  ///
  /// In en, this message translates to:
  /// **'Work and customer names stay private on the lock screen.'**
  String get m04WorkAndCustomerNamesStayPrivateOn;

  /// No description provided for @m04NotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get m04NotNow;

  /// No description provided for @m04ReminderDetails.
  ///
  /// In en, this message translates to:
  /// **'Reminder details'**
  String get m04ReminderDetails;

  /// No description provided for @m04DefaultsAreReadyChangeOnlyIfNeeded.
  ///
  /// In en, this message translates to:
  /// **'Defaults are ready—change only if needed'**
  String get m04DefaultsAreReadyChangeOnlyIfNeeded;

  /// No description provided for @m04UseAppDefaults.
  ///
  /// In en, this message translates to:
  /// **'Use app defaults'**
  String get m04UseAppDefaults;

  /// No description provided for @m04TimingChangesInSettingsWillApplyTo.
  ///
  /// In en, this message translates to:
  /// **'Timing changes in Settings will apply to this work'**
  String get m04TimingChangesInSettingsWillApplyTo;

  /// No description provided for @m04StartsSoonAlert.
  ///
  /// In en, this message translates to:
  /// **'Starts-soon alert'**
  String get m04StartsSoonAlert;

  /// No description provided for @m04EndAlertForActiveWork.
  ///
  /// In en, this message translates to:
  /// **'End alert for active work'**
  String get m04EndAlertForActiveWork;

  /// No description provided for @m04OnlyShownAfterClockIn.
  ///
  /// In en, this message translates to:
  /// **'Only shown after Clock In'**
  String get m04OnlyShownAfterClockIn;

  /// No description provided for @m04WorkStartsSoon.
  ///
  /// In en, this message translates to:
  /// **'Work starts soon'**
  String get m04WorkStartsSoon;

  /// No description provided for @m04MinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute before} other{{count} minutes before}}'**
  String m04MinutesBefore(int count);

  /// No description provided for @m04HoursBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour before} other{{count} hours before}}'**
  String m04HoursBefore(int count);

  /// No description provided for @m04ReminderStatus.
  ///
  /// In en, this message translates to:
  /// **'{pending} reminders prepared · {attention} need attention'**
  String m04ReminderStatus(int pending, int attention);

  /// No description provided for @m04NotificationsEnabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled and schedule repaired.'**
  String get m04NotificationsEnabledMessage;

  /// No description provided for @m04NotificationsDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was not granted. Work is still saved.'**
  String get m04NotificationsDeniedMessage;

  /// No description provided for @m04ScheduleRepairedMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification schedule repaired.'**
  String get m04ScheduleRepairedMessage;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted.'**
  String get recordDeleted;

  /// No description provided for @payEvidencePacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay evidence packs'**
  String get payEvidencePacksTitle;

  /// No description provided for @payEvidencePacksDescription.
  ///
  /// In en, this message translates to:
  /// **'Open payslips, evidence and PDF + ZIP exports from Money'**
  String get payEvidencePacksDescription;

  /// No description provided for @auditPreferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Workspace preferences updated'**
  String get auditPreferencesUpdated;

  /// No description provided for @auditPayPeriodCreated.
  ///
  /// In en, this message translates to:
  /// **'Pay period snapshot created'**
  String get auditPayPeriodCreated;

  /// No description provided for @auditPayslipRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payslip recorded for comparison'**
  String get auditPayslipRecorded;

  /// No description provided for @auditPayAdjustmentAdded.
  ///
  /// In en, this message translates to:
  /// **'Expected-pay adjustment added'**
  String get auditPayAdjustmentAdded;

  /// No description provided for @auditEvidenceAdded.
  ///
  /// In en, this message translates to:
  /// **'Evidence added with integrity record'**
  String get auditEvidenceAdded;

  /// No description provided for @auditWorkProofExported.
  ///
  /// In en, this message translates to:
  /// **'WorkProof PDF + ZIP pack exported'**
  String get auditWorkProofExported;

  /// No description provided for @customerBillingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Customer billing currency'**
  String get customerBillingCurrency;

  /// No description provided for @generalWork.
  ///
  /// In en, this message translates to:
  /// **'General work'**
  String get generalWork;

  /// No description provided for @adjustmentSaved.
  ///
  /// In en, this message translates to:
  /// **'Adjustment saved and expected pay updated.'**
  String get adjustmentSaved;

  /// No description provided for @evidenceFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is too large. Choose a file up to 25 MB.'**
  String get evidenceFileTooLarge;

  /// No description provided for @notificationMorningDigestTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 work item today} other{{count} work items today}}'**
  String notificationMorningDigestTitle(int count);

  /// No description provided for @notificationMorningDigestBody.
  ///
  /// In en, this message translates to:
  /// **'Open Calendar to review your day.'**
  String get notificationMorningDigestBody;

  /// No description provided for @notificationMotivationBody.
  ///
  /// In en, this message translates to:
  /// **'Start today with one small, clear work plan.'**
  String get notificationMotivationBody;

  /// No description provided for @notificationUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming work{subject}'**
  String notificationUpcomingTitle(String subject);

  /// No description provided for @notificationUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'Review the schedule and prepare.'**
  String get notificationUpcomingBody;

  /// No description provided for @notificationPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare for work{subject}'**
  String notificationPrepareTitle(String subject);

  /// No description provided for @notificationPrepareBody.
  ///
  /// In en, this message translates to:
  /// **'Check the time and what you need.'**
  String get notificationPrepareBody;

  /// No description provided for @notificationStartsSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Work starts soon{subject}'**
  String notificationStartsSoonTitle(String subject);

  /// No description provided for @notificationStartsSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Scheduled time: {time}.'**
  String notificationStartsSoonBody(String time);

  /// No description provided for @notificationBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Break reminder'**
  String get notificationBreakTitle;

  /// No description provided for @notificationBreakBody.
  ///
  /// In en, this message translates to:
  /// **'Take a safe break when practical.'**
  String get notificationBreakBody;

  /// No description provided for @notificationFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled finish'**
  String get notificationFinishTitle;

  /// No description provided for @notificationFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Clock out when your work is complete.'**
  String get notificationFinishBody;

  /// No description provided for @notificationReviewPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Review your work plan.'**
  String get notificationReviewPlanBody;

  /// No description provided for @securityPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Security & privacy'**
  String get securityPrivacyTitle;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLockTitle;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect WorkProof with a PIN and device biometrics.'**
  String get appLockSubtitle;

  /// No description provided for @enableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Enable app lock'**
  String get enableAppLock;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get useBiometrics;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics available on this device.'**
  String get biometricLockSubtitle;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are unavailable on this device.'**
  String get biometricUnavailable;

  /// No description provided for @lockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get lockNow;

  /// No description provided for @evidenceEncryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted evidence'**
  String get evidenceEncryptionTitle;

  /// No description provided for @evidenceEncryptionDescription.
  ///
  /// In en, this message translates to:
  /// **'New evidence files are protected with authenticated AES-256 encryption on this device.'**
  String get evidenceEncryptionDescription;

  /// No description provided for @securitySaved.
  ///
  /// In en, this message translates to:
  /// **'Security settings saved.'**
  String get securitySaved;

  /// No description provided for @securitySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Security settings could not be saved.'**
  String get securitySaveFailed;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'That PIN is not correct.'**
  String get wrongPin;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN'**
  String get createPin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @pinDigitsHint.
  ///
  /// In en, this message translates to:
  /// **'Use 4 to 8 digits.'**
  String get pinDigitsHint;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs do not match.'**
  String get pinMismatch;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait 30 seconds and try again.'**
  String get tooManyAttempts;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric verification was not completed.'**
  String get biometricFailed;

  /// No description provided for @unlockWorkProof.
  ///
  /// In en, this message translates to:
  /// **'Unlock WorkProof'**
  String get unlockWorkProof;

  /// No description provided for @enterPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue.'**
  String get enterPinToContinue;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @biometricUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your WorkProof workspace'**
  String get biometricUnlockReason;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get unlockWithBiometrics;

  /// No description provided for @biometricSetupReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm biometrics for WorkProof app lock'**
  String get biometricSetupReason;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted backup or safely restore your workspace.'**
  String get backupRestoreSubtitle;

  /// No description provided for @backupSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted, verified and offline'**
  String get backupSafetyTitle;

  /// No description provided for @backupSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'Backups include your local records and evidence. WorkProof verifies every file before restore and never uploads it automatically.'**
  String get backupSafetyDescription;

  /// No description provided for @createBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackupTitle;

  /// No description provided for @createBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a password-encrypted .workproof file containing a consistent database snapshot and your evidence.'**
  String get createBackupDescription;

  /// No description provided for @lastBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String lastBackupLabel(String date);

  /// No description provided for @creatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Creating encrypted backup…'**
  String get creatingBackup;

  /// No description provided for @createEncryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backup'**
  String get createEncryptedBackup;

  /// No description provided for @shareBackup.
  ///
  /// In en, this message translates to:
  /// **'Share or save backup'**
  String get shareBackup;

  /// No description provided for @shareBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'The backup could not be shared.'**
  String get shareBackupFailed;

  /// No description provided for @backupCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup created and verified.'**
  String get backupCreatedSuccess;

  /// No description provided for @backupCreatedSummary.
  ///
  /// In en, this message translates to:
  /// **'{records} records · {evidence} evidence files · {size}'**
  String backupCreatedSummary(int records, int evidence, String size);

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a .workproof file and enter its password. Nothing is changed until verification finishes and you confirm a restore mode.'**
  String get restoreBackupDescription;

  /// No description provided for @chooseBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get chooseBackupFile;

  /// No description provided for @verifyingBackup.
  ///
  /// In en, this message translates to:
  /// **'Verifying every file…'**
  String get verifyingBackup;

  /// No description provided for @verifiedBackupPreview.
  ///
  /// In en, this message translates to:
  /// **'Verified backup preview'**
  String get verifiedBackupPreview;

  /// No description provided for @backupRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'Records: {count}'**
  String backupRecordsCount(int count);

  /// No description provided for @backupEvidenceCount.
  ///
  /// In en, this message translates to:
  /// **'Evidence files: {count}'**
  String backupEvidenceCount(int count);

  /// No description provided for @backupSchemaVersion.
  ///
  /// In en, this message translates to:
  /// **'Backup data version: {version}'**
  String backupSchemaVersion(int version);

  /// No description provided for @chooseRestoreMode.
  ///
  /// In en, this message translates to:
  /// **'Choose how to restore'**
  String get chooseRestoreMode;

  /// No description provided for @mergeRestore.
  ///
  /// In en, this message translates to:
  /// **'Merge with this device'**
  String get mergeRestore;

  /// No description provided for @mergeRestoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Keeps existing data and adds records that are not already on this device.'**
  String get mergeRestoreDescription;

  /// No description provided for @replaceRestore.
  ///
  /// In en, this message translates to:
  /// **'Replace this workspace'**
  String get replaceRestore;

  /// No description provided for @replaceRestoreWarning.
  ///
  /// In en, this message translates to:
  /// **'This replaces the current local workspace with the verified backup. WorkProof creates a recovery snapshot first and rolls back if any check fails.'**
  String get replaceRestoreWarning;

  /// No description provided for @restoreRollbackNote.
  ///
  /// In en, this message translates to:
  /// **'A protected pre-import snapshot is created before either restore mode.'**
  String get restoreRollbackNote;

  /// No description provided for @restoringBackup.
  ///
  /// In en, this message translates to:
  /// **'Restoring and checking your workspace…'**
  String get restoringBackup;

  /// No description provided for @createBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Protect this backup'**
  String get createBackupPassword;

  /// No description provided for @enterBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter backup password'**
  String get enterBackupPassword;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPassword;

  /// No description provided for @confirmBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm backup password'**
  String get confirmBackupPassword;

  /// No description provided for @backupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Use at least 10 characters.'**
  String get backupPasswordHint;

  /// No description provided for @backupPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'WorkProof cannot recover this password. Store it separately from the backup file.'**
  String get backupPasswordWarning;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @backupVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup password and file checks passed.'**
  String get backupVerifiedSuccess;

  /// No description provided for @confirmMergeRestore.
  ///
  /// In en, this message translates to:
  /// **'Merge this verified backup?'**
  String get confirmMergeRestore;

  /// No description provided for @confirmReplaceRestore.
  ///
  /// In en, this message translates to:
  /// **'Replace the local workspace?'**
  String get confirmReplaceRestore;

  /// No description provided for @restoreNow.
  ///
  /// In en, this message translates to:
  /// **'Restore now'**
  String get restoreNow;

  /// No description provided for @restoreBlockedByTimer.
  ///
  /// In en, this message translates to:
  /// **'Stop the active timer before backing up or restoring workspace data.'**
  String get restoreBlockedByTimer;

  /// No description provided for @restoreCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore completed and all integrity checks passed.'**
  String get restoreCompletedSuccess;

  /// No description provided for @wrongPasswordOrDamaged.
  ///
  /// In en, this message translates to:
  /// **'The password is wrong or the backup is damaged.'**
  String get wrongPasswordOrDamaged;

  /// No description provided for @unsupportedBackup.
  ///
  /// In en, this message translates to:
  /// **'This backup version is not supported by this app version.'**
  String get unsupportedBackup;

  /// No description provided for @backupIntegrityFailed.
  ///
  /// In en, this message translates to:
  /// **'A backup checksum failed. No data was changed.'**
  String get backupIntegrityFailed;

  /// No description provided for @restoreFailedRolledBack.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Your previous workspace was restored automatically.'**
  String get restoreFailedRolledBack;

  /// No description provided for @restoreValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'This backup could not be verified. No data was changed.'**
  String get restoreValidationFailed;

  /// No description provided for @backupOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'The backup operation could not be completed. Your local data is unchanged.'**
  String get backupOperationFailed;

  /// No description provided for @useLatestRecovery.
  ///
  /// In en, this message translates to:
  /// **'Use latest recovery snapshot'**
  String get useLatestRecovery;

  /// No description provided for @recoveryVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The latest protected recovery snapshot passed all checks.'**
  String get recoveryVerifiedSuccess;

  /// No description provided for @noRecoverySnapshot.
  ///
  /// In en, this message translates to:
  /// **'No recovery snapshot is available yet.'**
  String get noRecoverySnapshot;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & statements'**
  String get reportsTitle;

  /// No description provided for @reportsOfflineDescription.
  ///
  /// In en, this message translates to:
  /// **'Weekly, monthly and custom reports are calculated from your on-device records.'**
  String get reportsOfflineDescription;

  /// No description provided for @reportLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The offline report could not be calculated.'**
  String get reportLoadFailed;

  /// No description provided for @reportEndDateInclusive.
  ///
  /// In en, this message translates to:
  /// **'The displayed end date is included.'**
  String get reportEndDateInclusive;

  /// No description provided for @reportAllWork.
  ///
  /// In en, this message translates to:
  /// **'All work'**
  String get reportAllWork;

  /// No description provided for @reportEmployerStatement.
  ///
  /// In en, this message translates to:
  /// **'Employer statement'**
  String get reportEmployerStatement;

  /// No description provided for @reportCustomerStatement.
  ///
  /// In en, this message translates to:
  /// **'Customer statement'**
  String get reportCustomerStatement;

  /// No description provided for @reportPartyStatement.
  ///
  /// In en, this message translates to:
  /// **'Employer or customer statement'**
  String get reportPartyStatement;

  /// No description provided for @reportAllParties.
  ///
  /// In en, this message translates to:
  /// **'All employers and customers'**
  String get reportAllParties;

  /// No description provided for @reportWorkerSummary.
  ///
  /// In en, this message translates to:
  /// **'Worker pay summary'**
  String get reportWorkerSummary;

  /// No description provided for @reportIncomeSummary.
  ///
  /// In en, this message translates to:
  /// **'Business income summary'**
  String get reportIncomeSummary;

  /// No description provided for @reportStatementLines.
  ///
  /// In en, this message translates to:
  /// **'Statement lines'**
  String get reportStatementLines;

  /// No description provided for @reportNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No matching records were found in this date range.'**
  String get reportNoRecords;

  /// No description provided for @reportExportPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Exports are created offline and may contain private work and pay data. Share them only with someone you trust.'**
  String get reportExportPrivacyNote;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @reportCreatingExport.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get reportCreatingExport;

  /// No description provided for @reportExportFailed.
  ///
  /// In en, this message translates to:
  /// **'The report export could not be created.'**
  String get reportExportFailed;

  /// No description provided for @reportExportCreated.
  ///
  /// In en, this message translates to:
  /// **'Offline report created and checksum recorded.'**
  String get reportExportCreated;

  /// No description provided for @reportBillableHours.
  ///
  /// In en, this message translates to:
  /// **'Billable hours'**
  String get reportBillableHours;

  /// No description provided for @reportPossibleDifference.
  ///
  /// In en, this message translates to:
  /// **'Possible difference'**
  String get reportPossibleDifference;

  /// No description provided for @reportBillableWork.
  ///
  /// In en, this message translates to:
  /// **'Billable work'**
  String get reportBillableWork;

  /// No description provided for @reportInvoiced.
  ///
  /// In en, this message translates to:
  /// **'Invoiced'**
  String get reportInvoiced;

  /// No description provided for @reportPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get reportPaid;

  /// No description provided for @reportOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get reportOutstanding;

  /// No description provided for @reportExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportExpenses;

  /// No description provided for @reportNetCash.
  ///
  /// In en, this message translates to:
  /// **'Net cash'**
  String get reportNetCash;

  /// No description provided for @reportWorkerTime.
  ///
  /// In en, this message translates to:
  /// **'Worker time'**
  String get reportWorkerTime;

  /// No description provided for @reportBusinessTime.
  ///
  /// In en, this message translates to:
  /// **'Business time'**
  String get reportBusinessTime;

  /// No description provided for @reportInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get reportInvoice;

  /// No description provided for @reportPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get reportPayment;

  /// No description provided for @reportExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get reportExpense;

  /// No description provided for @auditReportExported.
  ///
  /// In en, this message translates to:
  /// **'Offline report exported'**
  String get auditReportExported;

  /// No description provided for @privacyChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices'**
  String get privacyChoicesTitle;

  /// No description provided for @privacyChoicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Review or change advertising consent choices.'**
  String get privacyChoicesAvailable;

  /// No description provided for @privacyChoicesDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage consent when privacy options are required in your region.'**
  String get privacyChoicesDescription;

  /// No description provided for @privacyChoicesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices were reviewed.'**
  String get privacyChoicesUpdated;

  /// No description provided for @privacyChoicesNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Additional privacy choices are not required for this region.'**
  String get privacyChoicesNotRequired;

  /// No description provided for @privacyChoicesFailed.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices could not be opened.'**
  String get privacyChoicesFailed;

  /// No description provided for @advertisementLabel.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisementLabel;

  /// No description provided for @reportMissingRateWarning.
  ///
  /// In en, this message translates to:
  /// **'Some completed entries have no saved rate. Review totals before sharing.'**
  String get reportMissingRateWarning;

  /// No description provided for @marketingStudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketing Studio'**
  String get marketingStudioTitle;

  /// No description provided for @marketingStudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a premium promotion image or PDF offline, then share it with Facebook, WhatsApp, email or another device app.'**
  String get marketingStudioSubtitle;

  /// No description provided for @marketingProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Business or personal promotion'**
  String get marketingProfileTitle;

  /// No description provided for @marketingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company or professional name'**
  String get marketingNameLabel;

  /// No description provided for @marketingHeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Headline or short message'**
  String get marketingHeadlineLabel;

  /// No description provided for @marketingOfferLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer or promotion (optional)'**
  String get marketingOfferLabel;

  /// No description provided for @marketingServicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get marketingServicesLabel;

  /// No description provided for @marketingServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter one service per line'**
  String get marketingServicesHint;

  /// No description provided for @marketingServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our services'**
  String get marketingServicesTitle;

  /// No description provided for @marketingWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website or social page'**
  String get marketingWebsiteLabel;

  /// No description provided for @marketingTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Premium design'**
  String get marketingTemplateLabel;

  /// No description provided for @marketingTemplateProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get marketingTemplateProfessional;

  /// No description provided for @marketingTemplateBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get marketingTemplateBold;

  /// No description provided for @marketingTemplateElegant.
  ///
  /// In en, this message translates to:
  /// **'Elegant'**
  String get marketingTemplateElegant;

  /// No description provided for @marketingChooseLogo.
  ///
  /// In en, this message translates to:
  /// **'Add logo or photo'**
  String get marketingChooseLogo;

  /// No description provided for @marketingRemoveLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove logo'**
  String get marketingRemoveLogo;

  /// No description provided for @marketingPreview.
  ///
  /// In en, this message translates to:
  /// **'Live promotion preview'**
  String get marketingPreview;

  /// No description provided for @marketingSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save promotion profile'**
  String get marketingSaveProfile;

  /// No description provided for @marketingProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Promotion profile saved on this device.'**
  String get marketingProfileSaved;

  /// No description provided for @marketingCreateImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get marketingCreateImage;

  /// No description provided for @marketingCreatePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get marketingCreatePdf;

  /// No description provided for @marketingCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get marketingCreating;

  /// No description provided for @marketingExportSaved.
  ///
  /// In en, this message translates to:
  /// **'Promotion saved. Choose an app to share it.'**
  String get marketingExportSaved;

  /// No description provided for @marketingExportFailed.
  ///
  /// In en, this message translates to:
  /// **'The promotion could not be created.'**
  String get marketingExportFailed;

  /// No description provided for @marketingLogoFailed.
  ///
  /// In en, this message translates to:
  /// **'Choose a PNG, JPG or WebP logo up to 12 MB.'**
  String get marketingLogoFailed;

  /// No description provided for @marketingRequiredInfo.
  ///
  /// In en, this message translates to:
  /// **'Add the required promotion information.'**
  String get marketingRequiredInfo;

  /// No description provided for @marketingContactRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a phone number or email address.'**
  String get marketingContactRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'ga',
    'hi',
    'ja',
    'pl',
    'ro',
    'ur',
    'yo',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'ga':
      return AppLocalizationsGa();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'pl':
      return AppLocalizationsPl();
    case 'ro':
      return AppLocalizationsRo();
    case 'ur':
      return AppLocalizationsUr();
    case 'yo':
      return AppLocalizationsYo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
