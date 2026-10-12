import 'package:cloud_firestore/cloud_firestore.dart';

/// Phiếu báo lỗi CNTT (collection `errors`).
class ErrorReportRepository {
  ErrorReportRepository._();

  static final _errors = FirebaseFirestore.instance.collection('errors');

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchAll() =>
      _errors.orderBy('timeErrorStart', descending: true).snapshots();

  static Future<void> create({
    required String title,
    required String detail,
    required String errorType,
    required String location,
    required String note,
    required String reporterUid,
    required String reporterName,
    required String reporterPhone,
  }) {
    return _errors.add({
      'errorTitle': title,
      'clarifyTitle': detail,
      'errorType': errorType,
      'address': location,
      'note': note,
      'reporterUid': reporterUid,
      'nameDoctor': reporterName,
      'phoneContact': reporterPhone,
      'timeErrorStart': FieldValue.serverTimestamp(),
      'isTakeOver': false,
      'timeTakeOver': null,
      'nameStaff': '',
      'isDone': false,
      'timeDone': null,
    });
  }

  static Future<void> takeOver(String id, String staffName) => _errors.doc(id).update({
        'isTakeOver': true,
        'timeTakeOver': FieldValue.serverTimestamp(),
        'nameStaff': staffName,
      });

  static Future<void> markDone(String id) => _errors.doc(id).update({
        'isDone': true,
        'timeDone': FieldValue.serverTimestamp(),
      });
}
