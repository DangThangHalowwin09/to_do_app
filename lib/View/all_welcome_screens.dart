import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/signup_screen.dart';
import 'package:flutter_to_do_list/View/task_screen.dart';
import 'package:flutter_to_do_list/View/update_profile_screen.dart';
import '../Service/auth_service.dart';
import '../screen/blog_screen.dart';
import '../screen/statistics_screen.dart';
import 'area_manager_screen.dart';
import 'error_screen.dart';
import 'group_manager_screen.dart';
import 'login_screen.dart';
import 'member_manager_screen.dart';
import 'coming_soon_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'onduty_screen.dart';


final AuthService _authService = AuthService();

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Màn hình Admin'),
        backgroundColor: const Color(0xFF3A4C7A),
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
                  'ADMIN',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Chào mừng bạn đến với trang Admin!',
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
                  icon: Icons.logout,
                  label: 'Đăng Xuất',
                  iconColor: Colors.red,
                  onTap: () {
                    _authService.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.person_add,
                  label: 'Đăng ký',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.task,
                  label: 'Giao việc',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TaskScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.error,
                  label: 'Báo lỗi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ErrorScreen()),
                    );
                  },
                ),
                /*_buildGridItem(
                  icon: Icons.computer,
                  label: 'NV P.Cứng',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ErrorScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.code,
                  label: 'NV P.Mềm',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ErrorScreen()),
                    );
                  },
                ),*/
                _buildGridItem(
                  icon: FontAwesomeIcons.userGear,
                  label: 'NV IT',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MembersITScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: FontAwesomeIcons.userDoctor, // ✅ thêm `icon:`
                  label: 'Bác sỹ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MembersDoctorScreen()),
                    );
                  },
                ),

                _buildGridItem(
                  icon: Icons.local_hospital,
                  label: 'Các khoa',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AreaManagerScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.domain,
                  label: 'Khu vực',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GroupManagementScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.calendar_today,
                  label: 'Lịch trực',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DutyScreen()),
                    );
                  },
                ),
                /*_buildGridItem(
                  icon: Icons.bar_chart,
                  label: 'Thống kê',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ComingSoonScreen()),
                      //MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                    );
                  },
                ),*/
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

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Màn hình nhân viên'),
        backgroundColor: const Color(0xFF3A4C7A),
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
                  'NHÂN VIÊN',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Chào mừng đến với màn hình IT!',
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
                  icon: Icons.logout,
                  label: 'Đăng Xuất',
                  iconColor: Colors.red,
                  onTap: () {
                    _authService.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.task,
                  label: 'Nhiệm vụ phòng IT',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TaskScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.error,
                  label: 'Nhiệm vụ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ErrorScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.group,
                  label: 'Team Task',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
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

class HardwareScreen extends StatelessWidget {
  const HardwareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Màn hình nhân viên phần cứng'),
        backgroundColor: const Color(0xFF3A4C7A),
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
                  'NHÂN VIÊN PHẦN CỨNG',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Chào mừng đến với màn hình nhân viên phần cứng!',
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
                  icon: Icons.task,
                  label: 'Nhiệm vụ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TaskScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.error,
                  label: 'Báo lỗi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ErrorScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.build,
                  label: 'Mẹo PC',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BlogScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.person,
                  label: 'Tài khoản',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.calendar_today,
                  label: 'Lịch trực',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DutyScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.logout,
                  label: 'Đăng Xuất',
                  iconColor: Colors.red,
                  onTap: () {
                    _authService.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
       /*         _buildGridItem(
                  icon: Icons.calendar_today,
                  label: 'Lịch trực',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ComingSoonScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.inventory_2,
                  label: 'Kho',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
                    );
                  },
                ),*/
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

class SoftwareScreen extends StatelessWidget {
  const SoftwareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Báo lỗi phần mềm'),
        backgroundColor: const Color(0xFF3A4C7A),
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
                  'NHÂN VIÊN PHẦN MỀM',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Chào mừng đến với màn hình nhân viên phần mềm!',
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
                  icon: Icons.task,
                  label: 'Việc phòng IT',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TaskScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.error,
                  label: 'Báo lỗi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ErrorScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.code,
                  label: 'Mẹo PM',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BlogScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.person,
                  label: 'Tài Khoản',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
                    );
                  },
                ),
                _buildGridItem(
                  icon: Icons.calendar_today,
                  label: 'Lịch trực',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DutyScreen()),
                    );
                  },
                ),

                _buildGridItem(
                  icon: Icons.logout,
                  label: 'Đăng Xuất',
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

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Y Bác Sỹ'),
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
                  'USERNAME_HERE',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Chào mừng đến với màn hình Y Bác Sỹ!',
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
                  label: 'Tài Khoản',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
                  ),
                ),
                _buildGridItem(
                  icon: Icons.inventory_2,
                  label: 'Kho',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ComingSoonScreen()),
                  ),
                ),  _buildGridItem(
                  icon: Icons.access_time,
                  label: 'Trực IT',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DutyScreen()),
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