import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/signup_screen.dart';
import 'package:flutter_to_do_list/View/task_screen.dart';
import 'package:flutter_to_do_list/View/update_profile_screen.dart';
import '../Service/auth_service.dart';
import '../screen/blog_screen.dart';
import '../screen/statistics_screen.dart';
import 'all_errors_screen.dart';
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
                      //_authService.signOut();
                      Navigator.push(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TaskScreen(),

                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ phòng IT"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),

                        ),
                      );
                    },
                    child: const Text("Tất cả các lỗi"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ Phần Cứng"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ Phần Mềm"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
                        ),
                      );
                    },
                    child: const Text("Các bảng thống kê"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
                        ),
                      );
                    },
                    child: const Text("Quản lý thông tin nhân viên"),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TaskScreen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ phòng IT"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
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


class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Màn hình báo lỗi cho y bác sỹ'),
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
                  const Text('Chào mình đến với màn hình báo lỗi cho y bác sỹ!'),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
                        ),
                      );
                    },
                    child: const Text("Báo lỗi cho IT"),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BlogScreen(),
                        ),
                      );
                    },
                    child: const Text("Mẹo sửa lỗi Phần Cứng"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BlogScreen(),
                        ),
                      );
                    },
                    child: const Text("Mẹo sửa lỗi Phần Mềm"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
                        ),
                      );
                    },
                    child: const Text("Tất cả nhân viên IT"),
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

class HardwareScreen extends StatelessWidget {
  const HardwareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Màn hình báo lỗi cho y bác sỹ'),
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
                  const Text('Chào mừng đến với màn hình nhân viên phần cứng!'),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TaskScreen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ phòng IT"),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
                        ),
                      );
                    },
                    child: const Text("Lỗi các phòng ban"),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BlogScreen(),
                        ),
                      );
                    },
                    child: const Text("Mẹo sửa lỗi Phần Cứng"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UpdateProfileScreen(),
                        ),
                      );
                    },
                    child: const Text("Chỉnh sửa thông tin cá nhân"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UpdateProfileScreen(),
                        ),
                      );
                    },
                    child: const Text("Lịch trực phòng IT"),
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

class SoftwareScreen extends StatelessWidget {
  const SoftwareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Báo lỗi phần mềm'),
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
                  const Text('Chào mừng đến với màn hình nhân viên phần mềm!'),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TaskScreen(),
                        ),
                      );
                    },
                    child: const Text("Nhiệm vụ phòng IT"),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Error_Screen(),
                        ),
                      );
                    },
                    child: const Text("Báo lỗi phần mềm"),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BlogScreen(),
                        ),
                      );
                    },
                    child: const Text("Mẹo sửa lỗi Phần Mềm"),
                  ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  //_authService.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpdateProfileScreen(),
                    ),
                  );
                },
                child: const Text("Chỉnh sửa thông tin cá nhân"),
              ),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      //_authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UpdateProfileScreen(),
                        ),
                      );
                    },
                    child: const Text("Lịch trực phòng IT"),
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