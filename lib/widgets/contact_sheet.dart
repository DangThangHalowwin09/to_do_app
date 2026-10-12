import 'package:flutter/material.dart';

import '../core/utils/contact_launcher.dart';

/// Bottom sheet "Liên hệ" hiển thị các kênh hỗ trợ của bệnh viện.
void showContactSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Liên hệ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _ContactItem(
              icon: Icons.local_hospital,
              title: 'Phòng CNTT',
              subtitle: '0985386838',
              onTap: () => ContactLauncher.zalo('0985386838'),
            ),
            _ContactItem(
              icon: Icons.call,
              title: 'Tổng đài',
              subtitle: '1900 068681',
              onTap: () => ContactLauncher.call('1900068681'),
            ),
            _ContactItem(
              icon: Icons.facebook,
              title: 'Facebook',
              onTap: () => ContactLauncher.url('https://www.facebook.com/Benhvienungbuounghean'),
            ),
            _ContactItem(
              icon: Icons.chat_bubble,
              title: 'Zalo',
              onTap: () => ContactLauncher.zalo('4579373442512550836'),
            ),
            _ContactItem(
              icon: Icons.tiktok,
              title: 'Tiktok',
              onTap: () => ContactLauncher.url('https://www.tiktok.com/@benhvienungbuounghean.vn'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.withValues(alpha: 0.15),
              child: Icon(icon, color: Colors.blue, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle!, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
