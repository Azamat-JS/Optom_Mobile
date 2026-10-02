import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = Self.mapsApiKey() { GMSServices.provideAPIKey(key) }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Reads MAPS_API_KEY from the bundled Flutter `.env` asset — the same file the Dart side loads
  /// with flutter_dotenv — so the key is configured in exactly one place.
  private static func mapsApiKey() -> String? {
    let assetKey = FlutterDartProject.lookupKey(forAsset: ".env")
    guard let path = Bundle.main.path(forResource: assetKey, ofType: nil),
          let contents = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
    for line in contents.split(whereSeparator: \.isNewline) {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      if trimmed.hasPrefix("MAPS_API_KEY=") {
        let value = String(trimmed.dropFirst("MAPS_API_KEY=".count)).trimmingCharacters(in: .whitespaces)
        return value.isEmpty ? nil : value
      }
    }
    return nil
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
