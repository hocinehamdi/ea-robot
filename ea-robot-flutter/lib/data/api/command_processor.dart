import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'command_queue.dart';
import '../../presentation/providers/robot_provider.dart';
import '../../domain/repositories/robot_repository.dart';

/// A service that handles deferred command execution.
/// It is NOT a Notifier to avoid build-phase recursion.
class CommandProcessor {
  final Ref ref;
  bool _isProcessing = false;
  StreamSubscription? _subscription;

  CommandProcessor(this.ref) {
    _init();
  }

  RobotRepository get _repository => ref.read(robotRepositoryProvider);

  void _init() {
    // Listen to the queue provider directly to trigger processing
    ref.listen<List<QueuedCommand>>(commandQueueProvider, (previous, next) {
      if (next.isNotEmpty && !_isProcessing) {
        _process();
      }
    }, fireImmediately: true);
  }

  Future<void> _process() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (true) {
      final queue = ref.read(commandQueueProvider);
      if (queue.isEmpty) break;

      final command = queue.first;

      try {
        // Update status for the UI monitor
        ref
            .read(commandQueueProvider.notifier)
            .updateStatus(command.id, 'processing');

        print('[CommandProcessor] Sending ${command.label} command (ID: ${command.id}) to robot...');
        if (command.path == '/move') {
          await _repository.move();
        } else if (command.path == '/stop') {
          await _repository.stop();
        } else if (command.path == '/connect') {
          await _repository.connect();
        } else if (command.path == '/disconnect') {
          await _repository.disconnect();
        } else {
          // Fallback for custom commands if any
          await ref.read(dioProvider).request(
            command.path,
            data: command.data,
            options: Options(method: command.method),
          );
        }

        print('[CommandProcessor] ${command.label} command (ID: ${command.id}) completed successfully');
        // Success - remove from queue
        ref.read(commandQueueProvider.notifier).remove(command.id);
      } catch (e) {
        print(
          '[CommandProcessor] Persistent failure for ${command.id}. Sleeping 5s...',
        );
        ref
            .read(commandQueueProvider.notifier)
            .updateStatus(command.id, 'failed');

        // Wait before next attempt at the head of the queue
        await Future.delayed(const Duration(seconds: 5));
        
        // Check if queue has changed (e.g. user cleared it) before looping
        if (ref.read(commandQueueProvider).isEmpty) break;
      }
    }

    _isProcessing = false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}

/// A permanent provider that keeps the processor alive in the background.
final commandProcessorProvider = Provider<CommandProcessor>((ref) {
  final processor = CommandProcessor(ref);
  ref.onDispose(() => processor.dispose());
  return processor;
});
