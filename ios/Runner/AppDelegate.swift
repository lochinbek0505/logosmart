import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LogoSmartStorage") {
      registerStorageChannel(messenger: registrar.messenger())
    }
  }

  /// Resurslar uchun: bo'sh joy va iCloud zaxirasidan chiqarish (~155 MB iCloud'ni egallamasin)
  private func registerStorageChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "uz.logosmart/storage", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "freeBytes":
        let url = URL(fileURLWithPath: NSHomeDirectory())
        if let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
           let free = values.volumeAvailableCapacityForImportantUsage {
          result(NSNumber(value: free))
        } else {
          result(nil)
        }
      case "excludeFromBackup":
        guard let args = call.arguments as? [String: Any], let path = args["path"] as? String else {
          result(false)
          return
        }
        var url = URL(fileURLWithPath: path)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        do {
          try url.setResourceValues(values)
          result(true)
        } catch {
          result(false)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
