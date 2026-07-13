# 🚀 HELIOT - IoT Project Builder

![Flutter](https://img.shields.io/badge/Flutter-%5E3.10.0-blue.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-SDK-blue.svg?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen.svg)

**HELIOT (IoT Project Builder)** adalah platform mobile inovatif berbasis Flutter yang dirancang untuk mempermudah perancangan, kalkulasi estimasi harga, dan pemesanan proyek *Internet of Things* (IoT). 

Baik Anda seorang mahasiswa, penghobi elektronika, maupun pemula, HELIOT hadir untuk menjembatani ide cemerlang Anda menjadi purwarupa yang nyata melalui fitur *custom project builder* terpadu.

## ✨ Fitur Utama

- 🔐 **Autentikasi Terpusat:** Sistem Login dan Registrasi aman yang ditenagai oleh **Supabase Auth**.
- 📦 **Katalog Komponen & Template:** Telusuri berbagai jenis mikrokontroler (Arduino, ESP32, Raspberry Pi), ragam sensor, modul, hingga bundel proyek siap pakai (Smart Home, Smart Agriculture, dsb).
- 🛠️ **Custom Project Builder:** Rancang proyek IoT Anda secara spesifik. Bebas memilih mikrokontroler, jumlah sensor, tipe konektivitas, jenis catu daya, dan bentuk *enclosure* (casing).
- 💰 **Kalkulasi Biaya Cerdas (Smart Pricing):** Fitur auto-kalkulasi harga estimasi proyek beserta biaya perakitan (*service fee*) yang menyesuaikan tingkat kesulitan proyek.
- 💳 **Pembayaran Instan:** Pengecekan *status order* *real-time* yang terintegrasi dengan **Midtrans Payment Gateway** melalui arsitektur *Serverless Edge Functions*.
- 🔔 **Push Notifications:** Pembaruan status perakitan pesanan yang dikirimkan langsung ke perangkat melalui **Firebase Cloud Messaging**.
- 📍 **Manajemen Lokasi:** Integrasi *Geolocation* dan *Maps* untuk pengaturan titik lokasi alamat pengiriman secara akurat.

## 🛠️ Teknologi & Arsitektur (Tech Stack)

- **Frontend:** [Flutter](https://flutter.dev/) (Dart)
- **Backend (BaaS):** [Supabase](https://supabase.com/) (PostgreSQL, Storage, Edge Functions)
- **Payment Gateway:** [Midtrans](https://midtrans.com/) (Diintegrasikan via Deno / TypeScript Edge Functions)
- **Push Notification:** [Firebase Cloud Messaging](https://firebase.google.com/) (FCM)
- **Maps:** `flutter_map`, `latlong2`, `geolocator`, `geocoding`

## 🚀 Cara Menjalankan Proyek (Getting Started)

### Prasyarat (Prerequisites)
Pastikan sistem Anda sudah terinstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.10.0)
- Editor pilihan (VS Code / Android Studio)

### Instalasi & Menjalankan Aplikasi
1. **Clone repositori ini:**
   ```bash
   git clone https://github.com/4tmaa/heliot.git
   cd heliot
   ```
2. **Install dependensi Flutter:**
   ```bash
   flutter pub get
   ```
3. **Konfigurasi *Environment Variables*:**
   Buat file `.env` di *root* direktori proyek dan masukkan variabel Supabase Anda. *(File ini aman dan di-ignore oleh Git)*:
   ```env
   supabaseUrl=URL_SUPABASE_ANDA
   supabaseAnonKey=ANON_KEY_SUPABASE_ANDA
   ```
4. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```

## 📸 Tampilan Aplikasi (Screenshots)

<div align="center">
<img width="1794" height="876" alt="banner_heliot" src="https://github.com/user-attachments/assets/bdee49d5-aa2e-4d9f-b812-44ebad757193" />
<img width="220" alt="mockup1" src="https://github.com/user-attachments/assets/fe02e272-01de-4376-936a-4a15e07eb168" />
<img width="220" alt="mockup2" src="https://github.com/user-attachments/assets/6664f868-ec9f-4876-8738-c33e6002cf3c" />
<img width="220" alt="mockup3" src="https://github.com/user-attachments/assets/4b835c59-b740-486e-8c93-47f59edeb6e7" />
<img width="220" alt="mockup4" src="https://github.com/user-attachments/assets/5fc4204e-571f-4fd9-8b34-54ee9cb19b98" />

</div>

## 🤝 Penutup
Proyek aplikasi ini dikembangkan untuk pemenuhan tugas Mata Kuliah Pemrograman Seluler. Kami percaya aplikasi ini dapat terus dikembangkan menjadi ekosistem yang luar biasa bagi penggiat *Internet of Things*. Masukan dan *feedback* dari audiens sangat kami hargai!
