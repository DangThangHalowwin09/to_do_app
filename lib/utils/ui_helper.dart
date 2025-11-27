
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'helper.dart';

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
              imageUrl: General_Helper.convertDriveLinkToDirect(data['imageUrl']),
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

class WebViewScreen extends StatefulWidget {
  final String url; // nhận URL từ bên ngoài

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url)); // dùng URL truyền vào
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UBNA Manager'),
        centerTitle: true, // căn giữa
        backgroundColor: Colors.blue, // màu appbar
      ),
      backgroundColor: Colors.blue,
      body: Container(
        //color: Colors.blue, // nền ngoài webview
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
