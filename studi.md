# Studi — Dasar Teori & Konfigurasi Model Fish Scan

> Dokumen ini merangkum dasar teori, arsitektur model, dan konfigurasi yang dipakai
> aplikasi **Fish Scan** untuk mendeteksi/klasifikasi spesies ikan dari gambar
> (galeri) maupun kamera real-time.

---

## 1. Arsitektur Model

- **Framework**: [Ultralytics YOLO](https://docs.ultralytics.com/) via package
  `ultralytics_yolo` (v0.6.2) — wrapper Flutter untuk menjalankan model `.tflite`
  secara on-device (Android/iOS), tanpa koneksi internet.
- **Format model**: `assets/models/best_float32.tflite` (TensorFlow Lite,
  hasil export dari model YOLO yang sudah di-*training*/fine-tune).
- **Task**: `YOLOTask.detect` — model melakukan **object detection**
  (bounding box + label kelas + confidence score), bukan klasifikasi
  gambar penuh (whole-image classification).
- **Eksekusi**: `useGpu: false` — inferensi dijalankan di CPU agar stabil
  di berbagai perangkat (beberapa device Android punya delegasi GPU/NNAPI
  yang tidak kompatibel dengan operator tertentu pada model TFLite).

## 2. Kelas / Label

Model dilatih untuk mendeteksi **6 spesies ikan** (lihat `assets/models/ikan.json`):

| classIndex | Nama Kelas         |
|-----------:|--------------------|
| 0 | Ikan Baramundi |
| 1 | Ikan Belanak Merah |
| 2 | Ikan Cakalang |
| 3 | Ikan Kakap Putih |
| 4 | Ikan Kembung |
| 5 | Ikan Sarden |

Kelas ke-7 (`id: 6`, **"Non Ikan"**) **bukan kelas hasil training model** —
melainkan kategori buatan aplikasi (lihat bagian 4) yang dipakai untuk
menampung:
1. Lukisan/ilustrasi/gambar ikan yang bukan foto nyata,
2. Objek mirip ikan tapi bukan ikan (sampah laut, terumbu karang, biota laut lain, dll),
3. Objek lain yang tidak dikenali model dengan baik.

## 3. Parameter Inferensi (`lib/core/constants/app_constants.dart`)

```dart
static const double confidenceThreshold   = 0.40; // ambang minimum deteksi diterima
static const double identificationThreshold = 0.65; // ambang "yakin ini spesies tsb"
static const double iouThreshold          = 0.45; // non-max suppression
```

- **`confidenceThreshold` (0.40)** — hasil deteksi dari model dengan confidence
  di bawah ini **dibuang sepenuhnya** (dianggap noise / tidak ada objek).
- **`identificationThreshold` (0.65)** — ambang kedua di atas threshold pertama.
  Hasil deteksi dengan confidence **0.40 ≤ x < 0.65** masih "lolos" sebagai deteksi,
  tapi **direklasifikasi menjadi "Non Ikan"** karena dianggap belum cukup yakin
  untuk diklaim sebagai spesies tertentu.
- **`iouThreshold` (0.45)** — dipakai oleh algoritma Non-Max Suppression (NMS)
  bawaan model untuk membuang bounding box duplikat/tumpang-tindih.

## 4. Alur Klasifikasi (Pipeline)

```
Gambar (galeri/kamera)
   │
   ▼
YOLO.predict() / YOLOView (real-time)
   │  → list bounding box: { className, confidence, classIndex?, box }
   ▼
Filter: confidence >= confidenceThreshold (0.40)?
   │  tidak → dibuang
   ▼ ya
confidence >= identificationThreshold (0.65)?
   │
   ├─ ya → label = className asli, classIndex = lookup di ikan.json (by name)
   │
   └─ tidak → label = "non_ikan", classIndex = 6 ("Non Ikan")
   ▼
Ambil hasil dengan confidence tertinggi (top-1)
   │
   ▼
Tampilkan di UI (ResultCard / overlay kamera) + simpan ke Riwayat Deteksi
```

> **Catatan teknis**: pada `ultralytics_yolo 0.6.2`, hasil `YOLO.predict()`
> (single image, dipakai di Galeri) **tidak menyertakan key `classIndex`**
> pada map box — hanya `className` (string). Karena itu, `classIndex` yang
> benar di-resolve ulang via `IkanRepository.findByName(className)` yang
> mencocokkan nama kelas ke `ikan.json`.

## 5. Implikasi untuk Tiga Jenis Input Gambar

| Jenis Gambar | Perilaku yang Diharapkan |
|---|---|
| **Foto ikan asli** (sesuai 6 kelas training) | Confidence tinggi (umumnya > 0.65) → diklasifikasikan sebagai spesies yang benar, masuk Riwayat Deteksi dengan nama spesies. |
| **Lukisan/ilustrasi ikan** | Model masih bisa mendeteksi "bentuk ikan" (karena fitur visual seperti sirip/ekor mirip), tapi confidence biasanya lebih rendah karena tekstur/warna berbeda dari data latih (foto asli) → sering jatuh ke rentang 0.40–0.65 → direklasifikasi "Non Ikan". |
| **Objek mirip ikan (bukan ikan)** | Confidence biasanya rendah (di bawah 0.65, kadang di bawah 0.40) → "Non Ikan" atau tidak terdeteksi sama sekali (`noDetection`). |

Lihat **`perbandingan.md`** untuk analisis lebih rinci & matriks perbandingan,
serta **`transfer_knowledge.md`** untuk panduan retraining/penyesuaian model
agar performa pada lukisan/ilustrasi dapat ditingkatkan.

## 6. Referensi

- Ultralytics YOLO docs: https://docs.ultralytics.com/
- Package `ultralytics_yolo` (pub.dev): https://pub.dev/packages/ultralytics_yolo
- TensorFlow Lite: https://www.tensorflow.org/lite
