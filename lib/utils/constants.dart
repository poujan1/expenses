import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = 'https://api.nirajandahal.com.np/api';

  static const List<String> transactionCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Investment',
    'Salary',
    'Business',
    'Other',
  ];

  static const Map<String, Map<String, dynamic>> categoryInfo = {
    'Food & Dining': {'icon': Icons.restaurant, 'color': Colors.orange},
    'Transportation': {'icon': Icons.directions_car, 'color': Colors.blue},
    'Shopping': {'icon': Icons.shopping_bag, 'color': Colors.purple},
    'Entertainment': {'icon': Icons.movie, 'color': Colors.pink},
    'Bills & Utilities': {'icon': Icons.receipt, 'color': Colors.red},
    'Healthcare': {'icon': Icons.local_hospital, 'color': Colors.green},
    'Education': {'icon': Icons.school, 'color': Colors.indigo},
    'Travel': {'icon': Icons.flight, 'color': Colors.teal},
    'Investment': {'icon': Icons.trending_up, 'color': Colors.green},
    'Salary': {'icon': Icons.work, 'color': Colors.green},
    'Business': {'icon': Icons.business, 'color': Colors.blue},
    'Other': {'icon': Icons.category, 'color': Colors.grey},
  };
}
