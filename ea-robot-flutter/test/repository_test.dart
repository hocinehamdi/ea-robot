import 'dart:async';
import 'dart:convert';

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

    test('disconnect should call POST /disconnect', () async {
      when(() => mockDio.post('/disconnect')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/disconnect'),
        ),
      );
      await repository.disconnect();
      verify(() => mockDio.post('/disconnect')).called(1);
    });

    test('move should call POST /move', () async {
      when(() => mockDio.post('/move')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/move'),
        ),
      );
      await repository.move();
      verify(() => mockDio.post('/move')).called(1);
    });

    test('stop should call POST /stop', () async {
      when(() => mockDio.post('/stop')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/stop'),
        ),
      );
      await repository.stop();
      verify(() => mockDio.post('/stop')).called(1);
    });

    group('SSE Telemetry Stream', () {
      test('getTelemetry should yield robot updates from stream', () async {
        final robotData = {
          'id': 'r1',
          'connected': true,
          'battery': 85.0,
          'thermalState': 'fair',
          'moving': true,
        };
        final sseLine = 'data: ${jsonEncode(robotData)}\n';
        final streamController = StreamController<Uint8List>();

        when(() => mockDio.get(
              '/telemetry',
              options: any(named: 'options'),
            )).thenAnswer((_) async => Response(
              data: ResponseBody(
                streamController.stream,
                200,
                headers: {
                  'content-type': ['text/event-stream']
                },
              ),
              statusCode: 200,
              requestOptions: RequestOptions(path: '/telemetry'),
            ));

        final telemetryStream = repository.getTelemetry();
        
        // Push data to stream
        streamController.add(Uint8List.fromList(utf8.encode(sseLine)));
        
        final robot = await telemetryStream.first;
        expect(robot.battery, 85.0);
        expect(robot.moving, isTrue);
        
        await streamController.close();
      });
    });

    group('Native MethodChannel Mapping', () {
      void setMockThermal(String value) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.engineeredarts.robot/telemetry'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getThermalState') return value;
            return null;
          },
        );
      }

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.engineeredarts.robot/telemetry'),
          null,
        );
      });

      test('FAIR mapping', () async {
        setMockThermal('FAIR');
        expect(await repository.getNativeThermalState(), ThermalState.fair);
      });

      test('CRITICAL mapping', () async {
        setMockThermal('CRITICAL');
        expect(await repository.getNativeThermalState(), ThermalState.critical);
      });

      test('Unknown string defaults to nominal', () async {
        setMockThermal('MELTING');
        expect(await repository.getNativeThermalState(), ThermalState.nominal);
      });
    });
  });
}
