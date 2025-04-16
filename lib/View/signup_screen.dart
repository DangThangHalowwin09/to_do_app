import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/home_screen.dart';
import '../Service/auth_service.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService =
      AuthService(); // Instance of AuthService for authentication logic

  // Controllers for capturing input from text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'User'; // Default selected role for dropdown
  bool _isLoading = false; // To show loading spinner during signup
  bool isPasswordHidden = true;

  // Signup function to handle user registration
  void _signup() async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    // Call signup method from AuthService with user inputs
    String? result = await _authService.signup(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    setState(() {
      _isLoading = false; // Hide loading spinner
    });

    if (result == null) {
      // Signup successful: Navigate to LoginScreen with success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đăng ký thành công'),
      ));
      showActionDialog(context);
      /*Navigator.pushReplacement(


        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );*/
    } else {
      // Signup failed: Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Đăng ký thất bại nguyên nhân: $result'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding to the screen
        child: SingleChildScrollView(
          // Makes the screen scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/icon_login.jpg"), // Display an image at the top
              // Input for name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Input for email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Input for password
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                     onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: isPasswordHidden, // Hide the password
              ),
              const SizedBox(height: 16),
              // Dropdown for selecting role
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!; // Update role selection
                  });
                },
                items: ['Admin', 'User', 'Nhân viên phần cứng', 'Nhân viên phần mềm', 'Y bác sỹ'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Signup button or loading spinner
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity, // Button stretches across width
                      child: ElevatedButton(
                        onPressed: () {
                          _signup();
                           // Gọi hàm khi nhấn
                        },// Call signup function
                        child: const Text(" Đăng ký "),
                      ),
                    ),
              const SizedBox(height: 10),
              // Navigation to LoginScreen
              /*Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Đã có tài khoản? Đăng nhập ",
                    style: TextStyle(fontSize: 18),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "tại đây.",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: -1),
                    ),
                  ),
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

void showActionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Bạn đã đăng ký thành công tài khoản'),
        content: const Text('Tiếp tục đăng ký tài khoản?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              // Hành động đăng ký thêm ở đây, có thể không cần chuyển trang
            },
            child: const Text('Đăng ký thêm'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AdminScreen()),
                    (route) => false,
              );
            },
            child: const Text('Về trang Admin'),
          ),
        ],
      );
    },
  );
}