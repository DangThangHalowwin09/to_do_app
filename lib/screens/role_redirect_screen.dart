import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../services/auth_service.dart';
import '../services/user_session.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

/// Màn hình trung gian sau khi đăng nhập: nạp hồ sơ rồi chuyển tới màn hình đúng vai trò.
/// Đây là NƠI DUY NHẤT quyết định người dùng sẽ vào màn hình nào.
class RoleRedirectScreen extends StatefulWidget {
  const RoleRedirectScreen({super.key});

  @override
  State<RoleRedirectScreen> createState() => _RoleRedirectScreenState();
}

class _RoleRedirectScreenState extends State<RoleRedirectScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    setState(() => _error = null);
    final session = UserSession.instance;
    try {
      final hasProfile = await session.load();
      if (!mounted) return;

      if (!hasProfile || !session.hasCompleteProfile) {
        Navigator.pushReplacementNamed(context, AppRoutes.updateProfile);
        return;
      }

      final role = session.role;
      if (role == null) {
        setState(() => _error = 'Vai trò không hợp lệ: "${session.roleLabel}". Vui lòng liên hệ phòng CNTT.');
        return;
      }

      await AuthService().saveFcmToken();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(role: role)),
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Không tải được thông tin tài khoản. Kiểm tra kết nối mạng và thử lại.');
    }
  }

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    await AuthService().signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return Scaffold(
      body: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(error, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _redirect, child: const Text('Thử lại')),
                    TextButton(onPressed: _signOut, child: const Text('Đăng xuất')),
                  ],
                ),
              ),
      ),
    );
  }
}
