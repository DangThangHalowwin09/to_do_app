import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/user_role.dart';
import '../services/upload_service.dart';
import '../services/user_session.dart';

/// Nhân viên tự cập nhật tên, số điện thoại, giới thiệu và ảnh đại diện.
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  XFile? _pickedImage;
  String? _currentImageUrl;
  UserRole? _role;
  List<String> _areas = [];
  List<String> _groups = [];
  bool _loading = true;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = UserSession.instance.uid;
    return uid == null ? null : FirebaseFirestore.instance.collection('users').doc(uid);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final data = (await _userDoc?.get())?.data();
    if (!mounted) return;
    setState(() {
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _currentImageUrl = data['image'] as String?;
        _role = UserRole.fromLabel(data['role'] as String?);
        _areas = List<String>.from(data['areas'] ?? const []);
        _groups = List<String>.from(data['groups'] ?? const []);
      }
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1024);
    if (picked != null) setState(() => _pickedImage = picked);
  }

  Future<void> _saveProfile() async {
    final doc = _userDoc;
    if (doc == null) return;

    setState(() => _loading = true);
    try {
      final update = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
      };
      // Chỉ ghi đè ảnh khi người dùng chọn ảnh mới.
      if (_pickedImage != null) update['image'] = await UploadService.uploadImage(_pickedImage!);

      await doc.set(update, SetOptions(merge: true));
      await UserSession.instance.load();
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật thành công')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại, vui lòng thử lại')));
    }
  }

  Future<ImageProvider?> _avatar() async {
    final picked = _pickedImage;
    if (picked != null) return MemoryImage(await picked.readAsBytes());
    final url = _currentImageUrl;
    return url == null || url.isEmpty ? null : NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật thông tin cá nhân')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: FutureBuilder<ImageProvider?>(
                      future: _avatar(),
                      builder: (context, snapshot) => Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: snapshot.data,
                            child: snapshot.data == null ? const Icon(Icons.person, size: 40) : null,
                          ),
                          IconButton.filled(
                            tooltip: 'Đổi ảnh đại diện',
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_a_photo, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Giới thiệu bản thân'),
                  ),
                  const SizedBox(height: 20),
                  if (_role != null)
                    Text('Thành viên: ${_role!.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (_role == UserRole.hardTeam) _ScopeList(title: 'Nhóm khu vực đảm nhiệm:', items: _groups),
                  if (_role == UserRole.doctor) _ScopeList(title: 'Khoa phòng đảm nhiệm:', items: _areas),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(onPressed: _saveProfile, child: const Text('Lưu')),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ScopeList extends StatelessWidget {
  const _ScopeList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}
