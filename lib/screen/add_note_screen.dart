import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_to_do_list/const/colors.dart';
import 'package:flutter_to_do_list/data/firestor.dart';

final GlobalKey<FlutterMentionsState> mentionKeyNew = GlobalKey<FlutterMentionsState>();
final GlobalKey<FlutterMentionsState> subtitleMentionKeyNew = GlobalKey<FlutterMentionsState>();

class AddTaskScreenNew extends StatefulWidget {
  const AddTaskScreenNew({super.key});

  @override
  State<AddTaskScreenNew> createState() => _AddTaskScreenNewState();
}

class _AddTaskScreenNewState extends State<AddTaskScreenNew> {
  List<Map<String, dynamic>> mentionUsers = [];
  int selectedImageIndex = 0;

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

  void _handleAddTask() {
    final title = mentionKeyNew.currentState?.controller?.markupText ?? '';
    final subtitle = subtitleMentionKeyNew.currentState?.controller?.markupText ?? '';

    Firestore_Datasource().AddNote(subtitle, title, selectedImageIndex);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColors,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text("Add New Task", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMentionInput(
              key: mentionKeyNew,
              hintText: 'Enter title',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildMentionInput(
              key: subtitleMentionKeyNew,
              hintText: 'Enter subtitle',
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            _buildImageSelector(width),
            const SizedBox(height: 20),
            _buildActionButtons()
          ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
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

  Widget _buildImageSelector(double width) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => selectedImageIndex = index),
            child: Container(
              width: width * 0.35,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedImageIndex == index ? custom_green : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'images/$index.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            onPressed: _handleAddTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: custom_green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: const Text("Add Task", style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: const Text("Cancel", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
