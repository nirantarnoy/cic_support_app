import UIKit
import Flutter

import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FlutterLocalNotificationsPlugin.setPluginRegistransCallback((registry) in GeneratedPluginRegistrant.register(with: registry))

    GeneratedPluginRegistrant.register(with: self)

      if #available(iOS 10.0,*){
        UnUserNotificationCenter.current().delegate = self as? UnUserNotificationCenter
      }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
