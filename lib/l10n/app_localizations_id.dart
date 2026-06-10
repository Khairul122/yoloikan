// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navCamera => 'Kamera';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get chooseMode => 'Pilih Mode';

  @override
  String get realtimeDetection => 'Deteksi Real-time';

  @override
  String get useCameraDirect => 'Gunakan kamera langsung';

  @override
  String get uploadImage => 'Unggah Gambar';

  @override
  String get pickFromGallery => 'Pilih dari galeri';

  @override
  String get quickGuide => 'Panduan Cepat';

  @override
  String get goodLighting => 'Pencahayaan Cukup';

  @override
  String get goodLightingDesc =>
      'Pastikan objek ikan terlihat jelas dengan pencahayaan yang baik agar deteksi lebih akurat.';

  @override
  String get focusOnObject => 'Fokus pada Objek';

  @override
  String get focusOnObjectDesc =>
      'Arahkan kamera atau pilih foto yang menampilkan ikan secara utuh tanpa terhalang objek lain.';

  @override
  String get welcomeTitle => 'Selamat Datang di\nLautan Data';

  @override
  String get welcomeDesc =>
      'Identifikasi spesies ikan secara cepat dan akurat menggunakan teknologi Yolo.';

  @override
  String get uploadGalleryTitle => 'Upload Galeri';

  @override
  String get detectionResults => 'Hasil Deteksi';

  @override
  String get tapResultHint => 'Ketuk hasil untuk melihat detail spesies';

  @override
  String get analyzingImage => 'Menganalisis gambar...';

  @override
  String get emptyGalleryHint =>
      'Tekan tombol di bawah untuk\nmemilih foto ikan dari galeri.';

  @override
  String get tapToPickPhoto => 'Ketuk untuk memilih foto';

  @override
  String get pickImage => 'Pilih Gambar';

  @override
  String get historyTitle => 'Riwayat Deteksi';

  @override
  String get clearHistoryDialogTitle => 'Hapus Riwayat';

  @override
  String get searchSpeciesHint => 'Cari spesies...';

  @override
  String get noMatchingResults => 'Tidak ada hasil yang cocok';

  @override
  String get noHistoryYet => 'Belum ada riwayat deteksi';

  @override
  String get description => 'Deskripsi';

  @override
  String get scanAgain => 'Scan Lagi';

  @override
  String confidentPercent(String value) {
    return '$value% yakin';
  }

  @override
  String get liveDetection => 'Deteksi Langsung';

  @override
  String get targetLocked => 'Target Terkunci';

  @override
  String get accuracyLabel => 'Akurasi';

  @override
  String get aimCameraHint => 'Arahkan kamera ke ikan...';

  @override
  String get back => 'Kembali';

  @override
  String get cameraPermissionRequired => 'Izin Kamera Diperlukan';

  @override
  String get cameraPermissionDesc =>
      'Izinkan akses kamera untuk menggunakan fitur deteksi real-time.';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutAppSection => 'Tentang Aplikasi';

  @override
  String get appNameLabel => 'Nama Aplikasi';

  @override
  String get versionLabel => 'Versi';

  @override
  String get modelAiLabel => 'Model Yolo';

  @override
  String get dataSection => 'Data';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Apakah Anda yakin ingin logout?';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get deleteHistoryItemConfirm =>
      'Item riwayat ini akan dihapus permanen. Lanjutkan?';

  @override
  String get swipeToDeleteHint => 'Geser ke kiri untuk menghapus item';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get notification => 'Notifikasi';

  @override
  String get notificationDesc => 'Terima pemberitahuan dari aplikasi';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get darkModeDesc => 'Gunakan tema gelap untuk aplikasi';

  @override
  String get language => 'Bahasa';

  @override
  String get languageDesc => 'Pilih bahasa aplikasi';

  @override
  String get moreSection => 'More';

  @override
  String get helpCenter => 'Pusat Bantuan';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get aboutApp => 'Tentang Aplikasi';

  @override
  String get featureInDevelopment => 'Fitur ini sedang dalam pengembangan.';

  @override
  String get info => 'Info';

  @override
  String get ok => 'OK';

  @override
  String get developerSection => 'Pengembang';

  @override
  String get developerName => 'Nama';

  @override
  String get developerNim => 'NIM';

  @override
  String get chooseImageSource => 'Pilih Sumber Gambar';

  @override
  String get takePhoto => 'Ambil Foto';

  @override
  String get lowConfidenceHint => 'Kemungkinan bukan ikan';

  @override
  String get modelLoadFailedMsg =>
      'Model Yolo gagal dimuat. Pastikan file model valid.';

  @override
  String get noFishDetectedMsg =>
      'Tidak ada ikan terdeteksi. Coba foto yang lebih jelas.';

  @override
  String get splashTagline => 'Deteksi Spesies Laut Bertenaga Yolo';

  @override
  String get initializingSystem => 'Memuat Sistem';

  @override
  String unknownErrorMsg(String message) {
    return 'Terjadi kesalahan: $message';
  }
}
