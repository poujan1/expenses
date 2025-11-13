// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:income_expense_tracker/screens/analysis/k_means_screen.dart';
import 'package:income_expense_tracker/screens/analysis/simutated_annealing_screen.dart';

import 'analysis/knapsack_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Choose Analysis",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KMeansScreen()),
              ),
              child: Text("K-Means Clustering"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KnapsackScreen()),
              ),
              child: Text("Knapsack Optimization"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SimAnnealScreen()),
              ),
              child: Text("Simulated Annealing"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SimAnnealScreen()),
              ),
              child: const Text("Simulated Annealing"),
            ),
          ],
        ),
      ),
    );
  }
}
