import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Service/upload_service.dart'; // Hàm upload ảnh lên Firebase Storage

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _image;
  bool _loading = false;

  final currentUser = FirebaseAuth.instance.currentUser;

  String? _role;
  List<String> _areas = [];
  List<String> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _bioController.text = data['bio'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _role = data['role'] ?? '';
      _areas = List<String>.from(data['areas'] ?? []);
      _groups = List<String>.from(data['groups'] ?? []);
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (currentUser == null) return;

    setState(() => _loading = true);
    String? imageUrl;

    if (_image != null) {
      imageUrl = await UploadService.uploadImage(_image!);
    }

    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'phone': _phoneController.text.trim(),
      'image': imageUrl,
    }, SetOptions(merge: true));

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thành công')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật thông tin cá nhân')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? const Icon(Icons.add_a_photo, size: 30) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                maxLines: 1,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
              ),
              TextField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Giới thiệu bản thân'),
              ),
              const SizedBox(height: 20),
              if (_role != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Thành viên: $_role',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (_role == 'Tổ phần cứng') ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Nhóm khu vực đảm nhiệm:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _groups
                      .map((area) => Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(area),
                    ],
                  ))
                      .toList(),
                ),
                ],
                const SizedBox(height: 20),
                if (_role == 'Y bác sỹ') ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Khoa phòng đảm nhiệm:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _areas
                      .map((area) => Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(area),
                    ],
                  ))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
