const test = require('node:test');
const assert = require('node:assert/strict');
const { tokensOf, pickRecipients, isDeadTokenCode, taskNeedsNotice, ROLE, ERROR_TYPE } = require('../lib');

const staff = [
  { id: 'a', role: ROLE.soft, groups: [] },
  { id: 'b', role: ROLE.hard, groups: ['Khu A'] },
  { id: 'c', role: ROLE.hard, groups: ['Khu B'] },
];

test('tokensOf gộp token mới + cũ, bỏ rỗng/trùng', () => {
  assert.deepEqual(tokensOf({ fcmTokens: ['x', 'y', ''], fcmToken: 'x' }), ['x', 'y']);
  assert.deepEqual(tokensOf({ fcmToken: 'z' }), ['z']);
  assert.deepEqual(tokensOf({ fcmToken: '' }), []);
  assert.deepEqual(tokensOf(undefined), []);
});

test('lỗi phần mềm → cả Tổ phần mềm', () => {
  assert.deepEqual(pickRecipients(ERROR_TYPE.software, staff, ['Khu A']).map((u) => u.id), ['a']);
});

test('lỗi phần cứng → đúng người phụ trách khu vực', () => {
  assert.deepEqual(pickRecipients(ERROR_TYPE.hardware, staff, ['Khu A']).map((u) => u.id), ['b']);
});

test('lỗi phần cứng nhưng không khớp khu vực → cả Tổ phần cứng', () => {
  assert.deepEqual(pickRecipients(ERROR_TYPE.hardware, staff, []).map((u) => u.id), ['b', 'c']);
  assert.deepEqual(pickRecipients(ERROR_TYPE.hardware, staff, ['Khu Z']).map((u) => u.id), ['b', 'c']);
});

test('nhận diện token chết', () => {
  assert.equal(isDeadTokenCode('messaging/registration-token-not-registered'), true);
  assert.equal(isDeadTokenCode('messaging/internal-error'), false);
});

test('taskNeedsNotice', () => {
  const ts = (ms) => ({ toMillis: () => ms });
  const t = { assignedTo: 'u1', title: 'A', endTime: ts(1) };
  assert.equal(taskNeedsNotice(null, t), true);
  assert.equal(taskNeedsNotice(t, { ...t }), false);
  assert.equal(taskNeedsNotice(t, { ...t, status: 'done' }), false);
  assert.equal(taskNeedsNotice(t, { ...t, assignedTo: 'u2' }), true);
  assert.equal(taskNeedsNotice(t, { ...t, endTime: ts(2) }), true);
  assert.equal(taskNeedsNotice(null, { title: 'x' }), false);
});
