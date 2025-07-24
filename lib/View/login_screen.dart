// This screen handles user login with email and password
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Service/auth_service.dart';
import '../data/auth_data.dart';
import '../utils/helper.dart';
import 'all_welcome_screens.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService(); // Instance of AuthService
// Controller for email input
  final _emailController = TextEditingController();
  // Controller for password input
  final _passwordController = TextEditingController();
  // To show spinner during login
  bool _isLoading = false;

  // Login function to handle user authentication
  void _login() async {
    AuthenticationRemote().login(_emailController.text, _passwordController.text);
    setState(() {
      _isLoading = true; // Show spinner
      
    });

    // Call login method from AuthService with user inputs
    String? result = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    await UserSession.loadUserData();
    setState(() {
      _isLoading = false; // Hide spinner
    });

    // Navigate based on role or show error message
    if (result == 'Admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminScreen(),
        ),
      );
    } else if (result == 'User') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const UserScreen(),
        ),
      );
    }
    else if (result ==  'Tổ phần cứng') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HardwareScreen(),
        ),
      );
    }
    else if (result == 'Tổ phần mềm') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SoftwareScreen(),
        ),
      );
    }
    else if (result == 'Y bác sỹ') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DoctorScreen(),
        ),
      );
    }
   else {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  backgroundColor: Colors.black,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  content: Row(
  children: [
  Icon(Icons.error_outline, color: Colors.red),
  const SizedBox(width: 8),
  Expanded(child: Text('${translateError(result ?? 'Firebase return null')}')),
  ],
  ),
  duration: Duration(seconds: 4),
  ),
  );
  }
  }
  bool isPasswordHidden = true;

 /* Future<void> _launchZalo() async {
    final phoneNumber = '0866573502';
    final Uri url = Uri.parse('https://zalo.me/$phoneNumber');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('Không thể mở $url');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Add padding
            child: Column(
              children: [
                   Image.asset("assets/icon_login.jpg"), // Display login screen image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Đăng Nhập",
                      style: TextStyle(fontSize: 24,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                  obscureText: true, // Hide password
                ),
                const SizedBox(height: 20),
                // Login button or spinner
                _isLoading
                    ? const CircularProgressIndicator()
                    :  SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login, // Call login function
                          child: const Text('Đăng nhập'),
                        ),
                      ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Nếu chưa có tài khoản?",
                      style: TextStyle(fontSize: 15,
                        color: Colors.blue,
                      ),
          
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GuestScreen()),
                        );
                      },
                      child: const Text(
                        " Tài khoản khách",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: -1,
                        ),

                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                /*SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GuestScreen()),
                      );
                    }, // Call login function
                    child: const Text('Tài khoản Guest'),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
String translateError(String errorCode) {
  switch (errorCode) {
    case 'Firebase return null':
      return 'Firebase return null string, hãy liên hệ IT';
    default:
      return 'Đăng nhập thất bại, kiểm tra tài khoản hoặc liên hệ với IT, tên lỗi: $errorCode';
  }
}