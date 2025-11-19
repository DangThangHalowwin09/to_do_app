
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Service/auth_service.dart';
import '../View/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({
      'fcmToken': "",
    });
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
  static const String TaskScreen = "task";
  static const String ErrorScreen = "error";
  static const String TypeMessageData = "type";
  static const String IdMessageData = "id";
  static const String TaskScreenRoute = '/task';
  static const String ErrorScreenRoute = '/error';

  static Future<void> sendPushMessage(
      String targetToken,
      String title,
      String detail,
      Map<String, String>? data,
      ) async {
    try {
      final url = Uri.parse("http://192.168.1.10:5000/send-notification"); // hoặc IP máy bạn nếu là máy thật
      final body = {
        "message": {
          "token": targetToken,
          "notification": {"title": title, "body": detail},
          "data": data ?? {},
        }
      };

      final response = await http
          .post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      print("✅ Gửi notification thành công: ${response.body}");
    } catch (e) {
      print("❌ Lỗi khi gửi notification: $e");
    }
  }

}
class StatisticHelper {
  static final _db = FirebaseFirestore.instance;

  static String getPlatform() {
    if (kIsWeb) return "Web";
    if (Platform.isAndroid) return "Android";
    if (Platform.isIOS) return "Ios";
    return "Khác";
  }

  static Future<void> recordVisit(String platform) async {
    try {
      final now = DateTime.now();
      final docId = "${now.year}-${now.month.toString().padLeft(2, '0')}"; // ví dụ: 2025-11
      final docRef = _db.collection('visits').doc(docId);
      final platformKey = 'platform_${platform[0].toUpperCase()}${platform.substring(1)}';
      print('recordVisit() -> $platformKey');

      await docRef.set({
        platformKey: FieldValue.increment(1),
        'todayVisits': FieldValue.increment(1),
        'weekVisits': FieldValue.increment(1),
        'monthVisits': FieldValue.increment(1),
        'lastUpdate': now,
      }, SetOptions(merge: true));

      print('recordVisit() ✅ success for $platformKey');
    } catch (e, st) {
      print('recordVisit() ❌ error: $e');
      print(st);
    }
  }
}

class AppColors {
  static const Color red = Color(0xFFCE3531);  // Đỏ
  static const Color blue = Color(0xFF00408C); // Xanh
}
class NewsContainer extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const NewsContainer({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 70,
                fit: BoxFit.fitHeight,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class General_Helper{
  static String convertDriveLinkToDirect(String url) {
    try {
      // Trường hợp link dạng: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
      if (url.contains("drive.google.com/file/d/")) {
        final id = url.split("drive.google.com/file/d/")[1].split("/")[0];
        return "https://drive.google.com/uc?export=view&id=$id";
      }

      // Trường hợp link dạng: https://drive.google.com/open?id=FILE_ID
      if (url.contains("drive.google.com/open?id=")) {
        final id = url.split("drive.google.com/open?id=")[1];
        return "https://drive.google.com/uc?export=view&id=$id";
      }

      // Trường hợp link dạng: https://drive.google.com/uc?id=FILE_ID&export=download
      if (url.contains("drive.google.com/uc?id=")) {
        final id = url.split("drive.google.com/uc?id=")[1].split("&")[0];
        return "https://drive.google.com/uc?export=view&id=$id";
      }

      return url; // Không phải link Drive → trả lại bình thường
    } catch (e) {
      return url; // Khi lỗi vẫn trả lại link cũ
    }
  }
}