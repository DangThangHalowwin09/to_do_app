import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckBHXHScreen extends StatefulWidget {
  const CheckBHXHScreen({Key? key}) : super(key: key);

  @override
  State<CheckBHXHScreen> createState() => _CheckBHXHScreenState();
}

class _CheckBHXHScreenState extends State<CheckBHXHScreen> {
  final CollectionReference _errorRef =
  FirebaseFirestore.instance.collection('errors');

  void _deleteError(String docId) async {
    try {
      await _errorRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã xoá bệnh nhân khỏi danh sách lỗi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi khi xoá: $e')),
      );
    }
  }

  void _showErrorDetail(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> errors = data['errors'] ?? [];
    final String name = data['name'] ?? 'Không rõ';
    final String code = data['code'] ?? 'Không rõ';
    final Timestamp updatedAt = data['updatedAt'] ?? Timestamp.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Chi tiết lỗi - $name'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🧍‍♂️ Bệnh nhân: $name"),
              Text("🩺 Mã bệnh nhân: $code"),
              Text("🕓 Cập nhật: ${updatedAt.toDate()}"),
              const SizedBox(height: 10),
              const Text("Danh sách lỗi:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...errors.map((e) => Text("• $e")).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteError(doc.id);
            },
            child: const Text('✅ Hoàn thành chỉnh lỗi'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🩻 Kiểm tra lỗi BHXH'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _errorRef.orderBy('updatedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có lỗi nào'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String name = data['name'] ?? 'Không rõ';
              final String code = data['code'] ?? 'Không rõ';
              final List errors = data['errors'] ?? [];
              final Timestamp updatedAt = data['updatedAt'] ?? Timestamp.now();

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Mã bệnh nhân: $code"),
                      Text("Số lỗi: ${errors.length}"),
                      Text("Cập nhật: ${updatedAt.toDate()}"),
                    ],
                  ),
                  onTap: () => _showErrorDetail(docs[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
