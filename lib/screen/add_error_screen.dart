import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_to_do_list/const/colors.dart';
import 'package:flutter_to_do_list/data/firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final GlobalKey<FlutterMentionsState> mentionKeyNew = GlobalKey<FlutterMentionsState>();
final GlobalKey<FlutterMentionsState> subtitleMentionKeyNew = GlobalKey<FlutterMentionsState>();

class AddNewErrorScreen extends StatefulWidget {
  const AddNewErrorScreen({super.key});

  @override
  State<AddNewErrorScreen> createState() => _AddNewErrorScreenState();
}

class _AddNewErrorScreenState extends State<AddNewErrorScreen> {
  List<Map<String, dynamic>> mentionUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsersFromFirestore();
  }

  Future<void> fetchUsersFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      mentionUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'display': data['name'] ?? 'No Name',
        };
      }).toList();
    });
  }

  void _handleAddTaskWithNotification() async {
    final titleMarkup = mentionKeyNew.currentState?.controller?.markupText ?? '';
    final subtitleMarkup = subtitleMentionKeyNew.currentState?.controller?.markupText ?? '';

    /*await Firestore_Datasource().AddError_ForDoctor(
      subtitleMarkup,
      titleMarkup,
      "name",
      "address",
    );*/

    final mentionedUserIds = [
      ...extractMentionedUserIds(titleMarkup),
      ...extractMentionedUserIds(subtitleMarkup),
    ].toSet().toList();

    if (mentionedUserIds.isNotEmpty) {
      await sendMentionNotification(
        mentionedUserIds,
        'Bạn được nhắc đến trong một task mới!',
      );
    }

    Navigator.pop(context);
  }

  List<String> extractMentionedUserIds(String markupText) {
    final regex = RegExp(r'@\[\_\_(.*?)\_\_\]\(\_\_.*?\_\_\)');
    return regex.allMatches(markupText).map((m) => m.group(1)!).toList();
  }

  Future<void> sendMentionNotification(List<String> userIds, String message) async {
    const serverKey = 'AAAA...YOUR_SERVER_KEY_HERE...'; // 🔐 Replace with your FCM Server Key

    for (final userId in userIds) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final fcmToken = doc.data()?['fcmToken'];

      if (fcmToken != null) {
        final body = {
          'to': fcmToken,
          'notification': {
            'title': 'Mention Alert',
            'body': message,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
          }
        };

        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: json.encode(body),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text("Thêm lỗi mới", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tiêu đề", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildMentionInput(
                key: mentionKeyNew,
                hintText: 'Nhập tiêu đề lỗi...',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text("Mô tả", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildMentionInput(
                key: subtitleMentionKeyNew,
                hintText: 'Nhập mô tả chi tiết...',
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      onPressed: _handleAddTaskWithNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: custom_green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: const Text("Báo lỗi", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: const Text("Hủy", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMentionInput({
    required GlobalKey<FlutterMentionsState> key,
    required String hintText,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: FlutterMentions(
        key: key,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: hintText,
          border: InputBorder.none,
        ),
        maxLines: maxLines,
        minLines: 1,
        mentions: [
          Mention(
            trigger: "@",
            style: const TextStyle(color: Colors.blue),
            data: mentionUsers,
            suggestionBuilder: (data) => ListTile(title: Text(data['display'])),
          ),
        ],
      ),
    );
  }
}
