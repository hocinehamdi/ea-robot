# EA Robot Flutter Client

This is the primary Flutter application for interacting with the Engineered Arts humanoid robot. It serves as the mobile interface showcasing a highly resilient, offline-capable architecture designed for critical hardware control.

## Project Structure

This application adheres to **Clean Architecture** principles, enforcing separation of concerns:

* **`lib/domain/`**: The core business logic, including Entities (`Robot`) and Repository Interfaces (`RobotRepository`). Independent of any external packages like Flutter or Dio.
* **`lib/data/`**: The implementation layer. Includes `RobotRepositoryImpl`, DTOs (`RobotModel`), and network configuration components like custom `Dio` Interceptors for resiliency (`ResiliencyInterceptor`).
* **`lib/presentation/`**: The graphical interface. Contains screens, custom widgets, and **Riverpod** providers acting as the State Management and Dependency Injection container.

## Architecture Highlights

1. **Riverpod DI & State**: Providers inject dependencies down the tree. Real-time updates are driven via `StreamProvider` connecting to SSE endpoints.
2. **Resiliency Layer**: If the network drops or the robot API errors (e.g. 500), `ResiliencyInterceptor` handles automatic, escalating retries.
3. **Command Queue**: Hard failures are routed to an offline-first Queue (`CommandQueueNotifier`), persisting operator commands to retry automatically once the connection is restored.
4. **Platform Channels**: `MethodChannel` code resides in `android/app/src/main/kotlin/...` to tap directly into the low-level Android hardware Thermal APIs, bypassing standard generic limits.

## Generating the Environment
Ensure the mocked API robot backend is running before testing. See the [Root README](../README.md) for full system context.

To boot the Flutter app:

```bash
flutter pub get

# If running on Android Physical Device, establish the network bridge to localhost first:
adb reverse tcp:3000 tcp:3000

flutter run 
```

## Running Tests

This application contains Unit, Widget, and full E2E Integration tests.

```bash
# General tests
flutter test

# To see a complete coverage report
flutter test --coverage

# To run Integration tests (Requires active Node server)
flutter test integration_test/app_test.dart
```
