// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'offline_service.dart';

class AuthService {
  final String baseUrl =
      "https://income-expense-personal-dvpl.onrender.com/api/auth";

  // 🔹 Login
  Future<bool> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await OfflineService.saveToken(data['token']);
        return true;
      } else {
        print("Login failed: ${res.body}");
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  // 🔹 Register
  Future<bool> register(String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        await OfflineService.saveToken(data['token']);
        return true;
      } else {
        print("Register failed: ${res.body}");
        return false;
      }
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }

  // 🔹 Get Token
  Future<String?> getToken() async {
    return await OfflineService.getToken();
  }

  // 🔹 Logout
  Future<void> logout() async {
    await OfflineService.clearAllData();
  }
}
