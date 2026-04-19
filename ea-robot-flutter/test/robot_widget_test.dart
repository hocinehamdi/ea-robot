import 'package:ea_robot/domain/entities/robot.dart';
import 'package:ea_robot/domain/repositories/robot_repository.dart';
import 'package:ea_robot/presentation/providers/robot_provider.dart';
import 'package:ea_robot/presentation/screens/home/robot_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

class MockRobotRepository extends Mock implements RobotRepository {}

void main() {
  late MockRobotRepository mockRepository;

  setUp(() {
    mockRepository = MockRobotRepository();
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        robotRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(home: RobotHomeScreen()),
    );
  }

  testWidgets('RobotHomeScreen shows Offline state and handles Connect action', (tester) async {
    final robot = Robot(
      connected: false,
      battery: 50.0,
      thermalState: ThermalState.nominal,
      deviceThermalState: ThermalState.nominal,
      moving: false,
    );

    when(() => mockRepository.getStatus()).thenAnswer((_) async => robot);
    when(() => mockRepository.getTelemetry()).thenAnswer((_) => Stream.value(robot));
    when(() => mockRepository.connect()).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.text('CONNECT'), findsOneWidget);

    await tester.tap(find.text('CONNECT'));
    await tester.pump();

    verify(() => mockRepository.connect()).called(1);
  });

  testWidgets('RobotHomeScreen shows Online state and handles Move action', (tester) async {
    final robot = Robot(
      connected: true,
      battery: 92.0,
      thermalState: ThermalState.nominal,
      deviceThermalState: ThermalState.nominal,
      moving: false,
    );

    when(() => mockRepository.getStatus()).thenAnswer((_) async => robot);
    when(() => mockRepository.getTelemetry()).thenAnswer((_) => Stream.value(robot));
    when(() => mockRepository.move()).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ONLINE'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);

    // Use arrow_upward as identified in ControlPanel
    final moveBtn = find.byIcon(Icons.arrow_upward);
    expect(moveBtn, findsOneWidget);
    await tester.tap(moveBtn);
    await tester.pump();

    verify(() => mockRepository.move()).called(1);
  });

  testWidgets('RobotHomeScreen displays Stop button when connected', (tester) async {
    final robot = Robot(
      connected: true,
      battery: 80.0,
      thermalState: ThermalState.nominal,
      deviceThermalState: ThermalState.nominal,
      moving: true,
    );

    when(() => mockRepository.getStatus()).thenAnswer((_) async => robot);
    when(() => mockRepository.getTelemetry()).thenAnswer((_) => Stream.value(robot));

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // ControlPanel shows Icons.stop regardless of moving status if connected
    expect(find.byIcon(Icons.stop), findsOneWidget);
  });

  testWidgets('RobotHomeScreen displays Thermal status in TelemetryCard', (tester) async {
    final robot = Robot(
      connected: true,
      battery: 80.0,
      thermalState: ThermalState.critical,
      deviceThermalState: ThermalState.nominal,
      moving: false,
    );

    when(() => mockRepository.getStatus()).thenAnswer((_) async => robot);
    when(() => mockRepository.getTelemetry()).thenAnswer((_) => Stream.value(robot));

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Critical shows up in TelemetryCard via label mapping
    expect(find.text('CRITICAL'), findsOneWidget);
    expect(find.text('NOMINAL'), findsOneWidget); // For device
  });
}
