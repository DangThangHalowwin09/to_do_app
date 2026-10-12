import 'package:cloud_firestore/cloud_firestore.dart';

class ItStaff {
  const ItStaff({required this.name, required this.phone});

  final String name;
  final String phone;
}

class StaffRepository {
  StaffRepository._();

  static final _db = FirebaseFirestore.instance;
  static const _whereInLimit = 10;

  /// Nhân viên IT phụ trách các khoa trong [areaNames]:
  /// khoa → khu vực (`areas.groupId`) → nhân viên có khu vực đó trong `users.groups`.
  static Future<List<ItStaff>> forAreas(List<String> areaNames) async {
    if (areaNames.isEmpty) return [];

    final groupIds = <String>{};
    for (final chunk in _chunks(areaNames)) {
      final areas = await _db.collection('areas').where('name', whereIn: chunk).get();
      for (final doc in areas.docs) {
        final groupId = doc.data()['groupId'] as String?;
        if (groupId != null) groupIds.add(groupId);
      }
    }
    if (groupIds.isEmpty) return [];

    final groupNames = <String>{};
    for (final chunk in _chunks(groupIds.toList())) {
      final groups = await _db.collection('groups').where(FieldPath.documentId, whereIn: chunk).get();
      for (final doc in groups.docs) {
        final name = doc.data()['name'] as String?;
        if (name != null) groupNames.add(name);
      }
    }
    if (groupNames.isEmpty) return [];

    final staffByUid = <String, ItStaff>{};
    for (final chunk in _chunks(groupNames.toList())) {
      final users = await _db.collection('users').where('groups', arrayContainsAny: chunk).get();
      for (final doc in users.docs) {
        staffByUid[doc.id] = ItStaff(
          name: (doc.data()['name'] ?? '') as String,
          phone: (doc.data()['phone'] ?? '') as String,
        );
      }
    }
    return staffByUid.values.toList();
  }

  static Iterable<List<String>> _chunks(List<String> items) sync* {
    for (var i = 0; i < items.length; i += _whereInLimit) {
      final end = i + _whereInLimit < items.length ? i + _whereInLimit : items.length;
      yield items.sublist(i, end);
    }
  }
}
