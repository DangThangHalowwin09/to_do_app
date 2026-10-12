import 'package:cloud_firestore/cloud_firestore.dart';

class DutyPerson {
  const DutyPerson({required this.name, required this.phone});

  final String name;
  final String phone;
}

class DutyRepository {
  DutyRepository._();

  /// Danh sách người trực: `idDuty → người`. Chỉ lấy những nhân viên đã được gán `idDuty`.
  static Future<Map<int, DutyPerson>> loadRoster() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('idDuty', isGreaterThanOrEqualTo: 0)
        .get();

    final roster = <int, DutyPerson>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final id = (data['idDuty'] as num?)?.toInt();
      if (id == null || roster.containsKey(id)) continue;
      roster[id] = DutyPerson(
        name: (data['name'] ?? 'Không có tên') as String,
        phone: (data['phone'] ?? '').toString().trim(),
      );
    }
    return roster;
  }
}
