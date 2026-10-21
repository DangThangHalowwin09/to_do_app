import 'package:cloud_firestore/cloud_firestore.dart';

/// Một lượt đánh giá nhân viên IT (collection `staffRatings`).
/// - [kind] = `error`: đánh giá sau khi xử lý một phiếu báo lỗi (mỗi phiếu tối đa 1 lượt).
/// - [kind] = `general`: đánh giá chung của một người về một nhân viên (mỗi người 1 lượt, sửa được).
class StaffRating {
  const StaffRating({
    required this.id,
    required this.kind,
    required this.staffUid,
    required this.staffName,
    required this.raterUid,
    required this.raterName,
    required this.stars,
    required this.comment,
    this.errorId,
    this.errorTitle,
    this.createdAt,
  });

  static const kindError = 'error';
  static const kindGeneral = 'general';

  final String id;
  final String kind;
  final String staffUid;
  final String staffName;
  final String raterUid;
  final String raterName;
  final int stars;
  final String comment;
  final String? errorId;
  final String? errorTitle;
  final DateTime? createdAt;

  /// Id cố định để mỗi phiếu / mỗi cặp người–nhân viên chỉ có một lượt đánh giá.
  static String errorDocId(String errorId) => 'error_$errorId';
  static String generalDocId(String raterUid, String staffUid) => 'general_${raterUid}_$staffUid';

  factory StaffRating.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return StaffRating(
      id: doc.id,
      kind: (d['kind'] ?? kindGeneral) as String,
      staffUid: (d['staffUid'] ?? '') as String,
      staffName: (d['staffName'] ?? '') as String,
      raterUid: (d['raterUid'] ?? '') as String,
      raterName: (d['raterName'] ?? '') as String,
      stars: (d['stars'] as num?)?.toInt() ?? 0,
      comment: (d['comment'] ?? '') as String,
      errorId: d['errorId'] as String?,
      errorTitle: d['errorTitle'] as String?,
      createdAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Điểm trung bình của một nhân viên, do Cloud Function cộng dồn vào `users/{uid}`.
class RatingSummary {
  const RatingSummary({required this.sum, required this.count});

  final int sum;
  final int count;

  double get average => count == 0 ? 0 : sum / count;

  factory RatingSummary.fromUser(Map<String, dynamic> user) => RatingSummary(
        sum: (user['ratingSum'] as num?)?.toInt() ?? 0,
        count: (user['ratingCount'] as num?)?.toInt() ?? 0,
      );
}
