import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helper.dart';
import 'all_welcome_screens.dart';

// Import các màn hình theo vai trò

class RoleRedirectScreen extends StatefulWidget {
  const RoleRedirectScreen({super.key});

  @override
  State<RoleRedirectScreen> createState() => _RoleRedirectScreenState();
}

class _RoleRedirectScreenState extends State<RoleRedirectScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRedirect();
  }

  Future<void> _checkAndRedirect() async {
    await UserSession.loadUserData();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Không có user nào đang đăng nhập → trở lại LoginScreen
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uid = user.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        //throw Exception("Không tìm thấy người dùng trong Firestore.");

        Navigator.pushReplacementNamed(context, '/updateProfile');
        return;
      }

      final role = userDoc['role'] as String;
      Widget targetScreen;

      switch (role) {
        case 'Admin':
          targetScreen = const AdminScreen();
          break;
        case 'User':
          targetScreen =  UserScreen();
          break;
        case 'Tổ phần mềm':
          targetScreen =  SoftwareScreen();
          break;
        case 'Tổ phần cứng':
          targetScreen = HardwareScreen();
          break;
        case 'Y bác sỹ':
          targetScreen =  DoctorScreen();
          break;
        default:
          throw Exception("Vai trò không hợp lệ: $role");
      }

      // Điều hướng đến màn hình phù hợp
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } catch (e) {
      // Xử lý lỗi: thông báo hoặc chuyển về login

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Thông báo: $e")),
      );
      //Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Đang xử lý...
      ),
    );
  }
}
