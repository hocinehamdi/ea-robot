import 'package:flutter_test/flutter_test.dart';
import 'package:ea_robot/domain/entities/robot.dart';
import 'package:ea_robot/data/models/robot_model.dart';

void main() {
  group('Robot Entity', () {
    test('fromJson should create valid Robot object', () {
      final json = {
        'id': 'robot-01',
        'connected': true,
        'battery': 85.5,
        'thermalState': 'nominal',
        'moving': false,
      };

      final robot = RobotModel.fromJson(json);

      expect(robot.connected, isTrue);
      expect(robot.battery, 85.5);
      expect(robot.thermalState, ThermalState.nominal);
      expect(robot.moving, isFalse);
    });

    test('ThermalState fromString mapping', () {
      expect(ThermalState.nominal.name, 'nominal');
      expect(ThermalState.critical.name, 'critical');
    });
  });
}
