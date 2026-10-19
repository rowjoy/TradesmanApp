// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'WorkProof';

  @override
  String get tagline => '记录您的工作。保护您的薪酬。留存您的凭证。';

  @override
  String get loadingApp => '正在打开本地工作区…';

  @override
  String get startupFailed => '无法打开您的本地工作区。';

  @override
  String get retry => '重试';

  @override
  String get continueLabel => '继续';

  @override
  String get backLabel => '返回';

  @override
  String get finishSetup => '完成设置';

  @override
  String get skipSetup => '暂时跳过';

  @override
  String get skipOptional => '您稍后可以在设置中进行更改。';

  @override
  String get onboardingTitle => '设置 WorkProof';

  @override
  String get onboardingSubtitle => '无需注册账号或连接网络。';

  @override
  String get languageTitle => '选择您的语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get workModeTitle => '您的工作方式是什么？';

  @override
  String get workerMode => '我为雇主工作（雇员）';

  @override
  String get workerModeDescription => '班次、工时、预期薪酬和工资单';

  @override
  String get tradesmanMode => '我为自己的客户工作（自雇/技工）';

  @override
  String get tradesmanModeDescription => '项目、客户、报价和发票';

  @override
  String get bothMode => '两者皆有';

  @override
  String get bothModeDescription => '将雇主工作与客户项目分开管理';

  @override
  String get marketTitle => '您的工作设置';

  @override
  String get countryLabel => '国家/地区';

  @override
  String get countryUnitedKingdom => '英国';

  @override
  String get countryOther => '其他 / 未列出';

  @override
  String get currencyLabel => '货币';

  @override
  String get professionLabel => '行业或职业';

  @override
  String get professionHint => '例如：建筑、护理、清洁';

  @override
  String get professionRequired => '请输入您的行业或职业';

  @override
  String get payMethodTitle => '常用计薪或收费方式';

  @override
  String get methodHourly => '按小时';

  @override
  String get methodDaily => '按天';

  @override
  String get methodFixed => '固定金额';

  @override
  String get methodMixed => '混合计费';

  @override
  String get defaultRateLabel => '默认费率（可选）';

  @override
  String get invalidRate => '请输入有效的金额（最多保留2位小数）';

  @override
  String get preferencesTitle => '个性化设置';

  @override
  String get themeLabel => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get demoDataTitle => '加载示例数据';

  @override
  String get demoDataDescription => '通过示例客户和项目体验工作流程。';

  @override
  String get privacySetupNote => '您的设置仅保存在此设备上。您可以在“设置”中创建加密备份文件。';

  @override
  String get setupSaveFailed => '设置未保存。';

  @override
  String get navHome => '首页';

  @override
  String get navWork => '工作';

  @override
  String get navMoney => '薪酬';

  @override
  String get navProof => '记录';

  @override
  String get navMore => '设置';

  @override
  String get moneyTitle => '薪酬与收入';

  @override
  String get moneyExpected => '预期收益';

  @override
  String get moneyTrackedTime => '已记录工时';

  @override
  String get moneyCompletedEntries => '已完成记录';

  @override
  String get moneyEmpty => '完成工作记录后，收益计算将显示在这里。';

  @override
  String get proofTitle => '工作记录';

  @override
  String get proofSubtitle => '保存在此设备上的活动';

  @override
  String get proofEmpty => '记录的操作活动将显示在这里。';

  @override
  String get savedOnDevice => '存储在此设备上';

  @override
  String get localOnlyStatus => '存储在此设备上';

  @override
  String get auditOnboardingCompleted => 'WorkProof 设置完成';

  @override
  String get auditCustomerCreated => '已创建客户';

  @override
  String get auditJobCreated => '已创建项目';

  @override
  String get auditClockedIn => '已上班打卡 (Clock In)';

  @override
  String get auditBreakStarted => '休息开始';

  @override
  String get auditBreakEnded => '休息结束';

  @override
  String get auditClockedOut => '已下班打卡 (Clock Out)';

  @override
  String get unknownActivity => '已记录工作活动';

  @override
  String get settings => '设置';

  @override
  String get profileModeWorker => '雇员模式';

  @override
  String get profileModeTradesman => '自雇模式';

  @override
  String get profileModeBoth => '混合模式';

  @override
  String get workTitle => '工作';

  @override
  String get workerFlow => '雇主工作';

  @override
  String get tradesmanFlow => '客户项目';

  @override
  String get peopleTitle => '联系人与服务';

  @override
  String get calendarTitle => '工作日历';

  @override
  String get newShift => '新建班次';

  @override
  String get newJob => '新建项目';

  @override
  String get editShift => '编辑班次';

  @override
  String get editJob => '编辑项目';

  @override
  String get searchShifts => '搜索班次…';

  @override
  String get searchJobs => '搜索项目…';

  @override
  String get searchPeople => '搜索名录…';

  @override
  String get filterAll => '全部';

  @override
  String get statusScheduled => '已计划';

  @override
  String get statusCompleted => '已完成';

  @override
  String get noShifts => '未找到班次。';

  @override
  String get noJobs => '未找到项目。';

  @override
  String get workLoadFailed => '无法加载工作记录。';

  @override
  String get notScheduled => '未排班';

  @override
  String get trackTime => '记录时间';

  @override
  String get editLabel => '编辑';

  @override
  String get deleteLabel => '删除';

  @override
  String get cancelLabel => '取消';

  @override
  String get saveLabel => '保存';

  @override
  String get addLabel => '添加';

  @override
  String get deleteWorkTitle => '确认删除此工作记录？';

  @override
  String get deleteWorkDescription => '它将从活动列表中移除。';

  @override
  String get employers => '雇主';

  @override
  String get workplaces => '工作地点';

  @override
  String get customers => '客户';

  @override
  String get services => '服务';

  @override
  String get noEmployers => '暂无雇主。';

  @override
  String get noWorkplaces => '暂无工作地点。';

  @override
  String get noCustomers => '暂无客户。';

  @override
  String get noServices => '暂无服务。';

  @override
  String get noContactInfo => '无联系信息';

  @override
  String get peopleLoadFailed => '无法加载此名录。';

  @override
  String get deleteRecordTitle => '确认删除记录？';

  @override
  String get deleteRecordDescription => '相关联的历史记录不会被静默抹去。';

  @override
  String get newEmployer => '新建雇主';

  @override
  String get editEmployer => '编辑雇主';

  @override
  String get employerName => '雇主/公司名称';

  @override
  String get contactName => '联系人姓名';

  @override
  String get phoneLabel => '电话';

  @override
  String get emailLabel => '邮箱';

  @override
  String get paySchedule => '发薪周期';

  @override
  String get contractNotes => '合同备注';

  @override
  String get newWorkplace => '新建工作地点';

  @override
  String get editWorkplace => '编辑工作地点';

  @override
  String get workplaceName => '工作地点名称';

  @override
  String get addressLabel => '地址';

  @override
  String get notesLabel => '备注';

  @override
  String get timeZoneLabel => '时区';

  @override
  String get newCustomer => '新建客户';

  @override
  String get editCustomer => '编辑客户';

  @override
  String get customerName => '客户姓名';

  @override
  String get newService => '新建服务';

  @override
  String get editService => '编辑服务';

  @override
  String get serviceName => '服务名称';

  @override
  String get categoryLabel => '类别';

  @override
  String get pricingLabel => '计费方式';

  @override
  String get durationMinutes => '默认时长（分钟）';

  @override
  String get descriptionLabel => '描述';

  @override
  String get requiredField => '此项为必填项';

  @override
  String get saveFailed => '保存失败。';

  @override
  String get scheduleTitle => '时间安排';

  @override
  String get startLabel => '开始';

  @override
  String get endLabel => '结束';

  @override
  String get startUtcOffset => '开始 UTC 偏移';

  @override
  String get endUtcOffset => '结束 UTC 偏移';

  @override
  String get overnightLabel => '通宵班';

  @override
  String get invalidSchedule => '结束时间必须晚于开始时间。';

  @override
  String get shiftTitleLabel => '班次名称';

  @override
  String get employerOptional => '雇主（可选）';

  @override
  String get workplaceOptional => '工作地点（可选）';

  @override
  String get hourlyRateOptional => '时薪（可选）';

  @override
  String get dailyRateOptional => '日薪（可选）';

  @override
  String get fixedPriceOptional => '固定价格（可选）';

  @override
  String get breakMinutes => '休息时长（分钟）';

  @override
  String get paidBreak => '有薪休息';

  @override
  String get invalidNumber => '请输入有效的非负数';

  @override
  String get remindersEnabled => '提醒已启用';

  @override
  String get reminderIntentNote => '离线提醒将遵循此时间安排。';

  @override
  String get saveShift => '保存班次';

  @override
  String get saveJob => '保存项目';

  @override
  String get saveDraft => '保存草稿';

  @override
  String get draftSaved => '草稿已保存在此设备。';

  @override
  String get jobTitleLabel => '项目名称';

  @override
  String get serviceOptional => '服务（可选）';

  @override
  String get calendarLoadFailed => '无法加载本月数据。';

  @override
  String get noWorkOnDate => '此日期无排班。';

  @override
  String get dashboardTitle => '首页';

  @override
  String get shiftsLabel => '今日班次';

  @override
  String get jobsLabel => '今日项目';

  @override
  String get todayWork => '今日工作';

  @override
  String get seeAll => '查看全部';

  @override
  String get loadMore => '加载更多';

  @override
  String get jobTimerTitle => '项目计时器';

  @override
  String get shiftTimerTitle => '班次计时器';

  @override
  String get workRecordNotFound => '未找到此工作记录。';

  @override
  String get timerRecovered => '已恢复活动计时器。';

  @override
  String get activeSessionExists => '另一个计时器正在运行';

  @override
  String get activeSessionExistsDescription => '同一时间只能运行一个计时器。';

  @override
  String get openActiveWork => '打开活动中的工作';

  @override
  String get openLabel => '打开';

  @override
  String get notStarted => '未开始';

  @override
  String get lastBillableTime => '上次计费时间';

  @override
  String get onBreak => '休息中';

  @override
  String get timerRunning => '计时中';

  @override
  String get anotherTimerRunning => '另一个计时器正在运行';

  @override
  String get clockIn => '上班打卡 (Clock In)';

  @override
  String get clockOut => '下班打卡 (Clock Out)';

  @override
  String get resumeWork => '恢复工作';

  @override
  String get startBreak => '休息';

  @override
  String get chooseBreakType => '选择休息类型';

  @override
  String get paidBreakDescription => '计入计费工作工时。';

  @override
  String get unpaidBreak => '无薪休息';

  @override
  String get unpaidBreakDescription => '从计费工作工时中扣除。';

  @override
  String get clockOutConfirmTitle => '确认现在下班打卡？';

  @override
  String get clockOutConfirmDescription => '进行中的休息也将同时结束。';

  @override
  String get timerActionFailed => '计时操作未保存。';

  @override
  String get timerLoadFailed => '无法加载此计时器。';

  @override
  String get payRules => '薪酬规则';

  @override
  String get payRulesDescription => '加班、补贴及舍入设置';

  @override
  String get overtimeAfter => '加班触发时长';

  @override
  String get overtimeMultiplier => '加班倍率';

  @override
  String get ratePremium => '津贴倍率';

  @override
  String get timeRounding => '工时舍入';

  @override
  String get hoursShort => '小时';

  @override
  String get daysShort => '天';

  @override
  String get minutesShort => '分';

  @override
  String get extraPay => '小费或奖金';

  @override
  String get plannedVsActual => '计划 vs 实际';

  @override
  String get plannedTime => '计划安排';

  @override
  String get actualTime => '实际打卡时间';

  @override
  String get nowLabel => '现在';

  @override
  String get rawDuration => '总时长';

  @override
  String get billableDuration => '计费时长';

  @override
  String get earningsBreakdown => '薪酬明细';

  @override
  String get baseRate => '基础费率';

  @override
  String get regularPay => '基本薪水';

  @override
  String get overtimePay => '加班费';

  @override
  String get premiumPay => '津贴薪水';

  @override
  String get fixedPay => '固定薪水';

  @override
  String get expectedTotal => '预期总额';

  @override
  String get calculationSnapshotNote => '下班打卡时将保存计算快照。';

  @override
  String get recentSessions => '近期记录';

  @override
  String get completedSession => '已完成工时';

  @override
  String get correctTime => '修正时间';

  @override
  String get corrected => '已修正';

  @override
  String get actualStart => '实际开始';

  @override
  String get actualEnd => '实际结束';

  @override
  String get correctionReason => '修正原因';

  @override
  String get correctionReasonRequired => '请输入至少3个字符的原因。';

  @override
  String get correctionAuditNote => '原因将保留在审计历史中。';

  @override
  String get auditPaidBreakStarted => '开始有薪休息';

  @override
  String get auditUnpaidBreakStarted => '开始无薪休息';

  @override
  String get auditTimeCorrected => '记录时间已修正';

  @override
  String get activeTimer => '活动工作计时器';

  @override
  String get helpAndGuidance => '帮助与指南';

  @override
  String get sendFeedbackOnWhatsApp => '通过WhatsApp发送反馈';

  @override
  String whatsAppFeedbackSubtitle(String phoneNumber) {
    return '打开可编辑的草稿，收件人为 $phoneNumber';
  }

  @override
  String get whatsAppFeedbackMessage => 'WorkProof团队，你们好，我想分享反馈：';

  @override
  String get whatsAppFeedbackFailed => '无法打开WhatsApp，请重试。';

  @override
  String get replayShowcase => '重播操作指南';

  @override
  String get replayShowcaseDescription => '重新查看打卡流程。';

  @override
  String get showcaseBlockedByTimer => '请先结束活动计时器再打开指南。';

  @override
  String get showcasePlanTitle => '从您的工作计划开始';

  @override
  String get showcaseWorkerPlanBody => '从首页或日历打开已安排的班次。';

  @override
  String get showcaseTradesmanPlanBody => '从首页或日历打开客户项目。';

  @override
  String get showcaseBothPlanBody => '班次和项目分开管理。';

  @override
  String get showcaseClockInTitle => '开始工作时打卡 (Clock In)';

  @override
  String get showcaseClockInBody => '同一时间只能运行一个计时器。';

  @override
  String get showcaseBreakTitle => '选择正确的休息类型';

  @override
  String get showcaseBreakBody => '有薪休息仍计入计费工时。';

  @override
  String get showcaseClockOutTitle => '结束工作时打卡 (Clock Out)';

  @override
  String get showcaseClockOutBody => '您将看到计划与实际时间的薪酬明细。';

  @override
  String get showcaseProofTitle => '保持可信的凭证记录';

  @override
  String get showcaseProofBody => '更正需要填写原因。最终的工作时间和薪酬计算会保存在“工作记录”中。';

  @override
  String get skipShowcase => '跳过指南';

  @override
  String get nextLabel => '下一步';

  @override
  String get gotIt => '知道了';

  @override
  String get appearanceTitle => '外观';

  @override
  String get workProfileTitle => '工作资料';

  @override
  String get localProfile => '本地资料';

  @override
  String get countryCurrencyTitle => '国家和货币';

  @override
  String get languageLabel => '语言';

  @override
  String get notificationsTitle => '通知';

  @override
  String get offlineNotificationsTitle => '工作提醒与通知';

  @override
  String get offlineNotificationsDescription => '时间、隐私、免打扰时段和日程修复';

  @override
  String get dataTitle => '数据';

  @override
  String get localDataDescription => '无需账户或网络。';

  @override
  String get payProtectionGuide => '薪酬核对指南';

  @override
  String get payProtectionGuideDescription => '核对预期薪酬、工资单、辅助文件和导出内容。';

  @override
  String get regionLanguageTitle => '地区和语言';

  @override
  String get localWorkspaceTitle => '此设备上的数据';

  @override
  String get localWorkspaceDescription => '无需账户或网络即可更改语言和金额显示。';

  @override
  String get appLanguageLabel => '应用语言';

  @override
  String get countryMarketLabel => '国家或地区';

  @override
  String get defaultCurrencyLabel => '默认货币';

  @override
  String get currencyHistoryNote => '更改默认货币不会换算旧记录。每位客户可以使用不同的结算货币。';

  @override
  String get savePreferences => '保存偏好';

  @override
  String get preferencesSaved => '偏好已保存。';

  @override
  String get preferencesSaveFailed => '无法保存偏好。';

  @override
  String get m05PayProtection => '薪酬核对';

  @override
  String get m05WorkerPay => '我的薪酬';

  @override
  String get m05BusinessMoney => '经营收入';

  @override
  String get m05PayAtAGlance => '薪酬摘要';

  @override
  String get m05StartAPayPeriod => '添加薪酬周期';

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
  String get m05AddEvidence => '添加文件';

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
  String get m05CreatePayProtectionPeriod => '添加薪酬周期';

  @override
  String get m05ReviewEvidenceExport => '核对薪酬与文件';

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
  String get m05EvidenceTimeline => '文件与备注';

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
  String get payEvidencePacksTitle => '薪酬记录与导出';

  @override
  String get payEvidencePacksDescription =>
      '从“薪酬与收入”中打开工资单、辅助文件以及PDF + ZIP导出内容。';

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
  String get evidenceEncryptionTitle => '受保护的文件';

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
  String get reportWorkerSummary => '薪酬摘要';

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
  String get marketingStudioTitle => '制作推广素材';

  @override
  String get marketingStudioSubtitle =>
      '离线制作精美的推广图片或PDF，然后通过Facebook、WhatsApp、电子邮件或设备上的其他应用分享。';

  @override
  String get marketingProfileTitle => '推广详情';

  @override
  String get marketingNameLabel => '公司或职业名称';

  @override
  String get marketingHeadlineLabel => '标题或简短信息';

  @override
  String get marketingOfferLabel => '优惠或促销（可选）';

  @override
  String get marketingServicesLabel => '服务';

  @override
  String get marketingServicesHint => '每行输入一项服务';

  @override
  String get marketingServicesTitle => '我们的服务';

  @override
  String get marketingWebsiteLabel => '网站或社交主页';

  @override
  String get marketingTemplateLabel => '设计风格';

  @override
  String get marketingTemplateProfessional => '专业';

  @override
  String get marketingTemplateBold => '醒目';

  @override
  String get marketingTemplateElegant => '优雅';

  @override
  String get marketingChooseLogo => '添加公司标志';

  @override
  String get marketingRemoveLogo => '移除标志';

  @override
  String get marketingChooseCoverPhoto => '添加业务照片';

  @override
  String get marketingRemoveCoverPhoto => '移除业务照片';

  @override
  String get marketingPreview => '实时预览推广素材';

  @override
  String get marketingSaveProfile => '保存推广详情';

  @override
  String get marketingProfileSaved => '推广详情已保存在此设备上。';

  @override
  String get marketingCreateImage => '图片';

  @override
  String get marketingCreatePdf => 'PDF';

  @override
  String get marketingCreating => '正在制作…';

  @override
  String get marketingExportSaved => '推广素材已保存。请选择一个应用进行分享。';

  @override
  String get marketingExportFailed => '无法制作推广素材。';

  @override
  String get marketingLogoFailed => '请选择不超过12 MB的PNG、JPG或WebP标志。';

  @override
  String get marketingCoverPhotoFailed => '请选择不超过12 MB的PNG、JPG或WebP业务照片。';

  @override
  String get marketingRequiredInfo => '请填写推广所需的信息。';

  @override
  String get marketingContactRequired => '请添加电话号码或电子邮件地址。';

  @override
  String get aboutWorkProof => '关于WorkProof';

  @override
  String get appInformationTitle => '应用信息';

  @override
  String get aboutAppDescription =>
      '一款以离线使用为先的工作助手，可用于安排工作和班次、记录时间、核对薪酬并保存可靠记录。';

  @override
  String get rateWorkProof => '为 WorkProof 评分';

  @override
  String get storeListingFailed => '无法打开应用商店。请重试。';

  @override
  String get appFeaturesTitle => '您可以做什么';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get versionUnavailable => '无法获取版本信息';

  @override
  String get featureDetails => '功能详情';

  @override
  String get openFeature => '打开功能';

  @override
  String get featureWorkShortDescription => '创建、安排和管理客户工作或雇主班次。';

  @override
  String get featureWorkDescription => '集中整理每项工作或班次的时间安排、定价、提醒和当前状态。';

  @override
  String get featureTimeTrackingTitle => '时间记录';

  @override
  String get featureTimeTrackingShortDescription => '记录上下班和休息时间，并比较计划时间与实际时间。';

  @override
  String get featureTimeTrackingDescription =>
      '使用一个可靠的计时器离线记录工作，包括带薪或无薪休息、带原因的更正以及保存的收入计算。';

  @override
  String get featureContactsShortDescription => '整理雇主、工作地点、客户和服务。';

  @override
  String get featureContactsDescription => '保存与工作相关的人员、地点和服务，以便更快创建新的工作和班次。';

  @override
  String get featureCalendarShortDescription => '按日期查看工作和班次，并规划接下来的安排。';

  @override
  String get featureCalendarDescription => '浏览月历和每日安排，然后打开或添加所需的工作。';

  @override
  String get featurePayShortDescription => '核对预期薪酬、实收薪酬、经营收入和未结金额。';

  @override
  String get featurePayDescription => '比较薪酬周期与工资单，或查看已保存工作的发票、收款、支出和收入。';

  @override
  String get featureRecordsShortDescription => '在设备上清晰保存重要的工作和薪酬活动历史。';

  @override
  String get featureRecordsDescription => '查看已保存的活动、辅助文件、更正和导出内容，帮助说明发生过什么。';

  @override
  String get featureReportsShortDescription => '根据保存的记录制作周报、月报或自定义报告。';

  @override
  String get featureReportsDescription => '查看工作、时间、薪酬和经营汇总，然后离线导出PDF或CSV报表。';

  @override
  String get featureRemindersShortDescription => '在设备上接收即将开始的工作、休息和计划结束时间提醒。';

  @override
  String get featureRemindersDescription => '无需互联网连接即可选择提醒时间、免打扰时段、隐私设置和每日摘要。';

  @override
  String get featureBackupShortDescription => '创建加密备份文件，并安全恢复您的工作区。';

  @override
  String get featureBackupDescription => '使用密码加密且会在恢复前验证的备份来保护本地记录和文件。';

  @override
  String get featureSecurityShortDescription => '使用PIN、生物识别和加密文件保护私人记录。';

  @override
  String get featureSecurityDescription =>
      '离开设备时锁定WorkProof，并将新的辅助文件加密保存在此设备上。';

  @override
  String get featurePromotionsShortDescription => '制作精美的推广图片或PDF，并从设备上分享。';

  @override
  String get featurePromotionsDescription =>
      '保存服务、联系方式、标志、优惠和设计风格，离线制作可重复使用的推广素材。';

  @override
  String get codeToolsTitle => '扫描和创建代码';

  @override
  String get codeToolsShortDescription => '扫描二维码和条形码，或创建并分享自己的代码。';

  @override
  String get codeToolsDescription => '使用相机读取支持的代码，或完全在设备上将文本生成二维码和条形码。';

  @override
  String get manageJobTitle => '管理工作';

  @override
  String get manageJobDescription => '状态 · 成本 · 收款 · 工作文件';

  @override
  String get jobStatusTitle => '工作状态';

  @override
  String get costsAndPaymentsTitle => '成本与收款';

  @override
  String get jobDocumentsTitle => '工作文件';

  @override
  String get updateAvailableTitle => '有新版本可用';

  @override
  String get updateAvailableMessage => 'WorkProof有新版本可用，其中包含改进、错误修复和新功能。';

  @override
  String get updateRequiredMessage => '为了安全地继续使用，您必须安装此重要更新。';

  @override
  String get updateNow => '立即更新';

  @override
  String get later => '稍后';

  @override
  String get checkingForUpdates => '正在检查更新…';

  @override
  String get installingUpdate => '正在准备更新…';

  @override
  String get updateDownloadReadyTitle => '更新已就绪';

  @override
  String get updateDownloadReadyMessage => '更新已下载。请重新启动WorkProof以完成安装。';

  @override
  String get restartToUpdate => '重新启动并更新';

  @override
  String get updateFailed => '无法完成更新。您可以继续使用WorkProof。';

  @override
  String get updateCheckFailed => '目前无法检查更新。您可以继续正常使用。';

  @override
  String get latestVersionInstalled => '您已经安装了最新版本。';

  @override
  String get checkForUpdates => '检查更新';
}
