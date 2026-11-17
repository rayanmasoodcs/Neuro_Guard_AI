// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'NeuroGuard AI';

  @override
  String get appTagline => 'Yapay Zeka Destekli Epilepsi Nöbet İzleme Sistemi';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get update => 'Güncelle';

  @override
  String get add => 'Ekle';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get available => 'Available';

  @override
  String get search => 'Ara';

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get next => 'İleri';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get confirm => 'Onayla';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get noData => 'Veri yok';

  @override
  String get errorOccurred => 'Bir hata oluştu';

  @override
  String get success => 'Başarılı';

  @override
  String get version => 'Sürüm 1.0.0';

  @override
  String get copyright => '© 2026 NeuroGuard AI';

  @override
  String get loginTitle => 'NeuroGuard AI';

  @override
  String get loginSubtitle =>
      'Yapay Zeka Destekli Epilepsi Nöbet İzleme Sistemi';

  @override
  String get emailLabel => 'E-posta Adresi';

  @override
  String get emailHint => 'E-posta Adresi';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordHint => 'Şifre';

  @override
  String get loginButton => 'GİRİŞ YAP';

  @override
  String get forgotPassword => 'Şifrenizi mi Unuttunuz?';

  @override
  String get signupPrompt => 'Hesabınız yok mu?';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get orDivider => 'VEYA';

  @override
  String get continueWithGoogle => 'Google ile Devam Et';

  @override
  String get chooseAccount => 'Hesap Seçin';

  @override
  String get toContinue => 'NeuroGuard AI\'ya devam etmek için';

  @override
  String get useAnotherAccount => 'Başka Hesap Kullan';

  @override
  String get fillAllFields => 'Lütfen tüm alanları doldurun';

  @override
  String get loginSuccess => 'Başarıyla giriş yapıldı!';

  @override
  String get roleConfigError => 'Rol yapılandırma hatası';

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
  String get signupTitle => 'Hesap Oluştur';

  @override
  String get fullNameLabel => 'Ad Soyad';

  @override
  String get ageLabel => 'Yaş';

  @override
  String get genderLabel => 'Cinsiyet';

  @override
  String get roleLabel => 'Rol';

  @override
  String get phoneLabel => 'Telefon Numarası';

  @override
  String get confirmPasswordLabel => 'Şifreyi Onayla';

  @override
  String get signupButton => 'KAYIT OL';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get loginPrompt => 'Giriş Yap';

  @override
  String get selectGender => 'Devam etmek için lütfen cinsiyetinizi seçin.';

  @override
  String get invalidEmail => 'Geçerli bir e-posta adresi girin';

  @override
  String get invalidPassword =>
      'Şifre 8+ karakter, büyük harf, küçük harf, rakam ve özel karakter içermelidir';

  @override
  String get signupSuccess => 'Hesap başarıyla oluşturuldu!';

  @override
  String get signupFailed => 'Kayıt başarısız';

  @override
  String get doctorRole => 'Doktor';

  @override
  String get patientRole => 'Hasta';

  @override
  String get selectRole => 'Rol Seçin';

  @override
  String get maleGender => 'Erkek';

  @override
  String get femaleGender => 'Kadın';

  @override
  String get otherGender => 'Diğer';

  @override
  String get doctorDashboard => 'Doktor Paneli';

  @override
  String get patientDashboard => 'Hasta Paneli';

  @override
  String get bluetoothDevices => 'Bluetooth Cihazları';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get homeNav => 'Ana Sayfa';

  @override
  String get patientsNav => 'Hastalar';

  @override
  String get reportsNav => 'Raporlar';

  @override
  String get profileNav => 'Profil';

  @override
  String get remindersNav => 'Hatırlatıcılar';

  @override
  String get dashboardNav => 'Panel';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirmation => 'Çıkış Onayı';

  @override
  String get logoutMessage =>
      'Profilinizden çıkış yapmak istediğinize emin misiniz?';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String welcomeBack(String name) {
    return 'Tekrar Hoş Geldiniz, $name';
  }

  @override
  String get welcomeSubtitle => 'Hastaları ve yapay zeka tahminlerini izleyin';

  @override
  String get todaysOverview => 'Bugünün Özeti';

  @override
  String get overviewDescription =>
      'NeuroGuard AI, EEG raporlarını ve acil durum uyarılarını gerçek zamanlı olarak sürekli izler.';

  @override
  String get viewAiAnalysis => 'YZ Analizini Görüntüle';

  @override
  String get patientsStat => 'Hastalar';

  @override
  String get eegReportsStat => 'EEG Raporları';

  @override
  String get emergencyStat => 'Acil Durum';

  @override
  String get aiAccuracyStat => 'YZ Doğruluğu';

  @override
  String get aiSummary => 'YZ Özeti';

  @override
  String get aiPrediction => 'YZ Tahmini';

  @override
  String get aiPredictionSubtitle =>
      'Önümüzdeki saatlerde yüksek riskli nöbet tahmin edilmemektedir.';

  @override
  String get todaysAnalysis => 'Bugünün Analizi';

  @override
  String get todaysAnalysisSubtitle => '12 EEG raporu başarıyla işlendi.';

  @override
  String get emergencyAlerts => 'Acil Durum Uyarıları';

  @override
  String emergencyAlertsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hasta acil inceleme gerektiriyor.',
      one: '1 hasta acil inceleme gerektiriyor.',
    );
    return '$_temp0';
  }

  @override
  String get loadingAlerts => 'Uyarılar yükleniyor...';

  @override
  String get recentPatients => 'Son Hastalar';

  @override
  String get noPatientsYet => 'Henüz kayıtlı hasta yok.';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get uploadEeg => 'EEG Yükle';

  @override
  String get alerts => 'Uyarılar';

  @override
  String get medication => 'İlaç';

  @override
  String get prescribeMedication => 'İlaç Reçete Et';

  @override
  String get noMedicationsYet => 'Henüz reçete edilmiş ilaç yok.';

  @override
  String get noMedicationsLogged => 'Bu hasta için kayıtlı ilaç yok.';

  @override
  String get patientList => 'Hasta Listesi';

  @override
  String get noPatientsMatch => 'Kriterlere uyan hasta kaydı yok.';

  @override
  String get patientStatistics => 'Hasta İstatistikleri';

  @override
  String get total => 'Toplam';

  @override
  String get critical => 'Kritik';

  @override
  String get stable => 'Stabil';

  @override
  String get generalReview => 'Genel İnceleme';

  @override
  String get needUrgentReview => 'Acil İnceleme Gerekli';

  @override
  String get emergencyAlert => 'Acil Durum Uyarısı';

  @override
  String get observationRequired => 'Gözlem Gerekli';

  @override
  String get addPatient => 'Hasta Ekle';

  @override
  String get updatePatient => 'Güncelle';

  @override
  String get searchPatient => 'Hasta Ara';

  @override
  String ageYears(String age) {
    return 'Yaş: $age';
  }

  @override
  String get years => 'Yaş';

  @override
  String get statusStable => 'Stabil';

  @override
  String get statusEmergency => 'Acil';

  @override
  String get statusCritical => 'Kritik';

  @override
  String get statusObservation => 'Gözlem';

  @override
  String get managePatients =>
      'Tüm kayıtlı hastaları yönetin, izleyin ve inceleyin.';

  @override
  String get registerNewPatient => 'Yeni Hasta Kaydet';

  @override
  String get patientIdLabel => 'Hasta ID (örn. 01, 02)';

  @override
  String get medicalConditionLabel => 'Tıbbi Durum';

  @override
  String get lastEegInfo => 'Son EEG Bilgisi (örn. bugün, geçen ay)';

  @override
  String get lastEegInfoUpdate =>
      'Last EEG Info Update (e.g. today, last month)';

  @override
  String get emailHintPatient => 'E-posta Adresi';

  @override
  String get phoneHintPatient => 'Telefon Numarası';

  @override
  String get residentialAddress => 'İkamet Adresi';

  @override
  String get emergencyContactNumber => 'Acil Durum İletişim Numarası';

  @override
  String get additionalNotes => 'Ek Notlar / Geçmiş';

  @override
  String get savePatientProfile => 'Hasta Profilini Kaydet';

  @override
  String get updatePatientFile => 'Hasta Dosyasını Güncelle';

  @override
  String get targetPatientId => 'Hedef Hasta ID (Dosyayı Bul)';

  @override
  String get updateInstructions =>
      'Yalnızca değiştirmek istediğiniz alanları doldurun. Boş alanlar önceki kayıtları değiştirmez.';

  @override
  String get commitProfileUpdates => 'Profil Güncellemelerini Onayla';

  @override
  String get registerFailed => 'Hasta kaydı başarısız';

  @override
  String get selectCondition => 'Lütfen bir tıbbi durum seçin.';

  @override
  String get providePatientId =>
      'Dosyayı tanımlamak için lütfen bir Hasta ID girin.';

  @override
  String get notSpecified => 'Belirtilmedi';

  @override
  String get patientRecordTitle => 'Klinik Durum';

  @override
  String patientFileTitle(String id) {
    return 'Hasta Dosyası: $id';
  }

  @override
  String get clinicalStatus => 'Klinik Durum';

  @override
  String get medicalConditionDiagnostic => 'Tıbbi Durum/Tanı Etiketi';

  @override
  String get noConditionFlagged => 'İşaretlenmiş durum yok';

  @override
  String get latestEegAnalysis => 'Son EEG Analiz Özeti';

  @override
  String get noEegRecorded => 'Henüz EEG takip profili kaydedilmedi.';

  @override
  String get contactInformation => 'İletişim Bilgileri';

  @override
  String get emailNotProvided => 'Belirtilmedi';

  @override
  String get mobileNumber => 'Cep Numarası';

  @override
  String get emergencySosContact => 'Acil SOS İletişim';

  @override
  String get activeMedications => 'Aktif İlaçlar';

  @override
  String get confidentialClinicalFile => 'NeuroGuard AI • Gizli Klinik Dosya';

  @override
  String get doseLabel => 'Doz';

  @override
  String get frequencyLabel => 'Sıklık';

  @override
  String get timingLabel => 'Zamanlama';

  @override
  String get asDirected => 'Talimatlara göre';

  @override
  String get reportSectionTitle => 'EEG Raporları';

  @override
  String get reportSubtitle =>
      'Yüklenen EEG raporlarını ve YZ analizini inceleyin.';

  @override
  String get aiReportAnalysis => 'YZ Rapor Analizi';

  @override
  String get uploadEegPrompt =>
      'Nöbet tahmini ve YZ nörolojik bilgiler için EEG raporu yükleyin.';

  @override
  String get uploadEegButton => 'EEG Raporu Yükle';

  @override
  String get recentReports => 'Son Raporlar';

  @override
  String get aiStatistics => 'YZ İstatistikleri';

  @override
  String get reportsProcessed => 'İşlenen Raporlar';

  @override
  String get exportPdf => 'PDF Dışa Aktar';

  @override
  String get reportStatusNormal => 'Normal';

  @override
  String get reportStatusObservation => 'Gözlem';

  @override
  String get reportStatusEmergency => 'Acil';

  @override
  String get reportsFooter => 'Reports';

  @override
  String get eegUploadTitle => 'EEG Analizi ve Sınıflandırma';

  @override
  String get eegUploadHeader => 'EEG Veri Yükleme ve YZ Sınıflandırma';

  @override
  String get eegUploadDescription =>
      'Otomatik nöbet sınıflandırması için EEG verileri yükleyin. Formatlar: CSV, TXT, EDF.';

  @override
  String get chooseEegDataset => 'EEG Veri Seti Seç';

  @override
  String get fileSelected => 'Dosya Seçildi';

  @override
  String get analyzingEeg => 'EEG Verileri Analiz Ediliyor...';

  @override
  String get runningAiModel => 'YZ sınıflandırma modeli çalışıyor';

  @override
  String get classificationResults => 'Sınıflandırma Sonuçları';

  @override
  String get riskLevel => 'Risk Seviyesi';

  @override
  String get riskHigh => 'Yüksek';

  @override
  String get eegPatternsDetected => 'Tespit Edilen EEG Desenleri';

  @override
  String get detailedAnalysis => 'Detaylı Analiz';

  @override
  String get additionalInformation => 'Ek Bilgiler';

  @override
  String get recommendedAction => 'Önerilen Eylem';

  @override
  String get medicalDisclaimerTitle => 'Tıbbi Uyarı';

  @override
  String get medicalDisclaimerText =>
      'Bu YZ analizi yalnızca bilgilendirme amaçlıdır. Tıbbi kararlar için yalnızca bu sonuçlara güvenmeyin. Teşhis ve tedavi için daima kalifiye bir nöroloğa danışın.';

  @override
  String get analysisComplete => 'Analiz tamamlandı';

  @override
  String get analysisError => 'Analiz hatası';

  @override
  String get couldNotParse => 'Hata: EEG verileri ayrıştırılamadı';

  @override
  String get doctorProfile => 'Doktor Profili';

  @override
  String get doctorProfileFooter => 'Doctor Profile';

  @override
  String get neurologist => 'Nörolog';

  @override
  String get doctorId => 'Doktor ID';

  @override
  String get phone => 'Telefon';

  @override
  String get emailAddress => 'E-posta Adresi';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get notificationSettings => 'Bildirim Ayarları';

  @override
  String get privacySecurity => 'Gizlilik ve Güvenlik';

  @override
  String get passwordChanged => 'Şifre başarıyla güncellendi';

  @override
  String get currentPassword => 'Mevcut Şifre';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get updatePassword => 'Şifreyi Güncelle';

  @override
  String get updatingPassword => 'Şifre Güncelleniyor...';

  @override
  String get allPasswordFieldsRequired => 'Tüm şifre alanları zorunludur';

  @override
  String get newPasswordMismatch => 'Yeni şifreler eşleşmiyor';

  @override
  String get errorResettingPassword => 'Şifre sıfırlama hatası';

  @override
  String get connectionFailed => 'Bağlantı başarısız';

  @override
  String get accountCoreCredentials => 'Hesap Temel Bilgileri';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get profileUpdated => 'Profil başarıyla güncellendi!';

  @override
  String get profileUpdateFailed => 'Profil güncellemesi başarısız.';

  @override
  String get emptyFieldsWarning =>
      'Tüm alanlar boş. Güncellemek için en az bir detay girin.';

  @override
  String get allNotifications => 'Tüm Bildirimler';

  @override
  String get allNotificationsDesc =>
      'Tüm uygulama bildirimlerini etkinleştir veya devre dışı bırak';

  @override
  String get alertPreferences => 'Uyarı Tercihleri';

  @override
  String get emailNotifications => 'E-posta Bildirimleri';

  @override
  String get emailNotificationsDesc =>
      'Önemli güncellemeler için e-posta bildirimleri alın';

  @override
  String get appointmentAlerts => 'Randevu Bildirimleri';

  @override
  String get appointmentAlertsDesc => 'Randevu planlama uyarıları alın';

  @override
  String get reminderAlerts => 'Hatırlatma Bildirimleri';

  @override
  String get reminderAlertsDesc => 'İlaç ve görev hatırlatıcıları alın';

  @override
  String get saveNotifications => 'Ayarları Kaydet';

  @override
  String get savingNotifications => 'Ayarlar Kaydediliyor...';

  @override
  String get notificationsSaved => 'Bildirim ayarları başarıyla kaydedildi!';

  @override
  String get notificationsSaveError => 'Bildirim ayarları kaydedilirken hata';

  @override
  String get accountSecurity => 'Hesap Güvenliği';

  @override
  String get accountSecurityDesc =>
      'Tıbbi verileriniz güvenli erişim kontrolleriyle korunmaktadır.';

  @override
  String get securityPreferences => 'Güvenlik Tercihleri';

  @override
  String get profileVisibility => 'Profil Görünürlüğü';

  @override
  String get profileVisibilityDesc =>
      'Doktor profilinizi kimlerin görebileceğini kontrol edin';

  @override
  String get shareActivity => 'Aktiviteyi Paylaş';

  @override
  String get shareActivityDesc =>
      'Klinik aktivitenizi meslektaşlarınızla paylaşın';

  @override
  String get allowMessages => 'Mesajlara İzin Ver';

  @override
  String get allowMessagesDesc =>
      'Hastaların size doğrudan mesaj göndermesine izin verin';

  @override
  String get appLock => 'Uygulama Kilidi';

  @override
  String get appLockDesc => 'Uygulama açılırken kimlik doğrulama iste';

  @override
  String get saveSecuritySettings => 'Güvenlik Ayarlarını Kaydet';

  @override
  String get savingSecuritySettings => 'Kaydediliyor...';

  @override
  String get privacySaved => 'Gizlilik ayarları başarıyla kaydedildi!';

  @override
  String get privacySaveError => 'Gizlilik ayarları kaydedilirken hata';

  @override
  String get bluetoothTitle => 'Bluetooth Cihazları';

  @override
  String get bluetoothStatus => 'Bluetooth Durumu';

  @override
  String get readyToScan => 'Taramaya hazır';

  @override
  String get bluetoothDisabled => 'Bluetooth devre dışı';

  @override
  String get initializationFailed => 'Başlatma başarısız';

  @override
  String get connectedDevice => 'Bağlı Cihaz';

  @override
  String get connected => 'Bağlı';

  @override
  String get pairedDevices => 'Eşleştirilmiş Cihazlar';

  @override
  String get availableDevices => 'Kullanılabilir Cihazlar';

  @override
  String get noDevicesFound => 'Cihaz bulunamadı';

  @override
  String get tapToScan => 'Cihazları aramak için \"Tara\" düğmesine dokunun';

  @override
  String get startScan => 'Taramayı Başlat';

  @override
  String get stopScanning => 'Taramayı Durdur';

  @override
  String get bluetoothPermissionRequired => 'Bluetooth izinleri gerekli';

  @override
  String get enableBluetooth => 'Lütfen Bluetooth\'u etkinleştirin';

  @override
  String connectedTo(String device) {
    return '$device cihazına bağlandı';
  }

  @override
  String get disconnected => 'Bağlantı kesildi';

  @override
  String get deviceUnpaired => 'Cihaz eşleştirmesi kaldırıldı';

  @override
  String get initializing => 'Başlatılıyor...';

  @override
  String get patientProfileTitle => 'Hasta Profili';

  @override
  String get patientProfileFooter => 'Hasta Profili';

  @override
  String get patientIdLabelProfile => 'Hasta ID';

  @override
  String welcomeBackPatient(String name) {
    return 'Tekrar Hoş Geldiniz, $name 👋';
  }

  @override
  String get stayHealthy => 'Sağlıklı kalın ve tedavi planınızı takip edin.';

  @override
  String get todaysHealthStatus => 'Bugünün Sağlık Durumu';

  @override
  String get noSeizureRisk =>
      'Bugün nöbet riski tespit edilmedi. İlaçlarınızı zamanında almaya devam edin.';

  @override
  String get viewHealthReport => 'Sağlık Raporunu Görüntüle';

  @override
  String get liveSensors => 'Canlı Sensörler';

  @override
  String get chatWithAi => 'YZ Asistan ile Sohbet Et';

  @override
  String get medicationReminder => 'İlaç Hatırlatıcısı';

  @override
  String get healthParameters => 'Sağlık Parametreleri';

  @override
  String get heartRate => 'Kalp Atış Hızı';

  @override
  String get temperature => 'Sıcaklık';

  @override
  String get o2Saturation => 'O2 Satürasyonu';

  @override
  String get motion => 'Hareket';

  @override
  String get motionLow => 'Düşük';

  @override
  String get motionActivity => 'Aktivite';

  @override
  String get viewDetailedSensors => 'Detaylı Sensör Analizini Görüntüle';

  @override
  String get emergencyContact => 'Acil Durum İletişim';

  @override
  String get emergencyHelpline => 'Acil Yardım Hattı';

  @override
  String get patientHomeFooter => 'Patients';

  @override
  String get remindersTitle => 'Hatırlatıcılar';

  @override
  String get remindersSubtitle =>
      'İlaç ve randevu hatırlatıcılarınızı yönetin.';

  @override
  String get reminderTitle => 'Hatırlatıcı Başlığı';

  @override
  String get reminderType => 'Hatırlatıcı Türü';

  @override
  String get reminderDate => 'Tarih';

  @override
  String get reminderTime => 'Saat';

  @override
  String get addReminder => 'Hatırlatıcı Ekle';

  @override
  String get saveReminder => 'Hatırlatıcıyı Kaydet';

  @override
  String get medicationType => 'İlaç';

  @override
  String get pillType => 'Hap';

  @override
  String get appointmentType => 'Randevu';

  @override
  String get doctorVisitType => 'Doktor Ziyareti';

  @override
  String get noRemindersYet => 'Henüz hatırlatıcı ayarlanmadı.';

  @override
  String get addFirstReminder =>
      'İlk hatırlatıcınızı ayarlamak için \'Hatırlatıcı Ekle\'ye dokunun.';

  @override
  String get viewMedicationTitle => 'İlaçlar';

  @override
  String get patientMedicationsTitle => 'İlaçlarım';

  @override
  String get medicationNameLabel => 'İlaç Adı (örn. Panadol)';

  @override
  String get medicationDoseLabel => 'Dozaj (örn. 500mg, 2 tablet)';

  @override
  String get medicationFrequencyLabel =>
      'Sıklık (örn. Günde iki kez, Her 8 saatte)';

  @override
  String get medicationTimingLabel =>
      'Zamanlama (örn. Yemeklerden önce, Yemeklerden sonra)';

  @override
  String get takeWithLabel =>
      'Birlikte Alınacak (örn. Su, Süt - Varsayılan Su)';

  @override
  String get instructionsLabel => 'Klinik Talimatlar / Özel Açıklama';

  @override
  String get savePrescription => 'Reçeteyi Kaydet';

  @override
  String get medicationSaved => 'Reçete başarıyla kaydedildi!';

  @override
  String get medicationSaveFailed => 'Reçete kaydedilemedi.';

  @override
  String get noMedications => 'Henüz reçete edilmiş ilaç yok.';

  @override
  String medicineDose(String dose, String frequency) {
    return 'Doz: $dose • Sıklık: $frequency';
  }

  @override
  String get callTitle => 'Acil Çağrı';

  @override
  String get callPrompt =>
      'Acil durum kişisini aramak istediğinize emin misiniz?';

  @override
  String get calling => 'Aranıyor...';

  @override
  String get chatbotTitle => 'YZ Sağlık Asistanı';

  @override
  String get chatbotSubtitle =>
      'Epilepsi, ilaçlar ve sağlık hakkında bana soru sorun.';

  @override
  String get typeMessage => 'Mesajınızı yazın...';

  @override
  String get sendMessage => 'Gönder';

  @override
  String get chatbotDisclaimer =>
      'Bu sohbet robotu yalnızca eğitim amaçlı bilgi sağlar. Tıbbi tavsiye için daima doktorunuza danışın.';

  @override
  String get realtimeSensorTitle => 'Canlı Sensör Verileri';

  @override
  String get realtimeSensorSubtitle =>
      'Bağlı sensörlerden gerçek zamanlı fizyolojik verileri izleyin.';

  @override
  String get fallDetected => 'DÜŞME TESPİT EDİLDİ';

  @override
  String get fallSafe => 'Güvenli';

  @override
  String get sensorUpdated => 'Güncellendi';

  @override
  String get bpmUnit => 'bpm';

  @override
  String get celsiusUnit => '°C';

  @override
  String get percentUnit => '%';

  @override
  String get healthReportTitle => 'Sağlık Raporu';

  @override
  String get healthReportSubtitle =>
      'En son sağlık raporunuzu ve analizinizi görüntüleyin.';

  @override
  String get healthReportSummary => 'Sağlık Özeti';

  @override
  String get generateReport => 'Rapor Oluştur';

  @override
  String get medicalHistoryTitle => 'Tıbbi Geçmiş';

  @override
  String get medicalHistorySubtitle =>
      'Tam tıbbi geçmişinizi ve geçmiş tedavilerinizi inceleyin.';

  @override
  String get pastRecords => 'Geçmiş Kayıtlar';

  @override
  String get noHistoryFound => 'Tıbbi geçmiş kaydı bulunamadı.';

  @override
  String get predictionTitle => 'Nöbet Tahmini';

  @override
  String get predictionSubtitle => 'YZ destekli nöbet risk değerlendirmesi';

  @override
  String get seizureStatus => 'Nöbet Durumu';

  @override
  String get predictionConfidence => 'Tahmin Güveni';

  @override
  String get predictionTime => 'Tahmin Zamanı';

  @override
  String get viewDetails => 'Detayları Gör';

  @override
  String get analyzing => 'Analiz ediliyor...';

  @override
  String get recentSeizureEvents => 'Son Nöbet Olayları';

  @override
  String get noSeizureEvents => 'Nöbet olayı kaydedilmedi';

  @override
  String get seizureEventsWillAppear => 'Son nöbet olayları burada görünecek';

  @override
  String get acknowledge => 'Onayla';

  @override
  String get acknowledged => 'Onaylandı';

  @override
  String get acknowledgeSeizureEvent => 'Nöbet Olayını Onayla';

  @override
  String get eventAcknowledged => 'Olay başarıyla onaylandı';

  @override
  String get addDoctorNotes => 'Doktor notları veya ilaç ayarlamaları ekleyin';

  @override
  String get medicationAlertSent => 'İlaç Uyarısı Gönderildi';

  @override
  String get appointmentAlertSent => 'Randevu Uyarısı Gönderildi';

  @override
  String get refresh => 'Yenile';

  @override
  String get historyTitle => 'Geçmiş';

  @override
  String get historySubtitle =>
      'Geçmiş kayıtları ve klinik geçmişi görüntüleyin.';

  @override
  String get exportPdfTitle => 'Raporu PDF Olarak Dışa Aktar';

  @override
  String get exportPdfSubtitle => 'PDF raporu oluşturun ve indirin.';

  @override
  String get exporting => 'Dışa aktarılıyor...';

  @override
  String get exportComplete => 'PDF dışa aktarımı tamamlandı';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get tomorrow => 'Yarın';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get thisMonth => 'Bu Ay';

  @override
  String get languageNameEn => 'İngilizce';

  @override
  String get languageNameEs => 'İspanyolca';

  @override
  String get languageNameUr => 'Urduca';

  @override
  String get languageNameAr => 'Arapça';

  @override
  String get languageNameFr => 'Fransızca';

  @override
  String get languageNameDe => 'Almanca';

  @override
  String get languageNameTr => 'Türkçe';

  @override
  String get languageNameZh => 'Çince (Basitleştirilmiş)';

  @override
  String languageSwitched(String language) {
    return 'Dil $language olarak değiştirildi';
  }

  @override
  String get clinicalStatus_observation => 'Gözlem Altında';

  @override
  String get clinicalStatus_stable => 'Stabil';

  @override
  String get clinicalStatus_critical => 'Kritik';

  @override
  String get clinicalStatus_urgent => 'Acil İnceleme Gerekli';

  @override
  String doseFormat(String dose) {
    return 'Doz: $dose';
  }

  @override
  String get genderMale => 'Erkek';

  @override
  String get genderFemale => 'Kadın';

  @override
  String get genderOther => 'Diğer';

  @override
  String genderAndAge(String gender, String age) {
    return 'Cinsiyet: $gender • Yaş: $age';
  }

  @override
  String get seizureTypeUnknown => 'Bilinmeyen Nöbet';

  @override
  String get severityCritical => 'KRİTİK';

  @override
  String get severityHigh => 'YÜKSEK';

  @override
  String get severityMedium => 'ORTA';

  @override
  String get severityLow => 'DÜŞÜK';

  @override
  String get severityLabelCritical => 'Kritik';

  @override
  String get severityLabelHigh => 'Yüksek';

  @override
  String get severityLabelMedium => 'Orta';

  @override
  String get severityLabelLow => 'Düşük';

  @override
  String get motionStatusMinimal => 'Minimal';

  @override
  String get motionStatusLow => 'Düşük';

  @override
  String get motionStatusModerate => 'Orta';

  @override
  String get motionStatusHigh => 'Yüksek';

  @override
  String get heartRateStatusNormal => 'Normal';

  @override
  String get heartRateStatusLow => 'Düşük';

  @override
  String get heartRateStatusHigh => 'Yüksek';

  @override
  String get temperatureStatusNormal => 'Normal';

  @override
  String get temperatureStatusLow => 'Düşük';

  @override
  String get temperatureStatusHigh => 'Yüksek';

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
