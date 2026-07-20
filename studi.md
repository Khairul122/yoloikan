# Studi — Dokumentasi Lengkap Proyek Fish Scan

> Dokumen ini menjelaskan proyek **Fish Scan** (nama paket: `yoloikan`) secara
> menyeluruh: mulai dari tech stack, arsitektur, alur kerja tiap fitur, model
> machine learning yang dipakai, hingga status/hasil akhir proyek saat ini.
> Untuk riwayat perubahan per update, lihat `AGENT.md`. Untuk panduan
> retraining model, lihat `transfer_knowledge.md`. Untuk analisis performa
> model pada berbagai jenis gambar, lihat `perbandingan.md`.

---

## 1. Gambaran Umum

**Fish Scan** adalah aplikasi mobile Flutter untuk mengidentifikasi spesies
ikan dari gambar, menggunakan model **YOLO** (object detection) yang berjalan
**on-device** (tanpa koneksi internet). Aplikasi punya dua cara input:

1. **Upload Galeri/Kamera** — ambil/pilih satu foto, model mendeteksi & hasil
   ditampilkan di halaman detail spesies.
2. **Deteksi Real-time** — kamera live, bounding box & label muncul langsung
   di atas preview, auto-navigasi ke detail saat deteksi stabil 1.5 detik.

Setiap hasil deteksi yang valid otomatis tersimpan ke **Riwayat Deteksi**
lokal (tanpa server/backend — seluruh data ada di penyimpanan device).

---

## 2. Tech Stack

### 2.1 Platform & Bahasa
- **Flutter** (Dart SDK `^3.8.1`) — cross-platform (target utama: Android;
  iOS & Web ikut ter-generate tapi belum jadi fokus pengujian).
- **minSdk Android**: 26, **compileSdk**: 36, **AGP**: 8.9.1, **Kotlin**: 2.3.0,
  **NDK**: 28.2.13676358 — versi-versi ini dinaikkan secara bertahap untuk
  kompatibilitas native build Android & LiteRT dependencies.

### 2.2 Machine Learning
- **`flutter_vision`** (fork lokal: `packages/flutter_vision_local`, berbasis `flutter_vision` 2.0.0) —
  menggantikan `ultralytics_yolo` karena pustaka native `libLiteRt.so` bawaan `ultralytics_yolo` mengalami crash (`SIGSEGV`) pada beberapa perangkat.
  Fork lokal ini ditambal pada `FlutterVisionPlugin.java` & `Yolov8.java` agar mendukung tensor TFLite berlayout NCHW (`[1, 3, H, W]`).
- **`camera: ^0.11.2+1`** — mengelola stream gambar kamera live secara native untuk deteksi real-time.
- **TensorFlow Lite** — format model akhir (`assets/models/best.tflite`),
  hasil export dari model YOLO yang sudah difine-tune untuk 6 kelas ikan.
- Inferensi dijalankan **di CPU** (`useGpu: false`) demi stabilitas lintas
  perangkat.

### 2.3 State Management & Arsitektur
- **`provider: ^6.1.2`** — `ChangeNotifier` + `MultiProvider`/`Consumer`,
  dipakai untuk seluruh controller (Gallery, Realtime, Theme, Locale).
- **Arsitektur MVC**: `models/` (data class), `controllers/` (business logic +
  state), `views/` (UI per halaman), `widgets/` (komponen reusable),
  `services/` (akses data/storage), `core/` (constants & utils).

### 2.4 Penyimpanan Lokal (tanpa backend)
- **`shared_preferences: ^2.5.3`** — preferensi sederhana (tema, bahasa,
  notifikasi on/off).
- **`path_provider: ^2.1.5`** — akses direktori dokumen aplikasi, dipakai
  untuk menyimpan `history.json` dan foto hasil capture.
- Repository pattern manual (`HistoryRepository`, `IkanRepository`,
  `PreferencesService`) — tidak ada database SQL; semua persist via file JSON
  + `SharedPreferences`.

### 2.5 UI/UX
- **`google_fonts: ^6.2.1`** — tipografi kustom (termasuk JetBrains Mono untuk
  data monospace seperti confidence/persentase).
- **`flutter_localizations` + `intl: ^0.20.2`** — i18n penuh Indonesia/Inggris
  via file `.arb` (`lib/l10n/app_id.arb`, `app_en.arb`) yang digenerate jadi
  `AppLocalizations`.
- Tema **dark mode** penuh — `AppColors` resolve dinamis ke palet
  light/dark via `AppColors.setBrightness()`.
- **`flutter_launcher_icons: ^0.14.3`** — generate app icon (Android adaptive
  icon, iOS, web) dari aset `assets/icon/`.

### 2.6 Lain-lain
- **`image_picker: ^1.1.2`** — ambil foto dari kamera/galeri (mode Upload).
- **`permission_handler: ^11.3.1`** — request izin kamera saat dibutuhkan.
- **`cupertino_icons: ^1.0.8`**, **`flutter_lints: ^5.0.0`** (dev).

---

## 3. Struktur Proyek (`lib/`)

```
lib/
├── main.dart                       # entry point, setup MultiProvider, load preferences
├── app/app.dart                    # MaterialApp, routing, theme, locale, localization delegates
├── core/
│   ├── constants/app_colors.dart        # palet warna dinamis (light/dark)
│   ├── constants/app_colors_dark.dart   # palet dark mode
│   ├── constants/app_text_styles.dart   # text style (headline, monoData, labelBold, dst)
│   ├── constants/app_constants.dart     # konfigurasi model, threshold, route names
│   └── utils/permission_helper.dart     # request izin kamera
├── models/
│   ├── detection_result.dart       # hasil deteksi (classIndex, className, confidence)
│   ├── history_item.dart           # entri riwayat (id, classIndex, confidence, photoPath, timestamp)
│   └── ikan_model.dart             # data spesies dari ikan.json (id, nama, deskripsi, warna)
├── controllers/
│   ├── gallery_controller.dart     # logic upload galeri/kamera + parsing hasil YOLO via flutter_vision
│   ├── realtime_controller.dart    # setup & lifecycle FlutterVision untuk kamera live
│   ├── theme_controller.dart       # persist & toggle dark/light mode
│   └── locale_controller.dart      # persist & toggle bahasa ID/EN
├── services/
│   ├── ikan_repository.dart        # lazy-load ikan.json, findById/findByName
│   ├── history_repository.dart     # CRUD riwayat ke history.json (write-queue, revision notifier)
│   └── preferences_service.dart    # persist toggle notifikasi
├── views/
│   ├── splash/splash_view.dart
│   ├── shell/main_shell.dart       # IndexedStack: Home/History/Settings + tab Kamera
│   ├── home/home_view.dart
│   ├── gallery/gallery_view.dart
│   ├── realtime/realtime_view.dart
│   ├── detail/species_detail_view.dart
│   ├── history/history_view.dart
│   └── settings/settings_view.dart, about_page.dart
├── widgets/
│   ├── app_header.dart, result_card.dart, confidence_bar.dart
│   ├── main_bottom_nav.dart, responsive_center.dart, settings_widgets.dart
└── l10n/
    ├── app_id.arb, app_en.arb          # sumber string i18n
    └── app_localizations*.dart         # hasil generate (flutter gen-l10n)

assets/
├── models/best.tflite              # model YOLO terkompilasi (TFLite)
├── models/ikan.json                # metadata 6 spesies + 1 kategori "Non Ikan"
└── images/, icon/
```

---

## 4. Model Machine Learning

### 4.1 Arsitektur & Task
- **Framework**: Ultralytics YOLO, **task: `YOLOTask.detect`** (object
  detection — bounding box + label + confidence, bukan whole-image
  classification).
- **Format**: TensorFlow Lite (`best.tflite`), dijalankan on-device
  via plugin `flutter_vision` (fork lokal `packages/flutter_vision_local`).

### 4.2 Kelas Model
Model dilatih untuk **6 spesies ikan** (lihat `assets/models/ikan.json`):

| classIndex | Nama Kelas |
|---:|---|
| 0 | Ikan Baramundi |
| 1 | Ikan Belanak Merah |
| 2 | Ikan Cakalang |
| 3 | Ikan Kakap Putih |
| 4 | Ikan Kembung |
| 5 | Ikan Sarden |

Kelas ke-7 (`id: 6`, **"Non Ikan"**) **bukan kelas hasil training** —
melainkan kategori buatan aplikasi untuk menampung hasil dengan confidence
rendah, lukisan/ilustrasi, atau objek mirip ikan yang bukan ikan sungguhan.

### 4.3 Parameter Inferensi (`app_constants.dart`)

```dart
static const double confidenceThreshold      = 0.40; // ambang minimum diterima
static const double identificationThreshold  = 0.65; // ambang "yakin spesies tsb"
static const double iouThreshold              = 0.45; // non-max suppression
```

- **`confidenceThreshold` (0.40)** — di bawah ini, deteksi dibuang total
  (dianggap noise/tidak ada objek) → `GalleryError.noDetection`.
- **`identificationThreshold` (0.65)** — hasil dengan **0.40 ≤ confidence < 0.65**
  tetap "lolos" sebagai deteksi tapi **direklasifikasi jadi "Non Ikan"**.
- **`iouThreshold` (0.45)** — dipakai NMS bawaan model untuk membuang
  bounding box duplikat.

### 4.4 Pipeline Klasifikasi

```
Gambar (galeri/kamera)
   │
   ▼
FlutterVision.yoloOnImage() / camera stream (real-time)
   │  → list bounding box: { className, confidence, classIndex?, box }
   ▼
confidence >= 0.40?  ── tidak → dibuang (noDetection)
   │ ya
confidence >= 0.65?
   ├─ ya  → label = className asli, classIndex di-resolve via IkanRepository.findByName(className)
   └─ tidak → label = "non_ikan", classIndex = 6
   ▼
Ambil hasil confidence tertinggi (top-1)
   ▼
Tampilkan (ResultCard / overlay kamera) + simpan ke Riwayat Deteksi
```

> **Catatan teknis penting**: aplikasi menggunakan plugin custom lokal
> `packages/flutter_vision_local` (fork `flutter_vision 2.0.0`). Native Java
> (`FlutterVisionPlugin.java` & `Yolov8.java`) ditambal khusus untuk membaca layout
> NCHW `[1, 3, H, W]`. Hasil deteksi `yoloOnImage` dikembalikan berupa list bounding
> box dan nama label (`tag`). Kode lalu mencocokkan `tag` ke `ikan.json` via
> `IkanRepository.findByName(className)` untuk mendapatkan `classIndex` yang tepat.

### 4.5 Ekspektasi Performa per Jenis Input
(detail & matriks lengkap di `perbandingan.md`)

| Jenis Gambar | Confidence Tipikal | Hasil App |
|---|---|---|
| Foto ikan asli (sesuai 6 kelas) | ≥ 0.65 | Nama spesies yang benar |
| Lukisan/ilustrasi ikan | 0.40–0.65 (kadang < 0.40) | "Non Ikan" |
| Objek mirip ikan (bukan ikan) | < 0.40 (kadang 0.40–0.65) | "Non Ikan" / tidak terdeteksi |

---

## 5. Fitur Aplikasi & Alur Kerja

### 5.1 Splash & Navigasi Utama
- `SplashView` tampil 2 detik (logo + tagline) → `MainShell` (`IndexedStack`
  Home/History/Settings + bottom nav 4 item, tab "Kamera" push route
  terpisah tanpa mengubah tab aktif).

### 5.2 Upload Galeri/Kamera (`GalleryController` + `GalleryView`)
- Bottom sheet pilih sumber: kamera (request izin) atau galeri.
- `FlutterVision.yoloOnImage()` → `_parseResults` (async): filter threshold, resolve
  `classIndex` via nama kelas, ambil top-1 (`take(1)`).
- Error ditangani via enum `GalleryError` (modelLoadFailed/noDetection/unknown)
  → pesan ber-locale.
- Hasil "Non Ikan" → `ResultCard` tidak bisa di-tap; hasil valid → tap
  navigasi ke `SpeciesDetailView`.

### 5.3 Deteksi Real-time (`RealtimeController` + `RealtimeView`)
- Deteksi real-time menggunakan stream dari paket `camera` dikombinasikan dengan `FlutterVision`, `setNumItemsThreshold(1)`
  (hanya tampilkan 1 box confidence tertinggi).
- Top-1 result dipantau via `Timer` stabilitas 1.5 detik (reset jika spesies
  berubah) + `AnimationController` progress bar "Mengidentifikasi...".
- Jika stabil 1.5 detik dan bukan "Non Ikan" → `capturePhoto(withOverlays: true)`
  → auto-navigate ke `SpeciesDetailView`.
- Kamera otomatis pause saat masuk halaman detail, resume saat kembali;
  `WidgetsBindingObserver` melepas kamera saat app di-background.

### 5.4 Halaman Detail Spesies (`SpeciesDetailView`)
- `SliverAppBar` dengan foto hasil capture (atau fallback gradient + ikon),
  bounding box & label tetap terlihat bila dari realtime.
- Menampilkan badge confidence, nama spesies, deskripsi & warna khas dari
  `ikan.json` (via `IkanRepository.findById`).
- "Non Ikan" (id 6) juga punya halaman detail sendiri (deskripsi generik).

### 5.5 Riwayat Deteksi (`HistoryRepository` + `HistoryView`)
- Setiap deteksi valid disimpan ke `history.json` di app documents
  directory (bukan SharedPreferences lagi — diganti karena masalah race
  condition); foto hasil capture ikut disimpan ke folder lokal.
- Write-queue (chain `Future`) mencegah lost-update saat `add`/`deleteById`/
  `clear` terpanggil hampir bersamaan.
- `ValueNotifier<int> revision` membuat `HistoryView` auto-reload setiap ada
  perubahan data (fix bug riwayat tidak update tanpa restart app).
- Swipe-to-delete per item (dengan konfirmasi) + tombol "Hapus Semua".
- `className` yang disimpan = nama kanonik dari `ikan.json` (`species.nama`),
  bukan label mentah model, agar konsisten dengan halaman detail.

### 5.6 Pengaturan (`SettingsView`)
- Profil statis (nama & NIM mahasiswa, tidak ada sistem akun/login).
- Section **Preferences**: toggle notifikasi, mode gelap, pilihan bahasa
  (ID/EN) — semua persisted lokal.
- Section **More**: Pusat Bantuan, Kebijakan Privasi (placeholder dialog),
  Tentang Aplikasi (`AboutPage`).
- **Logout** — karena tidak ada sistem akun sungguhan, tombol ini menutup
  aplikasi penuh via `SystemNavigator.pop()` setelah dialog konfirmasi.

### 5.7 Responsivitas & Tema
- `ResponsiveCenter` (max-width 640–720) + `responsiveValue()` membuat
  layout adaptif dari ponsel kecil hingga tablet (grid Home 2/4 kolom,
  padding & expandedHeight skala terhadap ukuran layar).
- Dark mode penuh (semua warna via `AppColors` dinamis) + i18n penuh
  ID/EN (≈50 string key di `.arb`).

---

## 6. Branding & Build

- Nama aplikasi: **"Fish Scan"** (label Android/iOS/web), package internal
  masih bernama `yoloikan` (nama proyek Flutter, tidak diubah).
- App icon: lingkaran putih + ikon gelombang (waves) navy di atas gradient
  navy `#001E40` → `#003366`, sesuai logo di `SplashView` — digenerate via
  `flutter_launcher_icons` (mipmap Android, AppIcon iOS, icon web).
- Build release: minify + shrink resources aktif (`isMinifyEnabled`,
  `isShrinkResources`, ProGuard rules custom untuk Flutter +
  `com.ultralytics.yolo.**` + TFLite).

---

## 7. Hasil & Status Proyek Saat Ini

- **Status fungsional**: seluruh fitur inti (upload galeri/kamera, deteksi
  real-time, detail spesies, riwayat deteksi, dark mode, i18n ID/EN,
  pengaturan) **selesai dan berjalan** — `flutter analyze` konsisten 0 issues
  di setiap update.
- **Bug-bug & masalah teknis signifikan yang sudah diperbaiki**:
  - Crash `SIGSEGV` native pada `ultralytics_yolo` pada perangkat tertentu →
    diganti dengan paket fork lokal `packages/flutter_vision_local` (ditambal untuk layout NCHW `[1, 3, H, W]`) + paket `camera`.
  - `classIndex` salah pada hasil upload galeri (selalu fallback ke 0) →
    fixed via resolusi berdasarkan `className` (`IkanRepository.findByName`).
  - Riwayat deteksi tidak konsisten/hilang akibat race condition pada
    `SharedPreferences` → diganti penyimpanan file JSON dengan write-queue.
  - Riwayat tidak auto-refresh setelah scan baru → fixed dengan
    `ValueNotifier` reactive reload.
  - Klasifikasi "Non Ikan" untuk lukisan/objek non-ikan, threshold ganda
    (0.40 / 0.65) untuk memisahkan "tidak terdeteksi" vs "terdeteksi tapi
    tidak yakin".
- **Build**: `flutter build apk --release` berhasil, ukuran **±118.3MB**,
  dapat diinstal & diuji manual di device Android.
- **Yang BELUM selesai untuk rilis ke Play Store** (keputusan ada di tangan
  pengembang):
  1. `applicationId` masih placeholder `com.example.yoloikan` — harus
     diganti ke package ID unik.
  2. Belum ada keystore produksi (`android/key.properties` belum dibuat) —
     APK release saat ini masih ditandatangani dengan **debug signing**
     sebagai fallback.
  3. Pengujian performa model pada data nyata (foto asli/lukisan/objek
     mirip ikan) baru berupa **ekspektasi teoritis** — tabel hasil uji
     aktual di `perbandingan.md` §5 masih kosong, perlu diisi manual via
     pengujian device nyata.
- **Dokumentasi pendukung** sudah lengkap: `AGENT.md` (changelog & progress
  tracker, 37 update), `studi.md` (dokumen ini), `transfer_knowledge.md`
  (panduan retraining/ganti model), `perbandingan.md` (analisis performa
  model per jenis input).

---

## 8. Referensi

- Ultralytics YOLO docs: https://docs.ultralytics.com/
- Package `ultralytics_yolo` (pub.dev): https://pub.dev/packages/ultralytics_yolo
- TensorFlow Lite: https://www.tensorflow.org/lite
- Flutter docs: https://docs.flutter.dev/
