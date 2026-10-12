import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../core/utils/contact_launcher.dart';

/// Băng-rôn quảng bá tự động chuyển; bấm vào để mở liên kết tương ứng.
class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  static const _items = [
    (image: 'assets/newsite.jpg', link: 'https://www.facebook.com/share/p/17XqgweM3k/'),
    (image: 'assets/astrazenka.jpg', link: 'https://www.facebook.com/share/p/1KGbHZuwZm/'),
    (image: 'assets/cntt.jpg', link: 'http://tailieu.ubna.local:81/'),
    (image: 'assets/facebook_nen.jpg', link: 'https://www.facebook.com/Benhvienungbuounghean'),
    (
      image: 'assets/tiktok_nen.jpg',
      link: 'https://www.tiktok.com/@benhvienungbuounghean.vn?is_from_webapp=1&sender_device=pc',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          enlargeCenterPage: true,
          viewportFraction: 0.9,
        ),
        items: [
          for (final item in _items)
            GestureDetector(
              onTap: () => ContactLauncher.url(item.link),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(item.image, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
        ],
      ),
    );
  }
}
