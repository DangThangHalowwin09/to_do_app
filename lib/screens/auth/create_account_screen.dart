import 'package:flutter/material.dart';

import '../../core/constants/user_role.dart';
import '../../services/auth_service.dart';
import '../../widgets/role_scope_picker.dart';

/// Admin tạo tài khoản cho nhân viên.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  UserRole _role = UserRole.user;
  List<String> _areas = [];
  List<String> _groups = [];
  bool _isLoading = false;
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final error = await _authService.createAccountByAdmin(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      role: _role.label,
      areas: _role == UserRole.doctor ? _areas : const [],
      groups: _role == UserRole.hardTeam ? _groups : const [],
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo tài khoản thất bại: $error')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo tài khoản thành công')));
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
  }

  String? _required(String? v, String message) => (v == null || v.trim().isEmpty) ? message : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Tên', border: OutlineInputBorder()),
                validator: (v) => _required(v, 'Vui lòng nhập tên'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => _required(v, 'Vui lòng nhập email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                    icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu tối thiểu 6 ký tự' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Vai trò', border: OutlineInputBorder()),
                items: [
                  for (final role in UserRole.values)
                    DropdownMenuItem(value: role, child: Text(role.label)),
                ],
                onChanged: (role) => setState(() => _role = role!),
              ),
              RoleScopePicker(
                role: _role,
                onAreasChanged: (v) => _areas = v,
                onGroupsChanged: (v) => _groups = v,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createAccount,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Tạo tài khoản'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
