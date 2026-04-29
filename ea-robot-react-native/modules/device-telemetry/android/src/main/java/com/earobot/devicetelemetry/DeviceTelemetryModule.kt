package com.earobot.devicetelemetry

import android.os.Build
import android.os.PowerManager
import android.content.Context
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class DeviceTelemetryModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("DeviceTelemetry")

    Events("onThermalStateChange")

    AsyncFunction("getThermalStateAsync") {
      val powerManager = appContext.reactContext?.getSystemService(Context.POWER_SERVICE) as? PowerManager
      val status = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        powerManager?.currentThermalStatus ?: 0
      } else {
        0
      }
      getThermalStatusString(status)
    }

    OnStartObserving {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        val powerManager = appContext.reactContext?.getSystemService(Context.POWER_SERVICE) as? PowerManager
        powerManager?.addThermalStatusListener { status ->
          sendEvent("onThermalStateChange", mapOf(
            "state" to getThermalStatusString(status)
          ))
        }
      }
    }
  }

  private fun getThermalStatusString(status: Int): String {
    return when (status) {
      PowerManager.THERMAL_STATUS_NONE -> "NOMINAL"
      PowerManager.THERMAL_STATUS_LIGHT -> "FAIR"
      PowerManager.THERMAL_STATUS_MODERATE -> "SERIOUS"
      PowerManager.THERMAL_STATUS_SEVERE -> "CRITICAL"
      PowerManager.THERMAL_STATUS_CRITICAL -> "CRITICAL"
      PowerManager.THERMAL_STATUS_EMERGENCY -> "CRITICAL"
      PowerManager.THERMAL_STATUS_SHUTDOWN -> "CRITICAL"
      else -> "UNKNOWN"
    }
  }
}
