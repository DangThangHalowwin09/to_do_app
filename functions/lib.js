// Hàm thuần (không gọi Firebase) để dễ kiểm thử.

const ROLE = {
  admin: 'Admin',
  soft: 'Tổ phần mềm',
  hard: 'Tổ phần cứng',
  doctor: 'Y bác sỹ',
  headNurse: 'Điều dưỡng trưởng',
  nurse: 'Điều dưỡng',
};

const IT_ROLES = [ROLE.soft, ROLE.hard];

const ERROR_TYPE = {
  software: 'Báo lỗi phần mềm',
  hardware: 'Báo lỗi phần cứng',
};

const HOUR = 60 * 60 * 1000;

/**
 * Chỉ nhắc / báo khẩn cho dữ liệu trong khoảng này. Tránh việc lần chạy đầu tiên
 * (hoặc sau khi Functions tạm dừng) gửi hàng loạt thông báo cho phiếu, nhiệm vụ cũ.
 */
const MAX_AGE = 24 * HOUR;

/**
 * Gom token của một người: thiết bị đã đăng ký (`users/{uid}/devices`) + trường cũ
 * `fcmTokens` (mảng) / `fcmToken` (chuỗi) của các bản app trước. Bỏ rỗng và trùng.
 */
function collectTokens(userData, deviceTokens = []) {
  const list = Array.isArray(userData?.fcmTokens) ? userData.fcmTokens : [];
  const legacy = userData?.fcmToken ? [userData.fcmToken] : [];
  return [...new Set([...deviceTokens, ...list, ...legacy].filter((t) => typeof t === 'string' && t.length > 0))];
}

/**
 * Chọn nhân viên IT cần báo khi có phiếu lỗi mới.
 * - Lỗi phần mềm: toàn bộ Tổ phần mềm.
 * - Lỗi phần cứng: Tổ phần cứng phụ trách khu vực của người báo; nếu không khớp ai thì báo cả tổ.
 * `candidates`: [{ id, role, groups }]; `reporterGroups`: tên các khu vực của người báo lỗi.
 */
function pickRecipients(errorType, candidates, reporterGroups) {
  if (errorType === ERROR_TYPE.software) {
    return candidates.filter((u) => u.role === ROLE.soft);
  }
  const hardware = candidates.filter((u) => u.role === ROLE.hard);
  const matched = hardware.filter((u) => (u.groups ?? []).some((g) => reporterGroups.includes(g)));
  return matched.length > 0 ? matched : hardware;
}

/** Token mà FCM báo là không còn dùng được → nên xoá khỏi hồ sơ. */
function isDeadTokenCode(code) {
  return (
    code === 'messaging/registration-token-not-registered' ||
    code === 'messaging/invalid-registration-token' ||
    code === 'messaging/invalid-argument'
  );
}

/** Nhiệm vụ cần báo lại người nhận khi mới tạo hoặc đổi người/tiêu đề/deadline. */
function taskNeedsNotice(before, after) {
  if (!after?.assignedTo) return false;
  if (!before) return true;
  const deadline = (t) => t.endTime?.toMillis?.() ?? null;
  return (
    before.assignedTo !== after.assignedTo ||
    before.title !== after.title ||
    deadline(before) !== deadline(after)
  );
}

/**
 * Mốc nhắc hạn cần gửi cho một nhiệm vụ tại thời điểm `nowMs`, hoặc `null`.
 * Mỗi mốc chỉ gửi một lần (đánh dấu trong `task.reminders`):
 *   `h24` còn ≤ 24 giờ · `h1` còn ≤ 1 giờ · `overdue` đã quá hạn.
 */
function dueReminder(task, nowMs) {
  if (!task || task.status === 'done' || !task.assignedTo) return null;
  const endMs = task.endTime?.toMillis?.();
  if (typeof endMs !== 'number') return null;
  const sent = task.reminders ?? {};
  const left = endMs - nowMs;
  if (left <= 0) return sent.overdue || -left > MAX_AGE ? null : 'overdue';
  if (left <= HOUR) return sent.h1 ? null : 'h1';
  if (left <= 24 * HOUR) return sent.h24 ? null : 'h24';
  return null;
}

/** Các mốc được coi là đã gửi khi gửi mốc `kind` (gửi mốc gần hơn thì bỏ qua mốc xa hơn). */
function remindersAfter(kind) {
  if (kind === 'overdue') return { h24: true, h1: true, overdue: true };
  if (kind === 'h1') return { h24: true, h1: true };
  return { h24: true };
}

/** Nội dung nhắc hạn. `deadlineText` đã định dạng sẵn theo giờ Việt Nam. */
function reminderMessage(kind, title, deadlineText) {
  switch (kind) {
    case 'overdue':
      return { title: 'Nhiệm vụ đã quá hạn', body: `"${title}" đã quá hạn lúc ${deadlineText}.` };
    case 'h1':
      return { title: 'Nhiệm vụ sắp đến hạn (còn dưới 1 giờ)', body: `"${title}" – hạn ${deadlineText}.` };
    default:
      return { title: 'Nhắc việc: hạn trong 24 giờ tới', body: `"${title}" – hạn ${deadlineText}.` };
  }
}

/** Phiếu lỗi chưa ai nhận sau `minutes` phút và chưa từng nhắc lại → cần báo khẩn. */
function shouldEscalate(error, nowMs, minutes) {
  if (!error || error.isTakeOver || error.isDone || error.escalatedAt) return false;
  const created = error.timeErrorStart?.toMillis?.();
  if (typeof created !== 'number') return false;
  const age = nowMs - created;
  return age >= minutes * 60 * 1000 && age <= MAX_AGE;
}

/**
 * Thay đổi điểm đánh giá khi một bản ghi `staffRatings` được tạo/sửa/xoá.
 * Trả về { [staffUid]: { sum, count } } là lượng cần cộng thêm (có thể âm).
 */
function ratingDelta(before, after) {
  const changes = {};
  const add = (uid, sum, count) => {
    if (!uid) return;
    changes[uid] = changes[uid] ?? { sum: 0, count: 0 };
    changes[uid].sum += sum;
    changes[uid].count += count;
  };
  const valid = (r) => r && r.staffUid && Number.isInteger(r.stars) && r.stars >= 1 && r.stars <= 5;
  if (valid(before)) add(before.staffUid, -before.stars, -1);
  if (valid(after)) add(after.staffUid, after.stars, 1);
  for (const [uid, c] of Object.entries(changes)) {
    if (c.sum === 0 && c.count === 0) delete changes[uid];
  }
  return changes;
}

/** Định dạng thời gian theo giờ Việt Nam, ví dụ "14:30 21/10/2026". */
function formatVnTime(ms) {
  const d = new Date(ms + 7 * HOUR); // UTC+7, không có giờ mùa hè
  const p = (n) => String(n).padStart(2, '0');
  return `${p(d.getUTCHours())}:${p(d.getUTCMinutes())} ${p(d.getUTCDate())}/${p(d.getUTCMonth() + 1)}/${d.getUTCFullYear()}`;
}

module.exports = {
  ROLE,
  IT_ROLES,
  ERROR_TYPE,
  HOUR,
  MAX_AGE,
  collectTokens,
  pickRecipients,
  isDeadTokenCode,
  taskNeedsNotice,
  dueReminder,
  remindersAfter,
  reminderMessage,
  shouldEscalate,
  ratingDelta,
  formatVnTime,
};
