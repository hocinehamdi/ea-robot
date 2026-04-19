import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ea_robot/data/api/command_queue.dart';

void main() {
  group('CommandQueueNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state is empty', () {
      final container = ProviderContainer();
      final queue = container.read(commandQueueProvider);
      expect(queue, isEmpty);
      container.dispose();
    });

    test('Add command appends to list', () {
      final container = ProviderContainer();
      final cmd = QueuedCommand(
        id: '1',
        label: 'MOVE',
        method: 'POST',
        path: '/move',
        timestamp: DateTime.now(),
      );

      container.read(commandQueueProvider.notifier).add(cmd);
      
      final state = container.read(commandQueueProvider);
      expect(state.length, 1);
      expect(state.first.id, '1');
      container.dispose();
    });

    test('updateStatus changes specific command status', () {
      final container = ProviderContainer();
      final cmd1 = QueuedCommand(
        id: '1', label: 'MOVE', method: 'POST', path: '/move', timestamp: DateTime.now()
      );
      final cmd2 = QueuedCommand(
        id: '2', label: 'STOP', method: 'POST', path: '/stop', timestamp: DateTime.now()
      );

      final notifier = container.read(commandQueueProvider.notifier);
      notifier.add(cmd1);
      notifier.add(cmd2);

      notifier.updateStatus('1', 'processing');

      final state = container.read(commandQueueProvider);
      expect(state.firstWhere((c) => c.id == '1').status, 'processing');
      expect(state.firstWhere((c) => c.id == '2').status, 'pending');
      container.dispose();
    });

    test('remove removes command by id', () {
      final container = ProviderContainer();
      final cmd = QueuedCommand(
        id: '99', label: 'TMP', method: 'DELETE', path: '/tmp', timestamp: DateTime.now()
      );

      container.read(commandQueueProvider.notifier).add(cmd);
      expect(container.read(commandQueueProvider), isNotEmpty);

      container.read(commandQueueProvider.notifier).remove('99');
      expect(container.read(commandQueueProvider), isEmpty);
      container.dispose();
    });

    test('Persistence: reloads from SharedPreferences correctly', () async {
      // 1. Setup - pre-load SharedPreferences with data
      final cmd = QueuedCommand(
        id: 'external-1', label: 'EXT', method: 'GET', path: '/e', timestamp: DateTime.now()
      );
      
      // Inject data directly into the mock backend
      SharedPreferences.setMockInitialValues({
        'robot_command_queue': jsonEncode([cmd.toJson()])
      });
      
      // 2. Initialize container (triggers build -> _loadQueue)
      final container = ProviderContainer();
      
      // 3. Wait for async _loadQueue to finish
      // We loop-check the state with a timeout
      bool loaded = false;
      for (int i = 0; i < 10; i++) {
        if (container.read(commandQueueProvider).isNotEmpty) {
          loaded = true;
          break;
        }
        await Future.delayed(const Duration(milliseconds: 20));
      }

      final state = container.read(commandQueueProvider);
      expect(loaded, isTrue, reason: 'Queue did not load in time');
      expect(state.first.id, 'external-1');
      
      container.dispose();
    });

    test('QueuedCommand JSON serialization', () {
      final cmd = QueuedCommand(
        id: 'j1',
        label: 'JSON',
        method: 'PUT',
        path: '/json',
        timestamp: DateTime.now(),
        data: {'key': 'value'},
      );

      final json = cmd.toJson();
      final fromJson = QueuedCommand.fromJson(json);

      expect(fromJson.id, cmd.id);
      expect(fromJson.data?['key'], 'value');
      expect(fromJson.timestamp.toIso8601String(), cmd.timestamp.toIso8601String());
    });
  });
}
