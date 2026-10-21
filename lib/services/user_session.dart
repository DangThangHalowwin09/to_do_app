import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/user_role.dart';

/// Thông tin người dùng đang đăng nhập, nạp một lần từ `users/{uid}` rồi dùng chung.
/// Thay thế cho 3 lớp trùng chức năng trước đây (UserSession, UserInfoService, GetCurrentUserInfor).
class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  String? uid;
  String name = '';
  String email = '';
  String phone = '';
  String roleLabel = '';
  List<String> areas = const [];

  UserRole? get role => UserRole.fromLabel(roleLabel);
  bool get isAdmin => role == UserRole.admin;
  /// Bác sỹ / điều dưỡng: gửi báo lỗi và đánh giá nhân viên IT.
  bool get isClinical => role?.isClinical ?? false;
  bool get isItMember => role?.isItMember ?? false;

  /// Hồ sơ đã đủ tên + vai trò chưa (nếu chưa thì phải qua màn hình hoàn thiện hồ sơ).
  bool get hasCompleteProfile => name.trim().isNotEmpty && roleLabel.trim().isNotEmpty;

  /// Trả về `false` nếu chưa đăng nhập hoặc chưa có document `users/{uid}`.
  Future<bool> load() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      clear();
      return false;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
    final data = doc.data();
    if (data == null) {
      clear();
      uid = currentUid;
      return false;
    }
    uid = currentUid;
    name = (data['name'] ?? '').toString();
    email = (data['email'] ?? '').toString();
    phone = (data['phone'] ?? '').toString();
    roleLabel = (data['role'] ?? '').toString();
    areas = List<String>.from(data['areas'] ?? const []);
    return true;
  }

  void clear() {
    uid = null;
    name = '';
    email = '';
    phone = '';
    roleLabel = '';
    areas = const [];
  }
}
