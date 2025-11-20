import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/helper.dart';
import 'main_screen/login_screen.dart';
import 'main_screen/new_sign_up_screen.dart';
import 'member_manager_screen.dart';
import 'on_duty_screen.dart';

class General_Information_Screen extends StatelessWidget {
  const General_Information_Screen({super.key});

  void login(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    print("Đi tới trang Login");
  }

  void duty(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DutyScreen()));
    print("Đi tới trang Duty");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ===== HEADER =====
              Row(
                children: [
                  // Logo bệnh viện
                  Image.asset(
                    "assets/icon/app_icon.png", // bạn thay bằng logo của bạn
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 25),

                  Column(
                      children:[
                        const SizedBox(height: 5),

                        const Text(
                          "UBNA Manager",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(height: 0),
                        const Text(
                          "Ứng dụng hỗ trợ nhân viên UBNA",
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFD01F26),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ]
                  )
                ],
              ),

              const SizedBox(height: 10),
              AutoImageSlider(),
              const SizedBox(height: 10),
              // ===== MỤC CHỨC NĂNG =====
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Chức năng",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _functionButton(
                      icon: Icons.login,
                      label: "Đăng nhập",
                      onTap: () => login(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _functionButton(
                      icon: FontAwesomeIcons.userGear,
                      label: 'Đăng ký',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupEmailScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _functionButton(
                      icon: Icons.calendar_today,
                      label: "Lịch trực",
                      onTap: () => duty(context),
                    ),
                  ),

                 /* const SizedBox(width: 12),
                  Expanded(
                    child: _functionButton(
                      icon: FontAwesomeIcons.userGear,
                      label: 'NV IT',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MembersITScreen())),
                    ),
                  ),
*/

                ],
              ),

              const SizedBox(height: 30),

              // ===== MỤC TIN TỨC =====
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tin tức",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const NewsListWidget(),

              /*Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Center(
                  child: Text(
                    "Danh sách bài viết sẽ hiển thị ở đây...",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),*/

            ],
          ),
        ),
      ),
    );
  }

  // Widget button chức năng
  Widget _functionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,               // Nền trắng
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,    // Viền xám nhạt
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,  // Đổ bóng màu ghi
              blurRadius: 6,
              offset: const Offset(0, 3),   // Đổ bóng nhẹ xuống dưới
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade500),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}

class AutoImageSlider extends StatelessWidget {
  AutoImageSlider({super.key});

  final List<Map<String, String>> bannerItems = [
    {
      "image": "assets/newsite.jpg",
      "link": "https://www.facebook.com/share/p/17XqgweM3k/"
    },
   {
      "image": "assets/astrazenka.jpg",
      "link": "https://www.facebook.com/share/p/1KGbHZuwZm/"
    },
    {
      "image": "assets/cntt.jpg",
      "link": "http://tailieu.ubna.local:81/"
    },
  ];

  Future<void> _openLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Dùng thẳng launchUrl với LaunchMode.externalApplication
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Không thể mở liên kết: $url');
      }
    } catch (e) {
      print('Lỗi khi mở liên kết: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          enableInfiniteScroll: true,
        ),
        items: bannerItems.map((item) {
          return GestureDetector(
            onTap: () => _openLink(item['link']!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item['image']!,       // ví dụ: assets/icon/app_icon.png
                fit: BoxFit.cover,
                width: double.infinity,
              ),

            ),
          );
        }).toList(),
      ),
    );
  }
}

class NewsListWidget extends StatelessWidget {
  const NewsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('news')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Chưa có bài viết nào"),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // không cuộn bên trong ScrollView cha
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data();

            return NewsContainer(
              title: data['title'],
              imageUrl: convertDriveLinkToDirect(data['imageUrl']),
              onTap: ()
              {
                launchUrl(Uri.parse(data['url']), mode: LaunchMode.externalApplication);
              },

            );
          },
        );
      },
    );
  }
}

String convertDriveLinkToDirect(String url) {
  try {
    // Trường hợp link dạng: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
    if (url.contains("drive.google.com/file/d/")) {
      final id = url.split("drive.google.com/file/d/")[1].split("/")[0];
      return "https://drive.google.com/uc?export=view&id=$id";
    }

    // Trường hợp link dạng: https://drive.google.com/open?id=FILE_ID
    if (url.contains("drive.google.com/open?id=")) {
      final id = url.split("drive.google.com/open?id=")[1];
      return "https://drive.google.com/uc?export=view&id=$id";
    }

    // Trường hợp link dạng: https://drive.google.com/uc?id=FILE_ID&export=download
    if (url.contains("drive.google.com/uc?id=")) {
      final id = url.split("drive.google.com/uc?id=")[1].split("&")[0];
      return "https://drive.google.com/uc?export=view&id=$id";
    }

    return url; // Không phải link Drive → trả lại bình thường
  } catch (e) {
    return url; // Khi lỗi vẫn trả lại link cũ
  }
}
