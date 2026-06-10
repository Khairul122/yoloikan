# AGENT.md — yoloikan Progress Tracker

> Update file ini setiap kali ada perubahan pada project.

**Last updated:** 2026-06-10 (update 37)

---

## Status

| # | Deskripsi | Status |
|---|-----------|--------|
| 1 | Foundation & config (pubspec, assets, AndroidManifest, minSdk=26) | ✅ Done |
| 2 | Core layer (AppColors, AppTextStyles, AppConstants, PermissionHelper) | ✅ Done |
| 3 | Model layer (DetectionResult) | ✅ Done |
| 4 | Controllers (GalleryController, RealtimeController) | ✅ Done |
| 5 | Widgets (AppHeader, FeatureCard, ConfidenceBar, ResultCard) | ✅ Done |
| 6 | Views (HomeView, GalleryView, RealtimeView) | ✅ Done |
| 7 | App root & routing (app.dart, main.dart) | ✅ Done |
| 8 | flutter pub get + flutter analyze (0 issues) | ✅ Done |
| 9 | Model best_float16.tflite dipindah ke assets/models/, path diupdate | ✅ Done |
| 10 | RealtimeView: multi-result bottom panel (top-3 detections + mini confidence bar) | ✅ Done |
| 11 | IkanModel + IkanRepository: load ikan.json, lookup by classIndex | ✅ Done |
| 12 | SpeciesDetailView: foto kamera + nama + confidence + deskripsi + warna spesies | ✅ Done |
| 13 | RealtimeView: stable detection 1.5s → auto-navigate detail, top-1 only, progress bar | ✅ Done |
| 14 | GalleryView: ResultCard tappable → IkanRepository lookup → navigate ke SpeciesDetailView | ✅ Done |
| 15 | "Non Ikan" (id=6) kini bisa dibuka ke detail (lukisan/objek mirip ikan/lainnya); deskripsi ikan.json id=6 diperluas; `nonFishClassIndex` constant dihapus | ✅ Done |
| 16 | RealtimeView: bounding box overlay native ditampilkan kembali (`setShowOverlays` dihapus); `capturePhoto(withOverlays: true)` agar foto di halaman detail menampilkan bounding box | ✅ Done |
| 17 | RealtimeController: `setNumItemsThreshold(1)` — overlay kamera hanya menampilkan 1 bounding box (confidence tertinggi) | ✅ Done |
| 18 | Redesign UI "Marine Intelligence": palet warna & tipografi baru, bottom nav (Home/Kamera/History/Settings), Riwayat Deteksi (persisted via shared_preferences + path_provider), Pengaturan Profil statis (JULIANA SARI/210180171), restyle Home & Detail | ✅ Done |
| 19 | Frontend dinamis & responsif: ResponsiveCenter (max-width 720 utk tablet), grid Home adaptif 2/4 kolom, header detail & padding skala terhadap ukuran layar — support semua ukuran Android | ✅ Done |
| 20 | Settings: section "Preferences" (Notifikasi, Mode Gelap, Bahasa) & "More" (Pusat Bantuan, Kebijakan Privasi, Tentang Aplikasi). Full dark theme (AppColors dark-aware + ThemeController) & full localization ID/EN (intl + l10n, LocaleController) | ✅ Done |
| 21 | RealtimeView: redesign sesuai referensi_ui "Marine Intelligence" — TopAppBar gradient + tombol back bulat + judul "Live Detection", Detection Info Card frosted-glass (Target Terkunci, nama spesies, badge akurasi, progress bar) | ✅ Done |
| 22 | History: hapus item satu-per-satu via swipe (Dismissible + konfirmasi dialog + `HistoryRepository.deleteById`), hapus foto terkait dari storage; tombol "Hapus Semua" tetap ada. Data riwayat 100% lokal (SharedPreferences + app docs dir) | ✅ Done |
| 23 | Upload Image: pilih sumber kamera/galeri via bottom sheet, indikator confidence rendah pada ResultCard, pesan error via AppLocalizations, fix bug non-ikan terdeteksi sebagai "Ikan Baramundi" (reklasifikasi `confidence < identificationThreshold` → "Non Ikan") di gallery & realtime | ✅ Done |
| 24 | SplashView baru sesuai referensi_ui "Marine Intelligence - Splash": logo bulat ikon ombak, judul FishScan + tagline, atmospheric blob blur, loading indicator "Initializing System", auto-navigate ke MainShell setelah 2 detik | ✅ Done |
| 25 | Halaman detail tidak ditampilkan untuk hasil "Non Ikan" — RealtimeView tidak auto-navigate saat top result = Non Ikan; GalleryView: ResultCard "Non Ikan" tidak bisa di-tap (onTap null) | ✅ Done |
| 26 | Upload Galeri: hanya menampilkan 1 hasil deteksi dengan confidence tertinggi (`_parseResults` → `take(1)`, `maxResults` dihapus); guard tambahan di `_openDetail` — hasil "Non Ikan" tidak akan navigasi ke detail meski terpanggil | ✅ Done |
| 27 | Fix bug: detail spesies di Upload Galeri selalu menampilkan "Ikan Baramundi" walau yang terdeteksi spesies lain — root cause: `YOLO.predict` (single image) di ultralytics_yolo 0.6.2 tidak menyertakan key `classIndex` pada hasil, sehingga `YOLOResult.fromMap` selalu fallback ke `classIndex = 0`. Fix: `IkanRepository.findByName` (cocokkan `className` ke `nama` di ikan.json) dipakai di `GalleryController._parseResults` untuk resolve `classIndex` yang benar | ✅ Done |
| 28 | Riwayat Deteksi: ganti backend penyimpanan dari `SharedPreferences` ke file `history.json` di app documents directory (real device storage, bukan path proyek), tambah write-queue agar `add`/`deleteById`/`clear` tidak race; `className` yang disimpan kini `species.nama` (canonical dari ikan.json, konsisten dengan halaman detail); `HistoryRepository.add` dibungkus try/catch agar kegagalan simpan tidak memblokir navigasi ke detail | ✅ Done |
| 29 | Ganti teks header Home dari "Marine Intelligence" → "Fish Scan"; ganti semua teks statis "AI"/"Model AI" → "Yolo"/"Model Yolo" pada `welcomeDesc`, `modelAiLabel`, `modelLoadFailedMsg`, `splashTagline` (ARB ID & EN) | ✅ Done |
| 30 | Clean code untuk production: `dart format` seluruh `lib/` & `test/` (23 file), hapus folder `referensi_ui/` (tidak dipakai app), aktifkan `minifyEnabled`/`shrinkResources` + ProGuard rules untuk release build, signing config release dibaca dari `android/key.properties` (fallback ke debug signing jika belum ada) | ✅ Done |
| 31 | App icon & nama aplikasi: ganti label/display name "yoloikan" → "Fish Scan" (Android, iOS, web); buat icon launcher baru (lingkaran putih + ikon waves navy di atas gradient navy `#001E40`→`#003366`, sesuai logo SplashView) via `flutter_launcher_icons` | ✅ Done |
| 32 | Asset icon (`assets/icon/icon.png`, `icon_background.png`, `icon_foreground.png`) di-regenerate manual oleh user; `dart run flutter_launcher_icons` dijalankan ulang untuk propagasi ke Android/iOS/web; script generator `tool/generate_app_icon.py` dihapus (tidak diperlukan lagi) | ✅ Done |
| 33 | Settings: ganti aksi "Hapus Riwayat Deteksi" pada section Data → "Logout" (icon `logout_rounded`, dialog konfirmasi, navigasi ke `/splash` & clear stack); hapus key ARB `clearHistory`/`clearHistoryConfirm`/`historyClearedMsg` (sudah tidak dipakai), tambah `logout`/`logoutConfirm` | ✅ Done |
| 34 | Fix: hasil deteksi baru tidak muncul di Riwayat Deteksi setelah scan — root cause: `HistoryView` pakai `AutomaticKeepAliveClientMixin` (tab di `IndexedStack`) dan `_future` cuma di-set sekali di `initState`, jadi tidak reload saat kembali dari halaman detail. Fix: `HistoryRepository.revision` (`ValueNotifier<int>`, increment tiap `_writeAll`) didengarkan oleh `HistoryView` → auto reload data setiap kali ada perubahan (add/delete/clear) | ✅ Done |
| 35 | Fix: tombol "Logout" di Settings sebelumnya navigasi ke `/splash` (yang setelah 2 detik auto pindah ke `/` lewat timer) — diganti langsung `pushNamedAndRemoveUntil('/', (route) => false)` agar lebih langsung & tidak bergantung timer/route tambahan | ✅ Done |
| 36 | Logout: app tidak punya sistem akun (profil statis), atas permintaan user "Logout" sekarang menutup aplikasi sepenuhnya via `SystemNavigator.pop()` setelah dialog konfirmasi | ✅ Done |
| 37 | Build release APK (`flutter build apk --release`, signing fallback ke debug, applicationId masih `com.example.yoloikan`) → `build/app/outputs/flutter-apk/app-release.apk` (118.3MB); tambah dokumentasi `studi.md`, `transfer_knowledge.md`, `perbandingan.md` (analisis performa model untuk foto ikan asli vs lukisan/ilustrasi vs objek mirip ikan) | ✅ Done |

---

## Struktur File

```
lib/
├── main.dart
├── app/app.dart
├── core/constants/app_colors.dart
├── core/constants/app_text_styles.dart
├── core/constants/app_constants.dart
├── core/utils/permission_helper.dart
├── models/detection_result.dart
├── controllers/gallery_controller.dart
├── controllers/realtime_controller.dart
├── views/home/home_view.dart
├── views/gallery/gallery_view.dart
├── views/realtime/realtime_view.dart
└── widgets/
    ├── app_header.dart
    ├── feature_card.dart
    ├── confidence_bar.dart
    └── result_card.dart
assets/
├── models/   ← letakkan fish.tflite di sini
└── images/
```

---

## Catatan Penting

- **minSdk Android** diset ke `26` (syarat ultralytics_yolo)
- **Library versi** yang terinstall: `ultralytics_yolo 0.6.2` (pubspec.yaml: `^0.6.1`) — API: class `YOLO`, `YOLOView`, `YOLOTask`, `YOLOResult`. **Catatan**: hasil `YOLO.predict` (single image, dipakai GalleryController) tidak menyertakan key `classIndex` pada map box — `YOLOResult.fromMap` akan fallback ke `0`. Gunakan `className` (selalu akurat) lalu `IkanRepository.findByName` untuk resolve spesies/classIndex yang benar (lihat update 27).
- **Model path** dikonfigurasi di `lib/core/constants/app_constants.dart` → `modelPath = 'assets/models/best_float32.tflite'`
- Tema warna: **Ocean Blue** (`#0077B6` primary, `#00B4D8` accent)
- Confidence threshold default: 40% (ubah di `app_constants.dart`)

---

## Changelog

### 2026-06-10 (update 37)
- `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk` (118.3MB). Signing masih fallback ke debug (`android/key.properties` belum ada), `applicationId` masih placeholder `com.example.yoloikan` — cukup untuk instal/uji manual, **belum siap publish ke Play Store**.
- Dokumen baru di root project:
  - `studi.md` — dasar teori, arsitektur model YOLO/TFLite, kelas & threshold (`confidenceThreshold`/`identificationThreshold`), alur klasifikasi
  - `transfer_knowledge.md` — panduan retraining/penggantian model, pitfall (resolusi `classIndex` via nama kelas, threshold ganda, minSdk 26)
  - `perbandingan.md` — analisis & matriks ekspektasi performa untuk 3 jenis input: foto ikan asli, lukisan/ilustrasi, objek mirip ikan; termasuk template tabel hasil uji manual

### 2026-06-10 (update 36)
- `lib/views/settings/settings_view.dart`: `_confirmLogout` — `pushNamedAndRemoveUntil('/', ...)` → `SystemNavigator.pop()` (tutup aplikasi sepenuhnya setelah dialog konfirmasi "Logout"); tambah import `package:flutter/services.dart`
- `flutter analyze`: 0 issues

### 2026-06-10 (update 35)
- `lib/views/settings/settings_view.dart`: `_confirmLogout` — `pushNamedAndRemoveUntil('/splash', ...)` → `pushNamedAndRemoveUntil('/', ...)` (langsung kembali ke `MainShell`, tanpa lewat splash + timer 2 detik)
- `flutter analyze`: 0 issues

### 2026-06-10 (update 34)
- **Bug**: setelah scan (galeri/realtime), riwayat baru tersimpan ke `history.json` tapi halaman "Riwayat Deteksi" tidak menampilkannya sampai app di-restart — karena `HistoryView` ada di `IndexedStack` dengan `AutomaticKeepAliveClientMixin`, dan `_future = HistoryRepository.getAll()` hanya dipanggil sekali di `initState`, tidak pernah re-fetch saat user kembali (pop) dari halaman detail ke tab Riwayat
- Fix: `lib/services/history_repository.dart` — tambah `static final ValueNotifier<int> revision`, di-increment di `_writeAll` (dipanggil oleh `add`/`deleteById`/`clear`)
- `lib/views/history/history_view.dart` — `initState` daftar listener `HistoryRepository.revision.addListener(_reload)`, `dispose` melepas listener; `_reload()` set ulang `_future` agar `FutureBuilder` memuat data terbaru
- `flutter analyze`: 0 issues

### 2026-06-10 (update 33)
- `lib/views/settings/settings_view.dart`: ganti `_confirmClearHistory` → `_confirmLogout`; aksi "Data" section sekarang "Logout" (icon `Icons.logout_rounded`), dialog konfirmasi → `Navigator.pushNamedAndRemoveUntil('/splash', (route) => false)`. Hapus import `HistoryRepository` (tidak dipakai lagi di file ini)
- ARB (ID & EN): hapus `clearHistory`, `clearHistoryConfirm`, `historyClearedMsg`; tambah `logout`, `logoutConfirm`
- `flutter gen-l10n && flutter analyze`: 0 issues

### 2026-06-10 (update 32)
- User regenerate sendiri asset icon (`assets/icon/icon.png`, `icon_background.png`, `icon_foreground.png`)
- Jalankan ulang `dart run flutter_launcher_icons` → propagasi icon baru ke Android (mipmap + adaptive icon), iOS AppIcon, dan web icons
- Hapus `tool/generate_app_icon.py` (script generator Python sebelumnya, sudah tidak diperlukan)
- `flutter analyze`: 0 issues

### 2026-06-10 (update 31)
- **Nama aplikasi** "yoloikan" → "Fish Scan":
  - `android/app/src/main/AndroidManifest.xml`: `android:label`
  - `ios/Runner/Info.plist`: `CFBundleDisplayName`, `CFBundleName`
  - `web/manifest.json`: `name`/`short_name` (+ `background_color`/`theme_color` → `#001E40` agar konsisten dengan tema)
  - `web/index.html`: `<title>`, `apple-mobile-web-app-title`
- **App icon baru** sesuai logo di `SplashView` (lingkaran putih + ikon "waves" navy di atas gradient navy `#001E40`→`#003366`):
  - `tool/generate_app_icon.py` (NEW): script Python (PIL) untuk generate `assets/icon/icon.png`, `icon_background.png`, `icon_foreground.png` (1024x1024)
  - `pubspec.yaml`: tambah dev dependency `flutter_launcher_icons: ^0.14.3` + konfigurasi `flutter_launcher_icons` (android adaptive icon, iOS `remove_alpha_ios: true`, web)
  - Jalankan `python tool/generate_app_icon.py && dart run flutter_launcher_icons` untuk regenerate semua ukuran icon (Android mipmap, iOS AppIcon, web icons)
- `flutter analyze`: 0 issues; `flutter build apk --debug`: berhasil

### 2026-06-10 (update 30)
- `dart format lib/ test/`: 23 file diformat ulang (whitespace/style only, tidak ada perubahan logika). `flutter analyze`: 0 issues.
- Hapus folder `referensi_ui/` (file HTML/gambar referensi desain, tidak dipakai aplikasi).
- `android/app/build.gradle.kts`:
  - `buildTypes.release`: `isMinifyEnabled = true`, `isShrinkResources = true`, `proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")`.
  - Signing config release dibaca dari `android/key.properties` (jika ada) — fallback ke debug signing kalau file belum dibuat, supaya `flutter build apk --release` tetap jalan saat development.
- `android/app/proguard-rules.pro` (NEW): keep rules untuk Flutter, `com.ultralytics.yolo.**`, TFLite, dan `-dontwarn com.google.android.play.core.**` (fix R8 "Missing classes" pada deferred-components yang tidak dipakai).
- `android/key.properties.example` (NEW): template untuk signing config; `.gitignore` ditambah `/android/key.properties`, `*.jks`, `*.keystore`.
- Verifikasi: `flutter build apk --release` sukses (118.2MB).
- **Catatan untuk publish ke Play Store** (belum dilakukan, butuh keputusan Anda):
  - `applicationId` masih `com.example.yoloikan` (placeholder default) — harus diganti ke package ID unik sebelum rilis.
  - Belum ada keystore release — buat `android/key.properties` dari `key.properties.example` + keystore `.jks` sendiri agar APK ditandatangani dengan key produksi (saat ini fallback ke debug signing).

### 2026-06-10 (update 29)
- lib/views/home/home_view.dart: header `'Marine Intelligence'` → `'Fish Scan'`
- lib/l10n/app_id.arb & app_en.arb: ganti semua teks statis "AI" → "Yolo":
  - `welcomeDesc`: "...teknologi AI." → "...teknologi Yolo." / "...AI technology." → "...Yolo technology."
  - `modelAiLabel`: "Model AI"/"AI Model" → "Model Yolo"/"Yolo Model"
  - `modelLoadFailedMsg`: "Model AI gagal dimuat..." → "Model Yolo gagal dimuat..." / "Failed to load AI model..." → "Failed to load Yolo model..."
  - `splashTagline`: "...Bertenaga AI" → "...Bertenaga Yolo" / "AI-Powered..." → "Yolo-Powered..."
- `flutter gen-l10n && flutter analyze`: 0 issues

### 2026-06-10 (update 28)
- **Analisa**: Riwayat Deteksi kadang tidak tersimpan / data salah setelah deteksi (upload galeri & realtime). Penyebab:
  1. Backend lama (`SharedPreferences`) melakukan read-modify-write (`getStringList` → `setStringList`) yang tidak atomik — kalau `HistoryRepository.add` terpanggil hampir bersamaan (mis. tap ganda pada ResultCard), penulisan kedua bisa menimpa hasil penulisan pertama (lost update) → entri hilang.
  2. `await HistoryRepository.add(...)` tidak dibungkus try/catch — jika terjadi error I/O saat menulis foto/JSON, exception langsung melempar ke luar handler `onTap`/`_navigateToDetail`, sehingga **baik penyimpanan maupun navigasi ke halaman detail batal** tanpa pesan error ke user.
  3. `className` yang disimpan ke riwayat sebelumnya berasal dari label mentah model (`result.label` / `detection.className`), bukan nama kanonik di `ikan.json` (`species.nama`) yang ditampilkan di halaman detail — bisa berbeda format/penulisan, terlihat seperti "data salah" di list riwayat.
- **Fix**:
  - `lib/services/history_repository.dart`: ganti backend dari `SharedPreferences` ke file `history.json` di `getApplicationDocumentsDirectory()` (real device path, sejajar dengan folder `history/` foto) — bisa di-pull via `adb` untuk debugging. Tambah `_queue` (chain `Future`) agar `add`/`deleteById`/`clear` berjalan berurutan (anti race/lost-update). `clear()` kini juga menghapus file foto terkait.
  - `lib/views/gallery/gallery_view.dart` & `lib/views/realtime/realtime_view.dart`: `HistoryRepository.add` dibungkus try/catch (gagal simpan tidak membatalkan navigasi ke detail, error di-log via `debugPrint`); `className` yang disimpan diganti jadi `species.nama`.
- flutter analyze: 0 issues

### 2026-06-10 (update 27)
- **Bug fix**: detail spesies di Upload Galeri selalu menampilkan "Ikan Baramundi" (nama+deskripsi) walau model mendeteksi spesies lain dengan benar (cth. "Ikan Belanak Merah").
  - Root cause: di `ultralytics_yolo 0.6.2`, hasil `YOLO.predict()` (single image) — `YOLOPlugin.kt` baris ~230-244 — membangun map box hanya dengan key `class`/`className`/`confidence`/koordinat, **tanpa key `classIndex`**. `YOLOResult.fromMap` (`MapConverter.safeGetInt(map, 'classIndex')`) lalu fallback ke `0` untuk semua deteksi, sehingga `IkanRepository.findById(0)` selalu mengembalikan entri id=0 ("Ikan Baramundi"), padahal `className` (dipakai untuk subtitle/badge) tetap benar.
  - Fix: `lib/services/ikan_repository.dart` — tambah `findByName(String className)` (cocokkan `nama` di ikan.json, case-insensitive).
  - `lib/controllers/gallery_controller.dart` — `_parseResults` jadi `async`; resolve `classIndex` via `IkanRepository.findByName(result.className)?.id` sebelum membuat `DetectionResult`. Hapus debug print sementara. Import `package:flutter/foundation.dart` → `package:flutter/material.dart`.
  - Catatan versi `ultralytics_yolo` di "Catatan Penting" dikoreksi dari 0.0.9 → 0.6.2 (sesuai pubspec.lock).
  - flutter analyze: 0 issues

### 2026-06-10 (update 26)
- lib/controllers/gallery_controller.dart: `_parseResults` → `mapped.take(1)` (sebelumnya `take(AppConstants.maxResults)`), gallery upload kini hanya menampilkan 1 hasil dengan confidence tertinggi
- lib/core/constants/app_constants.dart: hapus `maxResults` (tidak terpakai lagi)
- lib/views/gallery/gallery_view.dart: `_openDetail` — tambah guard awal `if (result.classIndex == AppConstants.nonFishClassIndex) return;` agar hasil "Non Ikan" tidak pernah navigasi ke halaman detail dari jalur manapun
- flutter analyze: 0 issues

### 2026-06-10 (update 25)
- lib/views/realtime/realtime_view.dart: `_onDetectionResult` — jika top result hasil reklasifikasi "Non Ikan" (`classIndex == nonFishClassIndex`), tidak memulai stable timer / tidak auto-navigate ke halaman detail (info card tetap menampilkan "Non Ikan" sebagai info, tapi tidak ada navigasi)
- lib/views/gallery/gallery_view.dart: `ResultCard` untuk hasil "Non Ikan" (`classIndex == nonFishClassIndex`) → `onTap = null` (tidak bisa dibuka ke halaman detail)
- flutter analyze: 0 issues

### 2026-06-10 (update 24)
- lib/views/splash/splash_view.dart (NEW): SplashView sesuai `referensi_ui/code.html` ("Marine Intelligence - Splash") — logo bulat (Icons.waves_rounded) dengan shadow lembut, judul `AppConstants.appName`, tagline `splashTagline`, 2 blob blur atmosfer (primaryContainer/secondaryContainer), fade-in animasi, loading indicator + label `initializingSystem`, auto-navigate `pushReplacementNamed('/')` setelah 2 detik
- lib/app/app.dart: tambah route `/splash` → SplashView, `initialRoute` diubah dari `/` ke `/splash`
- lib/l10n/app_id.arb & app_en.arb: tambah `splashTagline`, `initializingSystem`
- flutter gen-l10n + flutter analyze: 0 issues

### 2026-06-10 (update 23)
- lib/core/constants/app_constants.dart: tambah `identificationThreshold = 0.65`, `iouThreshold`, `maxResults`, re-tambah `nonFishClassIndex = 6`
- lib/models/detection_result.dart: tambah getter `isConfidentFish`
- lib/controllers/gallery_controller.dart: `pickAndDetect(ImageSource source)` (kamera/galeri); `GalleryError` enum (modelLoadFailed/noDetection/unknown) + `errorDetail` menggantikan pesan string hardcode; `_parseResults` reklasifikasi hasil dengan `confidence < identificationThreshold` → `classIndex = nonFishClassIndex`, `label = 'non_ikan'`
- lib/views/gallery/gallery_view.dart: `_PickSourceSheet` (bottom sheet "Ambil Foto" / "Pilih dari Galeri", request `PermissionHelper.requestCamera()` untuk kamera); `_buildError` map `GalleryError` → pesan ber-locale; teruskan `isLowConfidence` ke `ResultCard`
- lib/widgets/result_card.dart: tambah param `isLowConfidence` — badge confidence abu-abu + hint `lowConfidenceHint` saat hasil "Non Ikan"
- lib/views/realtime/realtime_view.dart: `_onDetectionResult` reklasifikasi top result dengan `confidence < identificationThreshold` → "Non Ikan" (konsisten dengan gallery)
- lib/l10n/app_id.arb & app_en.arb: tambah `chooseImageSource`, `takePhoto`, `lowConfidenceHint`, `modelLoadFailedMsg`, `noFishDetectedMsg`, `unknownErrorMsg` (placeholder `{message}`)
- flutter gen-l10n + flutter analyze: 0 issues

### 2026-06-10 (update 22)
- lib/services/history_repository.dart: tambah `deleteById(id)` — hapus 1 item dari SharedPreferences + hapus file foto terkait dari app docs dir
- lib/views/history/history_view.dart: tiap `_HistoryCard` dibungkus `Dismissible` (swipe kiri), `confirmDismiss` → dialog konfirmasi (key baru `deleteHistoryItemConfirm`), `onDismissed` → `HistoryRepository.deleteById` + reload; tambah hint `swipeToDeleteHint` di bawah search bar; tombol "Hapus Semua" (clear) tetap ada
- lib/l10n/app_id.arb & app_en.arb: tambah `deleteHistoryItemConfirm`, `swipeToDeleteHint`
- Konfirmasi: data riwayat (SharedPreferences key `history_items` + foto di app documents dir) sudah murni on-device, tidak ada perubahan diperlukan
- flutter gen-l10n + flutter analyze: 0 issues

### 2026-06-10 (update 21)
- lib/views/realtime/realtime_view.dart: redesign mengikuti `referensi_ui/` (DESIGN.md "Marine Intelligence" + screen.png)
  - `_TopBar`: gradient overlay hitam→transparan, tombol back bulat (`_CircleIconButton`), judul `l10n.liveDetection` di tengah (tanpa flashlight, ultralytics_yolo 0.0.9 tidak expose torch API)
  - `_BackButton` pill bawah & `_ScanProgressBar` dihapus, digantikan `_DetectionInfoCard` (frosted glass via BackdropFilter): label "TARGET TERKUNCI" + dot, nama spesies, badge akurasi mono-data, progress bar `_ProgressTrack`; saat tidak ada deteksi → hint "Arahkan kamera..."
  - lib/l10n/app_id.arb & app_en.arb: tambah `liveDetection`, `targetLocked`, `accuracyLabel`; hapus key `live` & `identifying` (tidak terpakai lagi)
- flutter gen-l10n + flutter analyze: 0 issues

### 2026-06-10 (update 20)
- pubspec.yaml: tambah `flutter_localizations`, `intl ^0.20.2`, `flutter: generate: true`
- l10n.yaml (NEW) + lib/l10n/app_id.arb & app_en.arb (NEW): ~50 string keys (nav, home, gallery, history, detail, realtime, settings) → generate `AppLocalizations` (lib/l10n/app_localizations*.dart)
- lib/core/constants/app_colors_dark.dart (NEW): palet "Marine Intelligence" dark
- lib/core/constants/app_colors.dart: semua warna jadi getter dinamis (`AppColors.setBrightness()`), resolve ke palet light/dark
- lib/controllers/theme_controller.dart (NEW): ThemeController (ChangeNotifier) — persist `theme_mode` via SharedPreferences, update AppColors brightness
- lib/controllers/locale_controller.dart (NEW): LocaleController (ChangeNotifier) — persist `app_locale` via SharedPreferences
- lib/services/preferences_service.dart (NEW): persist toggle `notification_enabled`
- lib/main.dart: `MultiProvider` (GalleryController, ThemeController, LocaleController), load preferences sebelum runApp
- lib/app/app.dart: `Consumer2<ThemeController, LocaleController>`, tambah `darkTheme`, `themeMode`, `locale`, localization delegates; `builder` dengan `KeyedSubtree(key: ValueKey(brightness))` untuk remount full subtree saat ganti tema
- lib/widgets/settings_widgets.dart (NEW): `GroupCard`, `InfoRow`, `ActionRow` (extracted dari settings_view), `PreferenceSwitchRow`, `LanguageRow` (toggle ID/EN)
- lib/views/settings/about_page.dart (NEW): halaman "Tentang Aplikasi" (nama, versi, model AI, info pengembang)
- lib/views/settings/settings_view.dart: convert ke StatefulWidget; tambah section "Preferences" (Notifikasi, Mode Gelap, Bahasa) & "More" (Pusat Bantuan, Kebijakan Privasi → dialog "fitur sedang dikembangkan"; Tentang Aplikasi → AboutPage); semua string via AppLocalizations
- lib/widgets/main_bottom_nav.dart, lib/views/home/home_view.dart, lib/views/gallery/gallery_view.dart, lib/views/history/history_view.dart, lib/views/detail/species_detail_view.dart, lib/views/realtime/realtime_view.dart: string hardcode → AppLocalizations (ID/EN)
- flutter pub get + flutter analyze: 0 issues

### 2026-06-10 (update 19)
- lib/widgets/responsive_center.dart (NEW): `ResponsiveCenter` (constrain max-width 640/720 + center, untuk tablet) dan helper `responsiveValue()` (skala nilai terhadap lebar layar)
- home_view.dart: bento "Pilih Mode" diganti dari Row 2-kolom fixed-height menjadi `GridView.count` adaptif (2 kolom di ponsel, 4 kolom di layar ≥600dp), padding horizontal skala 5% lebar layar (clamp 16-32), dibungkus ResponsiveCenter
- species_detail_view.dart: `expandedHeight` SliverAppBar dihitung dari 38% tinggi layar (clamp 240-420) agar proporsional di layar pendek/tinggi, konten dibungkus ResponsiveCenter
- history_view.dart, settings_view.dart, gallery_view.dart: dibungkus ResponsiveCenter (max-width 720) agar list/card tidak melebar berlebihan di tablet
- flutter analyze: 0 issues

### 2026-06-10 (update 18)
- pubspec.yaml: tambah shared_preferences ^2.5.3, path_provider ^2.1.5
- app_colors.dart & app_text_styles.dart: palet "Marine Intelligence" (primary #001e40, secondary/teal #006a6a, dst) + style baru headlineMedium, monoData (JetBrains Mono), labelBold
- lib/models/history_item.dart (NEW): model riwayat deteksi (id, classIndex, className, confidence, photoPath, timestamp) + toJson/fromJson
- lib/services/history_repository.dart (NEW): persist riwayat ke SharedPreferences (JSON list), simpan foto ke app docs dir via path_provider, getAll/add/clear
- lib/widgets/main_bottom_nav.dart (NEW): bottom nav 4 item (Home, Kamera, History, Settings) dengan active dot indicator
- lib/views/shell/main_shell.dart (NEW): IndexedStack (Home/History/Settings), tab "Kamera" push ke /realtime tanpa ubah tab aktif
- lib/views/home/home_view.dart: restyle — TopAppBar "Marine Intelligence", hero glass card, bento grid 2 kolom (Deteksi Real-time/Unggah Gambar), section "Panduan Cepat"
- lib/widgets/feature_card.dart: dihapus (sudah tidak dipakai)
- lib/views/history/history_view.dart (NEW): list riwayat dari HistoryRepository, search filter, tap untuk buka detail, tombol hapus semua dengan konfirmasi, empty state
- lib/views/settings/settings_view.dart (NEW): profil statis (Nama: JULIANA SARI, NIM: 210180171), info aplikasi, tombol "Hapus Riwayat Deteksi" fungsional
- lib/views/detail/species_detail_view.dart: restyle palet baru, SpeciesDetailArgs tambah field timestamp, label AI bounding box pada foto (className + confidence%), hanya menampilkan field dari ikan.json (nama, deskripsi, warna)
- lib/views/realtime/realtime_view.dart & lib/views/gallery/gallery_view.dart: simpan entry HistoryRepository.add() sebelum navigasi ke halaman detail
- lib/app/app.dart: route '/' → MainShell (bukan langsung HomeView)
- flutter pub get + flutter analyze: 0 issues

### 2026-06-10 (update 11–13)
- lib/models/ikan_model.dart: data class dari ikan.json (id, nama, deskripsi, warna)
- lib/services/ikan_repository.dart: lazy-load + cache ikan.json, findById(classIndex)
- lib/core/constants/app_constants.dart: tambah detailRoute + nonFishClassIndex = 6
- lib/views/detail/species_detail_view.dart: halaman detail spesies baru
  - SliverAppBar + foto kamera (Image.memory) atau fallback gradient + ikon ikan
  - Badge confidence, nama spesies, divider, deskripsi dari ikan.json
  - Warna accent sesuai species.warna per spesies
  - Tombol "Scan Lagi" = Navigator.pop
- lib/app/app.dart: tambah route AppConstants.detailRoute → SpeciesDetailView
- lib/views/realtime/realtime_view.dart: rewrite fitur utama
  - top-1 only (reduce by confidence, bukan top-3)
  - stable detection: Timer 1.5s, reset saat spesies berubah
  - AnimationController 1.5s → progress bar "Mengidentifikasi..."
  - Non Ikan (classIndex 6) tidak memicu navigasi
  - capturePhoto(withOverlays: false) sebelum navigate
  - Camera pause saat di detail, resume saat kembali

### 2026-06-10 (update 10)
- realtime_view.dart: _TopResult → _results (List<YOLOResult>), tampilkan top-3 detections
- Tambah _TopBar: live indicator + top-1 label dengan color-coded dot
- Tambah _BottomResultPanel: gradient overlay, rank badge, confidence bar per row
- Tambah _ResultRow: highlight top-1 dengan accent color, rank 2-3 dengan warna lebih redup
- Back button digeser ke atas panel (bottom: 120 + safeArea padding)
- Analisa: bounding box displacement = coordinate transform issue di library (bukan model); bias = model training data issue

### 2026-06-09 (update 9)
- android/app/build.gradle.kts: kotlinOptions { jvmTarget } → kotlin { compilerOptions { jvmTarget } } (Kotlin 2.3.0 breaking change)

### 2026-06-09 (update 8)
- android/settings.gradle.kts: Kotlin 2.1.0 → 2.3.0 (litert-2.1.5 butuh Kotlin 2.3.0)

### 2026-06-09 (update 7)
- android/settings.gradle.kts: AGP 8.7.3 → 8.9.1 (required by ultralytics_yolo 0.6.2)
- android/app/build.gradle.kts: compileSdk 35 → 36, ndkVersion → 28.2.13676358

### 2026-06-09 (update 6)
- Upgrade ultralytics_yolo 0.0.9 → 0.6.2 (fix inference error dengan float32/YOLOv8)
- API baru: YOLOView (kapital), YOLOViewController, YOLO(useGpu: false)
- YOLO.dispose() async ditambahkan di gallery_controller
- YOLOViewController.dispose() ditambahkan di realtime_controller
- confidenceThreshold & iouThreshold dikirim langsung ke predict() dan YOLOView
- Import semua dari package:ultralytics_yolo/ultralytics_yolo.dart

### 2026-06-09 (update 5)
- Fix #1 (kamera terus running): RealtimeController dipindah dari global MultiProvider ke local ChangeNotifierProvider per-route di app.dart — dispose otomatis saat halaman ditutup
- Fix #1: RealtimeView tambah WidgetsBindingObserver — YoloView di-unmount saat app background
- Fix #2 (inference error): validasi return value loadModel(), reset _yolo jika gagal, error message lebih deskriptif
- Fix #2: AppConstants.yoloTask ditambah — ganti ke YOLOTask.classify jika model adalah klasifikasi
- main.dart: hapus RealtimeController dari global provider

### 2026-06-09 (update 4)
- Fix bottom overflow: HomeView pakai LayoutBuilder + SingleChildScrollView, spacing proporsional (h * ratio)
- GalleryView: preview height dinamis (30% layar, clamp 160–260px), FAB centered, bottom padding auto
- FeatureCard: padding dikurangi, teks maxLines+ellipsis, ripple effect dengan InkWell
- Semua ukuran Android didukung (layar kecil hingga tablet)

### 2026-06-09 (update 3)
- android/app/build.gradle.kts: ndkVersion diupdate ke "27.0.12077973" (kompatibel dengan semua plugin)

### 2026-06-09 (update 2)
- Model best_float16.tflite dipindah dari root ke assets/models/
- AppConstants.modelPath diupdate ke 'assets/models/best_float16.tflite'

### 2026-06-09
- Initial full implementation dari blank Flutter project
- MVC architecture: controllers (ChangeNotifier), views (Consumer), widgets (reusable)
- Dependency: ultralytics_yolo 0.0.9, image_picker, permission_handler, provider, google_fonts
- API fix: disesuaikan dengan actual API v0.0.9 (YOLO, YoloView, YOLOTask, YOLOResult)
- Fitur 1: Gallery upload → YOLO.predict() → ResultCard list dengan animated ConfidenceBar
- Fitur 2: Real-time camera → YoloView dengan live detection overlay
- flutter analyze: 0 issues
