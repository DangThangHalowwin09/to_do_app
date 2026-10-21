import 'package:cloud_firestore/cloud_firestore.dart';

/// Mức độ ưu tiên của phiếu báo hỏng (giá trị lưu ở `errors.priority`).
class ErrorPriority {
  ErrorPriority._();

  static const normal = 'normal';

  /// Ảnh hưởng trực tiếp tới người bệnh (phòng mổ, cấp cứu, hồi sức...):
  /// thông báo ghi "KHẨN", báo khẩn cho toàn bộ IT nếu sau 5 phút chưa ai nhận.
  static const urgent = 'urgent';
}

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
    String priority = ErrorPriority.normal,
    List<String> imageUrls = const [],
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
      'priority': priority,
      'imageUrls': imageUrls,
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
