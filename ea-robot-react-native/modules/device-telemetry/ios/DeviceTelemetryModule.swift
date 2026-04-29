import ExpoModulesCore

public class DeviceTelemetryModule: Module {
  public override func definition() -> ModuleDefinition {
    Name("DeviceTelemetry")

    Events("onThermalStateChange")

    AsyncFunction("getThermalStateAsync") { () -> String in
      return getThermalStateString(ProcessInfo.processInfo.thermalState)
    }

    OnStartObserving {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.thermalStateChanged),
        name: ProcessInfo.thermalStateDidChangeNotification,
        object: nil
      )
    }

    OnStopObserving {
      NotificationCenter.default.removeObserver(self)
    }
  }

  @objc
  private func thermalStateChanged() {
    let state = ProcessInfo.processInfo.thermalState
    sendEvent("onThermalStateChange", [
      "state": getThermalStateString(state)
    ])
  }

  private func getThermalStateString(_ state: ProcessInfo.ThermalState) -> String {
    switch state {
    case .nominal:
      return "NOMINAL"
    case .fair:
      return "FAIR"
    case .serious:
      return "SERIOUS"
    case .critical:
      return "CRITICAL"
    @unknown default:
      return "UNKNOWN"
    }
  }
}
