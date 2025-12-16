import Flutter
import UIKit
import AVFoundation

public class SwiftFlutterLivePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_live", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterLivePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
    default:
        break
    }
  }
}
