enum ThermalState {
  nominal,
  fair,
  serious,
  critical,
}

// Removed RobotMovement

class Robot {
  final bool connected;
  final double battery;
  final ThermalState thermalState;
  final ThermalState deviceThermalState;
  final bool moving;

  Robot({
    required this.connected,
    required this.battery,
    required this.thermalState,
    required this.deviceThermalState,
    required this.moving,
  });

  Robot copyWith({
    bool? connected,
    double? battery,
    ThermalState? thermalState,
    ThermalState? deviceThermalState,
    bool? moving,
  }) {
    return Robot(
      connected: connected ?? this.connected,
      battery: battery ?? this.battery,
      thermalState: thermalState ?? this.thermalState,
      deviceThermalState: deviceThermalState ?? this.deviceThermalState,
      moving: moving ?? this.moving,
    );
  }
}
