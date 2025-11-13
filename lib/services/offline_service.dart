import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class OfflineService {
  static const String _tokenKey = 'auth_token';
  static const String _transactionsKey = 'transactions';
  static const String _pendingActionsKey = 'pending_actions';
  static const String _lastSyncKey = 'last_sync';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Transaction management
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, jsonEncode(jsonList));
  }

  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_transactionsKey);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Transaction.fromJson(json)).toList();
  }

  // Pending actions management
  static Future<void> savePendingAction(Map<String, dynamic> action) async {
    final prefs = await SharedPreferences.getInstance();
    final existingActions = await getPendingActions();
    existingActions.add(action);
    await prefs.setString(_pendingActionsKey, jsonEncode(existingActions));
  }

  static Future<List<Map<String, dynamic>>> getPendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pendingActionsKey);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.cast<Map<String, dynamic>>();
  }

  static Future<void> clearPendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingActionsKey);
  }

  // Sync management
  static Future<void> updateLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastSyncKey);

    if (dateString == null) return null;

    return DateTime.parse(dateString);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_pendingActionsKey);
    await prefs.remove(_lastSyncKey);
  }
}
