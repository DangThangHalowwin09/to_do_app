import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Không cần import ở đây
import '../../Service/auth_service.dart'; // Đảm bảo đúng đường dẫn

class SignupWithEmailVerification extends StatefulWidget {
  const SignupWithEmailVerification({super.key});

  @override
  State<SignupWithEmailVerification> createState() =>
      _SignupWithEmailVerificationState();
}

class _SignupWithEmailVerificationState
    extends State<SignupWithEmailVerification> {
  final AuthService _auth = AuthService();

  // Controllers
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = false;
  String selectedRole = "";

  void showPopup(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thông báo"),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // ----------------------- SIGNUP & SEND VERIFICATION EMAIL -----------------------------
  void registerAccount() async {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String pass = passwordController.text.trim();
    String confirm = confirmPasswordController.text.trim();
    String phone = phoneController.text.trim();

    // --- Kiểm tra đầu vào ---
    if (email.isEmpty || !email.contains("@")) {
      showPopup("Email không hợp lệ!");
      return;
    }
    if (name.isEmpty) {
      showPopup("Chưa nhập tên!");
      return;
    }
    if (pass.isEmpty || confirm.isEmpty) {
      showPopup("Chưa nhập mật khẩu!");
      return;
    }
    if (pass != confirm) {
      showPopup("Mật khẩu không khớp!");
      return;
    }
    if (selectedRole.isEmpty) {
      showPopup("Bạn chưa chọn vai trò!");
      return;
    }
    // -------------------------

    setState(() => loading = true);

    String? result = await _auth.signup_with_email_verify(
      name: name,
      email: email,
      password: pass,
      phone: phone,
      role: selectedRole,
      areas: [],
      group: [],
    );

    setState(() => loading = false);

    if (result == null) {
      // Đăng ký thành công và đã gửi email xác minh
      showPopup(
          "Đăng ký thành công! Vui lòng kiểm tra email của bạn để xác minh tài khoản trước khi đăng nhập.");
      // Có thể điều hướng đến màn hình đăng nhập
      // Navigator.pop(context);
    } else {
      showPopup("Đăng ký thất bại: $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký tài khoản")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CÁC TRƯỜNG THÔNG TIN ĐĂNG KÝ ---
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Gmail",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Tên",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Mật khẩu",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nhập lại mật khẩu",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Phone",
              ),
            ),
            const SizedBox(height: 12),

            // --- VAI TRÒ ---
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Vai trò"),
              value: selectedRole.isEmpty ? null : selectedRole,
              items: [
                "User",
                "Admin",
                "Tổ phần cứng",
                "Tổ phần mềm",
                "Y bác sỹ"
              ]
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => selectedRole = v!),
            ),

            const SizedBox(height: 30),

            // --- NÚT ĐĂNG KÝ ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : registerAccount,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15)),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Đăng ký và Gửi Email Xác minh",
                    style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Tài khoản sẽ được tạo, nhưng bạn cần xác minh email để đăng nhập.",
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}