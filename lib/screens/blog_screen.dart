import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';

/// Các mẹo hay (collection `blogs`) do nhân viên IT chia sẻ.
class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final _blogs = FirebaseFirestore.instance.collection('blogs');

  Future<void> _openForm({String? id, String title = '', String content = ''}) async {
    final result = await showDialog<({String title, String content})>(
      context: context,
      builder: (_) => _BlogFormDialog(title: title, content: content, isEditing: id != null),
    );
    if (result == null || !mounted) return;

    await runWithFeedback(
      context,
      () => id == null
          ? _blogs.add({'title': result.title, 'content': result.content, 'created_at': FieldValue.serverTimestamp()})
          : _blogs.doc(id).update({'title': result.title, 'content': result.content}),
      success: id == null ? 'Đã đăng mẹo' : 'Đã cập nhật',
    );
  }

  Future<void> _delete(String id, String title) async {
    final ok = await confirmDelete(context, title: 'Xoá bài viết', message: 'Xoá "$title"?');
    if (!ok || !mounted) return;
    await runWithFeedback(context, () => _blogs.doc(id).delete(), success: 'Đã xoá');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mẹo hay')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Thêm mẹo'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _blogs.orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const EmptyState(icon: Icons.cloud_off_rounded, message: 'Không tải được dữ liệu');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return EmptyState(
              icon: Icons.lightbulb_outline_rounded,
              message: 'Chưa có mẹo nào.\nHãy chia sẻ mẹo đầu tiên cho đồng nghiệp.',
              actionLabel: 'Thêm mẹo',
              onAction: _openForm,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final title = (data['title'] ?? '') as String;
              final content = (data['content'] ?? '') as String;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  title: Text(title, style: Theme.of(context).textTheme.titleMedium),
                  shape: const Border(),
                  collapsedShape: const Border(),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(content, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _openForm(id: docs[i].id, title: title, content: content),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Sửa'),
                        ),
                        TextButton.icon(
                          onPressed: () => _delete(docs[i].id, title),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Xoá'),
                          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BlogFormDialog extends StatefulWidget {
  const _BlogFormDialog({required this.title, required this.content, required this.isEditing});

  final String title;
  final String content;
  final bool isEditing;

  @override
  State<_BlogFormDialog> createState() => _BlogFormDialogState();
}

class _BlogFormDialogState extends State<_BlogFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.title);
  late final _content = TextEditingController(text: widget.content);

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Chỉnh sửa mẹo' : 'Thêm mẹo mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _title, autofocus: true, decoration: const InputDecoration(labelText: 'Chủ đề'), validator: _required),
              const SizedBox(height: 12),
              TextFormField(controller: _content, maxLines: 6, minLines: 3, decoration: const InputDecoration(labelText: 'Nội dung'), validator: _required),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, (title: _title.text.trim(), content: _content.text.trim()));
            }
          },
          child: Text(widget.isEditing ? 'Cập nhật' : 'Lưu'),
        ),
      ],
    );
  }
}
