/// Quy tắc xoay vòng lịch trực: mỗi ngày một người, lặp lại sau [cycleLength] ngày.
///
/// Mỗi nhân viên có `idDuty` (0..12) trong hồ sơ. Ca trực của ngày D kéo dài từ 08:00 ngày D
/// đến 08:00 ngày D+1; từ 00:00 đến 08:00 ngày D vẫn là người trực của ngày D-1.
class DutySchedule {
  DutySchedule._();

  static const int cycleLength = 13;

  /// Ngày đầu tiên của chu kỳ (có `idDuty` = 0).
  static final DateTime firstDay = DateTime(2025, 7, 5);

  /// `idDuty` của người trực ca bắt đầu từ 08:00 ngày [date]; `null` nếu [date] trước [firstDay].
  static int? idOnDate(DateTime date) {
    final days = _dateOnly(date).difference(firstDay).inDays;
    return days < 0 ? null : days % cycleLength;
  }

  /// `idDuty` của người trực ngay trước [id] (quay vòng 0 → 12).
  static int previousId(int id) => (id + cycleLength - 1) % cycleLength;

  /// Các ngày trong tháng [month] năm [year] mà người có `idDuty` = [id] trực.
  static List<DateTime> daysOfMonth({required int id, required int year, required int month}) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return [
      for (var day = 1; day <= daysInMonth; day++)
        if (idOnDate(DateTime(year, month, day)) == id) DateTime(year, month, day),
    ];
  }

  static const _weekdays = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];

  /// Ví dụ: "Thứ Hai, 5/7/2025".
  static String formatDate(DateTime date) =>
      '${_weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
