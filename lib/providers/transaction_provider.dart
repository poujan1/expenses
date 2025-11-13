import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction.dart';
import '../services/offline_service.dart';
import '../utils/constants.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  String? _token;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  DateTimeRange? _dateRange;
  bool _isOnline = true;

  List<Transaction> get transactions {
    List<Transaction> filtered = _transactions;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                t.category.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((t) => t.category == _selectedCategory)
          .toList();
    }

    // Filter by date range
    if (_dateRange != null) {
      filtered = filtered
          .where(
            (t) =>
                t.date.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))),
          )
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  DateTimeRange? get dateRange => _dateRange;
  bool get isOnline => _isOnline;

  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  Map<String, double> get categoryExpenses {
    final Map<String, double> categoryTotals = {};

    for (final transaction in _transactions.where((t) => t.type == 'expense')) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  List<Transaction> get recentTransactions => transactions.take(5).toList();

  void setToken(String token) {
    _token = token;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _dateRange = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    try {
      _setLoading(true);
      _setError(null);

      // Load from offline storage first
      _transactions = await OfflineService.loadTransactions();
      notifyListeners();

      // Try to fetch from server
      try {
        final response = await http
            .get(
              Uri.parse('${AppConstants.baseUrl}/transactions'),
              headers: {'Authorization': 'Bearer $_token'},
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _transactions = data
              .map((json) => Transaction.fromJson(json))
              .toList();

          // Save to offline storage
          await OfflineService.saveTransactions(_transactions);
          await OfflineService.updateLastSync();

          _setOnlineStatus(true);

          // Sync pending actions
          await _syncPendingActions();
        } else {
          _setOnlineStatus(false);
          _setError('Failed to fetch transactions (using offline data)');
        }
      } catch (e) {
        _setOnlineStatus(false);
        if (_transactions.isEmpty) {
          _setError('No internet connection and no offline data available');
        }
      }
    } catch (e) {
      _setError('Failed to load transactions');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      _setLoading(true);
      _setError(null);

      // Add to local list immediately for better UX
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final localTransaction = transaction.copyWith(id: tempId);
      _transactions.add(localTransaction);
      notifyListeners();

      // Save to offline storage
      await OfflineService.saveTransactions(_transactions);

      try {
        // Try to sync with server
        final response = await http
            .post(
              Uri.parse('${AppConstants.baseUrl}/transactions'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              body: jsonEncode(transaction.toJson()),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 201) {
          // Update with server response
          final serverTransaction = Transaction.fromJson(
            jsonDecode(response.body),
          );
          final index = _transactions.indexWhere((t) => t.id == tempId);
          if (index != -1) {
            _transactions[index] = serverTransaction;
          }
          await OfflineService.saveTransactions(_transactions);
          _setOnlineStatus(true);
        } else {
          throw Exception('Server error');
        }
      } catch (e) {
        // Save as pending action for later sync
        await OfflineService.savePendingAction({
          'action': 'add',
          'transaction': transaction.toJson(),
          'tempId': tempId,
        });
        _setOnlineStatus(false);
      }

      return true;
    } catch (e) {
      _setError('Failed to add transaction');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction(String id, Transaction transaction) async {
    try {
      _setLoading(true);
      _setError(null);

      // Update local list immediately
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transactions[index] = transaction.copyWith(id: id);
        notifyListeners();
        await OfflineService.saveTransactions(_transactions);
      }

      try {
        // Try to sync with server
        final response = await http
            .put(
              Uri.parse('${AppConstants.baseUrl}/transactions/$id'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              body: jsonEncode(transaction.toJson()),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final updatedTransaction = Transaction.fromJson(
            jsonDecode(response.body),
          );
          if (index != -1) {
            _transactions[index] = updatedTransaction;
          }
          await OfflineService.saveTransactions(_transactions);
          _setOnlineStatus(true);
        } else {
          throw Exception('Server error');
        }
      } catch (e) {
        // Save as pending action for later sync
        await OfflineService.savePendingAction({
          'action': 'update',
          'id': id,
          'transaction': transaction.toJson(),
        });
        _setOnlineStatus(false);
      }

      return true;
    } catch (e) {
      _setError('Failed to update transaction');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      _setLoading(true);
      _setError(null);

      // Remove from local list immediately
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      await OfflineService.saveTransactions(_transactions);

      try {
        // Try to sync with server
        final response = await http
            .delete(
              Uri.parse('${AppConstants.baseUrl}/transactions/$id'),
              headers: {'Authorization': 'Bearer $_token'},
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _setOnlineStatus(true);
        } else {
          throw Exception('Server error');
        }
      } catch (e) {
        // Save as pending action for later sync
        await OfflineService.savePendingAction({'action': 'delete', 'id': id});
        _setOnlineStatus(false);
      }

      return true;
    } catch (e) {
      _setError('Failed to delete transaction');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sync pending actions when online
  Future<void> _syncPendingActions() async {
    final pendingActions = await OfflineService.getPendingActions();

    for (final action in pendingActions) {
      try {
        switch (action['action']) {
          case 'add':
            await http.post(
              Uri.parse('${AppConstants.baseUrl}/transactions'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              body: jsonEncode(action['transaction']),
            );
            break;
          case 'update':
            await http.put(
              Uri.parse('${AppConstants.baseUrl}/transactions/${action['id']}'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              body: jsonEncode(action['transaction']),
            );
            break;
          case 'delete':
            await http.delete(
              Uri.parse('${AppConstants.baseUrl}/transactions/${action['id']}'),
              headers: {'Authorization': 'Bearer $_token'},
            );
            break;
        }
      } catch (e) {
        // If sync fails, keep the pending action
        continue;
      }
    }

    // Clear pending actions after successful sync
    await OfflineService.clearPendingActions();
  }

  // Force sync with server
  Future<void> forceSync() async {
    await fetchTransactions();
  }
}
