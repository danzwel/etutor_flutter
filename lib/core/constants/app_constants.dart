import 'package:flutter/material.dart';

// API Configuration
class ApiConfig {
  // GANTI dengan IP server Anda (localhost tidak akan berfungsi di emulator/device)
  static const String baseUrl = 'http://192.168.1.27/etutor_flutter/backend/api';
  
  // Endpoints
  static const String login = '$baseUrl/login.php';
  static const String register = '$baseUrl/register.php';
  static const String getTutors = '$baseUrl/get_tutors.php';
  static const String getTutorDetail = '$baseUrl/get_tutor_detail.php';
  static const String createBooking = '$baseUrl/create_booking.php';
  static const String getStudentBookings = '$baseUrl/get_student_bookings.php';
  static const String getTutorBookings = '$baseUrl/get_tutor_bookings.php';
  static const String updateBookingStatus = '$baseUrl/update_booking_status.php';
  static const String submitReview = '$baseUrl/submit_review.php';
  
  // Admin endpoints
  static const String getStatistics = '$baseUrl/get_statistics.php';
  static const String getAllTutors = '$baseUrl/get_all_tutors.php';
  static const String updateTutorStatus = '$baseUrl/update_tutor_status.php';
  static const String getAllUsers = '$baseUrl/get_all_users.php';
  static const String updateTutorProfile = '$baseUrl/update_tutor_profile.php';
}

// App Colors - Sama dengan web version
class AppColors {
  static const Color primaryColor = Color(0xFF2A6EBB);
  static const Color secondaryColor = Color(0xFFFF7A00);
  static const Color successColor = Color(0xFF28a745);
  static const Color dangerColor = Color(0xFFdc3545);
  static const Color warningColor = Color(0xFFffc107);
  static const Color infoColor = Color(0xFF17a2b8);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF666666);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, Color(0xFF1e5a99)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, Color(0xFFe66d00)],
  );
}

// App Text Styles
class AppTextStyles {
  static const String fontFamily = 'Poppins';
  
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    fontFamily: fontFamily,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: fontFamily,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    fontFamily: fontFamily,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );
}

// App Dimensions
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double borderRadius = 10.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 15.0;
  
  static const double buttonHeight = 50.0;
  static const double inputHeight = 55.0;
}

// App Strings
class AppStrings {
  static const String appName = 'ETutor';
  static const String appTagline = 'Platform Belajar dengan Tutor Profesional';
  
  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String username = 'Username';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  
  // Common
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String search = 'Cari';
  static const String loading = 'Memuat...';
  static const String error = 'Terjadi Kesalahan';
  static const String success = 'Berhasil';
  static const String confirm = 'Konfirmasi';
}
