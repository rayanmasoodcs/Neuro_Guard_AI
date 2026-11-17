// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'NeuroGuard AI';

  @override
  String get appTagline => '人工智能驱动的癫痫发作监测系统';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get update => '更新';

  @override
  String get add => '添加';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get available => 'Available';

  @override
  String get search => '搜索';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get confirm => '确认';

  @override
  String get retry => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get noData => '无数据';

  @override
  String get errorOccurred => '发生错误';

  @override
  String get success => '成功';

  @override
  String get version => '版本 1.0.0';

  @override
  String get copyright => '© 2026 NeuroGuard AI';

  @override
  String get loginTitle => 'NeuroGuard AI';

  @override
  String get loginSubtitle => '人工智能驱动的癫痫发作监测系统';

  @override
  String get emailLabel => '电子邮箱';

  @override
  String get emailHint => '电子邮箱';

  @override
  String get passwordLabel => '密码';

  @override
  String get passwordHint => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get signupPrompt => '没有账户？';

  @override
  String get createAccount => '创建账户';

  @override
  String get orDivider => '或';

  @override
  String get continueWithGoogle => '使用 Google 继续';

  @override
  String get chooseAccount => '选择账户';

  @override
  String get toContinue => '继续使用 NeuroGuard AI';

  @override
  String get useAnotherAccount => '使用其他账户';

  @override
  String get fillAllFields => '请填写所有字段';

  @override
  String get loginSuccess => '登录成功！';

  @override
  String get roleConfigError => '角色配置错误';

  @override
  String get newPrompt => 'New?';

  @override
  String get registerPrompt => 'Register';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get allFieldsRequired => 'All fields are required';

  @override
  String get serverError => 'Server connection failure';

  @override
  String get signupTitle => '创建账户';

  @override
  String get fullNameLabel => '全名';

  @override
  String get ageLabel => '年龄';

  @override
  String get genderLabel => '性别';

  @override
  String get roleLabel => '角色';

  @override
  String get phoneLabel => '电话号码';

  @override
  String get confirmPasswordLabel => '确认密码';

  @override
  String get signupButton => '注册';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get loginPrompt => '登录';

  @override
  String get selectGender => '请选择您的性别以继续。';

  @override
  String get invalidEmail => '请输入有效的电子邮箱';

  @override
  String get invalidPassword => '密码需8位以上，包含大小写字母、数字和特殊字符';

  @override
  String get signupSuccess => '账户创建成功！';

  @override
  String get signupFailed => '注册失败';

  @override
  String get doctorRole => '医生';

  @override
  String get patientRole => '患者';

  @override
  String get selectRole => '选择角色';

  @override
  String get maleGender => '男';

  @override
  String get femaleGender => '女';

  @override
  String get otherGender => '其他';

  @override
  String get doctorDashboard => '医生控制台';

  @override
  String get patientDashboard => '患者控制台';

  @override
  String get bluetoothDevices => '蓝牙设备';

  @override
  String get notifications => '通知';

  @override
  String get homeNav => '首页';

  @override
  String get patientsNav => '患者';

  @override
  String get reportsNav => '报告';

  @override
  String get profileNav => '个人资料';

  @override
  String get remindersNav => '提醒';

  @override
  String get dashboardNav => '控制台';

  @override
  String get logout => '退出登录';

  @override
  String get logoutConfirmation => '退出确认';

  @override
  String get logoutMessage => '您确定要退出登录吗？';

  @override
  String get selectLanguage => '选择语言';

  @override
  String welcomeBack(String name) {
    return '欢迎回来，$name';
  }

  @override
  String get welcomeSubtitle => '监控患者和 AI 预测';

  @override
  String get todaysOverview => '今日概览';

  @override
  String get overviewDescription => 'NeuroGuard AI 持续实时监控 EEG 报告和紧急警报。';

  @override
  String get viewAiAnalysis => '查看 AI 分析';

  @override
  String get patientsStat => '患者';

  @override
  String get eegReportsStat => 'EEG 报告';

  @override
  String get emergencyStat => '紧急';

  @override
  String get aiAccuracyStat => 'AI 准确率';

  @override
  String get aiSummary => 'AI 摘要';

  @override
  String get aiPrediction => 'AI 预测';

  @override
  String get aiPredictionSubtitle => '未来几小时内未预测到高风险癫痫发作。';

  @override
  String get todaysAnalysis => '今日分析';

  @override
  String get todaysAnalysisSubtitle => '已成功处理 12 份 EEG 报告。';

  @override
  String get emergencyAlerts => '紧急警报';

  @override
  String emergencyAlertsSubtitle(int count) {
    return '$count 名患者需要立即检查。';
  }

  @override
  String get loadingAlerts => '加载警报中...';

  @override
  String get recentPatients => '近期患者';

  @override
  String get noPatientsYet => '暂无注册患者。';

  @override
  String get quickActions => '快捷操作';

  @override
  String get uploadEeg => '上传 EEG';

  @override
  String get alerts => '警报';

  @override
  String get medication => '药物';

  @override
  String get prescribeMedication => '开具处方';

  @override
  String get noMedicationsYet => '暂无处方药物。';

  @override
  String get noMedicationsLogged => '该患者无记录药物。';

  @override
  String get patientList => '患者列表';

  @override
  String get noPatientsMatch => '没有匹配的患者记录。';

  @override
  String get patientStatistics => '患者统计';

  @override
  String get total => '总计';

  @override
  String get critical => '危重';

  @override
  String get stable => '稳定';

  @override
  String get generalReview => '一般检查';

  @override
  String get needUrgentReview => '需要紧急检查';

  @override
  String get emergencyAlert => '紧急警报';

  @override
  String get observationRequired => '需要观察';

  @override
  String get addPatient => '添加患者';

  @override
  String get updatePatient => '更新';

  @override
  String get searchPatient => '搜索患者';

  @override
  String ageYears(String age) {
    return '年龄：$age';
  }

  @override
  String get years => '岁';

  @override
  String get statusStable => '稳定';

  @override
  String get statusEmergency => '紧急';

  @override
  String get statusCritical => '危重';

  @override
  String get statusObservation => '观察';

  @override
  String get managePatients => '管理、监控和检查所有已注册患者。';

  @override
  String get registerNewPatient => '注册新患者';

  @override
  String get patientIdLabel => '患者 ID（例如 01, 02）';

  @override
  String get medicalConditionLabel => '医疗状况';

  @override
  String get lastEegInfo => '最近 EEG 信息（例如今天、上月）';

  @override
  String get lastEegInfoUpdate => '更新 EEG 信息（例如今天、上月）';

  @override
  String get emailHintPatient => '电子邮箱';

  @override
  String get phoneHintPatient => '电话号码';

  @override
  String get residentialAddress => '居住地址';

  @override
  String get emergencyContactNumber => '紧急联系电话';

  @override
  String get additionalNotes => '补充说明 / 病史';

  @override
  String get savePatientProfile => '保存患者资料';

  @override
  String get updatePatientFile => '更新患者档案';

  @override
  String get targetPatientId => '目标患者 ID（定位档案）';

  @override
  String get updateInstructions => '只填写您要修改的字段。空白字段将保留原有记录。';

  @override
  String get commitProfileUpdates => '提交资料更新';

  @override
  String get registerFailed => '患者注册失败';

  @override
  String get selectCondition => '请选择医疗状况。';

  @override
  String get providePatientId => '请提供患者 ID 以识别档案。';

  @override
  String get notSpecified => '未指定';

  @override
  String get patientRecordTitle => '临床状态';

  @override
  String patientFileTitle(String id) {
    return '患者档案：$id';
  }

  @override
  String get clinicalStatus => '临床状态';

  @override
  String get medicalConditionDiagnostic => '医疗状况/诊断标签';

  @override
  String get noConditionFlagged => '未标记状况';

  @override
  String get latestEegAnalysis => '最新 EEG 分析摘要';

  @override
  String get noEegRecorded => '尚未记录 EEG 跟踪资料。';

  @override
  String get contactInformation => '联系信息';

  @override
  String get emailNotProvided => '未提供';

  @override
  String get mobileNumber => '手机号码';

  @override
  String get emergencySosContact => '紧急 SOS 联系';

  @override
  String get activeMedications => '当前用药';

  @override
  String get confidentialClinicalFile => 'NeuroGuard AI • 保密临床档案';

  @override
  String get doseLabel => '剂量';

  @override
  String get frequencyLabel => '频率';

  @override
  String get timingLabel => '时间';

  @override
  String get asDirected => '遵医嘱';

  @override
  String get reportSectionTitle => 'EEG 报告';

  @override
  String get reportSubtitle => '查看上传的 EEG 报告和 AI 生成的分析。';

  @override
  String get aiReportAnalysis => 'AI 报告分析';

  @override
  String get uploadEegPrompt => '上传 EEG 报告以获取癫痫发作预测和 AI 神经学洞察。';

  @override
  String get uploadEegButton => '上传 EEG 报告';

  @override
  String get recentReports => '近期报告';

  @override
  String get aiStatistics => 'AI 统计';

  @override
  String get reportsProcessed => '已处理报告';

  @override
  String get exportPdf => '导出 PDF';

  @override
  String get reportStatusNormal => '正常';

  @override
  String get reportStatusObservation => '观察';

  @override
  String get reportStatusEmergency => '紧急';

  @override
  String get reportsFooter => 'Reports';

  @override
  String get eegUploadTitle => 'EEG 分析与分类';

  @override
  String get eegUploadHeader => 'EEG 数据上传与 AI 分类';

  @override
  String get eegUploadDescription => '上传 EEG 数据以进行自动癫痫分类。支持格式：CSV、TXT、EDF。';

  @override
  String get chooseEegDataset => '选择 EEG 数据集';

  @override
  String get fileSelected => '已选择文件';

  @override
  String get analyzingEeg => '正在分析 EEG 数据...';

  @override
  String get runningAiModel => '正在运行 AI 分类模型';

  @override
  String get classificationResults => '分类结果';

  @override
  String get riskLevel => '风险等级';

  @override
  String get riskHigh => '高';

  @override
  String get eegPatternsDetected => '检测到的 EEG 模式';

  @override
  String get detailedAnalysis => '详细分析';

  @override
  String get additionalInformation => '附加信息';

  @override
  String get recommendedAction => '建议措施';

  @override
  String get medicalDisclaimerTitle => '医疗免责声明';

  @override
  String get medicalDisclaimerText =>
      '此 AI 分析仅供信息参考。请勿仅依赖这些结果做出医疗决定。请始终咨询合格的神经科医生进行诊断和治疗。';

  @override
  String get analysisComplete => '分析完成';

  @override
  String get analysisError => '分析错误';

  @override
  String get couldNotParse => '错误：无法解析文件中的 EEG 数据';

  @override
  String get doctorProfile => '医生资料';

  @override
  String get doctorProfileFooter => 'Doctor Profile';

  @override
  String get neurologist => '神经科医生';

  @override
  String get doctorId => '医生 ID';

  @override
  String get phone => '电话';

  @override
  String get emailAddress => '电子邮箱';

  @override
  String get editProfile => '编辑资料';

  @override
  String get changePassword => '修改密码';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get privacySecurity => '隐私与安全';

  @override
  String get passwordChanged => '密码更新成功';

  @override
  String get currentPassword => '当前密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get updatePassword => '更新密码';

  @override
  String get updatingPassword => '正在更新密码...';

  @override
  String get allPasswordFieldsRequired => '所有密码字段为必填';

  @override
  String get newPasswordMismatch => '新密码不匹配';

  @override
  String get errorResettingPassword => '重置密码出错';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get accountCoreCredentials => '账户核心信息';

  @override
  String get saveChanges => '保存更改';

  @override
  String get profileUpdated => '资料更新成功！';

  @override
  String get profileUpdateFailed => '资料更新失败。';

  @override
  String get emptyFieldsWarning => '所有字段为空。请至少输入一项进行更新。';

  @override
  String get allNotifications => '所有通知';

  @override
  String get allNotificationsDesc => '启用或禁用所有应用通知';

  @override
  String get alertPreferences => '提醒偏好';

  @override
  String get emailNotifications => '邮件通知';

  @override
  String get emailNotificationsDesc => '接收重要更新的邮件通知';

  @override
  String get appointmentAlerts => '预约通知';

  @override
  String get appointmentAlertsDesc => '接收预约安排提醒';

  @override
  String get reminderAlerts => '提醒通知';

  @override
  String get reminderAlertsDesc => '接收药物和任务提醒';

  @override
  String get saveNotifications => '保存设置';

  @override
  String get savingNotifications => '正在保存设置...';

  @override
  String get notificationsSaved => '通知设置保存成功！';

  @override
  String get notificationsSaveError => '保存通知设置出错';

  @override
  String get accountSecurity => '账户安全';

  @override
  String get accountSecurityDesc => '您的医疗数据受到安全访问控制保护。';

  @override
  String get securityPreferences => '安全偏好';

  @override
  String get profileVisibility => '资料可见性';

  @override
  String get profileVisibilityDesc => '控制谁可以查看您的医生资料';

  @override
  String get shareActivity => '共享活动';

  @override
  String get shareActivityDesc => '与同事共享您的临床活动';

  @override
  String get allowMessages => '允许消息';

  @override
  String get allowMessagesDesc => '允许患者向您发送直接消息';

  @override
  String get appLock => '应用锁定';

  @override
  String get appLockDesc => '打开应用时需要身份验证';

  @override
  String get saveSecuritySettings => '保存安全设置';

  @override
  String get savingSecuritySettings => '正在保存...';

  @override
  String get privacySaved => '隐私设置保存成功！';

  @override
  String get privacySaveError => '保存隐私设置出错';

  @override
  String get bluetoothTitle => '蓝牙设备';

  @override
  String get bluetoothStatus => '蓝牙状态';

  @override
  String get readyToScan => '准备扫描';

  @override
  String get bluetoothDisabled => '蓝牙已禁用';

  @override
  String get initializationFailed => '初始化失败';

  @override
  String get connectedDevice => '已连接设备';

  @override
  String get connected => '已连接';

  @override
  String get pairedDevices => '已配对设备';

  @override
  String get availableDevices => '可用设备';

  @override
  String get noDevicesFound => '未找到设备';

  @override
  String get tapToScan => '点击\"扫描\"搜索附近设备';

  @override
  String get startScan => '开始扫描';

  @override
  String get stopScanning => '停止扫描';

  @override
  String get bluetoothPermissionRequired => '需要蓝牙权限';

  @override
  String get enableBluetooth => '请启用蓝牙';

  @override
  String connectedTo(String device) {
    return '已连接到 $device';
  }

  @override
  String get disconnected => '已断开';

  @override
  String get deviceUnpaired => '设备已取消配对';

  @override
  String get initializing => '初始化中...';

  @override
  String get patientProfileTitle => '患者资料';

  @override
  String get patientProfileFooter => '患者资料';

  @override
  String get patientIdLabelProfile => '患者 ID';

  @override
  String welcomeBackPatient(String name) {
    return '欢迎回来，$name 👋';
  }

  @override
  String get stayHealthy => '保持健康，遵循您的治疗计划。';

  @override
  String get todaysHealthStatus => '今日健康状况';

  @override
  String get noSeizureRisk => '今日未检测到癫痫风险。请继续按时服药。';

  @override
  String get viewHealthReport => '查看健康报告';

  @override
  String get liveSensors => '实时传感器';

  @override
  String get chatWithAi => '与 AI 助手聊天';

  @override
  String get medicationReminder => '用药提醒';

  @override
  String get healthParameters => '健康参数';

  @override
  String get heartRate => '心率';

  @override
  String get temperature => '体温';

  @override
  String get o2Saturation => '血氧饱和度';

  @override
  String get motion => '运动';

  @override
  String get motionLow => '低';

  @override
  String get motionActivity => '活动';

  @override
  String get viewDetailedSensors => '查看详细传感器分析';

  @override
  String get emergencyContact => '紧急联系人';

  @override
  String get emergencyHelpline => '紧急热线';

  @override
  String get patientHomeFooter => 'Patients';

  @override
  String get remindersTitle => '提醒';

  @override
  String get remindersSubtitle => '管理您的用药和预约提醒。';

  @override
  String get reminderTitle => '提醒标题';

  @override
  String get reminderType => '提醒类型';

  @override
  String get reminderDate => '日期';

  @override
  String get reminderTime => '时间';

  @override
  String get addReminder => '添加提醒';

  @override
  String get saveReminder => '保存提醒';

  @override
  String get medicationType => '药物';

  @override
  String get pillType => '药片';

  @override
  String get appointmentType => '预约';

  @override
  String get doctorVisitType => '就诊';

  @override
  String get noRemindersYet => '暂无提醒。';

  @override
  String get addFirstReminder => '点击\"添加提醒\"设置您的第一个提醒。';

  @override
  String get viewMedicationTitle => '药物';

  @override
  String get patientMedicationsTitle => '我的药物';

  @override
  String get medicationNameLabel => '药物名称（例如 潘拿多）';

  @override
  String get medicationDoseLabel => '剂量（例如 500mg，2片）';

  @override
  String get medicationFrequencyLabel => '频率（例如 每日两次，每8小时）';

  @override
  String get medicationTimingLabel => '时间（例如 饭前，饭后）';

  @override
  String get takeWithLabel => '随服（例如 水，牛奶 - 默认为水）';

  @override
  String get instructionsLabel => '临床说明 / 特殊描述';

  @override
  String get savePrescription => '保存处方';

  @override
  String get medicationSaved => '处方记录成功！';

  @override
  String get medicationSaveFailed => '保存处方失败。';

  @override
  String get noMedications => '暂无处方药物。';

  @override
  String medicineDose(String dose, String frequency) {
    return '剂量：$dose • 频率：$frequency';
  }

  @override
  String get callTitle => '紧急呼叫';

  @override
  String get callPrompt => '您确定要呼叫紧急联系人吗？';

  @override
  String get calling => '正在呼叫...';

  @override
  String get chatbotTitle => 'AI 健康助手';

  @override
  String get chatbotSubtitle => '向我询问关于癫痫、药物和健康的问题。';

  @override
  String get typeMessage => '输入您的消息...';

  @override
  String get sendMessage => '发送';

  @override
  String get chatbotDisclaimer => '此聊天机器人仅提供教育信息。请始终咨询医生获取医疗建议。';

  @override
  String get realtimeSensorTitle => '实时传感器数据';

  @override
  String get realtimeSensorSubtitle => '从连接的传感器监控实时生理数据。';

  @override
  String get fallDetected => '检测到跌倒';

  @override
  String get fallSafe => '安全';

  @override
  String get sensorUpdated => '已更新';

  @override
  String get bpmUnit => '次/分钟';

  @override
  String get celsiusUnit => '°C';

  @override
  String get percentUnit => '%';

  @override
  String get healthReportTitle => '健康报告';

  @override
  String get healthReportSubtitle => '查看您的最新健康报告和分析。';

  @override
  String get healthReportSummary => '健康摘要';

  @override
  String get generateReport => '生成报告';

  @override
  String get medicalHistoryTitle => '病史';

  @override
  String get medicalHistorySubtitle => '查看您的完整病史和过往治疗。';

  @override
  String get pastRecords => '过往记录';

  @override
  String get noHistoryFound => '未找到病史记录。';

  @override
  String get predictionTitle => '癫痫预测';

  @override
  String get predictionSubtitle => 'AI 驱动的癫痫风险评估';

  @override
  String get seizureStatus => '癫痫状态';

  @override
  String get predictionConfidence => '预测置信度';

  @override
  String get predictionTime => '预测时间';

  @override
  String get viewDetails => '查看详情';

  @override
  String get analyzing => '分析中...';

  @override
  String get recentSeizureEvents => '近期癫痫事件';

  @override
  String get noSeizureEvents => '未记录癫痫事件';

  @override
  String get seizureEventsWillAppear => '近期癫痫事件将显示在此处';

  @override
  String get acknowledge => '确认';

  @override
  String get acknowledged => '已确认';

  @override
  String get acknowledgeSeizureEvent => '确认癫痫事件';

  @override
  String get eventAcknowledged => '事件确认成功';

  @override
  String get addDoctorNotes => '添加医生备注或药物调整';

  @override
  String get medicationAlertSent => '药物提醒已发送';

  @override
  String get appointmentAlertSent => '预约提醒已发送';

  @override
  String get refresh => '刷新';

  @override
  String get historyTitle => '历史记录';

  @override
  String get historySubtitle => '查看过往记录和临床历史。';

  @override
  String get exportPdfTitle => '导出报告为 PDF';

  @override
  String get exportPdfSubtitle => '生成并下载 PDF 报告。';

  @override
  String get exporting => '导出中...';

  @override
  String get exportComplete => 'PDF 导出完成';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get tomorrow => '明天';

  @override
  String get thisWeek => '本周';

  @override
  String get thisMonth => '本月';

  @override
  String get languageNameEn => '英语';

  @override
  String get languageNameEs => '西班牙语';

  @override
  String get languageNameUr => '乌尔都语';

  @override
  String get languageNameAr => '阿拉伯语';

  @override
  String get languageNameFr => '法语';

  @override
  String get languageNameDe => '德语';

  @override
  String get languageNameTr => '土耳其语';

  @override
  String get languageNameZh => '简体中文';

  @override
  String languageSwitched(String language) {
    return '语言已更改为$language';
  }

  @override
  String get clinicalStatus_observation => '观察中';

  @override
  String get clinicalStatus_stable => '稳定';

  @override
  String get clinicalStatus_critical => '危重';

  @override
  String get clinicalStatus_urgent => '需要紧急检查';

  @override
  String doseFormat(String dose) {
    return '剂量：$dose';
  }

  @override
  String get genderMale => '男';

  @override
  String get genderFemale => '女';

  @override
  String get genderOther => '其他';

  @override
  String genderAndAge(String gender, String age) {
    return '性别：$gender • 年龄：$age 岁';
  }

  @override
  String get seizureTypeUnknown => '未知癫痫';

  @override
  String get severityCritical => '危重';

  @override
  String get severityHigh => '高';

  @override
  String get severityMedium => '中';

  @override
  String get severityLow => '低';

  @override
  String get severityLabelCritical => '危重';

  @override
  String get severityLabelHigh => '高';

  @override
  String get severityLabelMedium => '中';

  @override
  String get severityLabelLow => '低';

  @override
  String get motionStatusMinimal => '极低';

  @override
  String get motionStatusLow => '低';

  @override
  String get motionStatusModerate => '中等';

  @override
  String get motionStatusHigh => '高';

  @override
  String get heartRateStatusNormal => '正常';

  @override
  String get heartRateStatusLow => '偏低';

  @override
  String get heartRateStatusHigh => '偏高';

  @override
  String get temperatureStatusNormal => '正常';

  @override
  String get temperatureStatusLow => '偏低';

  @override
  String get temperatureStatusHigh => '偏高';

  @override
  String labelNgaPrefix(String id) {
    return 'NGA-DR-$id';
  }

  @override
  String labelNgaPatient(String id) {
    return 'NGA-P$id';
  }

  @override
  String get uploadEegFormats => 'Supported formats: CSV, TXT, EDF, DAT';

  @override
  String get analyzeAllPatients => 'Analyze All Patients (Batch)';

  @override
  String get generateEegGraph => 'Generate EEG Graph';

  @override
  String get generatingEegGraph => 'Generating EEG graph...';

  @override
  String get eegGraphFailed => 'Failed to generate graph';

  @override
  String get exportReport => 'Export Report';

  @override
  String get exportBatchReport => 'Export Batch Report';

  @override
  String get reportGenerated => 'Report generated successfully!';

  @override
  String get reportFailed => 'Report generation failed';

  @override
  String get generatingReport => 'Generating report...';

  @override
  String get datasetReview => 'Dataset Review';

  @override
  String multiPatientDataset(int count) {
    return 'Multi-Patient Dataset — $count patients detected';
  }

  @override
  String batchResultsTitle(int count) {
    return 'Batch Results ($count Patients)';
  }

  @override
  String get tableHeaderPatient => '#';

  @override
  String get tableHeaderSeizureType => 'Seizure Type';

  @override
  String get tableHeaderConfidence => 'Confidence';

  @override
  String get tableHeaderRisk => 'Risk';

  @override
  String get tableHeaderRecommendation => 'Recommendation';

  @override
  String get tableHeaderGraph => 'Graph';

  @override
  String batchAnalysisComplete(int count) {
    return 'Batch complete: $count patients analyzed';
  }

  @override
  String get doctorChatbotTitle => 'Advanced Doctor Chatbot';

  @override
  String get doctorChatbotDisclaimer =>
      'CLINICAL DECISION SUPPORT ONLY: All recommendations must be verified against current evidence-based guidelines.';

  @override
  String get doctorChatbotHint => 'Type your clinical query...';

  @override
  String get doctorChatbotWelcome =>
      'Welcome Doctor. I am your Clinical Decision Support AI Assistant. How can I assist you today?';

  @override
  String get quickCommandGenerateReport => 'Generate Report';

  @override
  String get quickCommandExportPdf => 'Export PDF';

  @override
  String get quickCommandMedicationInfo => 'Medication Info';

  @override
  String get quickCommandEegGuidance => 'EEG Guidance';

  @override
  String get quickCommandSafetyGuidelines => 'Safety Guidelines';

  @override
  String get quickCommandPatientHistory => 'Patient History';

  @override
  String get quickCommandDiagnosticWorkup => 'Diagnostic Workup';

  @override
  String get quickCommandComorbidity => 'Comorbidity Management';

  @override
  String get patientUpdateTitle => 'Update Patient File';

  @override
  String get patientUpdateDriveId =>
      'Doctor identity not found. Please log in again.';
}
