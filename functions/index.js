const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { setGlobalOptions } = require('firebase-functions/v2');
const { defineString } = require('firebase-functions/params');
const { onDocumentCreated, onDocumentUpdated, onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const logger = require('firebase-functions/logger');

const lib = require('./lib');
const { ROLE, IT_ROLES, HOUR, MAX_AGE } = lib;

initializeApp();
const db = getFirestore();

// Đặt cùng vùng với Firestore của dự án để giảm độ trễ (đổi nếu Firestore ở vùng khác).
setGlobalOptions({ region: 'asia-southeast1', maxInstances: 5 });

/** Địa chỉ bản web, dùng làm link khi bấm thông báo trên trình duyệt. Đổi khi deploy nếu cần. */
const APP_WEB_URL = defineString('APP_WEB_URL', { default: 'https://test-937d3.web.app' });

const ANDROID_CHANNEL_ID = 'channel_id'; // trùng với kênh tạo trong LocalNotificationsService
const TIME_ZONE = 'Asia/Ho_Chi_Minh';
const ESCALATE_AFTER_MINUTES = 15;

// ---------------------------------------------------------------------------
// Gửi thông báo: ghi hộp thư + gửi push tới mọi thiết bị, dọn token hết hạn.
// ---------------------------------------------------------------------------

/**
 * @param {string[]} userIds người nhận
 * @param {{title: string, body: string, type: 'error'|'task'|'rating', refId: string}} message
 */
async function notifyUsers(userIds, { title, body, type, refId }) {
  const ids = [...new Set(userIds.filter(Boolean))];
  if (ids.length === 0) return;

  // 1) Hộp thư trong app: người tắt push hoặc dùng web chưa cấp quyền vẫn thấy.
  const inbox = db.batch();
  for (const uid of ids) {
    inbox.set(db.collection('users').doc(uid).collection('notifications').doc(), {
      title,
      body,
      type,
      refId,
      read: false,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  await inbox.commit();

  // 2) Thu token của mọi thiết bị.
  const owners = []; // [{ uid, token }]
  await Promise.all(
    ids.map(async (uid) => {
      const [user, devices] = await Promise.all([
        db.collection('users').doc(uid).get(),
        db.collection('users').doc(uid).collection('devices').get(),
      ]);
      for (const token of lib.collectTokens(user.data(), devices.docs.map((d) => d.id))) {
        owners.push({ uid, token });
      }
    }),
  );
  if (owners.length === 0) {
    logger.info('Không có thiết bị để gửi push', { userIds: ids, type });
    return;
  }

  // 3) Gửi (FCM cho phép tối đa 500 token mỗi lần).
  for (let i = 0; i < owners.length; i += 500) {
    const batch = owners.slice(i, i + 500);
    const response = await getMessaging().sendEachForMulticast({
      tokens: batch.map((o) => o.token),
      notification: { title, body },
      data: { type, id: refId },
      android: {
        priority: 'high',
        notification: { channelId: ANDROID_CHANNEL_ID, icon: 'ic_stat_notification', color: '#00408C' },
      },
      apns: { headers: { 'apns-priority': '10' }, payload: { aps: { sound: 'default' } } },
      webpush: {
        headers: { Urgency: 'high' },
        notification: { icon: '/icons/Icon-192.png' },
        fcmOptions: { link: APP_WEB_URL.value() },
      },
    });

    const cleanups = [];
    response.responses.forEach((r, idx) => {
      if (r.success) return;
      const { uid, token } = batch[idx];
      logger.warn('Gửi push thất bại', { uid, code: r.error?.code });
      if (!lib.isDeadTokenCode(r.error?.code)) return;
      const userRef = db.collection('users').doc(uid);
      cleanups.push(userRef.collection('devices').doc(token).delete());
      cleanups.push(userRef.update({ fcmTokens: FieldValue.arrayRemove(token) }));
    });
    await Promise.allSettled(cleanups);
  }
}

async function usersWithRoles(roles) {
  const snapshot = await db.collection('users').where('role', 'in', roles).get();
  return snapshot.docs.map((d) => ({ id: d.id, role: d.data().role, groups: d.data().groups ?? [] }));
}

/** Tên các khu vực (groups) của người báo lỗi: areas → groupId → groups.name. */
async function groupNamesOfReporter(reporterUid) {
  if (!reporterUid) return [];
  const reporter = await db.collection('users').doc(reporterUid).get();
  const areaNames = reporter.data()?.areas ?? [];
  if (areaNames.length === 0) return [];

  const groupIds = new Set();
  for (let i = 0; i < areaNames.length; i += 10) {
    const areas = await db.collection('areas').where('name', 'in', areaNames.slice(i, i + 10)).get();
    areas.docs.forEach((d) => d.data().groupId && groupIds.add(d.data().groupId));
  }
  const groups = await Promise.all([...groupIds].map((id) => db.collection('groups').doc(id).get()));
  return groups.map((g) => g.data()?.name).filter(Boolean);
}

// ---------------------------------------------------------------------------
// 1) Báo hỏng
// ---------------------------------------------------------------------------

/** Có phiếu báo hỏng mới → báo nhân viên IT phụ trách. */
exports.onErrorCreated = onDocumentCreated('errors/{errorId}', async (event) => {
  const error = event.data?.data();
  if (!error) return;

  const candidates = await usersWithRoles(IT_ROLES);
  const recipients = lib.pickRecipients(error.errorType, candidates, await groupNamesOfReporter(error.reporterUid));
  const where = error.address ? ` tại ${error.address}` : '';

  await notifyUsers(recipients.map((u) => u.id), {
    title: `Báo hỏng mới: ${error.errorTitle ?? ''}`,
    body: `${error.nameDoctor || 'Nhân viên'}${where}: ${error.clarifyTitle ?? ''}`.slice(0, 240),
    type: 'error',
    refId: event.params.errorId,
  });
});

/** IT nhận xử lý / hoàn thành → báo lại người báo; hoàn thành thì mời đánh giá. */
exports.onErrorUpdated = onDocumentUpdated('errors/{errorId}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after || !after.reporterUid) return;
  const title = after.errorTitle ?? '';

  if (!before.isTakeOver && after.isTakeOver) {
    await notifyUsers([after.reporterUid], {
      title: 'Phiếu báo hỏng đã có người nhận',
      body: `${after.nameStaff || 'Nhân viên IT'} đang xử lý: ${title}`,
      type: 'error',
      refId: event.params.errorId,
    });
  } else if (!before.isDone && after.isDone) {
    await notifyUsers([after.reporterUid], {
      title: 'Đã xử lý xong – mời bạn đánh giá',
      body: `"${title}" đã hoàn thành. Hãy đánh giá ${after.nameStaff || 'nhân viên IT'} để phòng CNTT phục vụ tốt hơn.`,
      type: 'rating',
      refId: event.params.errorId,
    });
  }
});

/** Phiếu chưa ai nhận sau 15 phút → báo khẩn cho toàn bộ IT và Admin (một lần). */
exports.escalateUnclaimedErrors = onSchedule({ schedule: 'every 5 minutes', timeZone: TIME_ZONE }, async () => {
  const now = Date.now();
  const cutoff = Timestamp.fromMillis(now - ESCALATE_AFTER_MINUTES * 60 * 1000);
  const snapshot = await db
    .collection('errors')
    .where('isTakeOver', '==', false)
    .where('timeErrorStart', '<=', cutoff)
    .where('timeErrorStart', '>=', Timestamp.fromMillis(now - MAX_AGE))
    .get();

  const pending = snapshot.docs.filter((d) => lib.shouldEscalate(d.data(), now, ESCALATE_AFTER_MINUTES));
  if (pending.length === 0) return;

  const recipients = (await usersWithRoles([...IT_ROLES, ROLE.admin])).map((u) => u.id);
  for (const doc of pending) {
    const error = doc.data();
    // Đánh dấu trước khi gửi để lần chạy sau không gửi trùng.
    await doc.ref.update({ escalatedAt: FieldValue.serverTimestamp() });
    await notifyUsers(recipients, {
      title: `Chưa ai nhận phiếu sau ${ESCALATE_AFTER_MINUTES} phút`,
      body: `${error.errorTitle ?? ''} – ${error.nameDoctor || 'Nhân viên'}${error.address ? `, ${error.address}` : ''}`,
      type: 'error',
      refId: doc.id,
    });
  }
});

// ---------------------------------------------------------------------------
// 2) Giao việc + nhắc hạn
// ---------------------------------------------------------------------------

async function noticeTask(taskId, before, after) {
  if (!lib.taskNeedsNotice(before, after)) return;
  const deadline = after.endTime?.toMillis?.();
  await notifyUsers([after.assignedTo], {
    title: before ? 'Nhiệm vụ của bạn được cập nhật' : 'Bạn được giao nhiệm vụ mới',
    body: `${after.title ?? ''}${deadline ? ` – hạn ${lib.formatVnTime(deadline)}` : ''}`,
    type: 'task',
    refId: taskId,
  });
}

exports.onTaskCreated = onDocumentCreated('tasks/{taskId}', (event) =>
  noticeTask(event.params.taskId, null, event.data?.data()),
);

exports.onTaskUpdated = onDocumentUpdated('tasks/{taskId}', (event) =>
  noticeTask(event.params.taskId, event.data?.before.data(), event.data?.after.data()),
);

/** Mỗi 15 phút: nhắc nhiệm vụ còn ≤ 24 giờ, ≤ 1 giờ và khi đã quá hạn (mỗi mốc một lần). */
exports.taskDeadlineReminders = onSchedule({ schedule: 'every 15 minutes', timeZone: TIME_ZONE }, async () => {
  const now = Date.now();
  const snapshot = await db
    .collection('tasks')
    .where('status', '==', 'pending')
    .where('endTime', '<=', Timestamp.fromMillis(now + 24 * HOUR))
    .where('endTime', '>=', Timestamp.fromMillis(now - MAX_AGE))
    .get();

  for (const doc of snapshot.docs) {
    const task = doc.data();
    const kind = lib.dueReminder(task, now);
    if (!kind) continue;

    const flags = lib.remindersAfter(kind);
    await doc.ref.update(Object.fromEntries(Object.entries(flags).map(([k, v]) => [`reminders.${k}`, v])));

    const msg = lib.reminderMessage(kind, task.title ?? '', lib.formatVnTime(task.endTime.toMillis()));
    // Quá hạn thì báo cả người giao việc.
    const recipients = kind === 'overdue' ? [task.assignedTo, task.createdBy] : [task.assignedTo];
    await notifyUsers(recipients, { ...msg, type: 'task', refId: doc.id });
  }
});

// ---------------------------------------------------------------------------
// 3) Đánh giá nhân viên: cộng dồn điểm vào users/{staffUid}.ratingSum / ratingCount
// ---------------------------------------------------------------------------

exports.onStaffRatingWritten = onDocumentWritten('staffRatings/{ratingId}', async (event) => {
  const changes = lib.ratingDelta(event.data?.before.data(), event.data?.after.data());
  await Promise.all(
    Object.entries(changes).map(([uid, c]) =>
      db.collection('users').doc(uid).update({
        ratingSum: FieldValue.increment(c.sum),
        ratingCount: FieldValue.increment(c.count),
      }),
    ),
  );
});
