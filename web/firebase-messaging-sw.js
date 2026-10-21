// Service worker nhận thông báo đẩy khi trang web UBNA Manager không mở.
// Phải nằm ở gốc tên miền (ví dụ Firebase Hosting: https://<project>.web.app/firebase-messaging-sw.js).
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// Phải trùng với DefaultFirebaseOptions.web trong lib/firebase_options.dart.
firebase.initializeApp({
  apiKey: 'AIzaSyBK_SVII93P0-hnUOHe0JqPDXMASXeitDs',
  authDomain: 'test-937d3.firebaseapp.com',
  projectId: 'test-937d3',
  storageBucket: 'test-937d3.firebasestorage.app',
  messagingSenderId: '385662617488',
  appId: '1:385662617488:web:22419240a09cbf22789515',
  measurementId: 'G-2PBMWMLCTD',
});

// Thông báo có phần `notification` (do Cloud Functions gửi) được trình duyệt tự hiển thị
// và tự mở `webpush.fcmOptions.link` khi bấm, nên không cần tự gọi showNotification ở đây
// (tự gọi sẽ làm mỗi thông báo hiện 2 lần).
firebase.messaging();
