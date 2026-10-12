import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_to_do_list/core/utils/duty_schedule.dart';

void main() {
  group('DutySchedule.idOnDate', () {
    test('ngày đầu chu kỳ có id 0 và tăng dần mỗi ngày', () {
      expect(DutySchedule.idOnDate(DateTime(2025, 7, 5)), 0);
      expect(DutySchedule.idOnDate(DateTime(2025, 7, 6)), 1);
      expect(DutySchedule.idOnDate(DateTime(2025, 7, 17)), 12);
    });

    test('quay vòng sau 13 ngày', () {
      expect(DutySchedule.idOnDate(DateTime(2025, 7, 18)), 0);
      expect(DutySchedule.idOnDate(DateTime(2026, 10, 12)), 9); // 464 ngày kể từ 5/7/2025, 464 % 13 = 9
    });

    test('không phụ thuộc giờ trong ngày', () {
      expect(DutySchedule.idOnDate(DateTime(2025, 7, 6, 0, 0)), 1);
      expect(DutySchedule.idOnDate(DateTime(2025, 7, 6, 23, 59)), 1);
    });

    test('trước ngày đầu chu kỳ thì chưa có lịch', () {
      expect(DutySchedule.idOnDate(DateTime(2025, 7, 4)), isNull);
    });
  });

  test('previousId quay vòng từ 0 về 12', () {
    expect(DutySchedule.previousId(0), 12);
    expect(DutySchedule.previousId(5), 4);
  });

  test('daysOfMonth: id 0 trực 5/7, 18/7, 31/7', () {
    final days = DutySchedule.daysOfMonth(id: 0, year: 2025, month: 7);
    expect(days.map((d) => d.day), [5, 18, 31]);
  });

  test('formatDate', () {
    expect(DutySchedule.formatDate(DateTime(2025, 7, 5)), 'Thứ Bảy, 5/7/2025');
  });
}
