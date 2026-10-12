/// Vai trò người dùng. [label] là giá trị lưu trong Firestore (`users.role`),
/// nên KHÔNG được đổi chuỗi này nếu không muốn mất dữ liệu cũ.
enum UserRole {
  admin('Admin'),
  user('User'),
  softTeam('Tổ phần mềm'),
  hardTeam('Tổ phần cứng'),
  doctor('Y bác sỹ');

  const UserRole(this.label);

  final String label;

  /// Nhân viên phòng IT (xử lý báo lỗi).
  bool get isItMember => this == softTeam || this == hardTeam;

  static UserRole? fromLabel(String? label) {
    for (final role in values) {
      if (role.label == label) return role;
    }
    return null;
  }

  /// Danh sách nhãn của nhân viên IT, dùng cho truy vấn Firestore.
  static List<String> get itLabels =>
      values.where((r) => r.isItMember).map((r) => r.label).toList();
}
