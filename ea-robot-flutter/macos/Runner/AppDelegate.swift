import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    let telemetryChannel = FlutterMethodChannel(name: "com.engineeredarts.robot/telemetry",
                                              binaryMessenger: controller.engine.binaryMessenger)
    telemetryChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getThermalState" {
        result(self.getThermalState())
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    super.applicationDidFinishLaunching(notification)
  }

  private func getThermalState() -> String {
    switch ProcessInfo.processInfo.thermalState {
    case .nominal: return "NOMINAL"
    case .fair: return "FAIR"
    case .serious: return "SERIOUS"
    case .critical: return "CRITICAL"
    @unknown default: return "NOMINAL"
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
