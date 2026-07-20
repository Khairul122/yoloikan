# Laporan Pengujian Blackbox — Fish Scan (yoloikan)

Dokumen ini berisi dokumentasi dan hasil **Pengujian Blackbox (Blackbox Testing)** untuk aplikasi **Fish Scan**. Pengujian ini difokuskan untuk memvalidasi fungsionalitas antarmuka (UI/UX) dan kecocokan alur logika bisnis (termasuk validasi error, izin perangkat, batasan threshold, dan reaktivitas data) tanpa menguji baris kode internal secara langsung.

---

## 1. Metodologi Pengujian
- **Jenis Pengujian**: Pengujian Blackbox Fungsional.
- **Metode**: *Equivalence Partitioning* (pembagian kelas input seperti rentang threshold confidence) dan *Boundary Value Analysis* (pengujian batas nilai seperti batas izin ditolak, limit waktu deteksi, dan threshold minimum).
- **Lingkungan Uji (Test Environment)**:
  - **Perangkat Fisik**: Realme (RMX3830) / Android Emulator
  - **Sistem Operasi**: Android (minSdk 26, compileSdk 36)
  - **Format Model ML**: TFLite (`best.tflite`) - 6 Kelas Spesies Ikan + 1 Kategori "Non Ikan" buatan aplikasi.

---

## 2. Parameter Uji Thresholding (Logika Bisnis)
Aplikasi menerapkan logika batas (*threshold*) ganda untuk menyaring hasil deteksi model YOLO:
- **`Confidence < 0.40`**: Objek diabaikan (dianggap noise / tidak ada deteksi).
- **`0.40 <= Confidence < 0.65`**: Objek terdeteksi, namun dikelompokkan sebagai **"Non Ikan"** (terdeteksi tapi tingkat keyakinan rendah).
- **`Confidence >= 0.65`**: Objek diidentifikasi dengan yakin sebagai salah satu dari 6 spesies ikan terdaftar.

---

## 3. Matriks Hasil Pengujian Blackbox

### Modul 1: Splash Screen & Navigasi Utama

| ID Uji | Kasus Uji (Skenario) | Langkah Pengujian | Hasil yang Diharapkan | Hasil Aktual | Status |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **TC-01** | Splash Screen Auto-Navigasi | Buka aplikasi dari keadaan *cold start* / mati. | Menampilkan logo ombak navy dan judul "FishScan" + tagline "Bertenaga Yolo" selama 2 detik, lalu otomatis berpindah ke halaman utama (MainShell). | Sesuai ekspektasi, transisi mulus dalam waktu 2 detik. | **Lolos** |
| **TC-02** | Navigasi Tab Bottom Bar | Tap masing-masing ikon tab pada bottom navigation bar (Home, Kamera, History, Settings). | Halaman berpindah sesuai tab aktif tanpa lag. Khusus tab "Kamera", membuka halaman Live Detection secara terpisah. | Halaman berpindah dengan benar, tab Kamera membuka route `/realtime`. | **Lolos** |

---

### Modul 2: Deteksi via Upload (Gallery & Camera Upload)

| ID Uji | Kasus Uji (Skenario) | Langkah Pengujian | Hasil yang Diharapkan | Hasil Aktual | Status |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **TC-03** | Request Izin Kamera (Disetujui) | Buka menu Upload $\rightarrow$ Pilih Kamera $\rightarrow$ Berikan izin saat pop-up Android muncul. | Kamera native terbuka untuk mengambil foto. | Izin berhasil diminta dan kamera native terbuka normal. | **Lolos** |
| **TC-04** | Request Izin Kamera (Ditolak) | Buka menu Upload $\rightarrow$ Pilih Kamera $\rightarrow$ Pilih "Tolak" saat pop-up izin Android muncul. | Kamera tidak terbuka, aplikasi menampilkan pesan error "Izin kamera diperlukan" / `permissionDenied` yang ramah pengguna. | Kamera tidak terbuka, muncul pesan kesalahan ber-locale. | **Lolos** |
| **TC-05** | Proteksi Race Condition pada Upload | Ketuk tombol pilih gambar secara ganda dengan sangat cepat. | Aplikasi hanya memproses satu panggilan pertama, mencegah pemrosesan ganda dan crash memori. | Loading indicator hanya muncul sekali, proses berjalan stabil. | **Lolos** |
| **TC-06** | Koreksi Orientasi EXIF Foto Portrait | Ambil foto ikan dari kamera HP dengan orientasi Portrait (tegak lurus), lalu unggah. | Gambar dikoreksi otomatis agar tetap tegak lurus sebelum dikirim ke model YOLO. Model mendeteksi dengan confidence tinggi ($\ge 0.65$). | Gambar terunggah tegak lurus, bounding box terlukis presisi, confidence tinggi. | **Lolos** |
| **TC-07** | Deteksi Sukses Spesies Valid ($\ge 0.65$) | Unggah foto ikan asli (contoh: Ikan Kembung) dengan sudut dan pencahayaan yang jelas. | Sistem mengenali ikan $\rightarrow$ Bounding box digambar pas $\rightarrow$ ResultCard menampilkan "Ikan Kembung" (dapat ditap untuk masuk detail). | Deteksi akurat, nama ikan sesuai, ResultCard dapat ditap. | **Lolos** |
| **TC-08** | Deteksi Reklasifikasi "Non Ikan" ($0.40 \le \text{Conf} < 0.65$) | Unggah foto lukisan ikan atau objek ikan mainan. | Terdeteksi di bawah 65% $\rightarrow$ Sistem mereklasifikasi menjadi "Non Ikan" $\rightarrow$ ResultCard menampilkan warna abu-abu (tidak dapat ditap/onTap null). | Deteksi menampilkan label "Non Ikan", ikon detail dinonaktifkan (onTap null). | **Lolos** |
| **TC-09** | Deteksi Gagal / Tidak Ada Objek ($< 0.40$) | Unggah foto pemandangan ruangan atau meja polos tanpa objek ikan. | Tidak ada objek terdeteksi $\rightarrow$ Aplikasi menampilkan pesan kesalahan "Tidak Ada Ikan Terdeteksi" (`noDetection`). | Tampilan error `noDetection` muncul dalam bahasa terpilih. | **Lolos** |

---

### Modul 3: Deteksi Real-time (Live Camera Stream)

| ID Uji | Kasus Uji (Skenario) | Langkah Pengujian | Hasil yang Diharapkan | Hasil Aktual | Status |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **TC-10** | Gambar Overlay Bounding Box Real-time | Arahkan kamera live ke gambar ikan asli. | Bounding box dan badge akurasi (misal: "Kakap Putih 89%") digambar langsung di atas preview kamera secara real-time. | Kotak deteksi native muncul dan mengikuti pergerakan objek secara responsif. | **Lolos** |
| **TC-11** | Stabilitas Deteksi & Auto-Navigasi (1.5s) | Arahkan kamera secara stabil ke satu jenis spesies ikan asli selama minimal 1.5 detik. | Progress bar "Mengidentifikasi..." terisi penuh $\rightarrow$ sistem meng-capture foto $\rightarrow$ otomatis bernavigasi ke halaman Detail Spesies. | Setelah 1.5 detik stabil, kamera ter-pause dan langsung masuk ke halaman detail. | **Lolos** |
| **TC-12** | Pencegahan Auto-Navigasi "Non Ikan" | Arahkan kamera ke lukisan ikan atau objek mirip ikan (confidence < 0.65). | Teks "Non Ikan" muncul di overlay, tetapi **tidak memicu** pengisian progress bar stabilitas dan **tidak** auto-navigasi ke detail. | Aplikasi tetap berada di mode kamera, mencegah navigasi ke spesies salah. | **Lolos** |
| **TC-13** | Manajemen Lifecycle Kamera | Masuk ke halaman detail spesies, lalu tekan tombol kembali. Minimalisir aplikasi ke background lalu buka lagi. | Stream kamera di-pause saat halaman detail aktif, di-resume saat kembali ke view realtime, dan dilepas saat app di-background. | Konsumsi baterai stabil, kamera tidak crash / tersangkut saat app dibuka-tutup. | **Lolos** |

---

### Modul 4: Halaman Detail Spesies & Riwayat Deteksi

| ID Uji | Kasus Uji (Skenario) | Langkah Pengujian | Hasil yang Diharapkan | Hasil Aktual | Status |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **TC-14** | Informasi Detail Spesies Konsisten | Buka detail hasil scan spesies "Ikan Baramundi". | Menampilkan foto hasil capture (beserta bounding box), persentase confidence, nama spesies, deskripsi, dan warna aksen khas dari `ikan.json`. | Teks dan gambar termuat dengan benar, aksen warna sesuai jenis ikan. | **Lolos** |
| **TC-15** | Reaktivitas & Penyimpanan Riwayat | Lakukan scan sukses $\rightarrow$ Buka tab Riwayat Deteksi. | Hasil scan langsung tersimpan di `history.json` dan langsung muncul di list riwayat teratas tanpa perlu me-restart aplikasi. | List otomatis ter-update berkat listener `HistoryRepository.revision`. | **Lolos** |
| **TC-16** | Fitur Pencarian / Filter Riwayat | Ketik kata kunci pencarian (contoh: "Cakalang") di search bar riwayat. | List menyaring secara instan hanya menampilkan riwayat untuk spesies "Ikan Cakalang". | Filter bekerja reaktif per karakter yang diketik. | **Lolos** |
| **TC-17** | Swipe-to-Delete Riwayat (Satu Item) | Swipe kiri pada salah satu item riwayat $\rightarrow$ Konfirmasi dialog $\rightarrow$ Pilih "Hapus". | Item terhapus dari list, berkas foto fisik dihapus dari penyimpanan internal, dan file `history.json` ter-update. | Item hilang, ruang penyimpanan dilepaskan, data di berkas JSON ter-update. | **Lolos** |
| **TC-18** | Hapus Semua Riwayat | Tap tombol "Hapus Semua" pada header riwayat $\rightarrow$ Konfirmasi dialog $\rightarrow$ Pilih "Hapus". | List menjadi kosong (Empty State), seluruh foto di folder dokumen terhapus, dan file `history.json` dikosongkan. | Folder foto dibersihkan, list riwayat menampilkan halaman kosong. | **Lolos** |

---

### Modul 5: Pengaturan (Settings & Localization)

| ID Uji | Kasus Uji (Skenario) | Langkah Pengujian | Hasil yang Diharapkan | Hasil Aktual | Status |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **TC-19** | Penerapan Tema Gelap (Dark Mode) | Nyalakan switch "Mode Gelap" di menu Settings. | Seluruh antarmuka aplikasi berubah menjadi palet gelap seketika, status tersimpan di SharedPreferences (persisten saat restart). | Tema berganti instan ke palet gelap, tetap gelap saat aplikasi dibuka ulang. | **Lolos** |
| **TC-20** | Penerapan Pilihan Bahasa (ID / EN) | Ubah dropdown bahasa di Settings dari "Indonesia" ke "English". | Seluruh string teks dinamis pada UI (Menu, deskripsi, dialog box, dsb.) langsung berganti bahasa Inggris. | Lokalisasi langsung berubah seketika tanpa perlu memuat ulang aplikasi. | **Lolos** |
| **TC-21** | Tombol Keluar (Logout) | Buka Settings $\rightarrow$ Tap tombol "Logout" (Ikon keluar) $\rightarrow$ Konfirmasi dialog. | Aplikasi menutup secara aman dan bersih. | Aplikasi tertutup sepenuhnya dengan instruksi `SystemNavigator.pop()`. | **Lolos** |

---

## 4. Kesimpulan Pengujian
Berdasarkan hasil pengujian di atas, **21 kasus uji (test cases)** yang mencakup seluruh modul penting aplikasi Fish Scan telah **Lolos (Passed) 100%**. 

Perbaikan fungsionalitas kunci—terutama **penambalan EXIF orientation correction** pada Gallery Upload (TC-06) dan **Sinkronisasi Reaktif Riwayat** (TC-15)—telah memulihkan stabilitas aplikasi secara signifikan sehingga siap untuk didistribusikan kepada pengguna akhir.
