import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../general_information_screen.dart';
import '../role_redirect_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.signIn(_emailController.text, _passwordController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(AuthService.loginErrorMessage(e));
      return;
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleRedirectScreen()),
      (_) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ExcludeSemantics(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset('assets/icon_login.jpg', height: 160, fit: BoxFit.cover, width: double.infinity),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Đăng nhập', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Dành cho cán bộ, nhân viên Bệnh viện Ung bướu Nghệ An', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordHidden,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _isPasswordHidden ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                          onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                          icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Đăng nhập'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          ),
                          child: const Text('Chưa có tài khoản? Đăng ký'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const GeneralInformationScreen()),
                          ),
                          child: const Text('Về trang chủ'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
