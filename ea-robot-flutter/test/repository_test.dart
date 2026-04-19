import 'package:dio/dio.dart';
import 'package:ea_robot/data/repositories/robot_repository_impl.dart';
import 'package:ea_robot/domain/entities/robot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDio mockDio;
  late RobotRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = RobotRepositoryImpl(mockDio);
  });

  group('RobotRepositoryImpl', () {
    test('getStatus should return a Robot object on success', () async {
      final jsonResponse = {
        'id': 'robot-01',
        'connected': true,
        'battery': 100.0,
        'thermalState': 'nominal',
        'moving': false,
      };

      when(() => mockDio.get('/status')).thenAnswer(
        (_) async => Response(
          data: jsonResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/status'),
        ),
      );

      final result = await repository.getStatus();

      expect(result.connected, isTrue);
      expect(result.battery, 100.0);
      verify(() => mockDio.get('/status')).called(1);
    });

    test('connect should call POST /connect', () async {
      when(() => mockDio.post('/connect')).thenAnswer(
        (_) async => Response(
          data: {'status': 'success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/connect'),
        ),
      );

      await repository.connect();

      verify(() => mockDio.post('/connect')).called(1);
    });

    group('Native MethodChannel', () {
      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.engineeredarts.robot/telemetry'),
          null,
        );
      });

      test('getNativeThermalState should return ThermalState.serious', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.engineeredarts.robot/telemetry'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getThermalState') {
              return 'SERIOUS';
            }
            return null;
          },
        );

        final result = await repository.getNativeThermalState();
        expect(result, ThermalState.serious);
      });

      test('getNativeThermalState should default to nominal on exception', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.engineeredarts.robot/telemetry'),
          (MethodCall methodCall) async {
             throw PlatformException(code: 'UNAVAILABLE');
          },
        );

        final result = await repository.getNativeThermalState();
        expect(result, ThermalState.nominal);
      });
    });
  });
}
