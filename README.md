# Mobile Application - Smart Waste Management System

> **Komponen B: Mobile Application (Flutter Multiplatform)**  
> **Dibuat oleh: Adam Abdurrahman**  
> **Studi Kasus:** Smart Waste Management System  
> **Teknologi:** Flutter 3.x, Dart, Provider State Management, Dio HTTP Client, Flutter Map (OSM), LatLong2, Image Picker

---

## 🔗 Ekosistem Repository Terkait & Dataset

Aplikasi mobile ini merupakan bagian dari ekosistem **Smart Waste Management System** yang terbagi dalam tiga repositori terpisah:

- 🌐 **Website & Backend (Laravel):** [https://github.com/ADMM-ad/laravel_waste_management](https://github.com/ADMM-ad/laravel_waste_management)
- 📱 **Mobile Application (Repository Ini):** [https://github.com/ADMM-ad/flutter_waste_management](https://github.com/ADMM-ad/flutter_waste_management)
- 🤖 **Machine Learning Service (FastAPI):** [https://github.com/ADMM-ad/ml_waste_management](https://github.com/ADMM-ad/ml_waste_management)
- 📊 **Sumber Dataset AI:** [https://www.kaggle.com/datasets/mostafaabla/garbage-classification](https://www.kaggle.com/datasets/mostafaabla/garbage-classification)

---

## 📱 Deskripsi Proyek

Aplikasi **Flutter Waste Management** adalah aplikasi mobile berbasis Android/iOS yang ditujukan bagi Warga Masyarakat untuk mempermudah pelaporan timbunan sampah lingkungan secara cepat, akurat, dan transparan.

Aplikasi ini mengintegrasikan kamera ponsel, sensor geolokasi GPS presisi tinggi, peta interaktif OpenStreetMap, dan algoritma **Artificial Intelligence (MobileNetV2)** untuk mengenali klasifikasi jenis sampah secara otomatis sebelum laporan dikirimkan ke dinas kebersihan terkait.

---

## ✨ Fitur-Fitur Utama

1. **Layar Login Vektor Modern (Bebas AI-Slop):**
   - Header banner 30% layar berhiaskan ilustrasi vektor warga yang sedang memilah sampah daur ulang 3R di taman kota yang asri.
   - Form login 70% layar menempel langsung pada permukaan putih (*direct surface*, tanpa kartu bertumpuk atau lengkungan berlebihan).
   - Registrasi warga mandiri dan validasi login terenkripsi Bearer Token.
2. **Dashboard Beranda Warga:**
   - Ringkasan metrik status laporan pribadi (*Total Laporan, Menunggu Verifikasi, Sedang Ditangani, Selesai*).
   - Filter rentang waktu cepat: *Bulan Ini (Default), Hari Ini, 7 Hari Terakhir, dan Semua Waktu*.
   - Banner edukasi daur ulang interaktif.
3. **Formulir Pelaporan Sampah Interaktif:**
   - Pengambilan foto bukti dari kamera atau galeri dengan kompresi cerdas otomatis (< 5MB).
   - Fitur **Cek Kategori AI**: Mengirim foto ke microservice Machine Learning untuk mendeteksi apakah sampah termasuk kategori *Organik, Plastik, atau Kertas* beserta skor persentase keyakinannya (*Confidence Score*).
   - Pendeteksian lokasi GPS otomatis dan input patokan alamat yang jelas.
   - Pilihan *Skala Volume Sampah (Kecil, Sedang, Besar)* dan *Tingkat Urgensi (Rendah, Sedang, Darurat)* menggunakan Segmented Selector yang kokoh dan simetris.
4. **Detail Laporan & Peta Interaktif:**
   - Menampilkan koordinat lokasi sampah di atas peta interaktif OpenStreetMap (*flutter_map*) lengkap dengan penanda pin merah.
   - Garis waktu riwayat perubahan status (*Audit Timeline*) yang rapi tanpa isu *right overflow*.
   - Tombol **Edit Laporan** dan **Hapus Laporan** bagi warga jika laporan masih berstatus *Pending*.
5. **Riwayat Laporan Sampah:**
   - Menu navigasi tab status yang dapat digeser (*Semua, Menunggu, Diproses, Selesai, Ditolak*) dengan ikon tematik yang dimulai rapi dari tepi kiri.
6. **Modul Edukasi Pemilahan Sampah 3R:**
   - Halaman penuh (*EducationScreen*) yang mengupas tuntas cara pemilahan sampah Organik, Plastik, Kertas, serta prinsip *Reduce, Reuse, Recycle*.
7. **Pengaturan Profil:**
   - Ubah nama pengguna dan email akun warga secara langsung.

---

## 🛠️ Persyaratan Sistem

- Flutter SDK `>= 3.19.0`
- Dart SDK `>= 3.3.0`
- Android Studio / VS Code dengan Flutter Extension
- Android SDK (API level 21+) atau Emulator Android

---

## ⚙️ Panduan Port Lokal & Konfigurasi Alamat API

Backend Laravel berjalan di port lokal `8080` dan AI FastAPI berjalan di port `8000`. Sesuaikan konstanta URL pada berkas:
[`lib/core/constants/api_constants.dart`](file:///e:/manejemen_sampah/flutter_waste_management/lib/core/constants/api_constants.dart)

| Target Perangkat Pengujian | Backend Laravel URL (Port 8080) | AI FastAPI URL (Port 8000) |
| :--- | :--- | :--- |
| **Android Emulator (Bawaan Studio)** | `http://10.0.2.2:8080/api/v1` | `http://10.0.2.2:8000` |
| **Chrome / Web Desktop / Windows** | `http://127.0.0.1:8080/api/v1` | `http://127.0.0.1:8000` |
| **Smartphone Fisik (via Wi-Fi LAN)** | `http://<IP-LAN-LAPTOP>:8080/api/v1` | `http://<IP-LAN-LAPTOP>:8000` |

*Contoh jika IP LAN laptop Anda `192.168.1.10`, gunakan: `http://192.168.1.10:8080/api/v1`.*

---

## 🚀 Panduan Instalasi & Cara Menjalankan

1. Masuk ke direktori aplikasi mobile:
   ```bash
   cd flutter_waste_management
   ```

2. Unduh seluruh dependensi paket Dart:
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi pada perangkat atau emulator:
   ```bash
   flutter run
   ```

4. *(Opsional)* Build berkas APK Release mandiri:
   ```bash
   flutter build apk --release
   ```
   *Berkas APK siap dipasang akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`.*

---

## 🔑 Akun Demo Pengujian

| Role | Username / Email | Password | Keterangan |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin` | `12345678` | Akun Administrator |
| **Warga (User)** | `user` | `12345678` | Akun Warga Pelapor untuk login aplikasi mobile |

---

## 🧪 Analisis Statis & Pengujian

Sistem telah diuji secara menyeluruh untuk memastikan bebas dari *warning*, *overflow*, maupun regresi:

```bash
# Analisis kode statis
flutter analyze

# Unit & Widget Testing
flutter test
```

**Hasil Verifikasi:**
- `flutter analyze`: **No issues found!**
- `flutter test`: **All tests passed!**

---

*Hak Cipta © 2026 Adam Abdurrahman — Smart Waste Management System.*
