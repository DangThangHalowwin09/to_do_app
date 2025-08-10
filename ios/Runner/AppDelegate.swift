import Flutter
import UIKit
import flutter_local_notifications
import FirebaseCore  // Thêm Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Khởi tạo Firebase từ GoogleService-Info.plist
        FirebaseApp.configure()

        // Đăng ký plugin cho flutter_local_notifications
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        // Cấu hình quyền thông báo và delegate
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { granted, error in
                if let error = error {
                    print("Error requesting notification permission: \(error)")
                } else {
                    print("Notification permission granted: \(granted)")
                }
            }
        } else {
            // iOS 9 trở xuống
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Xử lý khi thông báo đến lúc app đang mở
    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }

    // Xử lý khi người dùng bấm vào thông báo
    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("User tapped notification: \(response.notification.request.identifier)")
        completionHandler()
    }
}
