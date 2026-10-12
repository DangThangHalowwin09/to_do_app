import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../services/auth_service.dart';

/// Tự đăng ký bằng email: tạo tài khoản, gửi email xác minh, chờ xác minh rồi sang bước hoàn tất hồ sơ.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _verifyPollInterval = Duration(seconds: 3);

  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isWaitingVerify = false;
  bool _isLoading = false;
  bool _isPasswordHidden = true;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return _showMessage('Vui lòng nhập đủ email và mật khẩu');
    }

    setState(() => _isLoading = true);
    try {
      await _authService.register(email, password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return _showMessage(_registerErrorMessage(e));
    }

    final sent = await _authService.sendVerificationEmail();
    if (!mounted) return;
    if (!sent) {
      setState(() => _isLoading = false);
      return _showMessage('Không thể gửi email xác minh');
    }

    setState(() {
      _isLoading = false;
      _isWaitingVerify = true;
    });
    _timer = Timer.periodic(_verifyPollInterval, (timer) async {
      if (!await _authService.isEmailVerified()) return;
      timer.cancel();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.updateProfile);
    });
  }

  String _registerErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email này đã được đăng ký';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      default:
        return 'Đăng ký thất bại, vui lòng thử lại';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chào bạn đến với UBNA Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                if (!_isWaitingVerify) ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email đăng ký',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isPasswordHidden,
                    onSubmitted: (_) => _signup(),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                        icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _signup,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Đăng ký & gửi email xác minh'),
                    ),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Email xác minh đã được gửi.\n'
                    'Sau khi bạn xác nhận, ứng dụng sẽ tự chuyển sang bước tiếp theo.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
