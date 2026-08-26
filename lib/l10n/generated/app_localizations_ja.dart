// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'WorkProof';

  @override
  String get tagline => '作業を記録し、給与を守り、証明を保管する。';

  @override
  String get loadingApp => 'ローカルワークスペースを開いています…';

  @override
  String get startupFailed => 'ローカルワークスペースを開くことができませんでした。';

  @override
  String get retry => '再試行';

  @override
  String get continueLabel => '次へ';

  @override
  String get backLabel => '戻る';

  @override
  String get finishSetup => 'セットアップ完了';

  @override
  String get skipSetup => '今はスキップ';

  @override
  String get skipOptional => '設定から後で変更できます。';

  @override
  String get onboardingTitle => 'WorkProof の設定';

  @override
  String get onboardingSubtitle => 'アカウントやインターネットは不要です。';

  @override
  String get languageTitle => '言語を選択してください';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get workModeTitle => 'どのような働き方ですか？';

  @override
  String get workerMode => '雇用主のもとで働く（従業員）';

  @override
  String get workerModeDescription => 'シフト、勤務時間、見込み給与、給与明細';

  @override
  String get tradesmanMode => '個人・顧客向けに働く（自営業）';

  @override
  String get tradesmanModeDescription => '案件、顧客管理、見積もり、請求書';

  @override
  String get bothMode => '両方行う';

  @override
  String get bothModeDescription => '従業員としての仕事と顧客の仕事を別々に管理';

  @override
  String get marketTitle => '勤務設定';

  @override
  String get countryLabel => '国';

  @override
  String get countryUnitedKingdom => 'イギリス';

  @override
  String get countryOther => 'その他 / 未掲載';

  @override
  String get currencyLabel => '通貨';

  @override
  String get professionLabel => '職種・ sector';

  @override
  String get professionHint => '例：建設、介護、清掃';

  @override
  String get professionRequired => '職種を入力してください';

  @override
  String get payMethodTitle => '通常の給与・請求方式';

  @override
  String get methodHourly => '時給';

  @override
  String get methodDaily => '日給';

  @override
  String get methodFixed => '固定給';

  @override
  String get methodMixed => '混合';

  @override
  String get defaultRateLabel => 'デフォルト単価（任意）';

  @override
  String get invalidRate => '有効な金額を入力してください（小数点以下2桁まで）';

  @override
  String get preferencesTitle => 'カスタマイズ';

  @override
  String get themeLabel => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get demoDataTitle => 'デモデータを読み込む';

  @override
  String get demoDataDescription => 'サンプルデータで使い方を確認できます。';

  @override
  String get privacySetupNote => '設定はこの端末のみに保存されます。';

  @override
  String get setupSaveFailed => '設定は保存されませんでした。';

  @override
  String get navHome => 'ホーム';

  @override
  String get navWork => '仕事';

  @override
  String get navMoney => '収支';

  @override
  String get navProof => '証明';

  @override
  String get navMore => 'その他';

  @override
  String get moneyTitle => '収支';

  @override
  String get moneyExpected => '予想収益';

  @override
  String get moneyTrackedTime => '記録時間';

  @override
  String get moneyCompletedEntries => '完了した記録';

  @override
  String get moneyEmpty => '完了した作業の収益がここに表示されます。';

  @override
  String get proofTitle => '証明';

  @override
  String get proofSubtitle => 'アクティビティ履歴';

  @override
  String get proofEmpty => 'このバージョンで記録されたアクティビティが表示されます。';

  @override
  String get savedOnDevice => '端末に保存済み';

  @override
  String get localOnlyStatus => 'ローカルのみ';

  @override
  String get auditOnboardingCompleted => 'WorkProof の設定が完了しました';

  @override
  String get auditCustomerCreated => '顧客を作成しました';

  @override
  String get auditJobCreated => '案件を作成しました';

  @override
  String get auditClockedIn => '出勤打刻';

  @override
  String get auditBreakStarted => '休憩開始';

  @override
  String get auditBreakEnded => '休憩終了';

  @override
  String get auditClockedOut => '退勤打刻';

  @override
  String get unknownActivity => 'アクティビティが記録されました';

  @override
  String get settings => '設定';

  @override
  String get profileModeWorker => '従業員モード';

  @override
  String get profileModeTradesman => '自営業モード';

  @override
  String get profileModeBoth => '複合モード';

  @override
  String get workTitle => '仕事';

  @override
  String get workerFlow => '雇用主の仕事';

  @override
  String get tradesmanFlow => '顧客の仕事';

  @override
  String get peopleTitle => '連絡先・サービス';

  @override
  String get calendarTitle => 'カレンダー';

  @override
  String get newShift => '新しいシフト';

  @override
  String get newJob => '新しい案件';

  @override
  String get editShift => 'シフト編集';

  @override
  String get editJob => '案件編集';

  @override
  String get searchShifts => 'シフトを検索…';

  @override
  String get searchJobs => '案件を検索…';

  @override
  String get searchPeople => '検索…';

  @override
  String get filterAll => 'すべて';

  @override
  String get statusScheduled => '予定あり';

  @override
  String get statusCompleted => '完了';

  @override
  String get noShifts => 'シフトが見つかりません。';

  @override
  String get noJobs => '案件が見つかりません。';

  @override
  String get workLoadFailed => '読み込めませんでした。';

  @override
  String get notScheduled => '予定なし';

  @override
  String get trackTime => '時間を記録';

  @override
  String get editLabel => '編集';

  @override
  String get deleteLabel => '削除';

  @override
  String get cancelLabel => 'キャンセル';

  @override
  String get saveLabel => '保存';

  @override
  String get addLabel => '追加';

  @override
  String get deleteWorkTitle => 'この記録を削除しますか？';

  @override
  String get deleteWorkDescription => 'リストから削除され、監査履歴に保管されます。';

  @override
  String get employers => '雇用主';

  @override
  String get workplaces => '勤務先';

  @override
  String get customers => '顧客';

  @override
  String get services => 'サービス';

  @override
  String get noEmployers => '雇用主が登録されていません。';

  @override
  String get noWorkplaces => '勤務先が登録されていません。';

  @override
  String get noCustomers => '顧客が登録されていません。';

  @override
  String get noServices => 'サービスが登録されていません。';

  @override
  String get noContactInfo => '連絡先情報がありません';

  @override
  String get peopleLoadFailed => '読み込めませんでした。';

  @override
  String get deleteRecordTitle => 'このレコードを削除しますか？';

  @override
  String get deleteRecordDescription => '関連する履歴は消去されません。';

  @override
  String get newEmployer => '新規雇用主';

  @override
  String get editEmployer => '雇用主編集';

  @override
  String get employerName => '雇用主・会社名';

  @override
  String get contactName => '担当者名';

  @override
  String get phoneLabel => '電話番号';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get paySchedule => '給与サイクル';

  @override
  String get contractNotes => '契約メモ';

  @override
  String get newWorkplace => '新規勤務先';

  @override
  String get editWorkplace => '勤務先編集';

  @override
  String get workplaceName => '勤務先名称';

  @override
  String get addressLabel => '住所';

  @override
  String get notesLabel => 'メモ';

  @override
  String get timeZoneLabel => 'タイムゾーン';

  @override
  String get newCustomer => '新規顧客';

  @override
  String get editCustomer => '顧客編集';

  @override
  String get customerName => '顧客名';

  @override
  String get newService => '新規サービス';

  @override
  String get editService => 'サービス編集';

  @override
  String get serviceName => 'サービス名';

  @override
  String get categoryLabel => 'カテゴリー';

  @override
  String get pricingLabel => '料金体系';

  @override
  String get durationMinutes => '標準時間（分）';

  @override
  String get descriptionLabel => '説明';

  @override
  String get requiredField => '必須項目です';

  @override
  String get saveFailed => '保存に失敗しました。';

  @override
  String get scheduleTitle => 'スケジュール';

  @override
  String get startLabel => '開始';

  @override
  String get endLabel => '終了';

  @override
  String get startUtcOffset => '開始 UTC オフセット';

  @override
  String get endUtcOffset => '終了 UTC オフセット';

  @override
  String get overnightLabel => '夜勤';

  @override
  String get invalidSchedule => '終了時間は開始時間より後に設定してください。';

  @override
  String get shiftTitleLabel => 'シフト名';

  @override
  String get employerOptional => '雇用主（任意）';

  @override
  String get workplaceOptional => '勤務先（任意）';

  @override
  String get hourlyRateOptional => '時給単価（任意）';

  @override
  String get dailyRateOptional => '日給単価（任意）';

  @override
  String get fixedPriceOptional => '固定料金（任意）';

  @override
  String get breakMinutes => '休憩時間（分）';

  @override
  String get paidBreak => '有給休憩';

  @override
  String get invalidNumber => '正の数値を入力してください';

  @override
  String get remindersEnabled => 'リマインダー有効';

  @override
  String get reminderIntentNote => 'このスケジュールに従って通知が届きます。';

  @override
  String get saveShift => 'シフトを保存';

  @override
  String get saveJob => '案件を保存';

  @override
  String get saveDraft => '下書き保存';

  @override
  String get draftSaved => '下書きを端末に保存しました。';

  @override
  String get jobTitleLabel => '案件名';

  @override
  String get serviceOptional => 'サービス（任意）';

  @override
  String get calendarLoadFailed => 'カレンダーを読み込めませんでした。';

  @override
  String get noWorkOnDate => 'この日の予定はありません。';

  @override
  String get dashboardTitle => 'ホーム';

  @override
  String get shiftsLabel => '今日のシフト';

  @override
  String get jobsLabel => '今日の案件';

  @override
  String get todayWork => '今日の仕事';

  @override
  String get seeAll => 'すべて見る';

  @override
  String get loadMore => 'さらに読み込む';

  @override
  String get jobTimerTitle => '案件タイマー';

  @override
  String get shiftTimerTitle => 'シフトタイマー';

  @override
  String get workRecordNotFound => '記録が見つかりませんでした。';

  @override
  String get timerRecovered => 'アクティブなタイマーを復元しました。';

  @override
  String get activeSessionExists => '他のタイマーが稼働中です';

  @override
  String get activeSessionExistsDescription => '一度に実行できるタイマーは1つです。';

  @override
  String get openActiveWork => 'アクティブな仕事を開く';

  @override
  String get openLabel => '開く';

  @override
  String get notStarted => '未開始';

  @override
  String get lastBillableTime => '最終集計時間';

  @override
  String get onBreak => '休憩中';

  @override
  String get timerRunning => '計測中';

  @override
  String get anotherTimerRunning => '別のタイマーが稼働中';

  @override
  String get clockIn => '出勤';

  @override
  String get clockOut => '退勤';

  @override
  String get resumeWork => '再開';

  @override
  String get startBreak => '休憩';

  @override
  String get chooseBreakType => '休憩の種類を選択';

  @override
  String get paidBreakDescription => '勤務時間にカウントされます。';

  @override
  String get unpaidBreak => '無給休憩';

  @override
  String get unpaidBreakDescription => '勤務時間から除外されます。';

  @override
  String get clockOutConfirmTitle => '退勤しますか？';

  @override
  String get clockOutConfirmDescription => '開始中の休憩も同時に終了します。';

  @override
  String get timerActionFailed => '操作の保存に失敗しました。';

  @override
  String get timerLoadFailed => '読み込めませんでした。';

  @override
  String get payRules => '給与/手当ルール';

  @override
  String get payRulesDescription => '残業や端数処理の設定';

  @override
  String get overtimeAfter => '残業適用時間';

  @override
  String get overtimeMultiplier => '残業倍率';

  @override
  String get ratePremium => '割増倍率';

  @override
  String get timeRounding => '時間切り上げ・切り捨て';

  @override
  String get hoursShort => '時間';

  @override
  String get daysShort => '日';

  @override
  String get minutesShort => '分';

  @override
  String get extraPay => '手当・ボーナス';

  @override
  String get plannedVsActual => '予定 vs 実績';

  @override
  String get plannedTime => '予定時間';

  @override
  String get actualTime => '実績時間';

  @override
  String get nowLabel => '現在';

  @override
  String get rawDuration => '実計測時間';

  @override
  String get billableDuration => '対象勤務時間';

  @override
  String get earningsBreakdown => '給与明細内訳';

  @override
  String get baseRate => '基本単価';

  @override
  String get regularPay => '基本給';

  @override
  String get overtimePay => '残業手当';

  @override
  String get premiumPay => '割増手当';

  @override
  String get fixedPay => '固定給';

  @override
  String get expectedTotal => '見込み合計';

  @override
  String get calculationSnapshotNote => '退勤時に計算スナップショットが保存されます。';

  @override
  String get recentSessions => '最近の履歴';

  @override
  String get completedSession => '完了したセッション';

  @override
  String get correctTime => '時間を修正';

  @override
  String get corrected => '修正済み';

  @override
  String get actualStart => '実際の開始';

  @override
  String get actualEnd => '実際の終了';

  @override
  String get correctionReason => '修正理由';

  @override
  String get correctionReasonRequired => '理由を3文字以上で入力してください。';

  @override
  String get correctionAuditNote => '理由は監査履歴に保管されます。';

  @override
  String get auditPaidBreakStarted => '有給休憩開始';

  @override
  String get auditUnpaidBreakStarted => '無給休憩開始';

  @override
  String get auditTimeCorrected => '打刻時間を修正';

  @override
  String get activeTimer => '計測中のタイマー';

  @override
  String get helpAndGuidance => 'ヘルプとガイド';

  @override
  String get replayShowcase => '使い方ガイドを再再生';

  @override
  String get replayShowcaseDescription => '打刻の手順をもう一度確認します。';

  @override
  String get showcaseBlockedByTimer => 'ガイドを開く前にタイマーを終了してください。';

  @override
  String get showcasePlanTitle => '仕事の予定から始めましょう';

  @override
  String get showcaseWorkerPlanBody => 'ホームやカレンダーからシフトを開きます。';

  @override
  String get showcaseTradesmanPlanBody => 'ホームやカレンダーから案件を開きます。';

  @override
  String get showcaseBothPlanBody => 'シフトと案件は別々に管理されます。';

  @override
  String get showcaseClockInTitle => '作業開始時に「出勤」';

  @override
  String get showcaseClockInBody => '一度に1つのタイマーのみ稼働できます。';

  @override
  String get showcaseBreakTitle => '適切な休憩を選択';

  @override
  String get showcaseBreakBody => '有給休憩は勤務時間にカウントされます。';

  @override
  String get showcaseClockOutTitle => '終了時に「退勤」';

  @override
  String get showcaseClockOutBody => '実績と給与の内訳を確認できます。';

  @override
  String get showcaseProofTitle => '信頼性の高い記録を保持';

  @override
  String get showcaseProofBody => '修正には理由の入力が必要です。';

  @override
  String get skipShowcase => 'スキップ';

  @override
  String get nextLabel => '次へ';

  @override
  String get gotIt => '了解';

  @override
  String get appearanceTitle => '外観';

  @override
  String get workProfileTitle => '仕事プロフィール';

  @override
  String get localProfile => 'ローカルプロフィール';

  @override
  String get countryCurrencyTitle => '国と通貨';

  @override
  String get languageLabel => '言語';

  @override
  String get notificationsTitle => '通知';

  @override
  String get offlineNotificationsTitle => 'オフライン通知と仕事アラート';

  @override
  String get offlineNotificationsDescription => '時刻、プライバシー、通知休止時間、予定の修復';

  @override
  String get dataTitle => 'データ';

  @override
  String get localDataDescription => 'アカウントもインターネットも必要ありません。';

  @override
  String get payProtectionGuide => '給与保護ガイド';

  @override
  String get payProtectionGuideDescription => '見込み給与、給与明細、証拠、エクスポートを確認';

  @override
  String get regionLanguageTitle => '地域と言語';

  @override
  String get localWorkspaceTitle => 'ローカルワークスペース';

  @override
  String get localWorkspaceDescription => 'アカウントやインターネットなしで言語と金額表示を変更できます。';

  @override
  String get appLanguageLabel => 'アプリの言語';

  @override
  String get countryMarketLabel => '国 / 市場';

  @override
  String get defaultCurrencyLabel => 'ワークスペースの既定通貨';

  @override
  String get currencyHistoryNote => '既定通貨を変更しても過去の記録は換算されません。顧客ごとに請求通貨を設定できます。';

  @override
  String get savePreferences => '設定を保存';

  @override
  String get preferencesSaved => '設定を保存しました。';

  @override
  String get preferencesSaveFailed => '設定を保存できませんでした。';

  @override
  String get m05PayProtection => 'Pay Protection';

  @override
  String get m05WorkerPay => 'Worker pay';

  @override
  String get m05BusinessMoney => 'Business money';

  @override
  String get m05PayAtAGlance => 'Pay at a glance';

  @override
  String get m05StartAPayPeriod => 'Start a pay period';

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
  String get m05AddEvidence => 'Add evidence';

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
  String get m05CreatePayProtectionPeriod => 'Create pay protection period';

  @override
  String get m05ReviewEvidenceExport => 'Review, evidence, export';

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
  String get m05EvidenceTimeline => 'Evidence timeline';

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
  String get payEvidencePacksTitle => 'Pay evidence packs';

  @override
  String get payEvidencePacksDescription =>
      'Open payslips, evidence and PDF + ZIP exports from Money';

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
  String get evidenceEncryptionTitle => 'Encrypted evidence';

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
  String get reportWorkerSummary => 'Worker pay summary';

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
  String get marketingStudioTitle => 'Marketing Studio';

  @override
  String get marketingStudioSubtitle =>
      'Create a premium promotion image or PDF offline, then share it with Facebook, WhatsApp, email or another device app.';

  @override
  String get marketingProfileTitle => 'Business or personal promotion';

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
  String get marketingTemplateLabel => 'Premium design';

  @override
  String get marketingTemplateProfessional => 'Professional';

  @override
  String get marketingTemplateBold => 'Bold';

  @override
  String get marketingTemplateElegant => 'Elegant';

  @override
  String get marketingChooseLogo => 'Add logo or photo';

  @override
  String get marketingRemoveLogo => 'Remove logo';

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
  String get marketingRequiredInfo => 'Add the required promotion information.';

  @override
  String get marketingContactRequired => 'Add a phone number or email address.';
}
