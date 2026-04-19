import '../entities/robot.dart';

abstract class RobotRepository {
  Future<Robot> getStatus();
  Future<void> connect();
  Future<void> disconnect();
  Future<void> move();
  Future<void> stop();
  Stream<Robot> getTelemetry();
  Future<ThermalState> getNativeThermalState();
}
