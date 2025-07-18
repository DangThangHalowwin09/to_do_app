
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Service/auth_service.dart';
import '../View/login_screen.dart';

class RoleKey {
  static const String admin = 'Admin';
  static const String softTeam = 'Tổ phần mềm';
  static const String hardTeam = 'Tổ phần cứng';
  static const String doctor = 'Y bác sỹ';
  static const String user = 'User';

  static const List<String> itMembers = [softTeam, hardTeam];
  static bool isITMembers(String? role){
    return RoleKey.itMembers.contains(role);
  }

}



class GetCurrentUserInfor {
  /// Lấy thông tin user hiện tại từ Firestore: name và role
  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
  static Future<Map<String, String>> fetchCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snapshot.data();

    if (data != null) {
      return {
        'name': data['name'] ?? '',
        'role': data['role'] ?? '',
      };
    } else {
      return {};
    }
  }

  /// Lấy vai trò người dùng hiện tại từ Firestore
  static Future<String?> getRole() async {
    final uid = currentUid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }

  /// Lấy toàn bộ dữ liệu user hiện tại: name, role, email...
  static Future<Map<String, dynamic>?> getData() async {
    final uid = currentUid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }
}

class UserSession {
  static String? name;
  static String? role;
  static String? email;
  static List<String?> areas = [];

  /// Load thông tin người dùng từ Firestore và lưu lại
  static Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      name = data['name'] ?? '';
      role = data['role'] ?? '';
      email = data['email'] ?? '';
      areas = List<String>.from(data['areas'] ?? []);

    }
  }

  static void clear() {
    name = null;
    role = null;
    email = null;
  }
}

class AuthHelper {
  static final AuthService _authService = AuthService();

  /// Đăng xuất Firebase và xoá session, rồi điều hướng về LoginScreen
  static Future<void> signOutAndRedirectToLogin(BuildContext context) async {
    await _authService.signOut();
    UserSession.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}