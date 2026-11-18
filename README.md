# Elwafy Care — Aplikasi Mobile Mom, Kids and Baby Spa (by Bidan Elfi)

Aplikasi *mobile* berbasis **Flutter** yang dirancang khusus untuk UMKM **Elwafy Mom, Kids and Baby Spa (by Bidan Elfi)**. Aplikasi ini mengintegrasikan **Layanan Pelanggan (Beranda Edukasi, Tanya Bidan ala Halodoc, Katalog Reservasi Homecare/Outlet, & Elwafy Poin)**, **Dashboard Pengelola (Admin & Laporan Keuangan)**, serta **Portal Mitra Bidan Homecare** dalam satu ekosistem terpadu.

---

## 📍 Identitas Resmi UMKM
- **Nama Usaha**: Elwafy Mom, Kids and Baby Spa (by Bidan Elfi)
- **Alamat Outlet**: Jl. Sei Mencirim, Medan Krio / Paya Geli, Kec. Sunggal, Kabupaten Deli Serdang / Medan, Sumatera Utara 20351
- **Jam Operasional**: `09.00 – 18.00 WIB` (Setiap Hari)
- **WhatsApp Resmi Reservasi**: `0822-8999-2812`
- **Instagram**: [`@elwafy.care`](https://www.instagram.com/elwafy.care/)

---

## 📱 Cara Paling Mudah Mencoba Aplikasi (Khusus Pemilik UMKM / Non-Teknis)

Jika Anda adalah pemilik/tim UMKM **Elwafy Care** dan hanya ingin **langsung mencoba aplikasinya di HP Android** (tanpa perlu mengerti kodingan atau menginstal aplikasi *programmer* di laptop):

1. **Unduh File Instalasi (`.apk`)**:
   - Buka menu **[Releases](https://github.com/ridwanharish/elwafy-care-app/releases)** di halaman GitHub ini (atau gunakan file `app-release.apk` yang dikirimkan melalui WhatsApp).
2. **Pasang (*Install*) di HP Android**:
   - Ketuk file `.apk` tersebut di HP Anda. Jika muncul peringatan *"Install aplikasi dari sumber ini"*, pilih **Izinkan / Tetap Install**.
3. **Buka Aplikasi `Elwafy Care`** (Ikon biru bergambar Ibu & Bayi Elwafy):
   - Saat pertama dibuka, Anda berada di **Tampilan Pelanggan (Bunda)**.
   - Untuk mencoba **Dashboard Pengelola (Admin)** atau **Portal Bidan Mitra**, ketuk menu **`Profil`** di pojok kanan bawah $\rightarrow$ pilih **`Masuk Dashboard Admin`** (Email: `admin@elwafy.care`, Sandi: `admin123`) atau **`Masuk Portal Mitra Homecare`**.

### ❓ Hal Penting yang Perlu Dipahami Saat Mencoba Aplikasi Ini (FAQ)
- **Q: Kenapa saat aplikasi ditutup paksa (*close app*), pesanan contoh yang baru saya buat kembali ke awal?**
  - **A:** Karena tahap ini adalah **Kerangka Besar Aplikasi (*Prototype MVP*)** dan **belum dihubungkan ke server/database internet berbayar**. Selama aplikasi dibuka, semua fitur (buat pesanan, *approve* jadwal di Admin, *assign* bidan mitra, sampai tukar *Elwafy Poin*) berjalan normal dan saling terhubung di dalam HP tersebut.
- **Q: Kenapa di menu `Profil` pelanggan ada tombol "Masuk Dashboard Admin" dan "Masuk Portal Mitra"?**
  - **A:** Sengaja disatukan di dalam 1 aplikasi agar pemilik UMKM bisa **mencoba ketiga peran sekaligus (sebagai Bunda, sebagai Admin, dan sebagai Bidan Mitra)** di satu HP yang sama. Nanti pada tahap operasional penuh, menu Admin dan Mitra akan dikunci khusus untuk staf saja.
- **Q: Apakah tombol WhatsApp di aplikasi ini sudah benar-benar jalan?**
  - **A:** **Sudah 100% jalan!** Saat pelanggan selesai mengisi jadwal reservasi atau menukar hadiah *Elwafy Poin*, tombol WhatsApp akan langsung membuka aplikasi WhatsApp asli di HP dengan teks pesanan lengkap menuju nomor Admin Elwafy Care (`0822-8999-2812`).

---

## 📊 Status Pengembangan Saat Ini (Penting Dibaca!)

> **Catatan Transparansi Proyek:**
> Versi aplikasi saat ini (**v2.1 — Frontend & Interactive Prototype MVP**) berfokus pada **kerangka besar antarmuka (UI/UX), alur bisnis lengkap 3 peran (Customer, Admin, Mitra), serta integrasi langsung ke WhatsApp**.
> Aplikasi ini **BELUM terhubung ke Database Cloud / Backend Server** (seperti Firebase, Supabase, atau REST API). Seluruh data saat ini berjalan menggunakan **In-Memory State Store** (`lib/state/elwafy_store.dart`) beserta data contoh (*seed data*) agar seluruh fitur dapat langsung didemokan tanpa perlu *setup* server terlebih dahulu.

### Tabel Rincian: Fitur yang Sudah Jalan vs. Tahap Backend Berikutnya

| No | Modul / Fitur | Status di Aplikasi Saat Ini | Cara Kerja Saat Ini | Yang Perlu Dibangun di Tahap Backend (Next Step) |
| :-: | :--- | :--- | :--- | :--- |
| **1** | **Beranda Gaya Halodoc & Artikel Kesehatan** | ✅ **Selesai (UI & Alur)** | Menampilkan *banner* promo grafis, 8 menu bulat, layanan *homecare*, dan 5 artikel kesehatan ibu-anak dengan filter kategori. | Membuat menu CMS di Admin agar pemilik usaha bisa mengunggah foto promo & menulis artikel berita dari database. |
| **2** | **Reservasi Pelanggan (Homecare & Outlet) + WhatsApp** | ✅ **Selesai & Berfungsi Penuh ke WA** | Pelanggan memilih layanan ke keranjang, mengisi 3 langkah jadwal/alamat, lalu sistem **otomatis membuka WhatsApp asli** dengan format pesanan lengkap & nomor rekening/QRIS. | Menyimpan data pesanan ke database server agar pesanan dari HP pelanggan langsung muncul di HP Admin secara *real-time*. |
| **3** | **Chat dengan Bidan (`Tanya Bidan`)** | ✅ **Selesai (Simulasi Interaktif)** | Menampilkan 4 Bidan ber-STR resmi. Ruang chat memiliki *auto-responder* cerdas berbasis kata kunci keluhan (*batuk, ASI, GTM, hamil*) yang otomatis menyematkan **Kartu Rekomendasi Terapi**, ditambah tombol pindah ke WhatsApp asli Bidan. | Menghubungkan ruang chat dengan *WebSocket / Firebase Firestore* untuk *live chat* 2 arah antar perangkat. |
| **4** | **Sistem Loyalitas `Elwafy Poin` (Non-Rupiah)** | ✅ **Selesai (Alur Tukar & Validasi)** | Poin tidak bernilai Rupiah (bebas risiko uang), diperoleh dari layanan berstatus *Selesai* (`+20`/`+30` poin). Pelanggan bisa menukar poin dengan hadiah fisik/layanan Elwafy dan mendapat kode unik **`ELW-RDM-XXXX`** yang harus divalidasi Admin. | Menyimpan saldo poin pelanggan dan status kode penukaran di database akun masing-masing pelanggan. |
| **5** | **Dashboard Admin (Antrean, Riwayat & Penugasan Mitra)** | ✅ **Selesai (Logika & UI)** | Admin dapat memfilter pesanan, menyetujui/mengubah jadwal, memilih Mitra Homecare terdekat, membuat **Token Tugas Acak (`TKN-ELW-XXXX`)**, mengirim link ke WA Mitra, serta memvalidasi kode penukaran *Elwafy Poin*. | Mengganti data lokal dengan database server dan sistem autentikasi akun Admin yang sesungguhnya. |
| **6** | **Dashboard Laporan Keuangan & Grafik Admin** | ✅ **Selesai (Visual & Data Dummy)** | Menampilkan ringkasan Omzet Kotor, Laba Bersih UMKM, Bagi Hasil Mitra, Biaya Operasional, Grafik Batang (*Homecare vs Outlet*), dan rekap komisi per bidan dengan filter *Minggu Ini / Bulan Ini / 3 Bulan*. | Menghubungkan angka laporan dan grafik agar dihitung otomatis dari transaksi nyata di database. |
| **7** | **Portal Mitra Bidan Homecare & Validasi Token** | ✅ **Selesai (Logika Keamanan Token)** | Memvalidasi apakah Mitra sudah login, apakah token tugas (`TKN-ELW-XXXX`) masih berlaku, dan apakah tugas tersebut memang milik Mitra yang sedang login. Mitra bisa **Terima** atau **Tolak (wajib alasan)**. | Menghubungkan *deep-link* URL web/aplikasi dan autentikasi akun Mitra dari server. |
| **8** | **Notifikasi Bot Telegram Internal Admin** | ⚠️ **Simulasi Log** | Setiap ada reservasi baru, penolakan mitra, atau tukar poin, sistem mencatat pesan notifikasi secara otomatis di menu *Pengaturan Admin -> Log Bot Telegram*. | Menghubungkan fungsi `_sendTelegramNotification` ke HTTP API Bot Telegram asli (`api.telegram.org`). |

---

## 🔑 Panduan Demo & Akun Akses (Customer, Admin, Mitra)

Aplikasi ini menyatukan **3 portal peran** dalam satu aplikasi agar mudah diuji dan didemokan di satu perangkat HP:

### 1. Portal Pelanggan (Tampilan Awal / Default)
- **Tanpa Login (Guest Mode)**: Pelanggan bisa langsung memilih layanan, membaca artikel, chat dengan bidan, dan membuat reservasi tanpa wajib membuat akun.
- **Simulasi Login Member Bunda**:
  - Ketuk tombol **`Masuk/Daftar`** di pojok kiri atas Beranda (atau lewat tab **Profil**).
  - Anda bisa langsung masuk sebagai **`Bunda Sarah Azzahra`** atau mengetik nama, nomor WA, dan wilayah Anda sendiri untuk mengaktifkan fitur *Autofill* saat reservasi.
- **Mencoba Fitur `Elwafy Poin`**:
  - Ketuk kartu **`elwafypoin (95 Poin)`** di kiri atas Beranda.
  - Pilih salah satu hadiah resmi (misal *Elwafy Natural Calming Roll-On Oil — 40 Poin*), lalu tekan **`Tukar Hadiah`**.
  - Sistem akan menerbitkan tiket berkode **`ELW-RDM-XXXX`** dengan status **`Menunggu validasi`**.

### 2. Cara Masuk ke Dashboard Admin
1. Dari tampilan Pelanggan, buka tab **`Profil`** (pojok kanan bawah).
2. Gulir ke bawah ke bagian **Akses Portal Internal UMKM**, lalu ketuk **`Masuk Dashboard Admin`**.
3. Gunakan akun demo berikut (sudah terisi otomatis):
   - **Email / Username**: `admin@elwafy.care`
   - **Kata Sandi**: `admin123`
4. Di dalam Dashboard Admin terdapat **5 Tab Navigasi Bawah**:
   - **`Antrean`**: Memproses pesanan baru atau pesanan yang ditolak mitra. Ketuk salah satu kartu untuk menyetujui jadwal, menugaskan Mitra Bidan, atau menekan tombol **`Tandai Selesai`** (otomatis menambah *Elwafy Poin* pelanggan).
   - **`Riwayat`**: Mencari dan memfilter seluruh reservasi berdasarkan tanggal, mode (*Homecare/Outlet*), dan status.
   - **`Keuangan`**: Melihat laporan Laba Bersih, Omzet Kotor, Bagi Hasil Mitra, dan Grafik Batang perbandingan *Homecare vs Outlet*.
   - **`Mitra`**: Melihat daftar Mitra Bidan, mengaktifkan/menonaktifkan layanan katalog, serta **memvalidasi atau menolak kode penukaran hadiah `Elwafy Poin` (`ELW-RDM-XXXX`)**.
   - **`Pengaturan`**: Mengatur nomor WA Admin, nomor rekening bank, dan melihat log notifikasi Bot Telegram.
5. Untuk kembali ke tampilan pelanggan, ketuk tombol **`Customer`** di pojok kanan atas.

### 3. Cara Masuk ke Portal Mitra Homecare
1. Dari tampilan Pelanggan, buka tab **`Profil`** $\rightarrow$ ketuk **`Masuk Portal Mitra Homecare`**.
2. Di dalam Portal Mitra terdapat **3 Tab**:
   - **`Tugas Saya`**: Melihat daftar tugas kunjungan Homecare untuk bidan yang sedang aktif, lengkap dengan tombol **`Terima Tugas`** dan **`Tolak Tugas`** (wajib memilih alasan).
   - **`Tautan WA`**: Simulasi verifikasi keamanan kode token tugas dari link WhatsApp (contoh token aktif milik Bidan Nisa: **`TKN-ELW-9942A7B1`**).
   - **`Akun Mitra`**: Berpindah sesi akun antara **Bidan Nisa, Amd.Keb**, **Bidan Putri, S.Tr.Keb**, **Bidan Dewi Sartika, Amd.Keb**, atau simulasi *Belum Login* untuk menguji penolakan hak akses jika token dibuka oleh mitra yang salah.

---

## 💻 Panduan Instalasi & Menjalankan Kode (Setelah `git clone`)

Tidak ada konfigurasi database, file `.env`, atau API key eksternal yang perlu disiapkan. Seluruh aset gambar lokal (`assets/images/`) sudah termasuk di dalam repositori ini.

### Prasyarat
- **Flutter SDK** (versi `3.11+` / Dart `3.11+`) sudah terpasang di komputer Anda.
- Untuk *build* APK Android: Android SDK & JDK sudah terpasang.

### Langkah Menjalankan Proyek
Buka terminal / PowerShell, lalu jalankan perintah berikut:

```bash
# 1. Clone repository ini
git clone https://github.com/ridwanharish/elwafy-care-app.git
cd elwafy-care-app

# 2. Unduh seluruh dependensi paket Flutter
flutter pub get

# 3. Jalankan aplikasi (pilih perangkat: HP Android via USB, Emulator, Chrome, atau Windows)
flutter run
```

### Perintah Membuat File APK Android (Untuk Di-install di HP)
```bash
# Membuat APK versi Debug (cepat, cocok untuk pengujian)
flutter build apk --debug

# ATAU membuat APK versi Release (ukuran lebih ringan untuk dibagikan ke klien/UMKM)
flutter build apk --release
```
Hasil file `.apk` dapat diambil di folder:
`build/app/outputs/flutter-apk/app-debug.apk` (atau `app-release.apk`).

Jika HP Android terhubung ke laptop dengan kabel USB (*USB Debugging* aktif), Anda dapat langsung memasangnya dengan perintah:
```bash
flutter install
```

---

## 🗂️ Struktur Folder Utama (`lib/`)

```text
lib/
├── main.dart                         # Titik masuk utama aplikasi (ElwafyCareApp)
├── models/
│   └── elwafy_models.dart            # Seluruh model data (Reservasi, Katalog, Bidan, Artikel, Poin, Hadiah)
├── state/
│   └── elwafy_store.dart             # State management utama, seed data UMKM, logika token & perhitungan poin
├── theme/
│   └── elwafy_theme.dart             # Tema warna Royal Cobalt Blue & Sky Blue, format Rupiah & Tanggal Indonesia
└── screens/
    ├── main_shell.dart               # Pembungkus responsif mobile-first + Animasi Splash Screen Elwafy Care
    ├── customer_flow_screen.dart     # Beranda gaya Halodoc, Katalog Layanan, Wizard Checkout 3 Langkah, Riwayat & Profil
    ├── tanya_bidan_screen.dart       # Halaman Chat dengan Bidan ala Halodoc, ruang chat cerdas & pembaca artikel
    ├── elwafy_poin_screen.dart       # Halaman saldo Elwafy Poin, tukar hadiah resmi, tiket kode & riwayat mutasi poin
    ├── admin_dashboard_screen.dart   # Dashboard Admin (Antrean, Riwayat, Laporan Keuangan + Grafik, Mitra & Pengaturan)
    └── mitra_portal_screen.dart      # Portal Mitra Homecare (Tugas Saya, Validasi Token Tautan WA & Ganti Sesi Mitra)
```

---

## 🚀 Roadmap Pengembangan Selanjutnya (Tahap Produksi / Operasional Penuh)

Jika pihak UMKM ingin melanjutkan aplikasi ini dari tahap *Prototype MVP* ke tahap **Operasional Produksi Penuh**, berikut adalah langkah teknis berikutnya:
1. **Integrasi Backend & Database Cloud (Supabase / Firebase)**:
   - Memindahkan penyimpanan di `ElwafyStore` ke database *cloud* agar reservasi pelanggan, status penugasan mitra, dan saldo *Elwafy Poin* tersimpan permanen serta tersinkronisasi antar perangkat secara *real-time*.
2. **Autentikasi Pengguna Asli (Auth)**:
   - Mengaktifkan login nomor WhatsApp (OTP) atau Email/Password untuk Pelanggan, Mitra Bidan, dan Admin.
3. **Pemisahan Hak Akses Aplikasi / Role-Based Access**:
   - Menyembunyikan menu *Akses Portal Internal UMKM* dari akun pelanggan biasa sehingga hanya akun ber-role `admin` atau `mitra` yang dapat membuka Dashboard Admin dan Portal Mitra.
4. **CMS Konten & Upload Bukti Pembayaran**:
   - Menambahkan fitur unggah gambar di Dashboard Admin untuk memperbarui *banner* promo, menulis artikel kesehatan baru, dan mengunggah foto bukti transfer pelanggan.
5. **Koneksi Webhook Bot Telegram Asli**:
   - Menghubungkan notifikasi reservasi baru dan respons mitra langsung ke grup Telegram internal pengelola Elwafy Care.
