import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueuedCommand {
  final String id;
  final String label;
  final String method;
  final String path;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  String status; // 'pending', 'processing', 'failed'

  QueuedCommand({
    required this.id,
    required this.label,
    required this.method,
    required this.path,
    required this.timestamp,
    this.data,
    this.status = 'pending',
  });

  QueuedCommand copyWith({String? status}) {
    return QueuedCommand(
      id: id,
      label: label,
      method: method,
      path: path,
      timestamp: timestamp,
      data: data,
      status: status ?? this.status,
    );
  }
}

class CommandQueueNotifier extends Notifier<List<QueuedCommand>> {
  @override
  List<QueuedCommand> build() {
    return [];
  }

  void add(QueuedCommand command) {
    state = [...state, command];
  }

  void updateStatus(String id, String status) {
    state = [
      for (final cmd in state)
        if (cmd.id == id) cmd.copyWith(status: status) else cmd
    ];
  }

  void remove(String id) {
    state = [
      for (final cmd in state)
        if (cmd.id != id) cmd
    ];
  }
}

final commandQueueProvider = NotifierProvider<CommandQueueNotifier, List<QueuedCommand>>(() {
  return CommandQueueNotifier();
});
