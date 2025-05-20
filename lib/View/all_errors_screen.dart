import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_to_do_list/View/login_screen.dart';
import 'package:flutter_to_do_list/const/colors.dart';
import 'package:flutter_to_do_list/screen/add_error_screen.dart';
import 'package:flutter_to_do_list/widgets/get_stream_error.dart';
import '../View/all_welcome_screens.dart';
import '../data/user_info_service.dart';

class Error_Screen extends StatefulWidget {
  const Error_Screen({super.key});

  @override
  State<Error_Screen> createState() => _Error_Screen();
}

bool show = true;

class _Error_Screen extends State<Error_Screen> {
  bool show = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      body: Stack(
        children: [
          // Nội dung chính
          SafeArea(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.forward) {
                  setState(() {
                    show = true;
                  });
                }
                if (notification.direction == ScrollDirection.reverse) {
                  setState(() {
                    show = false;
                  });
                }
                return true;
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Lỗi chưa xử lý',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Stream_global_note(false),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi đã xử lý',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  //Stream_personal_note(true),
                  Stream_global_note(true),
                  const SizedBox(height: 80), // Để tránh đè lên nút dưới
                ],
              ),
            ),
          ),

          // Hai nút ở hai bên dưới cùng
          if (show) ...[
            Positioned(
              bottom: 20,
              left: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: custom_green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  print(UserInfoService().role.toString() == "Y bác sỹ" + "22222222222");
                  if (UserInfoService().role == "Y bác sỹ") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddNewErrorScreen(),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Thông báo'),
                        content: Text('Chỉ cho phép y bác sỹ thêm lỗi.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Đóng hộp thoại
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text(
                  "Báo hỏng",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ));
                },
                child: const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center( // Canh giữa theo chiều ngang
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size.zero, // Không ép kích thước tối thiểu
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Thu nhỏ vùng chạm
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Trở về trang trước đó
                  },
                  child: const Text(
                    "Back",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

          ],
        ],
      ),
    );
  }
}