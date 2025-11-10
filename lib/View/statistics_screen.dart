import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getStatsStream() {
    final now = DateTime.now();
    final docId = "${now.year}-${now.month.toString().padLeft(2, '0')}"; // ví dụ: 2025-10
    return FirebaseFirestore.instance.collection('visits').doc(docId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê truy cập'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getStatsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Chưa có dữ liệu thống kê"));
          }

          final data = snapshot.data!.data()!;
          final platformAndroid = data['platform_Android'] ?? 0;
          final platformIos = data['platform_Ios'] ?? 0;
          final platformWeb = data['platform_Web'] ?? 0;
          final todayVisits = data['todayVisits'] ?? 0;
          final weekVisits = data['weekVisits'] ?? 0;
          final monthVisits = data['monthVisits'] ?? 0;
          final onlineCount = data['onlineCount'] ?? 0;

          final rows = [
            {'label': 'Truy cập Android', 'value': platformAndroid},
            {'label': 'Truy cập iOS', 'value': platformIos},
            {'label': 'Truy cập Web', 'value': platformWeb},
            {'label': 'Hôm nay', 'value': todayVisits},
            {'label': 'Tuần này', 'value': weekVisits},
            {'label': 'Tháng này', 'value': monthVisits},
            {'label': 'Đang online', 'value': onlineCount},
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: Text(row['label']!),
                  trailing: Text(
                    row['value'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
