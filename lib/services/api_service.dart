import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class ApiService {
  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Get Tutors
  static Future<Map<String, dynamic>> getTutors({
    String? search,
    String? mataPelajaran,
    String? maxHarga,
  }) async {
    try {
      String url = ApiConfig.getTutors;
      List<String> params = [];
      
      if (search != null && search.isNotEmpty) {
        params.add('search=$search');
      }
      if (mataPelajaran != null && mataPelajaran.isNotEmpty) {
        params.add('mata_pelajaran=$mataPelajaran');
      }
      if (maxHarga != null && maxHarga.isNotEmpty) {
        params.add('max_harga=$maxHarga');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(Uri.parse(url));
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Get Tutor Detail
  static Future<Map<String, dynamic>> getTutorDetail(int tutorId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getTutorDetail}?id=$tutorId'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Create Booking
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createBooking),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Get Student Bookings
  static Future<Map<String, dynamic>> getStudentBookings(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getStudentBookings}?student_id=$studentId'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Get Tutor Bookings
  static Future<Map<String, dynamic>> getTutorBookings(int tutorId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getTutorBookings}?tutor_id=$tutorId'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Update Booking Status
  static Future<Map<String, dynamic>> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updateBookingStatus),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'booking_id': bookingId,
          'status': status,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Submit Review
  static Future<Map<String, dynamic>> submitReview(
    int bookingId,
    int rating,
    String komentar,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.submitReview),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'booking_id': bookingId,
          'rating': rating,
          'komentar': komentar,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }
}
