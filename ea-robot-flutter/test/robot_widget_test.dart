import 'package:ea_robot/domain/entities/robot.dart';
import 'package:ea_robot/domain/repositories/robot_repository.dart';
import 'package:ea_robot/presentation/providers/robot_provider.dart';
import 'package:ea_robot/presentation/screens/home/robot_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRobotRepository extends Mock implements RobotRepository {}

void main() {
  late MockRobotRepository mockRepository;

  setUp(() {
    mockRepository = MockRobotRepository();
  });

  testWidgets('RobotHomeScreen shows Offline state initially', (tester) async {
    final robot = Robot(
      connected: false,
      battery: 50.0,
      thermalState: ThermalState.nominal,
      deviceThermalState: ThermalState.nominal,
      moving: false,
    );

    when(() => mockRepository.getStatus()).thenAnswer((_) async => robot);
    when(() => mockRepository.getTelemetry()).thenAnswer((_) => Stream.value(robot));
    when(() => mockRepository.getNativeThermalState()).thenAnswer((_) async => ThermalState.nominal);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          robotRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(home: RobotHomeScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('STANDBY'), findsOneWidget);
    expect(find.text('CONNECT'), findsOneWidget);
  });
}
