// screens/analysis/knapsack_screen.dart
import 'package:flutter/material.dart';
import 'package:income_expense_tracker/services/api_services.dart';

class KnapsackScreen extends StatefulWidget {
  @override
  _KnapsackScreenState createState() => _KnapsackScreenState();
}

class _KnapsackScreenState extends State<KnapsackScreen> {
  final ApiService api = ApiService();
  int capacity = 1000;
  Map<String, dynamic>? result;

  void fetchData() async {
    final data = await api.getKnapsack(capacity);
    setState(() => result = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Knapsack Optimization")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Capacity"),
              keyboardType: TextInputType.number,
              onChanged: (val) => capacity = int.parse(val),
            ),
            ElevatedButton(
              onPressed: fetchData,
              child: Text("Run Optimization"),
            ),
            const SizedBox(height: 20),
            if (result != null)
              Text(
                "Maximum Value: ${result!['maxValue']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
