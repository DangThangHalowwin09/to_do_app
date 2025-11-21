import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle user signup
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required List<String>? areas,
    required List<String>? group,
  }) async {
    try {
      // Create user in Firebase Authentication with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save additional user data (name, role) in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role, // Role determines if user is Admin or User
        'areas':  areas ?? [],
        'groups': group ?? [],
        'createAt': FieldValue.serverTimestamp(),
      });

      return null; // Success: no error message
    } catch (e) {
      return e.toString(); // Error: return the exception message
    }
  }


  Future<String?> signup_with_email_verify({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required List<String>? areas,
    required List<String>? group,
  }) async {
    try {
      // 1. TẠO USER TRONG FIREBASE AUTHENTICATION
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. GỬI EMAIL XÁC MINH
        await user.sendEmailVerification();

        // 3. LƯU DỮ LIỆU BỔ SUNG VÀO FIRESTORE (Lưu toàn bộ data để không bị mất)
        // Chúng ta dựa vào cờ 'emailVerified' và hàm login để ngăn chặn truy cập.
        await _firestore.collection('users').doc(user.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'role': role,
          'areas': areas ?? [],
          'groups': group ?? [],
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': user.emailVerified, // Luôn là false ban đầu
        });

        // 4. ⚠️ BƯỚC QUAN TRỌNG: ĐĂNG XUẤT NGAY LẬP TỨC
        // Điều này buộc người dùng phải đăng nhập lại,
        // kích hoạt kiểm tra emailVerified trong hàm login.
        await _auth.signOut();

        // 5. Trả về thông báo thành công (không phải null)
        return "Đăng ký thành công! Vui lòng kiểm tra email để xác minh tài khoản trước khi đăng nhập.";

      } else {
        return "Lỗi không xác định: Không thể tạo hồ sơ người dùng.";
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi Firebase Auth (email đã tồn tại, mật khẩu yếu,...)
      return e.message;
    } catch (e) {
      // Xử lý lỗi chung (Firestore, network,...)
      return e.toString();
    }
  }
  // Function to handle user login
  Future<String?> get_login_role({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in the user using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch the user's role from Firestore to determine access level
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      return userDoc['role']; // Return the user's role (Admin/User)
    } catch (e) {
      return e.toString(); // Error: return the exception message
    }
  }

  // for user log out
  signOut() async {
    _auth.signOut();
  }


  /// Đăng ký tài khoản bằng email
  Future<User?> createAccountWithPassword(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      return null;
    }
  }


  /// Gửi email xác minh
  Future<bool> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.sendEmailVerification();
      return true;
    } catch (e) {
      print("Lỗi gửi email verify: $e");
      return false;
    }
  }

  /// Kiểm tra email xác minh chưa
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    return user.emailVerified;
  }
}
