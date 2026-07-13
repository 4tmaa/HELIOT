# Presentasi Aplikasi HELIOT (IoT Project Builder)

## 1. Pembuka
- **Salam Pembuka:** Selamat pagi/siang/sore, salam sejahtera untuk kita semua.
- **Perkenalan Diri/Kelompok:** (Sebutkan nama dan anggota kelompok).
- **Pengantar:** Pada kesempatan kali ini, kami akan mempresentasikan proyek aplikasi mobile kami yang bernama **HELIOT (IoT Project Builder)**, sebuah platform inovatif yang dirancang untuk mempermudah perancangan, pemesanan, dan realisasi proyek *Internet of Things* (IoT).

## 2. Problem Statement (Rumusan Masalah)
- **Kompleksitas Komponen:** Mahasiswa, penghobi, atau pemula sering kali kesulitan mencari komponen IoT yang lengkap, kompatibel, dan sesuai dengan kebutuhan proyek mereka.
- **Estimasi Biaya yang Sulit:** Menghitung estimasi biaya total untuk proyek custom (mikrokontroler, sensor, aktuator) membutuhkan waktu dan riset yang mendalam, terlebih bagi pemula.
- **Keterbatasan Layanan Perakitan:** Belum banyak platform terpusat yang menawarkan layanan pemesanan proyek IoT secara custom mulai dari pemilihan komponen spesifik hingga perakitan akhir.

## 3. Solusi
- **HELIOT App:** Menyediakan aplikasi berbasis *mobile* yang ramah pengguna untuk merancang proyek IoT secara mandiri dan terstruktur.
- **Kalkulasi Cerdas (Smart Pricing):** Sistem secara otomatis akan menghitung estimasi biaya berdasarkan komponen yang dipilih (mikrokontroler, sensor, tipe konektivitas, sumber daya, hingga bentuk *enclosure*), termasuk menghitung biaya jasa berdasarkan tingkat kesulitan.
- **Template Proyek Instan:** Menyediakan bundel proyek IoT siap pakai bagi pengguna yang menginginkan solusi cepat tanpa harus memilih komponen satu per satu.

## 4. Preview Demo Aplikasi
*(Pada bagian ini, demonstrasikan penggunaan aplikasi secara langsung atau melalui slide/screenshot)*

**Detail Fitur & Fungsi Utama Aplikasi:**
1. **Autentikasi (Authentication):** 
   - Login dan registrasi yang aman dan tersentralisasi menggunakan layanan dari **Supabase**.
2. **Beranda (Home):**
   - *Dashboard* utama yang menyajikan *banner* promosi informatif dan rekomendasi proyek atau template populer.
3. **Katalog Terpadu (Catalog):**
   - **Komponen:** Pengguna leluasa mengeksplorasi berbagai daftar komponen IoT detail seperti keluarga Arduino, keluarga ESP32/NodeMCU, Raspberry Pi, serta ragam sensor (DHT11, Ultrasonik, MQ-2, dll).
   - **Template:** Daftar *bundle* proyek (contoh: *Smart Agriculture*, *Smart Home*) dengan detail deskripsi dan estimasi harganya.
4. **Perancangan Proyek Custom (Custom Order Builder):**
   - Formulir dinamis di mana pengguna memilih Mikrokontroler, kuantitas Sensor, opsi Konektivitas (Wi-Fi, Bluetooth, LoRa), dan jenis *Enclosure* (casing 3D print/akrilik).
   - Dilengkapi validasi form dan perhitungan harga transparan yang mencakup harga komponen dasar dan *service fee*.
5. **Manajemen Pesanan & Pembayaran (Orders & Payment):**
   - Pemantauan status proyek (mulai dari diajukan, dikerjakan, hingga dikirim).
   - Terintegrasi langsung dengan *payment gateway* **Midtrans** (via Supabase Edge Functions) untuk transaksi yang aman dan instan.
6. **Profil & Notifikasi (Profile & Push Notifications):**
   - Pengelolaan biodata dan titik alamat pengiriman (*shipping address*) berbasik map (*Geolocation*).
   - Notifikasi *real-time* (*Push Notification*) menggunakan **Firebase Cloud Messaging** (FCM) agar pengguna selalu *update* dengan status pesanan mereka.

## 5. Kesimpulan
- **HELIOT** berhasil memecahkan masalah para penggiat IoT dengan menjembatani kesenjangan antara ide rancangan dan realisasi teknis, memberikan ekosistem dari pemilihan spesifikasi komponen hingga transaksi perakitan proyek.
- Dibangun di atas infrastruktur modern (**Flutter** untuk antarmuka *multi-platform*, **Supabase** sebagai *backend-as-a-service* untuk database *real-time*, dan **Firebase**), HELIOT tidak hanya menawarkan fungsi yang lengkap namun juga *User Experience* yang responsif dan sangat baik.

## 6. Penutup
- **Harapan:** Kami berharap aplikasi ini dapat terus dikembangkan menjadi *marketplace* IoT terbesar dan memudahkan inovator teknologi untuk mewujudkan ide-ide brilian mereka.
- **Sesi Tanya Jawab (Q&A):** Kami membuka kesempatan bagi bapak/ibu dosen serta audiens sekalian yang ingin memberikan tanggapan atau pertanyaan.
- **Salam Penutup:** Sekian dari kami, terima kasih atas waktu dan perhatiannya.
