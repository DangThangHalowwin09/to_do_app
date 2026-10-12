import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Danh sách bệnh nhân có lỗi thẻ BHYT cần chỉnh sửa (collection `errors_BHYT`).
class CheckBHXHScreen extends StatefulWidget {
  const CheckBHXHScreen({super.key});

  @override
  State<CheckBHXHScreen> createState() => _CheckBHXHScreenState();
}

class _CheckBHXHScreenState extends State<CheckBHXHScreen> {
  static final _dateFormat = DateFormat('HH:mm dd/MM/yyyy');
  final _collection = FirebaseFirestore.instance.collection('errors_BHYT');

  Future<void> _markResolved(String docId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _collection.doc(docId).delete();
      messenger.showSnackBar(const SnackBar(content: Text('Đã xoá bệnh nhân khỏi danh sách lỗi')));
    } catch (e) {
      messenger.showSnackBar(const SnackBar(content: Text('Xoá thất bại, vui lòng thử lại')));
    }
  }

  void _showDetail(String docId, Map<String, dynamic> data) {
    final name = (data['name'] ?? 'Không rõ') as String;
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Chi tiết lỗi - $name'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('BN: $name'),
              Text('Mã BN: ${data['code'] ?? 'Không rõ'}'),
              if (updatedAt != null) Text('Cập nhật: ${_dateFormat.format(updatedAt)}'),
              const SizedBox(height: 10),
              const Text('Danh sách lỗi:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('- ${data['error'] ?? 'Không rõ'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _markResolved(docId);
            },
            child: const Text('Hoàn thành chỉnh lỗi'),
          ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra lỗi BHXH')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _collection.orderBy('updatedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Không tải được dữ liệu'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('Không có lỗi nào'));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text((data['name'] ?? 'Không rõ') as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Mã bệnh nhân: ${data['code'] ?? 'Không rõ'}'),
                  onTap: () => _showDetail(doc.id, data),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
