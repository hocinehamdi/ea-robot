import 'package:flutter_test/flutter_test.dart';
import 'package:ea_robot/data/api/command_queue.dart';

void main() {
  group('CommandQueueNotifier', () {
    late CommandQueueNotifier notifier;

    setUp(() {
      notifier = CommandQueueNotifier();
      // Since it's a Notifier but used raw for unit tests, we can just call build() to initialize state indirectly,
      // but state is protected, so for Riverpod Notifiers we typically test them by wrapping in a ProviderContainer.
    });

    // We can test the copyWith inside QueuedCommand too
    test('QueuedCommand copyWith', () {
      final cmd = QueuedCommand(
        id: '1',
        label: 'TEST',
        method: 'GET',
        path: '/test',
        timestamp: DateTime.now(),
      );
      final updated = cmd.copyWith(status: 'failed');
      expect(updated.id, cmd.id);
      expect(updated.status, 'failed');
    });
  });
}
