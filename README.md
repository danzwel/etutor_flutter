# 📱 ETutor Mobile - Platform Belajar dengan Tutor Profesional

<div align="center">

![ETutor Logo](https://img.shields.io/badge/ETutor-Mobile-2A6EBB?style=for-the-badge&logo=flutter)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)

**Tugas Besar Pemrograman Mobile 2**  
*Universitas Teknologi Bandung - Departemen Teknik Informatika*

</div>

---

## 📋 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Fitur Utama](#-fitur-utama)
- [Teknologi](#-teknologi)
- [Persyaratan Sistem](#-persyaratan-sistem)
- [Instalasi](#-instalasi)
- [Konfigurasi](#-konfigurasi)
- [Penggunaan](#-penggunaan)
- [Struktur Proyek](#-struktur-proyek)
- [Screenshots](#-screenshots)
- [Tim Pengembang](#-tim-pengembang)
- [Lisensi](#-lisensi)

---

## 🎯 Tentang Proyek

**ETutor Mobile** adalah aplikasi platform pembelajaran yang menghubungkan siswa dengan tutor profesional. Aplikasi ini memungkinkan siswa untuk mencari, membooking, dan memberikan review kepada tutor, sementara tutor dapat mengelola jadwal mengajar mereka.

### ✨ Highlights

- 🎨 **UI/UX Modern** - Design yang clean dengan gradient dan animasi smooth
- 🔐 **Multi-Role System** - Support untuk Admin, Tutor, dan Siswa
- 💳 **Booking System** - Sistem booking lengkap dengan perhitungan biaya otomatis
- ⭐ **Review & Rating** - Sistem review transparan untuk quality control
- 📊 **Admin Dashboard** - Panel admin dengan statistik lengkap

---

## 🚀 Fitur Utama

### 👨‍🎓 Untuk Siswa

- ✅ **Landing Page** - Halaman sambutan dengan informasi lengkap
- ✅ **Cari Tutor** - Search dan filter tutor berdasarkan mata pelajaran, harga, dll
- ✅ **Detail Tutor** - Lihat profil lengkap, rating, dan review tutor
- ✅ **Booking** - Buat booking dengan pilihan tanggal, jam, dan durasi
- ✅ **My Bookings** - Lihat histori booking (pending, confirmed, selesai, batal)
- ✅ **Review System** - Beri rating dan komentar setelah sesi selesai

### 👨‍🏫 Untuk Tutor

- ✅ **Dashboard** - Statistik booking dan status approval
- ✅ **Manage Bookings** - Terima/tolak booking dari siswa
- ✅ **Edit Profile** - Update informasi profil dan harga
- ✅ **View Reviews** - Lihat review dari siswa

### 🔧 Untuk Admin

- ✅ **Dashboard Analytics** - Statistik lengkap (users, revenue, bookings)
- ✅ **Approve Tutors** - Verifikasi dan approve tutor baru
- ✅ **Manage Users** - Kelola semua user (Admin, Tutor, Siswa)
- ✅ **Reports** - Laporan revenue dan booking statistics

---

## 💻 Teknologi

### Frontend (Mobile)

- **Flutter** 3.0+ - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Google Fonts** - Poppins font family
- **Cached Network Image** - Image caching
- **Intl** - Internationalization (Format tanggal dan currency)

### Backend

- **PHP** 8.0+ - Server-side scripting
- **MySQL** - Database
- **PDO** - Database abstraction
- **REST API** - API architecture

### Development Tools

- **Android Studio** / **VS Code** - IDE
- **XAMPP** - Local server (Apache + MySQL)
- **Flutter DevTools** - Debugging

---

## 📋 Persyaratan Sistem

### Software yang Diperlukan:

1. **Flutter SDK** (versi 3.0 atau lebih baru)
   - Download: https://flutter.dev/docs/get-started/install
   
2. **Android Studio** atau **VS Code**
   - Android Studio: https://developer.android.com/studio
   - VS Code + Flutter Extension

3. **XAMPP** (untuk server lokal)
   - Download: https://www.apachefriends.org/
   
4. **MySQL** (included in XAMPP)

5. **Android Emulator** atau **Physical Device**

### Spesifikasi Minimum:

- **RAM**: 4GB (8GB recommended)
- **Storage**: 2GB free space
- **OS**: Windows 10/11, macOS, atau Linux

---

## 🔧 Instalasi

### Step 1: Setup Backend (PHP + MySQL)

#### 1.1 Install dan Jalankan XAMPP

```bash
1. Download dan install XAMPP
2. Buka XAMPP Control Panel
3. Start Apache
4. Start MySQL
```

#### 1.2 Import Database

```bash
1. Buka browser, akses http://localhost/phpmyadmin
2. Klik "New" untuk create database baru
3. Nama database: etutor
4. Klik tab "Import"
5. Choose file: etutor.sql (dari folder proyek web sebelumnya)
6. Klik "Go"
```

#### 1.3 Setup Backend Files

```bash
1. Copy folder "backend" dari proyek ini
2. Paste ke: C:/xampp/htdocs/
3. Rename folder menjadi: etutor_flutter

Struktur akhir:
C:/xampp/htdocs/etutor_flutter/backend/
├── api/
│   ├── login.php
│   ├── register.php
│   ├── get_tutors.php
│   └── ... (semua file API)
└── config/
    └── database.php
```

#### 1.4 Cari IP Address Komputer Anda

**Windows:**
```bash
1. Buka CMD
2. Ketik: ipconfig
3. Cari "IPv4 Address"
4. Contoh: 192.168.1.100
```

**Mac/Linux:**
```bash
1. Buka Terminal
2. Ketik: ifconfig
3. Cari "inet"
4. Contoh: 192.168.1.100
```

#### 1.5 Update IP di Backend API

Buka semua file PHP di `backend/api/` dan ganti:
```php
// Cari baris ini:
$tutor['foto_url'] = 'http://YOUR_SERVER_IP/etutor/assets/images/' . $tutor['foto'];

// Ganti dengan IP Anda:
$tutor['foto_url'] = 'http://192.168.1.100/etutor/assets/images/' . $tutor['foto'];
```

#### 1.6 Test API

Buka browser dan test endpoint:
```
http://localhost/etutor_flutter/backend/api/get_tutors.php
```

Jika berhasil, akan muncul response JSON dengan data tutor.

---

### Step 2: Setup Flutter Project

#### 2.1 Clone/Extract Project

```bash
# Extract ZIP ke folder pilihan
# Contoh: C:/Projects/etutor_flutter
```

#### 2.2 Install Dependencies

```bash
cd etutor_flutter
flutter pub get
```

#### 2.3 Ganti IP Address

Buka file: `lib/core/constants/app_constants.dart`

```dart
// Ganti baris ini:
static const String baseUrl = 'http://192.168.1.100/etutor_flutter/backend/api';

// Dengan IP komputer Anda:
static const String baseUrl = 'http://YOUR_IP_HERE/etutor_flutter/backend/api';
```

#### 2.4 Connect Device/Emulator

**Untuk Emulator:**
```bash
# Start Android emulator dari Android Studio
# Atau: flutter emulators
#       flutter emulators --launch <emulator_id>
```

**Untuk Physical Device:**
```bash
1. Enable Developer Options di Android
2. Enable USB Debugging
3. Connect via USB
4. flutter devices (untuk verify)
```

#### 2.5 Run Project

```bash
flutter run
```

Atau via IDE:
- **VS Code**: Press F5
- **Android Studio**: Click Run button

---

## ⚙️ Konfigurasi

### Database Configuration

File: `backend/config/database.php`

```php
$host = 'localhost';
$dbname = 'etutor';
$username = 'root';
$password = '';
```

### API Configuration

File: `lib/core/constants/app_constants.dart`

```dart
class ApiConfig {
  static const String baseUrl = 'http://YOUR_IP/etutor_flutter/backend/api';
}
```

### App Colors

```dart
class AppColors {
  static const Color primaryColor = Color(0xFF2A6EBB);
  static const Color secondaryColor = Color(0xFFFF7A00);
  static const Color successColor = Color(0xFF28a745);
  static const Color dangerColor = Color(0xFFdc3545);
}
```

---

## 📱 Penggunaan

### Demo Accounts

#### Siswa:
```
Username: wahyu
Password: password123
```

#### Tutor:
```
Username: tutor1
Password: password123
```

#### Admin:
```
Username: admin
Password: password123
```

### User Flow

#### **Siswa:**
1. Buka aplikasi → Lihat landing page
2. Login/Register sebagai siswa
3. Browse tutor di "Cari Tutor"
4. Klik tutor → Lihat detail
5. Klik "Booking Sekarang"
6. Isi form booking (mata pelajaran, tanggal, jam, durasi)
7. Konfirmasi → Booking berhasil
8. Cek "Booking Saya" untuk tracking
9. Setelah selesai → Beri review

#### **Tutor:**
1. Login sebagai tutor
2. Lihat dashboard
3. Buka "Booking Masuk"
4. Terima/tolak booking
5. Tandai selesai setelah sesi
6. Edit profile di menu "Profile"

#### **Admin:**
1. Login sebagai admin
2. Lihat statistics di dashboard
3. Approve tutor baru di "Kelola Tutor"
4. Manage users di "Kelola Users"
5. Lihat reports di "Laporan"

---

## 📁 Struktur Proyek

```
etutor_flutter/
├── backend/                      # Backend PHP
│   ├── api/                      # REST API endpoints
│   │   ├── login.php
│   │   ├── register.php
│   │   ├── get_tutors.php
│   │   ├── get_statistics.php
│   │   └── ...
│   └── config/
│       └── database.php          # Database config
│
├── lib/                          # Flutter source code
│   ├── core/
│   │   └── constants/
│   │       └── app_constants.dart # App configuration
│   │
│   ├── models/                   # Data models
│   │   ├── user_model.dart
│   │   ├── booking_model.dart
│   │   └── review_model.dart
│   │
│   ├── providers/                # State management
│   │   └── auth_provider.dart
│   │
│   ├── services/                 # API services
│   │   └── api_service.dart
│   │
│   ├── screens/                  # UI screens
│   │   ├── landing/
│   │   │   └── landing_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   ├── main_navigation.dart
│   │   │   ├── student_home.dart
│   │   │   ├── tutor_home.dart
│   │   │   └── admin_home.dart
│   │   ├── student/
│   │   │   ├── find_tutor_screen.dart
│   │   │   ├── tutor_detail_screen.dart
│   │   │   ├── booking_screen.dart
│   │   │   └── my_bookings_screen.dart
│   │   ├── tutor/
│   │   │   ├── bookings_screen.dart
│   │   │   └── tutor_profile_screen.dart
│   │   ├── admin/
│   │   │   ├── admin_dashboard.dart
│   │   │   ├── manage_tutors_screen.dart
│   │   │   ├── manage_users_screen.dart
│   │   │   └── reports_screen.dart
│   │   └── about/
│   │       └── about_screen.dart
│   │
│   └── main.dart                 # App entry point
│
├── assets/                       # Assets (jika ada)
│   ├── images/
│   └── icons/
│
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

---

## 📸 Screenshots

### Landing Page
Halaman sambutan dengan fitur ETutor dan featured tutors.

### Student Dashboard
Dashboard siswa dengan quick actions dan statistik.

### Find Tutor
Cari dan filter tutor berdasarkan berbagai kriteria.

### Tutor Detail
Profil lengkap tutor dengan rating dan reviews.

### Booking Screen
Form booking dengan perhitungan biaya otomatis.

### Admin Dashboard
Panel admin dengan statistics dan analytics.

---

## 🛠️ Troubleshooting

### 1. Error: "IP not reachable"

**Solusi:**
- Pastikan XAMPP Apache & MySQL running
- Cek firewall Windows
- Pastikan emulator/device di network yang sama dengan PC
- Test API di browser: `http://YOUR_IP/etutor_flutter/backend/api/get_tutors.php`

### 2. Error: "Locale has not been initialized"

**Solusi:**
Sudah diperbaiki di `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}
```

### 3. Error: "No data found"

**Solusi:**
- Pastikan database sudah di-import
- Cek ada data tutor dengan status 'approved'
- Test API endpoint di browser

### 4. Gambar tutor tidak muncul

**Solusi:**
- Pastikan IP di file PHP sudah benar
- Copy folder `assets/images` dari proyek web ke `C:/xampp/htdocs/etutor/`
- Pastikan file foto tutor ada di folder tersebut

### 5. Flutter dependencies error

**Solusi:**
```bash
flutter clean
flutter pub get
```

### 6. Build error

**Solusi:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔄 Update & Maintenance

### Update Dependencies

```bash
flutter pub upgrade
```

### Clean Build

```bash
flutter clean
flutter pub get
flutter run
```

### Database Backup

```bash
# Export dari phpMyAdmin
# atau via command line:
mysqldump -u root etutor > backup.sql
```

---

## 🧪 Testing

### Test Flow Siswa:
- [ ] Register sebagai siswa
- [ ] Login berhasil
- [ ] Browse tutor
- [ ] Search & filter tutor
- [ ] Lihat detail tutor
- [ ] Buat booking
- [ ] Lihat booking di "Booking Saya"
- [ ] Cancel booking
- [ ] Beri review (jika status selesai)

### Test Flow Tutor:
- [ ] Register sebagai tutor
- [ ] Login berhasil
- [ ] Lihat dashboard
- [ ] Terima booking
- [ ] Tolak booking
- [ ] Tandai selesai
- [ ] Edit profile

### Test Flow Admin:
- [ ] Login sebagai admin
- [ ] Lihat statistics
- [ ] Approve tutor
- [ ] Reject tutor
- [ ] View users
- [ ] View reports

---

## 🎓 Tim Pengembang

### Tugas Besar Pemrograman Mobile 2
**TIF RP 23 CID A**

| Nama | NPM |
|------|-----|
| **Daniel Desmanto Nugraha** | 23552011055 |
| **SULASTIAN SETIADI** | 23552011342 |
| **Syifa Aulia Fitri** | 23552011013 |
| **Dikdik Nawa Cendekia Agung** | 23552011240 |
| **Wildam Pramudiya Alif** | 23552011235 |

**Dosen Pembimbing:**  
Nova Agustina, S.T., M.Kom.

**Universitas Teknologi Bandung**  
Departemen Teknik Informatika

---

## 📄 Lisensi

Copyright © 2026 ETutor - Universitas Teknologi Bandung

Proyek ini dibuat untuk keperluan akademik (Tugas Besar Pemrograman Mobile 2).

---

## 🙏 Acknowledgments

- **Flutter Team** - Framework yang powerful
- **Google Fonts** - Poppins font family
- **Dosen Pembimbing** - Guidance dan support
- **Universitas Teknologi Bandung** - Fasilitas dan kesempatan belajar

---

## 📞 Support

Jika ada pertanyaan atau kendala:

1. **Check Troubleshooting** section di atas
2. **Review Documentation** lengkap
3. **Contact Team Members** untuk bantuan lebih lanjut
4. **Konsultasi dengan Dosen** untuk guidance akademik

---

## 🚀 Future Improvements

Potential features untuk development selanjutnya:

- [ ] Push notifications untuk booking
- [ ] Chat system antara siswa dan tutor
- [ ] Payment gateway integration
- [ ] Video call untuk sesi online
- [ ] Achievement & badges system
- [ ] Referral program
- [ ] Multi-language support
- [ ] Dark mode

---

<div align="center">

**Made with ❤️ by ETutor Team**

⭐ **Star this project if you find it helpful!** ⭐

[Report Bug](mailto:danieldesmanto@gmail.com) · [Request Feature](mailto:danieldesmanto@gmail.com)

</div>

---

**Happy Coding! 🎉**