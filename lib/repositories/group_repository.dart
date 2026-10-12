import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/app_logger.dart';

/// Truy vấn collection `groups` (khu vực) và `areas` (các khoa thuộc khu vực).
class GroupRepository {
  GroupRepository._();

  static final _db = FirebaseFirestore.instance;

  /// Firestore giới hạn `whereIn` tối đa 10 phần tử.
  static const _whereInLimit = 10;

  static Future<String?> nameById(String id) async {
    final doc = await _db.collection('groups').doc(id).get();
    return doc.data()?['name'] as String?;
  }

  static Future<String?> idByName(String name) async {
    final snapshot = await _db
        .collection('groups')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty ? null : snapshot.docs.first.id;
  }

  /// Tên các khoa thuộc những khu vực có tên trong [groupNames].
  static Future<List<String>> areaNamesOfGroups(List<String> groupNames) async {
    if (groupNames.isEmpty) return [];
    try {
      final groupIds = <String>[];
      for (final chunk in _chunks(groupNames)) {
        final groups = await _db.collection('groups').where('name', whereIn: chunk).get();
        groupIds.addAll(groups.docs.map((d) => d.id));
      }

      final areaNames = <String>[];
      for (final chunk in _chunks(groupIds)) {
        final areas = await _db.collection('areas').where('groupId', whereIn: chunk).get();
        for (final doc in areas.docs) {
          final name = doc.data()['name'] as String? ?? '';
          if (name.isNotEmpty) areaNames.add(name);
        }
      }
      return areaNames;
    } catch (e) {
      AppLog.e('Lỗi khi lấy danh sách khu vực', e);
      return [];
    }
  }

  static Iterable<List<String>> _chunks(List<String> items) sync* {
    for (var i = 0; i < items.length; i += _whereInLimit) {
      final end = i + _whereInLimit < items.length ? i + _whereInLimit : items.length;
      yield items.sublist(i, end);
    }
  }
}
