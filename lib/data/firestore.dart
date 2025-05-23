import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/model.dart';
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
      print('${e}22222');
      return false;
    }
  }

  Future<bool> AddError_ForDoctor(
      String errorTitle,
      String clarifyTitle,
      String name,
      String address,
      Timestamp timeErrorStart) async {
    try {
      var uuid = Uuid().v4();
      await _firestore.collection('errors').doc(uuid).set({
        'id': uuid,
        'errorTitle': errorTitle,
        'clarifyTitle': clarifyTitle,
        'name': name,
        'address': address,
        'timeErrorStart': timeErrorStart,
        'isDone': false,
        'nameStaff': '',
        'isTakeOver': false,
        'timeTakeOver': null,
        'timeDone': null,
        'note': '',
      });
      return true;
    } catch (e) {
      print('❌ AddError Error: $e');
      return false;
    }
  }

  Future<bool> Update_TakeOverError_ForIT(
      String uuid, String nameStaff, bool isTakeOver) async {
    try {
      await _firestore.collection('errors').doc(uuid).update({
        'nameStaff': nameStaff,
        'isTakeOver': isTakeOver,
        'timeTakeOver': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('❌ Update_TakeOverError Error: $e');
      return false;
    }
  }

  Future<bool> AddError_Complete_ForIT(
      String uuid, bool isDone, Timestamp timeDone, String note) async {
    try {
      await _firestore.collection('errors').doc(uuid).update({
        'isDone': true,
        'timeDone': FieldValue.serverTimestamp(),
        'note': note,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  List<Error> getError(AsyncSnapshot snapshot) {
    try {
      final notesList = snapshot.data!.docs.map<Error>((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Error(
          doc.id,
          data['errorTitle'] ?? '',
          data['clarifyTitle'] ?? '',
          data['name'] ?? '',
          data['address'] ?? '',
          data['timeErrorStart'] as Timestamp? ?? Timestamp.now(),
          data['nameStaff'] ?? '',
          data['isTakeOver'] ?? false,
          data['timeTakeOver'] as Timestamp? ?? Timestamp.now(),
          data['isDone'] ?? false,
          data['timeDone'] as Timestamp? ?? Timestamp.now(),
          data['note'] ?? '',
        );
      }).toList();

      return notesList;
    } catch (e) {
      print('🔥 Lỗi khi convert Error: $e');
      return [];
    }
  }

  Stream<QuerySnapshot> stream_ErrorTakeOver(bool isTakeOver) {
    return _firestore
        .collection('errors')
        .where('isTakeOver', isEqualTo: isTakeOver)
        .snapshots();
  }

  Stream<QuerySnapshot> stream_ErrorDone(bool isDone) {
    return _firestore
        .collection('errors')
        .where('isDone', isEqualTo: isDone)
        .snapshots();
  }

  Future<bool> isDone_Error(String uuid, bool isDone) async {
    try {
      await _firestore
          .collection('errors')
          .doc(uuid)
          .update({'isDone': isDone});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> Update_Error_ForDoctor(
      String uuid,
      String errorTitle,
      String clarifyTitle,
      String name,
      String address,
      Timestamp timeErrorStart,
      ) async {
    try {
      final doc = await _firestore.collection('errors').doc(uuid).get();

      final currentData = doc.data()!;
      bool currentIsDone = currentData['isDone'] ?? false;
      String currentNameStaff = currentData['nameStaff'] ?? '';
      bool currentIsTakeOver = currentData['isTakeOver'] ?? false;
      Timestamp currentTimeTakeOver =
          currentData['timeTakeOver'] ?? Timestamp.now();
      Timestamp currentTimeDone =
          currentData['timeDone'] ?? Timestamp.now();
      String note = currentData['note'] ?? "";

      await _firestore.collection('errors').doc(uuid).update({
        'errorTitle': errorTitle,
        'clarifyTitle': clarifyTitle,
        'name': name,
        'address': address,
        'timeErrorStart': timeErrorStart,
        'isDone': currentIsDone,
        'nameStaff': currentNameStaff,
        'isTakeOver': currentIsTakeOver,
        'timeTakeOver': currentTimeTakeOver,
        'timeDone': currentTimeDone,
        'note': note,
      });

      return true;
    } catch (e) {
      print('❌ Error updating document: $e');
      return false;
    }
  }

  Future<bool> Update_CompleteError_ForIT(
      String uuid, bool isDone, String note) async {
    try {
      await _firestore.collection('errors').doc(uuid).update({
        'isDone': true,
        'timeDone': FieldValue.serverTimestamp(),
        'note': note,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> delete_Error(String uuid) async {
    try {
      await _firestore.collection('errors').doc(uuid).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
