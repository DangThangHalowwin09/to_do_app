import 'package:flutter/material.dart';
//import 'package:lottie/lottie.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tính năng đang phát triển'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*Lottie.asset(
                'assets/coming_soon.json', // tải từ lottiefiles.com và đặt vào thư mục assets
                width: 250,
                repeat: true,
              ),*/
              const SizedBox(height: 20),
              const Text(
                'Chức năng này đang được hoàn thiện!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cảm ơn bạn đã sử dụng ứng dụng.\nHãy quay lại sau nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
