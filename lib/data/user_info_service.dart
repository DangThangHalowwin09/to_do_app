import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoService {
  // Singleton instance
  static final UserInfoService _instance = UserInfoService._internal();
  factory UserInfoService() => _instance;
  UserInfoService._internal();

  // Thông tin người dùng
  String? role;
  String? name;
  String? email;

  /// Gọi hàm này sau khi user đăng nhập để load dữ liệu từ Firestore
  Future<void> fetchUserInfo(String uid) async {
    try {
      clear();
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        role = data['role'];
        name = data['name'];
        email = data['email'];
      }

    } catch (e) {

    }
  }

  /// Xóa thông tin khi đăng xuất (nếu cần)
  void clear() {
    role = null;
    name = null;
    email = null;
  }
}
