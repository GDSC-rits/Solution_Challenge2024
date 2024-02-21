import Flutter
import UIKit
import GoogleMaps  // Add this import

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
     GMSServices.provideAPIKey("AIzaSyByiRQ1kWkA75jvc9T4GzQwCRn7Na3h3E8")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
