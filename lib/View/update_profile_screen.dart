import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Service/upload_service.dart'; // hàm upload ảnh lên Firebase Storage

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _numberController = TextEditingController();
  File? _image;
  bool _loading = false;

  final currentUser = FirebaseAuth.instance.currentUser;

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
      _numberController.text = data['number'] ?? '';
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
      imageUrl = await UploadService.uploadImage(_image!); // hàm upload trả về URL
    }

    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'number': _numberController.text.trim(),
      'image': imageUrl,
    }, SetOptions(merge: true));

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật thành công')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cập nhật thông tin cá nhân')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
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
                  child: _image == null ? Icon(Icons.add_a_photo, size: 30) : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _numberController,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'number'),
              ),
              TextField(
                controller: _bioController,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Giới thiệu bản thân'),
              ),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
