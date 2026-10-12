// Hàm thuần (không gọi Firebase) để dễ kiểm thử.

const ROLE = {
  soft: 'Tổ phần mềm',
  hard: 'Tổ phần cứng',
};

const ERROR_TYPE = {
  software: 'Báo lỗi phần mềm',
  hardware: 'Báo lỗi phần cứng',
};

/** Gom token của một hồ sơ user: `fcmTokens` (mới) + `fcmToken` (cũ), bỏ rỗng và trùng. */
function tokensOf(userData) {
  const list = Array.isArray(userData?.fcmTokens) ? userData.fcmTokens : [];
  const legacy = userData?.fcmToken ? [userData.fcmToken] : [];
  return [...new Set([...list, ...legacy].filter((t) => typeof t === 'string' && t.length > 0))];
}

/**
 * Chọn nhân viên IT cần báo khi có phiếu lỗi mới.
 * - Lỗi phần mềm: toàn bộ Tổ phần mềm.
 * - Lỗi phần cứng: Tổ phần cứng phụ trách khu vực của bác sỹ; nếu không khớp ai thì báo cả tổ.
 * `candidates`: [{ id, role, groups }]; `reporterGroups`: tên các khu vực của bác sỹ báo lỗi.
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
    code === 'messaging/invalid-registration-token'
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

module.exports = { ROLE, ERROR_TYPE, tokensOf, pickRecipients, isDeadTokenCode, taskNeedsNotice };
