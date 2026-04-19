import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/api/resiliency_interceptor.dart';
import '../../presentation/providers/network_status_provider.dart';
import '../../data/api/command_queue.dart';
import '../../data/repositories/robot_repository_impl.dart';
import '../../data/api/command_processor.dart';
import '../../domain/entities/robot.dart';
import '../../domain/repositories/robot_repository.dart';

part 'robot_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  const baseUrl = 'http://localhost:3000';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    ResiliencyInterceptor(() => ref.read(networkStatusProvider.notifier)),
  );
  return dio;
}

@Riverpod(keepAlive: true)
RobotRepository robotRepository(Ref ref) {
  return RobotRepositoryImpl(ref.watch(dioProvider));
}

@riverpod
Stream<Robot> robotTelemetry(Ref ref) {
  return ref.watch(robotRepositoryProvider).getTelemetry();
}

@riverpod
class RobotStatus extends _$RobotStatus {
  @override
  FutureOr<Robot> build() {
    return ref.read(robotRepositoryProvider).getStatus();
  }

  Future<void> connect() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(robotRepositoryProvider).connect();
      return ref.read(robotRepositoryProvider).getStatus();
    });
  }

  Future<void> disconnect() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(robotRepositoryProvider).disconnect();
      return ref.read(robotRepositoryProvider).getStatus();
    });
  }

  Future<void> move() async {
    final command = QueuedCommand(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'MOVE',
      method: 'POST',
      path: '/move',
      timestamp: DateTime.now(),
      data: null,
      status: 'pending',
    );

    ref.read(commandQueueProvider.notifier).add(command);
  }

  Future<void> stop() async {
    final command = QueuedCommand(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'STOP',
      method: 'POST',
      path: '/stop',
      timestamp: DateTime.now(),
      status: 'pending',
    );

    ref.read(commandQueueProvider.notifier).add(command);
  }
}
