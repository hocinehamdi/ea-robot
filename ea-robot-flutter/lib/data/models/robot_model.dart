import '../../domain/entities/robot.dart';

class RobotModel extends Robot {
  RobotModel({
    required super.connected,
    required super.battery,
    required super.thermalState,
    required super.deviceThermalState,
    required super.moving,
  });

  factory RobotModel.fromJson(Map<String, dynamic> json) {
    return RobotModel(
      connected: json['connected'] ?? false,
      battery: (json['battery'] as num).toDouble(),
      thermalState: _parseThermalState(json['thermalState']),
      deviceThermalState: ThermalState.nominal, // Local data, not from JSON
      moving: json['moving'] ?? false,
    );
  }

  static ThermalState _parseThermalState(String? state) {
    switch (state?.toUpperCase()) {
      case 'NOMINAL':
        return ThermalState.nominal;
      case 'FAIR':
        return ThermalState.fair;
      case 'SERIOUS':
        return ThermalState.serious;
      case 'CRITICAL':
        return ThermalState.critical;
      default:
        return ThermalState.nominal;
    }
  }
}
