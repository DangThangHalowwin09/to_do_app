import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/notes_model.dart';
import 'package:uuid/uuid.dart';

class Firestore_Datasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> CreateUser(String email) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({"id": _auth.currentUser!.uid, "email": email});
      return true;
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future<bool> AddNote(String subtitle, String title, int image) async {
    try {
      var uuid = Uuid().v4();
      DateTime data = new DateTime.now();
      await _firestore
          //.collection('users')
          //.doc(_auth.currentUser!.uid)
          //.collection('notes')
          .collection('tasks')
          .doc(uuid)
          .set({
        'id': uuid,
        'subtitle': subtitle,
        'isDon': false,
        'image': image,
        'time': '${data.hour}:${data.minute}',
        'title': title,
      });
      return true;
    } catch (e) {
      print(e);
      return true;
    }
  }

  List getNotes(AsyncSnapshot snapshot) {
    try {
      final notesList = snapshot.data!.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Note(
          data['id'],
          data['subtitle'],
          data['time'],
          data['image'],
          data['title'],
          data['isDon'],
        );
      }).toList();
      return notesList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Stream<QuerySnapshot> stream(bool isDone) {
    return _firestore
        //.collection('users')
        //.doc(_auth.currentUser!.uid)
        //.collection('notes')
        .collection('tasks')
        .where('isDon', isEqualTo: isDone)
        .snapshots();
  }

  Future<bool> isdone(String uuid, bool isDon) async {
    try {
      await _firestore
          //.collection('users')
          //.doc(_auth.currentUser!.uid)
          //.collection('notes')
          .collection('tasks')
          .doc(uuid)
          .update({'isDon': isDon});
      return true;
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future<bool> Update_Note(
      String uuid, int image, String title, String subtitle) async {
    try {
      DateTime data = new DateTime.now();
      await _firestore
          //.collection('users')
          //.doc(_auth.currentUser!.uid)
          //.collection('notes')
          .collection('tasks')
          .doc(uuid)
          .update({
        'time': '${data.hour}:${data.minute}',
        'subtitle': subtitle,
        'title': title,
        'image': image,
      });
      return true;
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future<bool> delet_note(String uuid) async {
    try {
      await _firestore
          //.collection('users')
          //.doc(_auth.currentUser!.uid)
          //.collection('notes')
          .collection('tasks')
          .doc(uuid)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return true;
    }
  }
  // Thêm task vào collection dùng chung
  Future<bool> addGlobalTask(String subtitle, String title, int image) async {
    try {
      var uuid = Uuid().v4();
      DateTime now = DateTime.now();
      await _firestore.collection('tasks').doc(uuid).set({
        'id': uuid,
        'subtitle': subtitle,
        'isDon': false,
        'image': image,
        'time': '${now.hour}:${now.minute}',
        'title': title,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

// Lấy stream danh sách nhiệm vụ chung
  Stream<QuerySnapshot> globalTasksStream() {
    return _firestore.collection('tasks').snapshots();
  }

// Đánh dấu hoàn thành nhiệm vụ chung
  Future<bool> updateGlobalTaskStatus(String id, bool isDone) async {
    try {
      await _firestore.collection('tasks').doc(id).update({
        'isDon': isDone,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

// Xoá task dùng chung
  Future<bool> deleteGlobalTask(String id) async {
    try {
      await _firestore.collection('tasks').doc(id).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

}
