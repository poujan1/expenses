// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:income_expense_tracker/services/auth_service.dart';

class ApiService {
  final String baseUrl =
      "https://income-expense-personal-dvpl.onrender.com/api/analysis";
  // "https://income-expense-personal-dvpl.onrender.com/api/analysis";
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>?> getKMeans(int k) async {
    final token = await _auth.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/kmeans?k=$k"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  Future<Map<String, dynamic>?> getKnapsack(int capacity) async {
    final token = await _auth.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/knapsack?capacity=$capacity"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  Future<Map<String, dynamic>?> getSimAnneal(int capacity) async {
    final token = await _auth.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/simanneal?capacity=$capacity"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }
}
