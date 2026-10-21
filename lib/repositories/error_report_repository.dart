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

  /// Chỉ nhận được phiếu chưa ai nhận (dùng transaction để 2 người bấm cùng lúc không đè nhau).
  /// Ném [StateError] nếu phiếu đã có người nhận.
  static Future<void> takeOver(String id, {required String staffUid, required String staffName}) {
    final ref = _errors.doc(id);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.data()?['isTakeOver'] == true) {
        throw StateError('Phiếu đã có ${snap.data()?['nameStaff'] ?? 'người khác'} nhận xử lý');
      }
      tx.update(ref, {
        'isTakeOver': true,
        'timeTakeOver': FieldValue.serverTimestamp(),
        'nameStaff': staffName,
        'staffUid': staffUid,
      });
    });
  }

  static Future<void> markDone(String id) => _errors.doc(id).update({
        'isDone': true,
        'timeDone': FieldValue.serverTimestamp(),
      });
}
