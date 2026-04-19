import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'method': method,
    'path': path,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'status': status,
  };

  factory QueuedCommand.fromJson(Map<String, dynamic> json) => QueuedCommand(
    id: json['id'],
    label: json['label'],
    method: json['method'],
    path: json['path'],
    timestamp: DateTime.parse(json['timestamp']),
    data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    status: json['status'],
  );

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
  static const _storageKey = 'robot_command_queue';

  @override
  List<QueuedCommand> build() {
    _loadQueue();
    return [];
  }

  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? queueJson = prefs.getString(_storageKey);
      if (queueJson != null) {
        final List<dynamic> decoded = jsonDecode(queueJson);
        state = decoded.map((item) => QueuedCommand.fromJson(item)).toList();
      }
    } catch (e) {
      print('[CommandQueue] Error loading queue: $e');
    }
  }

  Future<void> _persistQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        state.map((cmd) => cmd.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      print('[CommandQueue] Error persisting queue: $e');
    }
  }

  void add(QueuedCommand command) {
    state = [...state, command];
    _persistQueue();
  }

  void updateStatus(String id, String status) {
    state = [
      for (final cmd in state)
        if (cmd.id == id) cmd.copyWith(status: status) else cmd,
    ];
    _persistQueue();
  }

  void remove(String id) {
    state = [
      for (final cmd in state)
        if (cmd.id != id) cmd,
    ];
    _persistQueue();
  }
}

final commandQueueProvider =
    NotifierProvider<CommandQueueNotifier, List<QueuedCommand>>(() {
      return CommandQueueNotifier();
    });
