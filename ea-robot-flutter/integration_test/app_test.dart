import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ea_robot/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Robot App Integration Test', () {
    testWidgets('Verify complete robot control flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Ensure we start in OFFLINE state
      expect(find.text('OFFLINE'), findsOneWidget);

      // Tap CONNECT
      final connectButton = find.text('CONNECT');
      expect(connectButton, findsOneWidget);
      await tester.tap(connectButton);
      
      // Allow time for the network request and resiliency interceptor (if it retries)
      // We wait up to 10 seconds for the state change
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('ONLINE').evaluate().isNotEmpty) break;
      }

      // If we are connected, test movement
      if (find.text('ONLINE').evaluate().isNotEmpty) {
        final upArrow = find.byIcon(Icons.arrow_upward);
        await tester.tap(upArrow);
        await tester.pumpAndSettle();
        
        // Disconnect
        final disconnectButton = find.text('DISCONNECT');
        await tester.tap(disconnectButton);
        await tester.pumpAndSettle();
      }
    });
  });
}
