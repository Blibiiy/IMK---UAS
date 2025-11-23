import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'mahasiswa' atau 'dosen'
  final String? program; // Program studi untuk mahasiswa
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.program,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'mahasiswa',
      program: json['program'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'program': program,
      'avatar_url': avatarUrl,
    };
  }
}

class UserProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isDosen => _currentUser?.role == 'dosen';
  bool get isMahasiswa => _currentUser?.role == 'mahasiswa';

  /// Login dengan email dan password
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = await _supabaseService.login(
        email: email,
        password: password,
      );

      if (userData != null) {
        _currentUser = User.fromJson(userData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
