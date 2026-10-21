import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/user_role.dart';
import '../../widgets/role_scope_picker.dart';
import '../role_redirect_screen.dart';

/// Hoàn tất hồ sơ sau khi tự đăng ký tài khoản mới.
class FinishProfileScreen extends StatefulWidget {
  const FinishProfileScreen({super.key});

  @override
  State<FinishProfileScreen> createState() => _FinishProfileScreenState();
}

class _FinishProfileScreenState extends State<FinishProfileScreen> {
  /// Người tự đăng ký không được chọn Admin; quyền Admin do Admin cấp.
  static final _selectableRoles = UserRole.values.where((r) => r != UserRole.admin).toList();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  UserRole? _role;
  List<String> _areas = [];
  List<String> _groups = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final role = _role;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return _showMessage('Không tìm thấy tài khoản đăng nhập');
    if (name.isEmpty) return _showMessage('Bạn chưa nhập tên');
    if (phone.isEmpty) return _showMessage('Bạn chưa nhập số điện thoại');
    if (role == null) return _showMessage('Bạn chưa chọn vai trò');

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': name,
        'phone': phone,
        'role': role.label,
        'areas': role.isClinical ? _areas : <String>[],
        'groups': role == UserRole.hardTeam ? _groups : <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return _showMessage('Không lưu được thông tin, vui lòng thử lại');
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleRedirectScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Hoàn tất thông tin tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: email,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email (không thể thay đổi)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Tên', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Vai trò', border: OutlineInputBorder()),
              items: [
                for (final role in _selectableRoles)
                  DropdownMenuItem(value: role, child: Text(role.label)),
              ],
              onChanged: (role) => setState(() => _role = role),
            ),
            RoleScopePicker(
              role: _role,
              onAreasChanged: (v) => _areas = v,
              onGroupsChanged: (v) => _groups = v,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Lưu thông tin'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
