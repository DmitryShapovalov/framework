//import Crashlytics
//import Fabric
import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
//  var hypertrack: HyperTrack?

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    HyperTrack.registerForRemoteNotifications()
//    initializeSDK()
    return true
  }

//  func application(
//    _: UIApplication,
//    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
//  ) { HyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken) }
//  func application(
//    _: UIApplication,
//    didFailToRegisterForRemoteNotificationsWithError error: Error
//  ) { HyperTrack.didFailToRegisterForRemoteNotificationsWithError(error) }
//  func application(
//    _: UIApplication,
//    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//    fetchCompletionHandler completionHandler: @escaping (
//      UIBackgroundFetchResult
//    ) -> Void
//  ) {
//    HyperTrack.didReceiveRemoteNotification(
//      userInfo,
//      fetchCompletionHandler: completionHandler
//    )
//  }
//
//  private func initializeSDK() {
//    let infoDict = Bundle.main.infoDictionary
//    var publishableKey = infoDict?["HypertrackPK_Key"] as? String ?? ""
//    if let savedPk = UserDefaults.standard.value(forKey: kPublishableKey)
//      as? String
//    { publishableKey = savedPk }
//    if let firtchar = publishableKey.first {
//      let otherpk = String(publishableKey.dropFirst())
//      switch HyperTrack.makeSDK(publishableKey: .init(firtchar, otherpk)) {
//        case let .success(instace): hypertrack = instace
//        hypertrack?.stop()
//        case let .failure(error): print(error)
//      }
//    }
//  }
}
