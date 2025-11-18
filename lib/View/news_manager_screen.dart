import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsAdminScreen extends StatelessWidget {
  const NewsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý bài viết"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditNewsScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('news')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có bài viết nào"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                child: ListTile(
                  title: Text(data["title"] ?? "Không có tiêu đề"),
                  subtitle: Text(data["url"] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditNewsScreen(
                                id: doc.id,
                                data: data,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("news")
                              .doc(doc.id)
                              .delete();
                        },
                      ),
                    ],
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

class AddEditNewsScreen extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? data;

  const AddEditNewsScreen({this.id, this.data, super.key});

  @override
  State<AddEditNewsScreen> createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  final _titleController = TextEditingController();
  final _imageController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.data != null) {
      _titleController.text = widget.data!["title"] ?? "";
      _imageController.text = widget.data!["imageUrl"] ?? "";
      _urlController.text = widget.data!["url"] ?? "";
    }
  }

  void _saveNews() async {
    final title = _titleController.text.trim();
    final imageUrl = _imageController.text.trim();
    final url = _urlController.text.trim();

    if (title.isEmpty || imageUrl.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    final data = {
      "title": title,
      "imageUrl": imageUrl,
      "url": url,
      "createdAt": FieldValue.serverTimestamp(),
    };

    if (widget.id == null) {
      /// THÊM MỚI
      await FirebaseFirestore.instance.collection("news").add(data);
    } else {
      /// CẬP NHẬT
      await FirebaseFirestore.instance
          .collection("news")
          .doc(widget.id)
          .update(data);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? "Thêm bài viết" : "Sửa bài viết"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: "Link ảnh Google Drive"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: "Link bài viết gốc"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveNews,
              child: Text(widget.id == null ? "Thêm mới" : "Cập nhật"),
            )
          ],
        ),
      ),
    );
  }
}
