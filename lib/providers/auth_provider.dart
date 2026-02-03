import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  dynamic _profile; // Could be Student, Tutor, or Admin
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  dynamic get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  String get userRole => _user?.role ?? '';
  
  // Get profile ID based on role
  int? get profileId {
    if (_profile == null) return null;
    if (_profile is Student) return (_profile as Student).id;
    if (_profile is Tutor) return (_profile as Tutor).id;
    if (_profile is Admin) return (_profile as Admin).id;
    return null;
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(username, password);

      if (response['success'] == true) {
        _user = User.fromJson(response['data']['user']);
        
        // Parse profile based on role
        if (_user!.role == 'siswa' && response['data']['profile'] != null) {
          _profile = Student.fromJson(response['data']['profile']);
        } else if (_user!.role == 'tutor' && response['data']['profile'] != null) {
          _profile = Tutor.fromJson(response['data']['profile']);
        } else if (_user!.role == 'admin' && response['data']['profile'] != null) {
          _profile = Admin.fromJson(response['data']['profile']);
        }

        // Save to SharedPreferences
        await _saveToPreferences();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.register(data);

      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Registrasi gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    _profile = null;
    _errorMessage = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  // Save to SharedPreferences
  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('user', json.encode(_user!.toJson()));
    }
    if (_profile != null) {
      await prefs.setString('profile', json.encode(_profile.toJson()));
      await prefs.setString('profile_type', _user!.role);
    }
  }

  // Load from SharedPreferences
  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final userJson = prefs.getString('user');
    final profileJson = prefs.getString('profile');
    final profileType = prefs.getString('profile_type');

    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
    }

    if (profileJson != null && profileType != null) {
      final profileData = json.decode(profileJson);
      if (profileType == 'siswa') {
        _profile = Student.fromJson(profileData);
      } else if (profileType == 'tutor') {
        _profile = Tutor.fromJson(profileData);
      } else if (profileType == 'admin') {
        _profile = Admin.fromJson(profileData);
      }
    }

    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
