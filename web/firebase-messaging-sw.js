// web/firebase-messaging-sw.js

// Import các script cần thiết của Firebase
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// Cấu hình Firebase của bạn
firebase.initializeApp({
  apiKey: "AIzaSyBK_SVII93P0-hnUOHe0JqPDXMASXeitDs",
  authDomain: "test-937d3.firebaseapp.com",
  projectId: "test-937d3",
  storageBucket: "test-937d3.firebasestorage.app",
  messagingSenderId: "385662617488",
  appId: "1:385662617488:web:66c9e7f3eaaac36b789515",
  measurementId: "G-R6GQ0319TJ"
});

// Khởi tạo Messaging
const messaging = firebase.messaging();

// Xử lý nhận thông báo khi app không mở (background)
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification?.title ?? 'Thông báo mới';
  const notificationOptions = {
    body: payload.notification?.body ?? 'Bạn có thông báo mới.',
    icon: '/icons/Icon-192.png', // bạn có thể thay icon tùy thích
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
