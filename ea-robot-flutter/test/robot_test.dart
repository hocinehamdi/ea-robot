import 'package:flutter_test/flutter_test.dart';
import 'package:ea_robot/domain/entities/robot.dart';
import 'package:ea_robot/data/models/robot_model.dart';

void main() {
  group('RobotModel Tests', () {
    test('fromJson should correctly map all fields including various ThermalStates', () {
      final jsonNominal = {
        'connected': true,
        'battery': 100,
        'thermalState': 'nominal',
        'moving': false,
      };
      final jsonSerious = {
        'connected': false,
        'battery': 25.5,
        'thermalState': 'serious',
        'moving': true,
      };

      final robot1 = RobotModel.fromJson(jsonNominal);
      final robot2 = RobotModel.fromJson(jsonSerious);

      expect(robot1.thermalState, ThermalState.nominal);
      expect(robot1.battery, 100.0);
      
      expect(robot2.thermalState, ThermalState.serious);
      expect(robot2.connected, isFalse);
      expect(robot2.moving, isTrue);
    });

    test('fromJson should handle missing or null fields gracefully', () {
      final jsonMinimal = {
        'battery': 50,
      };

      final robot = RobotModel.fromJson(jsonMinimal);

      expect(robot.connected, isFalse); // Default
      expect(robot.battery, 50.0);
      expect(robot.thermalState, ThermalState.nominal); // Default
      expect(robot.moving, isFalse); // Default
    });

    test('fromJson should handle invalid thermalState strings by defaulting to nominal', () {
      final jsonInvalid = {
        'battery': 50,
        'thermalState': 'OVERHEATING_DANGER',
      };

      final robot = RobotModel.fromJson(jsonInvalid);
      expect(robot.thermalState, ThermalState.nominal);
    });

    test('ThermalState fromString mapping case-insensitivity', () {
      final jsonLower = {
        'battery': 50,
        'thermalState': 'critical',
      };
      final jsonUpper = {
        'battery': 50,
        'thermalState': 'CRITICAL',
      };

      expect(RobotModel.fromJson(jsonLower).thermalState, ThermalState.critical);
      expect(RobotModel.fromJson(jsonUpper).thermalState, ThermalState.critical);
    });

    test('Robot copyWith should preserve values correctly', () {
      final robot = Robot(
        connected: true,
        battery: 50,
        thermalState: ThermalState.nominal,
        deviceThermalState: ThermalState.fair,
        moving: false,
      );

      final updated = robot.copyWith(battery: 99, moving: true);

      expect(updated.battery, 99);
      expect(updated.moving, isTrue);
      expect(updated.connected, isTrue); // Preserved
      expect(updated.deviceThermalState, ThermalState.fair); // Preserved
    });
  });
}
