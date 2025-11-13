// screens/analysis/kmeans_screen.dart
import 'package:flutter/material.dart';
import 'package:income_expense_tracker/services/api_services.dart';

class KMeansScreen extends StatefulWidget {
  @override
  _KMeansScreenState createState() => _KMeansScreenState();
}

class _KMeansScreenState extends State<KMeansScreen> {
  final ApiService api = ApiService();
  Map<String, dynamic>? result;
  int k = 3;

  void fetchData() async {
    final data = await api.getKMeans(k);
    setState(() => result = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("K-Means Clustering")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Number of Clusters (k)"),
              keyboardType: TextInputType.number,
              onChanged: (val) => k = int.parse(val),
            ),
            ElevatedButton(onPressed: fetchData, child: Text("Run Analysis")),
            const SizedBox(height: 20),
            if (result != null)
              Expanded(
                child: ListView.builder(
                  itemCount: (result!['clusters'] as List).length,
                  itemBuilder: (context, i) {
                    final cluster = result!['clusters'][i];
                    return Card(
                      child: ListTile(
                        title: Text("Cluster $i"),
                        subtitle: Text("Transactions: ${cluster.length}"),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
