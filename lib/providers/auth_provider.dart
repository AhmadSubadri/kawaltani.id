// File: lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get token => _token;

  void setUser(User user) {
    _user = user;
    _token = user.token;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> checkToken() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token != null) {
      _token = token;
      // Opsional: Validasi token dengan panggilan API jika diperlukan
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
      _user = null;
      _token = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}
