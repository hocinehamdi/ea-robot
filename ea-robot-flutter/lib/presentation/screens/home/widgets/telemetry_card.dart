import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/robot.dart';

class TelemetryCard extends StatelessWidget {
  final AsyncValue<Robot> telemetry;
  final AsyncValue<Robot> status;

  const TelemetryCard({
    super.key,
    required this.telemetry,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final current = telemetry.value ?? status.value;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: baseColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactMetric(
              icon: Icons.battery_std,
              label: 'BATTERY',
              value: '${current?.battery.toStringAsFixed(0)}%',
              color: _getBatteryColor(current?.battery ?? 0),
              baseColor: baseColor,
            ),
          ),
          _buildDivider(isDarkMode),
          Expanded(
            child: _buildCompactMetric(
              icon: Icons.person,
              label: 'ROBOT',
              value: current?.thermalState.name.toUpperCase() ?? "--",
              color: _getThermalColor(current?.thermalState, isDarkMode),
              baseColor: baseColor,
            ),
          ),
          _buildDivider(isDarkMode),
          Expanded(
            child: _buildCompactMetric(
              icon: Icons.phone_android,
              label: 'DEVICE',
              value: current?.deviceThermalState.name.toUpperCase() ?? "--",
              color: _getThermalColor(current?.deviceThermalState, isDarkMode),
              baseColor: baseColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDarkMode ? Colors.white10 : Colors.black12,
    );
  }

  Widget _buildCompactMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color baseColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: baseColor.withValues(alpha: 0.54)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: baseColor.withValues(alpha: 0.38),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Color _getThermalColor(ThermalState? state, bool isDarkMode) {
    switch (state) {
      case ThermalState.nominal:
        return isDarkMode ? Colors.greenAccent : Colors.green;
      case ThermalState.fair:
        return isDarkMode ? Colors.orangeAccent : Colors.orange;
      case ThermalState.serious:
        return isDarkMode ? Colors.redAccent : Colors.red;
      case ThermalState.critical:
        return Colors.deepOrange;
      default:
        return isDarkMode ? Colors.white : Colors.black;
    }
  }

  Color _getBatteryColor(double battery) {
    if (battery > 50) return Colors.greenAccent;
    if (battery > 20) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
