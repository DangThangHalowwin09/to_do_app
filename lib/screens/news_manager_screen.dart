import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/utils/drive_link.dart';
import '../widgets/admin_list_tile.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';

/// Quản lý tin tức hiển thị ở trang chủ (collection `news`).
class NewsAdminScreen extends StatelessWidget {
  const NewsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final news = FirebaseFirestore.instance.collection('news');

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý tin tức')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditNewsScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Thêm tin'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: news.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const EmptyState(icon: Icons.cloud_off_rounded, message: 'Không tải được dữ liệu');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const EmptyState(icon: Icons.newspaper_rounded, message: 'Chưa có tin tức nào.');

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final title = (data['title'] ?? 'Không có tiêu đề') as String;
              return AdminListTile(
                title: title,
                subtitle: data['url'] as String?,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    driveLinkToDirect((data['imageUrl'] ?? '') as String),
                    width: 64,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 48,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditNewsScreen(id: doc.id, data: data)),
                ),
                onDelete: () async {
                  final ok = await confirmDelete(context, title: 'Xoá tin tức', message: 'Xoá "$title"?');
                  if (ok && context.mounted) {
                    await runWithFeedback(context, () => news.doc(doc.id).delete(), success: 'Đã xoá');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AddEditNewsScreen extends StatefulWidget {
  const AddEditNewsScreen({this.id, this.data, super.key});

  final String? id;
  final Map<String, dynamic>? data;

  @override
  State<AddEditNewsScreen> createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.data?['title'] as String?);
  late final _image = TextEditingController(text: widget.data?['imageUrl'] as String?);
  late final _url = TextEditingController(text: widget.data?['url'] as String?);
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _image.dispose();
    _url.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;

  String? _link(String? v) {
    final empty = _required(v);
    if (empty != null) return empty;
    final uri = Uri.tryParse(v!.trim());
    return (uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty)
        ? null
        : 'Link phải bắt đầu bằng http:// hoặc https://';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final collection = FirebaseFirestore.instance.collection('news');
    final fields = {
      'title': _title.text.trim(),
      'imageUrl': _image.text.trim(),
      'url': _url.text.trim(),
    };
    final ok = await runWithFeedback(
      context,
      () => widget.id == null
          // Chỉ đặt ngày đăng khi tạo mới, sửa bài không làm bài nhảy lên đầu danh sách.
          ? collection.add({...fields, 'createdAt': FieldValue.serverTimestamp()})
          : collection.doc(widget.id).update(fields),
      success: widget.id == null ? 'Đã thêm tin' : 'Đã cập nhật',
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = driveLinkToDirect(_image.text.trim());

    return Scaffold(
      appBar: AppBar(title: Text(widget.id == null ? 'Thêm tin tức' : 'Sửa tin tức')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _image,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Link ảnh (Google Drive hoặc link ảnh)',
                      helperText: 'Với Google Drive: đặt quyền "Bất kỳ ai có đường liên kết"',
                      helperMaxLines: 2,
                    ),
                    validator: _link,
                    onChanged: (_) => setState(() {}),
                  ),
                  if (preview.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        preview,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          alignment: Alignment.center,
                          color: Colors.grey.shade200,
                          child: const Text('Chưa xem trước được ảnh'),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _url,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'Link bài viết gốc'),
                    validator: _link,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(widget.id == null ? 'Thêm mới' : 'Cập nhật'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
