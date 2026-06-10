import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get navCamera;

  /// No description provided for @navHistory.
  ///
  /// In id, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In id, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @chooseMode.
  ///
  /// In id, this message translates to:
  /// **'Pilih Mode'**
  String get chooseMode;

  /// No description provided for @realtimeDetection.
  ///
  /// In id, this message translates to:
  /// **'Deteksi Real-time'**
  String get realtimeDetection;

  /// No description provided for @useCameraDirect.
  ///
  /// In id, this message translates to:
  /// **'Gunakan kamera langsung'**
  String get useCameraDirect;

  /// No description provided for @uploadImage.
  ///
  /// In id, this message translates to:
  /// **'Unggah Gambar'**
  String get uploadImage;

  /// No description provided for @pickFromGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari galeri'**
  String get pickFromGallery;

  /// No description provided for @quickGuide.
  ///
  /// In id, this message translates to:
  /// **'Panduan Cepat'**
  String get quickGuide;

  /// No description provided for @goodLighting.
  ///
  /// In id, this message translates to:
  /// **'Pencahayaan Cukup'**
  String get goodLighting;

  /// No description provided for @goodLightingDesc.
  ///
  /// In id, this message translates to:
  /// **'Pastikan objek ikan terlihat jelas dengan pencahayaan yang baik agar deteksi lebih akurat.'**
  String get goodLightingDesc;

  /// No description provided for @focusOnObject.
  ///
  /// In id, this message translates to:
  /// **'Fokus pada Objek'**
  String get focusOnObject;

  /// No description provided for @focusOnObjectDesc.
  ///
  /// In id, this message translates to:
  /// **'Arahkan kamera atau pilih foto yang menampilkan ikan secara utuh tanpa terhalang objek lain.'**
  String get focusOnObjectDesc;

  /// No description provided for @welcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang di\nLautan Data'**
  String get welcomeTitle;

  /// No description provided for @welcomeDesc.
  ///
  /// In id, this message translates to:
  /// **'Identifikasi spesies ikan secara cepat dan akurat menggunakan teknologi Yolo.'**
  String get welcomeDesc;

  /// No description provided for @uploadGalleryTitle.
  ///
  /// In id, this message translates to:
  /// **'Upload Galeri'**
  String get uploadGalleryTitle;

  /// No description provided for @detectionResults.
  ///
  /// In id, this message translates to:
  /// **'Hasil Deteksi'**
  String get detectionResults;

  /// No description provided for @tapResultHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk hasil untuk melihat detail spesies'**
  String get tapResultHint;

  /// No description provided for @analyzingImage.
  ///
  /// In id, this message translates to:
  /// **'Menganalisis gambar...'**
  String get analyzingImage;

  /// No description provided for @emptyGalleryHint.
  ///
  /// In id, this message translates to:
  /// **'Tekan tombol di bawah untuk\nmemilih foto ikan dari galeri.'**
  String get emptyGalleryHint;

  /// No description provided for @tapToPickPhoto.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk memilih foto'**
  String get tapToPickPhoto;

  /// No description provided for @pickImage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Gambar'**
  String get pickImage;

  /// No description provided for @historyTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Deteksi'**
  String get historyTitle;

  /// No description provided for @clearHistoryDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Riwayat'**
  String get clearHistoryDialogTitle;

  /// No description provided for @searchSpeciesHint.
  ///
  /// In id, this message translates to:
  /// **'Cari spesies...'**
  String get searchSpeciesHint;

  /// No description provided for @noMatchingResults.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil yang cocok'**
  String get noMatchingResults;

  /// No description provided for @noHistoryYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat deteksi'**
  String get noHistoryYet;

  /// No description provided for @description.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get description;

  /// No description provided for @scanAgain.
  ///
  /// In id, this message translates to:
  /// **'Scan Lagi'**
  String get scanAgain;

  /// No description provided for @confidentPercent.
  ///
  /// In id, this message translates to:
  /// **'{value}% yakin'**
  String confidentPercent(String value);

  /// No description provided for @liveDetection.
  ///
  /// In id, this message translates to:
  /// **'Deteksi Langsung'**
  String get liveDetection;

  /// No description provided for @targetLocked.
  ///
  /// In id, this message translates to:
  /// **'Target Terkunci'**
  String get targetLocked;

  /// No description provided for @accuracyLabel.
  ///
  /// In id, this message translates to:
  /// **'Akurasi'**
  String get accuracyLabel;

  /// No description provided for @aimCameraHint.
  ///
  /// In id, this message translates to:
  /// **'Arahkan kamera ke ikan...'**
  String get aimCameraHint;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In id, this message translates to:
  /// **'Izin Kamera Diperlukan'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionDesc.
  ///
  /// In id, this message translates to:
  /// **'Izinkan akses kamera untuk menggunakan fitur deteksi real-time.'**
  String get cameraPermissionDesc;

  /// No description provided for @tryAgain.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get tryAgain;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @aboutAppSection.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutAppSection;

  /// No description provided for @appNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Aplikasi'**
  String get appNameLabel;

  /// No description provided for @versionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get versionLabel;

  /// No description provided for @modelAiLabel.
  ///
  /// In id, this message translates to:
  /// **'Model Yolo'**
  String get modelAiLabel;

  /// No description provided for @dataSection.
  ///
  /// In id, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @deleteHistoryItemConfirm.
  ///
  /// In id, this message translates to:
  /// **'Item riwayat ini akan dihapus permanen. Lanjutkan?'**
  String get deleteHistoryItemConfirm;

  /// No description provided for @swipeToDeleteHint.
  ///
  /// In id, this message translates to:
  /// **'Geser ke kiri untuk menghapus item'**
  String get swipeToDeleteHint;

  /// No description provided for @preferencesSection.
  ///
  /// In id, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @notification.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notification;

  /// No description provided for @notificationDesc.
  ///
  /// In id, this message translates to:
  /// **'Terima pemberitahuan dari aplikasi'**
  String get notificationDesc;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In id, this message translates to:
  /// **'Gunakan tema gelap untuk aplikasi'**
  String get darkModeDesc;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @languageDesc.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa aplikasi'**
  String get languageDesc;

  /// No description provided for @moreSection.
  ///
  /// In id, this message translates to:
  /// **'More'**
  String get moreSection;

  /// No description provided for @helpCenter.
  ///
  /// In id, this message translates to:
  /// **'Pusat Bantuan'**
  String get helpCenter;

  /// No description provided for @privacyPolicy.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutApp;

  /// No description provided for @featureInDevelopment.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini sedang dalam pengembangan.'**
  String get featureInDevelopment;

  /// No description provided for @info.
  ///
  /// In id, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @ok.
  ///
  /// In id, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @developerSection.
  ///
  /// In id, this message translates to:
  /// **'Pengembang'**
  String get developerSection;

  /// No description provided for @developerName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get developerName;

  /// No description provided for @developerNim.
  ///
  /// In id, this message translates to:
  /// **'NIM'**
  String get developerNim;

  /// No description provided for @chooseImageSource.
  ///
  /// In id, this message translates to:
  /// **'Pilih Sumber Gambar'**
  String get chooseImageSource;

  /// No description provided for @takePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ambil Foto'**
  String get takePhoto;

  /// No description provided for @lowConfidenceHint.
  ///
  /// In id, this message translates to:
  /// **'Kemungkinan bukan ikan'**
  String get lowConfidenceHint;

  /// No description provided for @modelLoadFailedMsg.
  ///
  /// In id, this message translates to:
  /// **'Model Yolo gagal dimuat. Pastikan file model valid.'**
  String get modelLoadFailedMsg;

  /// No description provided for @noFishDetectedMsg.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada ikan terdeteksi. Coba foto yang lebih jelas.'**
  String get noFishDetectedMsg;

  /// No description provided for @splashTagline.
  ///
  /// In id, this message translates to:
  /// **'Deteksi Spesies Laut Bertenaga Yolo'**
  String get splashTagline;

  /// No description provided for @initializingSystem.
  ///
  /// In id, this message translates to:
  /// **'Memuat Sistem'**
  String get initializingSystem;

  /// No description provided for @unknownErrorMsg.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan: {message}'**
  String unknownErrorMsg(String message);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
