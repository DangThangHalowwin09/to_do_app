import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/contact_sheet.dart';
import '../widgets/news_list.dart';
import '../widgets/vibrating_fab.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'on_duty_screen.dart';
import 'onboarding/onboarding_screen.dart';

/// Màn hình chào dành cho người chưa đăng nhập.
class GeneralInformationScreen extends StatelessWidget {
  const GeneralInformationScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: AppSpacing.sm),
                  const BannerCarousel(),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Chức năng', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.sm + 4),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.login_rounded,
                          label: 'Đăng nhập',
                          primary: true,
                          onTap: () => _open(context, const LoginScreen()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Đăng ký',
                          onTap: () => _open(context, const SignupScreen()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.event_available_rounded,
                          label: 'Lịch trực',
                          onTap: () => _open(context, const DutyScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Tin tức', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.sm + 4),
                  const NewsList(),
                  const SizedBox(height: 96), // chừa chỗ cho nút liên hệ nổi
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: VibratingFab(onPressed: () => showContactSheet(context)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(
          child: Image.asset('assets/icon/app_icon.png', width: 52, height: 52, fit: BoxFit.contain),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UBNA Manager',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue),
              ),
              Text(
                'Bệnh viện Ung bướu Nghệ An',
                style: TextStyle(fontSize: 14, color: AppColors.tagline, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Giới thiệu ứng dụng',
          icon: const Icon(Icons.info_outline_rounded, color: AppColors.blue),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => OnboardingScreen(onFinished: () => Navigator.pop(ctx)),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap, this.primary = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final background = primary ? AppColors.blue : AppColors.surface;
    final foreground = primary ? Colors.white : AppColors.blue;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: primary ? AppColors.blue : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              children: [
                Icon(icon, size: 30, color: foreground),
                const SizedBox(height: AppSpacing.sm),
                Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: foreground)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
