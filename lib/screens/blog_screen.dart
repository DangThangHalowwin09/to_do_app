import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showBlogDialog({String? id, String? title, String? content}) async {
    final TextEditingController titleController = TextEditingController(text: title);
    final TextEditingController contentController = TextEditingController(text: content);

    final isEditing = id != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Chỉnh sửa bài viết" : "Thêm bài viết mới"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Chủ đề"),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Nội dung"),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(isEditing ? "Cập nhật" : "Lưu"),
            onPressed: () async {
              final newTitle = titleController.text.trim();
              final newContent = contentController.text.trim();
              if (newTitle.isNotEmpty && newContent.isNotEmpty) {
                if (isEditing) {
                  await _firestore.collection('blogs').doc(id).update({
                    'title': newTitle,
                    'content': newContent,
                  });
                } else {
                  await _firestore.collection('blogs').add({
                    'title': newTitle,
                    'content': newContent,
                    'created_at': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBlog(String id) async {
    await _firestore.collection('blogs').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Trở về trang trước đó
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('blogs')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi khi tải dữ liệu"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có bài viết nào"));
          }

          final blogs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
              final data = blog.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(data['content'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showBlogDialog(
                            id: blog.id,
                            title: data['title'],
                            content: data['content'],
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBlog(blog.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBlogDialog(),
        child: const Icon(Icons.add),
      ),

    );
  }
}
