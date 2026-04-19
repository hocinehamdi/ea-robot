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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactMetric(
              icon: Icons.battery_std,
              label: 'POWER',
              value: '${current?.battery.toStringAsFixed(0)}%',
              color: _getBatteryColor(current?.battery ?? 0),
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildCompactMetric(
              icon: Icons.precision_manufacturing,
              label: 'HUMANOID',
              value: current?.thermalState.name.toUpperCase() ?? "--",
              color: _getThermalColor(current?.thermalState),
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildCompactMetric(
              icon: Icons.developer_mode,
              label: 'CONTROLLER',
              value: current?.deviceThermalState.name.toUpperCase() ?? "--",
              color: _getThermalColor(current?.deviceThermalState),
              isNative: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white10,
    );
  }

  Widget _buildCompactMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isNative = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isNative ? Colors.blueAccent : Colors.white54,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isNative
                ? Colors.blueAccent.withOpacity(0.7)
                : Colors.white38,
            fontSize: 7,
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

  Color _getThermalColor(ThermalState? state) {
    switch (state) {
      case ThermalState.nominal:
        return Colors.greenAccent;
      case ThermalState.fair:
        return Colors.orangeAccent;
      case ThermalState.serious:
        return Colors.redAccent;
      case ThermalState.critical:
        return Colors.deepOrange;
      default:
        return Colors.white;
    }
  }

  Color _getBatteryColor(double battery) {
    if (battery > 50) return Colors.greenAccent;
    if (battery > 20) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
