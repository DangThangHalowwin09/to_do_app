import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_to_do_list/utils/helper.dart';

class AnimatedContactButton {
  static void showContactBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- TITLE ---
              const Text(
                "Liên hệ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // --- LIST OPTIONS ---
             /* _contactItem(
                icon: Icons.phone_in_talk,
                color: Colors.red,
                title: "Cấp cứu",
                subtitle: "0901 793 122",
                onTap: () {},
              ),
*/
              _contactItem(
                icon: Icons.local_hospital,
                color: Colors.blue,
                title: "Phòng CNTT",
                subtitle: "0985386838",
                onTap: () {
                  ContactHelper.launchZalo("0985386838") ; },
              ),

              _contactItem(
                icon: Icons.call,
                color: Colors.blue,
                title: "Tổng đài",
                subtitle: "1900 068681",
                onTap: () { ContactHelper.makePhoneCall("1900068681");},
              ),

              _contactItem(
                icon: Icons.facebook,
                color: Colors.blue,
                title: "Facebook",
                subtitle: "",//,
                onTap: () => ContactHelper.launchFacebook("https://www.facebook.com/Benhvienungbuounghean"),
              ),

              _contactItem(
                icon: Icons.chat_bubble,
                color: Colors.blue,
                title: "Zalo",
                subtitle: "",//"https://zalo.me/4579373442512550836",
                onTap: () => ContactHelper.launchZalo("4579373442512550836"),
              ),

              _contactItem(
                icon: Icons.tiktok,
                color: Colors.blue,
                title: "Tiktok",
                subtitle: "",//"https://www.tiktok.com/@benhvienungbuounghean.vn",
                onTap: () => ContactHelper.launchApp("https://www.tiktok.com/@benhvienungbuounghean.vn"),
              ),

              _contactItem(
                icon: Icons.thumb_up,
                color: Colors.blue,
                title: "Hỗ trợ - Góp ý",
                subtitle: "",
                onTap: () {},
              ),

             /* _contactItem(
                icon: Icons.local_hospital,
                color: Colors.blueGrey,
                title: "Nhà phát triển",
                subtitle: "",//,"0866573502",
                onTap: () => ContactHelper.launchZalo("0866573502"),
              ),*/

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  static Widget _contactItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 12),

            // Text phần bên trái
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
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
