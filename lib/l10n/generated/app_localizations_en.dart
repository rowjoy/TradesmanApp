// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WorkProof';

  @override
  String get tagline => 'Track your work. Protect your pay. Keep your proof.';

  @override
  String get loadingApp => 'Opening your local workspace…';

  @override
  String get startupFailed => 'We could not open your local workspace.';

  @override
  String get retry => 'Try again';

  @override
  String get continueLabel => 'Continue';

  @override
  String get backLabel => 'Back';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get skipSetup => 'Skip for now';

  @override
  String get skipOptional => 'You can change this later in Settings.';

  @override
  String get onboardingTitle => 'Set up WorkProof';

  @override
  String get onboardingSubtitle => 'No account or internet is required.';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get workModeTitle => 'How do you work?';

  @override
  String get workerMode => 'I work for an employer';

  @override
  String get workerModeDescription =>
      'Shifts, hours, expected pay, and payslips';

  @override
  String get tradesmanMode => 'I work for my own customers';

  @override
  String get tradesmanModeDescription =>
      'Jobs, customers, quotes, and invoices';

  @override
  String get bothMode => 'I do both';

  @override
  String get bothModeDescription =>
      'Keep employer work and customer work separate';

  @override
  String get marketTitle => 'Your work setup';

  @override
  String get countryLabel => 'Country';

  @override
  String get countryUnitedKingdom => 'United Kingdom';

  @override
  String get countryOther => 'Other / not listed yet';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get professionLabel => 'Profession or sector';

  @override
  String get professionHint => 'For example: construction, care, cleaning';

  @override
  String get professionRequired => 'Enter your profession or sector';

  @override
  String get payMethodTitle => 'Usual pay or charging method';

  @override
  String get methodHourly => 'Hourly';

  @override
  String get methodDaily => 'Daily';

  @override
  String get methodFixed => 'Fixed';

  @override
  String get methodMixed => 'Mixed';

  @override
  String get defaultRateLabel => 'Default rate (optional)';

  @override
  String get invalidRate => 'Enter a valid amount with up to 2 decimal places';

  @override
  String get preferencesTitle => 'Make it yours';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get demoDataTitle => 'Load editable demo data';

  @override
  String get demoDataDescription =>
      'See the workflow with a sample customer and job.';

  @override
  String get privacySetupNote =>
      'Your setup is saved only on this device. You can create an encrypted backup file in Settings.';

  @override
  String get setupSaveFailed =>
      'Setup was not saved. Your current data was not changed.';

  @override
  String get navHome => 'Home';

  @override
  String get navWork => 'Work';

  @override
  String get navMoney => 'Pay';

  @override
  String get navProof => 'Records';

  @override
  String get navMore => 'Settings';

  @override
  String get moneyTitle => 'Pay & Income';

  @override
  String get moneyExpected => 'Expected earnings';

  @override
  String get moneyTrackedTime => 'Tracked time';

  @override
  String get moneyCompletedEntries => 'Completed work records';

  @override
  String get moneyEmpty =>
      'Complete a tracked job to see deterministic earnings here.';

  @override
  String get proofTitle => 'Work Records';

  @override
  String get proofSubtitle => 'Activity saved on this device';

  @override
  String get proofEmpty =>
      'Actions recorded from this version will appear here.';

  @override
  String get savedOnDevice => 'Stored on This Device';

  @override
  String get localOnlyStatus => 'Stored on This Device';

  @override
  String get auditOnboardingCompleted => 'WorkProof setup completed';

  @override
  String get auditCustomerCreated => 'Customer created';

  @override
  String get auditJobCreated => 'Job created';

  @override
  String get auditClockedIn => 'Clocked in';

  @override
  String get auditBreakStarted => 'Break started';

  @override
  String get auditBreakEnded => 'Break ended';

  @override
  String get auditClockedOut => 'Clocked out';

  @override
  String get unknownActivity => 'Work activity recorded';

  @override
  String get settings => 'Settings';

  @override
  String get profileModeWorker => 'Worker mode';

  @override
  String get profileModeTradesman => 'Tradesman mode';

  @override
  String get profileModeBoth => 'Worker + Tradesman mode';

  @override
  String get workTitle => 'Work';

  @override
  String get workerFlow => 'Employer work';

  @override
  String get tradesmanFlow => 'Customer work';

  @override
  String get peopleTitle => 'Contacts & Services';

  @override
  String get calendarTitle => 'Work Calendar';

  @override
  String get newShift => 'New shift';

  @override
  String get newJob => 'New job';

  @override
  String get editShift => 'Edit shift';

  @override
  String get editJob => 'Edit job';

  @override
  String get searchShifts => 'Search shifts…';

  @override
  String get searchJobs => 'Search jobs…';

  @override
  String get searchPeople => 'Search this directory…';

  @override
  String get filterAll => 'All';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get noShifts => 'No shifts found. Add a normal or overnight shift.';

  @override
  String get noJobs => 'No jobs found. Add your first customer job.';

  @override
  String get workLoadFailed => 'We could not load your work.';

  @override
  String get notScheduled => 'Not scheduled';

  @override
  String get trackTime => 'Track time';

  @override
  String get editLabel => 'Edit';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get saveLabel => 'Save';

  @override
  String get addLabel => 'Add';

  @override
  String get deleteWorkTitle => 'Delete this work record?';

  @override
  String get deleteWorkDescription =>
      'It will be removed from active lists and kept in the local audit history.';

  @override
  String get employers => 'Employers';

  @override
  String get workplaces => 'Workplaces';

  @override
  String get customers => 'Customers';

  @override
  String get services => 'Services';

  @override
  String get noEmployers => 'No employers yet.';

  @override
  String get noWorkplaces => 'No workplaces yet.';

  @override
  String get noCustomers => 'No customers yet.';

  @override
  String get noServices => 'No services yet.';

  @override
  String get noContactInfo => 'No contact information';

  @override
  String get peopleLoadFailed => 'We could not load this directory.';

  @override
  String get deleteRecordTitle => 'Delete this record?';

  @override
  String get deleteRecordDescription =>
      'Linked history will not be silently erased.';

  @override
  String get newEmployer => 'New employer';

  @override
  String get editEmployer => 'Edit employer';

  @override
  String get employerName => 'Employer or agency name';

  @override
  String get contactName => 'Contact name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get emailLabel => 'Email';

  @override
  String get paySchedule => 'Pay schedule';

  @override
  String get contractNotes => 'Contract notes';

  @override
  String get newWorkplace => 'New workplace';

  @override
  String get editWorkplace => 'Edit workplace';

  @override
  String get workplaceName => 'Workplace name';

  @override
  String get addressLabel => 'Address';

  @override
  String get notesLabel => 'Notes';

  @override
  String get timeZoneLabel => 'Time Zone';

  @override
  String get newCustomer => 'New customer';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get customerName => 'Customer name';

  @override
  String get newService => 'New service';

  @override
  String get editService => 'Edit service';

  @override
  String get serviceName => 'Service name';

  @override
  String get categoryLabel => 'Category';

  @override
  String get pricingLabel => 'Pricing';

  @override
  String get durationMinutes => 'Default duration (minutes)';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get requiredField => 'This field is required';

  @override
  String get saveFailed => 'This record was not saved. Try again.';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get startUtcOffset => 'Start UTC offset';

  @override
  String get endUtcOffset => 'End UTC offset';

  @override
  String get overnightLabel => 'Overnight';

  @override
  String get invalidSchedule =>
      'End must be after start. Use the next date for overnight work.';

  @override
  String get shiftTitleLabel => 'Shift title';

  @override
  String get employerOptional => 'Employer (optional)';

  @override
  String get workplaceOptional => 'Workplace (optional)';

  @override
  String get hourlyRateOptional => 'Hourly rate (optional)';

  @override
  String get dailyRateOptional => 'Daily rate (optional)';

  @override
  String get fixedPriceOptional => 'Fixed price (optional)';

  @override
  String get breakMinutes => 'Break minutes';

  @override
  String get paidBreak => 'Paid break';

  @override
  String get invalidNumber => 'Enter a valid non-negative number';

  @override
  String get remindersEnabled => 'Reminders enabled';

  @override
  String get reminderIntentNote =>
      'Offline alerts will follow this work schedule.';

  @override
  String get saveShift => 'Save shift';

  @override
  String get saveJob => 'Save job';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get draftSaved => 'Draft saved on this device.';

  @override
  String get jobTitleLabel => 'Job title';

  @override
  String get serviceOptional => 'Service (optional)';

  @override
  String get calendarLoadFailed => 'We could not load this month.';

  @override
  String get noWorkOnDate => 'No work scheduled for this date.';

  @override
  String get dashboardTitle => 'Home';

  @override
  String get shiftsLabel => 'Today\'s shifts';

  @override
  String get jobsLabel => 'Today\'s jobs';

  @override
  String get todayWork => 'Today\'s work';

  @override
  String get seeAll => 'See all';

  @override
  String get loadMore => 'Load more';

  @override
  String get jobTimerTitle => 'Job time';

  @override
  String get shiftTimerTitle => 'Shift time';

  @override
  String get workRecordNotFound => 'This work record was not found.';

  @override
  String get timerRecovered =>
      'Active timer restored from this device. Its time is reconstructed from saved timestamps.';

  @override
  String get activeSessionExists => 'Another timer is active';

  @override
  String get activeSessionExistsDescription =>
      'WorkProof allows one active Job or Shift at a time.';

  @override
  String get openActiveWork => 'Open active work';

  @override
  String get openLabel => 'Open';

  @override
  String get notStarted => 'Not started';

  @override
  String get lastBillableTime => 'Last billable time';

  @override
  String get onBreak => 'On break';

  @override
  String get timerRunning => 'Timer running';

  @override
  String get anotherTimerRunning => 'Another timer is running';

  @override
  String get clockIn => 'Clock In';

  @override
  String get clockOut => 'Clock Out';

  @override
  String get resumeWork => 'Resume work';

  @override
  String get startBreak => 'Break';

  @override
  String get chooseBreakType => 'Choose break type';

  @override
  String get paidBreakDescription => 'Counts as billable work time.';

  @override
  String get unpaidBreak => 'Unpaid break';

  @override
  String get unpaidBreakDescription => 'Removed from billable work time.';

  @override
  String get clockOutConfirmTitle => 'Clock out now?';

  @override
  String get clockOutConfirmDescription =>
      'Any open break will end at the same time.';

  @override
  String get timerActionFailed => 'That timer action was not saved. Try again.';

  @override
  String get timerLoadFailed => 'This timer could not be loaded.';

  @override
  String get payRules => 'Pay rules';

  @override
  String get payRulesDescription =>
      'Optional overtime, premium, and rounding settings';

  @override
  String get overtimeAfter => 'Overtime after';

  @override
  String get overtimeMultiplier => 'Overtime multiplier';

  @override
  String get ratePremium => 'Rate premium';

  @override
  String get timeRounding => 'Billable time rounding';

  @override
  String get hoursShort => 'hr';

  @override
  String get daysShort => 'day';

  @override
  String get minutesShort => 'min';

  @override
  String get extraPay => 'Tips, bonus or allowance';

  @override
  String get plannedVsActual => 'Planned vs actual';

  @override
  String get plannedTime => 'Planned schedule';

  @override
  String get actualTime => 'Actual clock time';

  @override
  String get nowLabel => 'Now';

  @override
  String get rawDuration => 'Raw duration';

  @override
  String get billableDuration => 'Billable duration';

  @override
  String get earningsBreakdown => 'Earnings breakdown';

  @override
  String get baseRate => 'Base rate';

  @override
  String get regularPay => 'Regular pay';

  @override
  String get overtimePay => 'Overtime pay';

  @override
  String get premiumPay => 'Premium pay';

  @override
  String get fixedPay => 'Fixed pay';

  @override
  String get expectedTotal => 'Expected total';

  @override
  String get calculationSnapshotNote =>
      'Final values are saved as a deterministic calculation snapshot at Clock Out.';

  @override
  String get recentSessions => 'Recent sessions';

  @override
  String get completedSession => 'Completed session';

  @override
  String get correctTime => 'Correct time';

  @override
  String get corrected => 'Corrected';

  @override
  String get actualStart => 'Actual start';

  @override
  String get actualEnd => 'Actual end';

  @override
  String get correctionReason => 'Reason for correction';

  @override
  String get correctionReasonRequired =>
      'Use a reason of at least 3 characters and check the times.';

  @override
  String get correctionAuditNote =>
      'The reason and corrected timestamps stay in the audit history.';

  @override
  String get auditPaidBreakStarted => 'Paid break started';

  @override
  String get auditUnpaidBreakStarted => 'Unpaid break started';

  @override
  String get auditTimeCorrected => 'Tracked time corrected';

  @override
  String get activeTimer => 'Active work timer';

  @override
  String get helpAndGuidance => 'Help & guidance';

  @override
  String get sendFeedbackOnWhatsApp => 'Send feedback on WhatsApp';

  @override
  String whatsAppFeedbackSubtitle(String phoneNumber) {
    return 'Opens an editable draft to $phoneNumber';
  }

  @override
  String get whatsAppFeedbackMessage =>
      'Hi WorkProof team, I would like to share feedback:';

  @override
  String get whatsAppFeedbackFailed =>
      'Could not open WhatsApp. Please try again.';

  @override
  String get replayShowcase => 'Replay time tracking guide';

  @override
  String get replayShowcaseDescription =>
      'See the five-step Clock In and Clock Out workflow again.';

  @override
  String get showcaseBlockedByTimer =>
      'Finish the active timer before opening the guide.';

  @override
  String get showcasePlanTitle => 'Start from your work plan';

  @override
  String get showcaseWorkerPlanBody =>
      'Open a scheduled Shift from Home, Work, or Calendar.';

  @override
  String get showcaseTradesmanPlanBody =>
      'Open a customer Job from Home, Work, or Calendar.';

  @override
  String get showcaseBothPlanBody =>
      'Worker Shifts and customer Jobs stay separate, but use the same simple timer.';

  @override
  String get showcaseClockInTitle => 'Clock In when work begins';

  @override
  String get showcaseClockInBody =>
      'Only one Job or Shift can run at once. The timer survives an app restart.';

  @override
  String get showcaseBreakTitle => 'Choose the right break';

  @override
  String get showcaseBreakBody =>
      'Paid breaks remain billable. Unpaid breaks are removed automatically.';

  @override
  String get showcaseClockOutTitle => 'Clock Out when finished';

  @override
  String get showcaseClockOutBody =>
      'You will see planned versus actual time and a clear pay breakdown.';

  @override
  String get showcaseProofTitle => 'Keep a trustworthy record';

  @override
  String get showcaseProofBody =>
      'Corrections require a reason. Final time and pay calculations are saved in Work Records.';

  @override
  String get skipShowcase => 'Skip guide';

  @override
  String get nextLabel => 'Next';

  @override
  String get gotIt => 'Got it';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get workProfileTitle => 'Work profile';

  @override
  String get localProfile => 'Local profile';

  @override
  String get countryCurrencyTitle => 'Country and currency';

  @override
  String get languageLabel => 'Language';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get offlineNotificationsTitle => 'Work Reminders & Alerts';

  @override
  String get offlineNotificationsDescription =>
      'Timing, privacy, quiet hours and schedule repair';

  @override
  String get dataTitle => 'Data';

  @override
  String get localDataDescription => 'No account or internet is required.';

  @override
  String get payProtectionGuide => 'Pay Review guide';

  @override
  String get payProtectionGuideDescription =>
      'Review expected pay, payslips, supporting documents, and exports.';

  @override
  String get regionLanguageTitle => 'Region & language';

  @override
  String get localWorkspaceTitle => 'Data on This Device';

  @override
  String get localWorkspaceDescription =>
      'Language and money display update without an account or internet.';

  @override
  String get appLanguageLabel => 'App language';

  @override
  String get countryMarketLabel => 'Country or Region';

  @override
  String get defaultCurrencyLabel => 'Default Currency';

  @override
  String get currencyHistoryNote =>
      'Changing the default does not convert old records. Each customer can keep a separate billing currency.';

  @override
  String get savePreferences => 'Save preferences';

  @override
  String get preferencesSaved => 'Preferences saved.';

  @override
  String get preferencesSaveFailed => 'Preferences could not be saved.';

  @override
  String get m05PayProtection => 'Pay Review';

  @override
  String get m05WorkerPay => 'My Pay';

  @override
  String get m05BusinessMoney => 'Business Income';

  @override
  String get m05PayAtAGlance => 'Pay Summary';

  @override
  String get m05StartAPayPeriod => 'Add a Pay Period';

  @override
  String get m05PayPeriods => 'Pay periods';

  @override
  String get m05OnDevice => 'On device';

  @override
  String get m05ShowGuide => 'Show guide';

  @override
  String get m05AllEmployers => 'All employers';

  @override
  String get m05Expected => 'Expected';

  @override
  String get m05Received => 'Received';

  @override
  String get m05Reviewed => 'Reviewed';

  @override
  String get m05Exported => 'Exported';

  @override
  String get m05NoPayPeriodYet => 'No pay period yet';

  @override
  String get m05CreateNow => 'Create now';

  @override
  String get m05PayReview => 'Pay review';

  @override
  String get m05SavedCalculation => 'Saved calculation';

  @override
  String get m05ExpectedGross => 'Expected gross';

  @override
  String get m05ReceivedGross => 'Received gross';

  @override
  String get m05AddPayslip => 'Add payslip';

  @override
  String get m05EditPayslip => 'Edit payslip';

  @override
  String get m05AddEvidence => 'Add a document';

  @override
  String get m05RecordedHours => 'Recorded hours';

  @override
  String get m05Overtime => 'Overtime';

  @override
  String get m05Premiums => 'Premiums';

  @override
  String get m05Deductions => 'Deductions';

  @override
  String get m05NetPayment => 'Net payment';

  @override
  String get m05MetadataStripped => 'metadata stripped';

  @override
  String get m05ReviewMetadata => 'review metadata';

  @override
  String get m05NoEvidenceAttachedYet => 'No evidence attached yet.';

  @override
  String get m05Retry => 'Retry';

  @override
  String get m05Employer => 'Employer';

  @override
  String get m05NewPayPeriod => 'New pay period';

  @override
  String get m05EmployerScope => 'Employer scope';

  @override
  String get m05PayCurrency => 'Pay currency';

  @override
  String get m05From => 'From';

  @override
  String get m05To => 'To';

  @override
  String get m05CalculateAndSave => 'Calculate and save';

  @override
  String get m05Weekly => 'Weekly';

  @override
  String get m05Fortnightly => 'Fortnightly';

  @override
  String get m05FourWeekly => 'Four-weekly';

  @override
  String get m05Monthly => 'Monthly';

  @override
  String get m05CustomRange => 'Custom range';

  @override
  String get m05RecordPayslip => 'Record payslip';

  @override
  String get m05PayPeriodNotFound => 'Pay period not found.';

  @override
  String get m05PayDate => 'Pay date';

  @override
  String get m05NotSet => 'Not set';

  @override
  String get m05ChooseFile => 'Choose file';

  @override
  String get m05ReplaceFile => 'Replace file';

  @override
  String get m05SaveAndCompare => 'Save and compare';

  @override
  String get m05WriteANoteFirst => 'Write a note first.';

  @override
  String get m05ChooseAFileFirst => 'Choose a file first.';

  @override
  String get m05EvidenceType => 'Evidence type';

  @override
  String get m05WrittenNote => 'Written note';

  @override
  String get m05Photo => 'Photo';

  @override
  String get m05Payslip => 'Payslip';

  @override
  String get m05WhatHappened => 'What happened?';

  @override
  String get m05DescriptionOptional => 'Description (optional)';

  @override
  String get m05NoFileSelected => 'No file selected';

  @override
  String get m05ChooseAnother => 'Choose another';

  @override
  String get m05SaveEvidence => 'Save evidence';

  @override
  String get m05ExpectedAndReceivedPayStaySeparateA =>
      'Expected and received pay stay separate. A difference is a review prompt, not a legal conclusion.';

  @override
  String get m05ChooseEmployerScheduleAndCurrencyInsideThis =>
      'Choose employer, schedule and currency inside this screen. No popup dropdown is used.';

  @override
  String get m05CreatePayProtectionPeriod => 'Add a Pay Period';

  @override
  String get m05ReviewEvidenceExport => 'Review Pay & Documents';

  @override
  String get m05OpenAPeriodToAddAPayslip =>
      'Open a period to add a payslip, attach evidence and create an offline PDF + ZIP pack.';

  @override
  String get m05PossibleDifferenceToReview => 'Possible difference to review';

  @override
  String get m05CreateOneAfterRecordingShiftsExpectedPay =>
      'Create one after recording shifts. Expected pay is calculated from saved time snapshots.';

  @override
  String get m05PayslipSavedPayComparisonUpdated =>
      'Payslip saved. Pay comparison updated.';

  @override
  String get m05EvidenceSavedWithAnIntegrityChecksum =>
      'Evidence saved with an integrity checksum.';

  @override
  String get m05PDFZIPPackCreatedOfflineSHA256 =>
      'PDF + ZIP pack created offline. SHA-256 manifest included.';

  @override
  String get m05ExportCouldNotBeCreated => 'Export could not be created.';

  @override
  String get m05EvidenceTimeline => 'Documents & Notes';

  @override
  String get m05ExportsUseSelectedEvidenceAndPrivacyShare =>
      'Exports use selected evidence and privacy share-copies. Original files stay private on this device. Review documents before sharing.';

  @override
  String get m05CreatePDFZIPEvidencePack => 'Create PDF + ZIP evidence pack';

  @override
  String get m05ThisIsAUserCreatedRecordNot =>
      'This is a user-created record, not legal advice or a finding of underpayment.';

  @override
  String get m05AddAPayslipToComparePayment =>
      'Add a payslip to compare payment.';

  @override
  String get m05ExpectedAndReceivedGrossMatch =>
      'Expected and received gross match.';

  @override
  String get m05AllowancesAdjustments => 'Allowances & adjustments';

  @override
  String get m05NoCompletedShiftsWereFoundInThis =>
      'No completed shifts were found in this range.';

  @override
  String get m05EnterALabelAndValidAmount => 'Enter a label and valid amount.';

  @override
  String get m05AddExpectedPayAdjustment => 'Add expected-pay adjustment';

  @override
  String get m05AdjustmentType => 'Adjustment type';

  @override
  String get m05Allowance => 'Allowance';

  @override
  String get m05OvertimeCorrection => 'Overtime correction';

  @override
  String get m05ManualCorrection => 'Manual correction';

  @override
  String get m05ReasonLabel => 'Reason / label';

  @override
  String get m05UseAMinusSignOnlyForA =>
      'Use a minus sign only for a correction that reduces expected gross.';

  @override
  String get m05SaveAdjustment => 'Save adjustment';

  @override
  String get m05CouldNotLoadPayPeriod => 'Could not load pay period.';

  @override
  String get m05EndDateMustBeAfterStart => 'End date must be after start.';

  @override
  String get m05PayPeriodCreatedAndExpectedPayCalculated =>
      'Pay period created and expected pay calculated.';

  @override
  String get m05CouldNotCreatePayPeriod => 'Could not create pay period.';

  @override
  String get m05CompletedWorkerShiftsInThisDateRange =>
      'Completed worker shifts in this date range are used to create a saved expected-pay snapshot.';

  @override
  String get m05PrivateNoteOptional => 'Private note (optional)';

  @override
  String get m05FileCouldNotBePrepared => 'File could not be prepared.';

  @override
  String get m05EnterValidGrossDeductionsAndNetAmounts =>
      'Enter valid gross, deductions and net amounts.';

  @override
  String get m05PayslipCouldNotBeSaved => 'Payslip could not be saved.';

  @override
  String get m05EnterValuesExactlyAsShownOCRIs =>
      'Enter values exactly as shown. OCR is not used, so nothing is silently accepted.';

  @override
  String get m05PayslipReferenceOptional => 'Payslip reference (optional)';

  @override
  String get m05PayslipPhotoOrPDF => 'Payslip photo or PDF';

  @override
  String get m05EvidenceCouldNotBeSaved => 'Evidence could not be saved.';

  @override
  String get m05DocumentPDF => 'Document / PDF';

  @override
  String get m05TypedAcknowledgement => 'Typed acknowledgement';

  @override
  String get m05SignerNameAndAcknowledgement =>
      'Signer name and acknowledgement';

  @override
  String get m05CompressedShareCopyCreatedImageMetadataStripped =>
      'Compressed share-copy created; image metadata stripped.';

  @override
  String get m05AShareCopyIsCreatedDocumentMetadata =>
      'A share-copy is created. Document metadata may remain—review before sharing.';

  @override
  String get m05ChooseFromDevice => 'Choose from device';

  @override
  String get m05ThisRecordsTypedAcknowledgementAndTimeOnly =>
      'This records typed acknowledgement and time only; it is not a verified digital signature.';

  @override
  String get m05OriginalEvidenceStaysPrivateOnThisDevice =>
      'Original evidence stays private on this device. Only selected evidence is added to an export.';

  @override
  String m05OpenPeriodsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open periods',
      one: '1 open period',
      zero: 'No open periods',
    );
    return '$_temp0';
  }

  @override
  String m05PossibleDifferenceReview(String amount) {
    return 'Possible $amount difference — review the payslip and saved records.';
  }

  @override
  String m05ReceivedAboveExpectedReview(String amount) {
    return 'Received $amount above expected — review the saved records.';
  }

  @override
  String m05MissingRateReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries need a rate review.',
      one: '1 entry needs a rate review.',
      zero: 'All rates are ready.',
    );
    return '$_temp0';
  }

  @override
  String m05AmountWithCurrency(String currency) {
    return 'Amount ($currency)';
  }

  @override
  String get m04NotificationsJobAlerts => 'Notifications & Job Alerts';

  @override
  String get m04WorkAlerts => 'Work alerts';

  @override
  String get m04PrivateLockScreenText => 'Private lock-screen text';

  @override
  String get m04HidesJobCustomerAndWorkplaceNames =>
      'Hides Job, customer and workplace names';

  @override
  String get m04OptionalMotivation => 'Optional motivation';

  @override
  String get m04CalmDailyMessage => 'Calm daily message';

  @override
  String get m04OffByDefaultAndSuppressedNearImportant =>
      'Off by default and suppressed near important alerts';

  @override
  String get m04DeliveryTime => 'Delivery time';

  @override
  String get m04CustomMessageOptional => 'Custom message (optional)';

  @override
  String get m04QuietHours22000700 => 'Quiet hours: 22:00–07:00';

  @override
  String get m04PreviewAndMotivationWaitTimeSensitiveWork =>
      'Preview and motivation wait; time-sensitive work alerts stay on time.';

  @override
  String get m04OfflineDelivery => 'Offline delivery';

  @override
  String get m04NoInternetIsNeededOSBatteryRules =>
      'No internet is needed. OS battery rules may shift an inexact reminder; Repair schedule reconciles it again.';

  @override
  String get m04OnlyWhileWorkIsActive => 'Only while work is active';

  @override
  String get m04DigestTime => 'Digest time';

  @override
  String get m04HowEarly => 'How early';

  @override
  String get m04NotificationsEnabled => 'Notifications enabled';

  @override
  String get m04NotificationPermissionNeeded =>
      'Notification permission needed';

  @override
  String get m04Enable => 'Enable';

  @override
  String get m04RepairSchedule => 'Repair schedule';

  @override
  String get m04SystemSettings => 'System settings';

  @override
  String get m04PreviousDayPreview => 'Previous-day preview';

  @override
  String get m04700MorningDigest => '7:00 morning digest';

  @override
  String get m04PreparationAlert => 'Preparation alert';

  @override
  String get m04StartsSoon => 'Starts soon';

  @override
  String get m04ActiveWorkBreak => 'Active-work break';

  @override
  String get m04ScheduledFinish => 'Scheduled finish';

  @override
  String get m04Motivation => 'Motivation';

  @override
  String get m04RemindYouAboutWork => 'Remind you about work?';

  @override
  String get m04WorkProofCanScheduleJobAndShiftAlerts =>
      'WorkProof can schedule Job and Shift alerts on this device without internet.';

  @override
  String get m04WorkAndCustomerNamesStayPrivateOn =>
      'Work and customer names stay private on the lock screen.';

  @override
  String get m04NotNow => 'Not now';

  @override
  String get m04ReminderDetails => 'Reminder details';

  @override
  String get m04DefaultsAreReadyChangeOnlyIfNeeded =>
      'Defaults are ready—change only if needed';

  @override
  String get m04UseAppDefaults => 'Use app defaults';

  @override
  String get m04TimingChangesInSettingsWillApplyTo =>
      'Timing changes in Settings will apply to this work';

  @override
  String get m04StartsSoonAlert => 'Starts-soon alert';

  @override
  String get m04EndAlertForActiveWork => 'End alert for active work';

  @override
  String get m04OnlyShownAfterClockIn => 'Only shown after Clock In';

  @override
  String get m04WorkStartsSoon => 'Work starts soon';

  @override
  String m04MinutesBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes before',
      one: '1 minute before',
    );
    return '$_temp0';
  }

  @override
  String m04HoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours before',
      one: '1 hour before',
    );
    return '$_temp0';
  }

  @override
  String m04ReminderStatus(int pending, int attention) {
    return '$pending reminders prepared · $attention need attention';
  }

  @override
  String get m04NotificationsEnabledMessage =>
      'Notifications enabled and schedule repaired.';

  @override
  String get m04NotificationsDeniedMessage =>
      'Notification permission was not granted. Work is still saved.';

  @override
  String get m04ScheduleRepairedMessage => 'Notification schedule repaired.';

  @override
  String get recordDeleted => 'Record deleted.';

  @override
  String get payEvidencePacksTitle => 'Pay Records & Exports';

  @override
  String get payEvidencePacksDescription =>
      'Open payslips, supporting documents, and PDF + ZIP exports from Pay & Income.';

  @override
  String get auditPreferencesUpdated => 'Workspace preferences updated';

  @override
  String get auditPayPeriodCreated => 'Pay period snapshot created';

  @override
  String get auditPayslipRecorded => 'Payslip recorded for comparison';

  @override
  String get auditPayAdjustmentAdded => 'Expected-pay adjustment added';

  @override
  String get auditEvidenceAdded => 'Evidence added with integrity record';

  @override
  String get auditWorkProofExported => 'WorkProof PDF + ZIP pack exported';

  @override
  String get customerBillingCurrency => 'Customer billing currency';

  @override
  String get generalWork => 'General work';

  @override
  String get adjustmentSaved => 'Adjustment saved and expected pay updated.';

  @override
  String get evidenceFileTooLarge =>
      'This file is too large. Choose a file up to 25 MB.';

  @override
  String notificationMorningDigestTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count work items today',
      one: '1 work item today',
    );
    return '$_temp0';
  }

  @override
  String get notificationMorningDigestBody =>
      'Open Calendar to review your day.';

  @override
  String get notificationMotivationBody =>
      'Start today with one small, clear work plan.';

  @override
  String notificationUpcomingTitle(String subject) {
    return 'Upcoming work$subject';
  }

  @override
  String get notificationUpcomingBody => 'Review the schedule and prepare.';

  @override
  String notificationPrepareTitle(String subject) {
    return 'Prepare for work$subject';
  }

  @override
  String get notificationPrepareBody => 'Check the time and what you need.';

  @override
  String notificationStartsSoonTitle(String subject) {
    return 'Work starts soon$subject';
  }

  @override
  String notificationStartsSoonBody(String time) {
    return 'Scheduled time: $time.';
  }

  @override
  String get notificationBreakTitle => 'Break reminder';

  @override
  String get notificationBreakBody => 'Take a safe break when practical.';

  @override
  String get notificationFinishTitle => 'Scheduled finish';

  @override
  String get notificationFinishBody => 'Clock out when your work is complete.';

  @override
  String get notificationReviewPlanBody => 'Review your work plan.';

  @override
  String get securityPrivacyTitle => 'Security & privacy';

  @override
  String get appLockTitle => 'App lock';

  @override
  String get appLockSubtitle =>
      'Protect WorkProof with a PIN and device biometrics.';

  @override
  String get enableAppLock => 'Enable app lock';

  @override
  String get changePin => 'Change PIN';

  @override
  String get useBiometrics => 'Use biometrics';

  @override
  String get biometricLockSubtitle =>
      'Unlock with biometrics available on this device.';

  @override
  String get biometricUnavailable =>
      'Biometrics are unavailable on this device.';

  @override
  String get lockNow => 'Lock now';

  @override
  String get evidenceEncryptionTitle => 'Protected Documents';

  @override
  String get evidenceEncryptionDescription =>
      'New evidence files are protected with authenticated AES-256 encryption on this device.';

  @override
  String get securitySaved => 'Security settings saved.';

  @override
  String get securitySaveFailed => 'Security settings could not be saved.';

  @override
  String get wrongPin => 'That PIN is not correct.';

  @override
  String get createPin => 'Create a PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get pinDigitsHint => 'Use 4 to 8 digits.';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinMismatch => 'The PINs do not match.';

  @override
  String get tooManyAttempts =>
      'Too many attempts. Wait 30 seconds and try again.';

  @override
  String get biometricFailed => 'Biometric verification was not completed.';

  @override
  String get unlockWorkProof => 'Unlock WorkProof';

  @override
  String get enterPinToContinue => 'Enter your PIN to continue.';

  @override
  String get unlock => 'Unlock';

  @override
  String get biometricUnlockReason => 'Unlock your WorkProof workspace';

  @override
  String get unlockWithBiometrics => 'Unlock with biometrics';

  @override
  String get biometricSetupReason =>
      'Confirm biometrics for WorkProof app lock';

  @override
  String get backupRestoreTitle => 'Backup & restore';

  @override
  String get backupRestoreSubtitle =>
      'Create an encrypted backup or safely restore your workspace.';

  @override
  String get backupSafetyTitle => 'Encrypted, verified and offline';

  @override
  String get backupSafetyDescription =>
      'Backups include your local records and evidence. WorkProof verifies every file before restore and never uploads it automatically.';

  @override
  String get createBackupTitle => 'Create backup';

  @override
  String get createBackupDescription =>
      'Create a password-encrypted .workproof file containing a consistent database snapshot and your evidence.';

  @override
  String lastBackupLabel(String date) {
    return 'Last backup: $date';
  }

  @override
  String get creatingBackup => 'Creating encrypted backup…';

  @override
  String get createEncryptedBackup => 'Create encrypted backup';

  @override
  String get shareBackup => 'Share or save backup';

  @override
  String get shareBackupFailed => 'The backup could not be shared.';

  @override
  String get backupCreatedSuccess => 'Encrypted backup created and verified.';

  @override
  String backupCreatedSummary(int records, int evidence, String size) {
    return '$records records · $evidence evidence files · $size';
  }

  @override
  String get restoreBackupTitle => 'Restore backup';

  @override
  String get restoreBackupDescription =>
      'Choose a .workproof file and enter its password. Nothing is changed until verification finishes and you confirm a restore mode.';

  @override
  String get chooseBackupFile => 'Choose backup file';

  @override
  String get verifyingBackup => 'Verifying every file…';

  @override
  String get verifiedBackupPreview => 'Verified backup preview';

  @override
  String backupRecordsCount(int count) {
    return 'Records: $count';
  }

  @override
  String backupEvidenceCount(int count) {
    return 'Evidence files: $count';
  }

  @override
  String backupSchemaVersion(int version) {
    return 'Backup data version: $version';
  }

  @override
  String get chooseRestoreMode => 'Choose how to restore';

  @override
  String get mergeRestore => 'Merge with this device';

  @override
  String get mergeRestoreDescription =>
      'Keeps existing data and adds records that are not already on this device.';

  @override
  String get replaceRestore => 'Replace this workspace';

  @override
  String get replaceRestoreWarning =>
      'This replaces the current local workspace with the verified backup. WorkProof creates a recovery snapshot first and rolls back if any check fails.';

  @override
  String get restoreRollbackNote =>
      'A protected pre-import snapshot is created before either restore mode.';

  @override
  String get restoringBackup => 'Restoring and checking your workspace…';

  @override
  String get createBackupPassword => 'Protect this backup';

  @override
  String get enterBackupPassword => 'Enter backup password';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get confirmBackupPassword => 'Confirm backup password';

  @override
  String get backupPasswordHint => 'Use at least 10 characters.';

  @override
  String get backupPasswordWarning =>
      'WorkProof cannot recover this password. Store it separately from the backup file.';

  @override
  String get passwordsDoNotMatch => 'The passwords do not match.';

  @override
  String get backupVerifiedSuccess => 'Backup password and file checks passed.';

  @override
  String get confirmMergeRestore => 'Merge this verified backup?';

  @override
  String get confirmReplaceRestore => 'Replace the local workspace?';

  @override
  String get restoreNow => 'Restore now';

  @override
  String get restoreBlockedByTimer =>
      'Stop the active timer before backing up or restoring workspace data.';

  @override
  String get restoreCompletedSuccess =>
      'Restore completed and all integrity checks passed.';

  @override
  String get wrongPasswordOrDamaged =>
      'The password is wrong or the backup is damaged.';

  @override
  String get unsupportedBackup =>
      'This backup version is not supported by this app version.';

  @override
  String get backupIntegrityFailed =>
      'A backup checksum failed. No data was changed.';

  @override
  String get restoreFailedRolledBack =>
      'Restore failed. Your previous workspace was restored automatically.';

  @override
  String get restoreValidationFailed =>
      'This backup could not be verified. No data was changed.';

  @override
  String get backupOperationFailed =>
      'The backup operation could not be completed. Your local data is unchanged.';

  @override
  String get useLatestRecovery => 'Use latest recovery snapshot';

  @override
  String get recoveryVerifiedSuccess =>
      'The latest protected recovery snapshot passed all checks.';

  @override
  String get noRecoverySnapshot => 'No recovery snapshot is available yet.';

  @override
  String get reportsTitle => 'Reports & statements';

  @override
  String get reportsOfflineDescription =>
      'Weekly, monthly and custom reports are calculated from your on-device records.';

  @override
  String get reportLoadFailed => 'The offline report could not be calculated.';

  @override
  String get reportEndDateInclusive => 'The displayed end date is included.';

  @override
  String get reportAllWork => 'All work';

  @override
  String get reportEmployerStatement => 'Employer statement';

  @override
  String get reportCustomerStatement => 'Customer statement';

  @override
  String get reportPartyStatement => 'Employer or customer statement';

  @override
  String get reportAllParties => 'All employers and customers';

  @override
  String get reportWorkerSummary => 'Pay summary';

  @override
  String get reportIncomeSummary => 'Business income summary';

  @override
  String get reportStatementLines => 'Statement lines';

  @override
  String get reportNoRecords =>
      'No matching records were found in this date range.';

  @override
  String get reportExportPrivacyNote =>
      'Exports are created offline and may contain private work and pay data. Share them only with someone you trust.';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get reportCreatingExport => 'Creating…';

  @override
  String get reportExportFailed => 'The report export could not be created.';

  @override
  String get reportExportCreated =>
      'Offline report created and checksum recorded.';

  @override
  String get reportBillableHours => 'Billable hours';

  @override
  String get reportPossibleDifference => 'Possible difference';

  @override
  String get reportBillableWork => 'Billable work';

  @override
  String get reportInvoiced => 'Invoiced';

  @override
  String get reportPaid => 'Paid';

  @override
  String get reportOutstanding => 'Outstanding';

  @override
  String get reportExpenses => 'Expenses';

  @override
  String get reportNetCash => 'Net cash';

  @override
  String get reportWorkerTime => 'Worker time';

  @override
  String get reportBusinessTime => 'Business time';

  @override
  String get reportInvoice => 'Invoice';

  @override
  String get reportPayment => 'Payment';

  @override
  String get reportExpense => 'Expense';

  @override
  String get auditReportExported => 'Offline report exported';

  @override
  String get privacyChoicesTitle => 'Privacy choices';

  @override
  String get privacyChoicesAvailable =>
      'Review or change advertising consent choices.';

  @override
  String get privacyChoicesDescription =>
      'Manage consent when privacy options are required in your region.';

  @override
  String get privacyChoicesUpdated => 'Privacy choices were reviewed.';

  @override
  String get privacyChoicesNotRequired =>
      'Additional privacy choices are not required for this region.';

  @override
  String get privacyChoicesFailed => 'Privacy choices could not be opened.';

  @override
  String get advertisementLabel => 'Advertisement';

  @override
  String get reportMissingRateWarning =>
      'Some completed entries have no saved rate. Review totals before sharing.';

  @override
  String get marketingStudioTitle => 'Create Promotions';

  @override
  String get marketingStudioSubtitle =>
      'Create a premium promotion image or PDF offline, then share it with Facebook, WhatsApp, email or another device app.';

  @override
  String get marketingProfileTitle => 'Promotion Details';

  @override
  String get marketingNameLabel => 'Company or professional name';

  @override
  String get marketingHeadlineLabel => 'Headline or short message';

  @override
  String get marketingOfferLabel => 'Offer or promotion (optional)';

  @override
  String get marketingServicesLabel => 'Services';

  @override
  String get marketingServicesHint => 'Enter one service per line';

  @override
  String get marketingServicesTitle => 'Our services';

  @override
  String get marketingWebsiteLabel => 'Website or social page';

  @override
  String get marketingTemplateLabel => 'Design Style';

  @override
  String get marketingTemplateProfessional => 'Professional';

  @override
  String get marketingTemplateBold => 'Bold';

  @override
  String get marketingTemplateElegant => 'Elegant';

  @override
  String get marketingChooseLogo => 'Add company logo';

  @override
  String get marketingRemoveLogo => 'Remove logo';

  @override
  String get marketingChooseCoverPhoto => 'Add business photo';

  @override
  String get marketingRemoveCoverPhoto => 'Remove business photo';

  @override
  String get marketingPreview => 'Live promotion preview';

  @override
  String get marketingSaveProfile => 'Save promotion profile';

  @override
  String get marketingProfileSaved => 'Promotion profile saved on this device.';

  @override
  String get marketingCreateImage => 'Image';

  @override
  String get marketingCreatePdf => 'PDF';

  @override
  String get marketingCreating => 'Creating…';

  @override
  String get marketingExportSaved =>
      'Promotion saved. Choose an app to share it.';

  @override
  String get marketingExportFailed => 'The promotion could not be created.';

  @override
  String get marketingLogoFailed =>
      'Choose a PNG, JPG or WebP logo up to 12 MB.';

  @override
  String get marketingCoverPhotoFailed =>
      'Choose a PNG, JPG or WebP business photo up to 12 MB.';

  @override
  String get marketingRequiredInfo => 'Add the required promotion information.';

  @override
  String get marketingContactRequired => 'Add a phone number or email address.';

  @override
  String get aboutWorkProof => 'About WorkProof';

  @override
  String get appInformationTitle => 'App information';

  @override
  String get aboutAppDescription =>
      'An offline-first work companion for planning jobs and shifts, tracking time, reviewing pay, and keeping reliable records.';

  @override
  String get rateWorkProof => 'Rate WorkProof';

  @override
  String get storeListingFailed =>
      'The app store could not be opened. Try again.';

  @override
  String get appFeaturesTitle => 'What you can do';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get versionUnavailable => 'Version unavailable';

  @override
  String get featureDetails => 'Feature details';

  @override
  String get openFeature => 'Open feature';

  @override
  String get featureWorkShortDescription =>
      'Create, schedule, and manage customer jobs or employer shifts.';

  @override
  String get featureWorkDescription =>
      'Keep each job or shift organized with its schedule, pricing, reminders, and current status.';

  @override
  String get featureTimeTrackingTitle => 'Time Tracking';

  @override
  String get featureTimeTrackingShortDescription =>
      'Clock in and out, record breaks, and compare planned time with actual time.';

  @override
  String get featureTimeTrackingDescription =>
      'Track work offline with one reliable timer, paid or unpaid breaks, corrections with reasons, and saved earnings calculations.';

  @override
  String get featureContactsShortDescription =>
      'Keep employers, workplaces, customers, and services organized.';

  @override
  String get featureContactsDescription =>
      'Save the people, places, and services connected to your work so new jobs and shifts are quicker to create.';

  @override
  String get featureCalendarShortDescription =>
      'See jobs and shifts by date and plan what is coming next.';

  @override
  String get featureCalendarDescription =>
      'Browse a monthly calendar and daily agenda, then open or add the work you need.';

  @override
  String get featurePayShortDescription =>
      'Review expected pay, received pay, business income, and outstanding amounts.';

  @override
  String get featurePayDescription =>
      'Compare pay periods and payslips or review invoices, payments, expenses, and income from your saved work.';

  @override
  String get featureRecordsShortDescription =>
      'Keep a clear, on-device history of important work and pay activity.';

  @override
  String get featureRecordsDescription =>
      'Review saved activity, supporting documents, corrections, and exports that help explain what happened.';

  @override
  String get featureReportsShortDescription =>
      'Create weekly, monthly, or custom reports from your saved records.';

  @override
  String get featureReportsDescription =>
      'Review work, time, pay, and business totals, then export PDF or CSV statements offline.';

  @override
  String get featureRemindersShortDescription =>
      'Get on-device alerts for upcoming work, breaks, and planned finish times.';

  @override
  String get featureRemindersDescription =>
      'Choose reminder timing, quiet hours, privacy, and daily summaries without needing an internet connection.';

  @override
  String get featureBackupShortDescription =>
      'Create encrypted backup files and safely restore your workspace.';

  @override
  String get featureBackupDescription =>
      'Protect local records and documents with a password-encrypted backup that is verified before restore.';

  @override
  String get featureSecurityShortDescription =>
      'Protect private records with a PIN, biometrics, and encrypted documents.';

  @override
  String get featureSecurityDescription =>
      'Lock WorkProof when you are away and keep new supporting files encrypted on this device.';

  @override
  String get featurePromotionsShortDescription =>
      'Create a polished promotion image or PDF and share it from your device.';

  @override
  String get featurePromotionsDescription =>
      'Save your services, contact details, logo, offer, and design style to make reusable promotional material offline.';

  @override
  String get codeToolsTitle => 'Scan & Create Codes';

  @override
  String get codeToolsShortDescription =>
      'Scan QR codes and barcodes or create and share your own.';

  @override
  String get codeToolsDescription =>
      'Use the camera to read supported codes, or generate QR codes and barcodes from text entirely on your device.';

  @override
  String get manageJobTitle => 'Manage Job';

  @override
  String get manageJobDescription =>
      'Status · Costs · Payments · Job documents';

  @override
  String get jobStatusTitle => 'Job Status';

  @override
  String get costsAndPaymentsTitle => 'Costs & Payments';

  @override
  String get jobDocumentsTitle => 'Job Documents';

  @override
  String get updateAvailableTitle => 'New Version Available';

  @override
  String get updateAvailableMessage =>
      'A new version of WorkProof is available with improvements, bug fixes, and new features.';

  @override
  String get updateRequiredMessage =>
      'This important update is required to continue safely.';

  @override
  String get updateNow => 'Update Now';

  @override
  String get later => 'Later';

  @override
  String get checkingForUpdates => 'Checking for updates…';

  @override
  String get installingUpdate => 'Preparing your update…';

  @override
  String get updateDownloadReadyTitle => 'Update Ready';

  @override
  String get updateDownloadReadyMessage =>
      'The update has downloaded. Restart WorkProof to finish installing it.';

  @override
  String get restartToUpdate => 'Restart to Update';

  @override
  String get updateFailed =>
      'The update could not be completed. You can continue using WorkProof.';

  @override
  String get updateCheckFailed =>
      'Updates could not be checked right now. You can continue normally.';

  @override
  String get latestVersionInstalled => 'You already have the latest version.';

  @override
  String get checkForUpdates => 'Check for Updates';
}
