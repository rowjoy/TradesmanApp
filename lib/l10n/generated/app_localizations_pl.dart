// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'WorkProof';

  @override
  String get tagline =>
      'Śledź swoją pracę. Chroń swoje wynagrodzenie. Zachowaj dowód.';

  @override
  String get loadingApp => 'Otwieranie lokalnego obszaru roboczego…';

  @override
  String get startupFailed => 'Nie udało się otworzyć obszaru roboczego.';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get continueLabel => 'Kontynuuj';

  @override
  String get backLabel => 'Wstecz';

  @override
  String get finishSetup => 'Zakończ konfigurację';

  @override
  String get skipSetup => 'Pomiń na razie';

  @override
  String get skipOptional => 'Możesz to zmienić później w Ustawieniach.';

  @override
  String get onboardingTitle => 'Skonfiguruj WorkProof';

  @override
  String get onboardingSubtitle => 'Konto i internet nie są wymagane.';

  @override
  String get languageTitle => 'Wybierz swój język';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get workModeTitle => 'Jak pracujesz?';

  @override
  String get workerMode => 'Pracuję u pracodawcy (Pracownik)';

  @override
  String get workerModeDescription =>
      'Zmiany, godziny, przewidywane wynagrodzenie i paski płac';

  @override
  String get tradesmanMode => 'Pracuję dla własnych klientów (Firma/Fachowiec)';

  @override
  String get tradesmanModeDescription => 'Zlecenia, klienci, wyceny i faktury';

  @override
  String get bothMode => 'Robię jedno i drugie';

  @override
  String get bothModeDescription =>
      'Oddziel pracę u pracodawcy od zleceń dla klientów';

  @override
  String get marketTitle => 'Konfiguracja pracy';

  @override
  String get countryLabel => 'Kraj';

  @override
  String get countryUnitedKingdom => 'Wielka Brytania';

  @override
  String get countryOther => 'Inny / Brak na liście';

  @override
  String get currencyLabel => 'Waluta';

  @override
  String get professionLabel => 'Zawód lub branża';

  @override
  String get professionHint => 'Np.: budownictwo, opieka, sprzątanie';

  @override
  String get professionRequired => 'Wprowadź swój zawód lub branżę';

  @override
  String get payMethodTitle => 'Zwykły sposób rozliczenia';

  @override
  String get methodHourly => 'Stawka godzinowa';

  @override
  String get methodDaily => 'Stawka dzienna';

  @override
  String get methodFixed => 'Stawka stała';

  @override
  String get methodMixed => 'Mieszana';

  @override
  String get defaultRateLabel => 'Domyślna stawka (opcjonalnie)';

  @override
  String get invalidRate => 'Wprowadź prawidłową kwotę';

  @override
  String get preferencesTitle => 'Dostosuj aplikację';

  @override
  String get themeLabel => 'Motyw';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get demoDataTitle => 'Załaduj dane demonstracyjne';

  @override
  String get demoDataDescription =>
      'Zobacz jak działa aplikacja na przykładowych danych.';

  @override
  String get privacySetupNote =>
      'Konfiguracja jest zapisywana tylko na tym urządzeniu. Zaszyfrowany plik kopii zapasowej możesz utworzyć w Ustawieniach.';

  @override
  String get setupSaveFailed => 'Nie udało się zapisać konfiguracji.';

  @override
  String get navHome => 'Start';

  @override
  String get navWork => 'Praca';

  @override
  String get navMoney => 'Płace';

  @override
  String get navProof => 'Rejestry';

  @override
  String get navMore => 'Ustawienia';

  @override
  String get moneyTitle => 'Wynagrodzenie i przychody';

  @override
  String get moneyExpected => 'Przewidywane zarobki';

  @override
  String get moneyTrackedTime => 'Zarejestrowany czas';

  @override
  String get moneyCompletedEntries => 'Zakończone wpisy';

  @override
  String get moneyEmpty => 'Ukończ zlecenie, aby zobaczyć wyliczenia.';

  @override
  String get proofTitle => 'Rejestry pracy';

  @override
  String get proofSubtitle => 'Aktywność zapisana na tym urządzeniu';

  @override
  String get proofEmpty => 'Zarejestrowana aktywność pojawi się tutaj.';

  @override
  String get savedOnDevice => 'Przechowywane na tym urządzeniu';

  @override
  String get localOnlyStatus => 'Przechowywane na tym urządzeniu';

  @override
  String get auditOnboardingCompleted => 'Ukończono konfigurację WorkProof';

  @override
  String get auditCustomerCreated => 'Utworzono klienta';

  @override
  String get auditJobCreated => 'Utworzono zlecenie';

  @override
  String get auditClockedIn => 'Rozpoczęto pracę (Clock In)';

  @override
  String get auditBreakStarted => 'Rozpoczęto przerwę';

  @override
  String get auditBreakEnded => 'Zakończono przerwę';

  @override
  String get auditClockedOut => 'Zakończono pracę (Clock Out)';

  @override
  String get unknownActivity => 'Zarejestrowano aktywność';

  @override
  String get settings => 'Ustawienia';

  @override
  String get profileModeWorker => 'Tryb pracownika';

  @override
  String get profileModeTradesman => 'Tryb fachowca';

  @override
  String get profileModeBoth => 'Tryb hybrydowy';

  @override
  String get workTitle => 'Praca';

  @override
  String get workerFlow => 'Praca u pracodawcy';

  @override
  String get tradesmanFlow => 'Zlecenia klientów';

  @override
  String get peopleTitle => 'Kontakty i usługi';

  @override
  String get calendarTitle => 'Kalendarz pracy';

  @override
  String get newShift => 'Nowa zmiana';

  @override
  String get newJob => 'Nowe zlecenie';

  @override
  String get editShift => 'Edytuj zmianę';

  @override
  String get editJob => 'Edytuj zlecenie';

  @override
  String get searchShifts => 'Szukaj zmian…';

  @override
  String get searchJobs => 'Szukaj zleceń…';

  @override
  String get searchPeople => 'Szukaj w katalogu…';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get statusScheduled => 'Zaplanowane';

  @override
  String get statusCompleted => 'Zakończone';

  @override
  String get noShifts => 'Nie znaleziono zmian.';

  @override
  String get noJobs => 'Nie znaleziono zleceń.';

  @override
  String get workLoadFailed => 'Nie udało się załadować danych.';

  @override
  String get notScheduled => 'Niezaplanowane';

  @override
  String get trackTime => 'Mierz czas';

  @override
  String get editLabel => 'Edytuj';

  @override
  String get deleteLabel => 'Usuń';

  @override
  String get cancelLabel => 'Anuluj';

  @override
  String get saveLabel => 'Zapisz';

  @override
  String get addLabel => 'Dodaj';

  @override
  String get deleteWorkTitle => 'Usunąć ten wpis pracy?';

  @override
  String get deleteWorkDescription => 'Zostanie usunięty z aktywnych list.';

  @override
  String get employers => 'Pracodawcy';

  @override
  String get workplaces => 'Miejsca pracy';

  @override
  String get customers => 'Klienci';

  @override
  String get services => 'Usługi';

  @override
  String get noEmployers => 'Brak pracodawców.';

  @override
  String get noWorkplaces => 'Brak miejsc pracy.';

  @override
  String get noCustomers => 'Brak klientów.';

  @override
  String get noServices => 'Brak usług.';

  @override
  String get noContactInfo => 'Brak danych kontaktowych';

  @override
  String get peopleLoadFailed => 'Nie udało się załadować katalogu.';

  @override
  String get deleteRecordTitle => 'Usunąć rekord?';

  @override
  String get deleteRecordDescription =>
      'Powiązana historia nie zostanie usunięta.';

  @override
  String get newEmployer => 'Nowy pracodawca';

  @override
  String get editEmployer => 'Edytuj pracodawcę';

  @override
  String get employerName => 'Nazwa pracodawcy';

  @override
  String get contactName => 'Osoba kontaktowa';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get paySchedule => 'Harmonogram wypłat';

  @override
  String get contractNotes => 'Uwagi do umowy';

  @override
  String get newWorkplace => 'Nowe miejsce pracy';

  @override
  String get editWorkplace => 'Edytuj miejsce pracy';

  @override
  String get workplaceName => 'Nazwa miejsca pracy';

  @override
  String get addressLabel => 'Adres';

  @override
  String get notesLabel => 'Notatki';

  @override
  String get timeZoneLabel => 'Strefa czasowa';

  @override
  String get newCustomer => 'Nowy klient';

  @override
  String get editCustomer => 'Edytuj klienta';

  @override
  String get customerName => 'Nazwa klienta';

  @override
  String get newService => 'Nowa usługa';

  @override
  String get editService => 'Edytuj usługę';

  @override
  String get serviceName => 'Nazwa usługi';

  @override
  String get categoryLabel => 'Kategoria';

  @override
  String get pricingLabel => 'Cennik';

  @override
  String get durationMinutes => 'Domyślny czas (minuty)';

  @override
  String get descriptionLabel => 'Opis';

  @override
  String get requiredField => 'To pole jest wymagane';

  @override
  String get saveFailed => 'Nie udało się zapisać.';

  @override
  String get scheduleTitle => 'Harmonogram';

  @override
  String get startLabel => 'Początek';

  @override
  String get endLabel => 'Koniec';

  @override
  String get startUtcOffset => 'Strefa początkowa UTC';

  @override
  String get endUtcOffset => 'Strefa końcowa UTC';

  @override
  String get overnightLabel => 'Nocna zmiana';

  @override
  String get invalidSchedule => 'Koniec musi być po początku.';

  @override
  String get shiftTitleLabel => 'Tytuł zmiany';

  @override
  String get employerOptional => 'Pracodawca (opcjonalnie)';

  @override
  String get workplaceOptional => 'Miejsce pracy (opcjonalnie)';

  @override
  String get hourlyRateOptional => 'Stawka godzinowa (opcjonalnie)';

  @override
  String get dailyRateOptional => 'Stawka dzienna (opcjonalnie)';

  @override
  String get fixedPriceOptional => 'Cena stała (opcjonalnie)';

  @override
  String get breakMinutes => 'Przerwa (minuty)';

  @override
  String get paidBreak => 'Płatna przerwa';

  @override
  String get invalidNumber => 'Wprowadź prawidłową liczbę';

  @override
  String get remindersEnabled => 'Przypomnienia włączone';

  @override
  String get reminderIntentNote =>
      'Powiadomienia będą zgodne z tym harmonogramem.';

  @override
  String get saveShift => 'Zapisz zmianę';

  @override
  String get saveJob => 'Zapisz zlecenie';

  @override
  String get saveDraft => 'Zapisz szkic';

  @override
  String get draftSaved => 'Szkic zapisany na urządzeniu.';

  @override
  String get jobTitleLabel => 'Tytuł zlecenia';

  @override
  String get serviceOptional => 'Usługa (opcjonalnie)';

  @override
  String get calendarLoadFailed => 'Nie udało się załadować miesiąca.';

  @override
  String get noWorkOnDate => 'Brak zaplanowanej pracy w tym dniu.';

  @override
  String get dashboardTitle => 'Start';

  @override
  String get shiftsLabel => 'Dzisiejsze zmiany';

  @override
  String get jobsLabel => 'Dzisiejsze zlecenia';

  @override
  String get todayWork => 'Dzisiejsza praca';

  @override
  String get seeAll => 'Zobacz wszystko';

  @override
  String get loadMore => 'Załaduj więcej';

  @override
  String get jobTimerTitle => 'Stoper zlecenia';

  @override
  String get shiftTimerTitle => 'Stoper zmiany';

  @override
  String get workRecordNotFound => 'Nie znaleziono wpisu.';

  @override
  String get timerRecovered => 'Przywrócono aktywny stoper.';

  @override
  String get activeSessionExists => 'Inny stoper jest aktywny';

  @override
  String get activeSessionExistsDescription =>
      'Tylko jeden stoper może być aktywny jednocześnie.';

  @override
  String get openActiveWork => 'Otwórz aktywny stoper';

  @override
  String get openLabel => 'Otwórz';

  @override
  String get notStarted => 'Nie rozpoczęto';

  @override
  String get lastBillableTime => 'Ostatni płatny czas';

  @override
  String get onBreak => 'Na przerwie';

  @override
  String get timerRunning => 'Stoper działa';

  @override
  String get anotherTimerRunning => 'Działa inny stoper';

  @override
  String get clockIn => 'Rozpocznij (Clock In)';

  @override
  String get clockOut => 'Zakończ (Clock Out)';

  @override
  String get resumeWork => 'Wznów pracę';

  @override
  String get startBreak => 'Przerwa';

  @override
  String get chooseBreakType => 'Wybierz rodzaj przerwy';

  @override
  String get paidBreakDescription => 'Wlicza się do płatnego czasu.';

  @override
  String get unpaidBreak => 'Bezpłatna przerwa';

  @override
  String get unpaidBreakDescription => 'Odejmuje się od płatnego czasu.';

  @override
  String get clockOutConfirmTitle => 'Zakończyć pracę teraz?';

  @override
  String get clockOutConfirmDescription =>
      'Trwająca przerwa również zostanie zakończona.';

  @override
  String get timerActionFailed => 'Akcja stopera nie została zapisana.';

  @override
  String get timerLoadFailed => 'Nie udało się załadować stopera.';

  @override
  String get payRules => 'Zasady wynagrodzenia';

  @override
  String get payRulesDescription => 'Ustawienia nadgodzin i zaokrągleń';

  @override
  String get overtimeAfter => 'Nadgodziny po';

  @override
  String get overtimeMultiplier => 'Mnożnik nadgodzin';

  @override
  String get ratePremium => 'Premia do stawki';

  @override
  String get timeRounding => 'Zaokrąglanie czasu';

  @override
  String get hoursShort => 'godz.';

  @override
  String get daysShort => 'dni';

  @override
  String get minutesShort => 'min.';

  @override
  String get extraPay => 'Napiwki lub premia';

  @override
  String get plannedVsActual => 'Plan vs Rzeczywistość';

  @override
  String get plannedTime => 'Zaplanowany czas';

  @override
  String get actualTime => 'Rzeczywisty czas';

  @override
  String get nowLabel => 'Teraz';

  @override
  String get rawDuration => 'Całkowity czas';

  @override
  String get billableDuration => 'Płatny czas';

  @override
  String get earningsBreakdown => 'Rozliczenie wynagrodzenia';

  @override
  String get baseRate => 'Stawka podstawowa';

  @override
  String get regularPay => 'Wynagrodzenie podstawowe';

  @override
  String get overtimePay => 'Wynagrodzenie za nadgodziny';

  @override
  String get premiumPay => 'Wynagrodzenie z premią';

  @override
  String get fixedPay => 'Wynagrodzenie stałe';

  @override
  String get expectedTotal => 'Przewidywana suma';

  @override
  String get calculationSnapshotNote =>
      'Wartości są zapisywane po zakończeniu pracy.';

  @override
  String get recentSessions => 'Ostatnie sesje';

  @override
  String get completedSession => 'Zakończona sesja';

  @override
  String get correctTime => 'Popraw czas';

  @override
  String get corrected => 'Poprawiono';

  @override
  String get actualStart => 'Rzeczywisty początek';

  @override
  String get actualEnd => 'Rzeczywisty koniec';

  @override
  String get correctionReason => 'Powód poprawki';

  @override
  String get correctionReasonRequired => 'Wprowadź powód (min. 3 znaki).';

  @override
  String get correctionAuditNote => 'Powód pozostanie w historii zmian.';

  @override
  String get auditPaidBreakStarted => 'Rozpoczęto płatną przerwę';

  @override
  String get auditUnpaidBreakStarted => 'Rozpoczęto bezpłatną przerwę';

  @override
  String get auditTimeCorrected => 'Poprawiono czas';

  @override
  String get activeTimer => 'Aktywny stoper pracy';

  @override
  String get helpAndGuidance => 'Pomoc i instrukcja';

  @override
  String get sendFeedbackOnWhatsApp => 'Wyślij opinię przez WhatsApp';

  @override
  String whatsAppFeedbackSubtitle(String phoneNumber) {
    return 'Otwiera edytowalną wiadomość do $phoneNumber';
  }

  @override
  String get whatsAppFeedbackMessage =>
      'Cześć, zespole WorkProof, chcę przekazać opinię:';

  @override
  String get whatsAppFeedbackFailed =>
      'Nie udało się otworzyć WhatsApp. Spróbuj ponownie.';

  @override
  String get replayShowcase => 'Otwórz przewodnik';

  @override
  String get replayShowcaseDescription => 'Zobacz ponownie jak używać stopera.';

  @override
  String get showcaseBlockedByTimer =>
      'Zakończ stoper przed otwarciem przewodnika.';

  @override
  String get showcasePlanTitle => 'Rozpocznij od planu';

  @override
  String get showcaseWorkerPlanBody => 'Otwórz zaplanowaną zmianę.';

  @override
  String get showcaseTradesmanPlanBody => 'Otwórz zlecenie klienta.';

  @override
  String get showcaseBothPlanBody => 'Zmiany i zlecenia są rozdzielone.';

  @override
  String get showcaseClockInTitle => 'Kliknij Clock In gdy zaczynasz';

  @override
  String get showcaseClockInBody =>
      'Tylko jedno zlecenie może być aktywne naraz.';

  @override
  String get showcaseBreakTitle => 'Wybierz odpowiednią przerwę';

  @override
  String get showcaseBreakBody => 'Płatne przerwy wliczają się do czasu pracy.';

  @override
  String get showcaseClockOutTitle => 'Kliknij Clock Out gdy kończysz';

  @override
  String get showcaseClockOutBody =>
      'Zobaczysz podsumowanie czasu i wynagrodzenia.';

  @override
  String get showcaseProofTitle => 'Prowadź wiarygodne wpisy';

  @override
  String get showcaseProofBody =>
      'Korekty wymagają podania powodu. Końcowy czas i obliczenia wynagrodzenia są zapisywane w rejestrach pracy.';

  @override
  String get skipShowcase => 'Pomiń';

  @override
  String get nextLabel => 'Dalej';

  @override
  String get gotIt => 'Zrozumiano';

  @override
  String get appearanceTitle => 'Wygląd';

  @override
  String get workProfileTitle => 'Profil pracy';

  @override
  String get localProfile => 'Profil lokalny';

  @override
  String get countryCurrencyTitle => 'Kraj i waluta';

  @override
  String get languageLabel => 'Język';

  @override
  String get notificationsTitle => 'Powiadomienia';

  @override
  String get offlineNotificationsTitle => 'Przypomnienia i alerty o pracy';

  @override
  String get offlineNotificationsDescription =>
      'Czas, prywatność, cisza nocna i naprawa harmonogramu';

  @override
  String get dataTitle => 'Dane';

  @override
  String get localDataDescription => 'Konto ani internet nie są wymagane.';

  @override
  String get payProtectionGuide => 'Przewodnik weryfikacji wynagrodzenia';

  @override
  String get payProtectionGuideDescription =>
      'Sprawdź oczekiwane wynagrodzenie, paski płacowe, dokumenty pomocnicze i eksporty.';

  @override
  String get regionLanguageTitle => 'Region i język';

  @override
  String get localWorkspaceTitle => 'Dane na tym urządzeniu';

  @override
  String get localWorkspaceDescription =>
      'Zmień język i walutę bez konta i internetu.';

  @override
  String get appLanguageLabel => 'Język aplikacji';

  @override
  String get countryMarketLabel => 'Kraj lub region';

  @override
  String get defaultCurrencyLabel => 'Domyślna waluta';

  @override
  String get currencyHistoryNote =>
      'Zmiana domyślnej waluty nie przelicza starych wpisów. Każdy klient może mieć inną walutę rozliczeń.';

  @override
  String get savePreferences => 'Zapisz ustawienia';

  @override
  String get preferencesSaved => 'Ustawienia zapisane.';

  @override
  String get preferencesSaveFailed => 'Nie udało się zapisać ustawień.';

  @override
  String get m05PayProtection => 'Weryfikacja wynagrodzenia';

  @override
  String get m05WorkerPay => 'Moje wynagrodzenie';

  @override
  String get m05BusinessMoney => 'Przychody firmy';

  @override
  String get m05PayAtAGlance => 'Podsumowanie wynagrodzenia';

  @override
  String get m05StartAPayPeriod => 'Dodaj okres rozliczeniowy';

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
  String get m05AddEvidence => 'Dodaj dokument';

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
  String get m05CreatePayProtectionPeriod => 'Dodaj okres rozliczeniowy';

  @override
  String get m05ReviewEvidenceExport => 'Sprawdź wynagrodzenie i dokumenty';

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
  String get m05EvidenceTimeline => 'Dokumenty i notatki';

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
  String get payEvidencePacksTitle => 'Rejestry płac i eksporty';

  @override
  String get payEvidencePacksDescription =>
      'Otwieraj paski płacowe, dokumenty pomocnicze i eksporty PDF + ZIP w sekcji Wynagrodzenie i przychody.';

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
  String get evidenceEncryptionTitle => 'Chronione dokumenty';

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
  String get reportWorkerSummary => 'Podsumowanie wynagrodzenia';

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
  String get marketingStudioTitle => 'Twórz materiały promocyjne';

  @override
  String get marketingStudioSubtitle =>
      'Utwórz offline elegancki obraz promocyjny lub PDF, a następnie udostępnij go przez Facebook, WhatsApp, e-mail lub inną aplikację na urządzeniu.';

  @override
  String get marketingProfileTitle => 'Szczegóły promocji';

  @override
  String get marketingNameLabel => 'Nazwa firmy lub nazwa zawodowa';

  @override
  String get marketingHeadlineLabel => 'Nagłówek lub krótka wiadomość';

  @override
  String get marketingOfferLabel => 'Oferta lub promocja (opcjonalnie)';

  @override
  String get marketingServicesLabel => 'Usługi';

  @override
  String get marketingServicesHint => 'Wpisz jedną usługę w każdym wierszu';

  @override
  String get marketingServicesTitle => 'Nasze usługi';

  @override
  String get marketingWebsiteLabel =>
      'Strona internetowa lub profil społecznościowy';

  @override
  String get marketingTemplateLabel => 'Styl projektu';

  @override
  String get marketingTemplateProfessional => 'Profesjonalny';

  @override
  String get marketingTemplateBold => 'Wyrazisty';

  @override
  String get marketingTemplateElegant => 'Elegancki';

  @override
  String get marketingChooseLogo => 'Dodaj logo firmy';

  @override
  String get marketingRemoveLogo => 'Usuń logo';

  @override
  String get marketingChooseCoverPhoto => 'Dodaj zdjęcie firmowe';

  @override
  String get marketingRemoveCoverPhoto => 'Usuń zdjęcie firmowe';

  @override
  String get marketingPreview => 'Podgląd promocji na żywo';

  @override
  String get marketingSaveProfile => 'Zapisz szczegóły promocji';

  @override
  String get marketingProfileSaved =>
      'Szczegóły promocji zapisano na tym urządzeniu.';

  @override
  String get marketingCreateImage => 'Obraz';

  @override
  String get marketingCreatePdf => 'PDF';

  @override
  String get marketingCreating => 'Tworzenie…';

  @override
  String get marketingExportSaved =>
      'Materiał promocyjny zapisano. Wybierz aplikację, aby go udostępnić.';

  @override
  String get marketingExportFailed =>
      'Nie udało się utworzyć materiału promocyjnego.';

  @override
  String get marketingLogoFailed =>
      'Wybierz logo PNG, JPG lub WebP o rozmiarze do 12 MB.';

  @override
  String get marketingCoverPhotoFailed =>
      'Wybierz zdjęcie firmowe PNG, JPG lub WebP o rozmiarze do 12 MB.';

  @override
  String get marketingRequiredInfo => 'Dodaj wymagane informacje o promocji.';

  @override
  String get marketingContactRequired =>
      'Dodaj numer telefonu lub adres e-mail.';

  @override
  String get aboutWorkProof => 'O WorkProof';

  @override
  String get appInformationTitle => 'Informacje o aplikacji';

  @override
  String get aboutAppDescription =>
      'Działający przede wszystkim offline pomocnik do planowania zleceń i zmian, śledzenia czasu, sprawdzania wynagrodzenia oraz prowadzenia wiarygodnych rejestrów.';

  @override
  String get rateWorkProof => 'Oceń WorkProof';

  @override
  String get storeListingFailed =>
      'Nie udało się otworzyć sklepu z aplikacjami. Spróbuj ponownie.';

  @override
  String get appFeaturesTitle => 'Co możesz zrobić';

  @override
  String versionLabel(String version) {
    return 'Wersja $version';
  }

  @override
  String get versionUnavailable => 'Wersja niedostępna';

  @override
  String get featureDetails => 'Szczegóły funkcji';

  @override
  String get openFeature => 'Otwórz funkcję';

  @override
  String get featureWorkShortDescription =>
      'Twórz, planuj i obsługuj zlecenia klientów lub zmiany u pracodawcy.';

  @override
  String get featureWorkDescription =>
      'Porządkuj harmonogram, wycenę, przypomnienia i bieżący status każdego zlecenia lub zmiany.';

  @override
  String get featureTimeTrackingTitle => 'Śledzenie czasu';

  @override
  String get featureTimeTrackingShortDescription =>
      'Rejestruj rozpoczęcie i koniec pracy oraz przerwy, a także porównuj czas planowany z rzeczywistym.';

  @override
  String get featureTimeTrackingDescription =>
      'Śledź pracę offline jednym niezawodnym licznikiem, zapisuj płatne lub bezpłatne przerwy, korekty z uzasadnieniem i obliczenia wynagrodzenia.';

  @override
  String get featureContactsShortDescription =>
      'Porządkuj pracodawców, miejsca pracy, klientów i usługi.';

  @override
  String get featureContactsDescription =>
      'Zapisuj osoby, miejsca i usługi związane z pracą, aby szybciej tworzyć nowe zlecenia i zmiany.';

  @override
  String get featureCalendarShortDescription =>
      'Przeglądaj zlecenia i zmiany według daty oraz planuj kolejne zadania.';

  @override
  String get featureCalendarDescription =>
      'Przeglądaj kalendarz miesięczny i plan dnia, a następnie otwieraj lub dodawaj potrzebne zadania.';

  @override
  String get featurePayShortDescription =>
      'Sprawdzaj oczekiwane i otrzymane wynagrodzenie, przychody firmy oraz zaległe kwoty.';

  @override
  String get featurePayDescription =>
      'Porównuj okresy rozliczeniowe i paski płacowe albo przeglądaj faktury, płatności, wydatki i przychody z zapisanej pracy.';

  @override
  String get featureRecordsShortDescription =>
      'Przechowuj na urządzeniu przejrzystą historię ważnych działań związanych z pracą i wynagrodzeniem.';

  @override
  String get featureRecordsDescription =>
      'Przeglądaj zapisaną aktywność, dokumenty pomocnicze, korekty i eksporty, które wyjaśniają przebieg zdarzeń.';

  @override
  String get featureReportsShortDescription =>
      'Twórz raporty tygodniowe, miesięczne lub niestandardowe z zapisanych danych.';

  @override
  String get featureReportsDescription =>
      'Sprawdzaj podsumowania pracy, czasu, wynagrodzenia i firmy, a następnie eksportuj offline zestawienia PDF lub CSV.';

  @override
  String get featureRemindersShortDescription =>
      'Otrzymuj na urządzeniu alerty o nadchodzącej pracy, przerwach i planowanym czasie zakończenia.';

  @override
  String get featureRemindersDescription =>
      'Ustawiaj czas przypomnień, godziny ciszy, prywatność i podsumowania dnia bez połączenia z internetem.';

  @override
  String get featureBackupShortDescription =>
      'Twórz zaszyfrowane pliki kopii zapasowej i bezpiecznie przywracaj obszar roboczy.';

  @override
  String get featureBackupDescription =>
      'Chroń lokalne rejestry i dokumenty kopią zaszyfrowaną hasłem, która jest weryfikowana przed przywróceniem.';

  @override
  String get featureSecurityShortDescription =>
      'Chroń prywatne dane kodem PIN, biometrią i zaszyfrowanymi dokumentami.';

  @override
  String get featureSecurityDescription =>
      'Blokuj WorkProof, gdy odchodzisz od urządzenia, i przechowuj nowe pliki pomocnicze w zaszyfrowanej postaci.';

  @override
  String get featurePromotionsShortDescription =>
      'Twórz eleganckie obrazy promocyjne lub pliki PDF i udostępniaj je z urządzenia.';

  @override
  String get featurePromotionsDescription =>
      'Zapisz usługi, dane kontaktowe, logo, ofertę i styl projektu, aby offline tworzyć materiały promocyjne wielokrotnego użytku.';

  @override
  String get codeToolsTitle => 'Skanuj i twórz kody';

  @override
  String get codeToolsShortDescription =>
      'Skanuj kody QR i kreskowe albo twórz oraz udostępniaj własne.';

  @override
  String get codeToolsDescription =>
      'Używaj aparatu do odczytu obsługiwanych kodów lub generuj kody QR i kreskowe z tekstu całkowicie na swoim urządzeniu.';

  @override
  String get manageJobTitle => 'Zarządzaj zleceniem';

  @override
  String get manageJobDescription =>
      'Status · Koszty · Płatności · Dokumenty zlecenia';

  @override
  String get jobStatusTitle => 'Status zlecenia';

  @override
  String get costsAndPaymentsTitle => 'Koszty i płatności';

  @override
  String get jobDocumentsTitle => 'Dokumenty zlecenia';

  @override
  String get updateAvailableTitle => 'Dostępna jest nowa wersja';

  @override
  String get updateAvailableMessage =>
      'Dostępna jest nowa wersja WorkProof z ulepszeniami, poprawkami błędów i nowymi funkcjami.';

  @override
  String get updateRequiredMessage =>
      'Ta ważna aktualizacja jest wymagana, aby bezpiecznie kontynuować.';

  @override
  String get updateNow => 'Aktualizuj teraz';

  @override
  String get later => 'Później';

  @override
  String get checkingForUpdates => 'Sprawdzanie aktualizacji…';

  @override
  String get installingUpdate => 'Przygotowywanie aktualizacji…';

  @override
  String get updateDownloadReadyTitle => 'Aktualizacja jest gotowa';

  @override
  String get updateDownloadReadyMessage =>
      'Aktualizacja została pobrana. Uruchom ponownie WorkProof, aby dokończyć instalację.';

  @override
  String get restartToUpdate => 'Uruchom ponownie i zaktualizuj';

  @override
  String get updateFailed =>
      'Nie udało się ukończyć aktualizacji. Możesz nadal korzystać z WorkProof.';

  @override
  String get updateCheckFailed =>
      'Nie można teraz sprawdzić aktualizacji. Możesz normalnie korzystać z aplikacji.';

  @override
  String get latestVersionInstalled => 'Masz już najnowszą wersję.';

  @override
  String get checkForUpdates => 'Sprawdź aktualizacje';
}
