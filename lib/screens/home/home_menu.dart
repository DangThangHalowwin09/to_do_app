import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/user_role.dart';
import '../area_manager_screen.dart';
import '../auth/change_password_screen.dart';
import '../auth/create_account_screen.dart';
import '../blog_screen.dart';
import '../check_bhxh_screen.dart';
import '../errors/error_screen.dart';
import '../group_manager_screen.dart';
import '../member_manager_screen.dart';
import '../news_manager_screen.dart';
import '../on_duty_screen.dart';
import '../search_area_screen.dart';
import '../statistics_screen.dart';
import '../tasks/task_screen.dart';
import '../update_profile_screen.dart';

/// Một ô chức năng trên màn hình chính.
class HomeMenuItem {
  const HomeMenuItem(this.icon, this.label, this.screen, {this.urgent = false});

  final IconData icon;
  final String label;
  final Widget Function() screen;

  /// Chức năng cần nổi bật (ví dụ báo lỗi) → dùng màu đỏ thương hiệu.
  final bool urgent;
}

/// Nội dung màn hình chính của từng vai trò. Thêm/bớt chức năng chỉ cần sửa ở đây.
class HomeMenu {
  const HomeMenu({
    required this.title,
    required this.welcome,
    required this.items,
    this.greeting,
  });

  final String title;
  final String welcome;

  /// Dòng chào cố định; mặc định là "Xin chào: (tên người dùng)".
  final String? greeting;
  final List<HomeMenuItem> items;

  static const _changePassword = HomeMenuItem(
    Icons.lock_reset,
    'Đổi mật khẩu',
    ChangePasswordScreen.new,
  );
  static const _duty = HomeMenuItem(Icons.calendar_today, 'Lịch trực', DutyScreen.new);
  static const _checkBhxh = HomeMenuItem(
    Icons.health_and_safety_rounded,
    'Check BHXH',
    CheckBHXHScreen.new,
  );

  static HomeMenu of(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const HomeMenu(
          title: 'Màn hình Admin',
          greeting: 'ADMIN',
          welcome: 'Chào mừng bạn đến với trang Admin!',
          items: [
            HomeMenuItem(Icons.person_add, 'Đăng ký', CreateAccountScreen.new),
            HomeMenuItem(Icons.task, 'Giao việc', TaskScreen.new),
            HomeMenuItem(Icons.report_problem_rounded, 'Báo lỗi', ErrorScreen.new, urgent: true),
            HomeMenuItem(FontAwesomeIcons.userGear, 'NV IT', MembersITScreen.new),
            HomeMenuItem(FontAwesomeIcons.userDoctor, 'Bác sỹ', MembersDoctorScreen.new),
            HomeMenuItem(Icons.local_hospital, 'Các khoa', AreaManagerScreen.new),
            HomeMenuItem(Icons.domain, 'Khu vực', GroupManagementScreen.new),
            _duty,
            _checkBhxh,
            HomeMenuItem(Icons.newspaper, 'Tin tức', NewsAdminScreen.new),
            HomeMenuItem(Icons.bar_chart, 'Thống kê', StatisticScreen.new),
            _changePassword,
          ],
        );
      case UserRole.user:
        return const HomeMenu(
          title: 'Màn hình nhân viên',
          welcome: 'Chào mừng đến với màn hình nhân viên!',
          items: [
            HomeMenuItem(Icons.task, 'Nhiệm vụ phòng IT', TaskScreen.new),
            HomeMenuItem(Icons.report_problem_rounded, 'Nhiệm vụ', ErrorScreen.new, urgent: true),
            _changePassword,
          ],
        );
      case UserRole.hardTeam:
        return const HomeMenu(
          title: 'Màn hình nhân viên phần cứng',
          welcome: 'Chào mừng đến với màn hình nhân viên phần cứng!',
          items: [
            HomeMenuItem(Icons.task, 'Nhiệm vụ', TaskScreen.new),
            HomeMenuItem(Icons.report_problem_rounded, 'Báo lỗi', ErrorScreen.new, urgent: true),
            HomeMenuItem(Icons.build, 'Mẹo PC', BlogScreen.new),
            HomeMenuItem(Icons.person, 'Tài khoản', UpdateProfileScreen.new),
            _duty,
            _changePassword,
          ],
        );
      case UserRole.softTeam:
        return const HomeMenu(
          title: 'Báo lỗi phần mềm',
          welcome: 'Chào mừng đến với màn hình nhân viên phần mềm!',
          items: [
            HomeMenuItem(Icons.task, 'Việc phòng IT', TaskScreen.new),
            HomeMenuItem(Icons.report_problem_rounded, 'Báo lỗi', ErrorScreen.new, urgent: true),
            HomeMenuItem(Icons.code, 'Mẹo PM', BlogScreen.new),
            HomeMenuItem(Icons.person, 'Tài khoản', UpdateProfileScreen.new),
            _duty,
            _checkBhxh,
            _changePassword,
          ],
        );
      case UserRole.doctor:
        return const HomeMenu(
          title: 'Y Bác Sỹ',
          welcome: 'Các chức năng màn hình Y Bác Sỹ!',
          items: [
            HomeMenuItem(Icons.search, 'NVPT', SearchAreaScreen.new),
            _checkBhxh,
            _changePassword,
          ],
        );
    }
  }
}
