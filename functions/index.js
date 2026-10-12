const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { setGlobalOptions } = require('firebase-functions/v2');
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');

const { ROLE, tokensOf, pickRecipients, isDeadTokenCode, taskNeedsNotice } = require('./lib');

initializeApp();
const db = getFirestore();

// Đặt cùng vùng với Firestore của dự án để giảm độ trễ (đổi nếu Firestore ở vùng khác).
setGlobalOptions({ region: 'asia-southeast1', maxInstances: 5 });

const ANDROID_CHANNEL_ID = 'channel_id'; // trùng với kênh tạo trong LocalNotificationsService

/** Gửi thông báo tới các user; tự dọn token chết. */
async function notifyUsers(userIds, { title, body, data }) {
  const ids = [...new Set(userIds.filter(Boolean))];
  if (ids.length === 0) return;

  const docs = await Promise.all(ids.map((id) => db.collection('users').doc(id).get()));
  const owners = []; // [{ uid, token }]
  for (const doc of docs) {
    for (const token of tokensOf(doc.data())) owners.push({ uid: doc.id, token });
  }
  if (owners.length === 0) {
    logger.info('Không có token để gửi', { userIds: ids });
    return;
  }

  // FCM cho phép tối đa 500 token mỗi lần gửi.
  for (let i = 0; i < owners.length; i += 500) {
    const batch = owners.slice(i, i + 500);
    const response = await getMessaging().sendEachForMulticast({
      tokens: batch.map((o) => o.token),
      notification: { title, body },
      data,
      android: { priority: 'high', notification: { channelId: ANDROID_CHANNEL_ID } },
      apns: { headers: { 'apns-priority': '10' }, payload: { aps: { sound: 'default' } } },
    });

    const cleanups = [];
    response.responses.forEach((r, idx) => {
      if (r.success) return;
      const { uid, token } = batch[idx];
      logger.warn('Gửi thất bại', { uid, code: r.error?.code });
      if (isDeadTokenCode(r.error?.code)) {
        cleanups.push(
          db.collection('users').doc(uid).update({
            fcmTokens: FieldValue.arrayRemove(token),
            // token kiểu cũ (một giá trị) cũng được xoá nếu trùng
          }),
        );
      }
    });
    await Promise.allSettled(cleanups);
  }
}

async function usersWithRoles(roles) {
  const snapshot = await db.collection('users').where('role', 'in', roles).get();
  return snapshot.docs.map((d) => ({ id: d.id, role: d.data().role, groups: d.data().groups ?? [] }));
}

/** Tên các khu vực (groups) mà bác sỹ phụ trách: areas → groupId → groups.name. */
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
  const names = [];
  for (const groupId of groupIds) {
    const group = await db.collection('groups').doc(groupId).get();
    if (group.data()?.name) names.push(group.data().name);
  }
  return names;
}

// 1) Có phiếu báo lỗi mới → báo nhân viên IT phụ trách.
exports.onErrorCreated = onDocumentCreated('errors/{errorId}', async (event) => {
  const error = event.data?.data();
  if (!error) return;

  const candidates = await usersWithRoles([ROLE.soft, ROLE.hard]);
  const reporterGroups = await groupNamesOfReporter(error.reporterUid);
  const recipients = pickRecipients(error.errorType, candidates, reporterGroups);

  await notifyUsers(
    recipients.map((u) => u.id),
    {
      title: `Báo lỗi mới: ${error.errorTitle ?? ''}`,
      body: `${error.nameDoctor ?? 'Bác sỹ'}: ${error.clarifyTitle ?? ''}`.slice(0, 200),
      data: { type: 'error', id: event.params.errorId },
    },
  );
});

// 2) IT nhận xử lý / hoàn thành → báo lại cho người đã báo lỗi.
exports.onErrorUpdated = onDocumentUpdated('errors/{errorId}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after || !after.reporterUid) return;

  let body = null;
  if (!before.isTakeOver && after.isTakeOver) {
    body = `${after.nameStaff || 'Nhân viên IT'} đã nhận xử lý: ${after.errorTitle ?? ''}`;
  } else if (!before.isDone && after.isDone) {
    body = `Đã xử lý xong: ${after.errorTitle ?? ''}`;
  }
  if (!body) return;

  await notifyUsers([after.reporterUid], {
    title: 'Cập nhật phiếu báo lỗi',
    body,
    data: { type: 'error', id: event.params.errorId },
  });
});

// 3) Giao việc mới / đổi người nhận → báo người được giao.
async function noticeTask(taskId, before, after) {
  if (!taskNeedsNotice(before, after)) return;
  await notifyUsers([after.assignedTo], {
    title: 'Trưởng phòng đã giao bạn nhiệm vụ mới!',
    body: after.title ?? '',
    data: { type: 'task', id: taskId },
  });
}

exports.onTaskCreated = onDocumentCreated('tasks/{taskId}', (event) =>
  noticeTask(event.params.taskId, null, event.data?.data()),
);

exports.onTaskUpdated = onDocumentUpdated('tasks/{taskId}', (event) =>
  noticeTask(event.params.taskId, event.data?.before.data(), event.data?.after.data()),
);
