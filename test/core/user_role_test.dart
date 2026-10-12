import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_to_do_list/core/constants/user_role.dart';

void main() {
  group('UserRole', () {
    test('fromLabel khớp với giá trị đang lưu trong Firestore', () {
      expect(UserRole.fromLabel('Admin'), UserRole.admin);
      expect(UserRole.fromLabel('User'), UserRole.user);
      expect(UserRole.fromLabel('Tổ phần mềm'), UserRole.softTeam);
      expect(UserRole.fromLabel('Tổ phần cứng'), UserRole.hardTeam);
      expect(UserRole.fromLabel('Y bác sỹ'), UserRole.doctor);
    });

    test('fromLabel trả về null với vai trò lạ hoặc rỗng', () {
      expect(UserRole.fromLabel('admin'), isNull);
      expect(UserRole.fromLabel(''), isNull);
      expect(UserRole.fromLabel(null), isNull);
    });

    test('chỉ hai tổ IT là nhân viên IT', () {
      expect(UserRole.values.where((r) => r.isItMember), [UserRole.softTeam, UserRole.hardTeam]);
      expect(UserRole.itLabels, ['Tổ phần mềm', 'Tổ phần cứng']);
    });
  });
}
