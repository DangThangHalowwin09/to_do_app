import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/admin_list_tile.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';

/// Quản lý các khoa (collection `areas`), mỗi khoa có thể thuộc một khu vực (`groups`).
class AreaManagerScreen extends StatefulWidget {
  const AreaManagerScreen({super.key});

  @override
  State<AreaManagerScreen> createState() => _AreaManagerScreenState();
}

class _AreaManagerScreenState extends State<AreaManagerScreen> {
  final _db = FirebaseFirestore.instance;
  final _searchController = TextEditingController();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _areas = _db.collection('areas').orderBy('name').snapshots();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _groups = _db.collection('groups').orderBy('name').snapshots();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Thêm (docId == null) hoặc sửa một khoa.
  Future<void> _openForm(Map<String, String> groups, {String? docId, String name = '', String? groupId}) async {
    final saved = await showDialog<_AreaForm>(
      context: context,
      builder: (_) => _AreaFormDialog(groups: groups, initialName: name, initialGroupId: groupId, isEditing: docId != null),
    );
    if (saved == null || !mounted) return;

    final data = {'name': saved.name, 'groupId': saved.groupId};
    await runWithFeedback(
      context,
      () => docId == null ? _db.collection('areas').add(data) : _db.collection('areas').doc(docId).update(data),
      success: docId == null ? 'Đã thêm khoa' : 'Đã cập nhật',
    );
  }

  Future<void> _delete(String id, String name) async {
    final ok = await confirmDelete(context, title: 'Xoá khoa', message: 'Xoá "$name"?');
    if (!ok || !mounted) return;
    await runWithFeedback(context, () => _db.collection('areas').doc(id).delete(), success: 'Đã xoá');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _groups,
      builder: (context, groupSnapshot) {
        final groups = {
          for (final d in groupSnapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
            d.id: (d.data()['name'] ?? '') as String,
        };

        return Scaffold(
          appBar: AppBar(title: const Text('Quản lý các khoa')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(groups),
            icon: const Icon(Icons.add),
            label: const Text('Thêm khoa'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Tìm khoa...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Xoá tìm kiếm',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(_searchController.clear),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _areas,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const EmptyState(icon: Icons.cloud_off_rounded, message: 'Không tải được dữ liệu');
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final query = _searchController.text.trim().toLowerCase();
                    final docs = snapshot.data!.docs.where((d) => ((d.data()['name'] ?? '') as String).toLowerCase().contains(query)).toList();
                    if (docs.isEmpty) {
                      return EmptyState(
                        icon: Icons.local_hospital_outlined,
                        message: query.isEmpty ? 'Chưa có khoa nào.' : 'Không tìm thấy khoa "$query".',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data();
                        final name = (data['name'] ?? '') as String;
                        final groupId = data['groupId'] as String?;
                        return AdminListTile(
                          title: name,
                          subtitle: 'Khu vực: ${groups[groupId] ?? 'Chưa gán'}',
                          onEdit: () => _openForm(groups, docId: docs[i].id, name: name, groupId: groupId),
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
      },
    );
  }
}

class _AreaForm {
  const _AreaForm(this.name, this.groupId);

  final String name;
  final String? groupId;
}

class _AreaFormDialog extends StatefulWidget {
  const _AreaFormDialog({required this.groups, required this.initialName, required this.initialGroupId, required this.isEditing});

  final Map<String, String> groups;
  final String initialName;
  final String? initialGroupId;
  final bool isEditing;

  @override
  State<_AreaFormDialog> createState() => _AreaFormDialogState();
}

class _AreaFormDialogState extends State<_AreaFormDialog> {
  late final _name = TextEditingController(text: widget.initialName);
  late String? _groupId = widget.groups.containsKey(widget.initialGroupId) ? widget.initialGroupId : null;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return setState(() => _error = 'Vui lòng nhập tên khoa');
    Navigator.pop(context, _AreaForm(name, _groupId));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Sửa khoa' : 'Thêm khoa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Tên khoa', errorText: _error),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _groupId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Thuộc khu vực (tuỳ chọn)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Chưa gán')),
                for (final e in widget.groups.entries) DropdownMenuItem<String?>(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _groupId = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}
