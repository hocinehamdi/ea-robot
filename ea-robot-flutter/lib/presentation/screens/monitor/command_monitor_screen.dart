import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/api/command_queue.dart';

class CommandMonitorScreen extends ConsumerWidget {
  const CommandMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(commandQueueProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COMMAND MONITOR',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: baseColor),
        ),
        iconTheme: IconThemeData(color: baseColor),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3), const Color(0xFFE0EAFC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(queue.length, baseColor),
                const SizedBox(height: 20),
                Expanded(
                  child: queue.isEmpty
                      ? _buildEmptyState(baseColor)
                      : ListView.builder(
                          itemCount: queue.length,
                          itemBuilder: (context, index) {
                            final command = queue[index];
                            return _buildCommandCard(command, baseColor);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count, Color baseColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PENDING OPERATIONS',
              style: TextStyle(
                color: baseColor.withValues(alpha: 0.38),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '$count ACTIVE COMMANDS',
              style: TextStyle(
                color: baseColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: count > 0
                ? Colors.orangeAccent.withValues(alpha: 0.1)
                : Colors.greenAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: count > 0 ? Colors.orangeAccent : Colors.greenAccent,
              width: 2,
            ),
          ),
          child: Icon(
            count > 0 ? Icons.sync : Icons.check_circle_outline,
            color: count > 0 ? Colors.orangeAccent : Colors.greenAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color baseColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: baseColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'SYSTEM CALIBRATED',
            style: TextStyle(
              color: baseColor.withValues(alpha: 0.24),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            'No pending resilient operations',
            style: TextStyle(color: baseColor.withValues(alpha: 0.1), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard(QueuedCommand command, Color baseColor) {
    final timeStr = DateFormat('HH:mm:ss').format(command.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _getStatusIndicator(command.status),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      command.label,
                      style: TextStyle(
                        color: baseColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: baseColor.withValues(alpha: 0.24),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${command.method} ${command.path}',
                  style: TextStyle(
                    color: baseColor.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIndicator(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'processing':
        color = Colors.blueAccent;
        icon = Icons.hourglass_empty;
        break;
      case 'failed':
        color = Colors.redAccent;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.orangeAccent;
        icon = Icons.pending_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
