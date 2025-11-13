// screens/analysis/simanneal_screen.dart
import 'package:flutter/material.dart';
import 'package:income_expense_tracker/services/api_services.dart';

class SimAnnealScreen extends StatefulWidget {
  const SimAnnealScreen({super.key});

  @override
  _SimAnnealScreenState createState() => _SimAnnealScreenState();
}

class _SimAnnealScreenState extends State<SimAnnealScreen> {
  final ApiService api = ApiService();
  int capacity = 5000;
  Map<String, dynamic>? result;
  bool loading = false;

  void fetchData() async {
    setState(() {
      loading = true;
      result = null;
    });

    final data = await api.getSimAnneal(capacity);

    setState(() {
      result = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulated Annealing (Knapsack)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Capacity",
                hintText: "e.g. 5000",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                if (val.isNotEmpty) capacity = int.parse(val);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchData,
              child: const Text("Run Simulated Annealing"),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (!loading && result != null) Expanded(child: _buildResultView()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final maxValue = result!['maxValue'];
    final List<dynamic> solution = result!['solution'] ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Optimization Result",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: Text("Maximized Value"),
              subtitle: Text("Total value achieved under given capacity"),
              trailing: Text(
                maxValue.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Selected Items (solution vector):",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(solution.length, (index) {
              bool included = solution[index] == 1;
              return Chip(
                label: Text("Item ${index + 1}"),
                backgroundColor: included
                    ? Colors.green.shade300
                    : Colors.grey.shade300,
                avatar: Icon(
                  included ? Icons.check : Icons.close,
                  size: 18,
                  color: included ? Colors.white : Colors.black54,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
