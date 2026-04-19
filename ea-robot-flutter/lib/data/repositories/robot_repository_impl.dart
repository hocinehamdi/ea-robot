import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/robot.dart';
import '../../domain/repositories/robot_repository.dart';
import '../models/robot_model.dart';

class RobotRepositoryImpl implements RobotRepository {
  final Dio _dio;
  static const _platform = MethodChannel('com.engineeredarts.robot/telemetry');

  RobotRepositoryImpl(this._dio);

  @override
  Future<void> connect() async {
    await _dio.post('/connect');
  }

  @override
  Future<void> disconnect() async {
    await _dio.post('/disconnect');
  }

  @override
  Future<Robot> getStatus() async {
    final response = await _dio.get('/status');
    return RobotModel.fromJson(response.data);
  }

  @override
  Future<void> move() async {
    await _dio.post('/move');
  }

  @override
  Future<void> stop() async {
    await _dio.post('/stop');
  }

  @override
  Stream<Robot> getTelemetry() async* {
    // DIO does not natively support ResponseType.stream for SSE on Flutter Web.
    // It will hang and buffer forever. We fallback to polling if on Web.
    if (kIsWeb) {
      while (true) {
        try {
          final robot = await getStatus();
          final nativeThermal = await getNativeThermalState();
          yield robot.copyWith(deviceThermalState: nativeThermal);
        } catch (_) {}
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // Native Platforms (Android/iOS) SSE Implementation
    print('[Telemetry] Opening SSE connection...');
    try {
      final response = await _dio.get(
        '/telemetry',
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream as Stream<Uint8List>;
      final lineStream = stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lineStream) {
        if (line.startsWith('data: ')) {
          final jsonData = line.substring(6);
          final robot = RobotModel.fromJson(jsonDecode(jsonData));

          final nativeThermal = await getNativeThermalState();

          final updatedRobot = robot.copyWith(
            deviceThermalState: nativeThermal,
          );

          yield updatedRobot;
        }
      }
    } catch (e, stack) {
      print('[Telemetry] SSE Stream Error: $e');
      print(stack);
    }
  }

  @override
  Future<ThermalState> getNativeThermalState() async {
    try {
      final String? state = await _platform.invokeMethod('getThermalState');
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
    } catch (e) {
      // Catches PlatformException and MissingPluginException on unsupported platforms like Web
      return ThermalState.nominal;
    }
  }
}
