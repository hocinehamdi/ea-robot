# Humanoid Robot Interaction App - Technical Test

## Overview
This application is a foundational mobile interface for interacting with a humanoid robot. It demonstrates a scalable, resilient architecture capable of handling the real-world complexities of hardware communication and intermittent connectivity.

## Architectural Decisions
- **Clean Architecture (Layered)**: Decouples business logic from the UI and data sources, enabling future-proof migrations (e.g., from REST to gRPC/WebSockets).
- **State Management & Dependency Injection (Riverpod)**: Riverpod operates as both the reactive state management solution (via `StateNotifierProvider` and `StreamProvider` for high-performance UI updates) and the DI container, securely decoupling network dependencies and repositories for high testability.
- **Networking & Real-time Telemetry**: Powered by `Dio` with custom interceptors for failure handling, and **Server-Sent Events (SSE)** for battery-efficient, live robot status streams.
- **Resilient Command Queue**: Implements an offline-first strategy where movement commands are locally queued during connectivity drops and automatically retried upon restoration.
- **Native Interoperability (Kotlin & Swift)**: Uses `MethodChannel` to interface with both Android's and iOS's native thermal states, providing low-level hardware diagnostics directly in the app across platforms.
- **Quality & Reliability**: Focused on automated testing of the connectivity lifecycle and core notification logic to ensure stability.

## Assumptions & Behavior
- **Connectivity**: The app assumes a "Disconnected" state by default. A heartbeat check is maintained via SSE to update the UI status in real-time.
- **Battery**: Simulated as a draining resource that updates the UI dynamically.
- **Random Failures**: The Mock API is configured to return a 500 error 10% of the time to test the app's error handling and retry logic.

---

## How to Run

### 1. Mock Server
The mock server exposes the following end-points:
- `GET /status` → `{ connected: boolean, battery: number, moving: boolean }`
- `POST /connect`
- `POST /disconnect`
- `POST /move`
- `POST /stop`

For more detailed API documentation, see the [Mock Server README](mock_server/README.md).

```bash
cd mock_server
npm install
npm start
```

### 2. Flutter App
For robust details about the Flutter environment, clean architecture routing, testing commands, and more, please reference the [Flutter Client README](ea-robot-flutter/README.md).

Ensure the Mock Server is running, then execute:

```bash
cd ea-robot-flutter
flutter pub get

# To run on a connected device/emulator
flutter run
```

---

## Testing

The project includes a multi-layered testing strategy covering domain logic, widgets, and end-to-end integration.

### 1. Unit & Widget Tests
Run all unit and widget tests:
```bash
cd ea-robot-flutter
flutter test
```

### 2. Integration (E2E) Tests
Integration tests verify the full lifecycle of the robot control. Ensure the Mock Server is running before executing.

> **Note for Physical Devices**: You must bridge the network to access the local server. For Android devices, run the following command before running the E2E tests to forward port `3000` from the Android device to the development machine:
> ```bash
> adb reverse tcp:3000 tcp:3000
> ```

```bash
flutter test integration_test/app_test.dart -d <ANDROID_DEVICE_ID>
```

### 3. Test Coverage
To generate and view a line-by-line coverage report:
```bash
flutter test --coverage
```

---

## Production Readiness Notes

If this system were to be scaled and deployed to production, several enhancements would be necessary to ensure security, high availability, and maintainability.

### Security, Compliance & App Hardening
- **Authentication & Authorization**: Implement robust user session management (e.g., **Firebase Auth**, **Auth0**, or **Keycloak**) to ensure only authorized operators can control the robot. Role-Based Access Control (RBAC) should be added to separate viewer-only access from control access.
- **Encrypted Channels (HTTPS)**: Enforce secure TLS/SSL encryption for REST APIs (via HTTPS) and Server-Sent Events to prevent packet spoofing and man-in-the-middle attacks when commanding the hardware.
- **API Key & Secrets Management**: Extract all hardcoded URLs and secrets into `.env` files using packages like `flutter_dotenv` to ensure secrets never leak into source control.
- **Code Obfuscation**: Enable ProGuard/R8 on Android and Stripping on iOS to reverse-engineer-proof your code binaries before publishing.

### Observability & Reliability
- **Crash Reporting**: Integrate native crash handling using **Firebase Crashlytics** or **Sentry** to capture and group fatal/non-fatal exceptions across Android and iOS.
- **Performance Monitoring**: Use **Firebase Performance** or **Datadog** to profile API request latencies, monitor App UI framerate drops (especially around heavy Lottie animations), and observe memory leaks.
- **Structured Logging**: Implement standardized JSON logging on the backend (e.g., using **Pino** or **Winston** on Node.js) feeding into an aggregator like **Datadog**, **AWS CloudWatch**, or the **ELK Stack** for complete traceability of command executions.
- **Analytics**: Use **Mixpanel** or **Google Analytics** to monitor operator interaction patterns (e.g., identifying features with low adoption or high error rates).

### DevOps & Infrastructure
- **CI/CD Pipelines**: Automate linting, unit/integration testing, and binary deployment processes using **GitHub Actions**, **GitLab CI**, or **Codemagic** (specifically for cross-platform Flutter builds).
- **Internal & Beta Testing Tracks**: Seamlessly distribute pre-release builds to internal stakeholders and QA via **Firebase App Distribution**, **TestFlight** (iOS), and **Google Play Internal Testing** (Android) to gather feedback before production releases.
- **Expanded Test Coverage**: Augment existing unit tests with robust End-to-End (E2E) test suites using **Patrol** or the native Flutter `integration_test` framework to verify actual on-device integration behaviors against the true remote API.

### Network Architecture
- **Robust Offline Support**: Implement a local database (like **Drift**, **Hive**, or **Isar**) so standard commands and state logs are cached securely on the device until an internet connection is restored.

### UX & Scalability
- **Remote Config & Feature Flags**: Integrate **Firebase Remote Config** or **LaunchDarkly** to dynamically roll out feature updates, adjust UI themes, or modify logic (such as retry timeout durations) without requiring operators to go through the App Store to update.
- **Push Notifications**: Use **Firebase Cloud Messaging (FCM)** to proactively alert operators via mobile push notifications if a robot's thermal state hits critical or its battery is dangerously low while the app is backgrounded.
- **Internationalization (i18n)**: Support operators globally by modularizing string resources using the official `flutter_localizations` package or code-generation tools like **Slang**.
- **Adaptive UI & Multi-Device Support**: Ensure the primary screens are fully responsive and adapt gracefully to larger devices like **tablets and foldables**.

### Dedicated User Accessibility (a11y)
- **VoiceOver / TalkBack Support**: Add robust Semantic labels (`Semantics` in Flutter) across all control interfaces so visually impaired operators can successfully command the robot relying entirely on device screen-readers.
