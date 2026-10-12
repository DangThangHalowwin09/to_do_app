import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/constants/user_role.dart';
import '../core/utils/app_logger.dart';

/// Phạm vi làm việc gắn với một vai trò: danh sách khu vực (IT phần cứng) hoặc khoa (bác sỹ).
enum _Scope {
  groups(
    userField: 'groups',
    collection: 'groups',
    dialogTitle: 'Nhóm khu vực đảm nhiệm:',
    emptyText: 'Chưa gán nhóm',
    icon: Icons.hardware,
  ),
  areas(
    userField: 'areas',
    collection: 'areas',
    dialogTitle: 'Khoa phụ trách:',
    emptyText: 'Chưa gán khoa',
    icon: Icons.location_on,
  );

  const _Scope({
    required this.userField,
    required this.collection,
    required this.dialogTitle,
    required this.emptyText,
    required this.icon,
  });

  final String userField;
  final String collection;
  final String dialogTitle;
  final String emptyText;
  final IconData icon;

  static _Scope? of(UserRole? role) {
    switch (role) {
      case UserRole.hardTeam:
        return groups;
      case UserRole.doctor:
        return areas;
      default:
        return null;
    }
  }
}

/// Tra cứu / phân công nhân viên IT.
class MembersITScreen extends StatelessWidget {
  const MembersITScreen({super.key});

  @override
  Widget build(BuildContext context) => const _MemberListScreen(
        title: 'Tra cứu nhân viên IT',
        emptyText: 'Không có nhân viên nào trong danh sách',
        roles: [UserRole.hardTeam, UserRole.softTeam],
        sortScope: _Scope.groups,
      );
}

/// Tra cứu / phân công khoa cho y bác sỹ.
class MembersDoctorScreen extends StatelessWidget {
  const MembersDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) => const _MemberListScreen(
        title: 'Danh sách Y bác sỹ',
        emptyText: 'Không có Y bác sỹ trong danh sách',
        roles: [UserRole.doctor],
        sortScope: _Scope.areas,
      );
}

class _MemberListScreen extends StatelessWidget {
  const _MemberListScreen({
    required this.title,
    required this.emptyText,
    required this.roles,
    required this.sortScope,
  });

  final String title;
  final String emptyText;
  final List<UserRole> roles;
  final _Scope sortScope;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Truy vấn này cần composite index trong Firestore (role, <scope>, name).
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', whereIn: roles.map((r) => r.label).toList())
            .orderBy('role', descending: true)
            .orderBy(sortScope.userField)
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            AppLog.e('Lỗi Firestore (danh sách nhân viên)', snapshot.error);
            return const Center(
              child: Text('Đã xảy ra lỗi khi tải dữ liệu', style: TextStyle(color: Colors.red)),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data?.docs ?? [];
          if (users.isEmpty) return Center(child: Text(emptyText, style: const TextStyle(fontSize: 16)));

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => _MemberTile(
              docId: users[index].id,
              user: users[index].data(),
              showRole: roles.length > 1,
            ),
          );
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.docId, required this.user, required this.showRole});

  final String docId;
  final Map<String, dynamic> user;
  final bool showRole;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final role = UserRole.fromLabel(user['role'] as String?);
    final scope = _Scope.of(role);
    final scopeValues = scope == null ? const <String>[] : List<String>.from(user[scope.userField] ?? const []);

    return ListTile(
      title: Text((user['name'] ?? 'Chưa có tên') as String, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Row(
        children: [
          if (showRole) Text((user['role'] ?? 'Chưa gắn vị trí') as String),
          if (scope != null) ...[
            if (showRole) const SizedBox(width: 10),
            Icon(scope.icon, size: 16, color: muted),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                scopeValues.isEmpty ? scope.emptyText : scopeValues.join(', '),
                style: TextStyle(color: muted),
              ),
            ),
          ],
        ],
      ),
      trailing: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => _MemberDialog(docId: docId, user: user),
      ),
    );
  }
}

class _MemberDialog extends StatefulWidget {
  const _MemberDialog({required this.docId, required this.user});

  final String docId;
  final Map<String, dynamic> user;

  @override
  State<_MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<_MemberDialog> {
  late final UserRole? _role = UserRole.fromLabel(widget.user['role'] as String?);
  late final _Scope? _scope = _Scope.of(_role);
  late final Set<String> _selected =
      _scope == null ? {} : List<String>.from(widget.user[_scope.userField] ?? const []).toSet();
  late final Future<List<String>> _options = _loadOptions();

  bool _saving = false;

  Future<List<String>> _loadOptions() async {
    final scope = _scope;
    if (scope == null) return [];
    final snapshot = await FirebaseFirestore.instance.collection(scope.collection).orderBy('name').get();
    return snapshot.docs.map((d) => d['name'].toString()).toList();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docId)
          .update({_scope!.userField: _selected.toList()});
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final scope = _scope;

    return AlertDialog(
      title: Text((user['name'] ?? 'Không rõ') as String),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user['email'] != null) Text('Email: ${user['email']}'),
            Text('SĐT: ${user['phone'] ?? 'Chưa có DL'}'),
            Text('Giới thiệu: ${user['bio'] ?? 'Chưa có DL'}'),
            if (user['role'] != null) Text('Vị trí: ${user['role']}'),
            if (user['idDuty'] != null) Text('Mã trực: ${user['idDuty']}'),
            if (scope != null) ...[
              const SizedBox(height: 12),
              Text(scope.dialogTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              FutureBuilder<List<String>>(
                future: _options,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text('Không tải được danh sách');
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return Column(
                    children: [
                      for (final option in snapshot.data!)
                        CheckboxListTile(
                          title: Text(option),
                          value: _selected.contains(option),
                          onChanged: (v) => setState(() => v == true ? _selected.add(option) : _selected.remove(option)),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(scope == null ? 'Đóng' : 'Huỷ'),
        ),
        if (scope != null)
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Lưu thay đổi'),
          ),
      ],
    );
  }
}
