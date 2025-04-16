import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/signup_screen.dart';
import 'package:flutter_to_do_list/screen/home.dart';
import '../Service/auth_service.dart';
import '../screen/statistics_screen.dart';
import 'login_screen.dart';

final AuthService _authService = AuthService();

class AdminScreen extends StatelessWidget {
  const

    AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Màn hình Admin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text('Chào mừng bạn đến với trang Admin!'),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text("Đăng Xuất"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text("Đăng ký tài khoản"),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Home_Screen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ Phòng IT"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Home_Screen(),
                        ),
                      );
                    },
                    child: const Text("Tất cả nhiệm vụ"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Home_Screen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ Phần Cứng"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Home_Screen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ Phần Mềm"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),*/
    );
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Màn hình nhân viên'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text('Chào mình đến với màn hình IT!'),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text("Đăng Xuất"),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Home_Screen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ phòng IT"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Home_Screen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StatisticsScreen(),
                        ),
                      );
                    },
                    child: const Text("Team Task"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
