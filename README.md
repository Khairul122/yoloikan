# Fish Scan 🐟

Aplikasi Flutter untuk **identifikasi spesies ikan** menggunakan model
deteksi objek **YOLO (TensorFlow Lite)** yang berjalan langsung di perangkat
(on-device, tanpa koneksi internet).

## Fitur Utama

- **Upload Galeri** — pilih foto ikan dari galeri/kamera, lalu dianalisis
  untuk menentukan spesies.
- **Live Detection** — deteksi real-time melalui kamera dengan bounding box,
  auto-navigasi ke halaman detail saat deteksi stabil.
- **Detail Spesies** — nama, deskripsi, dan tingkat keyakinan (confidence)
  untuk setiap hasil deteksi.
- **Riwayat Deteksi** — riwayat hasil scan tersimpan secara lokal (file
  `history.json` di penyimpanan aplikasi), bisa dihapus per item.
- **Pengaturan** — mode gelap/terang, bahasa (Indonesia/English), info
  aplikasi, dan logout (menutup aplikasi).
- **Mendukung 6 spesies ikan**: Baramundi, Belanak Merah, Cakalang, Kakap
  Putih, Kembung, Sarden — serta kategori "Non Ikan" untuk gambar yang bukan
  foto ikan asli (lukisan, objek mirip ikan, dll).

## Arsitektur

Project mengikuti pola **MVC**:

```
lib/
├── main.dart, app/app.dart        # Entry point & routing
├── core/                          # Constants (warna, teks, konfigurasi model)
├── models/                        # Data model (DetectionResult, HistoryItem, dll)
├── controllers/                   # State management (ChangeNotifier)
├── services/                      # IkanRepository, HistoryRepository, dll
├── views/                         # Halaman (home, gallery, realtime, history, settings, detail, splash)
└── widgets/                       # Komponen UI yang dapat dipakai ulang

assets/
├── models/   # best_float32.tflite (model YOLO) + ikan.json (metadata spesies)
└── images/
```

## Model & Konfigurasi Deteksi

- Model: `assets/models/best_float32.tflite` (YOLO via package
  `ultralytics_yolo`), task: object detection.
- Konfigurasi threshold ada di `lib/core/constants/app_constants.dart`:
  - `confidenceThreshold` (0.40) — ambang minimum hasil deteksi diterima
  - `identificationThreshold` (0.65) — ambang minimum untuk diklaim sebagai
    spesies tertentu (di bawah ini direklasifikasi "Non Ikan")

Penjelasan lebih lengkap mengenai dasar teori, alur klasifikasi, dan analisis
performa tersedia di:
- [`studi.md`](studi.md) — dasar teori & arsitektur model
- [`transfer_knowledge.md`](transfer_knowledge.md) — panduan retraining/ganti model
- [`perbandingan.md`](perbandingan.md) — analisis performa untuk foto ikan asli,
  lukisan/ilustrasi, dan objek mirip ikan
- [`AGENT.md`](AGENT.md) — riwayat perubahan & status fitur project

## Menjalankan Project

```bash
flutter pub get
flutter gen-l10n
flutter run
```

Build APK release:

```bash
flutter build apk --release
```

> **Catatan**: `minSdk` Android diset ke `26` (syarat dari `ultralytics_yolo`).
> Inferensi model dijalankan di CPU (`useGpu: false`) untuk stabilitas lintas
> perangkat.

## Persyaratan

- Flutter SDK `^3.8.1`
- Android: minSdk 26+
- Perangkat dengan kamera (untuk fitur Live Detection)
