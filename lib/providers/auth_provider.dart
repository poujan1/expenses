import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../services/offline_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    try {
      final token = await OfflineService.getToken();
      if (token != null) {
        _token = token;
        _isAuthenticated = true;

        // Try to verify token with server
        try {
          final response = await http
              .get(
                Uri.parse('${AppConstants.baseUrl}/auth/verify'),
                headers: {'Authorization': 'Bearer $token'},
              )
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            _user = data['user'];
            notifyListeners();
            return true;
          } else {
            // Token is invalid, logout
            await logout();
            return false;
          }
        } catch (e) {
          // Network error, but keep user logged in with cached token
          print('Network error during token verification: $e');
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _setError('Failed to check authentication status');
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    await tryAutoLogin();
    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = data['user'];
        _isAuthenticated = true;

        // Save token to offline storage
        await OfflineService.saveToken(_token!);

        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print(e);
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = data['user'];
        _isAuthenticated = true;

        // Save token to offline storage
        await OfflineService.saveToken(_token!);

        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print(e);
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _user = null;
    _error = null;

    // Clear offline storage
    await OfflineService.clearToken();
    await OfflineService.clearAllData();

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
