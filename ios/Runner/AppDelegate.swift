import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // API 키를 String으로 안전하게 변환
    if let apiKey = Bundle.main.infoDictionary?["GOOGLE_MAP_API_KEY"] as? String {
      GMSServices.provideAPIKey(apiKey)
    } else {
      fatalError("Google Maps API key is missing in Info.plist")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
