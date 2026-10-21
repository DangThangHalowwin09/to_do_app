const test = require('node:test');
const assert = require('node:assert/strict');
const lib = require('../lib');
const { ROLE, ERROR_TYPE, HOUR } = lib;

const ts = (ms) => ({ toMillis: () => ms });

const staff = [
  { id: 'a', role: ROLE.soft, groups: [] },
  { id: 'b', role: ROLE.hard, groups: ['Khu A'] },
  { id: 'c', role: ROLE.hard, groups: ['Khu B'] },
];

test('collectTokens gộp thiết bị + trường cũ, bỏ rỗng/trùng', () => {
  assert.deepEqual(lib.collectTokens({ fcmTokens: ['x', ''], fcmToken: 'x' }, ['d', 'x']), ['d', 'x']);
  assert.deepEqual(lib.collectTokens({ fcmToken: 'z' }), ['z']);
  assert.deepEqual(lib.collectTokens(undefined, []), []);
});

test('pickRecipients: phần mềm → Tổ phần mềm; phần cứng → đúng khu vực, không khớp → cả tổ', () => {
  assert.deepEqual(lib.pickRecipients(ERROR_TYPE.software, staff, ['Khu A']).map((u) => u.id), ['a']);
  assert.deepEqual(lib.pickRecipients(ERROR_TYPE.hardware, staff, ['Khu A']).map((u) => u.id), ['b']);
  assert.deepEqual(lib.pickRecipients(ERROR_TYPE.hardware, staff, []).map((u) => u.id), ['b', 'c']);
});

test('isDeadTokenCode', () => {
  assert.equal(lib.isDeadTokenCode('messaging/registration-token-not-registered'), true);
  assert.equal(lib.isDeadTokenCode('messaging/internal-error'), false);
});

test('taskNeedsNotice', () => {
  const t = { assignedTo: 'u1', title: 'A', endTime: ts(1) };
  assert.equal(lib.taskNeedsNotice(null, t), true);
  assert.equal(lib.taskNeedsNotice(t, { ...t, status: 'done' }), false);
  assert.equal(lib.taskNeedsNotice(t, { ...t, assignedTo: 'u2' }), true);
  assert.equal(lib.taskNeedsNotice(t, { ...t, endTime: ts(2) }), true);
});

test('dueReminder: các mốc 24h / 1h / quá hạn, mỗi mốc một lần', () => {
  const now = 1_000 * HOUR;
  const task = (left, reminders) => ({ assignedTo: 'u', status: 'pending', endTime: ts(now + left), reminders });
  assert.equal(lib.dueReminder(task(30 * HOUR), now), null);
  assert.equal(lib.dueReminder(task(20 * HOUR), now), 'h24');
  assert.equal(lib.dueReminder(task(20 * HOUR, { h24: true }), now), null);
  assert.equal(lib.dueReminder(task(30 * 60 * 1000, { h24: true }), now), 'h1');
  assert.equal(lib.dueReminder(task(30 * 60 * 1000), now), 'h1'); // giao gấp: nhắc 1h, bỏ qua 24h
  assert.equal(lib.dueReminder(task(-1, { h24: true, h1: true }), now), 'overdue');
  assert.equal(lib.dueReminder(task(-1, { overdue: true }), now), null);
  assert.equal(lib.dueReminder({ ...task(-1), status: 'done' }, now), null);
  // Quá hạn từ lâu (nhiệm vụ cũ) thì không nhắc nữa.
  assert.equal(lib.dueReminder(task(-25 * HOUR), now), null);
});

test('remindersAfter đánh dấu cả các mốc xa hơn', () => {
  assert.deepEqual(lib.remindersAfter('h1'), { h24: true, h1: true });
  assert.deepEqual(lib.remindersAfter('overdue'), { h24: true, h1: true, overdue: true });
});

test('shouldEscalate: chưa nhận sau N phút và chưa nhắc', () => {
  const now = 100 * 60 * 1000;
  const e = (minAgo, extra = {}) => ({ isTakeOver: false, isDone: false, timeErrorStart: ts(now - minAgo * 60000), ...extra });
  assert.equal(lib.shouldEscalate(e(20), now, 15), true);
  assert.equal(lib.shouldEscalate(e(10), now, 15), false);
  assert.equal(lib.shouldEscalate(e(20, { escalatedAt: 1 }), now, 15), false);
  assert.equal(lib.shouldEscalate(e(20, { isTakeOver: true }), now, 15), false);
  // Phiếu cũ hơn 24 giờ không báo khẩn (tránh gửi tràn lúc mới deploy).
  assert.equal(lib.shouldEscalate(e(25 * 60), 30 * 60 * 60000, 15), false);
});

test('ratingDelta: tạo, sửa, đổi người, xoá, dữ liệu sai', () => {
  assert.deepEqual(lib.ratingDelta(undefined, { staffUid: 's', stars: 4 }), { s: { sum: 4, count: 1 } });
  assert.deepEqual(lib.ratingDelta({ staffUid: 's', stars: 4 }, { staffUid: 's', stars: 5 }), { s: { sum: 1, count: 0 } });
  assert.deepEqual(lib.ratingDelta({ staffUid: 's', stars: 4 }, { staffUid: 's', stars: 4 }), {});
  assert.deepEqual(lib.ratingDelta({ staffUid: 's', stars: 4 }, { staffUid: 't', stars: 2 }), {
    s: { sum: -4, count: -1 },
    t: { sum: 2, count: 1 },
  });
  assert.deepEqual(lib.ratingDelta({ staffUid: 's', stars: 3 }, undefined), { s: { sum: -3, count: -1 } });
  assert.deepEqual(lib.ratingDelta(undefined, { staffUid: 's', stars: 9 }), {});
});

test('formatVnTime dùng giờ Việt Nam (UTC+7)', () => {
  assert.equal(lib.formatVnTime(Date.UTC(2026, 9, 21, 7, 30)), '14:30 21/10/2026');
});
