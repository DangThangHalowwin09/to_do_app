
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Service/auth_service.dart';
import '../View/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';




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
  static bool isAdmin(String? role){
    return role == admin;
  }

  static Future<bool> isCurrentUserAdmin() async {
    final role = await GetCurrentUserInfor.getRole();
    print(role);
    return role == admin; // Giả sử "admin" là String, chứ không phải biến
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
  static Future<String?> getName() async {
    final uid = currentUid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['name'];
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


class ContactHelper {
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      print('Không thể gọi $phoneNumber');
    }
  }

  static Future<void> launchZalo(String phoneNumber) async {
    final Uri url = Uri.parse('https://zalo.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('Không thể mở Zalo với số $phoneNumber');
    }
  }

  static Future<void> launchFacebook(String facebookUrl) async {
    final Uri url = Uri.parse(facebookUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('Không thể mở Facebook $facebookUrl');
    }
  }

  static Future<void> launchYouTube(String youtubeUrl) async {
    final Uri url = Uri.parse(youtubeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('Không thể mở YouTube $youtubeUrl');
    }
  }
}
Future<List<String>> fetchAreaNamesFromGroups(List<String> groupIds) async {

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('groups')
      .where('name', whereIn: groupIds)
      .get();

  List<String> groupIdsList = snapshot.docs.map((doc) => doc.id).toList();

  try {
    // Kiểm tra danh sách rỗng
    if (groupIdsList.isEmpty) {
      return [];
    }

    // Firestore giới hạn whereIn tối đa 10 phần tử
    if (groupIdsList.length > 10) {
      throw Exception('Danh sách groupIdsList không được vượt quá 10 phần tử');
    }


    // Truy vấn Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('areas')
        .where('groupId', whereIn: groupIdsList)
        .get();
    print('Số lượng tài liệu tìm thấy: ${snapshot.docs.length}');
    print('Danh sách tài liệu: ${snapshot.docs.map((doc) => doc.data()).toList()}');
    // Lấy danh sách tên khu vực
    return snapshot.docs
        .map((doc) => doc.data()['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  } catch (e) {
    // Xử lý lỗi
    print('Lỗi khi lấy danh sách khu vực: $e');
    return [];
  }
}

class GroupHelper {
  static Future<String?> getGroupNameByID(String id) async {
    final doc = await FirebaseFirestore.instance.collection('groups').doc(id).get();
    return doc.data()?['name'] as String?;
  }

  static Future<String?> getGroupIDByName(String name) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
  }
}
class PushNotificationHelper{
  static Future<void> sendPushMessage(String token, String title, String body) async {
    const String serverKey = 'YOUR_SERVER_KEY_HERE'; // Server key từ Firebase console

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
          },
          'priority': 'high',
          'to': token,
        },
      ),
    );
  }
}

