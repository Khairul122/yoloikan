# Perbandingan — Performa Model & Aplikasi pada 3 Jenis Gambar

> Analisis perilaku model/aplikasi **Fish Scan** ketika diberi tiga jenis
> input: (1) foto ikan asli, (2) lukisan/ilustrasi ikan, dan (3) gambar/objek
> yang mirip ikan tapi bukan ikan. Analisis ini berdasarkan **logika kode**
> (`gallery_controller.dart`, `realtime_view.dart`, `app_constants.dart`)
> dan karakteristik umum model deteksi berbasis YOLO yang dilatih dari foto.
>
> Bagian "Hasil Uji Aktual" disediakan sebagai template untuk diisi setelah
> pengujian manual dengan dataset/sample nyata di device.

---

## 1. Ringkasan Mekanisme Penentuan Hasil

```
confidence < 0.40           → dibuang (noDetection)
0.40 ≤ confidence < 0.65     → "Non Ikan" (classIndex 6)
confidence ≥ 0.65            → spesies sesuai className (classIndex 0–5)
```

Hanya hasil dengan confidence tertinggi (top-1) yang ditampilkan/disimpan.

## 2. Matriks Perbandingan (Ekspektasi Berdasarkan Karakteristik Model)

| Aspek | Foto Ikan Asli | Lukisan / Ilustrasi Ikan | Objek Mirip Ikan (bukan ikan) |
|---|---|---|---|
| **Kesesuaian dengan data latih** | Tinggi — model dilatih dari foto sejenis | Rendah-sedang — bentuk mirip tapi tekstur/warna/gaya berbeda | Rendah — fitur visual berbeda (tidak ada sirip/ekor/bentuk tubuh ikan yang konsisten) |
| **Confidence yang diharapkan** | Umumnya **≥ 0.65** (tinggi) | Bervariasi, sering **0.40–0.65** (sedang), kadang < 0.40 jika gaya sangat abstrak | Umumnya **< 0.40**, kadang 0.40–0.65 jika bentuk mirip ikan (mis. cumi-cumi, sampah berbentuk lonjong) |
| **Hasil klasifikasi app** | Nama spesies spesifik (0–5) | "Non Ikan" (paling sering), kadang spesies salah jika gaya realistis | "Non Ikan" atau `noDetection` ("Tidak ada ikan terdeteksi") |
| **Disimpan ke Riwayat?** | Ya, dengan nama spesies | Ya, sebagai "Non Ikan" (tetap bisa dibuka detailnya) | Ya jika confidence ≥ 0.40, sebaliknya tidak ada hasil sama sekali |
| **Risiko utama** | False classification antar spesies mirip (mis. Kembung vs Sarden — keduanya ikan kecil pelagis) | False negative (lukisan realistis terdeteksi sebagai spesies asli, bukan "Non Ikan") | False positive (objek tertentu mirip bentuk ikan terdeteksi sebagai "Non Ikan" dengan confidence cukup tinggi, atau bahkan sebagai spesies jika sangat mirip) |

## 3. Analisis per Kategori

### 3.1 Foto Ikan Asli
- **Kekuatan**: Ini adalah domain utama model — performa terbaik diharapkan
  di sini karena dataset training (umumnya) terdiri dari foto asli.
- **Faktor yang memengaruhi akurasi**:
  - Sudut pandang ikan (dari atas/samping vs close-up)
  - Pencahayaan & latar belakang (air keruh, dek kapal, meja, dll.)
  - Kemiripan antar spesies dalam dataset (mis. Ikan Kembung vs Sarden —
    sama-sama ikan kecil bertubuh memanjang dengan warna keperakan/biru)
- **Potensi masalah**: jika confidence pas di ambang 0.65 (borderline),
  hasil bisa berubah-ubah antara "spesies X" dan "Non Ikan" hanya karena
  sedikit perbedaan sudut/cahaya — perlu diuji dengan beberapa foto per
  spesies untuk memastikan stabilitas.

### 3.2 Lukisan / Ilustrasi Ikan
- **Kekuatan model**: YOLO tetap dapat mendeteksi *bentuk* (shape) objek
  ikan (siluet badan, sirip, ekor) meski gaya visualnya berbeda dari foto,
  karena fitur geometris (edge, kontur) sering masih relevan.
- **Kelemahan**: Tekstur, warna, dan gradasi pada lukisan/ilustrasi
  umumnya jauh berbeda dari foto asli → confidence classification
  cenderung turun ke rentang 0.40–0.65, sehingga **direklasifikasi
  "Non Ikan"** oleh app — ini **sesuai desain** (lihat deskripsi `id: 6`
  di `ikan.json`: "Akurasi deteksi pada gambar lukisan/ilustrasi
  bergantung pada data latih model").
- **Skenario gagal**: lukisan/ilustrasi yang sangat realistis (hyperrealism)
  berpotensi tetap dikenali sebagai spesies tertentu dengan confidence
  tinggi — ini adalah **false positive identifikasi spesies** yang sulit
  dihindari tanpa data latih lukisan eksplisit (lihat `transfer_knowledge.md`
  §3 untuk opsi penambahan kelas khusus).

### 3.3 Gambar/Objek Mirip Ikan (Bukan Ikan)
- Contoh: terumbu karang berbentuk memanjang, sampah plastik di air, alat
  pancing, cumi-cumi/gurita, tanaman air.
- **Kekuatan model**: Karena model tidak dilatih untuk objek-objek ini,
  confidence umumnya rendah → sering jatuh di bawah `confidenceThreshold`
  (0.40) sehingga app menampilkan **"Tidak ada ikan terdeteksi"**
  (`GalleryError.noDetection`) — hasil yang **benar/aman**.
- **Skenario gagal**: objek dengan kemiripan struktural tinggi (cumi-cumi
  punya tubuh memanjang + "sirip" mirip ikan) bisa memicu confidence
  0.40–0.65 → "Non Ikan" (masih benar secara label akhir, meski sempat
  "terdeteksi"). Risiko terbesar adalah objek yang **sangat mirip** salah
  satu dari 6 spesies (mis. ikan mainan/replika) → bisa salah
  diklasifikasikan sebagai spesies asli jika confidence ≥ 0.65.

## 4. Rekomendasi Peningkatan

1. **Tambah data lukisan/ilustrasi berlabel "Non Ikan" secara eksplisit**
   pada training set, agar model belajar membedakan gaya foto vs lukisan,
   bukan hanya mengandalkan threshold confidence.
2. **Uji confidence riil** untuk masing-masing kategori (isi tabel §5 di
   bawah) untuk memvalidasi apakah ambang `0.40` / `0.65` saat ini sudah
   tepat, atau perlu disesuaikan (mis. dinaikkan jika banyak lukisan lolos
   sebagai spesies asli, atau diturunkan jika terlalu banyak foto asli
   jatuh ke "Non Ikan").
3. **Dataset tambahan untuk objek mirip ikan** (negative samples) agar
   model lebih percaya diri membedakan ikan vs non-ikan, mengurangi
   ketergantungan pada threshold buatan.

## 5. Hasil Uji Aktual (Template — isi setelah pengujian manual)

| No | Jenis Gambar | Sample | Confidence | Hasil App | Sesuai Ekspektasi? | Catatan |
|---|---|---|---|---|---|---|
| 1 | Foto ikan asli | (nama file/spesies) | | | | |
| 2 | Foto ikan asli | | | | | |
| 3 | Lukisan/ilustrasi ikan | | | | | |
| 4 | Lukisan/ilustrasi ikan | | | | | |
| 5 | Objek mirip ikan (bukan ikan) | | | | | |
| 6 | Objek mirip ikan (bukan ikan) | | | | | |

> Cara mengisi: jalankan app (`flutter run` / APK release), lakukan scan
> via Upload Galeri untuk tiap sample, catat confidence yang ditampilkan
> di halaman detail (atau tambahkan `debugPrint` sementara di
> `gallery_controller.dart` untuk melihat confidence mentah sebelum
> reklasifikasi).
