import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int doneCount = 0;
  int notDoneCount = 0;
  Map<String, int> donePerMonth = {};

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final snapshot = await FirebaseFirestore.instance.collection('notes').get();

    int done = 0;
    int notDone = 0;
    Map<String, int> monthlyDone = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final isDon = data['isDon'] ?? false;
      final Timestamp timestamp = data['createdAt'] ?? Timestamp.now();
      final date = timestamp.toDate();
      final key = "${date.month.toString().padLeft(2, '0')}/${date.year}";

      if (isDon) {
        done++;
        monthlyDone[key] = (monthlyDone[key] ?? 0) + 1;
      } else {
        notDone++;
      }
    }

    setState(() {
      doneCount = done;
      notDoneCount = notDone;
      donePerMonth = SplayTreeMap.from(monthlyDone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tổng Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 1, title: 'Loading...', color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Task đã làm theo tháng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 250,
              child: donePerMonth.isEmpty
                  ? const Center(child: Text('Không có dữ liệu'))
                  : BarChart(
                BarChartData(
                  barGroups: donePerMonth.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) => BarChartGroupData(x: entry.key, barRods: [
                    BarChartRodData(toY: entry.value.value.toDouble(), color: Colors.blue),
                  ]))
                      .toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          final keys = donePerMonth.keys.toList();
                          if (index >= 0 && index < keys.length) {
                            return Text(keys[index], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
