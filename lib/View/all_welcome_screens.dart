import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/signup_screen.dart';
import 'package:flutter_to_do_list/View/task_screen.dart';
import 'package:flutter_to_do_list/View/update_profile_screen.dart';
import '../Service/auth_service.dart';
import '../screen/blog_screen.dart';
import '../screen/statistics_screen.dart';
import 'error_screen.dart';
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
                          builder: (_) => const ErrorScreen(),

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
                          builder: (_) => const ErrorScreen(),
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
                          builder: (_) => const ErrorScreen(),
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
                          builder: (_) => const ErrorScreen(),
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
                          builder: (_) => const ErrorScreen(),
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
                          builder: (_) => const ErrorScreen(),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dành cho Y Bác Sỹ'),
        backgroundColor: const Color(0xFF3A4C7A), // màu giống trong hình
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF3A4C7A),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ĐẶNG QUANG THẮNG',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Chào mừng đến với màn hình báo lỗi!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildGridItem(
                  icon: Icons.report_problem,
                  label: 'Báo lỗi',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ErrorScreen()),
                  ),
                ),
                _buildGridItem(
                  icon: Icons.build,
                  label: 'Mẹo PC',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlogScreen()),
                  ),
                ),
                _buildGridItem(
                  icon: Icons.memory,
                  label: 'Mẹo PM',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlogScreen()),
                  ),
                ),
                _buildGridItem(
                  icon: Icons.people,
                  label: 'Nhân viên',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ErrorScreen()),
                  ),
                ),
                _buildGridItem(
                  icon: Icons.logout,
                  label: 'Đăng xuất',
                  iconColor: Colors.red,
                  onTap: () {
                    _authService.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.blue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Thay bằng service bạn thực tế đang dùng
//final _authService = AuthService();


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
                          builder: (_) => const ErrorScreen(),
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
                          builder: (_) => const ErrorScreen(),
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