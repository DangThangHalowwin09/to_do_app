import 'dart:async';
import 'package:flutter/material.dart';
import '../../Service/auth_service.dart';

class SignupEmailScreen extends StatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isWaitingVerify = false;
  bool isLoading = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _signup() async {
    String email = emailController.text.trim();
    String pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ email và mật khẩu")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Tạo tài khoản Firebase
    final user = await AuthService().createAccountWithPassword(email, pass);

    if (user == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email đã tồn tại hoặc không hợp lệ")),
      );
      return;
    }

    // Gửi email verify
    bool sent = await AuthService().sendVerificationEmail();

    if (!sent) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể gửi email xác minh")),
      );
      return;
    }

    setState(() {
      isLoading = false;
      isWaitingVerify = true;
    });

    // Tự động kiểm tra trạng thái emailVerified mỗi 3 giây
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      bool verified = await AuthService().isEmailVerified();

      if (verified) {
        timer.cancel();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/updateProfile");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Chào bạn đến với UBNA Manager",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              if (!isWaitingVerify) ...[
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Nhập email đăng ký",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Mật khẩu",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isLoading ? null : _signup,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Đăng ký & gửi email xác minh"),
                ),
              ] else ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  "Email xác minh đã được gửi.\n"
                      "Sau khi bạn xác nhận, App sẽ điều hướng trang tiếp theo!",
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
