# Progres Audit & Perbaikan — yoloikan (FishScan)

Catatan progres audit compatibility Flutter ↔ model YOLO (folder `detect/` hasil training) dan perbaikan bug yang ditemukan. Fokus: **Android**.

## Status ringkas

| # | Item | Status |
|---|---|---|
| 1 | Mismatch nama kelas "Cakalang" (`ikan_cakalang` vs `Ikan Cakalang`) | ✅ Fixed |
| 2 | Warning LiteRT "Input/Output tensor not found" | ⚠️ Investigasi selesai — self-healing via fallback, **bukan** penyebab bug deteksi |
| 3 | Race condition `GalleryController._initYolo()` | ✅ Fixed |
| 4 | `ImagePicker` exception tak tertangkap | ✅ Fixed |
| 5 | Toggle notifikasi non-fungsional (dead feature) | ✅ Fixed |
| 6 | Dead code `permission_helper.dart` | ✅ Fixed |
| 7 | Build APK gagal (Java heap space) | ✅ Fixed |
| 8 | File backup ikut ter-bundle ke APK | ✅ Fixed |
| 9 | **Gambar ikan tidak terdeteksi (confidence ~0% untuk semua kelas)** | ✅ Root cause ditemukan, fix diterapkan, **sedang tahap verifikasi di device** |

---

## Detail per item

### 1. Mismatch nama kelas "Cakalang"
Metadata model (`best.tflite`) punya kelas `"ikan_cakalang"` (underscore, dari `data.yaml` training), sementara `assets/models/ikan.json` pakai `"Ikan Cakalang"` (spasi). `IkanRepository.findByName` mencocokkan berdasarkan string — mismatch ini bikin resolusi `classIndex` untuk Cakalang selalu jatuh ke `nonFishClassIndex`, sehingga tap-to-detail gagal khusus untuk spesies ini.

**Fix:** `lib/services/ikan_repository.dart` — `findByName` sekarang menormalisasi underscore↔spasi sebelum membandingkan.

### 2. Warning LiteRT "Input/Output tensor not found"
Plugin `ultralytics_yolo` 0.6.2 (backend LiteRT 2.x) mengharapkan nama tensor `images`/`Identity` sesuai konvensi. Sempat dicoba fix dengan re-export model (downgrade ke `ultralytics==8.4.82` agar tidak pakai pipeline LiteRT-only yang cuma jalan di Linux/macOS). **Hasil investigasi: warning yang sama tetap muncul bahkan dengan model original yang belum disentuh sama sekali** — jadi ini bukan regresi dari re-export, dan kemungkinan besar karena LiteRT butuh *signature definition* resmi (bukan sekadar nama tensor mentah yang cocok).

Meski begitu, **ini bukan bug fungsional** — ada fallback di `ObjectDetector.kt` (native plugin) yang menghitung ulang shape lewat `outputElementCounts / (labels.size + 4)`, dan hasilnya tetap benar (`out1=10, out2=8400`, sesuai 6 kelas + 4 koordinat box). Model tetap bisa inferensi normal walau warning ini muncul di log.

**Keputusan:** dibiarkan sebagai warning kosmetik, model dikembalikan ke versi original (`detect/train/weights/best.tflite`, md5 `3aba1f6a6022b5fc916a29c0520d11ac`) karena re-export tidak memberi manfaat nyata dan menambah risiko.

### 3–4. Bug di `gallery_controller.dart`
- **Race condition**: dua panggilan `pickAndDetect()` bersamaan (mis. tap FAB dua kali) bisa saling men-dispose instance `_yolo` milik satu sama lain. Fix: guard `if (_isLoading) return;` di awal method.
- **`ImagePicker` exception tak tertangkap**: `picker.pickImage()` sebelumnya di luar blok `try/catch`. Fix: pindahkan seluruh alur (termasuk pick image) ke dalam `try`, `_isLoading` di-set sebelum picker dibuka.

### 5–6. Cleanup dead code
- `PreferencesService` (notifikasi) dihapus total — tidak ada sistem notifikasi sungguhan di app, togglenya cuma menyimpan boolean yang tak pernah dibaca. Diganti jadi `ActionRow` dengan dialog "fitur dalam pengembangan" (konsisten dengan Help Center/Privacy Policy).
- `PermissionHelper.requestStorage()` dan `isCameraGranted()` dihapus — tidak dipanggil dari mana pun.

### 7–8. Build pipeline
- `android/gradle.properties`: `org.gradle.jvmargs` dinaikkan dari `-Xmx2G` ke `-Xmx4G` (build sempat gagal "Java heap space" saat Jetifier transform; juga sempat exhausted karena daemon Gradle lama yang macet memakan >1GB RAM — sudah dibersihkan via `gradlew --stop`).
- File backup model (`best.tflite.bak`) sempat ikut ter-bundle ke APK karena `pubspec.yaml` men-declare seluruh folder `assets/models/`. Dipindah keluar ke `detect/train/weights/`.

### 9. Gambar ikan tidak terdeteksi — **root cause & fix**

**Gejala:** upload foto ikan di menu Gallery → selalu "tidak ada ikan terdeteksi", walau model punya mAP50 92% saat training/validasi.

**Diagnosis:** ditambahkan debug logging sementara di `gallery_controller.dart` untuk melihat confidence mentah (`predict()` dengan `confidenceThreshold: 0.0`). Hasilnya: 30 box terdeteksi, tapi confidence tertinggi cuma **3.7%** dan sisanya turun eksponensial sampai < 0.001% — pola khas model yang *bekerja normal secara matematis* tapi kontennya memang tidak dikenali sama sekali (bukan sekadar di bawah threshold kalibrasi).

**Root cause:** `YOLOPlugin.kt:202` (kode native plugin `ultralytics_yolo`) men-decode gambar dengan `BitmapFactory.decodeByteArray()` **tanpa mengoreksi EXIF orientation**. Foto dari kamera HP (terutama potret) biasanya disimpan sebagai piksel landscape + flag rotasi EXIF; kalau flag ini diabaikan, ikan yang tampak tegak di galeri terbaca miring ~90° oleh model — cukup untuk membuat confidence jatuh ke hampir nol di semua kelas.

**Fix:** karena ini bug di package vendor (tidak bisa ditambal permanen, akan hilang saat `flutter pub get`), koreksi dilakukan di sisi Dart sebelum bytes dikirim ke native:
- Tambah dependency `image: ^4.8.0` (sebelumnya cuma transitive lewat `image_picker`) ke `pubspec.yaml`.
- `gallery_controller.dart`: sebelum `_yolo!.predict()`, gambar di-decode via `img.decodeImage()`, rotasi EXIF di-"bake" ke piksel via `img.bakeOrientation()`, lalu di-encode ulang jadi JPEG — memastikan native plugin selalu menerima gambar yang sudah tegak lurus.

**Status:** APK dengan fix sudah di-build & diinstal ke device (Realme RMX3830), **sedang menunggu hasil tes ulang** dari user untuk konfirmasi fix bekerja.

---

## Yang masih pending / belum diverifikasi
- [ ] Konfirmasi fix EXIF di atas benar-benar membuat foto ikan terdeteksi dengan confidence tinggi di device.
- [ ] Realtime view (`realtime_view.dart`, kamera langsung) — belum diuji, kemungkinan tidak kena bug EXIF ini karena input dari CameraX stream (bukan file JPEG dari galeri), tapi belum dikonfirmasi.
- [ ] iOS (`Info.plist` belum ada `NSCameraUsageDescription`/`NSPhotoLibraryUsageDescription`) — di luar scope sesi ini (fokus Android per permintaan user).

## File yang diubah sesi ini
- `lib/services/ikan_repository.dart`
- `lib/controllers/gallery_controller.dart`
- `lib/views/settings/settings_view.dart`
- `lib/core/utils/permission_helper.dart`
- `lib/services/preferences_service.dart` (dihapus)
- `android/gradle.properties`
- `pubspec.yaml` / `pubspec.lock` (tambah dependency `image`)
- `assets/models/best.tflite` (dikembalikan ke versi original setelah percobaan re-export)
