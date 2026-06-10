# Transfer Knowledge — Fish Scan

> Dokumen serah-terima pengetahuan (knowledge transfer) untuk pengembang
> selanjutnya yang akan melanjutkan, memelihara, atau melatih ulang model
> pada project **Fish Scan**.

---

## 1. Gambaran Umum Project

Fish Scan adalah aplikasi Flutter untuk **identifikasi spesies ikan**
melalui:
- **Upload Galeri**: pilih foto dari galeri/kamera → dianalisis sekali (`YOLO.predict`)
- **Live Detection**: kamera real-time → deteksi terus-menerus (`YOLOView`),
  auto-navigasi ke halaman detail saat deteksi stabil 1.5 detik

Hasil deteksi disimpan ke **Riwayat Deteksi** secara lokal (file `history.json`
di folder dokumen aplikasi, lihat `lib/services/history_repository.dart`).

## 2. Komponen Inti yang Berkaitan dengan Model

| File | Peran |
|---|---|
| `assets/models/best_float32.tflite` | Model YOLO hasil training/fine-tune (TFLite) |
| `assets/models/ikan.json` | Metadata 6 spesies ikan + 1 kategori "Non Ikan" (nama, deskripsi, warna) |
| `lib/core/constants/app_constants.dart` | Path model, task, threshold confidence/identifikasi/IoU |
| `lib/services/ikan_repository.dart` | Load & lookup `ikan.json` (`findById`, `findByName`) |
| `lib/controllers/gallery_controller.dart` | Inferensi single-image + parsing hasil |
| `lib/controllers/realtime_controller.dart`, `lib/views/realtime/realtime_view.dart` | Inferensi real-time via `YOLOView` |

## 3. Cara Mengganti / Melatih Ulang Model (Transfer Learning)

Model `best_float32.tflite` adalah hasil **transfer learning** dari model
dasar YOLO (mis. YOLOv8n/YOLOv11n) yang di-*fine-tune* dengan dataset foto
ikan untuk 6 kelas pada bagian §2 `studi.md`. Untuk melatih ulang / menambah
kelas:

1. **Siapkan dataset** — kumpulkan foto ikan per spesies (format YOLO:
   gambar + label `.txt` berisi `class_id x_center y_center width height`
   ternormalisasi). Sertakan variasi:
   - Foto asli dari berbagai sudut, pencahayaan, latar belakang
   - (Opsional, jika ingin app lebih akurat pada lukisan/ilustrasi) tambahkan
     sebagian data lukisan/ilustrasi ikan berlabel sama, ATAU buat **kelas
     baru** "lukisan_ikan" agar model bisa membedakan secara eksplisit
   - Contoh negatif: objek mirip ikan tapi bukan ikan (sampah laut, terumbu
     karang, biota lain) — bisa sebagai background/negative samples
2. **Training** — gunakan Ultralytics CLI/Python:
   ```bash
   pip install ultralytics
   yolo detect train data=dataset.yaml model=yolov8n.pt epochs=100 imgsz=640
   ```
   `dataset.yaml` mendefinisikan path train/val dan daftar nama kelas
   (urutan **harus konsisten** dengan `classIndex` di `ikan.json`).
3. **Export ke TFLite**:
   ```bash
   yolo export model=runs/detect/train/weights/best.pt format=tflite imgsz=640
   ```
   Hasilnya `best_float32.tflite` (atau varian `float16`/`int8` untuk model
   lebih kecil — perhatikan trade-off ukuran vs akurasi vs kecepatan).
4. **Integrasi ke app**:
   - Salin file `.tflite` baru ke `assets/models/`, update
     `AppConstants.modelPath` jika nama file berbeda.
   - Update `assets/models/ikan.json` jika ada penambahan/perubahan kelas
     (urutan `id` harus sama persis dengan urutan kelas saat training).
   - Jalankan `flutter pub get` lalu test di device nyata
     (model TFLite custom **tidak bisa diuji penuh di emulator** untuk
     beberapa delegasi GPU/NNAPI — gunakan `useGpu: false`, sudah default).

## 4. Catatan Penting / Pitfall yang Sudah Ditemukan

- **`ultralytics_yolo 0.6.2` single-image predict tidak mengembalikan
  `classIndex`** pada hasil box — hanya `className`. Resolusi `classIndex`
  dilakukan via pencocokan nama (`IkanRepository.findByName`). Jika model
  baru memakai **nama kelas yang berbeda** dari `ikan.json`, lookup ini akan
  gagal (fallback ke "Non Ikan"). **Pastikan nama kelas hasil training sama
  persis (case-insensitive) dengan field `nama` di `ikan.json`.**
- **Threshold ganda** (`confidenceThreshold` 0.40, `identificationThreshold`
  0.65) adalah workaround karena model **tidak punya kelas "Non Ikan"
  sendiri**. Jika model baru dilatih dengan kelas negatif eksplisit
  (mis. "non_ikan" / "lukisan"), pertimbangkan untuk:
  - Menambahkan kelas tsb ke `ikan.json` dengan `id` sesuai urutan training, dan
  - Menyederhanakan/menghapus logika reklasifikasi berbasis
    `identificationThreshold` di `gallery_controller.dart` &
    `realtime_view.dart`, karena model sudah bisa menjawab langsung.
- **minSdk Android = 26** — syarat minimum dari `ultralytics_yolo`.
- Inferensi CPU (`useGpu: false`) dipilih demi stabilitas lintas-device;
  jika model baru diuji stabil dengan GPU delegate, bisa dipertimbangkan
  untuk meningkatkan FPS pada Live Detection.

## 5. Dokumen Terkait

- `studi.md` — dasar teori, arsitektur, & alur klasifikasi
- `perbandingan.md` — analisis performa terhadap 3 jenis input gambar
  (foto asli, lukisan/ilustrasi, objek mirip ikan)
- `AGENT.md` — riwayat perubahan & status fitur project secara keseluruhan
