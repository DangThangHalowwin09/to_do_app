import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/utils/drive_link.dart';
import 'news_card.dart';
import 'web_view_screen.dart';

/// Danh sách tin tức mới nhất (collection `news`), tối đa [limit] bài.
class NewsList extends StatelessWidget {
  const NewsList({super.key, this.limit = 3});

  final int limit;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('news')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Không tải được tin tức, vui lòng thử lại sau'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Chưa có bài viết nào'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final url = (data['url'] ?? '') as String;
            return NewsCard(
              title: (data['title'] ?? '') as String,
              imageUrl: driveLinkToDirect((data['imageUrl'] ?? '') as String),
              onTap: () => _open(context, url),
            );
          },
        );
      },
    );
  }

  void _open(BuildContext context, String url) {
    if (url.isEmpty) return;
    if (kIsWeb) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => WebViewScreen(url: url)));
    }
  }
}
