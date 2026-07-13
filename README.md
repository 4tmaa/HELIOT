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
  <img width="200" alt="Screenshot 1" src="https://github.com/user-attachments/assets/c6861ae3-e059-44b7-8c51-458d7ad5a892" />
  <img width="200" alt="Screenshot 2" src="https://github.com/user-attachments/assets/9f01adb2-8342-430e-aeaf-f972f117b564" />
  <img width="200" alt="Screenshot 3" src="https://github.com/user-attachments/assets/b28fc203-a615-4ea3-983e-08c49b072d73" />
  <img width="200" alt="Screenshot 4" src="https://github.com/user-attachments/assets/942b810a-a118-4893-8182-19c0eecf52af" />
  <img width="200" alt="Screenshot 5" src="https://github.com/user-attachments/assets/15393ba8-c247-4970-b184-9ce324706ad9" />
  <img width="200" alt="Screenshot 6" src="https://github.com/user-attachments/assets/66d5df09-ab07-41fc-94b1-f7e66e504d78" />
  <img width="200" alt="Screenshot 7" src="https://github.com/user-attachments/assets/be6f60c7-44e1-4d78-8156-09182d47eb00" />
  <img width="200" alt="Screenshot 8" src="https://github.com/user-attachments/assets/23edac67-3c44-434e-aaf2-e19d011caea9" />
  <img width="200" alt="Screenshot 9" src="https://github.com/user-attachments/assets/9b2bd30f-ad97-4555-abbf-5dd6150ee933" />
  <img width="200" alt="Screenshot 10" src="https://github.com/user-attachments/assets/13ee876f-d2fc-4c38-8962-80af238e2b8a" />
  <img width="200" alt="Screenshot 11" src="https://github.com/user-attachments/assets/c9f86796-6c06-4646-b396-baf978e35d7e" />
  <img width="200" alt="Screenshot 12" src="https://github.com/user-attachments/assets/6bb2a153-24e3-41c8-8911-7f715925f92f" />
</div>

## 🤝 Penutup
Proyek aplikasi ini dikembangkan untuk pemenuhan tugas Mata Kuliah Pemrograman Seluler. Kami percaya aplikasi ini dapat terus dikembangkan menjadi ekosistem yang luar biasa bagi penggiat *Internet of Things*. Masukan dan *feedback* dari audiens sangat kami hargai!
