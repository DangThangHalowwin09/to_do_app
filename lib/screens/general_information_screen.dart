import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants/app_colors.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/contact_sheet.dart';
import '../widgets/news_list.dart';
import '../widgets/vibrating_fab.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'on_duty_screen.dart';

/// Màn hình chào dành cho người chưa đăng nhập.
class GeneralInformationScreen extends StatelessWidget {
  const GeneralInformationScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 10),
              const BannerCarousel(),
              const SizedBox(height: 10),
              const _SectionTitle('Chức năng'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.login,
                      label: 'Đăng nhập',
                      onTap: () => _open(context, const LoginScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: FontAwesomeIcons.userPlus,
                      label: 'Đăng ký',
                      onTap: () => _open(context, const SignupScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.calendar_today,
                      label: 'Lịch trực',
                      onTap: () => _open(context, const DutyScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const _SectionTitle('Tin tức'),
              const SizedBox(height: 12),
              const NewsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: VibratingFab(onPressed: () => showContactSheet(context)),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/icon/app_icon.png', width: 50, height: 50, fit: BoxFit.contain),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UBNA Manager',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue),
              ),
              Text(
                'Ứng dụng hỗ trợ nhân viên UBNA',
                style: TextStyle(fontSize: 14, color: AppColors.tagline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade500),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
