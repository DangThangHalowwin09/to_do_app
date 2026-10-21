import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/user_role.dart';
import '../models/staff_rating.dart';
import '../services/user_session.dart';

class ItStaffEntry {
  const ItStaffEntry({required this.uid, required this.name, required this.role, required this.summary});

  final String uid;
  final String name;
  final String role;
  final RatingSummary summary;
}

/// Đánh giá nhân viên IT. Điểm trung bình được Cloud Function `onStaffRatingWritten` cập nhật.
class RatingRepository {
  RatingRepository._();

  static final _db = FirebaseFirestore.instance;
  static final _ratings = _db.collection('staffRatings');

  static Map<String, dynamic> _rater() {
    final s = UserSession.instance;
    return {'raterUid': s.uid, 'raterName': s.name, 'raterRole': s.roleLabel};
  }

  /// Đánh giá sau khi phiếu lỗi được xử lý xong. Ghi kèm điểm vào phiếu để hiển thị nhanh.
  static Future<void> rateError({
    required String errorId,
    required String errorTitle,
    required String staffUid,
    required String staffName,
    required int stars,
    required String comment,
  }) async {
    final batch = _db.batch()
      ..set(_ratings.doc(StaffRating.errorDocId(errorId)), {
        ..._rater(),
        'kind': StaffRating.kindError,
        'staffUid': staffUid,
        'staffName': staffName,
        'errorId': errorId,
        'errorTitle': errorTitle,
        'stars': stars,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..update(_db.collection('errors').doc(errorId), {
        'rating': stars,
        'ratingComment': comment,
        'ratedAt': FieldValue.serverTimestamp(),
      });
    await batch.commit();
  }

  /// Đánh giá chung (tạo mới hoặc sửa lượt đánh giá của chính mình).
  static Future<void> saveGeneralReview({
    required String staffUid,
    required String staffName,
    required int stars,
    required String comment,
  }) {
    final uid = UserSession.instance.uid!;
    return _ratings.doc(StaffRating.generalDocId(uid, staffUid)).set({
      ..._rater(),
      'kind': StaffRating.kindGeneral,
      'staffUid': staffUid,
      'staffName': staffName,
      'stars': stars,
      'comment': comment,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<StaffRating?> myGeneralReview(String staffUid) async {
    final uid = UserSession.instance.uid;
    if (uid == null) return null;
    final doc = await _ratings.doc(StaffRating.generalDocId(uid, staffUid)).get();
    return doc.exists ? StaffRating.fromDoc(doc) : null;
  }

  /// Các lượt đánh giá gần nhất của một nhân viên.
  static Stream<List<StaffRating>> watchForStaff(String staffUid, {int limit = 50}) => _ratings
      .where('staffUid', isEqualTo: staffUid)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(StaffRating.fromDoc).toList());

  /// Danh sách nhân viên IT kèm điểm trung bình.
  static Stream<List<ItStaffEntry>> watchItStaff() => _db
      .collection('users')
      .where('role', whereIn: UserRole.itLabels)
      .snapshots()
      .map((s) => s.docs
          .map((d) => ItStaffEntry(
                uid: d.id,
                name: (d.data()['name'] ?? 'Không tên') as String,
                role: (d.data()['role'] ?? '') as String,
                summary: RatingSummary.fromUser(d.data()),
              ))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name)));
}
