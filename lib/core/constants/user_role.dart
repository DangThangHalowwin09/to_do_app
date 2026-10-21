/// Vai trò người dùng. [label] là giá trị lưu trong Firestore (`users.role`),
/// nên KHÔNG được đổi chuỗi này nếu không muốn mất dữ liệu cũ.
enum UserRole {
  admin('Admin'),
  user('User'),
  softTeam('Tổ phần mềm'),
  hardTeam('Tổ phần cứng'),
  doctor('Y bác sỹ'),
  headNurse('Điều dưỡng trưởng'),
  nurse('Điều dưỡng');

  const UserRole(this.label);

  final String label;

  /// Nhân viên phòng IT (nhận và xử lý báo lỗi).
  bool get isItMember => this == softTeam || this == hardTeam;

  /// Nhân viên lâm sàng (bác sỹ, điều dưỡng): thuộc các khoa (`areas`), gửi báo lỗi,
  /// gọi nhanh IT phụ trách, đánh giá nhân viên IT. Dùng chung một bộ chức năng.
  bool get isClinical => this == doctor || this == headNurse || this == nurse;

  static UserRole? fromLabel(String? label) {
    for (final role in values) {
      if (role.label == label) return role;
    }
    return null;
  }

  /// Danh sách nhãn của nhân viên IT, dùng cho truy vấn Firestore.
  static List<String> get itLabels => values.where((r) => r.isItMember).map((r) => r.label).toList();

  /// Danh sách nhãn của nhân viên lâm sàng, dùng cho truy vấn Firestore.
  static List<String> get clinicalLabels => values.where((r) => r.isClinical).map((r) => r.label).toList();
}
