import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AreaManagerScreen extends StatefulWidget {
  const AreaManagerScreen({super.key});

  @override
  State<AreaManagerScreen> createState() => _AreaManagerScreenState();
}

class _AreaManagerScreenState extends State<AreaManagerScreen> {
  final _controller = TextEditingController();

  Future<void> _addArea(String name) async {
    if (name.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('areas').add({'name': name.trim()});
    _controller.clear();
  }

  Future<void> _editArea(String docId, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sửa tên khu vực"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Huỷ")),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Lưu")),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('areas').doc(docId).update({'name': result.trim()});
    }
  }

  Future<void> _deleteArea(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xoá khu vực"),
        content: const Text("Bạn có chắc muốn xoá khu vực này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Huỷ")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xoá")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('areas').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý khu vực")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Thêm khu vực mới...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addArea(_controller.text),
                  child: const Text("Thêm"),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('areas').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final areas = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: areas.length,
                  itemBuilder: (context, index) {
                    final doc = areas[index];
                    final name = doc['name'];
                    return ListTile(
                      title: Text(name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editArea(doc.id, name)),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteArea(doc.id)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
