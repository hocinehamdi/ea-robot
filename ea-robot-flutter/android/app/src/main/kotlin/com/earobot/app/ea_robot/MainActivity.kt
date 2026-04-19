package com.earobot.app.ea_robot

import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.engineeredarts.robot/telemetry"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getThermalState") {
                val thermalState = getThermalStatus()
                result.success(thermalState)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getThermalStatus(): String {
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            when (powerManager.currentThermalStatus) {
                PowerManager.THERMAL_STATUS_NONE -> "NOMINAL"
                PowerManager.THERMAL_STATUS_LIGHT -> "FAIR"
                PowerManager.THERMAL_STATUS_MODERATE -> "FAIR"
                PowerManager.THERMAL_STATUS_SEVERE -> "SERIOUS"
                PowerManager.THERMAL_STATUS_CRITICAL -> "CRITICAL"
                PowerManager.THERMAL_STATUS_EMERGENCY -> "CRITICAL"
                PowerManager.THERMAL_STATUS_SHUTDOWN -> "CRITICAL"
                else -> "NOMINAL"
            }
        } else {
            "NOMINAL"
        }
    }
}
