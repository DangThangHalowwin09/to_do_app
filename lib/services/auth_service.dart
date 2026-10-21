import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/utils/app_logger.dart';
import 'firebase_messaging_service.dart';
import 'user_session.dart';

/// Đăng nhập / đăng ký / đăng xuất và các thao tác liên quan tới tài khoản Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ném [FirebaseAuthException] nếu sai thông tin đăng nhập.
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
  }

  /// Tạo tài khoản tự đăng ký (chưa có hồ sơ). Ném [FirebaseAuthException] khi lỗi.
  Future<User> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return credential.user!;
  }

  /// Admin tạo tài khoản cho nhân viên. Trả về `null` nếu thành công, ngược lại là thông báo lỗi.
  ///
  /// Dùng một FirebaseApp phụ để tạo user, nếu không Firebase sẽ tự đăng nhập
  /// bằng tài khoản mới và làm admin bị văng khỏi phiên của mình.
  Future<String?> createAccountByAdmin({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    List<String> areas = const [],
    List<String> groups = const [],
  }) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'account-creation',
        options: Firebase.app().options,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role,
        'areas': areas,
        'groups': groups,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await secondaryAuth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    } finally {
      await secondaryApp?.delete();
    }
  }

  Future<bool> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      await user.sendEmailVerification();
      return true;
    } catch (e) {
      AppLog.e('Lỗi gửi email xác minh', e);
      return false;
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Đăng ký thiết bị này nhận thông báo cho tài khoản đang đăng nhập.
  Future<void> saveFcmToken() => FirebaseMessagingService.instance.registerDevice();

  /// Gỡ thiết bị (để không nhận thông báo của tài khoản cũ), xoá phiên và đăng xuất.
  Future<void> signOut() async {
    await FirebaseMessagingService.instance.unregisterDevice();
    UserSession.instance.clear();
    await _auth.signOut();
  }

  /// Chuyển lỗi đăng nhập của Firebase thành thông báo dễ hiểu cho nhân viên.
  static String loginErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Email không hợp lệ.';
        case 'user-disabled':
          return 'Tài khoản đã bị khoá, vui lòng liên hệ phòng CNTT.';
        case 'too-many-requests':
          return 'Đăng nhập sai quá nhiều lần, vui lòng thử lại sau.';
        case 'network-request-failed':
          return 'Không có kết nối mạng.';
        default:
          return 'Sai email hoặc mật khẩu.';
      }
    }
    return 'Đăng nhập thất bại, vui lòng liên hệ phòng CNTT. ($error)';
  }
}
