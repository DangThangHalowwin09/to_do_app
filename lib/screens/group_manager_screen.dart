import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/admin_list_tile.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';

/// Quản lý các khu vực (collection `groups`); mỗi khu vực gồm nhiều khoa (`areas`).
class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final _db = FirebaseFirestore.instance;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final ok = await runWithFeedback(
      context,
      () => _db.collection('groups').add({'name': name}),
      success: 'Đã thêm khu vực',
    );
    if (ok) _controller.clear();
  }

  Future<void> _edit(String id, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa tên khu vực'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Tên khu vực')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Lưu')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || name == current || !mounted) return;
    await runWithFeedback(context, () => _db.collection('groups').doc(id).update({'name': name}), success: 'Đã cập nhật');
  }

  Future<void> _delete(String id, String name) async {
    // Cảnh báo nếu còn khoa đang thuộc khu vực này.
    final inUse = await _db.collection('areas').where('groupId', isEqualTo: id).count().get();
    if (!mounted) return;
    final note = (inUse.count ?? 0) > 0 ? '\nCó ${inUse.count} khoa đang thuộc khu vực này, các khoa đó sẽ chưa có khu vực.' : '';
    final ok = await confirmDelete(context, title: 'Xoá khu vực', message: 'Xoá "$name"?$note');
    if (!ok || !mounted) return;
    await runWithFeedback(context, () => _db.collection('groups').doc(id).delete(), success: 'Đã xoá');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý khu vực')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                    decoration: const InputDecoration(labelText: 'Thêm khu vực mới'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(height: 52, child: FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Thêm'))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.collection('groups').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const EmptyState(icon: Icons.cloud_off_rounded, message: 'Không tải được dữ liệu');
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const EmptyState(icon: Icons.domain_rounded, message: 'Chưa có khu vực nào.\nHãy thêm khu vực đầu tiên ở ô phía trên.');

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final name = (docs[i].data()['name'] ?? '') as String;
                    return AdminListTile(
                      title: name,
                      onEdit: () => _edit(docs[i].id, name),
                      onDelete: () => _delete(docs[i].id, name),
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
