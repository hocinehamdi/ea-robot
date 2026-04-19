import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ea_robot/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Robot App Full Integration', () {
    testWidgets('Verify complete robot control and telemetry flow', (tester) async {
      // Start the app
      app.main();
      // Pump initial frames. We use pump() with duration because of Lottie infinite animations
      await tester.pump(const Duration(seconds: 2));

      // 1. Initial State Check
      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.text('CONNECT'), findsOneWidget);

      // 2. Connection Flow
      await tester.tap(find.text('CONNECT'));
      
      // Wait for ONLINE status (max 15s for possible server retries)
      bool connected = false;
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('ONLINE').evaluate().isNotEmpty) {
          connected = true;
          break;
        }
      }
      
      expect(connected, isTrue, reason: 'Robot should connect to the mock server');

      // 3. Telemetry Verification
      // Check if battery percentage is visible (format: XX%)
      expect(find.textContaining('%'), findsOneWidget);
      // Check if thermal state labels from the domain (NOMINAL/FAIR/etc) are visible
      expect(find.text('BATTERY'), findsOneWidget);
      expect(find.text('ROBOT'), findsOneWidget);

      // 4. Command Execution (Move Forward)
      final upArrow = find.byIcon(Icons.arrow_upward);
      expect(upArrow, findsOneWidget);
      await tester.tap(upArrow);
      await tester.pump(const Duration(milliseconds: 500));

      // 5. Monitor Navigation
      // Tap the monitor icon (hub_outlined)
      final monitorIcon = find.byIcon(Icons.hub_outlined);
      await tester.tap(monitorIcon);
      await tester.pumpAndSettle();

      // Verify we are in the Command Monitor screen
      expect(find.text('Command Monitor'), findsOneWidget);
      expect(find.text('LIVE LOG'), findsOneWidget);
      
      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 6. Safe Disconnect
      final disconnectButton = find.byIcon(Icons.logout);
      expect(disconnectButton, findsOneWidget);
      await tester.tap(disconnectButton);
      
      // Wait for OFFLINE status
      bool disconnected = false;
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('OFFLINE').evaluate().isNotEmpty) {
          disconnected = true;
          break;
        }
      }
      expect(disconnected, isTrue);
    });
  });
}
